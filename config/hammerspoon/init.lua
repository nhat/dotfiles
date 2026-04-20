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

hs.loadSpoon("Marginator")
spoon.Marginator:start()

hs.loadSpoon("MoveWindow")
spoon.MoveWindow:start()

hs.loadSpoon("MoveSpace")
spoon.MoveSpace:start()

hs.loadSpoon("ITermPaneNavigator")
spoon.ITermPaneNavigator:start()
