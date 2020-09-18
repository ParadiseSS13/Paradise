/datum/martial_art/plasma_fist
	name = "Plasma Fist"
	combos = list(/datum/martial_combo/plasma_fist/tornado_sweep, /datum/martial_combo/plasma_fist/throwback, /datum/martial_combo/plasma_fist/plasma_fist)
	has_explaination_verb = TRUE

/datum/martial_art/plasma_fist/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(A,D)
	return TRUE

/datum/martial_art/plasma_fist/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(A,D)
	return TRUE

/datum/martial_art/plasma_fist/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(A,D)
	return TRUE

/datum/martial_art/plasma_fist/explaination_header(user)
	to_chat(user, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")
