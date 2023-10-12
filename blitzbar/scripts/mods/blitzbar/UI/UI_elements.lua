local mod = get_mod("blitzbar")

local Definitions = mod:io_dofile("blitzbar/scripts/mods/blitzbar/UI/UI_definitions")
local HudElementblitzbarSettings = mod:io_dofile("blitzbar/scripts/mods/blitzbar/UI/UI_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local Stamina = mod:original_require("scripts/utilities/attack/stamina")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local TalentSettings = mod:original_require("scripts/settings/talent/talent_settings_new") --mod:original_require("scripts/settings/buff/talent_settings")
local ArchetypeTalents = mod:original_require("scripts/settings/ability/archetype_talents/archetype_talents")
local AbilitySettings = mod:original_require("scripts/settings/ability/player_abilities/player_abilities")
local HudElementblitzbar = class("HudElementblitzbar", "HudElementBase")

-- NEW ABILITIES LOCATION
--"scripts/settings/ability/player_abilities/player_abilities"
--"scripts/settings/talent/talent_settings_new"

local resource_info = {
	max_stacks = nil,
	max_duration = nil,
	stacks = 0,
	progress = 0,
	replenish = nil,
	replenish_buff = nil,
	damage_per_stack = nil,
	damage_boost = function (self)
		return math.clamp(self.stacks, 0, self.max_stacks) * self.damage_per_stack
	end
}

local function _is_warp_charge_buff(s)
    --return s == "psyker_biomancer_souls" or s == "psyker_biomancer_souls_increased_max_stacks"
	return s == "psyker_souls"
end

HudElementblitzbar.init = function (self, parent, draw_layer, start_scale)
	HudElementblitzbar.super.init(self, parent, draw_layer, start_scale, Definitions)

	self._shields = {}
	self._shield_width = 0
	self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

	self._player = Managers.player:local_player(1)
    self._archetype_name = self._player:archetype_name()
    local profile		 = self._player:profile()
	local player_talents = profile.talents

	--mod:dump(profile, "profile", 4)
	--mod:dump(ArchetypeTalents, "ArchetypeTalents", 4)
	--mod:dump(profile.talents, "profile.talents", 4)

	-- if false then
	-- 	if self._archetype_name == "psyker" then
	-- 		local souls_passive = TalentSettings.psyker_2.passive_1
	-- 		local extra_souls	= TalentSettings.psyker_2.offensive_2_1.max_souls_talent

	-- 		resource_info.max_stacks		= profile.talents.psyker_2_tier_5_name_1 and extra_souls or souls_passive.base_max_souls
	-- 		resource_info.damage_per_stack	= souls_passive.damage / extra_souls
	-- 		resource_info.max_duration		= souls_passive.soul_duration

	-- 	elseif self._archetype_name == "zealot" and mod:get("martyrdom") then
	-- 		self._zealot_martyrdom = true

	-- -- [zealot_increase_ranged_close_damage] = 1 (number)
	-- -- [zealot_toughness_on_heavy_kills] = 1 (number)
	-- -- [zealot_dash] = 1 (number)
	-- -- [zealot_heal_part_of_damage_taken] = 1 (number)
	-- -- [zealot_attack_speed] = 1 (number)
	-- -- [base_toughness_node_buff_low_1] = 1 (number)
	-- -- [zealot_increased_damage_vs_resilient] = 1 (number)
	-- -- [base_toughness_node_buff_low_2] = 1 (number)
	-- -- [base_melee_damage_node_buff_low_1] = 1 (number)
	-- -- [zealot_toughness_damage_coherency] = 1 (number)
	-- -- [base_melee_damage_node_buff_low_2] = 1 (number)
	-- -- [zealot_hits_grant_stacking_damage] = 1 (number)
	-- -- [zealot_martyrdom] = 1 (number)
	-- -- [base_toughness_node_buff_low_4] = 2 (number)
	-- -- [zealot_multi_hits_increase_damage] = 1 (number)
	-- -- [zealot_additional_wounds] = 1 (number)
	-- -- [base_toughness_damage_reduction_node_buff_low_1] = 1 (number)
	-- -- [base_toughness_damage_reduction_node_buff_low_4] = 1 (number)
	-- -- [zealot_resist_death] = 1 (number)
	-- -- [zealot_improved_weapon_handling_after_dodge] = 1 (number)
	-- -- [base_suppression_node_buff_low_1] = 1 (number)
	-- -- [zealot_damage_boosts_movement] = 1 (number)
	-- -- [zealot_flame_grenade] = 1 (number)
	-- -- [zealot_resist_death_healing] = 1 (number)
	-- -- [base_health_node_buff_medium_1] = 1 (number)
	-- -- [zealot_attack_speed_post_ability] = 1 (number)
	-- -- [zealot_toughness_damage_reduction_coherency_improved] = 1 (number)
	-- -- [zealot_martyrdom_grants_attack_speed] = 1 (number)
	-- -- [base_movement_speed_node_buff_low_1] = 1 (number)
	-- -- [zealot_martyrdom_grants_toughness] = 1 (number)
	-- -- [zealot_toughness_in_melee] = 1 (number)

	-- -- MARTYRDOM
	-- -- TalentSettings.zealot_2.offensive_3.attack_speed_per_segment
	-- -- TalentSettings.zealot_2.passive_1.damage_per_step
	-- -- TalentSettings.zealot_2.passive_1.martyrdom_max_stacks

	-- 		local p = self._parent

	-- 		local player_extensions = parent:player_extensions()

	-- 		--mod:dump(p, "p", 4)

	-- 		--local player_extensions = p:player_extensions()	--parent._parent:player_extensions()
	-- 		--local health_extension = player_extensions.health
	-- 		--local max_wounds = health_extension:max_wounds()

	-- 		local martyrdom_passive = TalentSettings.zealot_martyrdom --TalentSettings.zealot_2.passive_1
	-- 		local extra_stacks = TalentSettings.zealot_additional_wounds

	-- 		resource_info.max_stacks		= 10 --max_wounds --profile.talents.zealot_2_tier_5_name_3 and extra_stacks or martyrdom_passive.max_stacks
	-- 		resource_info.damage_per_stack	= 1.08 --martyrdom_passive.damage_per_step
	-- 		resource_info.max_duration		= nil
	-- 	else
	-- 		resource_info.max_stacks = ArchetypeTalents.veteran.veteran_extra_grenade and 1 or 0 --TalentSettings[self._archetype_name .. "_2"].grenade.max_charges
	-- 		if self._archetype_name == "veteran" then
	-- 			self._veteran_replenish = false --profile.talents.veteran_2_tier_2_name_3
	-- 			--resource_info.max_duration = TalentSettings.veteran_2.offensive_1_3.grenade_replenishment_cooldown
	-- 			resource_info.max_duration = ArchetypeTalents.veteran.veteran_replenish_grenades.format_values.time.value
	-- 		else
	-- 			resource_info.max_duration = nil
	-- 		end
	-- 	end
	-- end

	-- psyker_souls_increase_damage = {
	-- 	description = "loc_talent_psyker_souls_increase_damage_desc",
	-- 	name = "Reduces warp charge generation per soul.",
	-- 	display_name = "loc_talent_psyker_souls_increase_damage",
	-- 	icon = "content/ui/textures/icons/talents/psyker_2/psyker_2_tier_2_3",
	-- 	format_values = {
	-- 		damage = {
	-- 			prefix = "+",
	-- 			format_type = "percentage",
	-- 			value = talent_settings_2.passive_1.damage / talent_settings_2.offensive_2_1.max_souls_talent
	-- 		}
	-- 	},
	-- 	passive = {
	-- 		buff_template_name = "psyker_souls_increase_damage",
	-- 		identifier = "psyker_souls_increase_damage"
	-- 	}
	-- }

	-- psyker_increased_max_souls = {
	-- 	description = "loc_talent_psyker_increased_souls_desc",
	-- 	name = "Increases the maximum amount of souls you can have to 6.",
	-- 	display_name = "loc_talent_psyker_increased_souls",
	-- 	icon = "content/ui/textures/icons/talents/psyker_2/psyker_2_tier_5_1",
	-- 	format_values = {
	-- 		soul_amount = {
	-- 			format_type = "number",
	-- 			value = max_souls_talent
	-- 		}
	-- 	},
	-- 	special_rule = {
	-- 		special_rule_name = "psyker_increased_max_souls",
	-- 		identifier = "psyker_increased_max_souls"
	-- 	}
	-- }

	-- ##############################################################################
	-- #							EMPOWERED PSIONICS								#
	-- ##############################################################################
	
	-- psyker_empowered_ability = {
	-- 	description = "loc_talent_psyker_empowered_ability_description",
	-- 	name = "Passive - Kills have a chance to empower your next blitz ability",
	-- 	display_name = "loc_talent_psyker_empowered_ability",
	-- 	icon = "content/ui/textures/icons/talents/psyker_3/psyker_3_base_1",
	-- 	format_values = {
	-- 		chance = {
	-- 			num_decimals = 1,
	-- 			format_type = "percentage",
	-- 			find_value = {
	-- 				buff_template_name = "psyker_empowered_grenades_passive",
	-- 				find_value_type = "buff_template",
	-- 				path = {
	-- 					"proc_events",
	-- 					proc_events.on_hit
	-- 				}
	-- 			}
	-- 		},
	-- 		blitz_one = {
	-- 			value = "loc_talent_psyker_brain_burst_improved",
	-- 			format_type = "loc_string"
	-- 		},
	-- 		smite_cost = {
	-- 			format_type = "percentage",
	-- 			value = 1 - talent_settings_3.passive_1.psyker_smite_cost_multiplier
	-- 		},
	-- 		smite_attack_speed = {
	-- 			format_type = "percentage",
	-- 			find_value = {
	-- 				buff_template_name = "psyker_empowered_grenades_passive_visual_buff",
	-- 				find_value_type = "buff_template",
	-- 				path = {
	-- 					"stat_buffs",
	-- 					stat_buffs.smite_attack_speed
	-- 				}
	-- 			}
	-- 		},
	-- 		smite_damage = {
	-- 			prefix = "+",
	-- 			format_type = "percentage",
	-- 			find_value = {
	-- 				buff_template_name = "psyker_empowered_grenades_passive_visual_buff",
	-- 				find_value_type = "buff_template",
	-- 				path = {
	-- 					"stat_buffs",
	-- 					stat_buffs.smite_damage
	-- 				}
	-- 			}
	-- 		},
	-- 		blitz_two = {
	-- 			value = "loc_ability_psyker_chain_lightning",
	-- 			format_type = "loc_string"
	-- 		},
	-- 		chain_lightning_damage = {
	-- 			prefix = "+",
	-- 			format_type = "percentage",
	-- 			value = talent_settings_3.passive_1.chain_lightning_damage
	-- 		},
	-- 		chain_lightning_jump_time_multiplier = {
	-- 			format_type = "percentage",
	-- 			find_value = {
	-- 				buff_template_name = "psyker_empowered_grenades_passive_visual_buff",
	-- 				find_value_type = "buff_template",
	-- 				path = {
	-- 					"stat_buffs",
	-- 					stat_buffs.chain_lightning_jump_time_multiplier
	-- 				}
	-- 			}
	-- 		},
	-- 		blitz_three = {
	-- 			value = "loc_ability_psyker_blitz_throwing_knives",
	-- 			format_type = "loc_string"
	-- 		},
	-- 		throwing_knives_cost = {
	-- 			value = 1,
	-- 			format_type = "percentage"
	-- 		},
	-- 		throwing_knives_charges = {
	-- 			value = 0,
	-- 			format_type = "number"
	-- 		},
	-- 		throwing_knives_old_damage = {
	-- 			format_type = "number",
	-- 			find_value = {
	-- 				damage_profile_name = "psyker_throwing_knives",
	-- 				find_value_type = "base_damage",
	-- 				power_level = PowerLevelSettings.default_power_level
	-- 			}
	-- 		},
	-- 		throwing_knives_new_damage = {
	-- 			format_type = "number",
	-- 			find_value = {
	-- 				damage_profile_name = "psyker_throwing_knives_pierce",
	-- 				find_value_type = "base_damage",
	-- 				power_level = PowerLevelSettings.default_power_level
	-- 			}
	-- 		}
	-- 	},
	-- 	passive = {
	-- 		buff_template_name = "psyker_empowered_grenades_passive",
	-- 		identifier = "psyker_empowered_grenades_passive"
	-- 	},
	-- 	special_rule = {
	-- 		special_rule_name = "psyker_empowered_grenades",
	-- 		identifier = "psyker_empowered_grenades"
	-- 	}
	-- }

	if self._archetype_name == "psyker" then
		local knives = player_talents.psyker_grenade_throwing_knives

		local grenade = knives and profile.archetype.talents.psyker_grenade_throwing_knives

		if grenade then
			local grenade_ability = grenade.player_ability.ability

			resource_info.max_stacks = grenade_ability.max_charges
			resource_info.replenish = true
			resource_info.replenish_buff = "psyker_knife_replenishment"
			resource_info.max_duration = grenade.cooldown

			local assail_quicker = "psyker_reduced_throwing_knife_cooldown"
			psyker_throwing_knives_reduced_cooldown.format_values.
		else
			resource_info.max_stacks = nil
			resource_info.max_duration = nil
			mod:error("NO GRENADE EQUIPPED")
		end
	end

	if self._archetype_name == "zealot" then
		local stun	= player_talents.zealot_shock_grenade or player_talents.zealot_improved_stun_grenade
		local flame	= player_talents.zealot_flame_grenade
		local knife	= player_talents.zealot_throwing_knives

		mod:echo(stun)
		mod:echo(flame)
		mod:echo(knife)

		local grenade = stun	and profile.archetype.talents.zealot_shock_grenade or
						flame	and profile.archetype.talents.zealot_flame_grenade or
						knife	and profile.archetype.talents.zealot_throwing_knives

		if grenade then
			local grenade_ability = grenade.player_ability.ability

			mod:echo(grenade.name .. ": x" .. grenade_ability.max_charges)

			resource_info.max_stacks = grenade_ability.max_charges
		else
			resource_info.max_stacks = nil
			resource_info.max_duration = nil
			mod:error("NO GRENADE EQUIPPED")
		end
	end

	if self._archetype_name == "veteran" then

		local frag = player_talents.veteran_frag_grenade
		local krak = player_talents.veteran_krak_grenade
		local smoke = player_talents.veteran_smoke_grenade

		local grenade = frag	and profile.archetype.talents.frag_grenade or	--ArchetypeTalents.veteran.veteran_frag_grenade or
						krak	and profile.archetype.talents.krak_grenade or	--ArchetypeTalents.veteran.veteran_krak_grenade or
						smoke	and profile.archetype.talents.smoke_grenade	--ArchetypeTalents.veteran.veteran_smoke_grenade

		if grenade then
			local grenade_ability = grenade.player_ability.ability
			local grenades = grenade_ability.max_charges
			
			mod:echo(grenade.name .. ": x" .. grenades)
			
			local extra_grenade		= player_talents.veteran_extra_grenade		and 1 or 0
			local replenish_grenade = player_talents.veteran_replenish_grenades and 1 or 0
			
			--ArchetypeTalents.veteran.veteran_replenish_grenades
			mod:echo("Extra Grenade: " .. (extra_grenade == 1 and "true" or "false"))			--mod:echo(extra_grenade)
			mod:echo("Replenish Grenade: " .. (replenish_grenade == 1 and "true" or "false"))	--mod:echo(replenish_grenade)
			
			resource_info.max_stacks = grenades + extra_grenade
			resource_info.replenish = replenish_grenade == 1
			resource_info.replenish_buff = "veteran_grenade_replenishment"
			resource_info.max_duration = profile.archetype.talents.veteran_replenish_grenades.format_values.time.value
		else
			resource_info.max_stacks = nil
			resource_info.max_duration = nil
			mod:error("NO GRENADE EQUIPPED")
		end
	end

	if self._archetype_name == "ogryn" then
		local rock	= player_talents.ogryn_grenade_friend_rock
		local box	= player_talents.ogryn_grenade_box or player_talents.ogryn_box_explodes
		local frag	= player_talents.ogryn_grenade_frag

		local grenade = rock	and profile.archetype.talents.ogryn_grenade_friend_rock or
						box		and profile.archetype.talents.ogryn_grenade_box or
						frag	and profile.archetype.talents.ogryn_grenade_frag

		if grenade then
			local grenade_ability = grenade.player_ability.ability

			mod:echo(grenade.name .. ": x" .. grenade_ability.max_charges)

			resource_info.max_stacks	= grenade_ability.max_charges
			if rock then
				resource_info.replenish		= true
				resource_info.replenish_buff = "ogryn_friend_grenade_replenishment"
				resource_info.max_duration	= grenade.cooldown
			end
		else
			resource_info.max_stacks = nil
			resource_info.max_duration = nil
			mod:error("NO GRENADE EQUIPPED")
		end
	end

	mod:set("gauge_text", self._archetype_name .. "_gauge_text")
end

HudElementblitzbar.destroy = function (self)
	HudElementblitzbar.super.destroy(self)
end

HudElementblitzbar._add_shield = function (self)
	self._shields[#self._shields + 1] = {}
end

HudElementblitzbar._remove_shield = function (self)
	self._shields[#self._shields] = nil
end

HudElementblitzbar._is_resource_buff = function (self, buff)
	return	self._archetype_name == "psyker" and (buff == "psyker_biomancer_souls" or buff == "psyker_biomancer_souls_increased_max_stacks")	or
			self._veteran_replenish and (buff == "veteran_ranger_grenade_replenishment")														or
			self._zealot_martyrdom and (buff == "zealot_maniac_martyrdom_base")
end

HudElementblitzbar.update = function (self, dt, t, ui_renderer, render_settings, input_service)
	HudElementblitzbar.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local widget = self._widgets_by_name.gauge
    if not widget then return end

	local parent = self._parent
	local player_extensions = parent:player_extensions()

	local grenade = mod:get(self._archetype_name .. "_grenade")

	if player_extensions then
		local buff_extension = player_extensions.buff
		if buff_extension then
			local buffs = buff_extension:buffs()
			for i = 1, #buffs do
				local buff = buffs[i]
				local buff_name = buff:template_name()

				if buff_name == resource_info.replenish_buff then
					resource_info.progress = buff:duration_progress()
					--mod:echo(buff:duration_progress())
				end
			end
		end


		if grenade then
			local ability_extension = player_extensions.ability
			if ability_extension and ability_extension:ability_is_equipped("grenade_ability") then
				resource_info.stacks = ability_extension:remaining_ability_charges("grenade_ability")
			end

			if not resource_info.replenish then
				resource_info.progress = nil
			end
		else
		end

		-- ///////////////////////////////////////////////////////////////
		--								[GRENADES]
		-- ///////////////////////////////////////////////////////////////
		-- ogryn_grenade_friend_rock
		-- 	"ogryn_friend_grenade_replenishment"
		-- veteran_frag_grenade.max_charges
		-- veteran_krak_grenade.max_charges
		-- veteran_smoke_grenade.max_charges
		-- veteran_extra_grenade
		-- 	passive = {
		-- 		buff_template_name = "veteran_extra_grenade",
		-- 		identifier = "veteran_extra_grenade"
		-- 	}
		-- veteran_replenish_grenades = {
		-- 	format_values = {
		-- 		amount = {
		-- 			format_type = "value",
		-- 			value = talent_settings_2.offensive_1_3.grenade_restored
		-- 		},
		-- 		time = {
		-- 			format_type = "value",
		-- 			value = talent_settings_2.offensive_1_3.grenade_replenishment_cooldown
		-- 		}
		-- 	},
		-- 	passive = {
		-- 		buff_template_name = "veteran_grenade_replenishment",
		-- 		identifier = "veteran_grenade_replenishment"
		-- 	}
		-- }
	end

    self:_update_shield_amount()

	if mod:get(self._archetype_name .. "_show_gauge") then
		widget.content.visible = true
	else
		self:_update_visibility(dt)
	end
end

local function update_old()
	HudElementblitzbar.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local widget = self._widgets_by_name.gauge
    if not widget then return end

	--widget.style.warning.angle = widget.style.warning.angle + 0.1

	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
		if self._archetype_name == "psyker" or self._zealot_martyrdom or self._veteran_replenish then
			resource_info.stacks = 0
			local buff_extension = player_extensions.buff
			if buff_extension then
				local buffs = buff_extension:buffs()
				for i = 1, #buffs do
					local buff = buffs[i]
					local buff_name = buff:template_name()
					if self:_is_resource_buff(buff_name) then
						if self._zealot_martyrdom then
							resource_info.stacks = math.clamp(buff:visual_stack_count(), 0, resource_info.max_stacks)
							resource_info.progress = nil
						else
							if self._archetype_name == "psyker" then
								resource_info.stacks = math.clamp(buff:stack_count(), 0, resource_info.max_stacks)
							end
							resource_info.progress = buff:duration_progress()
						end
					end
				end
			end
		end

		if not (self._archetype_name == "psyker" or self._zealot_martyrdom) then
			local ability_extension = player_extensions.ability
			if ability_extension and ability_extension:ability_is_equipped("grenade_ability") then
				resource_info.stacks = ability_extension:remaining_ability_charges("grenade_ability")
			end
			if not self._veteran_replenish then
				resource_info.progress = nil
			end
		end
	end

    self:_update_shield_amount()

	if mod:get(self._archetype_name .. "_show_gauge") then
		widget.content.visible = true
	else
		self:_update_visibility(dt)
	end
end

-- TODO: need to trigger when talents change or exit inventory
HudElementblitzbar._resize_shield = function (self)
	local shield_amount = resource_info.max_stacks or 0
	local bar_size = HudElementblitzbarSettings.bar_size
	local segment_spacing = HudElementblitzbarSettings.spacing
	local total_segment_spacing = segment_spacing * math.max(shield_amount - 1, 0)
	local total_bar_length = bar_size[1] - total_segment_spacing

	self._shield_width = math.round(shield_amount > 0 and total_bar_length / shield_amount or total_bar_length)
	local shield_height = 9

	local horizontal =	mod:get("gauge_orientation") == mod.orientation_options["orientation_option_horizontal"] or
						mod:get("gauge_orientation") == mod.orientation_options["orientation_option_horizontal_flipped"]
	self._horizontal = horizontal

	local flipped = mod:get("gauge_orientation") == mod.orientation_options["orientation_option_horizontal_flipped"] or
					mod:get("gauge_orientation") == mod.orientation_options["orientation_option_vertical_flipped"]
	self._flipped = flipped

	local width  = horizontal and self._shield_width or shield_height
	local height = horizontal and shield_height or self._shield_width

	self:_set_scenegraph_size("shield", width, height)

	local widget = self._widgets_by_name.gauge
	if not widget then return end

	local gauge_style		= widget.style
	local value_text_style	= gauge_style.value_text
	local name_text_style	= gauge_style.name_text
	local warning_style		= gauge_style.warning

	local styles = {
		orientation_option_horizontal = {
			value_horizontal_alignment		= "right",
			value_text_horizontal_alignment = "right",
			value_offset = {
				0,
				10,
				3
			},
			name_horizontal_alignment		= "left",
			name_text_horizontal_alignment	= "left",
			name_offset = {
				0,
				10,
				3
			},
			angle = 0
		},
		orientation_option_horizontal_flipped = {
			value_horizontal_alignment		= "right",
			value_text_horizontal_alignment = "right",
			value_offset = {
				0,
				-30,
				3
			},
			name_horizontal_alignment		= "left",
			name_text_horizontal_alignment	= "left",
			name_offset = {
				0,
				-30,
				3
			},
			angle = math.pi
		},
		orientation_option_vertical = {
			value_horizontal_alignment = "right",
			value_text_horizontal_alignment = "right",
			value_offset = {
				-118,
				-86,
				3
			},
			name_horizontal_alignment =	"right",
			name_text_horizontal_alignment = "right",
			name_offset = {
				-118,
				-104,
				3
			},
			angle = (math.pi * 3) / 2
		},
		orientation_option_vertical_flipped = {
			value_horizontal_alignment = "left",
			value_text_horizontal_alignment = "left",
			value_offset = {
				118,
				-86,
				3
			},
			name_horizontal_alignment =	"left",
			name_text_horizontal_alignment = "left",
			name_offset = {
				118,
				-104,
				3
			},
			angle = math.pi / 2
		}
	}

	local orientation = mod:get("gauge_orientation")

	value_text_style.horizontal_alignment = styles[orientation].value_horizontal_alignment
	value_text_style.text_horizontal_alignment = styles[orientation].value_text_horizontal_alignment
	value_text_style.offset = styles[orientation].value_offset

	name_text_style.horizontal_alignment = styles[orientation].name_horizontal_alignment
	name_text_style.text_horizontal_alignment = styles[orientation].name_text_horizontal_alignment
	name_text_style.offset = styles[orientation].name_offset

	warning_style.angle = styles[orientation].angle
end

HudElementblitzbar._update_shield_amount = function (self)
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

HudElementblitzbar._update_visibility = function (self, dt)
	local draw = resource_info.stacks > 0 or resource_info.replenish --self._veteran_replenish

	local alpha_speed = 3
	local alpha_multiplier = self._alpha_multiplier or 0

	if draw then
		alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
	else
		alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
	end

	self._alpha_multiplier = alpha_multiplier
end

HudElementblitzbar._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
	if mod._is_in_hub() then return end

	if self._alpha_multiplier ~= 0 then
		local previous_alpha_multiplier = render_settings.alpha_multiplier
		render_settings.alpha_multiplier = self._alpha_multiplier

		HudElementblitzbar.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

		local gauge_widget = self._widgets_by_name.gauge
		gauge_widget.content.value_text = self:_get_value_text()

		self:_draw_shields(dt, t, ui_renderer)

		render_settings.alpha_multiplier = previous_alpha_multiplier
	end
end
local function y_offset()
	local Y_OFFSETS = {}
	Y_OFFSETS[12] = 0
	Y_OFFSETS[11] = 0
	Y_OFFSETS[10] = 0
	Y_OFFSETS[9] = 0
	Y_OFFSETS[8] = 0
	Y_OFFSETS[7] = 0
	Y_OFFSETS[6] = 39
	Y_OFFSETS[5] = 0
	Y_OFFSETS[4] = 64
	Y_OFFSETS[3] = 90
	Y_OFFSETS[2] = 141
	Y_OFFSETS[1] = 0
	return Y_OFFSETS[resource_info.max_stacks]
end

HudElementblitzbar._get_value_text = function (self)
	local format = ""
	local value = nil

	local archetype = self._archetype_name

	local value_option = mod:get(archetype .. "_gauge_value")
	if value_option == mod.value_options["none"] then return "" end

	local description = mod:get(archetype .. "_gauge_value_text")

	--if self._veteran_replenish and mod:get("veteran_override_replenish_text") then --and value_option ~= mod.value_options["none"] then
	if resource_info.replenish and mod:get("veteran_override_replenish_text") then
		if value_option ~= mod.value_options["value_option_time_percent"] then
			value_option = mod.value_options["value_option_time_seconds"]
		end
	end

	local progress = resource_info.progress
	local max_duration = resource_info.max_duration
	local stacks = resource_info.stacks
	local max_stacks = resource_info.max_stacks
	local full = (progress == nil and stacks == max_stacks) or (progress == 1 and stacks == max_stacks)
	local empty = (progress == nil and stacks == 0) or (progress == 0 and stacks == 0)

	if value_option == mod.value_options["value_option_damage"] and (self._archetype_name == "psyker" or self._zealot_martyrdom) then
		format = "%.0f%%"
		value = resource_info:damage_boost() * 100
	elseif value_option == mod.value_options["value_option_stacks"] then
		format = "%.0fx"
		value = resource_info.stacks
	--elseif value_option == mod.value_options["value_option_time_percent"] and (self._archetype_name == "psyker" or self._veteran_replenish) then
	elseif value_option == mod.value_options["value_option_time_percent"] and (self._archetype_name == "psyker" or resource_info.replenish) then
		format = "%.0f%%"
		value = progress * 100
	--elseif value_option == mod.value_options["value_option_time_seconds"] and (self._archetype_name == "psyker" or self._veteran_replenish) then
	elseif value_option == mod.value_options["value_option_time_seconds"] and (self._archetype_name == "psyker" or resource_info.replenish) then
		format = "%.0fs"
		value = progress * max_duration
		--if self._veteran_replenish then --count down for veteran demostockpile
		if resource_info.replenish then
			value = max_duration - value
		end
	end

	if mod:get("value_time_full_empty") then
		if (progress == nil and stacks == 0) or (progress == 0 and stacks == 0) then
			format = (self._archetype_name == "psyker" or self._zealot_martyrdom)
				and "" or ("{#color(249, 69, 69)}" .. mod:localize("empty"))
			description = nil
		elseif (progress == nil and stacks == max_stacks) or (progress == 1 and stacks == max_stacks) then
			format = (self._archetype_name == "psyker" or self._zealot_martyrdom)
				and ("{#color(249, 69, 69)}" .. mod:localize("max")) or mod:localize("full")
			description = nil
		end
	end

	local value_text = string.format(format, value)

	-- Prepend description
	if value and description then
		value_text = mod:localize(value_option .. "_display") .. " " .. value_text
	end

	return value_text
end

HudElementblitzbar._draw_shields = function (self, dt, t, ui_renderer)
	local num_shields = self._shield_amount

    if not num_shields then return end

	if num_shields < 1 then return end

	local widget = self._shield_widget
	local widget_offset = widget.offset
	local shield_width = self._shield_width

	local step_fraction = 1 / num_shields
	local spacing = HudElementblitzbarSettings.spacing
	local shield_offset = (shield_width + spacing) * (num_shields - 1) * 0.5
	if not self._horizontal then
		shield_offset = shield_offset + y_offset()
	end
	local shields = self._shields

	local progress = resource_info.progress or 1
	local stacks = resource_info.stacks - (resource_info.replenish and 0 or 1)
    local souls_progress = ( progress + ( stacks ) ) / resource_info.max_stacks

	for i = num_shields, 1, -1 do
		local shield = shields[i]

		if not shield then return end

		local end_value = i * step_fraction
		local start_value = end_value - step_fraction

		local color_full_name	= mod:get(self._archetype_name .. "_color_full")	or "ui_hud_yellow_super_light"
		local color_empty_name	= mod:get(self._archetype_name .. "_color_empty")	or "ui_hud_yellow_medium"

		local value
		if souls_progress >= end_value then
			value = 0
		elseif start_value < souls_progress then
			value = 1 - progress
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
			widget_offset[1] = shield_offset
			widget_offset[2] = self._flipped and 2 or 1
		else
			local scenegraph_size = self:scenegraph_size("shield")
			local height = scenegraph_size.y

			widget_offset[1] = 0
			widget_offset[2] = height - shield_offset
		end

		UIWidget.draw(widget, ui_renderer)

		shield_offset = shield_offset - shield_width - spacing
	end
end

return HudElementblitzbar