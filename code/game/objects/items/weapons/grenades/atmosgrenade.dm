/obj/item/grenade/gas
	name = "plasma fire grenade"
	desc = "A compressed plasma grenade, used to start horrific plasma fires."
	icon_state = "syndicate"
	origin_tech = "materials=3;magnets=4;syndicate=3"
	var/spawn_contents = LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS
	var/spawn_amount = 100

/obj/item/grenade/gas/prime()
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(spawn_contents, spawn_amount)
	qdel(src)

/obj/item/grenade/gas/plasma
	icon_state = "plasma"

/obj/item/grenade/gas/knockout
	name = "knockout grenade"
	desc = "A grenade that releases pure N2O gas."
	spawn_contents = LINDA_SPAWN_20C | LINDA_SPAWN_N2O

/obj/item/grenade/gas/oxygen
	name = "oxygen grenade"
	desc = "A grenade that releases pure O2 gas."
	icon_state = "oxygen"
	spawn_contents = LINDA_SPAWN_20C | LINDA_SPAWN_OXYGEN
	spawn_amount = 500
	origin_tech = null

/obj/item/grenade/gluon
	desc = "An advanced grenade that releases a harmful stream of gluons inducing radiation in those nearby. These gluon streams will also make victims feel exhausted, and induce shivering. This extreme coldness will also wet any nearby floors."
	name = "gluon grenade"
	icon_state = "gluon"
	var/freeze_range = 4
	var/rad_damage = 1400
	var/stamina_damage = 30

/obj/item/grenade/gluon/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, 1)
	radiation_pulse(src, rad_damage, BETA_RAD)
	for(var/turf/simulated/floor/T in view(freeze_range, loc))
		T.MakeSlippery(TURF_WET_ICE)
		for(var/mob/living/carbon/L in T)
			L.apply_damage(stamina_damage, STAMINA)
			L.adjust_bodytemperature(-230)
	qdel(src)
