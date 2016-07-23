/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	req_stat = DEAD

//Revive from regenerative stasis
/obj/effect/proc_holder/changeling/revive/sting_action(var/mob/living/carbon/user)
	if(user.stat == DEAD)
		dead_mob_list -= user
		living_mob_list |= user
	user.stat = CONSCIOUS
	user.setToxLoss(0)
	user.setOxyLoss(0)
	user.setCloneLoss(0)
	user.setBrainLoss(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.radiation = 0
	user.eye_blind = 0
	user.eye_blurry = 0
	user.setEarDamage(0,0)
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss())
	user.reagents.clear_reagents()
	user.germ_level = 0
	user.next_pain_time = 0
	user.traumatic_shock = 0
	user.timeofdeath = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.shock_stage = 0
		spawn(1)
			H.fixblood()
		H.species.create_organs(H)
		// Now that recreating all organs is necessary, the rest of this organ stuff probably
		//  isn't, but I don't want to remove it, just in case.
		for(var/organ_name in H.organs_by_name)
			var/obj/item/organ/external/O = H.organs_by_name[organ_name]
			if(!O) continue
			for(var/obj/item/weapon/shard/shrapnel/s in O.implants)
				if(istype(s))
					O.implants -= s
					H.contents -= s
					qdel(s)
			O.brute_dam = 0
			O.burn_dam = 0
			O.damage_state = "00"
			O.germ_level = 0
			O.hidden = null
			O.number_wounds = 0
			O.open = 0
			O.perma_injury = 0
			O.stage = 0
			O.status = 0
			O.trace_chemicals = list()
			O.wounds = list()
			O.wound_update_accuracy = 1
		for(var/obj/item/organ/internal/IO in H.internal_organs)
			IO.damage = 0
			IO.trace_chemicals = list()
		H.updatehealth()
	to_chat(user, "<span class='notice'>We have regenerated.</span>")

	user.regenerate_icons()

	user.status_flags &= ~(FAKEDEATH)
	user.update_canmove()
	user.mind.changeling.purchasedpowers -= src
	user.med_hud_set_status()
	user.med_hud_set_health()
	feedback_add_details("changeling_powers","CR")
	return 1
