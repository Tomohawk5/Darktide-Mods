local mod = get_mod("warpcharges")

mod.text_options = table.enum(
	"text_option_charges",
	"text_option_souls",
	"text_option_warp",
	"text_option_warpcharges"
)
mod.value_options = table.enum(
	"value_option_damage",
	"value_option_stacks",
	"value_option_time_percent",
	"value_option_time_seconds"
)
mod.orientation_options = table.enum(
	"orientation_option_horizontal",
	"orientation_option_vertical"
)

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "show_gauge",
				type = "checkbox",
				default_value = true
			},
			{
				setting_id = "gauge_orientation",
				type = "dropdown",
				default_value = mod.orientation_options["orientation_option_horizontal"],
				options = {
					{ text = "orientation_option_horizontal", value = mod.orientation_options["orientation_option_horizontal"]	},
					{ text = "orientation_option_vertical",	  value = mod.orientation_options["orientation_option_vertical"]	},
				}
			},
			{
				setting_id = "gauge_text",
				type = "dropdown",
				default_value = mod.text_options["text_option_warpcharges"],
				options = {
					{ text = "text_option_charges",		value = mod.text_options["text_option_charges"]		},
					{ text = "text_option_souls",		value = mod.text_options["text_option_souls"]		},
					{ text = "text_option_warp",		value = mod.text_options["text_option_warp"]		},
					{ text = "text_option_warpcharges",	value = mod.text_options["text_option_warpcharges"]	},
				}
			},
			{
				setting_id = "gauge_value",
				type = "dropdown",
				default_value = mod.value_options["value_option_stacks"],
				options = {
					{ text = "value_option_damage",			value = mod.value_options["value_option_damage"]		},
					{ text = "value_option_stacks",			value = mod.value_options["value_option_stacks"]		},
					{ text = "value_option_time_percent",	value = mod.value_options["value_option_time_percent"]	},
					{ text = "value_option_time_seconds",	value = mod.value_options["value_option_time_seconds"]	},
				}
			},
			{
				setting_id = "gauge_value_text",
				type = "checkbox",
				default_value = true
			}
		}
	}
}
