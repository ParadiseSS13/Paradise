/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 175
	health = 175
	icon_state = "aliens_s"
	surgery_container = /datum/xenobiology_surgery_container/alien/sentinel

/mob/living/carbon/alien/humanoid/sentinel/large
	name = "alien praetorian"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "prat_s"
	pixel_x = -16
	maxHealth = 200
	health = 200

/mob/living/carbon/alien/humanoid/sentinel/large/update_icons()
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "prat_dead"
	else if(stat == UNCONSCIOUS || IS_HORIZONTAL(src))
		icon_state = "prat_sleep"
	else
		icon_state = "prat_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/sentinel/Initialize(mapload)
	. = ..()
	name = "alien sentinel ([rand(1, 1000)])"
	real_name = name

/mob/living/carbon/alien/humanoid/sentinel/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/alien/plasmavessel,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/neurotoxin,
	)
