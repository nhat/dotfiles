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

hs.hotkey.bind({"alt"}, "f", function()
  local win = hs.window.focusedWindow()
  if not win or not win:isStandard() or win:isFullScreen() then return end
  local screen = win:screen()
  if not screen then return end

  local frame = screen:frame()
  local margin = spoon.MoveWindow.margin
  local ratio = spoon.MoveWindow.centerRatio
  local width = math.floor((frame.w - 2 * margin) * ratio.w)
  local height = math.floor((frame.h - 2 * margin) * ratio.h)
  win:setFrame({
    x = math.floor(frame.x + (frame.w - width) / 2),
    y = math.floor(frame.y + (frame.h - height) / 2),
    w = width,
    h = height
  }, 0)
end)

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
