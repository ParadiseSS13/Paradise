/obj/machinery/drone_fabricator
	name = "drone storage"
	desc = "A large automated machine for storing and maintaining maintenance drones."
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"

	density = TRUE
	anchored = TRUE
	idle_power_consumption = 20
	active_power_consumption = 5000

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

	if(stat & NOPOWER)
		if(icon_state != "drone_fab_nopower")
			icon_state = "drone_fab_nopower"
		return

	if(!recharge_drones())
		icon_state = "drone_fab_idle"
		return

	icon_state = "drone_fab_active"

/obj/machinery/drone_fabricator/proc/recharge_drones()
	for(var/mob/living/silicon/robot/drone/D in src)
		if(D.module)
			D.module.recharge_consumables(D, 1) // This will handle all of a cyborg's items.
		D.heal_overall_damage(1, 1)
		if(D.cell)
			D.cell.charge = min(D.cell.charge + 200, D.cell.maxcharge)
		. |= (D.health != D.maxHealth)


/obj/machinery/drone_fabricator/examine(mob/user)
	. = ..()
	if(isobserver(user) && get_noclient_drone())
		. += "<b>A drone is ready. Select 'Join As Drone' from the Ghost tab to spawn as a maintenance drone.</b>"

/obj/machinery/drone_fabricator/proc/get_noclient_drone()
	for(var/mob/living/silicon/robot/drone/D in src)
		if(!D.client)
			return D

/obj/machinery/drone_fabricator/proc/create_drone(client/player)
	if(stat & NOPOWER)
		return

	if(!player || !isobserver(player.mob))
		return
	var/mob/living/silicon/robot/drone/new_drone = get_noclient_drone()
	if(!istype(new_drone))
		return FALSE

	visible_message("[src] churns and grinds as it lurches into motion, disgorging a drone after a few moments.")
	new_drone.transfer_personality(player)
	new_drone.forceMove(get_turf(src))

/obj/machinery/drone_fabricator/attack_ghost(mob/user as mob)
	if(!get_noclient_drone() || !isobserver(user))
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

	if(!can_join_as_drone())
		return

	if(tgui_alert(usr, "Are you sure you want to respawn as a drone?", "Are you sure?", list("Yes", "No")) != "Yes")
		return

	for(var/obj/machinery/drone_fabricator/DF in GLOB.machines)
		if(DF.create_drone(client))
			return

	to_chat(src, "<span class='warning'>There are no available drone spawn points, sorry.</span>")

/mob/dead/proc/can_join_as_drone()
	if(jobban_isbanned(src, "nonhumandept") || jobban_isbanned(src, "Drone"))
		to_chat(usr, "<span class='warning'>You are banned from playing drones, and cannot spawn as one.</span>")
		return FALSE

	if(!SSticker || SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>You can't join as a drone before the game starts!</span>")
		return FALSE

	var/player_age_check = check_client_age(usr.client, 14) // 14 days to play as a drone
	if(player_age_check && GLOB.configuration.gamemode.antag_account_age_restriction)
		to_chat(usr, "<span class='warning'>This role is not yet available to you. You need to wait another [player_age_check] days.</span>")
		return FALSE

	var/pt_req = role_available_in_playtime(client, "Drone")
	if(pt_req)
		var/pt_req_string = get_exp_format(pt_req)
		to_chat(usr, "<span class='warning'>This role is not yet available to you. Play another [pt_req_string] to unlock it.</span>")
		return FALSE

	var/deathtime = world.time - timeofdeath
	var/joinedasobserver = FALSE
	if(isobserver(src))
		var/mob/dead/observer/G = src
		if(!G.check_ahud_rejoin_eligibility())
			to_chat(usr, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
			return FALSE
		if(G.started_as_observer)
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
		return FALSE
	return TRUE
