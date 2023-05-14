local mod = get_mod("warpcharges")

local Definitions = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_definitions")
local HudElementWarpChargesSettings = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Stamina = mod:original_require("scripts/utilities/attack/stamina")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local TalentSettings = mod:original_require("scripts/settings/buff/talent_settings")
local HudElementWarpCharges = class("HudElementWarpCharges", "HudElementBase")

local function _is_warp_charge_buff(s)
    return s == "psyker_biomancer_souls" or s == "psyker_biomancer_souls_increased_max_stacks"
end

HudElementWarpCharges.init = function (self, parent, draw_layer, start_scale)
	HudElementWarpCharges.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._shields = {}
	self._shield_width = 0
	self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

    self._player_unit = Managers.player:local_player(1).player_unit
    self.archetype = Managers.player:local_player(1):archetype_name()
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
    if not widget then
        mod:echo("not widget")
        return
    end

    local parent = self._parent
    if not parent then
        mod:echo("not parent")
        return
    end

    local player = parent:player()
    if not player then
        mod:echo("not player")
        return
    end

    local archetype_name = player:archetype_name()
    if archetype_name ~= "psyker" then
        mod:echo("not psyker")
        widget.content.visible = false
        return
    end

    local profile = player and player:profile()
    if profile and profile.talents then
        self._max_souls = profile.talents.psyker_2_tier_5_name_1 and 6 or 4
    end

    self:_update_shield_amount()
	self:_update_visibility(dt)
end

HudElementWarpCharges._update_shield_amount = function (self)
	local shield_amount = self._max_souls or 0
	--local parent = self._parent
	--local player_extensions = parent:player_extensions()

	-- if player_extensions then
    --     local buff_extension = player_extensions.buff
	-- 	local player_unit_data = player_extensions.unit_data

	-- 	if buff_extension and player_unit_data then
	-- 		local specialization = player_unit_data:specialization()
    --         local specialization_resource_component = player_unit_data:read_component("specialization_resource")
	-- 		--local stamina_component = unit_data_extension:read_component("stamina")
	-- 		--local stamina_template = specialization.stamina

    --         if specialization_resource_component then
    --             shield_amount = self._max_souls
    --         end

	-- 		-- if stamina_component and stamina_template then
	-- 		-- 	local player_unit = player_extensions.unit
	-- 		-- 	local current, max = Stamina.current_and_max_value(player_unit, stamina_component, stamina_template)
	-- 		-- 	shield_amount = max
	-- 		-- end
	-- 	end
	-- end

	if shield_amount ~= self._shield_amount then
		local amount_difference = (self._shield_amount or 0) - shield_amount
		self._shield_amount = shield_amount
		local bar_size = HudElementWarpChargesSettings.bar_size
		local segment_spacing = HudElementWarpChargesSettings.spacing
		local total_segment_spacing = segment_spacing * math.max(shield_amount - 1, 0)
		local total_bar_length = bar_size[1] - total_segment_spacing
		self._shield_width = math.round(shield_amount > 0 and total_bar_length / shield_amount or total_bar_length)
		local widget = self._shield_widget

		self:_set_scenegraph_size("shield", self._shield_width)

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
			--local block_component = player_unit_data:read_component("block")
			--local sprint_component = player_unit_data:read_component("sprint_character_state")
			--local stamina_component = player_unit_data:read_component("stamina")
            local specialization_resource_component = player_unit_data:read_component("specialization_resource")

			--if block_component and block_component.is_blocking or sprint_component and sprint_component.is_sprinting or stamina_component and stamina_component.current_fraction < 1 then
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
	empty = {
		100,
		UIHudSettings.color_tint_secondary_3[2],
		UIHudSettings.color_tint_secondary_3[3],
		UIHudSettings.color_tint_secondary_3[4]
	},
	half = UIHudSettings.color_tint_main_3,
	full = UIHudSettings.color_tint_main_1
}

