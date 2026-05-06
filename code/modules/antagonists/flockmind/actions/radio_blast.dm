/datum/action/cooldown/flock/radio_blast
	name = "Radio Stun Burst"
	desc = "Overwhelm the radio headsets of everyone within 3m of your target. Will not work on broken or non-existent headsets."
	button_icon_state = "radio_stun"
	cooldown_time = 20 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/flock/radio_blast/Activate(atom/target)
	var/list/targets = list()
	for(var/mob/living/carbon/human/guy in range(3, get_turf(target)))
		var/obj/item/radio/worn_radio = guy.get_item_by_slot(ITEM_SLOT_EARS)
		if(!istype(worn_radio))
			continue

		if(!guy.can_hear())
			continue

		if(!worn_radio.get_listening())
			continue

		targets += guy

	if(!length(targets))
		to_chat(owner, span_alert("No targets are in range with active headsets."))
		return FALSE

	. = ..()

	to_chat(owner, span_notice("You transmit the worst static you can weave into the headsets around you."))
	playsound(owner, 'goon/sounds/flockmind/flockmind_cast.ogg', 50, FALSE)

	for(var/mob/living/carbon/human/guy as anything in targets)
		to_chat(guy, span_alert("Horrifying static bursts into your headset, disorienting you severely!"))
		playsound(guy, "sound/effects/radio_sweep[rand(1,5)].ogg", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		guy.Knockdown(3 SECONDS)
		guy.set_confusion_if_lower(20 SECONDS)
		guy.do_jitter_animation(10)

		var/obj/item/organ/ears/ears = guy.getorganslot(ORGAN_SLOT_EARS)
		ears.adjustEarDamage(rand(2, 6), rand(3, 6))
