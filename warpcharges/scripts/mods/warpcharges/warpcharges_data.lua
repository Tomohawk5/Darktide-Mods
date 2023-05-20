local mod = get_mod("warpcharges")

mod.text_options = table.enum(
	"none",
	"text_option_charges",
	"text_option_souls",
	"text_option_warp",
	"text_option_warpcharges"
)
mod.value_options = table.enum(
	"none",
	"value_option_damage",
	"value_option_stacks",
	"value_option_time_percent",
	"value_option_time_seconds"
)
mod.orientation_options = table.enum(
	"orientation_option_horizontal",
	"orientation_option_vertical"
)

local colors = {}

for _, color_name in ipairs(Color.list) do
	table.insert(colors, { text = color_name, value = color_name })
end

table.sort(colors, function(a, b)
	return a.text < b.text
end)

local function get_colors()
	return table.clone(colors)
end

local function color_archetype(archetype)
	local widget = {
		setting_id = "color_" .. archetype,
		type = "checkbox",
		default_value = true,
		sub_widgets = {
			{
				setting_id = "color_" .. archetype .. "_full",
				type = "dropdown",
				default_value = "ui_" .. archetype,
				options = get_colors() --color_dropdown()
			},
			{
				setting_id = "color_" .. archetype .. "_empty",
				type = "dropdown",
				default_value = "ui_" .. archetype .. "_text",
				options = get_colors() --color_dropdown()
			}
		}
	}
	return widget
end

local function color_options()
	local archetypes = { "psyker", "veteran", "zealot", "ogryn" }
	local sub_widgets = {}
	for _, archetype in pairs(archetypes) do
		table.insert(sub_widgets, color_archetype(archetype))
	end
	return sub_widgets
end 

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "gauge",
				type = "group",
				sub_widgets = {
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
							{ text = "none",					value = mod.text_options["none"]					},
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
							{ text = "none",						value = mod.value_options["none"]						},
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
			},
			{
				setting_id = "psyker_only",
				type = "checkbox",
				default_value = false
			},
			{
				setting_id = "color_options",
				type = "group",
				sub_widgets = color_options()
			}
			-- {
			-- 	setting_id = "color_options",
			-- 	type = "group",
			-- 	sub_widgets = {
			-- 		{
			-- 			setting_id = "color_psyker",
			-- 			type = "checkbox",
			-- 			default_value = false,
			-- 			sub_widgets = {
			-- 				{
			-- 					setting_id = "color_psyker_full",
			-- 					type = "dropdown",
			-- 					default_value = "red",
			-- 					options = color_dropdown()
			-- 				},
			-- 				{
			-- 					setting_id = "color_psyker_empty",
			-- 					type = "dropdown",
			-- 					default_value = "red",
			-- 					options = color_dropdown()
			-- 				}
			-- 			}
			-- 		}
			-- 	}
			-- }
		}
	}
}