//This should hold all the vampire related powers
/mob/living/proc/affects_vampire(mob/user)
	//Other vampires and thralls aren't affected
	if(mind?.has_antag_datum(/datum/antagonist/vampire) || mind?.has_antag_datum(/datum/antagonist/mindslave/thrall))
		return FALSE
	//Vampires who have reached their full potential can affect nearly everything
	var/datum/antagonist/vampire/V = user?.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V?.get_ability(/datum/vampire_passive/full))
		return TRUE
	//Holy characters are resistant to vampire powers
	if(mind?.isholy)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/vampire
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	human_req = TRUE
	clothes_req = FALSE
	/// How much blood this ability costs to use
	var/required_blood
	var/deduct_blood_on_cast = TRUE

/obj/effect/proc_holder/spell/vampire/create_new_handler()
	var/datum/spell_handler/vampire/H = new
	H.required_blood = required_blood
	H.deduct_blood_on_cast = deduct_blood_on_cast
	return H

/obj/effect/proc_holder/spell/vampire/self/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/vampire_passive
	var/gain_desc
	var/mob/living/owner = null

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You can now use [src]."

/datum/vampire_passive/Destroy(force, ...)
	owner = null
	return ..()

/datum/vampire_passive/proc/on_apply(datum/antagonist/vampire/V)
	return

/obj/effect/proc_holder/spell/vampire/self/rejuvenate
	name = "Rejuvenate"
	desc = "Use reserve blood to enliven your body, removing any incapacitating effects."
	action_icon_state = "vampire_rejuvinate"
	charge_max = 20 SECONDS
	stat_allowed = 1

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/cast(list/targets, mob/user = usr)
	var/mob/living/U = user

	U.SetWeakened(0)
	U.SetStunned(0)
	U.SetParalysis(0)
	U.SetSleeping(0)
	U.SetConfused(0)
	U.adjustStaminaLoss(-100)
	to_chat(user, "<span class='notice'>You instill your body with clean blood and remove any incapacitating effects.</span>")
	var/datum/antagonist/vampire/V = U.mind.has_antag_datum(/datum/antagonist/vampire)
	var/rejuv_bonus = V.get_rejuv_bonus()
	if(rejuv_bonus)
		INVOKE_ASYNC(src, .proc/heal, U, rejuv_bonus)

/obj/effect/proc_holder/spell/vampire/self/rejuvenate/proc/heal(mob/living/user, rejuv_bonus)
	for(var/i in 1 to 5)
		user.adjustBruteLoss(-2 * rejuv_bonus)
		user.adjustOxyLoss(-5 * rejuv_bonus)
		user.adjustToxLoss(-2 * rejuv_bonus)
		user.adjustFireLoss(-2 * rejuv_bonus)
		for(var/datum/reagent/R in user.reagents.reagent_list)
			if(!R.harmless)
				user.reagents.remove_reagent(R.id, 2 * rejuv_bonus)
		sleep(35)

/datum/antagonist/vampire/proc/get_rejuv_bonus()
	var/rejuv_multiplier = 0
	if(!get_ability(/datum/vampire_passive/regen))
		return rejuv_multiplier

	if(subclass?.improved_rejuv_healing)
		rejuv_multiplier = clamp((100 - owner.current.health) / 20, 1, 5) // brute and burn healing between 5 and 50
		return rejuv_multiplier

	return 1


/obj/effect/proc_holder/spell/vampire/self/specialize
	name = "Choose Specialization"
	desc = "Choose what sub-class of vampire you want to evolve into."
	gain_desc = "You can now choose what specialization of vampire you want to evolve into."
	charge_max = 2 SECONDS
	action_icon_state = "select_class"

/obj/effect/proc_holder/spell/vampire/self/specialize/cast(mob/user)
	ui_interact(user)

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SpecMenu", "Specialisation Menu", 1200, 600, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_data(mob/user)
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/list/data = list("subclasses" = vamp.subclass)
	return data

/obj/effect/proc_holder/spell/vampire/self/specialize/ui_act(action, list/params)
	if(..())
		return
	var/datum/antagonist/vampire/vamp = usr.mind.has_antag_datum(/datum/antagonist/vampire)

	if(vamp.subclass)
		vamp.upgrade_tiers -= type
		vamp.remove_ability(src)
		return

	switch(action)
		if("umbrae")
			vamp.add_subclass(SUBCLASS_UMBRAE)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("hemomancer")
			vamp.add_subclass(SUBCLASS_HEMOMANCER)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("gargantua")
			vamp.add_subclass(SUBCLASS_GARGANTUA)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)
		if("dantalion")
			vamp.add_subclass(SUBCLASS_DANTALION)
			vamp.upgrade_tiers -= type
			vamp.remove_ability(src)


/datum/antagonist/vampire/proc/add_subclass(subclass_to_add, announce = TRUE, log_choice = TRUE)
	var/datum/vampire_subclass/new_subclass = new subclass_to_add
	subclass = new_subclass
	check_vampire_upgrade(announce)
	if(log_choice)
		SSblackbox.record_feedback("nested tally", "vampire_subclasses", 1, list("[new_subclass.name]"))

/obj/effect/proc_holder/spell/vampire/glare
	name = "Glare"
	desc = "Your eyes flash, stunning and silencing anyone infront of you. It has lesser effects for those around you."
	action_icon_state = "vampire_glare"
	charge_max = 30 SECONDS
	stat_allowed = TRUE

/obj/effect/proc_holder/spell/vampire/glare/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.allowed_type = /mob/living
	T.range = 1
	return T

/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define DEVIATION_NONE 3
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define DEVIATION_PARTIAL 2
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define DEVIATION_FULL 1

