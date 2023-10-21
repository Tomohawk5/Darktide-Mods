local mod = get_mod("blitzbar")
local InputUtils = mod:original_require("scripts/managers/input/input_utils")

local function cf(color_name)
	local color = Color[color_name](255, true)
	return string.format("{#color(%s,%s,%s)}", color[2], color[3], color[4])
end

local localizations = {
	mod_name = {
		en = "Blitz Bar",
	},
	mod_description = {
		en = "#NAME?",
	},
	show_gauge = {
		en = "Always show",
	},
	show_gauge_description = {
		en = "Show even when empty.\n\n"
			.. cf("ui_disabled_text_color") .. "Options that " .. cf("ui_hud_green_medium") .. "refill" .. cf("ui_disabled_text_color") .. " over time will always be shown."
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
		en = "Auto gauge text",
	},
	auto_text_option_description = {
		en = "Automatically sets gauge text to match what the bar is displaying.",
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
		en = "Show 1 decimal place for percentage values.\n\n"
		.. cf("ui_ogryn") .. "Ogryn{#reset()}" .. cf("ui_ogryn_text") .. " Feel no pain" .. cf("ui_disabled_text_color") .. " will appear incorrect with this off.",
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
		en = "Instead of numerical values for the " .. cf("item_rarity_2") .. "Stacks{#reset()} option when at maximum or 0 stacks.\n"
			.. "\n"
			.. cf("item_rarity_1") .. "Grenade\t{#reset()}:  " .. cf("terminal_text_header") .. "FULL{#reset()} and " .. cf("terminal_text_body") .. "EMPTY{#reset()}\n"
			.. cf("item_rarity_4") .. "Keystone\t{#reset()}:  " .. cf("ui_hud_overcharge_high") .. "MAX{#reset()} and " .. cf("ui_disabled_text_color") .. "[NOTHING]{#reset()}\n"
	},
	martyrdom = {
		en = "Zealot martyrdom"
	},
	martyrdom_description = {
		en = "Use bar to display stacks of the Zealot passive " .. cf("item_rarity_5") .. "Martyrdom{#reset()}." ..
			"\n\n" .. cf("ui_disabled_text_color") .. "Will show " .. cf("item_rarity_dark_5") .. "Stun grenade" .. cf("ui_disabled_text_color") .. " charges if not enabled."
	},
	veteran_override_replenish_text = {
		en = "Replenish time value"
	},
	veteran_override_replenish_text_description = {
		en = "Automatically change " .. cf("item_rarity_2") .. "Stacks{#reset()} value to\n"
			.. cf("item_rarity_2") .. "Time (s){#reset()} for options that " .. cf("ui_hud_green_light") .. "refill{#reset()} over time.\n"
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
		en = "Will display " .. cf("item_rarity_1") .. "Grenade{#reset()} charges over " .. cf("item_rarity_4") .. "Keystone{#reset()} charges if possible."
	},
	_show_gauge_description = {
		en = "Show the bar on this archetype."
	},
	_gauge_text = {
		en = "Gauge Text"
	},
	_gauge_text_description = {
		en = "What text should appear next to the gauge.\n"
			.. "\n"
			.. cf("ui_disabled_text_color") .. "Will have no affect if " .. cf("terminal_text_body") .. "Auto gauge text" .. cf("ui_disabled_text_color") .. " is enabled."
	},
	_gauge_value = {
		en = "Value"
	},
	_gauge_value_description = {
		en = "Value to be displayed next to the gauge. \n" ..
			"If the value would make no sense then " .. cf("ui_disabled_text_color") .. "[NOTHING]{#reset()} will be shown instead"
	},
	_gauge_value_text = {
		en = "Value text"
	},
	_gauge_value_text_description = {
		en = "Show additional text before value."
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
	localizations[color_name] = { en = cf(color_name) .. display_name(color_name) .. "{#reset()}"}
end

local archetypes = { "psyker", "veteran", "zealot", "ogryn" }
local options = { "_grenade", "_gauge_text", "_gauge_value", "_gauge_value_text", "_color_full", "_color_empty"}
for _, archetype in pairs(archetypes) do
	localizations[archetype .. "_show_gauge"] = {
		en = cf("ui_" .. archetype) .. localizations[archetype].en .. "{#reset()}"
	}
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