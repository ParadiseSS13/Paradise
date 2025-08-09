/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	stealth = 2
	resistance = 1
	stage_speed = -1
	transmissibility = -4
	level = 5
	severity = 4
	chem_treatments = list(
		"oculine" = list("multiplier" = 0, "timer" = 0)
		)

/datum/symptom/visionloss/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/carbon/M = A.affected_mob
	var/obj/item/organ/internal/eyes/eyes = M.get_int_organ(/obj/item/organ/internal/eyes)
	if(!eyes) //NO EYES, NO PROBLEM! Rip out your eyes today to prevent future blindness!
		return
	switch(A.stage)
		if(1, 2)
			to_chat(M, "<span class='warning'>Your eyes itch.</span>")
		if(3, 4)
			to_chat(M, "<span class='warning'><b>Your eyes burn!</b></span>")
			M.EyeBlurry(40 SECONDS * unmitigated)
			eyes.receive_damage(1 * unmitigated)
		else
			to_chat(M, "<span class='userdanger'>Your eyes burn horrificly!</span>")
			M.EyeBlurry(60 SECONDS * unmitigated)
			eyes.receive_damage(5 * unmitigated)
			if(eyes.damage >= 10)
				M.become_nearsighted(EYE_DAMAGE)
				if(prob(eyes.damage - 10 + 1) * unmitigated)
					if(!M.AmountBlinded())
						to_chat(M, "<span class='userdanger'>You go blind!</span>")
						eyes.receive_damage(eyes.max_damage)
