//This should hold all the vampire related powers
/mob/living/proc/affects_vampire(mob/user)
	//Other vampires aren't affected
	if(mind && mind.vampire)
		return FALSE
	//Vampires who have reached their full potential can affect nearly everything
	if(user && user.mind.vampire.get_ability(/datum/vampire_passive/full))
		return TRUE
	//Holy characters are resistant to vampire powers
	if(mind && mind.isholy)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/proc/vampire_can_cast(blood_cost, deduct_blood_on_cast = TRUE)
	var/mob/user = usr
	if(!user.mind)
		return FALSE

	var/datum/vampire/vampire = user.mind.vampire

	if(!vampire)
		return FALSE

	var/fullpower = vampire.get_ability(/datum/vampire_passive/full)

	if(user.stat >= DEAD)
		to_chat(user, "<span class='warning'>Not when you're dead!</span>")
		return FALSE

	if(vampire.nullified && !fullpower)
		to_chat(user, "<span class='warning'>Something is blocking your powers!</span>")
		return FALSE
	if(vampire.bloodusable < required_blood)
		to_chat(user, "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>")
		return FALSE
		//chapel check
	if(istype(loc.loc, /area/chapel) && !fullpower)
		to_chat(user, "<span class='warning'>Your powers are useless on this holy ground.</span>")
		return FALSE


/obj/effect/proc_holder/spell/self/choose_targets(mob/user = usr)
	perform(list(user))

/obj/effect/proc_holder/spell/mob_aoe/choose_targets(mob/user = usr)
	var/list/targets[0]
	for(var/mob/living/carbon/C in oview_or_orange(range, user, selection_type))
		targets += C
	for(var/mob/living/silicon/S in oview_or_orange(range, user, selection_type))
		targets += S

	if(!targets.len)
		revert_cast(user)
		return

	perform(targets, user = user)

/obj/effect/proc_holder/spell/proc/before_cast_vampire(list/targets)
	// sanity check before we cast
	if(!usr.mind || !usr.mind.vampire)
		targets.Cut()
		return FALSE

	if(!required_blood)
		return

	// enforce blood
	var/datum/vampire/vampire = usr.mind.vampire

	if(required_blood <= vampire.bloodusable)
		if(!deduct_blood_on_cast) //don't take the blood yet if this is false!
			return
		vampire.bloodusable -= required_blood
		to_chat(usr, "<span class='notice'><b>You have [vampire.bloodusable] left to use.</b></span>")
		return TRUE
	else
		// stop!!
		targets.Cut()
		return FALSE

/datum/vampire_passive
	var/gain_desc
	var/mob/living/owner = null

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."

////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/self/rejuvenate
	name = "Rejuvenate"
	desc= "Use reserve blood to enliven your body, removing any incapacitating effects."
	action_icon_state = "vampire_rejuvinate"
	charge_max = 200
	stat_allowed = 1
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/rejuvenate/cast(list/targets, mob/user = usr)
	var/mob/living/U = user

	U.SetWeakened(0)
	U.SetStunned(0)
	U.SetParalysis(0)
	U.SetSleeping(0)
	U.SetConfused(0)
	U.adjustStaminaLoss(-100)
	to_chat(user, "<span class='notice'>You instill your body with clean blood and remove any incapacitating effects.</span>")
	var/rejuv_bonus = U.mind.vampire.get_rejuv_bonus()
	if(rejuv_bonus)
		for(var/i = 1 to 5)
			U.adjustBruteLoss(-2 * rejuv_bonus)
			U.adjustOxyLoss(-5 * rejuv_bonus)
			U.adjustToxLoss(-2 * rejuv_bonus)
			U.adjustFireLoss(-2 * rejuv_bonus)
			for(var/datum/reagent/R in U.reagents.reagent_list)
				if(!R.harmless)
					U.reagents.remove_reagent(R.id, 2 * rejuv_bonus)
			sleep(35)

/datum/vampire/proc/get_rejuv_bonus()
	var/rejuv_multiplier = 0
	if(!get_ability(/datum/vampire_passive/regen))
		return rejuv_multiplier

	if(subclass == SUBCLASS_GARGANTUA)
		rejuv_multiplier = min((100 - owner.health)/20, 5) // max healing of 50 brute and burn
		return rejuv_multiplier

	return 1


