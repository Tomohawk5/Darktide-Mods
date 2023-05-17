local mod = get_mod("warpcharges")

local Definitions = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_definitions")
local HudElementWarpChargesSettings = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Stamina = mod:original_require("scripts/utilities/attack/stamina")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local TalentSettings = mod:original_require("scripts/settings/buff/talent_settings")
local HudElementWarpCharges = class("HudElementWarpCharges", "HudElementBase")

local souls_info = {
	max_stacks = nil,
	max_duration = nil,
	current_stacks = 0,
	current_soul_progress = 0,
	damage_per_soul = nil
}
local function _is_warp_charge_buff(s)
    return s == "psyker_biomancer_souls" or s == "psyker_biomancer_souls_increased_max_stacks"
end

local function _set_orientation()
	local horizontal = (mod:get("gauge_orientation") == mod.orientation_options["orientation_option_horizontal"])

end

HudElementWarpCharges.init = function (self, parent, draw_layer, start_scale)
	HudElementWarpCharges.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._shields = {}
	self._shield_width = 0
	self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

	self._player = Managers.player:local_player(1)

    self._archetype_name = self._player:archetype_name()

	
    local profile		= self._player:profile()
    local souls_passive = TalentSettings.psyker_2.passive_1
	local extra_souls	= TalentSettings.psyker_2.offensive_2_1

	souls_info.max_stacks		= profile.talents.psyker_2_tier_5_name_1
								  and extra_souls.max_souls_talent or souls_passive.base_max_souls
	souls_info.damage_per_soul	= souls_passive.damage / souls_info.max_stacks
	souls_info.max_duration		= souls_passive.soul_duration

	mod:notify("Initialised!")
end

HudElementWarpCharges.destroy = function (self)
	HudElementWarpCharges.super.destroy(self)
end

