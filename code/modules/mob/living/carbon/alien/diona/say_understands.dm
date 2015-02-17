/mob/living/carbon/alien/diona/say_understands(var/mob/other,var/datum/language/speaking = null)

	if (istype(other, /mob/living/carbon/human) && !speaking)
		if(languages.len >= 2) // They have sucked down some blood.
			return 1
	return ..()