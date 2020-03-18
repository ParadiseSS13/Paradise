/*
//////////////////////////////////////
Sensory-Restoration
	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal.
Bonus
	The body generates Sensory restorational chemicals.
	oculine for ears
	antihol for removal of alcohol
	synaptizine to purge sensory hallucigens
	mannitol to kickstart the mind

//////////////////////////////////////
*/
/datum/symptom/mind_restoration
	name = "Mind Restoration"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 0

/datum/symptom/mind_restoration/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 3))
		var/mob/living/M = A.affected_mob
		var/datum/reagents/RD = M.reagents

		if(A.stage >= 3)
			M.AdjustSlur(-2)
			M.AdjustDrunk(-4)
			M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3, 0, 1)
		if(A.stage >= 4)
			M.AdjustDrowsy(-2)
			if(RD.has_reagent("lsd"))
				RD.remove_reagent("lsd", 5)
			if(RD.has_reagent("histamine"))
				RD.remove_reagent("histamine", 5)
			M.AdjustHallucinate(-10)
		if(A.stage >= 5)
			RD.check_and_add("mannitol", 10, 10)

/datum/symptom/sensory_restoration
	name = "Sensory Restoration"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -4
	level = 4

/datum/symptom/sensory_restoration/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if(M.reagents.get_reagent_amount("oculine") < 20)
					M.reagents.add_reagent("oculine", 20)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					to_chat(M, "<span class='notice'>[pick("Your eyes feel great.","You feel like your eyes can focus more clearly.", "You don't feel the need to blink.","Your ears feel great.","Your healing feels more acute.")]</span>")
