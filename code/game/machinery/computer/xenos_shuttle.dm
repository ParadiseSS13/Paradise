#define XENOS_SHUTTLE_MOVE_TIME 240
#define XENOS_SHUTTLE_COOLDOWN 200

/obj/machinery/computer/xenos_station
	name = "xenos shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	req_access = list()
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0
	unacidable = 1


/obj/machinery/computer/xenos_station/New()
	curr_location = locate(/area/xenos_station/start)


/obj/machinery/computer/xenos_station/proc/xenos_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + XENOS_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	for(var/obj/machinery/door/airlock/alien/A in world)
		A.close()
		A.locked = 1
		A.update_icon()

	for(var/mob/M in curr_location)
		if(M.client)
			spawn(0)
				if(M.buckled)
					M << "\red Sudden acceleration presses you into your chair!"
					shake_camera(M, 3, 1)
				else
					M << "\red The floor lurches beneath you!"
					shake_camera(M, 10, 1)
		if(istype(M, /mob/living/carbon) && !isalien(M))
			if(!M.buckled)
				M.Weaken(3)

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/xenos_station/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(XENOS_SHUTTLE_MOVE_TIME)

	for(var/obj/machinery/door/airlock/alien/A in world)
		A.close()
		if(dest_location != locate(/area/xenos_station/start))
			A.locked = 0
			A.update_icon()

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in dest_location)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

	for(var/mob/living/carbon/bug in dest_location) // If someone somehow is still in the shuttle's docking area...
		bug.gib()

	for(var/mob/living/simple_animal/pest in dest_location) // And for the other kind of bug...
		pest.gib()

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1


/obj/machinery/computer/xenos_station/attackby(obj/item/I as obj, mob/user as mob, params)
	return attack_hand(user)

/obj/machinery/computer/xenos_station/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/xenos_station/attack_alien(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/xenos_station/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "\red Access denied."
		return

	if(!isalien(user) && !isrobot(user) && !isAI(user))
		user << "You do not know how to operate this terminal."
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + XENOS_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + XENOS_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];xenos=1'>Alien Space</a><br>
	<a href='?src=\ref[src];station_nw=1'>North-West of SS13</a> |
	<a href='?src=\ref[src];station_ne=1'>North-East of SS13</a><br>
	<a href='?src=\ref[src];station_e=1'>East of SS13</a> <br>
	<a href='?src=\ref[src];station_sw=1'>South-West of SS13</a> |
	<a href='?src=\ref[src];station_se=1'>South-East of SS13</a><br>
	<a href='?src=\ref[src];station_west=1'>West of SS13</a><br>
	<a href='?src=\ref[src];station_ro=1'>North of Research Outpost</a><br>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/xenos_station/Topic(href, href_list)
	if(..())
		return 1

	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	if(href_list["xenos"])
		xenos_move_to(/area/xenos_station/start)
	else if(href_list["station_nw"])
		xenos_move_to(/area/xenos_station/northwest)
	else if(href_list["station_ne"])
		xenos_move_to(/area/xenos_station/northeast)
	else if(href_list["station_e"])
		xenos_move_to(/area/xenos_station/east)
	else if(href_list["station_sw"])
		xenos_move_to(/area/xenos_station/southwest)
	else if(href_list["station_se"])
		xenos_move_to(/area/xenos_station/southeast)
	else if(href_list["station_w"])
		xenos_move_to(/area/xenos_station/west)
	else if(href_list["station_ro"])
		xenos_move_to(/area/xenos_station/researchoutpost)

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/xenos_station/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")	//let's not let them fuck themselves in the rear