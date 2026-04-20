--- ITermPaneNavigator.spoon
---
--- Ctrl+h/j/k/l: navigate iTerm2 split panes from the shell without cycling at
--- edges. In vim, splits are handled first; at a split edge vim writes a
--- direction to navFile and a pathwatcher here picks it up (~10-30ms, vs
--- ~80ms for the old shell+hs+IPC chain).
---
--- Setup in init.lua:
---   hs.loadSpoon("ITermPaneNavigator")
---   spoon.ITermPaneNavigator:start()
---
--- Setup in vim's SwitchWindow():
---   silent! call writefile([a:dir], '/tmp/.hs_nav_request')
---
--- vim also needs a VimEnter sentinel file for per-pane vim detection:
---   let s:uuid = matchstr($ITERM_SESSION_ID, '[^:]\+$')
---   if !empty(s:uuid)
---     autocmd VimEnter * silent! call writefile([], '/tmp/.vim_iterm_' . s:uuid)
---     autocmd VimLeave * silent! call delete('/tmp/.vim_iterm_' . s:uuid)
---   endif

local obj = {}
obj.__index = obj

obj.name    = "ITermPaneNavigator"
obj.version = "1.0"
obj.author  = "Nhat"
obj.license = "MIT"

-- ── Public configuration ──────────────────────────────────────────────────────

--- cooldown (number)
--- Per-direction cooldown in seconds after a navigation fires. Each of h/j/k/l
--- is independent, so pressing two different directions in quick succession both
--- work; rapid same-direction key-repeat is discarded. Default: 0.15
obj.cooldown = 0.15

--- uuidTTL (number)
--- How long to cache the current session UUID before re-querying via osascript.
--- Pre-warmed mid-cooldown so the next keypress rarely waits on it. Default: 2.0
obj.uuidTTL = 2.0

--- navFile (string)
--- File vim writes the direction to on a split-edge crossing. Must match the
--- path used in vim's SwitchWindow(). Default: "/tmp/.hs_nav_request"
obj.navFile = "/tmp/.hs_nav_request"

-- ── Constants ─────────────────────────────────────────────────────────────────

local _NAV_ITEMS   = { h="Select Pane Left", j="Select Pane Below", k="Select Pane Above", l="Select Pane Right" }
local _CTRL_KEYMAP = { [4]="h", [38]="j", [40]="k", [37]="l" }
local _TOL         = 10   -- pixel tolerance for adjacency

-- ── Pure helpers (no state, no self) ─────────────────────────────────────────

local function _iterm2App()
  local apps = hs.application.applicationsForBundleID("com.googlecode.iterm2")
  return apps and apps[1]
end

-- Walk focused element up to its AXScrollArea (real pane frame).
-- When vim is running the focused element is vim's virtual buffer with a
-- garbage frame; the AXScrollArea ancestor has the physical screen frame.
local function _findCurrentPane(app)
  local focused = hs.axuielement.applicationElement(app)
                    :attributeValue("AXFocusedUIElement")
  if not focused then return nil end
  local el = focused
  for _ = 1, 10 do
    if el:attributeValue("AXRole") == "AXScrollArea" then return el end
    local p = el:attributeValue("AXParent")
    if not p then return nil end
    el = p
  end
  return nil
end

