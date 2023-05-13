return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`warpcharges` encountered an error loading the Darktide Mod Framework.")

		new_mod("warpcharges", {
			mod_script       = "warpcharges/scripts/mods/warpcharges/warpcharges",
			mod_data         = "warpcharges/scripts/mods/warpcharges/warpcharges_data",
			mod_localization = "warpcharges/scripts/mods/warpcharges/warpcharges_localization",
		})
	end,
	packages = {},
}
