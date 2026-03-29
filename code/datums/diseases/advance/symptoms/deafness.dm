/*
//////////////////////////////////////

Deafness

	Slightly noticable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness
	name = "Deafness"
	stealth = 1
	stage_speed = -1
	transmissibility = -3
	level = 4
	severity = 3
	chem_treatments = list(
		"oculine" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/deafness/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	var/obj/item/organ/internal/ears/ears = M.get_organ_slot("ears")
	if(!ears)
		return //cutting off your ears to cure the deafness: the ultimate own
	switch(A.stage)
		if(3, 4)
			to_chat(M, SPAN_WARNING("[pick("You hear a ringing in your ear.", "Your ears pop.")]"))
		if(5)
			to_chat(M, SPAN_USERDANGER("Your ears pop and begin ringing loudly!"))
			M.Deaf(40 SECONDS * unmitigated)
