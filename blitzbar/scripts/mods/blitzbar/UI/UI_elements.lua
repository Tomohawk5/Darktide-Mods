local mod = get_mod("blitzbar")

local Definitions = mod:io_dofile("blitzbar/scripts/mods/blitzbar/UI/UI_definitions")
local HudElementblitzbarSettings = mod:io_dofile("blitzbar/scripts/mods/blitzbar/UI/UI_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local HudElementblitzbar = class("HudElementblitzbar", "HudElementBase")

-- NEW ABILITIES LOCATION
--"scripts/settings/ability/player_abilities/player_abilities"
--"scripts/settings/talent/talent_settings_new"

local resource_info_template = {
	display_name = nil,
	max_stacks = nil,
	max_duration = nil,
	decay = nil,
	grenade_ability = nil,
	stack_buff = nil,
	stacks = 0,
	progress = 0,
	timed = nil,
	replenish = nil,
	replenish_buff = nil,
	damage_per_stack = nil,
	damage_boost = function (self)
		if not self.stacks then return nil end
		if not self.max_stacks then return nil end
		if not self.damage_per_stack then return nil end

		return math.min(self.stacks, self.max_stacks) * self.damage_per_stack
	end
}

local resource_info

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
	local talents = profile.archetype.talents

	resource_info = nil

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
		local psionics_equipped = player_talents.psyker_empowered_ability == 1
		if psionics_equipped then
			mod:notify("PSIONICS EQUIPPED")

			local extra_stacks = player_talents.psyker_empowered_grenades_increased_max_stacks == 1

			mod:echo("extra_stacks: " .. (extra_stacks and "true" or "false"))

			local psionics = {
				display_name = mod.text_options["text_option_psionics"],
				max_stacks = extra_stacks and 3 or 1,
				max_duration = nil,
				decay = true,
				grenade_ability = false,
				-- stack_buff = {
				-- 	"psyker_empowered_grenades_passive",
				-- 	"psyker_empowered_grenades_passive_improved"
				-- },
				stack_buff = extra_stacks and "psyker_empowered_grenades_passive_visual_buff_increased" or "psyker_empowered_grenades_passive_visual_buff",
				stacks = 0,
				progress = 0,
				timed = false,
				replenish = nil,
				replenish_buff = nil,
				damage_per_stack = nil,
				damage_boost = nil
			}

			resource_info = table.clone(psionics)
		end

		local souls_equipped = player_talents.psyker_passive_souls_from_elite_kills == 1
		if souls_equipped then
			mod:notify("SOULS EQUIPPED")

			local extra_souls = player_talents.psyker_increased_max_souls
			local souls_amount = talents.psyker_increased_max_souls.format_values.soul_amount.value -- 6
			local souls_damage = player_talents.psyker_souls_increase_damage
			local souls_damage_increase = 0.04 --talents.psyker_souls_increased_damage.format_values.damage.value -- +0.04%

			--template_data.buff_name = template_data.psyker_increased_max_souls and "psyker_souls_increased_max_stacks" or "psyker_souls"

			local souls = {
				display_name = mod.text_options["text_option_warpcharges"],
				max_stacks = extra_souls and 6 or 4,
				max_duration = 20,
				decay = true,
				grenade_ability = false,
				stack_buff = extra_souls and "psyker_souls_increased_max_stacks" or "psyker_souls",
				stacks = 0,
				progress = 0,
				timed = true,
				replenish = nil,
				replenish_buff = nil,
				damage_per_stack = souls_damage and souls_damage_increase or 0,
				damage_boost = resource_info_template.damage_boost
			}

			resource_info = table.clone(souls)
		end

		local destiny_equipped = player_talents.psyker_new_mark_passive
		if destiny_equipped then
			mod:notify("DESTINY EQUIPPED")

			local increased_duration = player_talents.psyker_mark_increased_duration == 1
			local increased_stacks = player_talents.psyker_mark_increased_max_stacks == 1
			local weakspot_bonus = player_talents.psyker_mark_weakspot_kills == 1

			local destiny = {
				display_name = mod.text_options["text_option_destiny"],
				max_stacks = increased_stacks and 30 or 15,
				max_duration = increased_duration and 30 or 15,
				decay = false,
				grenade_ability = false,
				stack_buff =	(increased_stacks and "psyker_marked_enemies_passive_bonus_stacking_increased_stacks") or
								(increased_duration and "psyker_marked_enemies_passive_bonus_stacking_increased_duration") or
								"psyker_marked_enemies_passive_bonus_stacking",
				stacks = 0,
				progress = 0,
				timed = true,
				replenish = nil,
				replenish_buff = nil,
				damage_per_stack = 0, --psyker_souls_increase_damage.format_values.value,
				damage_boost = resource_info_template.damage_boost
			}

			resource_info = table.clone(destiny)
		end

		local knives = player_talents.psyker_grenade_throwing_knives
		local knives_equipped = knives and mod:get("psyker_grenade")

		if knives_equipped then

			local grenade = knives and talents.psyker_grenade_throwing_knives
			local grenade_ability = grenade.player_ability.ability

			local assail_quicker = "psyker_reduced_throwing_knife_cooldown"

			local assail = {
				display_name = mod.text_options["text_option_assail"],
				max_stacks = grenade_ability.max_charges,
				max_duration = grenade.cooldown,
				decay = true,
				grenade_ability = true,
				stack_buff = nil,
				stacks = 0,
				progress = 0,
				timed = true,
				replenish = true,
				replenish_buff = "psyker_knife_replenishment",
				damage_per_stack = 0,
				damage_boost = nil
			}

			resource_info = table.clone(assail)
		end

		-- if not (souls_equipped or psionics_equipped or destiny_equipped or knives_equipped) then
		-- 	resource_info = {
		-- 		display_name = "none",
		-- 		max_stacks = nil,
		-- 		max_duration = nil,
		-- 		decay = true,
		-- 		stack_buff = nil,
		-- 		stacks = nil,
		-- 		progress = nil,
		-- 		timed = nil,
		-- 		replenish = nil,
		-- 		replenish_buff = nil,
		-- 		damage_per_stack = nil,
		-- 		damage_boost = nil
		-- 	}
		-- 	mod:notify("No Grenade / Keystone to display!")
		-- end

		--local souls = player_talents.psyker_souls

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

	end

	if self._archetype_name == "zealot" then
		if mod:get("zealot_grenade") then
			local stun_equipped = player_talents.zealot_shock_grenade or player_talents.zealot_improved_stun_grenade
			if stun_equipped then
				mod:notify("STUN EQUIPPED")
				local stun_grenade = {
					display_name = mod.text_options["text_option_stun"],
					max_stacks = talents.zealot_shock_grenade.player_ability.ability.max_charges,
					max_duration = nil,
					decay = true,
					grenade_ability = true,
					stack_buff = nil,
					stacks = 0,
					progress = 0,
					timed = false,
					replenish = false,
					replenish_buff = nil,
					damage_per_stack = nil,
					damage_boost = nil
				}
				resource_info = table.clone(stun_grenade)
			end

			local flame_equipped = player_talents.zealot_flame_grenade
			if flame_equipped then
				mod:notify("FLAME EQUIPPED")
				local flame_grenade = {
					display_name = mod.text_options["text_option_flame"],
					max_stacks = talents.zealot_flame_grenade.player_ability.ability.max_charges,
					max_duration = nil,
					decay = true,
					grenade_ability = true,
					stack_buff = nil,
					stacks = 0,
					progress = 0,
					timed = false,
					replenish = false,
					replenish_buff = nil,
					damage_per_stack = nil,
					damage_boost = nil
				}
				resource_info = table.clone(flame_grenade)
			end

			local knife_equipped = player_talents.zealot_throwing_knives
			if knife_equipped then
				mod:notify("KNIFE EQUIPPED")
				local knife_grenade = {
					display_name = mod.text_options["text_option_knife"],
					max_stacks = talents.zealot_shock_grenade.player_ability.ability.max_charges,
					max_duration = nil,
					decay = true,
					grenade_ability = true,
					stack_buff = nil,
					stacks = 0,
					progress = 0,
					timed = false,
					replenish = false,
					replenish_buff = nil,
					damage_per_stack = nil,
					damage_boost = nil
				}
				resource_info = table.clone(knife_grenade)
			end
		end
	end

	if self._archetype_name == "veteran" then

		local frag = player_talents.veteran_frag_grenade
		local krak = player_talents.veteran_krak_grenade
		local smoke = player_talents.veteran_smoke_grenade

		local grenade = frag	and talents.veteran_frag_grenade or
						krak	and talents.veteran_krak_grenade or
						smoke	and talents.veteran_smoke_grenade

		if grenade then
			local grenade_ability = grenade.player_ability.ability
			local replenish_grenade = player_talents.veteran_replenish_grenades == 1

			local vet_grenade = {
				display_name =	(frag and mod.text_options["text_option_frag"]) or
								(krak and mod.text_options["text_option_krak"]) or
								mod.text_options["text_option_smoke"],
				max_stacks = grenade_ability.max_charges + (player_talents.veteran_extra_grenade or 0),
				max_duration = replenish_grenade and talents.veteran_replenish_grenades.format_values.time.value or nil,
				decay = true,
				grenade_ability = true,
				stack_buff = nil,
				stacks = 0,
				progress = 0,
				timed = replenish_grenade,
				replenish = replenish_grenade,
				replenish_buff = replenish_grenade and "veteran_grenade_replenishment" or nil,
				damage_per_stack = nil,
				damage_boost = nil
			}
			resource_info = table.clone(vet_grenade)
		end
	end

	-- TODO: Fix grenade charge bars not being empty
	if self._archetype_name == "ogryn" then
		local ogryn_armour = player_talents.ogryn_carapace_armor
		if ogryn_armour then
			mod:notify("ARMOUR EQUIPPED")
			local feel_no_pain = {
				display_name = mod.text_options["text_option_armour"],
				max_stacks = 10,
				max_duration = 6,
				decay = true,
				grenade_ability = false,
				stack_buff = "ogryn_carapace_armor_child",
				stacks = 0,
				progress = 0,
				timed = false,
				replenish = true,
				replenish_buff = "ogryn_carapace_armor_parent",
				damage_per_stack = 0.025,
				damage_boost = resource_info_template.damage_boost
			}
			resource_info = table.clone(feel_no_pain)
		end

		if mod:get("ogryn_grenade") or not ogryn_armour then
			local rock	= player_talents.ogryn_grenade_friend_rock
			if rock then
				mod:notify("ROCK EQUIPPED")
				local rock_grenade = {
					display_name = mod.text_options["text_option_rock"],
					max_stacks = rock.player_ability.ability.max_charges,
					max_duration = talents.ogryn_grenade_friend_rock.cooldown,
					decay = true,
					grenade_ability = true,
					stack_buff = nil,
					stacks = 0,
					progress = 0,
					timed = true,
					replenish = true,
					replenish_buff = "ogryn_friend_grenade_replenishment",
					damage_per_stack = nil,
					damage_boost = nil
				}
				resource_info = table.clone(rock_grenade)
			end

			local box	= player_talents.ogryn_grenade_box or player_talents.ogryn_box_explodes
			if box then
				mod:notify("BOX EQUIPPED")
				local box_grenade = {
					display_name = mod.text_options["text_option_box"],
					max_stacks = 2,
					max_duration = nil,
					decay = true,
					grenade_ability = true,
					stack_buff = nil,
					stacks = 0,
					progress = 0,
					timed = false,
					replenish = false,
					replenish_buff = nil,
					damage_per_stack = nil,
					damage_boost = nil
				}
				resource_info = table.clone(box_grenade)
			end

			local frag	= player_talents.ogryn_grenade_frag
			if frag then
				mod:notify("NUKE EQUIPPED")
				local frag_grenade = {
					display_name = mod.text_options["text_option_frag"],
					max_stacks = 1,
					max_duration = nil,
					decay = true,
					grenade_ability = true,
					stack_buff = nil,
					stacks = 0,
					progress = 0,
					timed = false,
					replenish = false,
					replenish_buff = nil,
					damage_per_stack = nil,
					damage_boost = nil
				}
				resource_info = table.clone(frag_grenade)
			end
		end
	end
		-- ogryn_carapace_armor = {
		-- 	description = "loc_talent_ogryn_carapace_armor_desc",
		-- 	name = "Carapace armor",
		-- 	display_name = "loc_talent_ogryn_carapace_armor",
		-- 	icon = "content/ui/textures/icons/talents/ogryn_1/ogryn_1_base_3",
		-- 	format_values = {
		-- 		toughness_regen = {
		-- 			prefix = "+",
		-- 			format_type = "percentage",
		-- 			find_value = {
		-- 				buff_template_name = "ogryn_carapace_armor_child",
		-- 				find_value_type = "buff_template",
		-- 				path = {
		-- 					"stat_buffs",
		-- 					stat_buffs.toughness_regen_rate_modifier
		-- 				}
		-- 			}
		-- 		},
		-- 		damage_reduction = {
		-- 			prefix = "+",
		-- 			format_type = "percentage",
		-- 			find_value = {
		-- 				buff_template_name = "ogryn_carapace_armor_child",
		-- 				find_value_type = "buff_template",
		-- 				path = {
		-- 					"stat_buffs",
		-- 					stat_buffs.toughness_damage_taken_modifier
		-- 				}
		-- 			},
		-- 			value_manipulation = function (value)
		-- 				return math.abs(value) * 100
		-- 			end
		-- 		},
		-- 		stacks = {
		-- 			format_type = "number",
		-- 			find_value = {
		-- 				buff_template_name = "ogryn_carapace_armor_child",
		-- 				find_value_type = "buff_template",
		-- 				path = {
		-- 					"max_stacks"
		-- 				}
		-- 			}
		-- 		},
		-- 		duration = {
		-- 			format_type = "number",
		-- 			find_value = {
		-- 				buff_template_name = "ogryn_carapace_armor_parent",
		-- 				find_value_type = "buff_template",
		-- 				path = {
		-- 					"restore_child_duration"
		-- 				}
		-- 			}
		-- 		}
		-- 	},
		-- 	passive = {
		-- 		buff_template_name = "ogryn_carapace_armor_parent",
		-- 		identifier = "ogryn_carapace_armor_parent"
		-- 	}
		-- }
	if resource_info == nil then
		resource_info = {
			display_name = mod.text_options["none"],
			max_stacks = nil,
			max_duration = nil,
			decay = true,
			grenade_ability = false,
			stack_buff = nil,
			stacks = nil,
			progress = nil,
			timed = nil,
			replenish = nil,
			replenish_buff = nil,
			damage_per_stack = nil,
			damage_boost = nil
		}
		mod:error("No Grenade / Keystone to display!")
	end

	-- mod:echo("> RESOURCE INFO")
	-- --mod:echo("max_stacks: " .. resource_info.max_stacks == nil and "[x]" or resource_info.max_stacks)
	-- mod:echo("max_stacks: " .. (resource_info.max_stacks or "[x]"))
	-- mod:echo("max_duration: " .. (resource_info.max_duration or "[x]"))
	-- mod:echo("decay: " .. (resource_info.decay and (resource_info.decay and "true" or "false") or "[x]"))
	-- mod:echo("stack_buff: " .. (resource_info.stack_buff or "[x]"))
	-- mod:echo("timed: " .. (resource_info.timed and (resource_info.timed and "true" or "false") or "[x]"))
	-- mod:echo("replenish: " .. (resource_info.replenish and (resource_info.replenish and "true" or "false") or "[x]"))
	-- mod:echo("replenish_buff: " .. (resource_info.replenish_buff or "[x]"))
	-- mod:echo("damage_per_stack: " .. (resource_info.damage_per_stack or "[x]"))
	-- mod:echo("damage_boost: " .. (resource_info.damage_boost  and "<Function>" or "[x]"))
	-- mod:echo("< RESOURCE INFO")

	if mod:get("auto_text_option") then
		mod:echo(resource_info.display_name)
		mod:set("gauge_text", resource_info.display_name or mod.text_options["text_option_blitz"])
	else
		mod:set("gauge_text", self._archetype_name .. "_gauge_text")
	end
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

	--local grenade = mod:get(self._archetype_name .. "_grenade") and resource_info.grenade_ability

	if player_extensions then
		local buff_extension = player_extensions.buff
		if buff_extension then
			local found_buff = false
			local buffs = buff_extension:buffs()
			for i = 1, #buffs do
				local buff = buffs[i]
				local buff_name = buff:template_name()

				-- DEBUG:
				-- if buff_name:find("^psyker_marked_enemies_passive_bonus") ~= nil then
				-- 	mod:echo(buff_name)
				-- end

				--local has_buff = buff_extension:has_unique_buff_id("ogryn_carapace_armor_explosion_on_zero_stacks_effect")

				if buff_name == resource_info.replenish_buff then
					resource_info.progress = buff:duration_progress()
					found_buff = true
				end


				if buff_name == resource_info.stack_buff then
					local stack_count = buff:stack_count()
					if resource_info.stack_buff == "ogryn_carapace_armor_child" then stack_count = stack_count - 1 end
					resource_info.stacks = math.min(stack_count, resource_info.max_stacks)
					resource_info.progress = buff:duration_progress()
					found_buff = true
				end
			end

			if not found_buff then
				resource_info.progress = nil
				resource_info.stacks = 0
			end
		end

		if resource_info.grenade_ability then -- or (resource_info.stack_buff == nil and resource_info.replenish_buff == nil) then
			local ability_extension = player_extensions.ability
			if ability_extension and ability_extension:ability_is_equipped("grenade_ability") then
				resource_info.stacks = ability_extension:remaining_ability_charges("grenade_ability")
			end

			if not resource_info.replenish then
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

local function update_old()
	HudElementblitzbar.super.update(self, dt, t, ui_renderer, render_settings, input_service)

    local widget = self._widgets_by_name.gauge
    if not widget then return end

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
	Y_OFFSETS[30] = 0
	Y_OFFSETS[20] = 0
	Y_OFFSETS[15] = 0
	Y_OFFSETS[12] = 0
	Y_OFFSETS[11] = 0
	Y_OFFSETS[10] = 108
	Y_OFFSETS[9] = 0
	Y_OFFSETS[8] = 0
	Y_OFFSETS[7] = 0
	Y_OFFSETS[6] = 39	-- old
	Y_OFFSETS[5] = 0	-- old
	Y_OFFSETS[4] = 64	-- old
	Y_OFFSETS[3] = 90	-- old
	Y_OFFSETS[2] = 141	-- old
	Y_OFFSETS[1] = 0
	return Y_OFFSETS[resource_info.max_stacks]
end

local function vertical_offset(n)
	local total_segment_spacing = 4 * math.max(n - 1, 0)
	local total_bar_length = 200 - total_segment_spacing

	local w = math.round(n > 0 and total_bar_length / n or total_bar_length)

	return ((200 / n) + 4) * (n - 1) * 0.5
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

	if value_option == mod.value_options["value_option_damage"] and resource_info.damage_boost then
		format = "%." .. (mod:get("value_decimals") and "1" or "0") .. "f%%"
		value = resource_info:damage_boost() * 100
	elseif value_option == mod.value_options["value_option_stacks"] and stacks then
		format = "%.0fx"
		value = resource_info.stacks
	elseif value_option == mod.value_options["value_option_time_percent"] and resource_info.timed and progress then
		format = "%." .. (mod:get("value_decimals") and "1" or "0") .. "f%%"
		value = progress * 100
	elseif value_option == mod.value_options["value_option_time_seconds"] and resource_info.timed and progress and max_duration then
		format = "%.0fs"
		value = progress * max_duration
		if resource_info.replenish then
			value = max_duration - value -- countdown for refill
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
		--shield_offset = shield_offset + y_offset()

		local n = num_shields

		local total_segment_spacing = 4 * math.max(n - 1, 0)
		local total_bar_length = 200 - total_segment_spacing
		local w = math.round(n > 0 and total_bar_length / n or total_bar_length)

		w = total_bar_length
		w = (w * 0.5) + (shield_width - 2)
		w = (total_bar_length * 0.5) + (shield_width)
		w = 100 + (shield_width * 0.5) + 4 -- BEST SO FAR
		w = 100 + (shield_width * 0.5) + (num_shields * 8)

		--mod:echo("w : " .. w)

		shield_offset = w
	end
	local shields = self._shields

	local progress = resource_info.progress or 1
	local stacks = resource_info.stacks - (resource_info.replenish and 0 or 1)
    local souls_progress = ( progress + ( stacks ) ) / resource_info.max_stacks

	local decay = resource_info.decay

	--mod:echo("step_fraction: " .. step_fraction)
	--mod:echo("progress: " .. progress)
	--mod:echo("souls_progress: " .. souls_progress)

	for i = num_shields, 1, -1 do
		local shield = shields[i]

		if not shield then return end

		local end_value = i * step_fraction
		local start_value = end_value - step_fraction

		--mod:echo("start: " .. start_value .. " end: " .. end_value)
		--mod:echo(string.format("S: %.4f, E: %.4f, P: %.4f", start_value, end_value, souls_progress))
		--mod:echo(string.format("SP: %.4f, P: %.4f", souls_progress, progress))
		--mod:echo(decay)

		local color_full_name	= mod:get(self._archetype_name .. "_color_full")	or "ui_hud_yellow_super_light"
		local color_empty_name	= mod:get(self._archetype_name .. "_color_empty")	or "ui_hud_yellow_medium"

		local value
		if souls_progress >= end_value then
			value = decay and 1 or progress
		elseif start_value < souls_progress then
			value = progress
		else
			value = 0
		end

		local color_full	= Color[color_full_name](255, true)
		local color_empty	= Color[color_empty_name](value == 1 and 255 or 100, true)

		local widget_style = widget.style
		local widget_color = widget_style.full.color

		for e = 1, 4 do
			--widget_color[e] = math.lerp(color_full[e], color_empty[e], value)
			widget_color[e] = math.lerp(color_empty[e], color_full[e], value)
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
		--mod:echo(i .. " : " .. shield_offset)
	end
end

return HudElementblitzbar