/datum/action/cooldown/flock/radio_talk
	name = "Radio Transmission"
	desc = "Hijack a radio headset of a target to broadcast a message."
	button_icon_state = "talk"
	cooldown_time = 2 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/flock/radio_talk/Activate(atom/target)
	var/obj/item/radio/worn_radio
	if(!ishuman(target))
		to_chat(owner, SPAN_ALERT("[target] is not a valid target!"))
		return FALSE

	var/mob/living/carbon/human/schmuck = target
	worn_radio = schmuck.get_item_by_slot(ITEM_SLOT_LEFT_EAR) || schmuck.get_item_by_slot(ITEM_SLOT_RIGHT_EAR)
	if(!istype(worn_radio))
		to_chat(owner, SPAN_ALERT("[target] does not have a working radio!"))
		return FALSE

	var/msg = tgui_input_text(usr, "What do you wish to broadcast?", null, "")
	if(!msg)
		return FALSE

	. = ..()

	to_chat(owner, SPAN_NOTICE("You transmit a message through [schmuck]'s [worn_radio]!"))
	playsound(schmuck, "sound/effects/radio_sweep[rand(1,5)].ogg", 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	worn_radio.autosay(msg, "Strange Static", null)
