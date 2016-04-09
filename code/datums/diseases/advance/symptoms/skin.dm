/*
//////////////////////////////////////
Vitiligo

	Extremely Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Reduces transmission.
	Critical Level.

BONUS
	Makes the mob lose skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/vitiligo

	name = "Vitiligo"
	stealth = -3
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 4
	severity = 1

/datum/symptom/vitiligo/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.s_tone == -85)
				return
			switch(A.stage)
				if(5)
					H.s_tone = -85
					H.update_body(0)
				else
					H.visible_message("<span class='warning'>[H] looks a bit pale...</span>", "<span class='notice'>Your skin suddenly appears lighter...</span>")

	return


/*
//////////////////////////////////////
Revitiligo

	Extremely Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Reduces transmission.
	Critical Level.

BONUS
	Makes the mob gain skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/revitiligo

	name = "Revitiligo"
	stealth = -3
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 4
	severity = 1

/datum/symptom/revitiligo/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.s_tone == 85)
				return
			switch(A.stage)
				if(5)
					H.s_tone = 85
					H.update_body(0)
				else
					H.visible_message("<span class='warning'>[H] looks a bit dark...</span>", "<span class='notice'>Your skin suddenly appears darker...</span>")

	return