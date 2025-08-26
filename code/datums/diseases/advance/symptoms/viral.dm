/*
//////////////////////////////////////
Viral adaptation

	Moderate stealth boost.
	Major Increases to resistance.
	Reduces stage speed.
	No change to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viraladaptation
	name = "Viral self-adaptation"
	stealth = 3
	resistance = 3
	stage_speed = -2
	level = 3

/datum/symptom/viraladaptation/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			to_chat(M, "<span class='notice'>You feel off, but no different from before.</span>")
		if(5)
			to_chat(M, "<span class='notice'>You feel better, but nothing interesting happens.</span>")

/*
//////////////////////////////////////
Viral evolution

	Moderate stealth reductopn.
	Major decreases to resistance.
	increases stage speed.
	increase to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viralevolution
	name = "Viral evolutionary acceleration"
	stealth = -4
	stage_speed = 5
	transmissibility = 3
	level = 3
	var/static/list/possible_blocks

/datum/symptom/viralevolution/Start(datum/disease/advance/A)
	. = ..()
	A.evolution_chance *= 1.5
	possible_blocks = list(GLOB.hornsblock, GLOB.loudblock, GLOB.comicblock, GLOB.swedeblock, GLOB.chavblock, GLOB.nervousblock, GLOB.lispblock)

/datum/symptom/viralevolution/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(prob(A.progress * 2))
		// randomly set the value of a minor disability block
		to_chat(M, "<span class='notice'>You feel like something is changing</span>")
		A.affected_mob.dna.SetSEValue(pick(possible_blocks), rand(0, 4095))
		domutcheck(A.affected_mob)
	else
		to_chat(M, "<span class='notice'>You feel a weird</span>")

