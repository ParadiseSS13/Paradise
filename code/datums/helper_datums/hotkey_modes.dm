/datum/hotkey_mode
	var/name
	var/macro_hotkeys_inactive
	var/macro_hotkeys_active
	var/mob/my_mob

/datum/hotkey_mode/New(mob)
	my_mob = mob

/datum/hotkey_mode/proc/set_winset_values()
	winset(my_mob, null, "mainwindow.macro=[macro_hotkeys_inactive] hotkey_toggle.is-checked=false input.focus=true input.background-color=#d3b5b5")
	winset(my_mob, null, "hotkey_toggle.command=\".winset \\\"mainwindow.macro != [macro_hotkeys_inactive] ? mainwindow.macro=[macro_hotkeys_inactive] hotkey_toggle.is-checked=false input.focus=true input.background-color=#d3b5b5 : mainwindow.macro=[macro_hotkeys_active] hotkey_toggle.is-checked=true mapwindow.map.focus=true input.background-color=#f0f0f0\\\"\"")

/datum/hotkey_mode/qwerty
	name = "QWERTY"
	macro_hotkeys_inactive = "macro"
	macro_hotkeys_active = "hotkeymode"

/datum/hotkey_mode/azerty
	name = "AZERTY"
	macro_hotkeys_inactive = "azertymacro"
	macro_hotkeys_active = "azertyhotkeymode"

/datum/hotkey_mode/cyborg
	name = "Cyborg"
	macro_hotkeys_inactive = "borgmacro"
	macro_hotkeys_active = "borghotkeymode"