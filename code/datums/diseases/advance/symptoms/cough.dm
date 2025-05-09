/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmittable.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	stealth = 2
	resistance = 0
	stage_speed = 1
	transmittable = 2
	level = 1
	severity = 1
	treatments = list("salbutamol", "perfluorodecalin")

/datum/symptom/cough/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(prob(A.progress + 20))
			M.emote("cough")
			var/obj/item/I = M.get_active_hand()
			if(prob(A.progress) && I && I.w_class == 1)
				M.drop_item()
			// smaller spread than sneeze
			A.spread(3)
		else
			to_chat(M, "<span notice='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
	return
