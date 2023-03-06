/turf/simulated/wall/indestructible
	name = "wall"
	desc = "Effectively impervious to conventional methods of destruction."
	explosion_block = 50
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"

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

/turf/simulated/wall/indestructible/ratvar_act()
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

/turf/simulated/wall/indestructible/rpd_act()
	return

/turf/simulated/wall/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return

/turf/simulated/wall/indestructible/try_decon(obj/item/I, mob/user, params)
	return

/turf/simulated/wall/indestructible/rcd_deconstruct_act()
	return RCD_NO_ACT

/turf/simulated/wall/indestructible/thermitemelt(mob/user as mob, speed)
	return

/turf/simulated/wall/indestructible/fakeglass
	name = "window"
	icon = 'icons/turf/walls/fake_glass.dmi'
	icon_state = "fake_glass"
	opacity = FALSE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/wall/indestructible/fakeglass)

/turf/simulated/wall/indestructible/reinforced
	name = "reinforced wall"
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	canSmoothWith = list(
	/turf/simulated/wall/indestructible/reinforced,
	/turf/simulated/wall,
	/turf/simulated/wall/r_wall,
	/obj/structure/falsewall,
	/obj/structure/falsewall/reinforced,
	/obj/structure/falsewall/clockwork,
	/turf/simulated/wall/rust,
	/turf/simulated/wall/r_wall/rust,
	/turf/simulated/wall/r_wall/coated)
	smooth = SMOOTH_TRUE

/turf/simulated/wall/indestructible/wood
	name = "wooden wall"
	desc = "A wall with wooden plating against any method of destruction. Very stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood"
	canSmoothWith = list(
	/turf/simulated/wall/indestructible/wood,
	/turf/simulated/wall/mineral/wood,
	/obj/structure/falsewall/wood,
	/turf/simulated/wall/mineral/wood/nonmetal)
	smooth = SMOOTH_TRUE

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
	icon_state = "wall"
	canSmoothWith = list(/turf/simulated/wall/indestructible/boss, /turf/simulated/wall/indestructible/boss/see_through)
	explosion_block = 50
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

/turf/simulated/wall/indestructible/metal
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	smooth = SMOOTH_TRUE

/turf/simulated/wall/indestructible/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon_state = "alien1"

/turf/simulated/wall/indestructible/splashcreen
	name = "Space Station 13"
	icon = 'config/title_screens/images/blank.png'
	icon_state = ""
	layer = FLY_LAYER
