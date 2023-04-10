return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`blessingviewer` encountered an error loading the Darktide Mod Framework.")

		new_mod("blessingviewer", {
			mod_script       = "blessingviewer/scripts/mods/blessingviewer/blessingviewer",
			mod_data         = "blessingviewer/scripts/mods/blessingviewer/blessingviewer_data",
			mod_localization = "blessingviewer/scripts/mods/blessingviewer/blessingviewer_localization",
		})
	end,
	packages = {},
}
