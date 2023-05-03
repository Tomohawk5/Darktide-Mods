return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`hideprompts` encountered an error loading the Darktide Mod Framework.")

		new_mod("hideprompts", {
			mod_script       = "hideprompts/scripts/mods/hideprompts/hideprompts",
			mod_data         = "hideprompts/scripts/mods/hideprompts/hideprompts_data",
			mod_localization = "hideprompts/scripts/mods/hideprompts/hideprompts_localization",
		})
	end,
	packages = {},
}
