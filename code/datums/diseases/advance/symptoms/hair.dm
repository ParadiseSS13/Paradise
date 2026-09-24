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
			to_chat(H, SPAN_WARNING("Your scalp itches."))
			head_organ.h_style = random_hair_style(head_organ.dna.species.name)
		else
			to_chat(H, SPAN_WARNING("Hair bursts forth from your scalp!"))
			var/tmp_hair_style = "Very Long Hair"
			switch(head_organ.dna.species.name)
				if("Diona")
					tmp_hair_style = "Spanish Moss"
				if("Kidan")
					tmp_hair_style = "Hawk Horn"
				if("Skkulakin")
					tmp_hair_style = "Brewmaster"
				if("Skrell")
					tmp_hair_style = "Long Skrell Tentacles"
				if("Tajaran")
					tmp_hair_style = "Tajara Long Tail"
				if("Vox")
					tmp_hair_style = "Long Vox Quills"
			head_organ.h_style = tmp_hair_style
	H.update_hair()
