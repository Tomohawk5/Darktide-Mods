local mod = get_mod("warpcharges")

local Definitions = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_definitions")
local HudElementWarpChargesSettings = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Stamina = mod:original_require("scripts/utilities/attack/stamina")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local TalentSettings = mod:original_require("scripts/settings/buff/talent_settings")
local HudElementWarpCharges = class("HudElementWarpCharges", "HudElementBase")

local resource_info = {
	max_stacks = nil,
	max_duration = nil,
	stacks = 0,
	progress = 0,
	damage_per_stack = nil,
	damage_boost = function (self)
		return math.clamp(self.stacks, 0, self.max_stacks) * self.damage_per_soul
	end
}

local function _is_warp_charge_buff(s)
    return s == "psyker_biomancer_souls" or s == "psyker_biomancer_souls_increased_max_stacks"
end

HudElementWarpCharges.init = function (self, parent, draw_layer, start_scale)
	HudElementWarpCharges.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._shields = {}
	self._shield_width = 0
	self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

	self._player = Managers.player:local_player(1)
    self._archetype_name = self._player:archetype_name()
    local profile		 = self._player:profile()

	if self._archetype_name == "psyker" then
		local souls_passive = TalentSettings.psyker_2.passive_1
		local extra_souls	= TalentSettings.psyker_2.offensive_2_1.max_souls_talent
		
		resource_info.max_stacks		= profile.talents.psyker_2_tier_5_name_1 and extra_souls or souls_passive.base_max_souls
		resource_info.damage_per_stack	= souls_passive.damage / extra_souls
		resource_info.max_duration		= souls_passive.soul_duration
		
	elseif self._archetype_name == "zealot" and mod:get("martyrdom") then
		local martyrdom_passive = TalentSettings.zealot_2.passive_1
		local extra_stacks = TalentSettings.zealot_2.offensive_2_3.max_stacks

		resource_info.max_stacks		= profile.talents.zealot_2_tier_5_name_3 and extra_stacks or martyrdom_passive.max_stacks
		resource_info.damage_per_stack	= martyrdom_passive.damage_per_step
		resource_info.max_duration		= nil
	else
		resource_info.max_stacks = TalentSettings[self._archetype_name .. "_2"].grenade.max_charges
		if self._archetype_name == "veteran" then
			self._veteran_replenish = profile.talents.veteran_2_tier_2_name_3
			local grenade_cooldown = TalentSettings.veteran_2.offensive_1_3.grenade_replenishment_cooldown
			resource_info.max_duration = grenade_cooldown
		else
			resource_info.max_duration		= nil
		end
	end
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


HudElementWarpCharges._is_resource_buff = function (self, buff)
	if self.archetype_name == "psyker"	then
		return buff == "psyker_biomancer_souls" or buff == "psyker_biomancer_souls_increased_max_stacks"
	elseif self.archetype_name == "veteran" then
		return self._veteran_replenish and buff == "veteran_ranger_grenade_replenishment"
	elseif self.archetype_name == "zealot" then
		return mod:get("martyrdom") and buff == "zealot_maniac_martyrdom_base"
	else
		return false
	end
end

HudElementWarpCharges.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementWarpCharges.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local widget = self._widgets_by_name.gauge
    if not widget then return end

    if mod:get("psyker_only") and self._archetype_name ~= "psyker" then
        widget.content.visible = false
        return
    end

	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
		resource_info.stacks = 0

		if self._archetype_name == "psyker" then
			local unit_data_extension = player_extensions.unit_data
			local specialization_resource_component = unit_data_extension:read_component("specialization_resource")
			resource_info.stacks = specialization_resource_component.current_resource
			
		else
			local ability_extension = player_extensions.ability
			if ability_extension and ability_extension:ability_is_equipped("grenade_ability") then
				resource_info.stacks = ability_extension:remaining_ability_charges("grenade_ability")
			end
		end

		if self._archetype_name == "psyker" or self._veteran_replenish then
			local buff_extension = player_extensions.buff
			if buff_extension then
				local buffs = buff_extension:buffs()
				for i = 1, #buffs do
					local buff = buffs[i]
					local buff_name = buff:template_name()
					if _is_warp_charge_buff(buff_name) or buff_name == "veteran_ranger_grenade_replenishment" then
						if self._archetype_name == "psyker" then
							resource_info.stacks = math.clamp(buff:stack_count(), 0, resource_info.max_stacks)
						end
						resource_info.progress = buff:duration_progress()
					end
				end
			end
		else
			resource_info.progress = nil
		end
	end

    self:_update_shield_amount()

	if mod:get("show_gauge") then
		widget.content.visible = true
	else
		self:_update_visibility(dt)
	end
end

