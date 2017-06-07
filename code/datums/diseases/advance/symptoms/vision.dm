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
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 4

/datum/symptom/visionloss/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		var/obj/item/organ/internal/eyes/eyes = M.get_int_organ(/obj/item/organ/internal/eyes)
		if(!eyes) //NO EYES, NO PROBLEM! Rip out your eyes today to prevent future blindness!
			return
		switch(A.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>Your eyes itch.</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>Your eyes burn!</b></span>")
				M.EyeBlurry(20)
				eyes.take_damage(1)
			else
				to_chat(M, "<span class='userdanger'>Your eyes burn horrificly!</span>")
				M.EyeBlurry(30)
				eyes.take_damage(5)
				if(eyes.damage >= 10)
					M.BecomeNearsighted()
					if(prob(eyes.damage - 10 + 1))
						if(M.BecomeBlind())
							to_chat(M, "<span class='userdanger'>You go blind!</span>")


/*
//////////////////////////////////////

Ocular Restoration

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	High level.

Bonus
	Restores eyesight.

//////////////////////////////////////
*/

/datum/symptom/visionaid

	name = "Ocular Restoration"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -4
	level = 4

/datum/symptom/visionaid/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if(M.reagents.get_reagent_amount("oculine") < 20)
					M.reagents.add_reagent("oculine", 20)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					to_chat(M, "<span class='notice'>[pick("Your eyes feel great.", "You are now blinking manually.", "You don't feel the need to blink.")]</span>")
	return
