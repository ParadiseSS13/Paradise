/datum/disease/zombie
	name = "Necrotizing Plague"
	medical_name = "Advanced Resurrection Syndrome"
	desc = "This virus infects humanoids and drives them insane with a hunger for flesh, along with possessing regenerative abilities."
	max_stages = 7
	spread_text = "Blood and Saliva"
	spread_flags = SPREAD_BLOOD
	cure_text = "Anti-plague viral solutions"
	cures = list()
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	severity = VIRUS_BIOHAZARD
	allow_dead = TRUE
	disease_flags = VIRUS_CAN_CARRY
	virus_heal_resistant = TRUE
	stage_prob = 100 // It isn't actually 100%, but is instead based on a timer
	cure_chance = 80
	/// How far this particular virus is in being cured (0-4)
	var/cure_stage = 0
	/// Cooldown until the virus can advance to the next stage
	COOLDOWN_DECLARE(stage_timer)
	/// What disease are we passing along to datum/antagonist/zombie
	var/plague_disease
	/// Activate the immediate zombie rot loop
	var/instant_zombie

/datum/disease/zombie/New(chosen_plague, plague_zomb)
	if(plague_zomb)
		plague_disease = chosen_plague
		instant_zombie = TRUE

/datum/disease/zombie/stage_act()
	if(stage == 8)
		// adminbus for immediate zombie
		var/mob/living/carbon/human/H = affected_mob
		if(!istype(H))
			return FALSE
		for(var/obj/item/organ/limb as anything in H.bodyparts)
			if(!(limb.status & ORGAN_DEAD) && !limb.is_robotic())
				limb.necrotize(TRUE, TRUE)
			if(!HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
				ADD_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)

	if(!..())
		return FALSE
	if(HAS_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS) || affected_mob.mind?.has_antag_datum(/datum/antagonist/zombie))
		SSticker.mode.zombie_infected -= affected_mob
		if(affected_mob.reagents.has_reagent("zombiecure4"))
			return
		handle_rot()
		stage = 7
		return FALSE
	SSticker.mode.zombie_infected |= affected_mob
	switch(stage)
		if(1) // cured by lvl 1 cure
			if(prob(4))
				to_chat(affected_mob, "<span class='warning'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>")
			else if(prob(5))
				to_chat(affected_mob, "<span class='warning'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>")
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Mucous runs down the back of your throat.</span>")
			else if(prob(5))
				to_chat(affected_mob, "<span class='warning'>[pick("You feel hungry.", "You crave for something to eat.")]</span>")
		if(3) // cured by lvl 2 cure
			if(prob(2))
				affected_mob.emote("sneeze")
			else if(prob(2))
				affected_mob.emote("cough")
			else if(prob(5))
				to_chat(affected_mob, "<span class='warning'><i>[pick("So hungry...", "You'd kill someone for a bite of food...", "Hunger cramps seize you...")]</i></span>")
			if(prob(5))
				affected_mob.adjustToxLoss(1)
		if(4) // shows up on medhuds
			if(prob(2))
				affected_mob.emote("stare")
			else if(prob(2))
				affected_mob.emote("drool")
			else if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel a cold sweat form.</span>")
			if(prob(25))
				affected_mob.adjustToxLoss(1)
		if(5, 6)  // 5 is cured by lvl 3 cure. 6+ needs lvl 4 cure
			var/turf/T = get_turf(affected_mob)
			if(T.get_lumcount() >= 0.5)
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Those lights seem bright. It stings.</span>")
				if(prob(25))
					affected_mob.adjustFireLoss(2)
			if(prob(2))
				affected_mob.emote("drool")
			if(stage == 6 && !affected_mob.reagents.has_reagent("zombiecure3")) // cure 3 can delay it, but not cure it
				if(prob(10))
					to_chat(affected_mob, "<span class='danger zombie'>You feel your flesh rotting.</span>")
				if(prob(10) || affected_mob.stat != DEAD)
					handle_rot()
		if(7)
			if(!handle_rot())
				stage = 6
				return

/datum/disease/zombie/handle_stage_advance(has_cure = FALSE)
	if(!stage_timer)
		COOLDOWN_START(src, stage_timer, 1 MINUTES) // for the first infection
	if(affected_mob.stat != DEAD || !prob(30)) // when the body is dead, it always has a 30% chance to advance regardless
		if(!COOLDOWN_FINISHED(src, stage_timer))
			return
	COOLDOWN_START(src, stage_timer, 1 MINUTES)
	..()


/datum/disease/zombie/proc/handle_rot()
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return FALSE
	for(var/obj/item/organ/limb as anything in H.bodyparts)
		if(!(limb.status & ORGAN_DEAD) && !limb.vital && !limb.is_robotic())
			limb.necrotize()
		if(!HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
			ADD_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)
			return FALSE

	for(var/obj/item/organ/limb as anything in H.bodyparts)
		if(!(limb.status & ORGAN_DEAD) && !limb.is_robotic())
			limb.necrotize(FALSE, TRUE)
		if(!HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
			ADD_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)
			return FALSE

	if(!HAS_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS))
		affected_mob.AddComponent(/datum/component/zombie_regen)
		ADD_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS, ZOMBIE_TRAIT)
		affected_mob.med_hud_set_health()
		affected_mob.med_hud_set_status()
		affected_mob.update_hands_hud()
		H.update_body()
	if(affected_mob.mind && !affected_mob.mind.has_antag_datum(/datum/antagonist/zombie))
		if(HAS_TRAIT(affected_mob, TRAIT_PLAGUE_ZOMBIE))
			var/datum/antagonist/zombie/plague = new /datum/antagonist/zombie(plague_disease)
			plague.silent = TRUE //to prevent the second box from appearing
			plague.wiki_page_name = null
			affected_mob.mind.add_antag_datum(plague)
		else
			affected_mob.mind.add_antag_datum(/datum/antagonist/zombie)

	return TRUE


