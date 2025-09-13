/datum/action/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	button_icon_state = "revive"
	req_dna = 1
	req_stat = DEAD
	bypass_fake_death = TRUE

//Revive from regenerative stasis
/datum/action/changeling/revive/sting_action(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_UNREVIVABLE))
		to_chat(user, "<span class='notice'>Something is preventing us from regenerating, we will need to revive at another point.</span>")
		return FALSE
	if(!HAS_TRAIT_FROM(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT))
		cling.acquired_powers -= src
		Remove(user)
		return
	REMOVE_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)
	for(var/obj/item/grab/G in user.grabbed_by)
		var/mob/living/carbon/M = G.assailant
		user.visible_message("<span class='warning'>[user] suddenly hits [M] in the face and slips out of their grab!</span>")
		M.Stun(2 SECONDS) //Drops the grab
		M.apply_damage(5, BRUTE, BODY_ZONE_HEAD, M.run_armor_check(BODY_ZONE_HEAD, MELEE))
		playsound(user.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	user.revive()
	user.updatehealth("revive sting")
	user.update_blind_effects()
	user.update_blurry_effects()
	cling.regenerating = FALSE
	user.UpdateAppearance() //Ensures that the user's appearance matches their DNA.

	to_chat(user, "<span class='notice'>We have regenerated.</span>")

	user.regenerate_icons()

	user.update_revive() //Handle waking up the changeling after the regenerative stasis has completed.
	cling.acquired_powers -= src
	Remove(user)
	user.med_hud_set_status()
	user.med_hud_set_health()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
