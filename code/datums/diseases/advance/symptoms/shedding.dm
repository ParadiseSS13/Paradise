/*
//////////////////////////////////////
Alopecia

	Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Transmittable.
	Intense Level.

BONUS
	Makes the mob lose hair.

//////////////////////////////////////
*/

/datum/symptom/shedding

	name = "Alopecia"
	stealth = -1
	resistance = -1
	stage_speed = -1
	transmittable = 2
	level = 4
	severity = 1

/datum/symptom/shedding/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		to_chat(M, "<span class='warning'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>")
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/head/head_organ = H.get_organ("head")
			switch(A.stage)
				if(3, 4)
					if(!(head_organ.h_style == "Bald") && !(head_organ.h_style == "Balding Hair"))
						to_chat(H, "<span class='warning'>Your hair starts to fall out in clumps...</span>")
						spawn(50)
							head_organ.h_style = "Balding Hair"
							H.update_hair()
				if(5)
					if(!(head_organ.f_style == "Shaved") || !(head_organ.h_style == "Bald"))
						to_chat(H, "<span class='warning'>Your hair starts to fall out in clumps...</span>")
						spawn(50)
							head_organ.f_style = "Shaved"
							head_organ.h_style = "Bald"
							H.update_hair()
							H.update_fhair()
	return
