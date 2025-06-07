/*
//////////////////////////////////////

Weight Loss

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced Transmittable.
	High level.

Bonus
	Decreases the weight of the mob,
	forcing it to be skinny.

//////////////////////////////////////
*/

/datum/symptom/weight_loss

	name = "Weight Loss"
	stealth = -2
	resistance = 1
	stage_speed = -2
	transmittable = -3
	level = 3
	severity = 4
	treatments = list("frostoil", "protein")

/datum/symptom/weight_loss/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(prob(A.progress))
			to_chat(M, "<span class='warning'><i>[pick("So hungry...", "You'd kill someone for a bite of food...", "Hunger cramps seize you...")]</i></span>")
			M.overeatduration = max(M.overeatduration - A.progress, 0)
			M.adjust_nutrition(-A.progress)
		else
			to_chat(M, "<span class='warning'>[pick("You feel hungry.", "You crave for food.")]</span>")

