
/mob/living/carbon/alien/humanoid/praetorian
	name = "alien praetorian"
	maxHealth = 250
	health = 250
	caste = "p"
	large = 1
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "alienp"
	pixel_x = -16
	pressure_resistance = 200

/mob/living/carbon/alien/humanoid/praetorian/large //adminspawn only, RP or events
	name = "alien praetorian"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "prat_s"
	pixel_x = -16
	maxHealth = 500
	health = 500
	large = 1

/mob/living/carbon/alien/humanoid/praetorian/large/update_icons()
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "prat_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "prat_sleep"
	else
		icon_state = "prat_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/praetorian/New()
	if(name == "alien praetorian")
		name = text("alien praetorian ([rand(1, 1000)])")
	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/queen
	alien_organs += new /obj/item/organ/internal/xenos/acidgland/large
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin/large
	..()

