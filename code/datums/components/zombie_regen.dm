
/datum/component/zombie_regen/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSprocessing, src)

/datum/component/zombie_regen/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/zombie_regen/process()
	if(!ishuman(parent))
		return
	var/mob/living/carbon/human/zomboid = parent
	if(zomboid.suiciding)
		return
	var/turf/current_turf = get_turf(zomboid)
	var/healing_factor = max(1, 6 * (1 - current_turf.get_lumcount()))
	if(HAS_TRAIT(zomboid, TRAIT_PLAGUE_ZOMBIE))
		healing_factor *= 1.6 // plague zombies have more health, and should heal faster
	if(zomboid.reagents.has_reagent("zombiecure3"))
		healing_factor /= 3
	if(zomboid.stat == DEAD)
		healing_factor *= 2
	for(var/obj/item/organ/external/E in zomboid.bodyparts)
		if(E.status & ORGAN_BURNT) // lets slowly remove any crit burns
			if(prob(20))
				E.status &= ~ORGAN_BURNT
			break
	zomboid.heal_overall_damage(healing_factor, healing_factor)
	zomboid.adjustBrainLoss(-healing_factor)
	if(zomboid.stat == DEAD && zomboid.getBruteLoss() <= 1 && zomboid.getFireLoss() <= 1 && (zomboid.timeofdeath + 15 SECONDS <= world.time))
		var/datum/reagent/the_cure = zomboid.reagents.has_reagent("zombiecure4")
		if(the_cure) // dead bodies dont process chemicals, so we gotta do it manually.
			zomboid.reagents.remove_reagent("zombiecure4", the_cure.metabolization_rate * zomboid.metabolism_efficiency)
			return
		zombie_rejuv()
		to_chat(zomboid, "<span class='zombielarge'>We... Awaken...</span>")
		zomboid.notify_ghost_cloning("Your zombie body has risen again, re-enter your corpse to continue the feast!", source = zomboid)

	// If no client, but they were a player thats not SSD (debrained, revived but hasn't returned to body, etc)
	if(zomboid.stat != CONSCIOUS || HAS_TRAIT(zomboid, TRAIT_HANDS_BLOCKED))
		return
	if(zomboid.client || isLivingSSD(zomboid))
		return
	if(HAS_TRAIT(zomboid, TRAIT_PLAGUE_ZOMBIE)) // dont want plague zombie NPCs
		return
	if((zomboid.last_known_ckey || HAS_TRAIT(zomboid, TRAIT_NPC_ZOMBIE)) && !zomboid.key) // make sure they were player inhabited and not admin ghosted
		mindless_hunger()

/datum/component/zombie_regen/proc/zombie_rejuv()
	var/mob/living/carbon/human/zomboid = parent
	zomboid.setToxLoss(0)
	zomboid.setOxyLoss(0)
	zomboid.setCloneLoss(0)
	zomboid.setBrainLoss(0)
	zomboid.setStaminaLoss(0)
	zomboid.SetSleeping(0)
	zomboid.SetParalysis(0, TRUE)
	zomboid.SetStunned(0, TRUE)
	zomboid.SetWeakened(0, TRUE)
	zomboid.SetSlowed(0)
	zomboid.SetImmobilized(0)
	zomboid.SetKnockDown(0)
	zomboid.SetLoseBreath(0)
	zomboid.SetDizzy(0)
	zomboid.SetJitter(0)
	zomboid.SetStuttering(0)
	zomboid.SetConfused(0)
	zomboid.SetDrowsy(0)
	zomboid.radiation = 0
	zomboid.SetDruggy(0)
	zomboid.SetHallucinate(0)
	zomboid.bodytemperature = 310
	zomboid.cure_blind()
	zomboid.cure_nearsighted()
	zomboid.CureMute()
	zomboid.CureDeaf()
	zomboid.CureEpilepsy()
	zomboid.CureParaplegia()
	zomboid.CureCoughing()
	zomboid.CureNervous()
	zomboid.SetEyeBlind(0)
	zomboid.SetEyeBlurry(0)
	zomboid.SetDeaf(0)
	zomboid.heal_overall_damage(1000, 1000)
	zomboid.ExtinguishMob()
	SEND_SIGNAL(zomboid, COMSIG_LIVING_CLEAR_STUNS)
	zomboid.fire_stacks = 0
	zomboid.on_fire = 0
	zomboid.suiciding = 0
	zomboid.set_nutrition(max(zomboid.nutrition, NUTRITION_LEVEL_HUNGRY))
	if(zomboid.buckled) //Unbuckle the mob and clear the alerts.
		zomboid.unbuckle(force = TRUE)

	var/datum/organ/heart/heart = zomboid.get_int_organ_datum(ORGAN_DATUM_HEART)
	var/heart_type = zomboid.dna?.species?.has_organ["heart"]
	if(!heart && heart_type)
		var/obj/item/organ/internal/new_heart = new heart_type()
		new_heart.insert(zomboid)

	var/datum/organ/lungs/lungs = zomboid.get_int_organ_datum(ORGAN_DATUM_LUNGS)
	var/lung_type = zomboid.dna?.species?.has_organ["lungs"]
	if(!lungs && lung_type)
		var/obj/item/organ/internal/new_lungs = new lung_type()
		new_lungs.insert(zomboid)

	zomboid.set_heartattack(FALSE)
	zomboid.restore_blood()
	zomboid.decaylevel = 0
	zomboid.remove_all_embedded_objects()

	zomboid.restore_all_organs()
	if(zomboid.stat == DEAD)
		zomboid.update_revive()
	else if(zomboid.stat == UNCONSCIOUS)
		zomboid.WakeUp()

	zomboid.update_fire()
	zomboid.regenerate_icons()
	zomboid.restore_blood()
	zomboid.update_eyes()

	for(var/datum/disease/critical/crit in zomboid.viruses) // cure all crit conditions
		crit.cure()

/datum/component/zombie_regen/proc/mindless_hunger()
	var/mob/living/carbon/human/zomboid = parent
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in view(6, zomboid))
		if(target.stat == CONSCIOUS && !HAS_TRAIT(target, TRAIT_I_WANT_BRAINS))
			targets |= target
			if(zomboid.Adjacent(target))
				break // we're just gonna hit em

	var/target
	if(length(targets))
		target = pick(targets)

	if(zomboid.Adjacent(target) && safe_active_hand(zomboid))
		if(!zomboid.get_active_hand())
			zomboid.put_in_hands(new /obj/item/zombie_claw())
		zomboid.a_intent = INTENT_HARM
		zomboid.ClickOn(target)
		return

	if(!target && prob(90)) // a small chance to wander
		return

	var/targetted_direction = pick(GLOB.cardinal)
	if(target)
		targetted_direction = get_dir(zomboid, target)

	var/delay = zomboid.movement_delay()
	if(IS_DIR_DIAGONAL(targetted_direction))
		delay *= SQRT_2
	zomboid.glide_for(delay)
	step(zomboid, targetted_direction)

/datum/component/zombie_regen/proc/safe_active_hand(mob/living/carbon/human/zomboid)
	if(zomboid.get_organ("[zomboid.hand ? "l" : "r" ]_hand"))
		return TRUE
	zomboid.swap_hand()
	if(zomboid.get_organ("[zomboid.hand ? "l" : "r" ]_hand"))
		return TRUE
	return FALSE

