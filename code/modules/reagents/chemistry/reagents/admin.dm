/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	can_synth = FALSE
	taste_description = "admin abuse"

/datum/reagent/medicine/adminordrazine/on_new(data)
	..()
	START_PROCESSING(SSprocessing, src)

/datum/reagent/medicine/adminordrazine/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/reagent/medicine/adminordrazine/process()
	if(..())
		if(istype(holder.my_atom, /mob/living/carbon))
			var/mob/living/carbon/M = holder.my_atom
			current_cycle++
			var/total_depletion_rate = (metabolization_rate / M.metabolism_efficiency) * M.digestion_ratio

			M.setCloneLoss(0, TRUE)
			M.setOxyLoss(0, TRUE)
			M.radiation = 0
			M.adjustBruteLoss(-5, TRUE)
			M.adjustFireLoss(-5, TRUE)
			M.adjustToxLoss(-5, TRUE)
			M.setBrainLoss(0, TRUE)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!H.bleedsuppress)
					H.suppress_bloodloss(volume * 8)
				H.set_heartattack(FALSE)
				for(var/thing in H.internal_organs)
					var/obj/item/organ/internal/I = thing
					I.receive_damage(-5, FALSE)
				for(var/obj/item/organ/external/E in H.bodyparts)
					E.mend_fracture()
					E.internal_bleeding = FALSE
				if(!(NO_BLOOD in H.dna.species.species_traits))//do not restore blood on things with no blood by nature.
					if(H.blood_volume < BLOOD_VOLUME_NORMAL)
						H.blood_volume += 15
			M.SetEyeBlind(0, TRUE)
			M.cure_nearsighted(null, TRUE)
			M.cure_blind(null, TRUE)
			M.CureMute()
			M.CureDeaf()
			M.CureEpilepsy()
			M.CureTourettes()
			M.CureCoughing()
			M.CureNervous()
			M.SetEyeBlurry(0, TRUE)
			M.SetWeakened(0, TRUE)
			M.SetStunned(0, TRUE)
			M.SetParalysis(0, TRUE)
			M.SetSilence(0, TRUE)
			M.SetHallucinate(0)
			REMOVE_TRAITS_NOT_IN(M, list(ROUNDSTART_TRAIT, SPECIES_TRAIT))
			M.SetDizzy(0)
			M.SetDrowsy(0)
			M.SetStuttering(0)
			M.SetSlur(0)
			M.SetConfused(0)
			M.SetSleeping(0, TRUE)
			M.SetJitter(0)
			for(var/thing in M.viruses)
				var/datum/disease/D = thing
				if(D.severity == NONTHREAT)
					continue
				D.cure(0)

			if(M.stat == DEAD && M.health > HEALTH_THRESHOLD_DEAD)
				if(!M.suiciding && !HAS_TRAIT(M, TRAIT_HUSK) && !HAS_TRAIT(M, TRAIT_BADDNA))
					M.grab_ghost()
					if(M.update_revive())
						M.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")
						add_attack_logs(M, M, "Revived with [name]") //Yes, the logs say you revived yourself.

			holder.remove_reagent(id, total_depletion_rate)

/datum/reagent/medicine/adminordrazine/nanites
	name = "Nanites"
	id = "nanites"
	description = "Nanomachines that aid in rapid cellular regeneration."
	taste_description = "nanomachines, son"
