/obj/machinery/transformer/xray/southnorth

/obj/machinery/transformer/xray/southnorth/New()
  // On us
  new /obj/machinery/conveyor/auto(loc, NORTH)
  addAtProcessing()

/obj/machinery/transformer/xray/southnorth/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//South
		var/turf/south = locate(T.x, T.y + 1, T.z)
		if(istype(south, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(south, NORTH)
		//South2
		var/turf/south2 = locate(T.x, T.y + 2, T.z)
		if(istype(south2, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(south2, NORTH)

		// North
		var/turf/north = locate(T.x, T.y - 1, T.z)
		if(istype(north, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(north, NORTH)

		// North2
		var/turf/north2 = locate(T.x, T.y - 2, T.z)
		if(istype(north2, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(north2, NORTH)

/obj/machinery/transformer/xray/southnorth/Bumped(var/atom/movable/AM)

	if(cooldown == 1)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if(H.lying && move_dir == NORTH)// || move_dir == WEST)
			AM.loc = src.loc
			irradiate(AM)

	else if(isobject(AM))
		AM.loc = src.loc
		scan(AM)

/obj/machinery/transformer/xray/southnorth/scan(var/obj/item/I)
	var/badcount = 0
	var/storagecount = 0
	if(istype(I, /obj/item/weapon/gun))
		badcount++
	if(istype(I, /obj/item/device/transfer_valve))
		badcount++
	if(istype(I, /obj/item/weapon/kitchen/knife))
		badcount++
	if(istype(I, /obj/item/weapon/grenade))
		badcount++
	if(istype(I, /obj/item/weapon/melee))
		badcount++
	if(istype(I, /obj/item/weapon/storage))
		for(var/obj/item/IT in I.contents)
			if(istype(IT, /obj/item/weapon/gun))
				badcount++
			if(istype(IT, /obj/item/ammo_box))
				badcount++
			if(istype(IT, /obj/item/ammo_casing))
				badcount++
			if(istype(IT, /obj/item/device/transfer_valve))
				badcount++
			if(istype(IT, /obj/item/weapon/kitchen/knife))
				badcount++
			if(istype(IT, /obj/item/weapon/grenade))
				badcount++
			if(istype(IT, /obj/item/weapon/melee))
				badcount++
			if(istype(IT, /obj/item/weapon/storage))
				storagecount++

	if(badcount)
		visible_message("<span class='warning'><b>Automatic X-Ray 5000</b> alerts: Found [badcount] dangerous objects.</span>")
		playsound(src.loc, 'sound/effects/alert.ogg', 50, 0)
		flick("separator-AO0",src)
	else if(storagecount)
		visible_message("<span class='notice'><b>Automatic X-Ray 5000</b> pings: Found [storagecount] storage units, which can't be x-rayed. Take them from the storage!</span>")
		playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
		flick("separator-AO0",src)
	else
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		sleep(30)