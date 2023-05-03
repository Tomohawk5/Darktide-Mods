local mod = get_mod("hideprompts")

return {
	name = "hideprompts",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "ability_slot",
				type = "checkbox",
				default_value = true
			},
			{
				setting_id = "weapon_slots",
				type = "checkbox",
				default_value = true
			}
		}
	}
}
