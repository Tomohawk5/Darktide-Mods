local mod = get_mod("hideprompts")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "ability_slot",
				type = "checkbox",
				default_value = false
			},
			{
				setting_id = "weapon_slots",
				type = "checkbox",
				default_value = false
			}
		}
	}
}
