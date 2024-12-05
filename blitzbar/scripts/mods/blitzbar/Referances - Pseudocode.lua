local mod = get_mod("blitzbar")

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

stacks = stack_buff:visual_stack_count() or 0
-- ogryn armour = stack_buff:stack_count() - 1
-- zealot martyrdom & quickness & fanatic = stack_buff:visual_stack_count()

progress = replenish and replenish_buff:duration_progress() or nil

local keystone = {
	special_rule = nil,
	stacks = resource_info.talent_resource.current_resource,	
}
zealot_martyrdom_base.stacks = health_extension:num_wounds()


local blitz = {
    display_name = nil,
	stacks = ability_extension:remaining_ability_charges("grenade_ability"),
	progress = replenish and replenish_buff:duration_progress() or nil,
}

-- COMBAT ABILITIES
-- VETERAN
    VeteranStealthBonusesBuff.duration_progress
    "scripts/extension_systems/buff/buffs/veteran_stealth_bonuses_buff.lua"

-- ZEALOT
    ZealotManiacPassiveBuff.visual_stack_count
    "scripts/extension_systems/buff/buffs/zealot_passive_buff.lua"

-- PSYKER
PsykerBiomancerPassiveBuff.visual_stack_count
"scripts/extension_systems/buff/buffs/psyker_passive_buff.lua"

--OGRYN


-- BUFF
"scripts/extension_systems/buff/buffs/buff.lua"
"scripts/extension_systems/buff/buff_extension_base.lua"

Buff.template = function (self)
	local template = self._template

	return template
end

BuffExtensionBase.current_stacks = function (self, buff_name)
	local buff_instance = self._stacking_buffs[buff_name]

	return buff_instance and buff_instance:stack_count() or 0
end

BuffExtensionBase.buffs = function (self)
	return self._buffs
end

-- ABILITY

"scripts/extension_systems/ability/player_unit_ability_extension.lua"
PlayerUnitAbilityExtension.max_ability_charges = function (self, ability_type)
PlayerUnitAbilityExtension.remaining_ability_charges = function (self, ability_type)
PlayerUnitAbilityExtension.remaining_ability_cooldown = function (self, ability_type)
PlayerUnitAbilityExtension.can_use_ability = function (self, ability_type)

PlayerUnitAbilityExtension.equipped_abilities = function (self)
PlayerUnitAbilityExtension.ability_is_equipped = function (self, ability_type)