local mod = get_mod("blitzbar")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local function color_format(color_name)
	local color = Color[color_name](255, true)
	return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4])
end

local localizations = {
	mod_name = {
		en = "Blitz Bar",
		["zh-cn"] = "闪击指示器",
	},
	mod_description = {
		en = "Adds a stamina style bar to show your current grenade charges, warp charges or martyrdom stacks.",
		["zh-cn"] = "添加类似体力条的状态条，显示当前的手雷数量、亚空间充能层数或殉道层数。",
	},
	show_gauge = {
		en = "Always show",
		["zh-cn"] = "总是显示",
	},
	show_gauge_description = {
		en = "Show even when empty.\n\n" .. color_format("ui_disabled_text_color") .. "Veterans with the " .. color_format("item_rarity_dark_5") .. "Demolition stockpile" .. color_format("ui_disabled_text_color") .. " talent will never have an empty bar.",
		["zh-cn"] = "即使为空也显示。\n\n" .. color_format("ui_disabled_text_color") .. "装备" .. color_format("item_rarity_dark_5") .. "爆破储备" .. color_format("ui_disabled_text_color") .. "技能的老兵状态条永远不会为空。",
	},
	gauge_orientation = {
		en = "Orientation",
		["zh-cn"] = "方向",
	},
	orientation_option_horizontal = {
		en = "Horizontal (Bottom)",
		["zh-cn"] = "水平（底部）",
	},
	orientation_option_horizontal_flipped = {
		en = "Horizontal (Top)",
		["zh-cn"] = "水平（顶部）",
	},
	orientation_option_vertical = {
		en = "Vertical (Left)",
		["zh-cn"] = "垂直（左侧）",
	},
	orientation_option_vertical_flipped = {
		en = "Vertical (Right)",
		["zh-cn"] = "垂直（右侧）",
	},
	none = {
		en = "", --color_format("ui_disabled_text_color") .. "[NOTHING]{#reset()}"
		--["zh-cn"] = "", --color_format("ui_disabled_text_color") .. "[无]{#reset()}"
	},
	none_display = {
		en = "",
	},
	text_option_charges = {
		en = "Charges",
		["zh-cn"] = "充能",
	},
	text_option_souls = {
		en = "Souls",
		["zh-cn"] = "灵魂",
	},
	text_option_warp = {
		en = "Warp",
		["zh-cn"] = "亚空间",
	},
	text_option_warpcharges = {
		en = "Warp charges",
		["zh-cn"] = "亚空间充能",
	},
	text_option_grenades = {
		en = "Grenades",
		["zh-cn"] = "手雷",
	},
	text_option_blitz = {
		en = "Blitz",
		["zh-cn"] = "闪击",
	},
	text_option_martyrdom = {
		en = "Martyrdom",
		["zh-cn"] = "殉道",
	},
	text_option_box = {
		en = "Box",
		["zh-cn"] = "爆箱",
	},
	gauge_value = {
		en = "Value",
		["zh-cn"] = "数据",
	},
	value_option_damage = {
		en = "Damage",
		["zh-cn"] = "伤害",
	},
	value_option_damage_display = {
		en = "DMG:",
		["zh-cn"] = "伤害：",
	},
	value_option_stacks = {
		en = "Stacks",
		["zh-cn"] = "数量",
	},
	value_option_stacks_display = {
		en = "STK:",
		["zh-cn"] = "数量：",
	},
	value_option_time_percent = {
		en = "Time (%%)",
		["zh-cn"] = "时间（%%）",
	},
	value_option_time_percent_display = {
		en = "T:",
		["zh-cn"] = "时间：",
	},
	value_option_time_seconds = {
		en = "Time (s)",
		["zh-cn"] = "时间（秒）",
	},
	value_option_time_seconds_display = {
		en = "T:",
		["zh-cn"] = "时间：",
	},
	gauge_color_1 = {
		en = "Value text color",
		["zh-cn"] = "数据文本颜色",
	},
	gauge_color_2 = {
		en = "Gauge color",
		["zh-cn"] = "指示器颜色",
	},
	value_time_full_empty = {
		en = "Full/Empty",
		["zh-cn"] = "满/空",
	},
	value_time_full_empty_description = {
		en = "\n" ..
			color_format("ui_hud_overcharge_high") .. "MAX{#reset()} and " .. color_format("ui_disabled_text_color") .. "[NOTHING]{#reset()} for " .. color_format("ui_psyker") .. "Psyker{#reset()} and " .. color_format("ui_zealot") .. "Zealot{#reset()}." ..
			"\n" .. color_format("terminal_text_header") .. "FULL{#reset()} and " .. color_format("terminal_text_body") .. "EMPTY{#reset()} for " .. color_format("ui_veteran") .. "Veteran{#reset()} and " .. color_format("ui_ogryn") .. "Ogryn{#reset()}." ..
			"\n\nInstead of numerical values for the " .. color_format("item_rarity_2") .. "Stacks{#reset()} option when at maximum or 0 stacks.",
		["zh-cn"] = "\n" ..
			color_format("ui_psyker") .. "灵能者{#reset()}与" .. color_format("ui_zealot") .. "狂信徒{#reset()}显示 " .. color_format("ui_hud_overcharge_high") .. "最大{#reset()} 和 " .. color_format("ui_disabled_text_color") .. "[无]{#reset()}。" ..
			"\n" .. color_format("ui_veteran") .. "老兵{#reset()}与" .. color_format("ui_ogryn") .. "欧格林{#reset()}显示 " .. color_format("terminal_text_header") .. "满{#reset()} 和 " .. color_format("terminal_text_body") .. "空{#reset()}。" ..
			"\n\n在数据为最大或零时，显示文本而非具体" .. color_format("item_rarity_2") .. "数量{#reset()}。",
	},
	martyrdom = {
		en = "Zealot martyrdom",
		["zh-cn"] = "狂信徒殉道",
	},
	martyrdom_description = {
		en = "Use bar to display stacks of the Zealot passive " .. color_format("item_rarity_5") .. "Martyrdom{#reset()}." ..
			"\n\n" .. color_format("ui_disabled_text_color") .. "Will show " .. color_format("item_rarity_dark_5") .. "Stun grenade" .. color_format("ui_disabled_text_color") .. " charges if not enabled.",
		["zh-cn"] = "使用状态条显示狂信徒被动技能" .. color_format("item_rarity_5") .. "殉道{#reset()}的层数。" ..
			"\n\n" .. color_format("ui_disabled_text_color") .. "如果禁用则显示" .. color_format("item_rarity_dark_5") .. "眩晕手雷" .. color_format("ui_disabled_text_color") .. "的数量。",
	},
	veteran_override_replenish_text = {
		en = "Veteran replenish value",
		["zh-cn"] = "老兵手雷恢复",
	},
	veteran_override_replenish_text_description = {
		en = "Change Veteran " .. color_format("item_rarity_2") .. "Stacks{#reset()} value to " .. color_format("item_rarity_2") .. "Time (s){#reset()} " ..
			"if " .. color_format("item_rarity_5") .. "Demolition stockpile{#reset()} is selected.",
		["zh-cn"] = "如果装备" .. color_format("item_rarity_5") .. "爆破储备{#reset()}技能，则将老兵的手雷" ..
			color_format("item_rarity_2") .. "数量{#reset()}改为手雷恢复" .. color_format("item_rarity_2") .. "时间（秒）{#reset()}。",
	},
	archetype_options = {
		en = "Archetypes",
		["zh-cn"] = "职业类型",
	},
	psyker = {
		en = "Psyker",
		["zh-cn"] = "灵能者",
	},
	veteran = {
		en = "Veteran",
		["zh-cn"] = "老兵",
	},
	zealot = {
		en = "Zealot",
		["zh-cn"] = "狂信徒",
	},
	ogryn = {
		en = "Ogryn",
		["zh-cn"] = "欧格林",
	},
	_show_gauge_description = {
		en = "Show the bar on this archetype.",
		["zh-cn"] = "在此职业下显示状态条。",
	},
	_gauge_text = {
		en = "Gauge Text",
		["zh-cn"] = "指示器文本",
	},
	_gauge_text_description = {
		en = "What text should appear next to the gauge.",
		["zh-cn"] = "指示器旁边应该显示什么文本。",
	},
	_gauge_value = {
		en = "Value",
		["zh-cn"] = "数据",
	},
	_gauge_value_description = {
		en = "Value to be displayed next to the gauge. \n" ..
			"If the value would make no sense then " .. color_format("ui_disabled_text_color") .. "[NOTHING]{#reset()} will be shown instead.",
		["zh-cn"] = "指示器旁边显示的数据。\n" ..
			"如果选择的数据没有意义，则" .. color_format("ui_disabled_text_color") .. "[无]{#reset()}显示。",
	},
	_gauge_value_text = {
		en = "Value text",
		["zh-cn"] = "数据文本",
	},
	_gauge_value_text_description = {
		en = "Label text of the value.",
		["zh-cn"] = "数据的标签文本。",
	},
	_color_full = {
		en = "Full color",
		["zh-cn"] = "满时颜色",
	},
	_color_full_description = {
		en = "Color of each bar when full.",
		["zh-cn"] = "状态条满时的颜色。",
	},
	_color_empty = {
		en = "Empty color",
		["zh-cn"] = "空时颜色",
	},
	_color_empty_description = {
		en = "Color of each bar when empty.\n" ..
			"Transparent at a value of 0.",
		["zh-cn"] = "状态条空时的颜色。\n" ..
			"数据为 0 时则透明。",
	},
	full = {
		en = "FULL",
		["zh-cn"] = "满",
	},
	max = {
		en = "MAX",
		["zh-cn"] = "最大",
	},
	empty = {
		en = "EMPTY",
		["zh-cn"] = "空",
	}
}

