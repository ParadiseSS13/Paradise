#define DRONE_BUILD_TIME 2 MINUTES
#define MAX_MAINT_DRONES 5

/obj/machinery/drone_fabricator
	name = "drone fabricator"
	desc = "A large automated factory for producing maintenance drones."
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"

	density = TRUE
	anchored = TRUE
	idle_power_consumption = 20
	active_power_consumption = 5000

	var/produce_drones = TRUE
	var/drone_progress = 100
	var/time_last_drone = 0

/obj/machinery/drone_fabricator/update_icon_state()
	. = ..()
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/drone_fabricator/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/drone_fabricator/process()

	if(SSticker.current_state < GAME_STATE_PLAYING)
		return

	if(stat & NOPOWER || !produce_drones)
		if(icon_state != "drone_fab_nopower")
			icon_state = "drone_fab_nopower"
		return

	if(drone_progress >= 100)
		icon_state = "drone_fab_idle"
		return

	icon_state = "drone_fab_active"
	var/elapsed = world.time - time_last_drone
	drone_progress = clamp(round((elapsed / DRONE_BUILD_TIME) * 100), 0, 100)

	if(drone_progress >= 100)
		visible_message("[src] voices a strident beep, indicating a drone chassis is prepared.")

/obj/machinery/drone_fabricator/proc/drone_prepared()
	return (produce_drones && drone_progress >= 100 && (count_drones() < MAX_MAINT_DRONES))

/obj/machinery/drone_fabricator/proc/count_drones()
	var/drones = 0
	for(var/mob/living/silicon/robot/drone/D in GLOB.silicon_mob_list)
		if(D.key && D.client)
			drones++
	return drones

/obj/machinery/drone_fabricator/proc/create_drone(client/player)
	if(stat & NOPOWER)
		return

	if(!produce_drones || count_drones() >= MAX_MAINT_DRONES)
		return

	if(!player || !isobserver(player.mob))
		return

	visible_message("[src] churns and grinds as it lurches into motion, disgorging a shiny new drone after a few moments.")
	flick("h_lathe_leave",src)

	time_last_drone = world.time
	var/mob/living/silicon/robot/drone/new_drone = new(get_turf(src))
	new_drone.transfer_personality(player)

	drone_progress = 0

/obj/machinery/drone_fabricator/attack_ghost(mob/user as mob)
	if(!drone_prepared() || !isobserver(user))
		return
	var/mob/dead/observer/ghost = user
	ghost.join_as_drone()

/obj/machinery/drone_fabricator/attack_hand(mob/user)
	. = ..()
	if(isdrone(user) && Adjacent(user))
		if(alert(user, "Would you like to shut down?", null, "Yes", "No") != "Yes")
			return
		var/mob/living/silicon/robot/drone/D = user
		if(!istype(D) || QDELETED(D))
			return
		D.cryo_with_dronefab(src)

#undef DRONE_BUILD_TIME
#undef MAX_MAINT_DRONES
