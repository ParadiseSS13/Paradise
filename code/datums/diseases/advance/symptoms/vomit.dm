/*
//////////////////////////////////////

Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmittable.
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
	resistance = 0
	stage_speed = -2
	transmittable = 1
	level = 3
	severity = 3
	treatments = list("calomel" , "charcoal", "pen_acid")

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
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
	Little transmittable.
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
	transmittable = 0
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
	Little transmittable.
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
	stage_speed = -2
	transmittable = 0
	level = 5
	severity = 4

/datum/symptom/vomit/projectile/Vomit(mob/living/carbon/M, progress)
	M.vomit(10 * ((progress / 100) ** 2), FALSE, TRUE, 6, 1)
