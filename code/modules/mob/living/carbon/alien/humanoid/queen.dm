/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 640
	health = 640
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	large = 1
	ventcrawler = 0
	attack_damage = 30
	disarm_stamina_damage = 34
	armour_penetration = 30
	obj_damage = 80
	time_to_open_doors = 0.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	tts_seed = "Queen"

/mob/living/carbon/alien/humanoid/queen/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	grant_all_babel_languages()
	..()


/mob/living/carbon/alien/humanoid/queen/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland/queen,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin
	)

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	. = ..()
	. += 3

/mob/living/carbon/alien/humanoid/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	return FALSE

/mob/living/carbon/alien/humanoid/queen/is_strong()
	return TRUE

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	large = 1
	var/datum/action/innate/small_sprite_alien/action_sprite


/mob/living/carbon/alien/humanoid/queen/large/New()
	action_sprite = new
	action_sprite.Grant(src)
	..()


/mob/living/carbon/alien/humanoid/queen/large/Destroy()
	if(action_sprite)
		action_sprite.Remove(src)
		action_sprite = null
	return ..()


/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "queen_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"

	for(var/image/I in overlays_standing)
		overlays += I
