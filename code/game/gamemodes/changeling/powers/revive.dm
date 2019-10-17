/datum/action/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	button_icon_state = "revive"
	req_stat = DEAD
	always_keep = 1

//Revive from regenerative stasis
/datum/action/changeling/revive/sting_action(var/mob/living/carbon/user)
	user.setToxLoss(0, FALSE)
	user.setOxyLoss(0, FALSE)
	user.setCloneLoss(0, FALSE)
	user.setBrainLoss(0, FALSE)
	user.SetParalysis(0, FALSE)
	user.SetStunned(0, FALSE)
	user.SetWeakened(0, FALSE)
	user.radiation = 0
	user.SetEyeBlind(0, FALSE)
	user.SetEyeBlurry(0, FALSE)
	user.RestoreEars()
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss(), updating_health = FALSE)
	user.CureBlind(FALSE)
	user.CureDeaf()
	user.CureNearsighted(FALSE)
	user.reagents.clear_reagents()
	user.germ_level = 0
	user.timeofdeath = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.next_pain_time = 0
		H.dna.species.create_organs(H)
		// Now that recreating all organs is necessary, the rest of this organ stuff probably
		//  isn't, but I don't want to remove it, just in case.
		for(var/organ_name in H.bodyparts_by_name)
			var/obj/item/organ/external/O = H.bodyparts_by_name[organ_name]
			if(!O)
				continue
			O.brute_dam = 0
			O.burn_dam = 0
			O.damage_state = "00"
			O.germ_level = 0
			QDEL_NULL(O.hidden)
			O.open = 0
			O.internal_bleeding = FALSE
			O.perma_injury = 0
			O.status = 0
			O.trace_chemicals.Cut()
		for(var/obj/item/organ/internal/IO in H.internal_organs)
			IO.rejuvenate()
			IO.trace_chemicals.Cut()
		H.remove_all_embedded_objects()
	for(var/datum/disease/critical/C in user.viruses)
		C.cure()
	user.status_flags &= ~(FAKEDEATH)
	user.updatehealth("revive sting")
	user.update_blind_effects()
	user.update_blurry_effects()
	user.mind.changeling.regenerating = FALSE
	user.UpdateAppearance() //Ensures that the user's appearance matches their DNA.

	to_chat(user, "<span class='notice'>We have regenerated.</span>")

	user.regenerate_icons()

	user.update_revive() //Handle waking up the changeling after the regenerative stasis has completed.
	src.Remove(user)
	user.med_hud_set_status()
	user.med_hud_set_health()
	feedback_add_details("changeling_powers","CR")
	return 1
