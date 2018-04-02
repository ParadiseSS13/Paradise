/mob/living/carbon/human/interactive/away
	var/away_area = /area/awaymission   // their overriden job area
	var/override_under = null		   // optional type for uniform, else default for job
	var/squad_member = 0				// was spawned by squad
	var/home_z

/mob/living/carbon/human/interactive/away/New()
	..()
	TRAITS |= TRAIT_ROBUST
	faction += "away"

/mob/living/carbon/human/interactive/away/random()
	if(ispath(override_under, /obj/item/clothing/under))
		equip_to_slot(new override_under(src), slot_w_uniform)
	..()

/mob/living/carbon/human/interactive/away/doSetup()
	..()
	var/datum/data/pda/app/messenger/M = MYPDA.find_program(/datum/data/pda/app/messenger)
	M.toff = 1
	var/datum/data/pda/app/chatroom/C = MYPDA.find_program(/datum/data/pda/app/chatroom)
	C.toff = 1

/mob/living/carbon/human/interactive/away/job2area()
	return away_area

/mob/living/carbon/human/interactive/away/doProcess()
	if(!home_z)
		home_z = get_turf(z)
	if(home_z != get_turf(z))
		gib()
	..()