local function display_name(text)
	local display_text = ""
	local words = string.split(text, "_")
	for _, word in ipairs(words) do
		word = (word:gsub("^%l", string.upper)) -- Parenthesis [https://www.luafaq.org/gotchas.html#T8.1]
		display_text = display_text .. " " .. word
	end
	return display_text
end

local color_names = Color.list
for _, color_name in ipairs(color_names) do
	localizations[color_name] = { en = color_format(color_name) .. display_name(color_name) .. "{#reset()}"}
end

local archetypes = { "psyker", "veteran", "zealot", "ogryn" }
local options = { "_gauge_text", "_gauge_value", "_gauge_value_text", "_color_full", "_color_empty"}
for _, archetype in pairs(archetypes) do
	--localizations[archetype .. "_show_gauge_description"] = localizations["_show_gauge_description"]
	localizations[archetype .. "_show_gauge"] = {
		en = color_format("ui_" .. archetype) .. localizations[archetype].en .. "{#reset()}",
		["zh-cn"] = color_format("ui_" .. archetype) .. localizations[archetype]["zh-cn"] .. "{#reset()}",
	}
	for _, option in pairs(options) do
		localizations[archetype .. option] = table.clone(localizations[option])
		localizations[archetype .. option .. "_description"] = table.clone(localizations[option .. "_description"])
		for language, _ in pairs(localizations[archetype .. option]) do
			localizations[archetype .. option][language] = color_format("ui_" .. archetype .. "_text") .. localizations[archetype .. option][language] .. "{#reset()}"
			localizations[archetype .. option .. "_description"][language] = localizations[archetype .. option .. "_description"][language]
		end
	end
end

return localizations
