require("hs.ipc")

hs.hotkey.bind({"shift", "alt", "cmd"}, "r", function()
  hs.alert.show("Reloading Hammerspoon!")
  hs.timer.doAfter(0.5, function() hs.reload() end)
end)

function caffeinateWatcher(event)
  if (event == hs.caffeinate.watcher.screensDidUnlock) then
    local gp = hs.window.find("GlobalProtect")
    if gp then gp:close() end
  end
end
cafWatcher = hs.caffeinate.watcher.new(caffeinateWatcher)
cafWatcher:start()

-- ── iTerm2 / vim pane navigator ──────────────────────────────────────────────

local _navItems   = { h="Select Pane Left", j="Select Pane Below", k="Select Pane Above", l="Select Pane Right" }
local _ctrlNavMap = { [4]="h", [38]="j", [40]="k", [37]="l" }

-- ── UUID cache ───────────────────────────────────────────────────────────────
local _cachedUUID = nil
local _cacheTime  = 0
local _UUID_TTL   = 2.0

local function _refreshUUID()
  local raw = hs.execute(
    "osascript -e 'tell application \"iTerm2\" to get unique id of current session of current tab of current window' 2>/dev/null"
  )
  _cachedUUID = raw:gsub("%s+", "")
  _cacheTime  = hs.timer.secondsSinceEpoch()
end

local function _getUUID()
  if not _cachedUUID or (hs.timer.secondsSinceEpoch() - _cacheTime) > _UUID_TTL then
    _refreshUUID()
  end
  return _cachedUUID
end

-- ── Pane geometry cache ───────────────────────────────────────────────────────
-- _paneFrames caches all AXScrollArea frames for the tab (the expensive part).
-- The current pane's frame is always fetched live via _findCurrentPane so the
-- layout check is never based on stale position data.

local _paneFrames = nil

-- Invalidate every 5s to pick up splits added/removed.
hs.timer.doEvery(5, function() _paneFrames = nil end)

local function _iterm2App()
  local apps = hs.application.applicationsForBundleID("com.googlecode.iterm2")
  return apps and apps[1]
end

-- Walk focused element up to its AXScrollArea (the real pane container).
-- When vim is running the focused element is vim's virtual buffer with a
-- garbage frame; the AXScrollArea ancestor has the physical screen frame.
local function _findCurrentPane(app)
  local focused = hs.axuielement.applicationElement(app):attributeValue("AXFocusedUIElement")
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

-- Collect every AXScrollArea frame in the outermost AXSplitGroup.
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

local TOL = 10

-- Returns {h,j,k,l} booleans.
-- _findCurrentPane (~5-10ms) is called every press — always correct.
-- _collectFrames (~20-40ms) is cached for 5s — only runs after splits change.
local function _paneLayout(app)
  local paneEl = _findCurrentPane(app)
  if not paneEl then return nil end
  local ff = paneEl:attributeValue("AXFrame")
  if not ff then return nil end
  if not _paneFrames then
    _paneFrames = _collectFrames(paneEl)
  end
  if not _paneFrames then return nil end

  local L  = {h=false, j=false, k=false, l=false}
  local fx, fy, fw, fh = ff.x, ff.y, ff.w, ff.h
  for _, f in ipairs(_paneFrames) do
    local sx, sy, sw, sh = f.x, f.y, f.w, f.h
    if math.abs(sx-fx) > 1 or math.abs(sy-fy) > 1 then
      if math.abs((sx+sw)-fx)<TOL and sy<fy+fh and sy+sh>fy then L.h=true end
      if math.abs(sx-(fx+fw))<TOL and sy<fy+fh and sy+sh>fy then L.l=true end
      if math.abs((sy+sh)-fy)<TOL and sx<fx+fw and sx+sw>fx then L.k=true end
      if math.abs(sy-(fy+fh))<TOL and sx<fx+fw and sx+sw>fx then L.j=true end
    end
  end
  return L
end

-- ── Per-direction cooldown ────────────────────────────────────────────────────
-- Each direction has an independent 150ms cooldown so pressing k then l in
-- quick succession works (different cooldowns), while rapid same-direction
-- key-repeat events are discarded (same cooldown).
local _cooldown = {h=false, j=false, k=false, l=false}
local _COOLDOWN = 0.15

function navigateITermPane(dir)
  if _cooldown[dir] then return end
  local app = _iterm2App()
  if not app then return end
  local layout = _paneLayout(app)
  if not layout or not layout[dir] then return end
  app:selectMenuItem({"Window", "Split Pane", "Select Split Pane", _navItems[dir]})
  _cachedUUID = nil               -- force UUID re-fetch (session changed)
  _cooldown[dir] = true
  hs.timer.doAfter(0.07, _refreshUUID)                            -- pre-warm UUID
  hs.timer.doAfter(_COOLDOWN, function() _cooldown[dir] = false end)
end

-- ── vim → navigator IPC via pathwatcher ──────────────────────────────────────
local _NAV_FILE = "/tmp/.hs_nav_request"
io.open(_NAV_FILE, "w"):close()

_navWatcher = hs.pathwatcher.new(_NAV_FILE, function()
  local fa = hs.application.frontmostApplication()
  if not fa or fa:bundleID() ~= "com.googlecode.iterm2" then return end
  local f = io.open(_NAV_FILE, "r")
  if not f then return end
  local dir = (f:read("*l") or ""):gsub("[^hjkl]", "")
  f:close()
  if #dir == 1 then navigateITermPane(dir) end
end)
_navWatcher:start()

-- ── Sentinel / vim detection ─────────────────────────────────────────────────
local function vimInCurrentPane()
  local id = _getUUID()
  if not id or id == "" then return false end
  if hs.fs.attributes("/tmp/.vim_iterm_" .. id) then return true end
  return os.execute("ls /tmp/.vim_iterm_*" .. id .. " > /dev/null 2>&1") == true
end

local _appWatcher = hs.application.watcher.new(function(name, event, _)
  if event == hs.application.watcher.activated and name == "iTerm2" then
    _refreshUUID()
  end
end)
_appWatcher:start()

-- ── Eventtap ─────────────────────────────────────────────────────────────────
ctrlNavTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local flags = event:getFlags()
  if not flags.ctrl or flags.alt or flags.cmd or flags.shift then return false end
  local dir = _ctrlNavMap[event:getKeyCode()]
  if not dir then return false end
  local fa = hs.application.frontmostApplication()
  if not fa or fa:bundleID() ~= "com.googlecode.iterm2" then return false end
  if vimInCurrentPane() then return false end
  if _cooldown[dir] then return true end      -- consume; per-direction cooldown
  navigateITermPane(dir)
  return true
end)
ctrlNavTap:start()

-- ─────────────────────────────────────────────────────────────────────────────

hs.loadSpoon("Marginator")
spoon.Marginator:start()

hs.loadSpoon("MoveWindow")
spoon.MoveWindow:start()

hs.loadSpoon("MoveSpace")
spoon.MoveSpace:start()
