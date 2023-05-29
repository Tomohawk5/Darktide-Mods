local mod = get_mod("warpcharges")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local localizations = {
	mod_name = {
		en = "Warp Charges",
	},
	mod_description = {
		en = "Warp Charges description",
	},
	show_gauge = {
		en = "Always show",
	},
	show_gauge_description = {
		en = "Show at all times, not just when you have warp charges.",
	},
	gauge_orientation = {
		en = "Orientation",
	},
	orientation_option_horizontal = {
		en = "Horizontal",
	},
	orientation_option_vertical = {
		en = "Vertical",
	},
	gauge_text = {
		en = "Label"
	},
	gauge_text_description = {
		en = "What text should appear to the left / top of the gauge."
	},
	none = {
		en = ""
	},
	none_display = {
		en = ""
	},
	text_option_charges = {
		en = "charges",
	},
	text_option_souls = {
		en = "souls",
	},
	text_option_warp = {
		en = "warp",
	},
	text_option_warpcharges = {
		en = "warp charges",
	},
	text_option_grenades = {
		en = "grenades"
	},
	text_option_blitz = {
		en = "blitz"
	},
	gauge_value = {
		en = "Value"
	},
	value_option_damage = {
		en = "Damage",
	},
	value_option_damage_display = {
		en = "DMG:",
	},
	value_option_stacks = {
		en = "Stacks",
	},
	value_option_stacks_display = {
		en = "STK:",
	},
	value_option_time_percent = {
		en = "Time (%%)",
	},
	value_option_time_percent_display = {
		en = "T:",
	},
	value_option_time_seconds = {
		en = "Time",
	},
	value_option_time_seconds_display = {
		en = "T:",
	},
}

local function readable(text)
	local readable_string = ""
	local tokens = string.split(text, "_")
	for i, token in ipairs(tokens) do
		local first_letter = string.sub(token, 1, 1)
		token = string.format("%s%s", string.upper(first_letter), string.sub(token, 2))
		readable_string = string.trim(string.format("%s %s", readable_string, token))
	end
	return readable_string
end

local color_names = Color.list
for i, color_name in ipairs(color_names) do
	local color_values = Color[color_name](255, true)
	local text = InputUtils.apply_color_to_input_text(readable(color_name), color_values)
	localizations[color_name] = { en = text }
end

return localizations