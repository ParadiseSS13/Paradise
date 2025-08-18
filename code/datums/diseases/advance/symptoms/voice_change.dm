/*
//////////////////////////////////////

Voice Change

	Very Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmissibility.
	Fatal Level.

Bonus
	Changes the voice of the affected mob. Causing confusion in communication.

//////////////////////////////////////
*/

/datum/symptom/voice_change

	name = "Voice Change"
	stealth = 2
	resistance = -3
	stage_speed = 3
	transmissibility = -2
	level = 6
	severity = 2
	chem_treatments = list(
		"honey" = list("multiplier" = 0, "timer" = 0),
		"lemonjuice" = list("multiplier" = 0, "timer" = 0),
		"orangejuice" = list("multiplier" = 0, "timer" = 0),
		"tea" = list("multiplier" = 0, "timer" = 0),
		)

/datum/symptom/voice_change/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			to_chat(M, "<span class='warning'>[pick("Your throat hurts.", "You clear your throat.")]</span>")
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.SetSpecialVoice(H.dna.species.get_random_name(H.gender))
	return

/datum/symptom/voice_change/post_treatment(datum/disease/advance/A, unmitigated)
	if(!unmitigated)
		End()

/datum/symptom/voice_change/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.UnsetSpecialVoice()
	return
