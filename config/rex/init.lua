dofile(os.getenv("HOME") .. "/.config/hammerspoon/Spoons/ITermPaneNavigator.spoon/rex.lua")

rex.bind("cmd+.", "pane.send_key", { key = "ctrl+c" })
rex.bind("alt+delete", function(ctx)
  if not ctx.block_id then return false end
  local result, err = rex.block.call("com.superlogical.terminal", "write", {
    block_id = ctx.block_id,
    data = "\27d",
  })
  if not result then error(err, 0) end
  return true
end)

rex.bind("cmd+delete", function(ctx)
  if not ctx.block_id then return false end
  local result, err = rex.block.call("com.superlogical.terminal", "write", {
    block_id = ctx.block_id,
    data = "\11",
  })
  if not result then error(err, 0) end
  return true
end)

rex.bind("cmd+r", function(ctx)
  if not ctx.block_id then return false end
  local result, err = rex.block.call("com.superlogical.terminal", "write", {
    block_id = ctx.block_id,
    data = "\18",
  })
  if not result then error(err, 0) end
  return true
end)

rex.bind("cmd+p", function(ctx)
  if not ctx.block_id then return false end
  local result, err = rex.block.call("com.superlogical.terminal", "write", {
    block_id = ctx.block_id,
    data = "\16",
  })
  if not result then error(err, 0) end
  return true
end)
rex.bind("cmd+z", function(ctx)
  if not ctx.block_id then return false end
  local result, err = rex.block.call("com.superlogical.terminal", "write", {
    block_id = ctx.block_id,
    data = "\31",
  })
  if not result then error(err, 0) end
  return true
end)

rex.bind("cmd+shift+z", function(ctx)
  if not ctx.block_id then return false end
  local result, err = rex.block.call("com.superlogical.terminal", "write", {
    block_id = ctx.block_id,
    data = "\24\31",
  })
  if not result then error(err, 0) end
  return true
end)
require("rexdiff")
rex.bind("ctrl+shift+[", "client.tab.move.backward")
rex.bind("ctrl+shift+]", "client.tab.move.forward")
rex.bind("cmd+d", "pane.split.auto")
rex.unbind("cmd+shift+d")

require("fleet_toggle")
