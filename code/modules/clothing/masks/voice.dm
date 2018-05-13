/obj/item/voice_changer
	name = "voice changer"
	desc = "A voice scrambling module. If you can see this, report it as a bug on the tracker."
	var/voice //If set and item is present in mask/suit, this name will be used for the wearer's speech.
	var/active

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	var/obj/item/voice_changer/changer
	burn_state = FIRE_PROOF
	actions_types = list(/datum/action/item_action/toggle_voice_changer, /datum/action/item_action/change_voice)

/obj/item/clothing/mask/gas/voice/New()
	..()
	changer = new(src)

/obj/item/clothing/mask/gas/voice/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_voice_changer))
		toggle_voice_changer(user)
		return TRUE
	if(istype(action, /datum/action/item_action/change_voice))
		set_voice(user)
		return TRUE
	return FALSE

/obj/item/clothing/mask/gas/voice/proc/toggle_voice_changer(mob/user)
	changer.active = !changer.active
	to_chat(user, "<span class='notice'>You [changer.active ? "enable" : "disable"] the voice-changing module on [src].</span>")

/obj/item/clothing/mask/gas/voice/proc/set_voice(mob/user)
	var/voice = sanitize(copytext(input(user, "Choose a voice to mimic.") as text, 1, MAX_MESSAGE_LEN))
	if(!voice || !length(voice))
		return
	changer.voice = voice
	to_chat(user, "<span class='notice'>You are now mimicking <B>[changer.voice]</B>.</span>")