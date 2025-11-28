/turf/simulated/floor/indestructible

/turf/simulated/floor/indestructible/update_icon_state()
	if(!broken && !burnt)
		icon_state = icon_regular_floor
	if(icon_regular_floor != icon_states(icon))
		icon_state = "plating"

/turf/simulated/floor/indestructible/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATTACK_BY, TYPE_PROC_REF(/datum, signal_cancel_attack_by))

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

/turf/simulated/floor/indestructible/attack_hand(mob/user)
	return

/turf/simulated/floor/indestructible/attack_hulk(mob/user, does_attack_animation = FALSE)
	return

/turf/simulated/floor/indestructible/attack_animal(mob/living/simple_animal/M)
	return

/turf/simulated/floor/indestructible/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/floor/indestructible/crowbar_act(mob/user, obj/item/I)
	return

/turf/simulated/floor/indestructible/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/indestructible/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon_state = "necro1"
	baseturf = /turf/simulated/floor/indestructible/necropolis
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA

/turf/simulated/floor/indestructible/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/simulated/floor/indestructible/necropolis/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	atmos_mode = ATMOS_MODE_SEALED
	atmos_environment = null

/// you put stone tiles on this and use it as a base
/turf/simulated/floor/indestructible/boss
	name = "necropolis floor"
	icon = 'icons/turf/floors/boss_floors.dmi'
	icon_state = "boss"
	baseturf = /turf/simulated/floor/indestructible/boss
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/indestructible/boss/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	atmos_mode = ATMOS_MODE_SEALED
	atmos_environment = null

/turf/simulated/floor/indestructible/hierophant
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	icon_state = "floor"
	oxygen = LAVALAND_OXYGEN
	nitrogen = LAVALAND_NITROGEN
	temperature = LAVALAND_TEMPERATURE
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND
	smoothing_flags = SMOOTH_CORNERS

/turf/simulated/floor/indestructible/hierophant/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	atmos_mode = ATMOS_MODE_SEALED
	atmos_environment = null

/turf/simulated/floor/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/indestructible/hierophant/two

/turf/simulated/floor/indestructible/hierophant/two/normal_air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	atmos_mode = ATMOS_MODE_SEALED
	atmos_environment = null
