local mod = get_mod("volleyfiretimer")

local _definitions = mod:io_dofile("/volleyfiretimer/scripts/mods/volleyfiretimer/UI/UI_definitions")

local veteran_ranger_buff_templates = require(
  "scripts/settings/buff/player_archetype_specialization/veteran_buff_templates_new"
)

local ranged_stance_template = veteran_ranger_buff_templates.veteran_combat_ability_stance_master

local HudElementVolleyFire = class("HudElementVolleyFire", "HudElementBase")

local buff_info = {
  stacks = 0,
  start = 0,
  active = false,
  was_active = false
}

function HudElementVolleyFire:init(parent, draw_layer, start_scale)
  HudElementVolleyFire.super.init(self, parent, draw_layer, start_scale, _definitions)

  self._player_unit = Managers.player:local_player(1).player_unit
  self.archetype = Managers.player:local_player(1):archetype_name()

  self._widgets_by_name.volley_fire_duration.content.visible = mod:get("always_visible")
end

local function _is_volley_fire_buff(s)
  return s == "veteran_combat_ability_stance_master"
end

function HudElementVolleyFire:update(dt, t, ui_renderer, render_settings, input_service)
  HudElementVolleyFire.super.update(self, dt, t, ui_renderer, render_settings, input_service)

  local widget = self._widgets_by_name.volley_fire_duration
  if not widget then
    return
  end

  if self.archetype ~= "veteran" then
    widget.content.visible = false
    return
  end

  local bar_enabled = mod:get("bar_enabled")
  local text_enabled = mod:get("text_enabled")
  local stack_enabled = mod:get("stack_enabled")

  if not (bar_enabled or text_enabled or stack_enabled) then
    return
  end

  if self._player_unit then
    local buff_extensions = ScriptUnit.extension(self._player_unit, "buff_system")
    if buff_extensions then
      for _, buff in pairs(buff_extensions._buffs_by_index) do
        local template = buff:template()
        if _is_volley_fire_buff(template.name) then
          local conditional_exit = ranged_stance_template.conditional_exit_func(
            buff._template_data,
            buff:template_context()
          )
          local duration_percent = buff:duration_progress() or 0

          buff_info.active = not (conditional_exit or duration_percent <= 0.002)
          if not buff_info.active then
            duration_percent = 1
          end

          local timer_style = widget.style
          local bar_width = mod:get("bar_width")
          local bar_height = mod:get("bar_height")

          if bar_enabled then
            local bar = timer_style.timer_bar
            local bar_border = timer_style.timer_bar_border
            local bar_orientation = mod:get("bar_orientation")
            local bar_border_enabled = mod:get("bar_border_enabled")

            local width = bar_orientation == mod.orientation_options.horizontal
                and mod.lerp(0, bar_width, duration_percent) or bar_width
            local height = bar_orientation == mod.orientation_options.vertical
                and mod.lerp(0, bar_height, duration_percent) or bar_height

            bar.size[1] = width
            bar.size[2] = height

            if bar_border_enabled then
              bar_border.size[1] = width
              bar_border.size[2] = height
            end
          end

          if text_enabled then
            widget.content.timer_text = string.format("%.1f", duration_percent * 5) or ""
          end

          if stack_enabled then
            buff_info.stacks = buff:stack_count()
            if buff_info.active then
              widget.content.stack_text = (buff_info.stacks .. "x") or ""
            else
              widget.content.stack_text = "00x"
            end
          end
        end
      end
    end

    -- BUFF START
    if buff_info.active and not buff_info.was_active then
      buff_info.start = Managers.time:time("gameplay")
      widget.content.visible = true

    -- BUFF END
    elseif buff_info.was_active and not buff_info.active then
      if mod:get("stack_alert") then
        local text = string.format(
          "  Volley Fire  \nRefreshes : %-3d\nDuration : %-4.1f",
          buff_info.stacks - 1,
          Managers.time:time("gameplay") - buff_info.start
        )
        mod:notify(text)
      end
      widget.content.visible = mod:get("always_visible")
    end
  end
  buff_info.was_active = buff_info.active
end

function HudElementVolleyFire:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
  if mod._is_in_hub() then
    return
  end

  HudElementVolleyFire.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
end

return HudElementVolleyFire