/obj/effect/proc_holder/spell/self/specialize
	name = "Choose Specialization"
	desc = "Choose what sub-class of vampire you want to evolve into."
	charge_max = 2 SECONDS
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"


/obj/effect/proc_holder/spell/self/specialize/cast(mob/user)
	var/list/options = list("Hemomancer",
							"Gargantua",
							"Dantalion",
							"Umbrae")
	var/choice = show_radial_menu(user, user, options)

	switch(choice)
		if("Hemomancer")
			user.mind.vampire.subclass = SUBCLASS_HEMOMANCER
			user.mind.vampire.upgrade_tiers.Remove(type)
			user.mind.vampire.remove_ability(src)
			user.mind.vampire.check_vampire_upgrade()
		if("Gargantua")
			user.mind.vampire.subclass = SUBCLASS_GARGANTUA
			user.mind.vampire.upgrade_tiers.Remove(type)
			user.mind.vampire.remove_ability(src)
			user.mind.vampire.check_vampire_upgrade()
		if("Dantalion")
			user.mind.vampire.subclass = SUBCLASS_DANTALION
			user.mind.vampire.upgrade_tiers.Remove(type)
			user.mind.vampire.remove_ability(src)
			user.mind.vampire.check_vampire_upgrade()
		if("Umbrae")
			user.mind.vampire.subclass = SUBCLASS_UMBRAE
			user.mind.vampire.upgrade_tiers.Remove(type)
			user.mind.vampire.remove_ability(src)
			user.mind.vampire.check_vampire_upgrade()

/obj/effect/proc_holder/spell/mob_aoe/glare
	name = "Glare"
	desc = "A scary glare that incapacitates people for a short while around you."
	action_icon_state = "vampire_glare"
	charge_max = 30 SECONDS
	stat_allowed = 1
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define DEVIATION_NONE 3
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define DEVIATION_PARTIAL 2
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define DEVIATION_FULL 1

/obj/effect/proc_holder/spell/mob_aoe/glare/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user]'s eyes emit a blinding flash!</span>")
	if(istype(user:glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, "<span class='warning'>You're blindfolded!</span>")
		return
	for(var/mob/living/target in targets)
		if(!target.affects_vampire())
			continue
		var/deviation = calculate_deviation(target, user)

		if(deviation == DEVIATION_FULL)
			target.AdjustConfused(3)
			target.adjustStaminaLoss(40)
		else if(deviation == DEVIATION_PARTIAL)
			target.Weaken(1)
			target.AdjustConfused(3)
			target.adjustStaminaLoss(40)
		else
			target.adjustStaminaLoss(120)
			target.Weaken(6)
			target.AdjustSilence(3)
		target.flash_eyes(2, TRUE, TRUE)
		to_chat(target, "<span class='warning'>You are blinded by [user]'s glare.</span>")
		add_attack_logs(user, target, "(Vampire) Glared at")

/obj/effect/proc_holder/spell/mob_aoe/glare/proc/calculate_deviation(mob/victim, mob/attacker)
	// Are they on the same tile? We'll return partial deviation. This may be someone flashing while lying down
	// or flashing someone they're stood on the same turf as, or a borg flashing someone buckled to them.
	if(victim.loc == attacker.loc)
		return DEVIATION_PARTIAL

	// If the victim was looking at the attacker, this is the direction they'd have to be facing.
	var/attacker_to_victim = get_dir(attacker, victim)
	// The victim's dir is necessarily a cardinal value.
	var/attacker_dir = attacker.dir

	// - - -
	// - V - Attacker facing south
	// # # #
	// Attacker within 45 degrees of where the victim is facing.
	if(attacker_dir & attacker_to_victim)
		return DEVIATION_NONE

	// # # #
	// - V - Attacker facing south
	// - - -
	// Victim at 135 or more degrees of where the victim is facing.
	if(attacker_dir & GetOppositeDir(attacker_to_victim))
		return DEVIATION_FULL

	// - - -
	// # V # Attacker facing south
	// - - -
	// Victim lateral to the victim.
	return DEVIATION_PARTIAL


/obj/effect/proc_holder/spell/self/screech
	name = "Chiropteran Screech (30)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chiropteran Screech ability which stuns anything with ears in a large radius and shatters glass in the process."
	action_icon_state = "vampire_screech"
	required_blood = 30
	vampire_ability = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/self/screech/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] lets out an ear piercing shriek!</span>", "<span class='warning'>You let out a loud shriek.</span>", "<span class='warning'>You hear a loud painful shriek!</span>")
	for(var/mob/living/carbon/C in hearers(4))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue
		if(!C.affects_vampire())
			continue
		to_chat(C, "<span class='warning'><font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b></span>")
		C.Weaken(4)
		C.AdjustEarDamage(0, 20)
		C.Stuttering(20)
		C.Stun(4)
		C.Jitter(150)
	for(var/obj/structure/window/W in view(4))
		W.deconstruct(FALSE)
	for(var/obj/machinery/light/L in view(4))
		L.burnout()
	playsound(user.loc, 'sound/effects/creepyshriek.ogg', 100, 1)

