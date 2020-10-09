/obj/item/voice_changer
	name = "voice changer"
	desc = "A voice scrambling module."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice_changer_off"

	actions_types = list(/datum/action/item_action/voice_changer/toggle, /datum/action/item_action/voice_changer/voice)

	var/obj/item/parent

	var/voice
	var/active

/obj/item/voice_changer/New()
	. = ..()

	if(isitem(loc))
		parent = loc
		parent.actions |= actions

/obj/item/voice_changer/Destroy()
	if(isitem(parent))
		parent.actions -= actions

	return ..()

/obj/item/voice_changer/attack_self(mob/user)
	active = !active
	icon_state = "voice_changer_[active ? "on" : "off"]"
	to_chat(user, "<span class='notice'>You toggle [src] [active ? "on" : "off"].</span>")

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/voice_changer/proc/set_voice(mob/user)
	var/chosen_voice = clean_input("What voice would you like to mimic? Leave this empty to use the voice on your ID card.", "Set Voice Changer", voice, user)
	if(!chosen_voice)
		voice = null
		to_chat(user, "<span class='notice'>You are now mimicking the voice on your ID card.</span>")
		return

	voice = sanitize(copytext_char(chosen_voice, 1, MAX_MESSAGE_LEN))
	to_chat(user, "<span class='notice'>You are now mimicking <b>[voice]</b>.</span>")
