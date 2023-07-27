/datum/action/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	button_icon_state = "revive"
	req_stat = DEAD
	bypass_fake_death = TRUE

//Revive from regenerative stasis
/datum/action/changeling/revive/sting_action(var/mob/living/carbon/user)

	to_chat(user, span_changeling("We have regenerated."))

	REMOVE_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)

	for(var/obj/item/grab/grab in user.grabbed_by)
		var/mob/living/carbon/grab_owner = grab.assailant
		user.visible_message(span_warning("[user] suddenly hits [grab_owner] in the face and slips out of their grab!"))
		grab_owner.Stun(2 SECONDS) //Drops the grab
		grab_owner.apply_damage(5, BRUTE, "head", grab_owner.run_armor_check("head", "melee"))
		playsound(user.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)

	user.revive()
	user.updatehealth("revive sting")
	user.update_blind_effects()
	user.update_blurry_effects()
	user.UpdateAppearance() //Ensures that the user's appearance matches their DNA.
	user.regenerate_icons()
	user.lying = FALSE
	user.resting = FALSE
	user.update_canmove()
	user.update_revive() //Handle waking up the changeling after the regenerative stasis has completed.

	cling.regenerating = FALSE
	cling.acquired_powers -= src
	Remove(user)
	user.med_hud_set_status()
	user.med_hud_set_health()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

