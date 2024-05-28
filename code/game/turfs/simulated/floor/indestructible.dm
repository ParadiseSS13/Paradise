/turf/simulated/floor/indestructible

/turf/simulated/floor/indestructible/ex_act(severity)
	return

/turf/simulated/floor/indestructible/blob_act(obj/structure/blob/B)
	return

/turf/simulated/floor/indestructible/singularity_act()
	return

/turf/simulated/floor/indestructible/singularity_pull(S, current_size)
	return

/turf/simulated/floor/indestructible/narsie_act()
	return

/turf/simulated/floor/indestructible/burn_down()
	return

/turf/simulated/floor/indestructible/attackby(obj/item/I, mob/user, params)
	return

/turf/simulated/floor/indestructible/attack_hand(mob/user)
	return

/turf/simulated/floor/indestructible/attack_hulk(mob/user, does_attack_animation = FALSE)
	return

/turf/simulated/floor/indestructible/attack_animal(mob/living/simple_animal/M)
	return

/turf/simulated/floor/indestructible/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/floor/indestructible/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturf = /turf/simulated/floor/indestructible/necropolis
	oxygen = 8
	nitrogen = 14
	temperature = 500
	planetary_atmos = TRUE
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/simulated/floor/indestructible/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/simulated/floor/indestructible/necropolis/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/// you put stone tiles on this and use it as a base
/turf/simulated/floor/indestructible/boss
	name = "necropolis floor"
	icon = 'icons/turf/floors/boss_floors.dmi'
	icon_state = "boss"
	baseturf = /turf/simulated/floor/indestructible/boss
	oxygen = 8
	nitrogen = 14
	temperature = 500
	planetary_atmos = TRUE

/turf/simulated/floor/indestructible/boss/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/simulated/floor/indestructible/hierophant
	name = "floor"
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	icon_state = "floor"
	oxygen = 8
	nitrogen = 14
	temperature = 500
	planetary_atmos = TRUE
	smoothing_flags = SMOOTH_CORNERS

/turf/simulated/floor/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/indestructible/hierophant/two