HudElementWarpCharges._draw_shields = function (self, dt, t, ui_renderer)
	local num_shields = self._shield_amount

    if not num_shields then
        return
    end

	if num_shields < 1 then
		return
	end

	local widget = self._shield_widget
	local widget_offset = widget.offset
	local shield_width = self._shield_width
	local bar_size = HudElementWarpChargesSettings.bar_size
	local max_glow_alpha = HudElementWarpChargesSettings.max_glow_alpha
	local half_distance = HudElementWarpChargesSettings.half_distance
	local current_soul = 0
    local total_souls = 0
	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
		-- local player_unit_data = player_extensions.unit_data
        local buff_extension = player_extensions.buff

        if buff_extension then
            local buffs = buff_extension:buffs()
            for i = 1, #buffs do
                local buff = buffs[i]
                local buff_name = buff:template_name()
                if _is_warp_charge_buff(buff_name) then
                    local duration = buff:duration()
                    total_souls = buff:stack_count()
                    current_soul = buff:duration_progress()
                    -- current_soul = ( soul + ( souls - 1 ) ) / self._max_souls
                end
            end
        end

		-- if player_unit_data then
		-- 	local stamina_component = player_unit_data:read_component("stamina")

		-- 	if stamina_component and stamina_component.current_fraction then
		-- 		stamina_fraction = stamina_component.current_fraction
		-- 	end
		-- end
	end

    local souls_passive = TalentSettings.psyker_2.passive_1
    local damage_boost_per_soul = souls_passive.damage / self._max_souls --souls_passive.base_max_souls
    local value = math.clamp(total_souls, 0, self._max_souls) * damage_boost_per_soul --current_soul

	local gauge_widget = self._widgets_by_name.gauge
	gauge_widget.content.value_text = string.format("%.0f%%", math.clamp(value, 0, 1) * 100)
	local step_fraction = 1 / num_shields
	local spacing = HudElementWarpChargesSettings.spacing
	local x_offset = (shield_width + spacing) * (num_shields - 1) * 0.5
	local shields = self._shields

    local souls_progress = ( current_soul + ( total_souls - 1 ) ) / self._max_souls

	for i = num_shields, 1, -1 do
		local shield = shields[i]

		if not shield then
			return
		end

		local end_value = i * step_fraction
		local start_value = end_value - step_fraction
		local is_full, is_half, is_empty = nil

		if souls_progress >= start_value + step_fraction * 0.5 then
			is_full = true
		elseif start_value < souls_progress then
			is_half = true
		else
			is_empty = true
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
		widget_offset[1] = x_offset

		UIWidget.draw(widget, ui_renderer)

		x_offset = x_offset - shield_width - spacing
	end
end

return HudElementWarpCharges


-- local _definitions = mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_definitions")

-- local HudElementWarpCharges = class("HudEelementWarpCharges", "HudElementBase")
-- HudElementWarpCharges.init = function (self, parent, draw_layer, start_scale)
--     HudElementWarpCharges.super.init(self, parent, draw_layer, start_scale, _definitions)
--     self._player_unit = Managers.player:local_player(1).player_unit
--     self.archetype = Managers.player:local_player(1):archetype_name()
-- end

-- HudElementWarpCharges.update = function (self, dt, t, ui_renderer, render_settings, input_service)
--     HudElementWarpCharges.super.update(self, dt, t, ui_renderer, render_settings, input_service)
--     local widget = self._widgets_by_name.HudElementWarpCharges
--     if not widget  then
--         return
--     end
--     if self.archetype ~= "psyker" then
--         widget.content.visible = false
--     end
--     if self._player_unit then
--         local buff_extensions = ScriptUnit.extension(self._player_unit, "buff_system")
--         if buff_extensions then
--             for _, buff in pairs(buff_extensions._buffs_by_index) do
--                 local template = buff:template()
--                 if _is_warp_charge_buff(template.name) then
--                    -- TODO: populate bar with warp charge segments 
--                 end
--             end
--         end
--     end
-- end