-- Collect every AXScrollArea frame under the outermost AXSplitGroup.
local function _collectFrames(paneEl)
  local el = paneEl
  local sg = nil
  for _ = 1, 10 do
    el = el:attributeValue("AXParent")
    if not el then break end
    local r = el:attributeValue("AXRole")
    if r == "AXSplitGroup" then sg = el end
    if r == "AXGroup"      then break end
  end
  if not sg then return nil end
  local frames = {}
  local function collect(e)
    if e:attributeValue("AXRole") == "AXScrollArea" then
      local f = e:attributeValue("AXFrame")
      if f then frames[#frames+1] = {x=f.x, y=f.y, w=f.w, h=f.h} end
      return
    end
    for _, c in ipairs(e:attributeValue("AXChildren") or {}) do collect(c) end
  end
  collect(sg)
  return frames
end

-- ── Stateful helpers (receive self) ──────────────────────────────────────────

local function _refreshUUID(self)
  local raw = hs.execute(
    "osascript -e 'tell application \"iTerm2\" to get unique id of current session of current tab of current window' 2>/dev/null"
  )
  self._cachedUUID = raw:gsub("%s+", "")
  self._cacheTime  = hs.timer.secondsSinceEpoch()
end

local function _getUUID(self)
  if not self._cachedUUID
    or (hs.timer.secondsSinceEpoch() - self._cacheTime) > self.uuidTTL then
    _refreshUUID(self)
  end
  return self._cachedUUID
end

-- Check sentinel file written by vim's VimEnter autocommand.
local function _vimInCurrentPane(self)
  local id = _getUUID(self)
  if not id or id == "" then return false end
  if hs.fs.attributes("/tmp/.vim_iterm_" .. id) then return true end
  -- backward compat: old sentinel format (wXtXpX:UUID) for un-restarted sessions
  return os.execute("ls /tmp/.vim_iterm_*" .. id .. " > /dev/null 2>&1") == true
end

-- Returns {h,j,k,l} booleans for pane adjacency.
-- _findCurrentPane (~5-10ms) runs every call — always correct, handles
-- mouse-click pane switches without stale state.
-- _paneFrames (20-40ms to collect) is cached until the layout changes:
-- invalidated when the current pane's frame isn't found in the cache,
-- which catches new splits, resizes, and tab/window switches.
local function _paneLayout(self, app)
  local paneEl = _findCurrentPane(app)
  if not paneEl then return nil end
  local ff = paneEl:attributeValue("AXFrame")
  if not ff then return nil end

  -- Cache validation: all 4 dimensions must match (x,y only is not enough —
  -- panes in different tabs can share the same origin but differ in size).
  if self._paneFrames then
    local found = false
    for _, f in ipairs(self._paneFrames) do
      if math.abs(f.x-ff.x)<=2 and math.abs(f.y-ff.y)<=2
        and math.abs(f.w-ff.w)<=2 and math.abs(f.h-ff.h)<=2 then
        found = true; break
      end
    end
    if not found then self._paneFrames = nil end
  end
  if not self._paneFrames then
    self._paneFrames = _collectFrames(paneEl)
  end
  if not self._paneFrames then return nil end

  local L  = {h=false, j=false, k=false, l=false}
  local fx, fy, fw, fh = ff.x, ff.y, ff.w, ff.h
  for _, f in ipairs(self._paneFrames) do
    local sx, sy, sw, sh = f.x, f.y, f.w, f.h
    if math.abs(sx-fx) > 1 or math.abs(sy-fy) > 1 then
      if math.abs((sx+sw)-fx)<_TOL and sy<fy+fh and sy+sh>fy then L.h=true end
      if math.abs(sx-(fx+fw))<_TOL and sy<fy+fh and sy+sh>fy then L.l=true end
      if math.abs((sy+sh)-fy)<_TOL and sx<fx+fw and sx+sw>fx then L.k=true end
      if math.abs(sy-(fy+fh))<_TOL and sx<fx+fw and sx+sw>fx then L.j=true end
    end
  end
  return L
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- ITermPaneNavigator:navigate(dir)
--- Navigate to the adjacent iTerm2 pane in direction dir ("h","j","k","l").
--- Called from the eventtap (shell) and the pathwatcher (vim edge crossing).
--- Also exposed as the global navigateITermPane() for debugging.
function obj:navigate(dir)
  if self._cooldowns[dir] then return end
  local app = _iterm2App()
  if not app then return end
  local layout = _paneLayout(self, app)
  if not layout or not layout[dir] then return end
  app:selectMenuItem({"Window", "Split Pane", "Select Split Pane", _NAV_ITEMS[dir]})
  self._cachedUUID      = nil        -- pane changed; force UUID re-fetch
  self._cooldowns[dir]  = true
  hs.timer.doAfter(0.07, function() _refreshUUID(self) end)  -- pre-warm UUID
  hs.timer.doAfter(self.cooldown, function() self._cooldowns[dir] = false end)
end

--- ITermPaneNavigator:start()
--- Starts the eventtap, pathwatcher, app watcher, and frame-cache timer.
function obj:start()
  if self._navTap then self:stop() end   -- clean restart if called twice

  self._cachedUUID = nil
  self._cacheTime  = 0
  self._paneFrames = nil
  self._cooldowns  = {h=false, j=false, k=false, l=false}

  -- Global shim: keeps `hs -c 'navigateITermPane("h")'` working for debugging.
  navigateITermPane = function(dir) self:navigate(dir) end

  -- Invalidate frame cache every 5s (no IPC — just sets a variable to nil).
  self._frameTimer = hs.timer.doEvery(5, function() self._paneFrames = nil end)

  -- Warm UUID and invalidate frames when returning to iTerm2 from another app.
  self._appWatcher = hs.application.watcher.new(function(name, event, _)
    if event == hs.application.watcher.activated and name == "iTerm2" then
      _refreshUUID(self)
      self._paneFrames = nil
    end
  end)
  self._appWatcher:start()

  -- vim writes direction to navFile instead of spawning hs (~15ms vs ~80ms).
  io.open(self.navFile, "w"):close()   -- must exist before pathwatcher starts
  self._navWatcher = hs.pathwatcher.new(self.navFile, function()
    local fa = hs.application.frontmostApplication()
    if not fa or fa:bundleID() ~= "com.googlecode.iterm2" then return end
    local f = io.open(self.navFile, "r")
    if not f then return end
    local dir = (f:read("*l") or ""):gsub("[^hjkl]", "")
    f:close()
    if #dir == 1 then self:navigate(dir) end
  end)
  self._navWatcher:start()

  -- Intercept Ctrl+h/j/k/l at the HID level.
  self._navTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local flags = event:getFlags()
    if not flags.ctrl or flags.alt or flags.cmd or flags.shift then return false end
    local dir = _CTRL_KEYMAP[event:getKeyCode()]
    if not dir then return false end
    local fa = hs.application.frontmostApplication()
    if not fa or fa:bundleID() ~= "com.googlecode.iterm2" then return false end
    if _vimInCurrentPane(self) then return false end   -- let vim handle it
    if self._cooldowns[dir] then return true end        -- consume; per-dir cooldown
    self:navigate(dir)
    return true
  end)
  self._navTap:start()

  return self
end

--- ITermPaneNavigator:stop()
--- Stops all watchers, the eventtap, and the cache timer.
function obj:stop()
  if self._navTap     then self._navTap:stop();    self._navTap     = nil end
  if self._navWatcher then self._navWatcher:stop(); self._navWatcher = nil end
  if self._appWatcher then self._appWatcher:stop(); self._appWatcher = nil end
  if self._frameTimer then self._frameTimer:stop(); self._frameTimer = nil end
  navigateITermPane = nil
  return self
end

return obj
