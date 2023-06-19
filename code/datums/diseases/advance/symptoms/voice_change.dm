/*
//////////////////////////////////////

Voice Change

	Very Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Fatal Level.

Bonus
	Changes the voice of the affected mob. Causing confusion in communication.

//////////////////////////////////////
*/

/datum/symptom/voice_change

	name = "Voice Change"
	id = "voice_change"
	stealth = -2
	resistance = -3
	stage_speed = -3
	transmittable = -1
	level = 6
	severity = 2

/datum/symptom/voice_change/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))

		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(M, "<span class='warning'>[pick("Your throat hurts.", "You clear your throat.")]</span>")
			else
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.SetSpecialVoice(H.dna.species.get_random_name(H.gender))
					H.SetSpecialTTSVoice(SStts.get_random_seed(H))

	return

/datum/symptom/voice_change/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.UnsetSpecialVoice()
		H.UnsetSpecialTTSVoice()
	return
