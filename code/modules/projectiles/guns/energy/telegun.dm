// Telegun for Tator RDs

/obj/item/weapon/gun/energy/telegun
	name = "Teleporter Gun"
	desc = "An extremely high-tech bluespace energy gun capable of teleporting targets to far off locations."
	icon_state = "telegun"
	item_state = "ionrifle"
	origin_tech = "combat=6;materials=7;powerstorage=5;bluespace=5;syndicate=4"
	cell_type = /obj/item/weapon/stock_parts/cell/crap
	ammo_type = list(/obj/item/ammo_casing/energy/teleport)
	shaded_charge = 1
	var/teleport_target = null

/obj/item/weapon/gun/energy/telegun/Destroy()
	teleport_target = null
	return ..()

/obj/item/weapon/gun/energy/telegun/attack_self(mob/living/user as mob)
	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/device/radio/beacon/R in beacons)
		var/turf/T = get_turf(R)
		if (!T)
			continue
		if((T.z in config.admin_levels) || T.z > 7)
			continue
		if(R.syndicate == 1)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	var/desc = input("Please select a location to lock in.", "Telegun Target Interface") in L
	teleport_target = L[desc]

/obj/item/weapon/gun/energy/telegun/newshot()
	..(teleport_target)