-- TODO: need to trigger when talents change or exit inventory
HudElementWarpCharges._resize_shield = function (self)
	local shield_amount = resource_info.max_stacks or 0
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

	local widget = self._widgets_by_name.gauge
	if not widget then return end

	local gauge_style		= widget.style
	local value_text_style	= gauge_style.value_text
	local name_text_style	= gauge_style.name_text
	local warning_style		= gauge_style.warning

	if horizontal then
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
		warning_style.angle = (math.pi * 3) / 2
	end
end

HudElementWarpCharges._update_shield_amount = function (self)
	local shield_amount = resource_info.max_stacks or 0
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
	local draw = resource_info.stacks > 0 or self._veteran_replenish

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
	if mod._is_in_hub() then return end

	if self._alpha_multiplier ~= 0 then
		local previous_alpha_multiplier = render_settings.alpha_multiplier
		render_settings.alpha_multiplier = self._alpha_multiplier

		HudElementWarpCharges.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)
		self:_draw_shields(dt, t, ui_renderer)

		render_settings.alpha_multiplier = previous_alpha_multiplier
	end
end

local Y_OFFSETS = {}
Y_OFFSETS[6] = 34
Y_OFFSETS[4] = 59
Y_OFFSETS[3] = 85
Y_OFFSETS[2] = 136

HudElementWarpCharges._get_value_text = function (self)
	local format = ""
	local value = nil
	local value_option = mod:get("gauge_value")
	local description = mod:get("gauge_value_text")

	if self._archetype_name == "psyker" and value_option == mod.value_options["value_option_damage"] then
		format = "%.0f%%"
		value = resource_info:damage_boost() * 100
	elseif value_option == mod.value_options["value_option_stacks"] then
		format = "%.0fx"
		value = resource_info.stacks
	elseif (self._archetype_name == "psyker" or self._veteran_replenish) and value_option == mod.value_options["value_option_time_percent"] then
		format = "%.0f%%"
		value = resource_info.progress * 100
	elseif (self._archetype_name == "psyker" or self._veteran_replenish) and value_option == mod.value_options["value_option_time_seconds"] then
		format = "%.0fs"
		value = resource_info.progress * resource_info.max_duration
	end

	local value_text = string.format(format, value)

	if description and (self._archetype_name == "psyker" or self._archetype_name == "veteran") then
		value_text = mod:localize(value_option .. "_display") .. " " .. value_text
	end

	return value_text
end

HudElementWarpCharges._draw_shields = function (self, dt, t, ui_renderer)
	local num_shields = self._shield_amount

    if not num_shields then return end

	if num_shields < 1 then return end

	local widget = self._shield_widget
	local widget_offset = widget.offset
	local shield_width = self._shield_width

	local gauge_widget = self._widgets_by_name.gauge
	gauge_widget.content.value_text = self:_get_value_text()

	local step_fraction = 1 / num_shields
	local spacing = HudElementWarpChargesSettings.spacing
	local shield_offset = (shield_width + spacing) * (num_shields - 1) * 0.5
	if not self._horizontal then
		shield_offset = shield_offset + Y_OFFSETS[resource_info.max_stacks]
	end
	local shields = self._shields

	local progress = resource_info.progress or 1
	local stacks = resource_info.stacks - (self._veteran_replenish and 0 or 1)
    local souls_progress = ( progress + ( stacks ) ) / resource_info.max_stacks

	for i = num_shields, 1, -1 do
		local shield = shields[i]

		if not shield then return end

		local end_value = i * step_fraction
		local start_value = end_value - step_fraction

		local color_archetype = mod:get("color_" .. self._archetype_name) and self._archetype_name or "default"

		local color_full_name	= mod:get("color_" .. color_archetype .. "_full")
		local color_empty_name	= mod:get("color_" .. color_archetype .. "_empty")

		local value = 1
		if souls_progress >= end_value then
			value = 0
		elseif start_value < souls_progress then
			value = 1 - resource_info.progress
		else
			value = 1
		end

		local color_full	= Color[color_full_name](255, true)
		local color_empty	= Color[color_empty_name](value == 1 and 100 or 255, true)
		
		local widget_style = widget.style
		local widget_color = widget_style.full.color
		
		for e = 1, 4 do
			widget_color[e] = math.lerp(color_full[e], color_empty[e], value)
		end

		if  self._horizontal then
			widget_offset[1] = 0
			widget_offset[1] = shield_offset
		else
			local scenegraph_size = self:scenegraph_size("shield")
			local height = scenegraph_size.y

			widget_offset[1] = 4
			widget_offset[2] = height - shield_offset
		end

		UIWidget.draw(widget, ui_renderer)

		shield_offset = shield_offset - shield_width - spacing
	end
end

return HudElementWarpCharges