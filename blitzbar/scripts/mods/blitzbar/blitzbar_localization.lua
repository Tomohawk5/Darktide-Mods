local mod = get_mod("blitzbar")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local function color_format(color_name)
	local color = Color[color_name](255, true)
	return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4])
end

local localizations = {
	mod_name = {
		en = "Blitz Bar",
	},
	mod_description = {
		en = "Blitz Bar description.",
	},
	show_gauge = {
		en = "Always show",
	},
	show_gauge_description = {
		en = "Show even when empty.\n\n" .. color_format("ui_disabled_text_color") .. "Veterans with the " .. color_format("item_rarity_dark_5") .. "Demolition stockpile" .. color_format("ui_disabled_text_color") .. " talent will never have an empty bar.",
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
	auto_text_option = {
		en = "Auto Gauge Text",
	},
	auto_text_option_description = {
		en = "Automatically sets gauge text to match what the bar is displaying.",
	},

	-- ##############################
	-- #        TEXT_OPTIONS        #
	-- ##############################
	none = {
		en = "", --color_format("ui_disabled_text_color") .. "[NOTHING]{#reset()}"
	},
	none_display = {
		en = "",
	},
	text_option_blitz = {
		en = "Blitz"
	},
	text_option_charges = {
		en = "Charges",
	},
	text_option_grenades = {
		en = "Grenades"
	},

	-- ##############################
	-- #           PSYKER           #
	-- ##############################
	text_option_assail = {
		en = "Assail"
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
	text_option_psionics = {
		en = "Psionics"
	},
	text_option_destiny = {
		en = "Destiny"
	},
	text_option_marks = {
		en = "Marks"
	},

	-- ##############################
	-- #           ZEALOT           #
	-- ##############################
	text_option_martyrdom = {
		en = "Martyrdom"
	},
	text_option_knife = {
		en = "Knife"
	},
	text_option_piety = {
		en = "Piety"
	},
	text_option_inexorable = {
		en = "Inexorable"
	},
	text_option_stun = {
		en = "Stun"
	},
	text_option_flame = {
		en = "Flame"
	},

	-- ##############################
	-- #          VETERAN           #
	-- ##############################
	text_option_frag = {
		en = "Frag"
	},
	text_option_krak = {
		en = "Krak"
	},
	text_option_smoke = {
		en = "Smoke"
	},

	-- ##############################
	-- #           OGRYN           #
	-- ##############################
	text_option_box = {
		en = "Box"
	},
	text_option_armour = {
		en = "Armour"
	},
	text_option_nuke = {
		en = "Nuke"
	},
	text_option_rock = {
		en = "Rock"
	},

	-- ##############################
	-- #           VALUE            #
	-- ##############################
	value_decimals = {
		en = "Decimals",
	},
	value_decimals_description = {
		en = "Show 1 decimal place for percentage values." ..
		"\n" .. color_format("ui_ogryn") .. "Ogryn{#reset()} Feel No Pain stacks will appear incorrect with this off.",
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
	value_time_full_empty = {
		en = "Full/Empty"
	},
	value_time_full_empty_description = {
		en = "\n" ..
			color_format("ui_hud_overcharge_high") .. "MAX{#reset()} and " .. color_format("ui_disabled_text_color") .. "[NOTHING]{#reset()} for " .. color_format("ui_psyker") .. "Psyker{#reset()} and " .. color_format("ui_zealot") .. "Zealot{#reset()}." ..
			"\n" .. color_format("terminal_text_header") .. "FULL{#reset()} and " .. color_format("terminal_text_body") .. "EMPTY{#reset()} for " .. color_format("ui_veteran") .. "Veteran{#reset()} and " .. color_format("ui_ogryn") .. "Ogryn{#reset()}." ..
			"\n\nInstead of numerical values for the " .. color_format("item_rarity_2") .. "Stacks{#reset()} option when at maximum or 0 stacks."
	},
	martyrdom = {
		en = "Zealot martyrdom"
	},
	martyrdom_description = {
		en = "Use bar to display stacks of the Zealot passive " .. color_format("item_rarity_5") .. "Martyrdom{#reset()}." ..
			"\n\n" .. color_format("ui_disabled_text_color") .. "Will show " .. color_format("item_rarity_dark_5") .. "Stun grenade" .. color_format("ui_disabled_text_color") .. " charges if not enabled."
	},
	veteran_override_replenish_text = {
		en = "Veteran replenish value"
	},
	veteran_override_replenish_text_description = {
		en = "Change Veteran " .. color_format("item_rarity_2") .. "Stacks{#reset()} value to " .. color_format("item_rarity_2") .. "Time (s){#reset()} " ..
			"if " .. color_format("item_rarity_5") .. "Demolition stockpile{#reset()} is selected."
	},
	archetype_options = {
		en = "Archetypes"
	},
	psyker = {
		en = "Psyker"
	},
	veteran = {
		en = "Veteran"
	},
	zealot = {
		en = "Zealot"
	},
	ogryn = {
		en = "Ogryn"
	},
	_grenade = {
		en = "Prefer Grenade"
	},
	_grenade_description = {
		en = "Will display grenade charges over keystone charges if possible."
	},
	_show_gauge_description = {
		en = "Show the bar on this archetype."
	},
	_gauge_text = {
		en = "Gauge Text"
	},
	_gauge_text_description = {
		en = "What text should appear next to the gauge."
	},
	_gauge_value = {
		en = "Value"
	},
	_gauge_value_description = {
		en = "Value to be displayed next to the gauge. \n" ..
			"If the value would make no sense then " .. color_format("ui_disabled_text_color") .. "[NOTHING]{#reset()} will be shown instead"
	},
	_gauge_value_text = {
		en = "Value text"
	},
	_gauge_value_text_description = {
		en = "Value text description"
	},
	_color_full = {
		en = "Full color"
	},
	_color_full_description = {
		en = "Color of each bar when full."
	},
	_color_empty = {
		en = "Empty color"
	},
	_color_empty_description = {
		en = "Color of each bar when empty.\n" ..
			"Transparent at a value of 0."
	},
	full = {
		en = "FULL"
	},
	max = {
		en = "MAX"
	},
	empty = {
		en = "EMPTY"
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
local options = { "_grenade", "_gauge_text", "_gauge_value", "_gauge_value_text", "_color_full", "_color_empty"}
for _, archetype in pairs(archetypes) do
	localizations[archetype .. "_show_gauge"] = {
		en = color_format("ui_" .. archetype) .. localizations[archetype].en .. "{#reset()}"
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