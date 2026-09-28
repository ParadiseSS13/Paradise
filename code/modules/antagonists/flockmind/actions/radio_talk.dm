/datum/action/cooldown/flock/radio_talk
	name = "Narrowbeam Transmission"
	desc = "Hijack a radio headset of a target to broadcast a message."
	button_icon_state = "talk"
	cooldown_time = 2 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/flock/radio_talk/Activate(atom/target)
	var/obj/item/radio/worn_radio


	if(!ishuman(target) && !istype(target, /obj/item/radio))
		to_chat(owner, SPAN_ALERT("[target] is not a valid target!"))
		return FALSE

	if(istype(target, /obj/item/radio))
		worn_radio = target
		if(!worn_radio.listening)
			to_chat(owner, SPAN_ALERT("[target] is not turned on!"))
			return FALSE

	if(ishuman(target))
		var/mob/living/carbon/human/schmuck = target
		for(var/obj/item/I in schmuck.get_contents())
			if(istype(I, /obj/item/radio))
				worn_radio = I
				break
		if(!istype(worn_radio) || !worn_radio.listening)
			to_chat(owner, SPAN_ALERT("[target] does not have a working radio!"))
			return FALSE

	var/msg = tgui_input_text(usr, "What do you wish to broadcast?", null, "")
	if(!msg)
		return FALSE

	. = ..()

	playsound(get_turf(worn_radio), "sound/effects/radio_sweep[rand(1,5)].ogg", 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(owner, SPAN_NOTICE("You transmit a message through [worn_radio]!"))
	worn_radio.autosay(istype(target, /obj/item/radio) ? Gibberish(msg, 70, 50) : msg, "Strange Static", null)
