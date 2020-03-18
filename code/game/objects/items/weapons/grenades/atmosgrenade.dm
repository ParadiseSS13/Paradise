/obj/item/grenade/gas
	name = "plasma fire grenade"
	desc = "A compressed plasma grenade, used to start horrific plasma fires."
	origin_tech = "materials=3;magnets=4;syndicate=3"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	var/spawn_contents = LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS
	var/spawn_amount = 100

/obj/item/grenade/gas/prime()
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(spawn_contents, spawn_amount)
		target_turf.air_update_turf()
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

/obj/item/grenade/gluon
	desc = "An advanced grenade that releases a harmful stream of gluons inducing radiation in those nearby. These gluon streams will also make victims feel exhausted, and induce shivering. This extreme coldness will also wet any nearby floors."
	name = "gluon grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "gluon"
	item_state = "flashbang"
	var/range = 4
	var/rad_damage = 60
	var/stamina_damage = 30

/obj/item/grenade/gluon/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, 1)
	for(var/turf/T in view(range, loc))
		if(isfloorturf(T))
			var/turf/simulated/F = T
			F.MakeSlippery(TURF_WET_PERMAFROST)
			for(var/mob/living/carbon/L in T)
				L.adjustStaminaLoss(stamina_damage)
				L.apply_effect(rad_damage, IRRADIATE)
				L.adjust_bodytemperature(-230)
	qdel(src)
