


/obj/item/weapon/grenade/gas
	name = "Plasma Fire Grenade"
	desc = "A compressed plasma grenade, used to start horrific plasma fires."
	origin_tech = "materials=3;magnets=4;syndicate=4"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	var/spawn_contents = SPAWN_HEAT | SPAWN_TOXINS
	var/spawn_amount = 100

/obj/item/weapon/grenade/gas/prime()
	var/turf/simulated/target_turf = get_turf(src)
	if(istype(target_turf))
		target_turf.atmos_spawn_air(spawn_contents, spawn_amount)
		target_turf.air_update_turf()
	qdel(src)

/obj/item/weapon/grenade/gas/knockout
	name = "Knockout Grenade"
	desc = "A grenade that completely removes all air and heat from its detonation area."
	spawn_contents = SPAWN_20C | SPAWN_N2O