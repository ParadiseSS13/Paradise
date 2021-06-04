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

/turf/simulated/wall/indestructible/sandstone
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone"
	canSmoothWith = list(/turf/simulated/wall/mineral/sandstone, /turf/simulated/wall/indestructible/sandstone, /obj/structure/falsewall/sandstone)

/turf/simulated/wall/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'config/title_screens/images/blank.png'
	icon_state = ""
	layer = FLY_LAYER

/turf/simulated/wall/indestructible/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/wall/mineral/uranium, /obj/structure/falsewall/uranium, /turf/simulated/wall/indestructible/uranium)

/turf/simulated/wall/indestructible/wood
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood"
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/wall/mineral/wood, /obj/structure/falsewall/wood, /turf/simulated/wall/mineral/wood/nonmetal, /turf/simulated/wall/indestructible/wood)

/turf/simulated/wall/indestructible/alien
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor"
	smooth = SMOOTH_TRUE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/simulated/wall/mineral/abductor, /obj/structure/falsewall/abductor, /turf/simulated/wall/indestructible/alien)

/turf/simulated/wall/indestructible/abductor
	icon = 'icons/turf/walls.dmi'
	icon_state = "alien1"

/turf/simulated/wall/indestructible/fakedoor
	name = "CentCom Access"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "fake_door"

/turf/simulated/wall/indestructible/fakeglass
	name = "window"
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "fake_window"
	opacity = FALSE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/full/basic, /obj/structure/window/full/reinforced, /obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/plasmabasic, /obj/structure/window/full/plasmareinforced, /turf/simulated/wall/indestructible/fakeglass)

/turf/simulated/wall/indestructible/fakeglass/Initialize(mapload)
	. = ..()
	icon_state = null
	underlays += mutable_appearance('icons/obj/structures.dmi', "grille") //add a grille underlay
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating") //add the plating underlay, below the grille

/turf/simulated/wall/indestructible/opsglass
	name = "window"
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window"
	opacity = FALSE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/wall/indestructible/opsglass, /obj/structure/window/full/plastitanium)

/turf/simulated/wall/indestructible/opsglass/Initialize(mapload)
	. = ..()
	icon_state = null
	underlays += mutable_appearance('icons/obj/structures.dmi', "grille")
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating")

/turf/simulated/wall/indestructible/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"

/turf/simulated/wall/indestructible/rock/snow
	name = "mountainside"
	desc = "An extremely densely-packed rock, sheeted over with centuries worth of ice and snow."
	icon = 'icons/turf/walls.dmi'
	icon_state = "snowrock"

/turf/simulated/wall/indestructible/riveted
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"

/turf/simulated/wall/indestructible/syndicate
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle"
	smooth = SMOOTH_MORE | SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/simulated/wall/mineral/plastitanium, /turf/simulated/wall/indestructible/syndicate, /obj/machinery/door/airlock/titanium, /obj/machinery/door/airlock, /obj/structure/shuttle/engine, /obj/structure/falsewall/plastitanium, /turf/simulated/wall/indestructible/opsglass, /obj/structure/window/full/plastitanium)
