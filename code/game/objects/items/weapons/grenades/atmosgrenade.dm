


/obj/item/weapon/grenade/gas
	name = "Plasma Fire Grenade"
	desc = "A compressed plasma grenade, used to start horrific plasma fires."
	origin_tech = "materials=3;magnets=4;syndicate=4"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"

/obj/item/weapon/grenade/gas/prime()
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 100)
		target_turf.air_update_turf()
	qdel(src)

/obj/item/weapon/grenade/gas/knockout
	name = "Knockout Grenade"
	desc = "A grenade that completely removes all air and heat from its detonation area."

/obj/item/weapon/grenade/gas/knockout/prime()
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(SPAWN_20C | SPAWN_N2O, 100)
		target_turf.air_update_turf()
	qdel(src)

