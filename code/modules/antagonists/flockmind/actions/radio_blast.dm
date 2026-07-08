/datum/action/cooldown/flock/radio_blast
	name = "Radio Stun Burst"
	desc = "Overwhelm the radio headsets of everyone within 3m of your target. Will not work on broken or non-existent headsets."
	button_icon_state = "radio_stun"
	cooldown_time = 20 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/flock/radio_blast/Activate(atom/target)
	var/list/targets = list()
	for(var/mob/living/carbon/human/guy in range(3, get_turf(target)))
		var/obj/item/radio/worn_radio
		for(var/obj/item/I in guy.get_contents())
			if(istype(I, /obj/item/radio))
				worn_radio = I
				break
		if(!istype(worn_radio) || !guy.can_hear() || !worn_radio.listening)
			continue

		targets += guy

	if(!length(targets))
		to_chat(owner, SPAN_ALERT("No targets are in range with active headsets."))
		return FALSE

	. = ..()

	to_chat(owner, SPAN_NOTICE("You transmit the worst static you can weave into the headsets around you."))
	playsound(owner, 'sound/goonstation/flockmind/flockmind_cast.ogg', 50, FALSE)

	for(var/mob/living/carbon/human/guy as anything in targets)
		to_chat(guy, SPAN_ALERT("Horrifying static bursts into your headset, disorienting you severely!"))
		playsound(guy, "sound/effects/radio_sweep[rand(1,5)].ogg", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		guy.KnockDown(3 SECONDS)
		guy.SetConfused(20 SECONDS)
		guy.do_jitter_animation(10)

		var/obj/item/organ/internal/ears/ears = guy.get_int_organ(/obj/item/organ/internal/ears)
		if(istype(ears))
			ears.receive_damage(rand(3, 6))
