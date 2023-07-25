/datum/action/changeling/headslug
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 20
	req_human = TRUE


/datum/action/changeling/headslug/try_to_sting(mob/user, mob/target)
	if(alert("Are you sure you wish to do this? This action cannot be undone.",, "Yes", "No") == "No")
		return
	..()


/datum/action/changeling/headslug/sting_action(mob/user)

	explosion(get_turf(user), 0, 0, 2, 0, silent = TRUE)

	for(var/mob/living/carbon/human/victim in range(2, user))
		to_chat(victim, span_userdanger("You are blinded by a shower of blood!"))
		victim.Stun(2 SECONDS)
		victim.EyeBlurry(40 SECONDS)
		var/obj/item/organ/internal/eyes/eyes = victim.get_int_organ(/obj/item/organ/internal/eyes)
		if(istype(eyes))
			eyes.receive_damage(5, 1)
		victim.AdjustConfused(6 SECONDS)

	for(var/mob/living/silicon/silicon in range(2, user))
		to_chat(silicon, span_userdanger("Your sensors are disabled by a shower of blood!"))
		silicon.Weaken(6 SECONDS)

	var/turf/our_turf = get_turf(user)
	var/datum/mind/user_mind = user.mind
	addtimer(CALLBACK(src, PROC_REF(headslug_appear), user_mind, our_turf), 0.5 SECONDS)	// So it's not killed in explosion

	user.gib()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE


/datum/action/changeling/headslug/proc/headslug_appear(datum/mind/user_mind, turf/cling_turf)

	var/mob/living/simple_animal/hostile/headslug/crab = new(cling_turf)
	crab.origin = user_mind

	if(crab.origin)
		crab.origin.active = TRUE
		crab.origin.transfer_to(crab)
		to_chat(crab, span_warning("You burst out of the remains of your former body in a shower of gore!"))
		to_chat(crab, span_changeling("Our eggs can be laid in any dead humanoid, but not in small ones. Use <B>Alt-Click</B> on the valid mob and keep calm for 5 seconds."))
		to_chat(crab, span_notice("Though this form shall perish after laying the egg, our true self shall be reborn in time."))

