
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
	if(zomboid.reagents.has_reagent("zombiecure3"))
		healing_factor /= 3
	if(zomboid.stat == DEAD)
		healing_factor *= 2
	zomboid.heal_overall_damage(healing_factor, healing_factor)
	zomboid.adjustBrainLoss(-healing_factor)
	if(zomboid.stat == DEAD && zomboid.getBruteLoss() <= 1 && zomboid.getFireLoss() <= 1 && (zomboid.timeofdeath + 30 SECONDS <= world.time))
		var/datum/reagent/the_cure = zomboid.reagents.has_reagent("zombiecure4")
		if(the_cure) // dead bodies dont process chemicals, so we gotta do it manually.
			zomboid.reagents.remove_reagent("zombiecure4", the_cure.metabolization_rate * zomboid.metabolism_efficiency)
			return
		zombie_rejuv()
		to_chat(zomboid, "<span class='zombielarge'>We... Awaken...</span>")

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
	zomboid.CureTourettes()
	zomboid.CureEpilepsy()
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
	if(zomboid.buckled) //Unbuckle the mob and clear the alerts.
		zomboid.buckled.unbuckle_mob(src, force = TRUE)

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
	zomboid.update_dna()

	for(var/datum/disease/critical/crit in zomboid.viruses) // cure all crit conditions
		crit.cure()
