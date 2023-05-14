local mod = get_mod("warpcharges")

local HudElementWarpCharges =mod:io_dofile("warpcharges/scripts/mods/warpcharges/UI/UI_settings")
local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIHudSettings = mod:original_require("scripts/settings/ui/ui_hud_settings")
local UIFontSettings = mod:original_require("scripts/managers/ui/ui_font_settings")
local bar_size = HudElementWarpCharges.bar_size
local area_size = HudElementWarpCharges.area_size
local glow_size = HudElementWarpCharges.glow_size
local center_offset = HudElementWarpCharges.center_offset
local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	area = {
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "center",
		size = area_size,
		position = {
			0,
			center_offset,
			0
		}
	},
	gauge = {
		vertical_alignment = "top",
		parent = "area",
		horizontal_alignment = "center",
		size = {
			212,
			10
		},
		position = {
			0,
			6,
			1
		}
	},
	shield = {
		vertical_alignment = "top",
		parent = "area",
		horizontal_alignment = "center",
		size = bar_size,
		position = {
			0,
			0,
			1
		}
	}
}
local value_text_style = table.clone(UIFontSettings.body_small)
value_text_style.offset = {
	0,
	10,
	3
}
value_text_style.size = {
	500,
	30
}
value_text_style.vertical_alignment = "top"
value_text_style.horizontal_alignment = "right"
value_text_style.text_horizontal_alignment = "right"
value_text_style.text_vertical_alignment = "top"
value_text_style.text_color = UIHudSettings.color_tint_main_1
local name_text_style = table.clone(value_text_style)
name_text_style.offset = {
	0,
	10,
	3
}
name_text_style.horizontal_alignment = "left"
name_text_style.text_horizontal_alignment = "left"
name_text_style.text_color = UIHudSettings.color_tint_main_2
name_text_style.drop_shadow = false
local widget_definitions = {
	gauge = UIWidget.create_definition({
		{
			value_id = "value_text",
			style_id = "value_text",
			pass_type = "text",
			value = Utf8.upper(Localize("loc_hud_display_overheat_death_danger")),
			style = value_text_style
		},
		{
			value_id = "name_text",
			style_id = "name_text",
			pass_type = "text",
			--value = Utf8.upper(Localize("loc_hud_display_name_stamina")),
			value = Utf8.upper("warp charges"),
			style = name_text_style
		},
		{
			value = "content/ui/materials/hud/stamina_gauge",
			style_id = "warning",
			pass_type = "texture",
			style = {
				vertical_alignment = "center",
				horizontal_alignment = "center",
				offset = {
					0,
					0,
					1
				},
				color = UIHudSettings.color_tint_main_2
			}
		}
	}, "gauge")
}
local shield = UIWidget.create_definition({
	{
		value = "content/ui/materials/hud/stamina_full",
		style_id = "full",
		pass_type = "rect",
		style = {
			offset = {
				0,
				0,
				3
			},
			color = UIHudSettings.color_tint_main_1
		}
	}
}, "shield")

return {
	shield_definition = shield,
	widget_definitions = widget_definitions,
	scenegraph_definition = scenegraph_definition
}
