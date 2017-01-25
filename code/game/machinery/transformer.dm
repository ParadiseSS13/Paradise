/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'human go in, robot come out', human must be lying down and alive. Has to cooldown between each use."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/transform_dead = 0
	var/transform_standing = 0
	var/cooldown_duration = 600 // 1 minute
	var/cooldown = 0
	var/robot_cell_charge = 5000

/obj/machinery/transformer/New()
	// On us
	..()
	new /obj/machinery/conveyor/auto(loc, WEST)

/obj/machinery/transformer/power_change()
	..()
	update_icon()

/obj/machinery/transformer/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER) || cooldown == 1)
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/Bumped(var/atom/movable/AM)

	if(cooldown == 1)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if((transform_standing || H.lying) && move_dir == EAST)// || move_dir == WEST)
			AM.loc = src.loc
			do_transform(AM)

/obj/machinery/transformer/proc/do_transform(var/mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return
	if(cooldown == 1)
		return

	if(!transform_dead && H.stat == DEAD)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	H.emote("scream") // It is painful
	H.adjustBruteLoss(max(0, 80 - H.getBruteLoss())) // Hurt the human, don't try to kill them though.
	H.handle_regular_hud_updates() // Make sure they see the pain.

	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(5)

	use_power(5000) // Use a lot of power.
	var/mob/living/silicon/robot/R = H.Robotize(1) // Delete the items or they'll all pile up in a single tile and lag

	R.cell.maxcharge = robot_cell_charge
	R.cell.charge = robot_cell_charge

 	// So he can't jump out the gate right away.
	R.lockcharge = !R.lockcharge
	spawn(50)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		sleep(30)
		if(R)
			R.lockcharge = !R.lockcharge
			R.notify_ai(1)

	// Activate the cooldown
	cooldown = 1
	update_icon()
	spawn(cooldown_duration)
		cooldown = 0
		update_icon()

/obj/machinery/transformer/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(east, WEST)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(west, WEST)



/obj/machinery/transformer/mime
	name = "Mimetech Greyscaler"
	desc = "Turns anything placed inside black and white."


/obj/machinery/transformer/mime/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(east, WEST)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(west, WEST)

/obj/machinery/transformer/mime/Bumped(var/atom/movable/AM)

	if(cooldown == 1)
		return

	// Crossed didn't like people lying down.
	if(isobject(AM))
		AM.loc = src.loc
		do_transform_mime(AM)
	else
		to_chat(AM, "Only items can be greyscaled.")
		return

/obj/machinery/transformer/proc/do_transform_mime(var/obj/item/I)
	if(stat & (BROKEN|NOPOWER))
		return
	if(cooldown == 1)
		return

	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	// Sleep for a couple of ticks to allow the human to see the pain
	sleep(5)
	use_power(5000) // Use a lot of power.

	var/icon/newicon = new(I.icon, I.icon_state)
	newicon.GrayScale()
	I.icon = newicon

	// Activate the cooldown
	cooldown = 1
	update_icon()
	spawn(cooldown_duration)
		cooldown = 0
		update_icon()

/obj/machinery/transformer/xray
	name = "Automatic X-Ray 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'backpack go in, backpack come out', 'human go in, irradiated human come out'."

/obj/machinery/transformer/xray/New()
	// On us
	new /obj/machinery/conveyor/auto(loc, EAST)
	addAtProcessing()

/obj/machinery/transformer/xray/conveyor/New()
	..()
	var/turf/T = loc
	if(T)
		// Spawn Conveyour Belts

		//East
		var/turf/east = locate(T.x + 1, T.y, T.z)
		if(istype(east, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(east, EAST)
		//East2
		var/turf/east2 = locate(T.x + 2, T.y, T.z)
		if(istype(east2, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(east2, EAST)

		// West
		var/turf/west = locate(T.x - 1, T.y, T.z)
		if(istype(west, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(west, EAST)

		// West2
		var/turf/west2 = locate(T.x - 2, T.y, T.z)
		if(istype(west2, /turf/simulated/floor))
			new /obj/machinery/conveyor/auto(west2, EAST)

/obj/machinery/transformer/xray/power_change()
	..()
	update_icon()

/obj/machinery/transformer/xray/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/xray/Bumped(var/atom/movable/AM)

	if(cooldown == 1)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/move_dir = get_dir(loc, AM.loc)
		var/mob/living/carbon/human/H = AM
		if(H.lying && move_dir == WEST)// || move_dir == WEST)
			AM.loc = src.loc
			irradiate(AM)

	else if(isobject(AM))
		AM.loc = src.loc
		scan(AM)

/obj/machinery/transformer/xray/proc/irradiate(var/mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return

	flick("separator-AO0",src)
	playsound(src.loc, 'sound/effects/alert.ogg', 50, 0)
	sleep(5)
	H.apply_effect((rand(150,200)),IRRADIATE,0)
	if(prob(5))
		if(prob(75))
			randmutb(H) // Applies bad mutation
			domutcheck(H,null,1)
		else
			randmutg(H) // Applies good mutation
			domutcheck(H,null,1)


/obj/machinery/transformer/xray/proc/scan(var/obj/item/I)
	var/badcount = 0
	for(var/obj/item/weapon/gun/G in src.loc)
		badcount++
	for(var/obj/item/device/transfer_valve/B in src.loc)
		badcount++
	for(var/obj/item/weapon/kitchen/knife/K in src.loc)
		badcount++
	for(var/obj/item/weapon/grenade/plastic/c4/KK in src.loc)
		badcount++
	for(var/obj/item/weapon/melee/ML in src.loc)
		badcount++
	if(badcount)
		playsound(src.loc, 'sound/effects/alert.ogg', 50, 0)
		flick("separator-AO0",src)
	else
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		sleep(30)

