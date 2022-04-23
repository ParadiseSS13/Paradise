/datum/action/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	button_icon_state = "revive"
	req_stat = DEAD
	always_keep = 1

//Revive from regenerative stasis
/datum/action/changeling/revive/sting_action(mob/living/carbon/user)
	REMOVE_TRAIT(user, TRAIT_FAKEDEATH, "changeling")
	for(var/obj/item/grab/G in user.grabbed_by)
		var/mob/living/carbon/M = G.assailant
		user.visible_message("<span class='warning'>[user] suddenly hits [M] in the face and slips out of their grab!</span>")
		M.Stun(1) //Drops the grab
		M.apply_damage(5, BRUTE, "head", M.run_armor_check("head", "melee"))
		playsound(user.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)
	user.revive()
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
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return 1
