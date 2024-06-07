/datum/action/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak minded. Costs 30 chemicals."
	helptext = "Emits a high frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	button_icon_state = "resonant_shriek"
	chemical_cost = 30
	dna_cost = 2
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/offence

//A flashy ability, good for crowd control and sowing chaos.
/datum/action/changeling/resonant_shriek/sting_action(mob/user)
	if(istype(user.loc, /obj/machinery/atmospherics))
		return FALSE
	for(var/mob/living/M as anything in get_mobs_in_view(4, user))
		if(iscarbon(M))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
					continue
			if(!M.mind || !IS_CHANGELING(M))
				M.Deaf(30 SECONDS)
				M.AdjustConfused(40 SECONDS)
				M.Jitter(100 SECONDS)
			else
				SEND_SOUND(M, sound('sound/effects/clingscream.ogg'))

		if(issilicon(M))
			var/mob/living/silicon/robot/R = M
			R.disable_component("actuator", 7 SECONDS)
			SEND_SOUND(M, sound('sound/weapons/flash.ogg'))
			R.flash_eyes(2, affect_silicon = TRUE) //80 Stamina damage

	for(var/obj/machinery/light/L in range(4, user))
		L.on = TRUE
		L.break_light_tube()

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high frequency sound that overloads nearby electronics. Costs 30 chemicals."
	button_icon_state = "dissonant_shriek"
	chemical_cost = 30
	dna_cost = 2
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/utility

//A flashy ability, good for crowd control and sewing chaos.
/datum/action/changeling/dissonant_shriek/sting_action(mob/user)
	if(istype(user.loc, /obj/machinery/atmospherics))
		return FALSE
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = TRUE
		L.break_light_tube()
	empulse(get_turf(user), 3, 5, 1)

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/// A more expensive version, used during rounds with cyber rev station trait for balance reasons.
/datum/action/changeling/dissonant_shriek/cyberrev
	dna_cost = 5
