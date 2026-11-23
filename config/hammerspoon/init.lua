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

hs.hotkey.bind({"alt", "shift"}, "f", function()
  local app = hs.application.frontmostApplication()
  if app then
    app:selectMenuItem({"Window", "Fill"})
  end
end)

for key, direction in pairs({h = "Left", l = "Right"}) do
  hs.hotkey.bind({"alt", "shift"}, key, function()
    local app = hs.application.frontmostApplication()
    if app then
      app:selectMenuItem({"Window", "Move & Resize", direction})
    end
  end)
end

hs.loadSpoon("MoveSpace")
spoon.MoveSpace:start()

hs.loadSpoon("ITermPaneNavigator")
spoon.ITermPaneNavigator:start()

local previousApp, currentApp = nil, hs.application.frontmostApplication()
appWatcher = hs.application.watcher.new(function(_, event, app)
  if event == hs.application.watcher.activated and app and app ~= currentApp then
    previousApp, currentApp = currentApp, app
  end
end):start()

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "b", function()
  if previousApp and previousApp:isRunning() then
    previousApp:activate()
  else
    previousApp = nil
  end
end)
