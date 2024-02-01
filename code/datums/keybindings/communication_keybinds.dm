/datum/keybinding/client/communication
	category = KB_CATEGORY_COMMUNICATION
	/// Used to store special rights if required by a keybind, such as R_ADMIN
	var/required_rights

/datum/keybinding/client/communication/down(client/C)
	. = ..()
	if(required_rights && !check_rights(required_rights, FALSE, C.mob))
		return
	winset(C, null, "command=[C.tgui_say_create_open_command(name)]")
	return TRUE

/datum/keybinding/client/communication/ooc
	name = OOC_CHANNEL
	keys = list("O")

/datum/keybinding/client/communication/looc
	name = LOOC_CHANNEL
	keys = list("L")

/datum/keybinding/client/communication/say
	name = SAY_CHANNEL
	keys = list("T")

/datum/keybinding/client/communication/me
	name = ME_CHANNEL
	keys = list("M")

/datum/keybinding/client/communication/whisper
	name = WHISPER_CHANNEL
	keys = list("U")

/datum/keybinding/client/communication/radio
	name = RADIO_CHANNEL
	keys = list("Y")

/datum/keybinding/client/communication/msay
	name = MENTOR_CHANNEL
	keys = list("F4")
	required_rights = R_MENTOR | R_ADMIN

/datum/keybinding/client/communication/asay
	name = ADMIN_CHANNEL
	keys = list("F5")
	required_rights = R_ADMIN

/datum/keybinding/client/communication/dsay
	name = DSAY_CHANNEL
	keys = list("F10")
	required_rights = R_ADMIN
