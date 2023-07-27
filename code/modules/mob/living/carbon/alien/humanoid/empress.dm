/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 900
	health = 900
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	mob_size = MOB_SIZE_LARGE
	bubble_icon = "alienroyal"
	large = 1
	ventcrawler = 0

/mob/living/carbon/alien/humanoid/empress/large
	name = "alien empress"
	caste = "e"
	icon = 'icons/mob/alienhuge.dmi'
	icon_state = "empress_s"
	pixel_x = -32

/mob/living/carbon/alien/humanoid/empress/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "empress_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "empress_sleep"
	else
		icon_state = "empress_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/empress/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/empress/E in GLOB.alive_mob_list)
		if(E == src)
			continue
		if(E.stat == DEAD)
			continue
		if(E.client)
			name = "alien grand princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = name
	..()


/mob/living/carbon/alien/humanoid/empress/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland/queen,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin
	)


/mob/living/carbon/alien/humanoid/empress/is_strong()
	return TRUE

