local mod = get_mod("blitzbar")

local Definitions = mod:io_dofile("blitzbar/scripts/mods/blitzbar/UI/UI_definitions")
local HudElementblitzbarSettings = mod:io_dofile("blitzbar/scripts/mods/blitzbar/UI/UI_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local HudElementblitzbar = class("HudElementblitzbar", "HudElementBase")

-- NEW ABILITIES LOCATION
--"scripts/settings/ability/player_abilities/player_abilities"
--"scripts/settings/talent/talent_settings_new"

--TODO: Resource type enum
--TODO: Rename / Consolodate (damage_per_stack -> resource_buff?)

local resource_info_template = {
	display_name = nil,
	max_stacks = nil,
	max_duration = nil,
	decay = nil,                        -- STACKS FALL OFF 1 AT A TIME ?
	grenade_ability = nil,
    talent_resource = nil,              -- unit_data_extension:read_component("talent_resource")
	stack_buff = nil,                   -- BUFF THAT DETERMINES STACK COUNT
	stacks = 0,
	progress = 0,
	timed = nil,                        -- DOES THE BUFF HAVE A TIMER ?
	replenish = nil,                    -- DOES THE BUFF REFILL ITSELF ?
	replenish_buff = nil,               -- BUFF THAT DETEMINES REFILL
	damage_per_stack = nil,
	damage_boost = function (self)
		if not self.stacks then return nil end
		if not self.max_stacks then return nil end
		if not self.damage_per_stack then return nil end

		return math.min(self.stacks, self.max_stacks) * self.damage_per_stack
	end
}

local resource_info

HudElementblitzbar.init = function (self, parent, draw_layer, start_scale)
	HudElementblitzbar.super.init(self, parent, draw_layer, start_scale, Definitions)

	--mod:echo("HudElementblitzbar.init")

	self._shields = {}
	self._shield_width = 0
	self._shield_widget = self:_create_widget("shield", Definitions.shield_definition)

	self._player = Managers.player:local_player(1)
    self._archetype_name = self._player:archetype_name()
	self._enabled = mod:get(self._archetype_name .. "_show_gauge")

    local profile = self._player:profile()
	local player_talents = profile.talents
	local talents = profile.archetype.talents

    local talent_extension = ScriptUnit.extension(self._player.player_unit, "talent_system")
    local unit_data_extension = ScriptUnit.has_extension(self._player.player_unit, "unit_data_system")

	resource_info = nil

	if self._archetype_name == "psyker" then
		local psionics_equipped = player_talents.psyker_empowered_ability == 1
		if psionics_equipped then
			--mod:notify("PSIONICS EQUIPPED")

			local extra_stacks = player_talents.psyker_empowered_grenades_increased_max_stacks == 1

			--mod:echo("extra_stacks: " .. (extra_stacks and "true" or "false"))

			local psionics = {
				display_name = mod.text_options["text_option_psionics"],
				max_stacks = extra_stacks and 3 or 1,
				max_duration = nil,
				decay = true,
				grenade_ability = false,
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
			--mod:notify("SOULS EQUIPPED")

			local extra_souls = player_talents.psyker_increased_max_souls
			local souls_amount = talents.psyker_increased_max_souls.format_values.soul_amount.value -- 6
			local souls_damage = player_talents.psyker_souls_increase_damage
			local souls_damage_increase = 0.04 --talents.psyker_souls_increased_damage.format_values.damage.value -- +0.04%

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
			--mod:notify("DESTINY EQUIPPED")

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
				damage_per_stack = 0,
				damage_boost = resource_info_template.damage_boost
			}

			resource_info = table.clone(destiny)
		end

		local knives_equipped = player_talents.psyker_grenade_throwing_knives

		if (knives_equipped and mod:get("psyker_grenade")) or not (psionics_equipped or souls_equipped or destiny_equipped) then
			local grenade_ability = talents.psyker_grenade_throwing_knives.player_ability.ability
			local assail_quicker = player_talents.psyker_reduced_throwing_knife_cooldown

			local assail = {
				display_name = mod.text_options["text_option_assail"],
				max_stacks = grenade_ability.max_charges,
				max_duration = grenade_ability.cooldown * (assail_quicker and 0.7 or 1),
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
	end

	if self._archetype_name == "zealot" then
		local martyrdom_equipped = player_talents.zealot_martyrdom
		if martyrdom_equipped then
			--mod:notify("MARTYRDOM EQUIPPED")
            local health_extension = ScriptUnit.extension(self._player.player_unit, "health_system")
			local martyrdom = {
				display_name = mod.text_options["text_option_martyrdom"],
				max_stacks = health_extension and (health_extension:max_wounds() - 1) or talents.zealot_martyrdom.format_values.max_wounds.value, --9, zealot_additional_wounds:["zealot_preacher_more_segments"]
				max_duration = nil,
				decay = true,
				grenade_ability = false,
				stack_buff = "zealot_martyrdom_base", --"zealot_martyrdom_attack_speed", "zealot_martyrdom_toughness",
				stacks = 0,
				progress = 0,
				timed = false,
				replenish = false,
				replenish_buff = nil,
				damage_per_stack = talents.zealot_martyrdom.format_values.damage.value, --0.08,
				damage_boost = resource_info_template.damage_boost
			}
			resource_info = table.clone(martyrdom)
		end
		local piety_equipped = player_talents.zealot_fanatic_rage
		if piety_equipped then
			--mod:notify("PIETY EQUIPPED")
			local piety = {
				display_name = mod.text_options["text_option_piety"],
				max_stacks = talents.zealot_fanatic_rage.format_values.max_stacks.value,
				max_duration = talents.zealot_fanatic_rage.format_values.duration.value,
				decay = true,
				grenade_ability = false,
				stack_buff = "zealot_fanatic_rage",
				stacks = 0,
				progress = 0,
				timed = false,
				replenish = false,
				replenish_buff = nil,
				damage_per_stack = nil,
				damage_boost = nil
			}
			resource_info = table.clone(piety)
		end

		local inexorable_equipped = player_talents.zealot_quickness_passive
		if inexorable_equipped then
			--mod:notify("INEXORABLE EQUIPPED")
			local inexorable = {
				display_name = mod.text_options["text_option_inexorable"],
				max_stacks = talents.zealot_quickness_passive.format_values.max_stacks.value, -- 20
				max_duration = nil,
				decay = true,
				grenade_ability = false,
				stack_buff = "zealot_quickness_passive", -- "zealot_quickness_active"
				stacks = 0,
				progress = 0,
				timed = false,
				replenish = false,
				replenish_buff = nil,
				damage_per_stack = nil,
				damage_boost = nil
			}
			resource_info = table.clone(inexorable)
		end

		if mod:get("zealot_grenade") or not (martyrdom_equipped or piety_equipped or inexorable_equipped) then
			local stun_equipped = player_talents.zealot_shock_grenade or player_talents.zealot_improved_stun_grenade
			if stun_equipped then
				--mod:notify("STUN EQUIPPED")
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
				--mod:notify("FLAME EQUIPPED")
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
				--mod:notify("KNIFE EQUIPPED")
				local knife_grenade = {
					display_name = mod.text_options["text_option_knife"],
					max_stacks = talents.zealot_throwing_knives.player_ability.ability.max_charges,
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

        local snipers_focus_equipped = player_talents.veteran_snipers_focus
        if snipers_focus_equipped then
            mod:notify("MARKSMAN EQUIPPED")

            local stacks_on_still = talent_extension:has_special_rule("veteran_snipers_focus_stacks_on_still")
            local max_stacks = talent_extension:has_special_rule("veteran_snipers_focus_increased_stacks")
                                and talents.veteran_snipers_focus_increased_stacks.format_values.new_stacks.value   -- 15
                                or talents.veteran_snipers_focus_increased_stacks.format_values.stacks.value        -- 10
            
			resource_info = {
				display_name = mod.text_options["text_option_snipers_focus"],
				max_stacks = max_stacks, -- 10 or 15
				max_duration = nil,
				decay = not talent_extension:has_special_rule("veteran_snipers_focus_stacks_on_still"),
				grenade_ability = false,
                talent_resource = unit_data_extension:read_component("talent_resource"),
				stack_buff = nil,
				stacks = 0,
				progress = 0,
				timed = false, --talent_extension:has_special_rule("veteran_snipers_focus_stacks_on_still"),
				replenish = false, --talent_extension:has_special_rule("veteran_snipers_focus_stacks_on_still"),    --TODO: Get progress working? Not essential
				replenish_buff = "", --"veteran_snipers_focus",
				damage_per_stack = 0.075, -- 7.5% ranged finesse
				damage_boost = resource_info_template.damage_boost
			}
        end

        local improved_tag_equipped = player_talents.veteran_improved_tag
        if improved_tag_equipped then
            mod:notify("FOCUS EQUIPPED")
            local more_damage_talent = talent_extension:has_special_rule("veteran_improved_tag_more_damage")
            local extra_stacks = player_talents.veteran_improved_tag_more_damage == 1
			resource_info = {
				display_name = mod.text_options["text_option_improved_tag"],
				max_stacks = extra_stacks and 8 or 5,
				max_duration = 2,
				decay = true,
				grenade_ability = false,
                talent_resource = unit_data_extension:read_component("talent_resource"),
				stack_buff = "veteran_improved_tag_effect",
				stacks = 0,
				progress = 0,
				timed = true,
				replenish = true,
				replenish_buff = "veteran_improved_tag",
				damage_per_stack = 15, -- 15%
				damage_boost = resource_info_template.damage_boost
			}
        end

        local weapon_switch_equipped = player_talents.veteran_weapon_switch_passive
        if weapon_switch_equipped then
            mod:notify("WEAPONS EQUIPPED")
            local more_damage_talent = talent_extension:has_special_rule("veteran_improved_tag_more_damage")
            local extra_stacks = player_talents.veteran_improved_tag_more_damage == 1
			resource_info = {
				display_name = mod.text_options["text_option_weapon_switch"],
				max_stacks = 10,
				max_duration = 2,
				decay = true,
				grenade_ability = false,
                talent_resource = unit_data_extension:read_component("talent_resource"), -- Ranged Stacks
				stack_buff = "veteran_weapon_switch_melee_visual",
				stacks = 0,
				progress = 0,
				timed = true,
				replenish = true,
				replenish_buff = "",
				damage_per_stack = 15, -- 15%
				damage_boost = resource_info_template.damage_boost
			}
        end

        if mod:get("veteran_grenade") or not (snipers_focus_equipped or improved_tag_equipped or weapon_switch_equipped) then
        
            local replenish_grenade = player_talents.veteran_replenish_grenades == 1
        
            if player_talents.veteran_frag_grenade or player_talents.veteran_frag_grenade_bleed then
                mod:notify("FRAG EQUIPPED")
                resource_info = {
                    display_name =	mod.text_options["text_option_frag"],
                    max_stacks = talents.veteran_frag_grenade.player_ability.ability.max_charges + (player_talents.veteran_extra_grenade or 0),
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
            end

            if player_talents.veteran_krak_grenade then
                mod:notify("KRAK EQUIPPED")
                resource_info = {
                    display_name =	mod.text_options["text_option_krak"],
                    max_stacks = talents.veteran_krak_grenade.player_ability.ability.max_charges + (player_talents.veteran_extra_grenade or 0),
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
            end

            if player_talents.veteran_smoke_grenade then
                mod:notify("SMOKE EQUIPPED")
                resource_info = {
                    display_name =	mod.text_options["text_option_smoke"],
                    max_stacks = talents.veteran_smoke_grenade.player_ability.ability.max_charges + (player_talents.veteran_extra_grenade or 0),
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
            end
        end
	end

	-- TODO: Fix grenade charge bars not being empty
	if self._archetype_name == "ogryn" then
		local ogryn_armour = player_talents.ogryn_carapace_armor
		if ogryn_armour then
			--mod:notify("ARMOUR EQUIPPED")
			local feel_no_pain = {
				display_name = mod.text_options["text_option_armour"],
				max_stacks = 10,
				max_duration = 6,
				decay = true,
				grenade_ability = false,
				stack_buff = "ogryn_carapace_armor_child",
				stacks = 0,
				progress = 0,
				timed = true,
				replenish = true,
				replenish_buff = "ogryn_carapace_armor_parent",
				damage_per_stack = 0.025,
				damage_boost = resource_info_template.damage_boost
			}
			resource_info = table.clone(feel_no_pain)
		end

		if mod:get("ogryn_grenade") or not ogryn_armour then
			local rock = player_talents.ogryn_grenade_friend_rock
			if rock then
				--mod:notify("ROCK EQUIPPED")
				local rock_grenade = {
					display_name = mod.text_options["text_option_rock"],
					max_stacks = talents.ogryn_grenade_friend_rock.player_ability.ability.max_charges,
					max_duration = talents.ogryn_grenade_friend_rock.format_values.recharge.value,
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

			local box = player_talents.ogryn_grenade_box or player_talents.ogryn_box_explodes
			if box then
				--mod:notify("BOX EQUIPPED")
				local box_grenade = {
					display_name = mod.text_options["text_option_box"],
					max_stacks = talents.ogryn_grenade_box.player_ability.ability.max_charges, --2,
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

			local frag = player_talents.ogryn_grenade_frag
			if frag then
				--mod:notify("NUKE EQUIPPED")
				local frag_grenade = {
					display_name = mod.text_options["text_option_frag"],
					max_stacks = talents.ogryn_grenade_frag.player_ability.ability.max_charges, --1,
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

	--mod:echo("> RESOURCE INFO")
	--mod:echo("max_stacks: " .. (resource_info.max_stacks or "[x]"))
	--mod:echo("max_duration: " .. (resource_info.max_duration or "[x]"))
	--mod:echo("decay: " .. (resource_info.decay and (resource_info.decay and "true" or "false") or "[x]"))
	--mod:echo("stack_buff: " .. (resource_info.stack_buff or "[x]"))
	--mod:echo("timed: " .. (resource_info.timed and (resource_info.timed and "true" or "false") or "[x]"))
	--mod:echo("replenish: " .. (resource_info.replenish and (resource_info.replenish and "true" or "false") or "[x]"))
	--mod:echo("replenish_buff: " .. (resource_info.replenish_buff or "[x]"))
	--mod:echo("damage_per_stack: " .. (resource_info.damage_per_stack or "[x]"))
	--mod:echo("damage_boost: " .. (resource_info.damage_boost  and "<Function>" or "[x]"))
	--mod:echo("< RESOURCE INFO")

	if mod:get("auto_text_option") then
		--mod:echo(resource_info.display_name)
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
	if not self._enabled then return end

    local widget = self._widgets_by_name.gauge
    if not widget then return end

	local parent = self._parent
	local player_extensions = parent:player_extensions()

	if player_extensions then
		local buff_extension = player_extensions.buff
		if buff_extension then
			local found_buff = false
			local buffs = buff_extension:buffs()
			for i = 1, #buffs do
				local buff = buffs[i]
				local buff_name = buff:template_name()

				if buff_name == resource_info.replenish_buff then
					resource_info.progress = buff:duration_progress()
					found_buff = true
				end


				if buff_name == resource_info.stack_buff then
					local stack_count = buff:stack_count()

					if resource_info.stack_buff == "ogryn_carapace_armor_child" then stack_count = stack_count - 1 end
					if resource_info.stack_buff == "zealot_martyrdom_base"		then stack_count = buff:visual_stack_count() end
					if resource_info.stack_buff == "zealot_quickness_passive"	then stack_count = buff:visual_stack_count() end
					if resource_info.stack_buff == "zealot_fanatic_rage"		then stack_count = buff:visual_stack_count()
						if stack_count == 1 then stack_count = 0 end
					end

					resource_info.stacks = math.min(stack_count, resource_info.max_stacks)

					if not resource_info.replenish then
						resource_info.progress = buff:duration_progress()
					end
					found_buff = true
				end
			end

			if not found_buff then
				resource_info.progress = nil
				resource_info.stacks = 0
			end
		end

		if resource_info.grenade_ability then
			local ability_extension = player_extensions.ability
			if ability_extension and ability_extension:ability_is_equipped("grenade_ability") then
				resource_info.stacks = ability_extension:remaining_ability_charges("grenade_ability")
			end

			if not resource_info.replenish then
				resource_info.progress = nil
			end
		end

        if resource_info.talent_resource then
            resource_info.stacks = resource_info.talent_resource.current_resource
            resource_info.progress = 0
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
	local draw = resource_info.stacks > 0 or resource_info.replenish

	local alpha_speed = 1 --3
	local alpha_multiplier = self._alpha_multiplier or 0

	if draw then
		alpha_multiplier = math.min(alpha_multiplier + dt * alpha_speed, 1)
	else
		alpha_multiplier = math.max(alpha_multiplier - dt * alpha_speed, 0)
	end

	self._alpha_multiplier = alpha_multiplier
end

HudElementblitzbar._draw_widgets = function (self, dt, t, input_service, ui_renderer, render_settings)
	if not self._enabled or mod._is_in_hub() then return end

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
	Y_OFFSETS[30]	= 100.5
	Y_OFFSETS[25]	= 96
	Y_OFFSETS[20]	= 98
	Y_OFFSETS[15]	= 107
	Y_OFFSETS[12]	= 106.5
	Y_OFFSETS[11]	= 0
	Y_OFFSETS[10]	= 108
	Y_OFFSETS[9]	= 114.5
	Y_OFFSETS[8]	= 0
	Y_OFFSETS[7]	= 0
	Y_OFFSETS[6]	= 123.5
	Y_OFFSETS[5]	= 131
	Y_OFFSETS[4]	= 140.5
	Y_OFFSETS[3]	= 158
	Y_OFFSETS[2]	= 192
	Y_OFFSETS[1]	= 294
	return Y_OFFSETS[resource_info.max_stacks] or 0
end

HudElementblitzbar._get_value_text = function (self)
	local format = ""
	local value = nil

	local archetype = self._archetype_name

	local value_option = mod:get(archetype .. "_gauge_value")
	if value_option == mod.value_options["none"] then return "" end

	local description = mod:get(archetype .. "_gauge_value_text")

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
		format = "%." .. (mod:get("value_decimals") and "1" or "0") .. "fs"
		value = progress * max_duration
		if resource_info.replenish then
			value = max_duration - value -- countdown for refill
		end
	end

    -- TODO: grenade_ability -> isKeystone?
	if mod:get("value_time_full_empty") then
		if (progress == nil and stacks == 0) or (progress == 0 and stacks == 0) then
			format = (resource_info.grenade_ability) and "" or ("{#color(249, 69, 69)}" .. mod:localize("empty"))
			description = nil
		elseif (progress == nil and stacks == max_stacks) or (progress == 1 and stacks == max_stacks) then
			format = (resource_info.grenade_ability) and ("{#color(249, 69, 69)}" .. mod:localize("max")) or mod:localize("full")
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
	local shield_offset
	if self._horizontal then
		shield_offset = (shield_width + spacing) * (num_shields - 1) * 0.5
	else
		shield_offset = y_offset()
	end

	local shields = self._shields

	local progress = (resource_info.timed and resource_info.progress) or 0.99
	local stacks = resource_info.stacks - (resource_info.replenish and 0 or 1)
    local souls_progress = ( progress + ( stacks ) ) / resource_info.max_stacks

	local decay = resource_info.decay

	for i = num_shields, 1, -1 do
		local shield = shields[i]

		if not shield then return end

		local end_value = i * step_fraction
		local start_value = end_value - step_fraction

		local color_full_name	= mod:get(self._archetype_name .. "_color_full")	or "ui_hud_yellow_super_light"
		local color_empty_name	= mod:get(self._archetype_name .. "_color_empty")	or "ui_hud_yellow_medium"

		local value
		if souls_progress >= end_value		then	value = decay and 1 or progress
		elseif start_value < souls_progress then	value = progress
		else										value = 0
		end

		local color_full	= Color[color_full_name](255, true)
		local color_empty	= Color[color_empty_name](value == 1 and 255 or 100, true)

		local widget_style = widget.style
		local widget_color = widget_style.full.color

		for e = 1, 4 do
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

		UIWidget.draw(widget, ui_renderer) -- TODO: Add dirty checks for performance

		shield_offset = shield_offset - shield_width - spacing
	end
end

return HudElementblitzbar