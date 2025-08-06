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
	stage_speed = 1
	transmissibility = 2
	level = 4
	severity = 1
	chem_treatments = list(
		"synthflesh" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/vitiligo/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.s_tone == 85)
			return
		switch(A.stage)
			if(5)
				H.change_skin_tone(85, TRUE)
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
	transmissibility = -2
	level = 4
	severity = 1
	chem_treatments = list(
		"synthflesh" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/revitiligo/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.s_tone == -85)
			return
		switch(A.stage)
			if(5)
				H.change_skin_tone(-85, TRUE)
			else
				H.visible_message("<span class='warning'>[H] looks a bit dark...</span>", "<span class='notice'>Your skin suddenly appears darker...</span>")

	return
