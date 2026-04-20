require("hs.ipc")

hs.hotkey.bind({"shift", "alt", "cmd"}, "r", function()
  hs.alert.show("Reloading Hammerspoon!")
  hs.timer.doAfter(0.5, function()
    hs.reload()
  end)
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
-- Ctrl+h/j/k/l navigates iTerm2 split panes from the shell, and passes through
-- to vim so SwitchWindow() can handle vim splits first (falling back to panes).

local _navItems = {
  h = "Select Pane Left", j = "Select Pane Below",
  k = "Select Pane Above", l = "Select Pane Right",
}
local _ctrlNavMap = {[4]="h", [38]="j", [40]="k", [37]="l"}

-- Session UUID cache — avoids an osascript round-trip on every keypress.
-- Invalidated after pane navigation; refreshed when iTerm2 activates.
local _cachedUUID = nil
local _cacheTime  = 0
local _UUID_TTL   = 0.5  -- seconds

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

-- Returns true if an adjacent pane exists in dir from the current session.
-- Uses hs.axuielement (native Accessibility API, no subprocess) to read pane
-- frames. Screen coords: origin = top-left, Y increases downward.
--   h left:  neighbor's right (sx+sw) ≈ our left  (fx)
--   l right: neighbor's left  (sx)    ≈ our right (fx+fw)
--   k above: neighbor's bottom (sy+sh) ≈ our top  (fy)
--   j below: neighbor's top   (sy)    ≈ our bottom (fy+fh)
local function _paneExistsInDir(dir)
  local apps = hs.application.applicationsForBundleID("com.googlecode.iterm2")
  local app  = apps and apps[1]
  if not app then return false end

  local appEl   = hs.axuielement.applicationElement(app)
  local focused = appEl:attributeValue("AXFocusedUIElement")
  if not focused then return false end

  -- Walk up from the focused element to the AXScrollArea (the pane container).
  -- When vim is running, the focused element is vim's virtual text buffer whose
  -- AXFrame is the scrollable coordinate space (e.g. y=-279919, h=280841) —
  -- not the physical screen position. The AXScrollArea ancestor has the real frame.
  local paneEl = focused
  for _ = 1, 10 do
    if paneEl:attributeValue("AXRole") == "AXScrollArea" then break end
    local parent = paneEl:attributeValue("AXParent")
    if not parent then break end
    paneEl = parent
  end

  local ff = paneEl:attributeValue("AXFrame")
  if not ff then return false end

  -- Walk up from the pane to the outermost AXSplitGroup (the tab's pane container)
  local el = paneEl
  local splitGroup = nil
  for _ = 1, 10 do
    el = el:attributeValue("AXParent")
    if not el then break end
    local role = el:attributeValue("AXRole")
    if role == "AXSplitGroup" then splitGroup = el end
    if role == "AXGroup"      then break end
  end
  if not splitGroup then return false end

  -- Collect frames of all AXScrollArea elements (one per pane)
  local panes = {}
  local function collect(e)
    if e:attributeValue("AXRole") == "AXScrollArea" then
      local f = e:attributeValue("AXFrame")
      if f then panes[#panes+1] = f end
      return
    end
    for _, child in ipairs(e:attributeValue("AXChildren") or {}) do
      collect(child)
    end
  end
  collect(splitGroup)

  local tol = 10
  local fx, fy, fw, fh = ff.x, ff.y, ff.w, ff.h
  for _, f in ipairs(panes) do
    local sx, sy, sw, sh = f.x, f.y, f.w, f.h
    if math.abs(sx - fx) > 1 or math.abs(sy - fy) > 1 then  -- skip self
      if dir == "h" and math.abs((sx+sw)-fx) < tol and sy < fy+fh and sy+sh > fy then return true end
      if dir == "l" and math.abs(sx-(fx+fw)) < tol and sy < fy+fh and sy+sh > fy then return true end
      if dir == "k" and math.abs((sy+sh)-fy) < tol and sx < fx+fw and sx+sw > fx then return true end
      if dir == "j" and math.abs(sy-(fy+fh)) < tol and sx < fx+fw and sx+sw > fx then return true end
    end
  end
  return false
end

-- Debounce state: rapid successive calls keep only the latest direction.
local _navTimer   = nil
local _navPending = nil

local function _doNav(dir)
  _navTimer = nil
  if not _paneExistsInDir(dir) then return end
  local apps = hs.application.applicationsForBundleID("com.googlecode.iterm2")
  local app  = apps and apps[1]
  if app and _navItems[dir] then
    app:selectMenuItem({"Window", "Split Pane", "Select Split Pane", _navItems[dir]})
    _cachedUUID = nil
  end
end

-- Called from the eventtap (shell) and from vim's SwitchWindow() via `hs` IPC.
-- 50ms debounce: if another call arrives before the timer fires, the previous
-- direction is discarded and only the latest executes.
function navigateITermPane(dir)
  _navPending = dir
  if _navTimer then _navTimer:stop() end
  _navTimer = hs.timer.doAfter(0.05, function() _doNav(_navPending) end)
end

-- Sentinel file written by vim's VimEnter autocommand, named with the bare
-- session UUID. hs.fs.attributes is a direct stat — no shell spawn.
-- Also accepts old-format files (wXtXpX:UUID) for sessions not yet restarted.
local function vimInCurrentPane()
  local id = _getUUID()
  if not id or id == "" then return false end
  if hs.fs.attributes("/tmp/.vim_iterm_" .. id) then return true end
  -- backward compat: old sentinel format used full ITERM_SESSION_ID as filename
  return os.execute("ls /tmp/.vim_iterm_*" .. id .. " > /dev/null 2>&1") == true
end

-- Warm UUID cache when iTerm2 gains focus
local _appWatcher = hs.application.watcher.new(function(name, event, _app)
  if event == hs.application.watcher.activated and name == "iTerm2" then
    _refreshUUID()
  end
end)
_appWatcher:start()

ctrlNavTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local flags = event:getFlags()
  if not flags.ctrl or flags.alt or flags.cmd or flags.shift then return false end
  local dir = _ctrlNavMap[event:getKeyCode()]
  if not dir then return false end
  -- Direct call — frontmostApplication() is a fast native call (~1ms),
  -- caching it caused stale state after Hammerspoon reloads.
  local fa = hs.application.frontmostApplication()
  if not fa or fa:bundleID() ~= "com.googlecode.iterm2" then return false end
  if vimInCurrentPane() then return false end
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
