/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 700
	health = 700
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	loudspeaker = TRUE
	mob_size = MOB_SIZE_LARGE
	bubble_icon = "alienroyal"
	ventcrawler = VENTCRAWLER_NONE
	move_resist = MOVE_FORCE_STRONG //Yes, big benos is huge and heavy
	alien_disarm_damage = 60 //Empress do higher disarm stamina damage than normal aliens
	alien_slash_damage = 30 //Empress do higher slashing damage to people

/mob/living/carbon/alien/humanoid/empress/large
	caste = "e"
	icon = 'icons/mob/alienhuge.dmi'
	icon_state = "empress_s"
	pixel_x = -32

/mob/living/carbon/alien/humanoid/empress/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "empress_dead"
	else if(stat == UNCONSCIOUS || IS_HORIZONTAL(src))
		icon_state = "empress_sleep"
	else
		icon_state = "empress_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/empress/Initialize(mapload)
	. = ..()
	//there should only be one queen
	ADD_TRAIT(src, TRAIT_FORCE_DOORS, UNIQUE_TRAIT_SOURCE(src))

/mob/living/carbon/alien/humanoid/empress/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/alien/plasmavessel/queen,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/eggsac,
		/obj/item/organ/internal/alien/resinspinner,
		/obj/item/organ/internal/alien/neurotoxin,
	)
