return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`blitzbar` encountered an error loading the Darktide Mod Framework.")

		new_mod("blitzbar", {
			mod_script       = "blitzbar/scripts/mods/blitzbar/blitzbar",
			mod_data         = "blitzbar/scripts/mods/blitzbar/blitzbar_data",
			mod_localization = "blitzbar/scripts/mods/blitzbar/blitzbar_localization",
		})
	end,
	packages = {},
}