/datum/disease/zombie/handle_cure_testing(has_cure = FALSE)
	if(has_cure && prob(cure_chance))
		stage = max(stage - 1, 0)

	if(stage <= 0 && has_cure)
		cure()
		return FALSE
	return TRUE

/datum/disease/zombie/proc/update_cure_stage()
	for(var/datum/reagent/zombie_cure/reag in affected_mob.reagents?.reagent_list)
		cure_stage = max(cure_stage, reag.cure_level)
	if(cure_stage)
		var/stages = list("Stabilized", "Weakened", "Faltering", "Suppressed")
		name = "[stages[cure_stage]] [initial(name)]"

/datum/disease/zombie/has_cure()
	update_cure_stage()
	var/required_reagent = (stage + 1) / 2 // stage 1 can be cured by cure 1, stage 3 with 2, stage 5 with 3, stage 7 with 4
	return cure_stage >= required_reagent

/datum/disease/zombie/cure()
	affected_mob.mind?.remove_antag_datum(/datum/antagonist/zombie)
	REMOVE_TRAIT(affected_mob, TRAIT_I_WANT_BRAINS, ZOMBIE_TRAIT)
	var/mob/living/carbon/human/H = affected_mob
	for(var/obj/item/organ/limb as anything in H.bodyparts)
		if(HAS_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN))
			REMOVE_TRAIT(limb, TRAIT_I_WANT_BRAINS_ORGAN, ZOMBIE_TRAIT)
	affected_mob.DeleteComponent(/datum/component/zombie_regen)
	affected_mob.med_hud_set_health()
	affected_mob.med_hud_set_status()
	return ..()

/datum/disease/zombie/wizard
		spread_flags = SPREAD_NON_CONTAGIOUS
		bypasses_immunity = TRUE
		spread_text = "Non Contagious"
		cure_text = "Anti-magic"

// this should not be curable. Prevents things like rez wands from un-zombifying your zombs.
/datum/disease/zombie/wizard/cure()
	return
