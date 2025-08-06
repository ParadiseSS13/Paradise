/*
//////////////////////////////////////
Cranial Hypertrichosis

	Very very Noticeable.
	Decreases resistance slightly.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

BONUS
	Makes the mob grow massive hair, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/hair
	name = "Cranial Hypertrichosis"
	stealth = -1
	resistance = -1
	stage_speed = 1
	transmissibility = 1
	level = 4
	severity = 1

/datum/symptom/hair/symptom_act(datum/disease/advance/A, unmitigated)
	if(!ishuman(A.affected_mob))
		return
	var/mob/living/carbon/human/H = A.affected_mob
	if(H.dna.species.bodyflags & BALD)
		return
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(!istype(head_organ))
		return
	switch(A.stage)
		if(1, 2, 3)
			to_chat(H, "<span class='warning'>Your scalp itches.</span>")
			head_organ.h_style = random_hair_style(H.gender, head_organ.dna.species.name)
		else
			to_chat(H, "<span class='warning'>Hair bursts forth from your scalp!</span>")
			var/datum/sprite_accessory/tmp_hair_style = GLOB.hair_styles_full_list["Very Long Hair"]

			if(head_organ.dna.species.name in tmp_hair_style.species_allowed) //If 'Very Long Hair' is a style the person's species can have, give it to them.
				head_organ.h_style = "Very Long Hair"
			else //Otherwise, give them a random hair style.
				head_organ.h_style = random_hair_style(H.gender, head_organ.dna.species.name)
	H.update_hair()
