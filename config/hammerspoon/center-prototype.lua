if centerPrototype then centerPrototype.stop() end

local prototype = {duration = 0.08}

function prototype.stop()
  if prototype.hotkey then
    prototype.hotkey:delete()
    prototype.hotkey = nil
  end
  if centerPrototype == prototype then centerPrototype = nil end
end

function prototype.preview()
  local win = hs.window.focusedWindow()
  if not win or not win:isStandard() or win:isFullScreen() then return end
  local screen = win:screen()
  if not screen then return end

  local frame = screen:frame()
  local margin = spoon.MoveWindow.margin
  local ratio = spoon.MoveWindow.centerRatio
  local width = math.floor((frame.w - 2 * margin) * ratio.w)
  local height = math.floor((frame.h - 2 * margin) * ratio.h)
  local target = {
    x = math.floor(frame.x + (frame.w - width) / 2),
    y = math.floor(frame.y + (frame.h - height) / 2),
    w = width,
    h = height
  }
  win:setFrame(target, prototype.duration)
  return target
end

prototype.hotkey = hs.hotkey.bind({"ctrl", "cmd", "shift"}, "m", function()
  prototype.preview()
end)
centerPrototype = prototype
return prototype
