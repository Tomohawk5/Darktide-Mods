local mod = get_mod("volleyfiretimer")

local _definitions = mod:io_dofile("/volleyfiretimer/scripts/mods/volleyfiretimer/UI/UI_definitions")

local vet_talents = require("scripts/settings/ability/archetype_talents/talents/veteran_talents")

local veteran_buff_templates = require(
    "scripts/settings/buff/archetype_buff_templates/veteran_buff_templates"
)

local buff_info = {
    stacks = 0,
    start = 0,
    active = false,
    was_active = false
}

local executioners_stance_template = veteran_buff_templates.veteran_combat_ability_stance_master
local voice_of_command_template = veteran_buff_templates.veteran_combat_ability_increase_toughness_to_coherency
local infiltrate_template = veteran_buff_templates.veteran_invisibility

local executioners_stance = {
    class_tag = "ranger",
    talent = vet_talents.veteran_combat_ability_stagger_nearby_enemies,
    buff_id = "veteran_combat_ability_stance_master",
    max_duration = 5,
    conditional_exit_func = executioners_stance_template.conditional_exit_func,
    notification = function()
        return string.format(
            "  Volley Fire  \nRefreshes : %-3d\nDuration : %-4.1f",
            buff_info.stacks - 1,
            Managers.time:time("gameplay") - buff_info.start
        )
    end,
    stacks = true,
    timer = true
}

local voice_of_command = {
    class_tag = "squad_leader",
    talent = vet_talents.veteran_combat_ability_increase_and_restore_toughness_to_coherency,
    buff_id = "veteran_combat_ability_increase_toughness_to_coherency",
    max_duration = voice_of_command_template.duration,
    conditional_exit_func = nil,
    notification = nil,
    stacks = false,
    timer = true
}

local infiltrate = {
    class_tag = "shock_trooper",
    talent = vet_talents.veteran_invisibility_on_combat_ability,
    buff_id = "veteran_invisibility",
    max_duration = 5,
    conditional_exit_func = infiltrate_template.conditional_exit_func,
    notification = function()
        return string.format(
            "  Infiltrate  \nDuration : %-4.1f",
            Managers.time:time("gameplay") - buff_info.start
        )
    end,
    stacks = false,
    timer = true
}

local combat_ability = nil

local HudElementVolleyFire = class("HudElementVolleyFire", "HudElementBase")
function HudElementVolleyFire:init(parent, draw_layer, start_scale)
    HudElementVolleyFire.super.init(self, parent, draw_layer, start_scale, _definitions)

    self._player = Managers.player:local_player(1)
    self._player_unit = self._player.player_unit
    self.archetype = Managers.player:local_player(1):archetype_name()

    self._widgets_by_name.volley_fire_duration.content.visible = mod:get("always_visible")

    local profile = self._player:profile()
    local player_talents = profile.talents
    if player_talents.veteran_combat_ability_stagger_nearby_enemies == 1 then
        combat_ability = voice_of_command
    elseif player_talents.veteran_invisibility_on_combat_ability == 1 then
        combat_ability = infiltrate
    else
        combat_ability = executioners_stance
    end
    if not mod:get("always_visible") then
        local widget = self._widgets_by_name.volley_fire_duration
        if widget then
            widget.content.timer_text = ""
            widget.content.stack_text = ""
        end
    end
end

local function _is_volley_fire_buff(s)
    return s == "veteran_combat_ability_stance_master"
end

function HudElementVolleyFire:update(dt, t, ui_renderer, render_settings, input_service)
    HudElementVolleyFire.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    if not combat_ability then return end
    if not self._player_unit then return end

    local widget = self._widgets_by_name.volley_fire_duration
    if not widget then return end

    if self.archetype ~= "veteran" then
        widget.content.visible = false
        return
    end

    local bar_enabled = mod:get("bar_enabled")
    local text_enabled = mod:get("text_enabled")
    local stack_enabled = mod:get("stack_enabled")
    local always_visible = mod:get("always_visible")

    if not (bar_enabled or text_enabled or stack_enabled) then
        return
    end

    local buff_extensions = ScriptUnit.extension(self._player_unit, "buff_system")
    if not buff_extensions then return end

    for _, buff in pairs(buff_extensions._buffs_by_index) do
        local template = buff:template()
        if combat_ability.buff_id == template.name then
            buff_info.stacks = buff:stack_count()

            local conditional_exit = combat_ability.conditional_exit_func and
            combat_ability.conditional_exit_func(buff._template_data, buff:template_context()) or false
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

            if text_enabled and combat_ability.timer then
                if buff_info.active then
                    widget.content.timer_text = string.format("%.1f", duration_percent * combat_ability.max_duration)
                else
                    widget.content.timer_text = ""
                end
                if (duration_percent == 0 or duration_percent == 1) then
                  widget.content.timer_text = always_visible and "0.0" or ""
                end
            end
        end

        if stack_enabled and combat_ability.stacks then
            if buff_info.active then
                widget.content.stack_text = (buff_info.stacks .. "x") or ""
            else
                widget.content.stack_text = always_visible and "00X" or ""
            end
        end
    end

    -- BUFF START
    if buff_info.active and not buff_info.was_active then
        buff_info.start = Managers.time:time("gameplay")
        widget.content.visible = true

        -- BUFF END
    elseif buff_info.was_active and not buff_info.active then
        if mod:get("stack_alert") and combat_ability.notification then
            mod:notify(combat_ability.notification())
        end
        widget.content.visible = always_visible
        widget.content.timer_text = ""
        widget.content.stack_text = ""
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
