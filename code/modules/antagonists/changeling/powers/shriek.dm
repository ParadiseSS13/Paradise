/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak minded. Costs 30 chemicals."
	helptext = "Emits a high frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 30
	req_human = TRUE


/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	for(var/mob/living/l_target in get_mobs_in_view(4, user))
		if(iscarbon(l_target))
			if(ishuman(l_target))
				var/mob/living/carbon/human/h_target = l_target
				if(h_target.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
					continue

				h_target.Deaf(60 SECONDS)

			if(!ischangeling(l_target))
				l_target.AdjustConfused(40 SECONDS)
				l_target.Jitter(100 SECONDS)
				SEND_SOUND(l_target, sound('sound/effects/screech.ogg'))

		if(issilicon(l_target))
			SEND_SOUND(l_target, sound('sound/weapons/flash.ogg'))
			l_target.Weaken(rand(10 SECONDS, 20 SECONDS))

	for(var/obj/machinery/light/lamp in range(4, user))
		lamp.on = TRUE
		lamp.break_light_tube()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high frequency sound that overloads nearby electronics. Costs 30 chemicals."
	button_icon_state = "dissonant_shriek"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 30


/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	for(var/obj/machinery/light/lamp in range(5, user))
		lamp.on = TRUE
		lamp.break_light_tube()
	empulse(get_turf(user), 2, 4, TRUE, "Changeling Shriek")
	return TRUE
