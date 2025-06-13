/*
//////////////////////////////////////
Facial Hypertrichosis

	Very very Noticable.
	Decreases resistance slightly.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	stealth = -1
	resistance = 0
	stage_speed = 2
	transmittable = -1
	level = 4
	severity = 1

/datum/symptom/beard/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/head/head_organ = H.get_organ("head")
			if(!istype(head_organ))
				return
			switch(A.stage)
				if(1, 2)
					to_chat(H, "<span class='warning'>Your chin itches.</span>")
					if(head_organ.f_style == "Shaved")
						head_organ.f_style = "Jensen Beard"
						H.update_fhair()
				if(3, 4)
					to_chat(H, "<span class='warning'>You feel tough.</span>")
					if(!(head_organ.f_style == "Dwarf Beard") && !(head_organ.f_style == "Very Long Beard") && !(head_organ.f_style == "Full Beard"))
						head_organ.f_style = "Full Beard"
						H.update_fhair()
				else
					to_chat(H, "<span class='warning'>You feel manly!</span>")
					if(!(head_organ.f_style == "Dwarf Beard") && !(head_organ.f_style == "Very Long Beard"))
						head_organ.f_style = pick("Dwarf Beard", "Very Long Beard")
						H.update_fhair()
	return
