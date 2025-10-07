/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmissibility.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen

	name = "Hallucigen"
	stealth = -2
	stage_speed = -4
	transmissibility = 1
	level = 5
	severity = 3
	chem_treatments = list(
		"synaptizine" = list("multiplier" = 0, "timer" = 0),
		"ephedrine" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/hallucigen/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			to_chat(M, "<span class='warning'>[pick("Something appears in your peripheral vision, then winks out.", "You hear a faint whisper with no source.", "Your head aches.")]</span>")
		if(3, 4)
			to_chat(M, "<span class='warning'><b>[pick("Something is following you.", "You are being watched.", "You hear a whisper in your ear.", "Thumping footsteps slam toward you from nowhere.")]</b></span>")
		else
			to_chat(M, "<span class='userdanger'>[pick("Oh, your head...", "Your head pounds.", "They're everywhere! Run!", "Something in the shadows...")]</span>")
			M.AdjustHallucinate(5 SECONDS)

	return
