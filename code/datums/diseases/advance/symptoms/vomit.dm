/*
//////////////////////////////////////

Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmissibility.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	stealth = -3
	stage_speed = -2
	transmissibility = 1
	level = 3
	severity = 3
	chem_treatments = list(
		"calomel" = list("multiplier" = 0, "timer" = 0),
		"charcoal" = list("multiplier" = 0, "timer" = 0),
		"pen_acid" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/vomit/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(A.progress > 20 && prob(A.progress))
		Vomit(M, A.progress)
	else
		switch(A.progress)
			if(0 to 59)
				to_chat(M, "<span class='warning'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>")
			if(60 to INFINITY)
				to_chat(M, "<span class='warning'>[pick("You feel extremely nauseous!", "You barely manage to not throw up!")]</span>")
	return

/datum/symptom/vomit/proc/Vomit(mob/living/carbon/M, progress)
	M.vomit(20 * (progress / 100))

/*
//////////////////////////////////////

Vomiting Blood

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Little transmissibility.
	Intense level.

Bonus
	Forces the affected mob to vomit blood!
	Meaning your disease can spread via
	people walking on the blood.
	Makes the affected mob lose health.

//////////////////////////////////////
*/

/datum/symptom/vomit/blood

	name = "Blood Vomiting"
	stealth = -2
	resistance = 2
	stage_speed = -3
	level = 4
	severity = 5

/datum/symptom/vomit/blood/Vomit(mob/living/carbon/M, progress)
	M.vomit(35 * ((progress / 100) ** 2), TRUE, TRUE, distance = 1)


/*
//////////////////////////////////////

Projectile Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmissibility.
	Medium Level.

Bonus
	As normal vomiting, except it will spread further,
	likely causing more to walk across the vomit.

//////////////////////////////////////
*/

/datum/symptom/vomit/projectile

	name = "Projectile Vomiting"
	stealth = -2
	resistance = 1
	level = 4
	severity = 4

/datum/symptom/vomit/projectile/Vomit(mob/living/carbon/M, progress)
	M.vomit(10 * ((progress / 100) ** 2), FALSE, TRUE, 6, 1)
