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
-- Uses frame geometry (Cocoa Y-up: origin = bottom-left):
--   h left:  neighbor's right (sx+sw) ≈ current left (cx)
--   l right: neighbor's left  (sx)    ≈ current right (cx+cw)
--   k above: neighbor's bottom (sy)   ≈ current top   (cy+ch)
--   j below: neighbor's top (sy+sh)   ≈ current bottom (cy)
local function _paneExistsInDir(dir)
  local as = ([[
tell application "iTerm2"
  try
    tell current tab of current window
      set curId to unique id of current session
      set curF to frame of current session
      set cx to item 1 of origin of curF
      set cy to item 2 of origin of curF
      set cw to item 1 of size of curF
      set ch to item 2 of size of curF
      repeat with s in sessions
        if unique id of s is not curId then
          set sf to frame of s
          set sx to item 1 of origin of sf
          set sy to item 2 of origin of sf
          set sw to item 1 of size of sf
          set sh to item 2 of size of sf
          if "DIR" is "h" and (sx+sw-cx)>=-10 and (sx+sw-cx)<=10 then return "true"
          if "DIR" is "l" and (sx-cx-cw)>=-10 and (sx-cx-cw)<=10 then return "true"
          if "DIR" is "k" and (sy-cy-ch)>=-10 and (sy-cy-ch)<=10 then return "true"
          if "DIR" is "j" and (sy+sh-cy)>=-10 and (sy+sh-cy)<=10 then return "true"
        end if
      end repeat
      return "false"
    end tell
  on error
    return "false"
  end try
end tell]]):gsub("DIR", dir)
  local result = hs.execute("osascript <<'__EOF__'\n" .. as .. "\n__EOF__\n 2>/dev/null")
  return result:gsub("%s+", "") == "true"
end

-- Called from vim's SwitchWindow() via `hs` IPC at vim split edges
function navigateITermPane(dir)
  if not _paneExistsInDir(dir) then return end  -- no cycle at edges
  local apps = hs.application.applicationsForBundleID("com.googlecode.iterm2")
  local app  = apps and apps[1]
  if app and _navItems[dir] then
    app:selectMenuItem({"Window", "Split Pane", "Select Split Pane", _navItems[dir]})
    _cachedUUID = nil  -- pane changed; force re-fetch on next call
  end
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