HudElementWarpCharges._add_shield = function (self)
	self._shields[#self._shields + 1] = {}
end

HudElementWarpCharges._remove_shield = function (self)
	self._shields[#self._shields] = nil
end

HudElementWarpCharges.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementWarpCharges.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local widget = self._widgets_by_name.gauge
    if not widget then return end

    if self._archetype_name ~= "psyker" then
        widget.content.visible = false
        return
    end

	local gauge_style		= widget.style
	local value_text_style	= gauge_style.value_text
	local name_text_style	= gauge_style.name_text
	local warning_style		= gauge_style.warning

	if mod:get("gauge_orientation") == mod.orientation_options["orientation_option_horizontal"] then
		value_text_style.offset = {
			0,
			10,
			3
		}

		name_text_style.horizontal_alignment		= "left"
		name_text_style.text_horizontal_alignment	= "left"
		name_text_style.offset = {
			0,
			10,
			3
		}

		warning_style.angle = 0
	else
		value_text_style.offset = {
			-118,
			-86,
			3
		}

		name_text_style.horizontal_alignment		= "right"
		name_text_style.text_horizontal_alignment	= "right"
		name_text_style.offset = {
			-118,
			-104,
			3
		}

		warning_style.angle = 4.71239
	end

    self:_update_shield_amount()
	
	if mod:get("show_gauge") then
		widget.content.visible = true
	else
		self:_update_visibility(dt)
	end
end

HudElementWarpCharges._resize_shield = function (self)
	local shield_amount = souls_info.max_stacks or 0
	local bar_size = HudElementWarpChargesSettings.bar_size
	local segment_spacing = HudElementWarpChargesSettings.spacing
	local total_segment_spacing = segment_spacing * math.max(shield_amount - 1, 0)
	local total_bar_length = bar_size[1] - total_segment_spacing

	self._shield_width = math.round(shield_amount > 0 and total_bar_length / shield_amount or total_bar_length)
	local shield_height = 9

	local horizontal = mod:get("gauge_orientation") == mod.orientation_options["orientation_option_horizontal"]
	self._horizontal = horizontal

	local width  = horizontal and self._shield_width or shield_height
	local height = horizontal and shield_height or self._shield_width

	self:_set_scenegraph_size("shield", width, height)
end

HudElementWarpCharges._update_shield_amount = function (self)
	local shield_amount = souls_info.max_stacks or 0
	if shield_amount ~= self._shield_amount then
		local amount_difference = (self._shield_amount or 0) - shield_amount
		self._shield_amount = shield_amount

		self:_resize_shield()

		local add_shields = amount_difference < 0

		for i = 1, math.abs(amount_difference) do
			if add_shields then
				self:_add_shield()
			else
				self:_remove_shield()
			end
		end
	end
end

HudElementWarpCharges._update_visibility = function (self, dt)
	local draw = false
	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
		local player_unit_data = player_extensions.unit_data
		if player_unit_data then
            local specialization_resource_component = player_unit_data:read_component("specialization_resource")
			if  specialization_resource_component and specialization_resource_component.current_resource > 0 then
                draw = true
			end
		end
	end

	local alpha_speed = 3
	local alpha_multiplier = self._alpha_multiplier or 0

	if draw then
		alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
	else
		alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
	end

	self._alpha_multiplier = alpha_multiplier
end

HudElementWarpCharges._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
	if self._alpha_multiplier ~= 0 then
		local previous_alpha_multiplier = render_settings.alpha_multiplier
		render_settings.alpha_multiplier = self._alpha_multiplier

		HudElementWarpCharges.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
		self:_draw_shields(dt, t, ui_renderer)

		render_settings.alpha_multiplier = previous_alpha_multiplier
	end
end

local STAMINA_STATE_COLORS = {
	-- empty = {
	-- 	100,
	-- 	UIHudSettings.color_tint_secondary_3[2],
	-- 	UIHudSettings.color_tint_secondary_3[3],
	-- 	UIHudSettings.color_tint_secondary_3[4]
	-- },
	-- half = UIHudSettings.color_tint_main_3,
	-- full = UIHudSettings.color_tint_main_1
	full = { -- Color.ui_interatction_critical
		255,
		246,
		99,
		99
	},
	half = {
		255,
		158,
		64,
		64
	},
	empty = {
		100,
		76,
		31,
		31
	}
}

HudElementWarpCharges._draw_shields = function (self, dt, t, ui_renderer)
	local num_shields = self._shield_amount

    if not num_shields then return end

	if num_shields < 1 then return end

	local widget = self._shield_widget
	local widget_offset = widget.offset
	local shield_width = self._shield_width
	local bar_size = HudElementWarpChargesSettings.bar_size
	local max_glow_alpha = HudElementWarpChargesSettings.max_glow_alpha
	local half_distance = HudElementWarpChargesSettings.half_distance
	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
        local buff_extension = player_extensions.buff

        if buff_extension then
            local buffs = buff_extension:buffs()
            for i = 1, #buffs do
                local buff = buffs[i]
                local buff_name = buff:template_name()
                if _is_warp_charge_buff(buff_name) then
                    souls_info.current_stacks = buff:stack_count()
                    souls_info.current_soul_progress = buff:duration_progress()
                end
            end
        end
	end

	local value_text = ""
	local value_option = mod:get("gauge_value")
	local description = mod:get("gauge_value_text")

	if value_option == mod.value_options["value_option_damage"] then
		local value = math.clamp(souls_info.current_stacks, 0, souls_info.max_stacks) * souls_info.damage_per_soul
		value_text = string.format("%.0f%%", math.clamp(value, 0, 1) * 100)
	elseif value_option == mod.value_options["value_option_stacks"] then
		value_text = string.format("%.0fx", souls_info.current_stacks)
	elseif value_option == mod.value_options["value_option_time_percent"] then
		local value = souls_info.current_soul_progress
		value_text = string.format("%.0f%%", math.clamp(value, 0, 1) * 100)
	elseif value_option == mod.value_options["value_option_time_seconds"] then
		local value = souls_info.current_soul_progress * souls_info.max_duration
		value_text = string.format("%.0fs", value)
	end

	if description then
		value_text = mod:localize(value_option .. "_display") .. " " .. value_text
	end

	local gauge_widget = self._widgets_by_name.gauge
	gauge_widget.content.value_text = value_text

	local step_fraction = 1 / num_shields
	local spacing = HudElementWarpChargesSettings.spacing
	local shield_offset = (shield_width + spacing) * (num_shields - 1) * 0.5
	local shields = self._shields

    local souls_progress = ( souls_info.current_soul_progress + ( souls_info.current_stacks - 1 ) ) / souls_info.max_stacks

	for i = num_shields, 1, -1 do
		local shield = shields[i]

		if not shield then return end

		local end_value = i * step_fraction
		local start_value = end_value - step_fraction
		local is_full, is_half, is_empty = nil

		if souls_progress >= start_value + step_fraction * 0.5 then	is_full	= true
		elseif start_value < souls_progress then					is_half = true
		else														is_empty = true
		end

		local active_color = nil

		if is_empty then
			active_color = STAMINA_STATE_COLORS.empty
		elseif is_full then
			active_color = STAMINA_STATE_COLORS.full
		elseif is_half then
			active_color = STAMINA_STATE_COLORS.half
		end

		local widget_style = widget.style
		local widget_color = widget_style.full.color
		widget_color[1] = active_color[1]
		widget_color[2] = active_color[2]
		widget_color[3] = active_color[3]
		widget_color[4] = active_color[4]

		if  self._horizontal then
			widget_offset[1] = 0
			widget_offset[1] = shield_offset
		else
			local scenegraph_size = self:scenegraph_size("shield")
			local height = scenegraph_size.y
			widget_offset[1] = 4
			widget_offset[2] = height - shield_offset - 34
		end

		UIWidget.draw(widget, ui_renderer)

		shield_offset = shield_offset - shield_width - spacing
	end
end

return HudElementWarpCharges