local mod = get_mod("blitzbar")

mod._is_in_hub = function()
  local game_mode_name = Managers.state.game_mode:game_mode_name()
  return (game_mode_name == "hub" or game_mode_name == "prologue_hub")
end
