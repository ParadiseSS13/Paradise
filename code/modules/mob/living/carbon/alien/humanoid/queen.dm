/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 250
	health = 250
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	loudspeaker = TRUE
	heal_rate = 5
	large = 1
	ventcrawler = VENTCRAWLER_NONE
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	move_resist = MOVE_FORCE_STRONG //Yes, queenos is huge and heavy
	alien_disarm_damage = 60 //Queens do higher disarm stamina damage than normal aliens
	alien_slash_damage = 30 //Queens do higher slashing damage to people
	alien_movement_delay = 1 //This represents a movement delay of 1, or roughly 80% the movement speed of a normal carbon mob

/mob/living/carbon/alien/humanoid/queen/Initialize(mapload)
	. = ..()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
		if(Q == src)
			ADD_TRAIT(Q, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
			continue
		if(Q.stat == DEAD)
			ADD_TRAIT(Q, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name

/mob/living/carbon/alien/humanoid/queen/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/alien/plasmavessel/queen,
		/obj/item/organ/internal/alien/acidgland,
		/obj/item/organ/internal/alien/eggsac,
		/obj/item/organ/internal/alien/resinspinner,
		/obj/item/organ/internal/alien/neurotoxin,
	)

/mob/living/carbon/alien/humanoid/queen/deathrattle_message()
	return "<i><span class='alien reallybig'>A shock reverberates through the hive; [name] has been slain!</span></i>"

/mob/living/carbon/alien/humanoid/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick)
	return FALSE

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	large = 1

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "queen_dead"
	else if(stat == UNCONSCIOUS || IS_HORIZONTAL(src))
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"

	for(var/image/I in overlays_standing)
		overlays += I
