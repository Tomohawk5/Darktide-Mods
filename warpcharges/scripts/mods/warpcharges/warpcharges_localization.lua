local mod = get_mod("warpcharges")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local localizations = {
	mod_name = {
		en = "Blitz Bar",
	},
	mod_description = {
		en = "Blitz Bar description",
	},
	show_gauge = {
		en = "Always show",
	},
	show_gauge_description = {
		en = "Show even when empty.",
	},
	gauge_orientation = {
		en = "Orientation",
	},
	orientation_option_horizontal = {
		en = "Horizontal (Bottom)",
	},
	orientation_option_horizontal_flipped = {
		en = "Horizontal (Top)",
	},
	orientation_option_vertical = {
		en = "Vertical (Left)",
	},
	orientation_option_vertical_flipped = {
		en = "Vertical (Right)",
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
		en = "Charges",
	},
	text_option_souls = {
		en = "Souls",
	},
	text_option_warp = {
		en = "Warp",
	},
	text_option_warpcharges = {
		en = "Warp charges",
	},
	text_option_grenades = {
		en = "Grenades"
	},
	text_option_blitz = {
		en = "Blitz"
	},
	text_option_martyrdom = {
		en = "Martyrdom"
	},
	text_option_box = {
		en = "Box"
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
		en = "Time (s)",
	},
	value_option_time_seconds_display = {
		en = "T:",
	},
	gauge_color_1 = {
		en = "Value text color"
	},
	gauge_color_2 = {
		en = "Gauge color"
	},
	martyrdom = {
		en = "Zealot martyrdom"
	},
	martyrdom_description = {
		en = "Use bar to display stacks of Zealot passive."
	},
	veteran_override_replenish_text = {
		en = "Veteran replenish value"
	},
	veteran_override_replenish_text_description = {
		en = "Change Veteran value to 'Time (s)' if '{#color(255, 180, 0)}Demolition stockpile{#reset()}' is selected."
	},
	archetype_options = {
		en = "Archetypes"
	},
	psyker = {
		en = "PSYKER"
	},
	veteran = {
		en = "VETERAN"
	},
	zealot = {
		en = "ZEALOT"
	},
	ogryn = {
		en = "OGRYN"
	}
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

local archetypes = { "psyker", "veteran", "zealot", "ogryn" }
local colors = {
	psyker = "{#color(59, 102, 150)}",
	veteran = "{#color(100, 172, 28)}",
	zealot = "{#color(204, 26, 28)}",
	ogryn = "{#color(188, 138, 67)}"
}
for _, archetype in pairs(archetypes) do
	localizations[archetype .. "_show_gauge"] = {
		en = colors[archetype] .. localizations[archetype].en .. "{#reset()}" --TODO: fix this
	}
	localizations[archetype .. "_gauge_text"] = {
		en = "Gauge Text"
	}
	localizations[archetype .. "_gauge_value"] = {
		en = "Value"
	}
	localizations[archetype .. "_gauge_value_text"] = {
		en = "Value text"
	}
	localizations[archetype .. "_color_full"] = {
		en = "Full color"
	}
	localizations[archetype .. "_color_empty"] = {
		en = "Empty color"
	}
end

return localizations