if centerPrototype then centerPrototype.stop() end

local prototype = {
  index = 0,
  variants = {
    {name = "Hairline", duration = 0.10, layers = {{width = 1, alpha = 0.24}}},
    {name = "Soft rim", duration = 0.14, layers = {{width = 3, alpha = 0.16}}},
    {name = "Soft halo", duration = 0.16, layers = {
      {width = 8, alpha = 0.035},
      {width = 4, alpha = 0.07},
      {width = 1, alpha = 0.20}
    }},
    {name = "Baseline", duration = 0, layers = {}}
  }
}

local function clearPreview()
  if prototype.timer then
    prototype.timer:stop()
    prototype.timer = nil
  end
  if prototype.canvas then
    prototype.canvas:delete()
    prototype.canvas = nil
  end
  if prototype.alert then
    hs.alert.closeSpecific(prototype.alert, 0)
    prototype.alert = nil
  end
end

function prototype.stop()
  clearPreview()
  if prototype.hotkey then
    prototype.hotkey:delete()
    prototype.hotkey = nil
  end
  if centerPrototype == prototype then centerPrototype = nil end
end

function prototype.preview(index, showLabel)
  local win = hs.window.focusedWindow()
  if not win or not win:isStandard() or win:isFullScreen() then return end
  local screen = win:screen()
  if not screen then return end

  clearPreview()
  prototype.index = index or (prototype.index % #prototype.variants + 1)
  local variant = prototype.variants[prototype.index]
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
  frame = win:frame()

  if #variant.layers > 0 then
    local padding = 10
    local canvas = hs.canvas.new({
      x = frame.x - padding,
      y = frame.y - padding,
      w = frame.w + 2 * padding,
      h = frame.h + 2 * padding
    })
    if canvas then
      prototype.canvas = canvas
      canvas:level("overlay"):clickActivating(false)
      for _, layer in ipairs(variant.layers) do
        canvas:appendElements({
          type = "rectangle",
          action = "stroke",
          frame = {x = padding, y = padding, w = frame.w, h = frame.h},
          roundedRectRadii = {xRadius = 12, yRadius = 12},
          strokeWidth = layer.width,
          strokeColor = {white = 0.5, alpha = layer.alpha}
        })
      end
      canvas:show():hide(variant.duration)
      prototype.timer = hs.timer.doAfter(variant.duration, function()
        if prototype.canvas == canvas then
          canvas:delete()
          prototype.canvas = nil
          prototype.timer = nil
        end
      end)
    end
  end

  if showLabel ~= false then
    prototype.alert = hs.alert.show(
      prototype.index .. "/" .. #prototype.variants .. ": " .. variant.name,
      {atScreenEdge = 1, textSize = 16, radius = 8, fadeInDuration = 0, fadeOutDuration = 0.08},
      screen,
      0.6
    )
  end
  return frame
end

prototype.hotkey = hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "p", function()
  prototype.preview()
end)
centerPrototype = prototype
return prototype
