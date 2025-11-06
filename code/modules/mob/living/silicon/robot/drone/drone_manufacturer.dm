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

/obj/machinery/drone_fabricator/examine(mob/user)
	. = ..()
	if(isobserver(user) && drone_prepared())
		. += "<BR><B>A drone is prepared. Select 'Join As Drone' from the Ghost tab to spawn as a maintenance drone.</B>"

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

/mob/dead/verb/join_as_drone()
	set category = "Ghost"
	set name = "Join As Drone"
	set desc = "If there is a powered, enabled fabricator in the game world with a prepared chassis, join as a maintenance drone."

	if(stat != DEAD)
		return

	if(usr != src)
		return FALSE //something is terribly wrong

	if(jobban_isbanned(src, "nonhumandept") || jobban_isbanned(src, "Drone"))
		to_chat(usr, "<span class='warning'>You are banned from playing drones, and cannot spawn as one.</span>")
		return

	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>You can't join as a drone before the game starts!</span>")
		return

	var/player_age_check = check_client_age(usr.client, 14) // 14 days to play as a drone
	if(player_age_check && GLOB.configuration.gamemode.antag_account_age_restriction)
		to_chat(usr, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return

	var/pt_req = role_available_in_playtime(client, "Drone")
	if(pt_req)
		var/pt_req_string = get_exp_format(pt_req)
		to_chat(usr, "<span class='warning'>This role is not yet available to you. Play another [pt_req_string] to unlock it.</span>")
		return

	var/deathtime = world.time - timeofdeath
	var/joinedasobserver = FALSE
	if(isobserver(src))
		var/mob/dead/observer/ghost = src
		if(!ghost.check_ahud_rejoin_eligibility())
			to_chat(usr, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
			return
		if(ghost.ghost_flags & GHOST_START_AS_OBSERVER)
			joinedasobserver = TRUE

	var/deathtimeminutes = round(deathtime / 600)
	var/pluralcheck = "minute"
	if(deathtimeminutes == 0)
		pluralcheck = ""
	else if(deathtimeminutes == 1)
		pluralcheck = " [deathtimeminutes] minute and"
	else if(deathtimeminutes > 1)
		pluralcheck = " [deathtimeminutes] minutes and"
	var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10, 1)

	if(deathtime < 6000 && joinedasobserver == 0)
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		to_chat(usr, "<span class='warning'>You must wait 10 minutes to respawn as a drone!</span>")
		return

	if(tgui_alert(usr, "Are you sure you want to respawn as a drone?", "Are you sure?", list("Yes", "No")) != "Yes")
		return

	for(var/obj/machinery/drone_fabricator/DF in SSmachines.get_by_type(/obj/machinery/drone_fabricator))
		if(DF.stat & NOPOWER || !DF.produce_drones)
			continue

		if(DF.count_drones() >= MAX_MAINT_DRONES)
			to_chat(src, "<span class='warning'>There are too many active drones in the world for you to spawn.</span>")
			return

		if(DF.drone_progress >= 100)
			DF.create_drone(client)
			return

	to_chat(src, "<span class='warning'>There are no available drone spawn points, sorry.</span>")

#undef DRONE_BUILD_TIME
#undef MAX_MAINT_DRONES
