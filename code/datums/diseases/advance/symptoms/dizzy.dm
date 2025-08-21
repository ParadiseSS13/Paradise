/*
//////////////////////////////////////

Dizziness

	Hidden.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

Bonus
	Shakes the affected mob's screen for short periods.

//////////////////////////////////////
*/

/// Not the egg
/datum/symptom/dizzy

	name = "Dizziness"
	stealth = 2
	stage_speed = -1
	transmissibility = -1
	level = 4
	severity = 2
	chem_treatments = list(
		"antihol" = list("multiplier" = 0, "timer" = 0),
		"ephedrine" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/dizzy/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			to_chat(M, "<span class='warning'>[pick("You feel dizzy.", "Your head spins.")]</span>")
		else
			to_chat(M, "<span class='userdanger'>A wave of dizziness washes over you!</span>")
			M.Dizzy(10 SECONDS * unmitigated)
	return
