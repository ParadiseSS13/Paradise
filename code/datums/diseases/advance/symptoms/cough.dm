/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	transmissibility.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	stealth = 2
	stage_speed = 1
	transmissibility = 2
	level = 1
	severity = 1
	chem_treatments = list(
		"salbutamol" = list("multiplier" = 0, "timer" = 0),
		"perfluorodecalin" = list("multiplier" = 0, "timer" = 0))

/datum/symptom/cough/symptom_act(datum/disease/advance/A, unmitigated)
	var/mob/living/M = A.affected_mob
	if(prob(A.progress + 20))
		M.emote("cough")
		var/obj/item/I = M.get_active_hand()
		if(prob(A.progress * unmitigated) && I && I.w_class == 1)
			M.drop_item()
		// smaller spread than sneeze
		A.spread(3 * unmitigated)
	else
		to_chat(M, "<span notice='warning'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>")
	return
