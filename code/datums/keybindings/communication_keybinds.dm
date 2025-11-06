/datum/keybinding/client/communication
	category = KB_CATEGORY_COMMUNICATION
	/// Used to store special rights if required by a keybind, such as R_ADMIN
	var/required_rights
	/// Used to map muted categories to channels
	var/mute_category = MUTE_OOC

/datum/keybinding/client/communication/down(client/C)
	. = ..()
	if(required_rights && !check_rights(required_rights, FALSE, C.mob))
		return

	if(mute_category && check_mute(C.ckey, mute_category))
		to_chat(C, "<span class='danger'>You cannot use [name] (muted).</span>", MESSAGE_TYPE_WARNING)
		return

	winset(C, null, "command=[C.tgui_say_create_open_command(name)];")
	winset(C, "tgui_say.browser", "focus=true")

/datum/keybinding/client/communication/ooc
	name = OOC_CHANNEL
	keys = list("O")

/datum/keybinding/client/communication/ooc/down(client/C)
	if(check_rights(R_ADMIN, FALSE, C.mob)) // You may pass
		return ..()

	if(!GLOB.ooc_enabled)
		to_chat(C, "<span class='danger'>OOC is globally muted.</span>", MESSAGE_TYPE_WARNING)
		return

	if(!GLOB.dooc_enabled && C.mob.stat == DEAD)
		to_chat(C, "<span class='danger'>OOC for dead mobs has been turned off.</span>", MESSAGE_TYPE_WARNING)
		return

	return ..()

/datum/keybinding/client/communication/looc
	name = LOOC_CHANNEL
	keys = list("L")

/datum/keybinding/client/communication/say
	name = SAY_CHANNEL
	keys = list("T")
	mute_category = MUTE_IC

/datum/keybinding/client/communication/me
	name = ME_CHANNEL
	keys = list("M")
	mute_category = MUTE_EMOTE

/datum/keybinding/client/communication/whisper
	name = WHISPER_CHANNEL
	keys = list("U")
	mute_category = MUTE_IC

/datum/keybinding/client/communication/radio
	name = RADIO_CHANNEL
	keys = list("Y")
	mute_category = MUTE_IC

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

/datum/keybinding/client/communication/devsay
	name = DEV_CHANNEL
	keys = list("F2")
	required_rights = R_DEV_TEAM | R_ADMIN

/datum/keybinding/client/communication/staffsay
	name = STAFF_CHANNEL
	keys = list("-")
	required_rights = R_DEV_TEAM | R_MENTOR | R_ADMIN
