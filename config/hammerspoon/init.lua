require("hs.ipc")

hs.hotkey.bind({"shift", "alt", "cmd"}, "r", function()
  hs.alert.show("Reloading Hammerspoon!")
  -- Add a short delay before reloading to ensure the alert is shown
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

-- Navigate iTerm2 split panes; called via `hs` IPC from vim at split edges
function navigateITermPane(dir)
  local items = {h="Select Pane Left", j="Select Pane Below", k="Select Pane Above", l="Select Pane Right"}
  local apps = hs.application.applicationsForBundleID("com.googlecode.iterm2")
  local app = apps and apps[1]
  if app and items[dir] then
    app:selectMenuItem({"Window", "Split Pane", "Select Split Pane", items[dir]})
  end
end

-- Ctrl+h/j/k/l: navigate iTerm2 panes when at shell; pass through to vim when vim is running
-- Uses hardware key codes: h=4, j=38, k=40, l=37
local ctrlNavMap = {[4]="h", [38]="j", [40]="k", [37]="l"}

local function vimInCurrentPane()
  -- AppleScript returns the UUID part; ITERM_SESSION_ID format is "wXtXpX:UUID"
  -- so we search for a sentinel file whose name contains the current session's UUID
  local id = hs.execute("osascript -e 'tell application \"iTerm2\" to get unique id of current session of current tab of current window' 2>/dev/null")
  id = id:gsub("%s+", "")
  if id == "" then return false end
  return os.execute("ls /tmp/.vim_iterm_*" .. id .. "* > /dev/null 2>&1") == true
end

ctrlNavTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  local flags = event:getFlags()
  if not flags.ctrl or flags.alt or flags.cmd or flags.shift then return false end

  local dir = ctrlNavMap[event:getKeyCode()]
  if not dir then return false end

  local app = hs.application.frontmostApplication()
  if not app or app:bundleID() ~= "com.googlecode.iterm2" then return false end

  if vimInCurrentPane() then return false end -- let vim handle it

  navigateITermPane(dir)
  return true -- consume event
end)
ctrlNavTap:start()

hs.loadSpoon("Marginator")
spoon.Marginator:start()

hs.loadSpoon("MoveWindow")
spoon.MoveWindow:start()

hs.loadSpoon("MoveSpace")
spoon.MoveSpace:start()