/datum/vampire_passive/regen
	gain_desc = "Your rejuvination abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."

/obj/effect/proc_holder/spell/targeted/raise_vampires
	name = "Raise Vampires"
	desc = "Summons deadly vampires from bluespace."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	human_req = 1
	invocation = "none"
	invocation_type = "none"
	max_targets = 0
	range = 3
	cooldown_min = 20
	action_icon_state = "revive_thrall"
	vampire_ability = TRUE
	sound = 'sound/magic/wandodeath.ogg'
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

/obj/effect/proc_holder/spell/targeted/raise_vampires/cast(list/targets, mob/user = usr)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	var/turf/T = get_turf(user)
	to_chat(user, "<span class='warning'>You call out within bluespace, summoning more vampiric spirits to aid you!</span>")
	for(var/mob/living/carbon/human/H in targets)
		T.Beam(H, "sendbeam", 'icons/effects/effects.dmi', time = 30, maxdistance = 7, beam_type = /obj/effect/ebeam)
		new /obj/effect/temp_visual/cult/sparks(H.loc)
		H.raise_vampire(user)


/mob/living/carbon/human/proc/raise_vampire(mob/M)
	if(!istype(M))
		log_debug("human/proc/raise_vampire called with invalid argument.")
		return
	if(!mind)
		visible_message("[src] looks to be too stupid to understand what is going on.")
		return
	if(dna && (NO_BLOOD in dna.species.species_traits) || dna.species.exotic_blood || !blood_volume)
		visible_message("[src] looks unfazed!")
		return
	if(mind.vampire || mind.special_role == SPECIAL_ROLE_VAMPIRE || mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		visible_message("<span class='notice'>[src] looks refreshed!</span>")
		adjustBruteLoss(-60)
		adjustFireLoss(-60)
		for(var/obj/item/organ/external/E in bodyparts)
			if(prob(25))
				E.mend_fracture()

		return
	if(stat != DEAD)
		if(IsWeakened())
			visible_message("<span class='warning'>[src] looks to be in pain!</span>")
			adjustBrainLoss(60)
		else
			visible_message("<span class='warning'>[src] looks to be stunned by the energy!</span>")
			Weaken(20)
		return
	for(var/obj/item/implant/mindshield/L in src)
		if(L && L.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in src)
		if(T && T.implanted)
			qdel(T)
	visible_message("<span class='warning'>[src] gets an eerie red glow in their eyes!</span>")
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = mind
	protect_objective.target = M.mind
	protect_objective.explanation_text = "Protect [M.real_name]."
	mind.objectives += protect_objective
	add_attack_logs(M, src, "Vampire-sired")
	mind.make_Vampire()
	revive()
	Weaken(20)

/obj/effect/proc_holder/spell/targeted/turf_teleport/shadow_step
	name = "Shadow Step"
	desc = "Teleport to a nearby dark region"
	gain_desc = "You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."
	action_icon_state = "shadowblink"
	charge_max = 20
	required_blood = 30
	centcom_cancast = FALSE
	vampire_ability = TRUE
	include_space = FALSE
	range = -1
	include_user = TRUE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

	// Teleport radii
	inner_tele_radius = 0
	outer_tele_radius = 6

	include_light = FALSE

	sound1 = null
	sound2 = null
