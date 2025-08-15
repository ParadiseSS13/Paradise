/*
//////////////////////////////////////

Weight Loss

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmissibility.
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
	transmissibility = -3
	level = 3
	severity = 4
	chem_treatments = list(
		"frostoil" = list("multiplier" = 0, "timer" = 0),
		"protein" = list("multiplier" = 0.8, "timer" = 0),
		"sugar" = list("multiplier" = 0.9, "timer" = 0),
		"plantmatter" = list("multiplier" = 0.9, "timer" = 0),
		"vitamin" = list("multiplier" = 0.8, "timer" = 0)
		)

/datum/symptom/weight_loss/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(prob(A.progress))
		to_chat(M, "<span class='warning'><i>[pick("So hungry...", "You'd kill someone for a bite of food...", "Hunger cramps seize you...")]</i></span>")
		M.overeatduration = max(M.overeatduration - A.progress * unmitigated, 0)
		M.adjust_nutrition(-A.progress * unmitigated)
	else
		to_chat(M, "<span class='warning'>[pick("You feel hungry.", "You crave for food.")]</span>")

