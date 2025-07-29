/datum/action/changeling/headslug
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 2
	req_human = TRUE
	req_stat = DEAD
	bypass_fake_death = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/defence

/datum/action/changeling/headslug/try_to_sting(mob/user, mob/target)
	if(tgui_alert(user, "Are you sure you wish to do this? This action cannot be undone.", "Sting", list("Yes", "No")) != "Yes")
		return
	..()

/datum/action/changeling/headslug/sting_action(mob/living/user)
	ADD_TRAIT(user, TRAIT_CLING_BURSTING, "last_resort")
	user.Weaken(30 SECONDS)
	user.do_jitter_animation(1000, -1) // jitter until they are gibbed
	user.visible_message("<span class='danger'>A loud crack erupts from [user], followed by a hiss.</span>")
	playsound(get_turf(user), "bonebreak", 75, TRUE)
	playsound(get_turf(user), 'sound/machines/hiss.ogg', 75, TRUE)
	addtimer(CALLBACK(src, PROC_REF(become_headslug), user), 5 SECONDS)
	var/matrix/M = user.transform
	M.Scale(1.8, 1.2)
	animate(user, time = 5 SECONDS, transform = M, easing = SINE_EASING)

/datum/action/changeling/headslug/proc/become_headslug(mob/user)
	var/datum/mind/M = user.mind
	var/list/organs = user.get_organs_zone("head", 1)
	if(isobj(user.loc))
		var/obj/thing_to_break = user.loc
		user.forceMove(get_turf(user)) // Get them outside of it before it breaks, to prevent issues / so they burst out of it dramatically
		thing_to_break.visible_message("<span class='danger'>[user] violently explodes out of [thing_to_break], breaking it!</span>")
		thing_to_break.obj_break(BRUTE)

	for(var/obj/item/organ/internal/I in organs)
		I.remove(user, TRUE)

	explosion(get_turf(user), 0, 0, 2, 0, silent = TRUE, cause = "Headslug explosion")
	for(var/mob/living/carbon/human/H in range(2, user))
		to_chat(H, "<span class='userdanger'>You are blinded by a shower of blood!</span>")
		H.KnockDown(4 SECONDS)
		H.EyeBlurry(40 SECONDS)
		var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(istype(E))
			E.receive_damage(5, 1)
		H.AdjustConfused(6 SECONDS)
	for(var/mob/living/silicon/S in range(2, user))
		to_chat(S, "<span class='userdanger'>Your sensors are disabled by a shower of blood!</span>")
		S.Weaken(6 SECONDS)
	var/turf/our_turf = get_turf(user)
	spawn(5) // So it's not killed in explosion
		var/mob/living/simple_animal/hostile/headslug/crab = new(our_turf)
		for(var/obj/item/organ/internal/I in organs)
			I.forceMove(crab)
		crab.origin = M
		if(crab.origin)
			crab.origin.active = TRUE
			crab.origin.transfer_to(crab)
			to_chat(crab, "<span class='warning'>You burst out of the remains of your former body in a shower of gore!</span>")
			to_chat(crab, "<span class='boldnotice'>Our eggs can be laid in any humanoid by ALT-CLICKing on them, this takes 5 seconds.</span>")
			to_chat(crab, "<span class='boldnotice'>Though this form shall perish after laying the egg, our true self shall be reborn in time.</span>")

	// This is done because after the original changeling gibs below, ALL of their actions are qdeleted
	// We need to store their power types so we can re-create them later.
	for(var/datum/action/changeling/power in cling.acquired_powers)
		cling.acquired_powers += power.type

	user.gib()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
