local TERM = "com.superlogical.terminal"
local LABEL = "fleet"
local LOOP = "f=~/.claude/assistant/bin/assistant-fleet-loop; [ -x $f ] && exec $f 5 2>/dev/null; while :; do clear; ~/.claude/assistant/bin/assistant-board --no-seen; sleep 15; done"

local function must(res, err)
  if err ~= nil then error(err, 0) end
  return res
end

local function fleet_blocks()
  local ids = {}
  for _, b in ipairs(must(rex.session.list_blocks{}).blocks or {}) do
    if b.creator_name == TERM and b.label == LABEL then
      table.insert(ids, b.block_id)
    end
  end
  return ids
end

rex.action{
  name = "assistant_fleet_toggle",
  title = "Toggle assistant fleet view",
  description = "Show the assistant board tree in a right split, or close it",
  category = "assistant",
  keywords = "assistant fleet board mechanic workers",
  run = function(ctx)
    local open = fleet_blocks()
    if #open > 0 then
      for _, id in ipairs(open) do
        must(rex.call("block.close", { session_id = ctx.session_id, block_id = id }))
      end
      return { closed = open }
    end
    return must(rex.session.new_split{
      anchor_id = ctx.block_id,
      direction = "horizontal",
      side = "after",
      ratio = 0.35,
      focus = false,
      layout = rex.layout.block{
        flavor = TERM .. ".shell",
        label = LABEL,
        options = { command = { "/bin/zsh", "-lc", LOOP } },
      },
    })
  end,
}

rex.bind("shift+cmd+e", "assistant_fleet_toggle")
