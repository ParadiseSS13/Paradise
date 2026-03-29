/// An OP chemical for admins
/datum/reagent/medicine/adminordrazine
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#600694"
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	taste_description = "admin abuse"

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0, FALSE)
	M.setOxyLoss(0, FALSE)
	M.radiation = 0
	M.adjustBruteLoss(-5, FALSE)
	M.adjustFireLoss(-5, FALSE)
	M.adjustToxLoss(-5, FALSE)
	M.setBrainLoss(0, FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/thing in H.internal_organs)
			var/obj/item/organ/internal/I = thing
			I.receive_damage(-5, FALSE)
		for(var/obj/item/organ/external/E in H.bodyparts)
			E.mend_fracture()
			E.fix_internal_bleeding()
			E.fix_burn_wound(update_health = FALSE)
	M.SetEyeBlind(0)
	M.cure_nearsighted(null, FALSE)
	M.cure_blind(null, FALSE)
	M.CureMute()
	M.CureDeaf()
	M.CureEpilepsy()
	M.CureCoughing()
	M.CureNervous()
	M.CureParaplegia()
	M.SetEyeBlurry(0)
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetImmobilized(0)
	M.SetKnockDown(0)
	M.adjustStaminaLoss(-60)
	M.SetParalysis(0)
	M.SetSilence(0)
	M.SetHallucinate(0)
	M.SetDizzy(0)
	M.SetDrowsy(0)
	M.SetStuttering(0)
	M.SetSlur(0)
	M.SetConfused(0)
	M.SetSleeping(0, FALSE)
	M.SetJitter(0)
	for(var/thing in M.viruses)
		var/datum/disease/D = thing
		if(D.severity == VIRUS_NONTHREAT)
			continue
		D.cure(0)
	..()
	if(M.dna?.species)
		// Set the temperature to the species's preferred temperature
		// For things like drasks, for example
		M.bodytemperature = M.dna.species.body_temperature
	else
		M.bodytemperature = BODYTEMP_NORMAL
	return STATUS_UPDATE_ALL

/datum/reagent/medicine/adminordrazine/nanites
	name = "Nanites"
	id = "nanites"
	description = "Nanomachines that aid in rapid cellular regeneration."
	taste_description = "nanomachines, son"
