/turf/simulated/wall/indestructible

/turf/simulated/wall/indestructible/dismantle_wall(devastated = 0, explode = 0)
	return

/turf/simulated/wall/indestructible/take_damage(dam)
	return

/turf/simulated/wall/indestructible/welder_act()
	return

/turf/simulated/wall/indestructible/ex_act(severity)
	return

/turf/simulated/wall/indestructible/blob_act(obj/structure/blob/B)
	return

/turf/simulated/wall/indestructible/singularity_act()
	return

/turf/simulated/wall/indestructible/singularity_pull(S, current_size)
	return

/turf/simulated/wall/indestructible/narsie_act()
	return

/turf/simulated/wall/indestructible/ratvar_act(force, ignore_mobs)
	return

/turf/simulated/wall/indestructible/burn_down()
	return

/turf/simulated/wall/indestructible/attackby(obj/item/I, mob/user, params)
	return

/turf/simulated/wall/indestructible/attack_hand(mob/user)
	return

/turf/simulated/wall/indestructible/attack_animal(mob/living/simple_animal/M)
	return

/turf/simulated/wall/indestructible/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/wall/indestructible/necropolis
	name = "necropolis wall"
	desc = "A seemingly impenetrable wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "necro"
	explosion_block = 50
	baseturf = /turf/simulated/wall/indestructible/necropolis

/turf/simulated/wall/indestructible/boss
	name = "necropolis wall"
	desc = "A thick, seemingly indestructible stone wall."
	icon = 'icons/turf/walls/boss_wall.dmi'
	icon_state = "boss_wall-0"
	base_icon_state = "boss_wall"
	smoothing_flags = SMOOTH_BITMASK
	explosion_block = 50
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_BOSS_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_BOSS_WALLS)
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
/turf/simulated/wall/indestructible/boss/see_through
	opacity = FALSE

/turf/simulated/wall/indestructible/hierophant
	name = "wall"
	desc = "A wall made out of a strange metal. The squares on it pulse in a predictable pattern."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "wall"
	smoothing_flags = SMOOTH_CORNERS

/turf/simulated/wall/indestructible/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_URANIUM_WALLS)