/obj/effect/proc_holder/spell/vampire/glare/cast(list/targets, mob/living/user = usr)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
			var/obj/item/clothing/glasses/sunglasses/blindfold/B = H.glasses
			if(B.tint)
				to_chat(user, "<span class='warning'>You're blindfolded!</span>")
				return
	user.mob_light(LIGHT_COLOR_BLOOD_MAGIC, 3, _duration = 2)
	user.visible_message("<span class='warning'>[user]'s eyes emit a blinding flash!</span>")

	for(var/mob/living/target in targets)
		if(!target.affects_vampire(user))
			continue

		var/deviation
		if(user.IsWeakened() || user.resting)
			deviation = DEVIATION_PARTIAL
		else
			deviation = calculate_deviation(target, user)

		if(deviation == DEVIATION_FULL)
			target.AdjustConfused(6 SECONDS)
			target.adjustStaminaLoss(40)
		else if(deviation == DEVIATION_PARTIAL)
			target.Weaken(2 SECONDS)
			target.AdjustConfused(6 SECONDS)
			target.adjustStaminaLoss(40)
		else
			target.adjustStaminaLoss(120)
			target.Weaken(12 SECONDS)
			target.AdjustSilence(6 SECONDS)
			target.flash_eyes(1, TRUE, TRUE)
		to_chat(target, "<span class='warning'>You are blinded by [user]'s glare.</span>")
		add_attack_logs(user, target, "(Vampire) Glared at")

/obj/effect/proc_holder/spell/vampire/glare/proc/calculate_deviation(mob/victim, mob/attacker)
	// Are they on the same tile? We'll return partial deviation. This may be someone flashing while lying down
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

#undef DEVIATION_NONE
#undef DEVIATION_PARTIAL
#undef DEVIATION_FULL

/datum/vampire_passive/regen
	gain_desc = "Your rejuvenation abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential. You are no longer weak to the effects of anything holy and your vision has improved greatly."

/obj/effect/proc_holder/spell/vampire/raise_vampires
	name = "Raise Vampires"
	desc = "Summons deadly vampires from bluespace."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	human_req = 1
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 20
	action_icon_state = "revive_thrall"
	sound = 'sound/magic/wandodeath.ogg'
	gain_desc = "You have gained the ability to Raise Vampires. This extremely powerful AOE ability affects all humans near you. Vampires/thralls are healed. Corpses are raised as vampires. Others are stunned, then brain damaged, then killed."

/obj/effect/proc_holder/spell/vampire/raise_vampires/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 3
	return T

/obj/effect/proc_holder/spell/vampire/raise_vampires/cast(list/targets, mob/user = usr)
	new /obj/effect/temp_visual/cult/sparks(user.loc)
	var/turf/T = get_turf(user)
	to_chat(user, "<span class='warning'>You call out within bluespace, summoning more vampiric spirits to aid you!</span>")
	for(var/mob/living/carbon/human/H in targets)
		T.Beam(H, "sendbeam", 'icons/effects/effects.dmi', time = 30, maxdistance = 7, beam_type = /obj/effect/ebeam)
		new /obj/effect/temp_visual/cult/sparks(H.loc)
		raise_vampire(user, H)


/obj/effect/proc_holder/spell/vampire/raise_vampires/proc/raise_vampire(mob/M, mob/living/carbon/human/H)
	if(!istype(M) || !istype(H))
		return
	if(!H.mind)
		visible_message("[H] looks to be too stupid to understand what is going on.")
		return
	if(H.dna && (NO_BLOOD in H.dna.species.species_traits) || H.dna.species.exotic_blood || !H.blood_volume)
		visible_message("[H] looks unfazed!")
		return
	if(H.mind.has_antag_datum(/datum/antagonist/vampire) || H.mind.special_role == SPECIAL_ROLE_VAMPIRE || H.mind.special_role == SPECIAL_ROLE_VAMPIRE_THRALL)
		visible_message("<span class='notice'>[H] looks refreshed!</span>")
		H.adjustBruteLoss(-60)
		H.adjustFireLoss(-60)
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(prob(25))
				E.mend_fracture()
				E.fix_internal_bleeding()

		return
	if(H.stat != DEAD)
		if(H.IsWeakened())
			visible_message("<span class='warning'>[H] looks to be in pain!</span>")
			H.adjustBrainLoss(60)
		else
			visible_message("<span class='warning'>[H] looks to be stunned by the energy!</span>")
			H.Weaken(40 SECONDS)
		return
	for(var/obj/item/implant/mindshield/L in H)
		if(L && L.implanted)
			qdel(L)
	for(var/obj/item/implant/traitor/T in H)
		if(T && T.implanted)
			qdel(T)
	visible_message("<span class='warning'>[H] gets an eerie red glow in their eyes!</span>")
	var/datum/objective/protect/protect_objective = new
	protect_objective.owner = H.mind
	protect_objective.target = M.mind
	protect_objective.explanation_text = "Protect [M.real_name]."
	H.mind.objectives += protect_objective
	add_attack_logs(M, H, "Vampire-sired")
	H.mind.make_vampire()
	H.revive()
	H.Weaken(40 SECONDS)

/obj/effect/proc_holder/spell/turf_teleport/shadow_step
	name = "Shadow Step (30)"
	desc = "Teleport to a nearby dark region"
	gain_desc = "You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."
	action_icon_state = "shadowblink"
	charge_max = 2 SECONDS
	clothes_req = FALSE
	centcom_cancast = FALSE
	include_space = FALSE
	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"

	// Teleport radii
	inner_tele_radius = 0
	outer_tele_radius = 6

	include_light_turfs = FALSE

	sound1 = null
	sound2 = null

/obj/effect/proc_holder/spell/turf_teleport/shadow_step/create_new_handler()
	var/datum/spell_handler/vampire/H = new
	H.required_blood = 30
	return H
