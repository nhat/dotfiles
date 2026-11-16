if centerPrototype then centerPrototype.stop() end

local prototype = {duration = 0.12, interval = 1 / 120}
local axes = {"x", "y", "w", "h"}

local function cancelAnimation(finish)
  local animation = prototype.animation
  if not animation then return end
  prototype.animation = nil
  animation.timer:stop()
  if finish and animation.window:id() and not animation.window:isFullScreen() then
    animation.window:setFrame(animation.target, 0)
  end
end

function prototype.stop()
  cancelAnimation(true)
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

  local previous = prototype.animation
  cancelAnimation(previous and previous.window ~= win)
  local start = win:frame()
  local unchanged = true
  for _, axis in ipairs(axes) do
    if start[axis] ~= target[axis] then unchanged = false end
  end
  if unchanged then return target end

  local animation = {window = win, target = target, started = hs.timer.absoluteTime()}
  prototype.animation = animation
  animation.timer = hs.timer.doEvery(prototype.interval, function()
    if prototype.animation ~= animation then return end
    if not win:id() or win:isFullScreen() then
      cancelAnimation(false)
      return
    end
    local progress = math.min(1, (hs.timer.absoluteTime() - animation.started) / (prototype.duration * 1000000000))
    if progress >= 1 then
      cancelAnimation(true)
      return
    end
    local eased = progress * progress * (3 - 2 * progress)
    local nextFrame = {}
    for _, axis in ipairs(axes) do
      nextFrame[axis] = start[axis] + (target[axis] - start[axis]) * eased
    end
    win:setFrame(nextFrame, 0)
  end)
  return target
end

prototype.hotkey = hs.hotkey.bind({"ctrl", "cmd", "shift"}, "m", function()
  prototype.preview()
end)
centerPrototype = prototype
return prototype
