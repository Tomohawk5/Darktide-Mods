local mod = get_mod("warpcharges")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")

mod.text_options = table.enum(
	"none",
	"text_option_charges",
	"text_option_souls",
	"text_option_warp",
	"text_option_warpcharges",
	"text_option_grenades",
	"text_option_blitz",
	"text_option_martyrdom"
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

local function list_options(enum)
	local options = {}
	for k, v in pairs(enum) do
		table.insert(options, { text = k, value = v })
	end
	return options
end

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

local function archetype_options()
	local archetypes = { "psyker", "veteran", "zealot", "ogryn" }
	local defaults = {
		psyker = {
			text = mod.text_options["text_option_warpcharges"],
			text_options = table.enum(
				mod.text_options["none"],
				mod.text_options["text_option_warp"],
				mod.text_options["text_option_warpcharges"],
				mod.text_options["text_option_souls"],
				mod.text_options["text_option_charges"],
				mod.text_options["text_option_blitz"]
			),
			value = mod.value_options["value_option_time_percent"],
			value_options = mod.value_options
		},
		veteran = {
			text = mod.text_options["text_option_grenades"],
			text_options = table.enum(
				mod.text_options["none"],
				mod.text_options["text_option_grenades"],
				mod.text_options["text_option_charges"],
				mod.text_options["text_option_blitz"]
			),
			value = mod.value_options["value_option_stacks"],
			value_options = table.enum(
				mod.value_options["none"],
				mod.value_options["value_option_stacks"],
				mod.value_options["value_option_time_seconds"],
				mod.value_options["value_option_time_percent"]
			)
		},
		zealot = {
			text = mod.text_options["text_option_martyrdom"],
			text_options = table.enum(
				mod.text_options["none"],
				mod.text_options["text_option_martyrdom"],
				mod.text_options["text_option_charges"],
				mod.text_options["text_option_blitz"]
			),
			value = mod.value_options["value_option_damage"],
			value_options = table.enum(
				mod.value_options["none"],
				mod.value_options["value_option_damage"],
				mod.value_options["value_option_stacks"]
			)
		},
		ogryn = {
			text = mod.text_options["text_option_grenades"],
			text_options = table.enum(
				mod.text_options["none"],
				mod.text_options["text_option_grenades"],
				mod.text_options["text_option_charges"],
				mod.text_options["text_option_blitz"]
			),
			value = mod.value_options["value_option_stacks"],
			value_options = table.enum(
				mod.value_options["none"],
				mod.value_options["value_option_stacks"]
			)
		}
	}
	local archetype_widgets = {}
	for _, archetype in pairs(archetypes) do
		local default = defaults[archetype]
		mod:dump(default, ("default:" .. archetype), 4)
		local widget = {
			setting_id = archetype .. "_show_gauge",
			type = "checkbox",
			default_value = true,
			sub_widgets = {
				{
					setting_id = archetype .. "_gauge_text",
					type = "dropdown",
					default_value = default.text, --default_text[archetype], --mod.text_options["text_option_warpcharges"],
					options = list_options(default.text_options) --list_options(mod.text_options)
				},
				{
					setting_id = archetype .. "_gauge_value",
					type = "dropdown",
					default_value = default.value, --default_value[archetype], --mod.value_options["value_option_stacks"],
					options = list_options(default.value_options) --list_options(mod.value_options)
				},
				{
					setting_id = archetype .. "_gauge_value_text",
					type = "checkbox",
					default_value = false
				},
				{
					setting_id = archetype .. "_color_full",
					type = "dropdown",
					default_value = "ui_" .. archetype,
					options = get_colors()
				},
				{
					setting_id = archetype .. "_color_empty",
					type = "dropdown",
					default_value = "ui_" .. archetype .. "_text",
					options = get_colors()
				}
			}
		}
		table.insert(archetype_widgets, widget)
	end
	return archetype_widgets
end

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "gauge_orientation",
				type = "dropdown",
				default_value = mod.orientation_options["orientation_option_vertical"],
				options = list_options(mod.orientation_options)
			},
			{
				setting_id = "gauge_color_1",
				type = "dropdown",
				default_value = "terminal_text_header",
				options = get_colors()
			},
			{
				setting_id = "gauge_color_2",
				type = "dropdown",
				default_value = "terminal_text_body",
				options = get_colors()
			},
			{
				setting_id = "show_gauge",
				type = "checkbox",
				default_value = true
			},
			{
				setting_id = "value_time_full_empty",
				type = "checkbox",
				default_value = false
			},
			{
				setting_id = "martyrdom",
				type = "checkbox",
				default_value = true
			},
			{
				setting_id = "veteran_override_replenish_text",
				type = "checkbox",
				default_value = false
			},
			{
				setting_id = "archetype_options",
				type = "group",
				sub_widgets = archetype_options()
			}
		}
	}
}