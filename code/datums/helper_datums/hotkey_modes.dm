/datum/hotkey_mode
	var/name
	var/macro_hotkeys_inactive
	var/macro_hotkeys_active

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