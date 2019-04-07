/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	show_laws(0)

	var/datum/hotkey_mode/cyborg/C = new()
	winset(src, null, "mainwindow.macro_hotkey_mode_inactive=[C.macro_hotkeys_inactive] mainwindow.macro_hotkey_mode_active=[C.macro_hotkeys_active] mainwindow.macro=[C.macro_hotkeys_inactive] hotkey_toggle.is-checked=false input.focus=true input.background-color=#d3b5b5")
