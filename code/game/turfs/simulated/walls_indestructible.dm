/turf/simulated/wall/indestructible
	name = "wall"
	desc = "Effectively impervious to conventional methods of destruction."
	explosion_block = 50

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

/turf/simulated/wall/indestructible/attack_hulk(mob/user, does_attack_animation = FALSE)
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
	baseturf = /turf/simulated/wall/indestructible/necropolis

/turf/simulated/wall/indestructible/boss
	name = "necropolis wall"
	desc = "A thick, seemingly indestructible stone wall."
	icon = 'icons/turf/walls/boss_wall.dmi'
	icon_state = "wall"
	canSmoothWith = list(/turf/simulated/wall/indestructible/boss, /turf/simulated/wall/indestructible/boss/see_through)
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	smooth = SMOOTH_TRUE

/turf/simulated/wall/indestructible/boss/see_through
	opacity = FALSE

/turf/simulated/wall/indestructible/hierophant
	name = "wall"
	desc = "A wall made out of a strange metal. The squares on it pulse in a predictable pattern."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	icon_state = "wall"
	smooth = SMOOTH_TRUE

/turf/simulated/wall/indestructible/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"

/turf/simulated/wall/indestructible/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"

/turf/simulated/wall/indestructible/riveted
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"

/turf/simulated/wall/indestructible/syndicate
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle"
	smooth = SMOOTH_MORE | SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/simulated/wall/mineral/plastitanium, /turf/simulated/wall/indestructible/syndicate, /obj/machinery/door/airlock/titanium, /obj/machinery/door/airlock, /obj/structure/shuttle/engine, /obj/structure/falsewall/plastitanium)

/turf/simulated/wall/indestructible/pt_wall
	name = "reinforced wall"
	desc = "An evil wall of plasma and titanium. This one looks heavily reinforced."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle_nd"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/simulated/wall/indestructible/pt_wall,
						/obj/machinery/door/airlock)

/turf/simulated/wall/indestructible/pt_window
	name = "reinforced plastitanium window"
	desc = "An evil looking window of plasma and titanium. This one looks heavily reinforced."
	icon = 'icons/turf/walls.dmi'
	icon_state = "fakewindows_p"
	opacity = 0
	layer = ABOVE_OBJ_LAYER
	level = 3

/turf/simulated/wall/indestructible/rock/asteroid
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/simulated/wall/indestructible/rock/asteroid,
						/turf/simulated/mineral/asteroid)
	layer = EDGED_TURF_LAYER

/turf/simulated/wall/indestructible/rock/asteroid/Initialize(mapload)
	. = ..()
	var/matrix/M = new
	M.Translate(-4, -4)
	transform = M
	icon = 'icons/turf/smoothrocks_a.dmi'
