
#define DEPOT_VISITOR_START	1
#define DEPOT_VISITOR_END	2
#define DEPOT_VISITOR_ADD	3


// Generic parent depot computer type

/obj/machinery/computer/syndicate_depot
	name = "depot computer"
	icon = 'icons/obj/machines/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "tcboss"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(ACCESS_SYNDICATE)
	bubble_icon = "syndibot"
	var/window_height = 400 // should be roughly 100 per section. Allow extra space for the lockout alert.
	var/window_width = 400
	var/security_lockout = FALSE
	var/sound_yes = 'sound/machines/twobeep.ogg'
	var/sound_no = 'sound/machines/buzz-sigh.ogg'
	var/sound_click = 'sound/machines/click.ogg'
	var/area/syndicate_depot/core/depotarea
	var/alerts_when_broken = FALSE
	var/has_alerted = FALSE


/obj/machinery/computer/syndicate_depot/Initialize(mapload)
	. = ..()
	depotarea = get_area(src)

/obj/machinery/computer/syndicate_depot/attack_ai(mob/user)
	if(length(req_access) && !("syndicate" in user.faction))
		to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
		return TRUE
	return ..()

/obj/machinery/computer/syndicate_depot/emp_act(severity)
	return

/obj/machinery/computer/syndicate_depot/emag_act(mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this console are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/computer/syndicate_depot/allowed(mob/user)
	if(user.can_advanced_admin_interact())
		return TRUE
	if(!isliving(user))
		return FALSE
	if(security_lockout)
		return FALSE
	return ..()

/obj/machinery/computer/syndicate_depot/proc/activate_security_lockout()
	security_lockout = TRUE
	disable_special_functions()

/obj/machinery/computer/syndicate_depot/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/computer/syndicate_depot/set_broken()
	. = ..()
	if(alerts_when_broken && !has_alerted)
		has_alerted = TRUE
		raise_alert("[src] was damaged.")
	disable_special_functions()

/obj/machinery/computer/syndicate_depot/proc/disable_special_functions()
	return

/obj/machinery/computer/syndicate_depot/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SyndicateComputerSimple",  name, window_width, window_height, master_ui, state)
		ui.open()

/obj/machinery/computer/syndicate_depot/ui_data(mob/user)
	var/list/data = list()
	data["rows"] = list()
	if(security_lockout)
		data["rows"] += list(list(
			"title" = "Security Lockout",
			"status" = "Due to heightened security alert, base computers are locked out.",
		))
	else if(length(req_access))
		data["rows"] += list(list(
			"title" = "Security Notice",
			"status" = "This terminal requires a syndicate ID of sufficient clearance.",
		))
	/*
		Guide for making your own template sections:
		data["rows"] += list(list(
			"title" = "Example Section Title",
			"status" = "Example text box contents. Can be long.",
			"bullets" = list(X,Y,Z) // a list of strings that appear, one per line, in the section.
			"buttontitle" = "Example Button Title", // If present, button shows up on right with the provided title. null = no button
			"buttonact" = "primary", // function name called when button is pressed ('primary' or 'secondary')
			"buttondisabled" = !allowed(user) // if true, button is not clickable, used to allow ghosts to see but not use buttons
			"buttontooltip" = "Tooltip that appears when you hover over the button"
		))
	*/
	return data

/obj/machinery/computer/syndicate_depot/ui_act(action, params)
	if(..())
		return
	. = FALSE
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return
	switch(action)
		if("primary")
			primary(usr)
			. = TRUE
		if("secondary")
			secondary(usr)
			. = TRUE
	if(.)
		add_fingerprint(usr)

/obj/machinery/computer/syndicate_depot/Destroy()
	disable_special_functions()
	if(alerts_when_broken && !has_alerted)
		raise_alert("[src] destroyed.")
	return ..()


/obj/machinery/computer/syndicate_depot/proc/primary(mob/user)
	return FALSE

/obj/machinery/computer/syndicate_depot/proc/secondary(mob/user)
	return FALSE

/obj/machinery/computer/syndicate_depot/proc/raise_alert(reason)
	if(istype(depotarea))
		depotarea.increase_alert(reason)



// Door Control Computer

/obj/machinery/computer/syndicate_depot/doors
	name = "depot door control computer"
	req_access = list()
	window_height = 300
	var/pub_access = FALSE

/obj/machinery/computer/syndicate_depot/doors/ui_data(mob/user)
	var/list/data = ..()
	data["rows"] += list(list(
		"title" = "Airlock Emergency Access",
		"status" = "Connected",
		"buttontitle" = pub_access ? "Disable" : "Enable",
		"buttonact" = "primary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "Enables/disables emergency access on every airlock nearby."
	))
	data["rows"] += list(list(
		"title" = "Secret Doors",
		"status" = "Connected",
		"buttontitle" = "Toggle Open/Closed",
		"buttonact" = "secondary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "Opens/closes secret doors nearby."
	))
	return data

/obj/machinery/computer/syndicate_depot/doors/primary(mob/user)
	if(depotarea)
		pub_access = !pub_access
		if(pub_access)
			depotarea.set_emergency_access(TRUE)
			to_chat(user, "<span class='notice'>Emergency Access enabled.</span>")
		else
			depotarea.set_emergency_access(FALSE)
			to_chat(user, "<span class='notice'>Emergency Access disabled.</span>")
		playsound(user, sound_yes, 50, 0)

/obj/machinery/computer/syndicate_depot/doors/secondary(mob/user, subcommand)
	if(depotarea)
		depotarea.toggle_falsewalls(src)
		to_chat(user, "<span class='notice'>False walls toggled.</span>")
		playsound(user, sound_yes, 50, 0)


// Engineering AKA self destruct computer, no useful functions, just a trap for the people who can't resist pushing dangerous-sounding buttons.

/obj/machinery/computer/syndicate_depot/selfdestruct
	name = "reactor control computer"
	icon_screen = "explosive"
	req_access = list()
	alerts_when_broken = TRUE
	window_height = 200 // this might appear big, but it has to have space for the lockout alert

/obj/machinery/computer/syndicate_depot/selfdestruct/ui_data(mob/user)
	var/list/data = ..()
	data["rows"] += list(list(
		"title" = "Reactor Containment Fields",
		"status" = (istype(depotarea) && !depotarea.used_self_destruct) ? "Online" : "Offline",
		"buttontitle" = (istype(depotarea) && !depotarea.used_self_destruct) ? "Disable" : null,
		"buttonact" = "primary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "Disables the containment field of the reactor."
	))
	return data

/obj/machinery/computer/syndicate_depot/selfdestruct/primary(mob/user)
	if(depotarea.used_self_destruct)
		playsound(user, sound_no, 50, 0)
		return
	if(depotarea)
		depotarea.activate_self_destruct("Fusion reactor containment field disengaged. All hands, evacuate. All hands, evacuate!", TRUE, user)
		playsound(user, sound_click, 20, 1)


// Shield computer, used to manipulate base shield, and armory shield

/obj/machinery/computer/syndicate_depot/shieldcontrol
	name = "shield control computer"
	icon_screen = "accelerator"
	req_access = list(ACCESS_SYNDICATE_LEADER)
	alerts_when_broken = TRUE
	window_height = 280
	var/area/syndicate_depot/perimeter/perimeterarea

/obj/machinery/computer/syndicate_depot/shieldcontrol/Initialize(mapload)
	. = ..()
	perimeterarea = locate(/area/syndicate_depot/perimeter)

/obj/machinery/computer/syndicate_depot/shieldcontrol/Destroy()
	if(istype(perimeterarea) && length(perimeterarea.shield_list))
		perimeterarea.perimeter_shields_down()
	return ..()

/obj/machinery/computer/syndicate_depot/shieldcontrol/ui_data(mob/user)
	var/list/data = ..()
	data["rows"] += list(list(
		"title" = "Asteroid Perimeter Shield",
		"status" = length(perimeterarea.shield_list) ? "ON" : "OFF",
		"buttontitle" = length(perimeterarea.shield_list) ? "Disable" : "Enable",
		"buttonact" = "primary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "While on, nobody can get into the depot."
	))
	data["rows"] += list(list(
		"title" = "Armory Shield",
		"status" = length(depotarea.shield_list) ? "ON" : "OFF",
		"buttontitle" = length(depotarea.shield_list) ? "Disable" : "Enable",
		"buttonact" = "secondary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "While on, the armory is protected from looters."
	))
	return data

/obj/machinery/computer/syndicate_depot/shieldcontrol/primary(mob/user)
	if(depotarea.used_self_destruct)
		playsound(user, sound_no, 50, 0)
		return
	if(!istype(perimeterarea))
		return
	if(length(perimeterarea.shield_list))
		perimeterarea.perimeter_shields_down()
		depotarea.perimeter_shield_status = FALSE
	else
		perimeterarea.perimeter_shields_up()
		depotarea.perimeter_shield_status = TRUE
	playsound(user, sound_yes, 50, 0)


/obj/machinery/computer/syndicate_depot/shieldcontrol/secondary(mob/user)
	if(!istype(depotarea))
		return
	if(length(depotarea.shield_list))
		depotarea.shields_down()
	else
		depotarea.shields_up()
	playsound(user, sound_yes, 50, 0)


// Syndicate comms computer, used to activate visitor mode, and message syndicate. Traitor-only use.

/obj/machinery/computer/syndicate_depot/syndiecomms
	name = "syndicate communications computer"
	icon_screen = "syndishuttle"
	req_access = list()
	alerts_when_broken = TRUE
	window_height = 300
	var/message_sent = FALSE

/obj/machinery/computer/syndicate_depot/syndiecomms/Initialize(mapload)
	. = ..()
	if(depotarea)
		depotarea.comms_computer = src

/obj/machinery/computer/syndicate_depot/syndiecomms/Destroy()
	if(depotarea)
		depotarea.comms_computer = null
	return ..()

/obj/machinery/computer/syndicate_depot/syndiecomms/ui_data(mob/user)
	var/list/data = ..()
	data["rows"] += list(list(
		"title" = "Communications Array",
		"status" = message_sent ? "Offline" : "Online",
		"buttontitle" = message_sent ? null : "Contact Syndicate HQ",
		"buttonact" = "primary",
		"buttondisabled" = !allowed(user)
	))
	data["rows"] += list(list(
		"title" = "Visiting Agents",
		"status" = !length(depotarea.peaceful_list) ? "None" : null,
		"bullets" = length(depotarea.peaceful_list) ? depotarea.list_shownames(depotarea.peaceful_list) : null,
		"buttontitle" = "Sign In As Agent",
		"buttonact" = "secondary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "Only actual syndicate agents can do this."
	))
	return data

/obj/machinery/computer/syndicate_depot/syndiecomms/primary(mob/user)
	if(!isliving(user))
		to_chat(user, "ERROR: No lifesigns detected at terminal, aborting.") // Safety to prevent aghosts accidentally consuming the only use.
		return
	if(message_sent)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='warning'>[src] has already been used to transmit a message to the Syndicate.</span>")
		return
	message_sent = TRUE
	var/input = stripped_input(user, "Please choose a message to transmit to Syndicate HQ via quantum entanglement.  Transmission does not guarantee a response. This function may only be used ONCE.", "To abort, send an empty message.", "")
	if(!input)
		message_sent = FALSE
		return
	Syndicate_announce(input, user)
	to_chat(user, "Message transmitted.")
	add_game_logs("has sent a Syndicate comms message from the depot: [input]", user)
	playsound(user, sound_yes, 50, 0)

/obj/machinery/computer/syndicate_depot/syndiecomms/secondary(mob/user)
	if(!istype(depotarea))
		to_chat(user, "<span class='warning'>ERROR: [src] is unable to uplink to depot network.</span>")
		return
	if(depotarea.local_alarm || depotarea.called_backup || depotarea.used_self_destruct)
		to_chat(user, "<span class='warning'>Visitor sign-in is not possible while the depot is on security alert.</span>")
		return
	if(depotarea.something_looted)
		to_chat(user, "<span class='warning'>Visitor sign-in is not possible after supplies have been taken from a locker in the depot.</span>")
		return
	if("syndicate" in user.faction)
		to_chat(user, "<span class='warning'>You are already recognized as a member of the Syndicate, and do not need to sign in.</span>")
		return
	if(!user.mind || user.mind.special_role != SPECIAL_ROLE_TRAITOR)
		to_chat(user, "<span class='warning'>Only verified agents of the Syndicate may sign in as visitors. Everyone else will be shot on sight.</span>")
		return
	if(depotarea.list_includes(user, depotarea.peaceful_list))
		to_chat(user, "<span class='warning'>[user] is already signed in as a visiting agent.</span>")
		return
	if(!depotarea.on_peaceful)
		depotarea.peaceful_mode(TRUE, TRUE)
	grant_syndie_faction(user)
	playsound(user, sound_yes, 50, 0)

/obj/machinery/computer/syndicate_depot/syndiecomms/proc/grant_syndie_faction(mob/user)
	user.faction += "syndicate"
	depotarea.alert_log += "[user.name] signed in as a visitor."
	depotarea.list_add(user, depotarea.peaceful_list)
	to_chat(user, {"<BR><span class='userdanger'>Welcome, Agent.</span>
		<span class='warning'>You are now signed-in as a depot visitor.
		Any other agents with you MUST sign in themselves.
		You may explore all rooms here, except for bolted ones.
		Your agent ID will give you access to most doors and computers.
		Standard Syndicate regulations apply to your visit.
		This means if ANY of you attack facility staff, break into anything, sabotage the facility, or bring non-agents here, then ALL of you will be summarily executed.
		Enjoy your stay.</span>
	"})

/obj/machinery/computer/syndicate_depot/syndiecomms/power_change()
	. = ..()
	if(!security_lockout && (stat & NOPOWER))
		security_lockout = TRUE
		raise_alert("[src] lost power.")


// Syndicate teleporter control, used to manage incoming/outgoing teleports

/obj/machinery/computer/syndicate_depot/teleporter
	name = "Syndicate Redspace Teleporter Console"
	desc = "This suspicious high-tech machine creates a Bi-Directional teleporter that is capable to ignore any bluespace interference!"
	icon_screen = "telesci"
	icon_keyboard = "teleport_key"
	window_height = 320
	var/obj/machinery/bluespace_beacon/syndicate/mybeacon
	var/obj/effect/portal/redspace/myportal
	var/obj/effect/portal/redspace/myportal2
	var/portal_enabled = FALSE
	var/portaldir = WEST
	var/blocked = FALSE 		//Блокирует кнопки телепортера если TRUE
	var/last_opened_time = null	//Время когда в последний раз было открыто меню выбора телепорта
	var/last_opener = null		//Последний открывший меню выбора телепорта
	var/timeout = 300			//Время в течении которого никто не может использовать консоль пока кто то выбирает телепорт
	var/is_cooldown = FALSE		//На кулдауне ли мы?
	var/wait_time = 0 			//Сколько осталось до конца кулдауна.
	var/lifespan = 300			//Сколько будут жить созданные порталы прежде чем удалиться

/obj/machinery/computer/syndicate_depot/teleporter/taipan
	req_access = list(154)
	circuit = /obj/item/circuitboard/syndicate_teleporter
	armor = list("melee" = 0, "bullet" = 100, "laser" = 40, "energy" = 0, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 20)

/obj/machinery/computer/syndicate_depot/teleporter/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/syndicate_depot/teleporter/LateInitialize()
	findbeacon()
	update_portal()

/obj/machinery/computer/syndicate_depot/teleporter/Destroy()
	if(mybeacon)
		mybeacon.mycomputer = null
	return ..()

/obj/machinery/computer/syndicate_depot/teleporter/portal_destroyed(obj/effect/portal/P)
	myportal = null

/obj/machinery/computer/syndicate_depot/teleporter/disable_special_functions()
	if(mybeacon)
		if(mybeacon.enabled)
			mybeacon.toggle()
	if(portal_enabled)
		portal_enabled = FALSE
		update_portal()

/obj/machinery/computer/syndicate_depot/teleporter/proc/findbeacon()
	if(mybeacon)
		return TRUE
	for(var/obj/machinery/bluespace_beacon/syndicate/B in myArea)
		mybeacon = B
		B.mycomputer = src
		return TRUE
	return FALSE

/obj/machinery/computer/syndicate_depot/teleporter/proc/cooldown()
	if(is_cooldown)
		wait_time = round((last_opened_time + timeout - world.time) / 10)
		if(wait_time <=0)
			wait_time = 0
			is_cooldown = FALSE
			blocked = FALSE
		return wait_time
	return 0

/obj/machinery/computer/syndicate_depot/teleporter/proc/choosetarget()
	var/list/L = list()
	var/list/areaindex = list()
	last_opened_time = world.time
	last_opener = usr
	is_cooldown = TRUE
	blocked = TRUE
	for(var/obj/item/radio/beacon/R in GLOB.beacons)
		var/turf/T = get_turf(R)
		if(!T)
			continue
		if(!is_teleport_allowed(T.z))
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R
	var/desc = input("Please select a location to lock in.", "Syndicate Teleporter") in L
	if(usr == last_opener && world.time >= last_opened_time + timeout)
		return FALSE
	return(L[desc])

/obj/machinery/computer/syndicate_depot/teleporter/proc/update_portal()
	if(portal_enabled && !myportal &&!myportal2)
		var/turf/tele_target = choosetarget()
		log_debug("[last_opener] attempted to open a two-way portal using [src.name]")
		if(!in_range(usr, src) || !tele_target || myportal || myportal2)
			return
		is_cooldown = FALSE
		wait_time = 0
		blocked = FALSE
		var/turf/portal_turf = get_step(src, portaldir)
		var/obj/effect/portal/redspace/P = new(portal_turf, tele_target, src, lifespan)
		myportal = P
		var/area/A = get_area(tele_target)
		P.name = "[A] portal"
		log_debug("First Portal: [P] opened at ([portal_turf.x],[portal_turf.y],[portal_turf.z])")
		var/obj/effect/portal/redspace/P2 = new(get_turf(tele_target), portal_turf, src, lifespan)
		myportal2 = P2
		P2.name = "Mysterious portal"
		log_debug("Second Portal: [P2] opened at ([tele_target.x],[tele_target.y],[tele_target.z])")
	else if(!portal_enabled)
		if(myportal)
			qdel(myportal)
			myportal = null
		if(myportal2)
			qdel(myportal2)
			myportal2 = null

/obj/machinery/computer/syndicate_depot/teleporter/ui_data(mob/user)
	findbeacon()
	var/list/data = ..()
	data["rows"] += list(list(
		"title" = "Status",
		"status" = is_cooldown ? "Awaiting teleport position: [cooldown()]" : "Ready"
	))
	if(mybeacon)
		data["rows"] += list(list(
			"title" = "Incoming Teleport Beacon",
			"status" = mybeacon.enabled ? "ON" : "OFF",
			"buttontitle" = mybeacon.enabled ? "Disable" : "Enable",
			"buttonact" = "primary",
			"buttondisabled" = (!allowed(user) || blocked),
			"buttontooltip" = "When on, emagged teleporters can lock onto this location and open portals here."
		))
	data["rows"] += list(list(
		"title" = "Outgoing Teleport Portal",
		"status" = portal_enabled ? "ON" : "OFF",
		"buttontitle" = portal_enabled ? "Disable" : "Enable",
		"buttonact" = "secondary",
		"buttondisabled" = (!allowed(user)|| blocked),
		//"buttondisabled" = (!allowed(user) || (!depotarea.on_peaceful && !check_rights(R_ADMIN, FALSE, user))),
		"buttontooltip" = "When on, creates a bi-directional portal to the beacon of your choice."
	))
	return data

/obj/machinery/computer/syndicate_depot/teleporter/primary(mob/user)
	if(!mybeacon && user)
		to_chat(user, "<span class='notice'>Unable to connect to teleport beacon.</span>")
		return
	var/bresult = mybeacon.toggle()
	to_chat(user, "<span class='notice'>Syndicate Teleporter Beacon: [bresult ? "<span class='green'>ON</span>" : "<span class='red'>OFF</span>"]</span>")
	playsound(user, sound_yes, 50, 0)

/obj/machinery/computer/syndicate_depot/teleporter/secondary(mob/user)
/*	if(!depotarea.on_peaceful && !check_rights(R_ADMIN, FALSE, user))
		to_chat(user, "<span class='notice'>Outgoing Teleport Portal controls are only enabled when the depot has a signed-in agent visitor.</span>")
		return
		*/

	if(!portal_enabled && myportal)
		to_chat(user, "<span class='notice'>Outgoing Teleport Portal: deactivating... please wait...</span>")
		return
	toggle_portal()
	to_chat(user, "<span class='notice'>Outgoing Teleport Portal: [portal_enabled ? "<span class='green'>ON</span>" : "<span class='red'>OFF</span>"]</span>")
	updateUsrDialog()
	playsound(user, sound_yes, 50, 0)

/obj/machinery/computer/syndicate_depot/teleporter/proc/toggle_portal()
	portal_enabled = !portal_enabled
	update_portal()

/obj/machinery/computer/syndicate_depot/aiterminal
	name = "syndicate ai terminal"
	icon_screen = "command"
	req_access = list()
	window_height = 750 // has to be very tall since it has many sections which can expand

/obj/machinery/computer/syndicate_depot/aiterminal/ui_data(mob/user)
	var/list/data = ..()
	if(!istype(depotarea))
		return data

	var/alertlevel = "Green"
	if(depotarea.on_peaceful)
		alertlevel = "Visitor Mode"
	else if(depotarea.used_self_destruct)
		alertlevel = "Delta"
	else if(depotarea.called_backup)
		alertlevel = "Red"
	else if(depotarea.local_alarm)
		alertlevel = "Blue"
	else
		alertlevel = "Green"
	data["rows"] += list(list(
		"title" = "Alert Level",
		"status" = alertlevel,
		"buttontitle" = (allowed(user) && check_rights(R_ADMIN, FALSE, user)) ? "(ADMIN) Reset Alert Level" : null,
		"buttonact" = "primary"
	))
	var/has_bot = FALSE
	for(var/mob/living/simple_animal/bot/ed209/syndicate/B in depotarea.list_getmobs(depotarea.guard_list))
		has_bot = TRUE
	data["rows"] += list(list(
		"title" = "Extra Security Forces",
		"status" = !length(depotarea.guard_list) ? "None Present" : null,
		"bullets" = length(depotarea.guard_list) ? depotarea.list_shownames(depotarea.guard_list) : null,
		"buttontitle" = has_bot ? "Recall Sentry Bot" : null,
		"buttonact" = "secondary",
		"buttondisabled" = !allowed(user),
		"buttontooltip" = "Removes the sentry bot, but increases the alert level."
	))
	data["rows"] += list(list(
		"title" = "Logs",
		"status" = !length(depotarea.alert_log) ? "None" : null,
		"bullets" = depotarea.alert_log // this is naturally a list
	))
	data["rows"] += list(list(
		"title" = "Terminated Intruders",
		"status" = !length(depotarea.dead_list) ? "None" : null,
		"bullets" = length(depotarea.dead_list) ? depotarea.list_shownames(depotarea.dead_list) : null
	))
	data["rows"] += list(list(
		"title" = "Visiting Agents",
		"status" = !length(depotarea.peaceful_list) ? "None" : null,
		"bullets" = length(depotarea.peaceful_list) ? depotarea.list_shownames(depotarea.peaceful_list) : null
	))
	return data

/obj/machinery/computer/syndicate_depot/aiterminal/primary(mob/user)
	if(!check_rights(R_ADMIN, FALSE, user))
		return
	if(!istype(depotarea))
		return
	if(depotarea.on_peaceful)
		depotarea.peaceful_mode(FALSE, TRUE)
	else
		depotarea.reset_alert()
	to_chat(user, "Alert level reset.")
	playsound(user, sound_yes, 50, 0)

/obj/machinery/computer/syndicate_depot/aiterminal/secondary(mob/user)
	for(var/mob/living/simple_animal/bot/ed209/syndicate/B in depotarea.list_getmobs(depotarea.guard_list))
		depotarea.list_remove(B, depotarea.guard_list)
		new /obj/effect/portal(get_turf(B))
		to_chat(user, "[B] has been recalled.")
		qdel(B)
		raise_alert("Sentry bot removed via emergency recall.")
	playsound(user, sound_yes, 50, 0)
