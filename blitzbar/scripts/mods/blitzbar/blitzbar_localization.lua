local mod = get_mod("blitzbar")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local function cf(color_name)
	local color = Color[color_name](255, true)
	return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4])
end

local localizations = {
	mod_name = {
		en = "Blitz Bar",
		["zh-cn"] = "闪击指示器",
	},
	mod_description = {
		en = "Adds a stamina style bar to show your current grenade or keystone charges.",
		["zh-cn"] = "添加类似体力条的状态条，显示当前的手雷数量或楔石层数。",
	},
	show_gauge = {
		en = "Always show",
		["zh-cn"] = "总是显示",
	},
	show_gauge_description = {
		en = "Show even when empty.\n\n"
			.. cf("ui_disabled_text_color") .. "Options that " .. cf("ui_hud_green_medium") .. "refill" .. cf("ui_disabled_text_color") .. " over time will always be shown.",
		["zh-cn"] = "即使为空也显示。\n\n"
			.. cf("ui_disabled_text_color") .. "随时间" .. cf("ui_hud_green_medium") .. "补充" .. cf("ui_disabled_text_color") .. "的选项将会始终显示。",
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
	auto_text_option = {
		en = "Auto gauge text",
		["zh-cn"] = "自动指示器文本",
	},
	auto_text_option_description = {
		en = "Automatically sets gauge text to match what the bar is displaying.",
		["zh-cn"] = "自动设置指示器文本，以匹配当前显示的状态条。",
	},

	-- ##############################
	-- #        TEXT_OPTIONS        #
	-- ##############################
	none = {
		en = "",
	},
	none_display = {
		en = "",
	},
	text_option_blitz = {
		en = "Blitz",
		["zh-cn"] = "闪击",
	},
	text_option_charges = {
		en = "Charges",
		["zh-cn"] = "充能",
	},
	text_option_grenades = {
		en = "Grenades",
		["zh-cn"] = "手雷",
	},

	-- ##############################
	-- #           PSYKER           #
	-- ##############################
	text_option_assail = {
		en = "Assail",
		["zh-cn"] = "灵能飞刀",
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
	text_option_psionics = {
		en = "Psionics",
		["zh-cn"] = "灵能强化",
	},
	text_option_destiny = {
		en = "Destiny",
		["zh-cn"] = "颠覆命运",
	},
	text_option_marks = {
		en = "Marks",
		["zh-cn"] = "标记",
	},

	-- ##############################
	-- #           ZEALOT           #
	-- ##############################
	text_option_martyrdom = {
		en = "Martyrdom",
		["zh-cn"] = "殉道",
	},
	text_option_knife = {
		en = "Knife",
		["zh-cn"] = "小刀",
	},
	text_option_piety = {
		en = "Piety",
		["zh-cn"] = "炽热虔诚",
	},
	text_option_inexorable = {
		en = "Inexorable",
		["zh-cn"] = "无情审判",
	},
	text_option_stun = {
		en = "Stun",
		["zh-cn"] = "眩晕",
	},
	text_option_flame = {
		en = "Flame",
		["zh-cn"] = "燃烧",
	},

	-- ##############################
	-- #          VETERAN           #
	-- ##############################
	text_option_frag = {
		en = "Frag",
		["zh-cn"] = "破片",
	},
	text_option_krak = {
		en = "Krak",
		["zh-cn"] = "穿甲",
	},
	text_option_smoke = {
		en = "Smoke",
		["zh-cn"] = "烟雾",
	},

	-- ##############################
	-- #           OGRYN           #
	-- ##############################
	text_option_box = {
		en = "Box",
		["zh-cn"] = "手雷箱",
	},
	text_option_armour = {
		en = "Armour",
		["zh-cn"] = "麻木",
	},
	text_option_nuke = {
		en = "Nuke",
		["zh-cn"] = "核弹",
	},
	text_option_rock = {
		en = "Rock",
		["zh-cn"] = "巨石",
	},

	-- ##############################
	-- #           VALUE            #
	-- ##############################
	value_decimals = {
		en = "Decimals",
		["zh-cn"] = "小数",
	},
	value_decimals_description = {
		en = "Show 1 decimal place for percentage values.\n\n"
		.. cf("ui_ogryn") .. "Ogryn{#reset()}" .. cf("ui_ogryn_text") .. " Feel no pain" .. cf("ui_disabled_text_color") .. " will appear incorrect with this off.",
		["zh-cn"] = "百分比数据显示 1 位小数。\n\n"
		.. "如果禁用，" .. cf("ui_ogryn") .. "欧格林{#reset()}的" .. cf("ui_ogryn_text") .. "麻木" .. cf("ui_disabled_text_color") .. "就无法正确显示。",
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
		en = "Instead of numerical values for the " .. cf("item_rarity_2") .. "Stacks{#reset()} option when at maximum or 0 stacks.\n"
			.. "\n"
			.. cf("item_rarity_1") .. "Grenade\t{#reset()}:  " .. cf("terminal_text_header") .. "FULL{#reset()} and " .. cf("terminal_text_body") .. "EMPTY{#reset()}\n"
			.. cf("item_rarity_4") .. "Keystone\t{#reset()}:  " .. cf("ui_hud_overcharge_high") .. "MAX{#reset()} and " .. cf("ui_disabled_text_color") .. "[NOTHING]{#reset()}\n",
		["zh-cn"] = "在" .. cf("item_rarity_2") .. "数量{#reset()}选项为最大值或 0 时，不显示数字。\n"
			.. "\n"
			.. cf("item_rarity_1") .. "手雷\t{#reset()}：" .. cf("terminal_text_header") .. "满{#reset()}和" .. cf("terminal_text_body") .. "空{#reset()}\n"
			.. cf("item_rarity_4") .. "楔石\t{#reset()}：" .. cf("ui_hud_overcharge_high") .. "最大{#reset()}和" .. cf("ui_disabled_text_color") .. "[无]{#reset()}\n",
	},
	martyrdom = {
		en = "Zealot martyrdom",
		["zh-cn"] = "狂信徒殉道",
	},
	martyrdom_description = {
		en = "Use bar to display stacks of the Zealot passive " .. cf("item_rarity_5") .. "Martyrdom{#reset()}." ..
			"\n\n" .. cf("ui_disabled_text_color") .. "Will show " .. cf("item_rarity_dark_5") .. "Stun Grenade" .. cf("ui_disabled_text_color") .. " charges if not enabled.",
		["zh-cn"] = "使用状态条显示狂信徒被动技能" .. cf("item_rarity_5") .. "殉道{#reset()}的层数。" ..
			"\n\n" .. cf("ui_disabled_text_color") .. "如果禁用则显示" .. cf("item_rarity_dark_5") .. "眩晕手雷" .. cf("ui_disabled_text_color") .. "的数量。",
	},
	veteran_override_replenish_text = {
		en = "Replenish time value",
		["zh-cn"] = "补充时间数据",
	},
	veteran_override_replenish_text_description = {
		en = "Automatically change " .. cf("item_rarity_2") .. "Stacks{#reset()} value to\n"
			.. cf("item_rarity_2") .. "Time (s){#reset()} for options that " .. cf("ui_hud_green_light") .. "refill{#reset()} over time.\n",
		["zh-cn"] = "对于随时间" .. cf("ui_hud_green_light") .. "补充{#reset()}的选项，\n"
			.. "自动将" .. cf("item_rarity_2") ..  "数量{#reset()}数据修改为" .. cf("item_rarity_2") .. "时间（秒）{#reset()}。\n",
	},
	archetype_options = {
		en = "Archetypes",
		["zh-cn"] = "职业",
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
	_grenade = {
		en = "Prefer Grenade",
		["zh-cn"] = "优先手雷",
	},
	_grenade_description = {
		en = "Will display " .. cf("item_rarity_1") .. "Grenade{#reset()} charges over " .. cf("item_rarity_4") .. "Keystone{#reset()} charges if possible.",
		["zh-cn"] = "如果可能，则优先显示" .. cf("item_rarity_1") .. "手雷{#reset()}而非" .. cf("item_rarity_4") .. "楔石{#reset()}充能。",
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
		en = "What text should appear next to the gauge.\n"
			.. "\n"
			.. cf("ui_disabled_text_color") .. "Will have no affect if " .. cf("terminal_text_body") .. "Auto gauge text" .. cf("ui_disabled_text_color") .. " is enabled.",
		["zh-cn"] = "指示器旁边应该显示什么文本。\n"
			.. "\n"
			.. cf("ui_disabled_text_color") .. "如果启用" .. cf("terminal_text_body") .. "自动指示器文本" .. cf("ui_disabled_text_color") .. "则无效果。",
	},
	_gauge_value = {
		en = "Value",
		["zh-cn"] = "数据",
	},
	_gauge_value_description = {
		en = "Value to be displayed next to the gauge. \n" ..
			"If the value would make no sense then " .. cf("ui_disabled_text_color") .. "[NOTHING]{#reset()} will be shown instead",
		["zh-cn"] = "指示器旁边显示的数据。\n" ..
			"如果选择的数据没有意义，则" .. cf("ui_disabled_text_color") .. "[无]{#reset()}显示。",
	},
	_gauge_value_text = {
		en = "Value text",
		["zh-cn"] = "数据文本",
	},
	_gauge_value_text_description = {
		en = "Show additional text before value.",
		["zh-cn"] = "在数据前显示的附加文本。",
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
	localizations[color_name] = { en = cf(color_name) .. display_name(color_name) .. "{#reset()}"}
end

local archetypes = { "psyker", "veteran", "zealot", "ogryn" }
local options = { "_grenade", "_gauge_text", "_gauge_value", "_gauge_value_text", "_color_full", "_color_empty"}
for _, archetype in pairs(archetypes) do
	localizations[archetype .. "_show_gauge"] = {
		en = cf("ui_" .. archetype) .. localizations[archetype].en .. "{#reset()}"
    }
	for language, _ in pairs(localizations[archetype]) do
		localizations[archetype .. "_show_gauge"][language] = cf("ui_" .. archetype) .. localizations[archetype][language] .. "{#reset()}"
	end
	for _, option in pairs(options) do
		localizations[archetype .. option] = table.clone(localizations[option])
		localizations[archetype .. option .. "_description"] = table.clone(localizations[option .. "_description"])
		for language, _ in pairs(localizations[archetype .. option]) do
			localizations[archetype .. option][language] = cf("ui_" .. archetype .. "_text") .. localizations[archetype .. option][language] .. "{#reset()}"
			localizations[archetype .. option .. "_description"][language] = localizations[archetype .. option .. "_description"][language]
		end
	end
end

return localizations
