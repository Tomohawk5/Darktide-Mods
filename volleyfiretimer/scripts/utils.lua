local mod = get_mod("volleyfiretimer")

mod._print_table = function(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. mod._print_table(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

mod.lerp = function(a, b, t)
  return (1 - t) * a + t * b
end

mod._is_in_hub = function()
  local game_mode_name = Managers.state.game_mode:game_mode_name()
  return (game_mode_name == "hub" or game_mode_name == "prologue_hub")
end
