return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`volleyfiretimer` encountered an error loading the Darktide Mod Framework.")

		new_mod("volleyfiretimer", {
			mod_script       = "volleyfiretimer/scripts/mods/volleyfiretimer/volleyfiretimer",
			mod_data         = "volleyfiretimer/scripts/mods/volleyfiretimer/volleyfiretimer_data",
			mod_localization = "volleyfiretimer/scripts/mods/volleyfiretimer/volleyfiretimer_localization",
		})
	end,
	packages = {},
}
