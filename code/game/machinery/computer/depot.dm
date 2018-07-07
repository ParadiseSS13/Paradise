
#define DEPOT_VISITOR_START	1
#define DEPOT_VISITOR_END	2
#define DEPOT_VISITOR_ADD	3


// Generic parent depot computer type

/obj/machinery/computer/syndicate_depot
	name = "depot computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "tcboss"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(access_syndicate)
	var/security_lockout = FALSE
	var/sound_yes = 'sound/machines/twobeep.ogg'
	var/sound_no = 'sound/machines/buzz-sigh.ogg'
	var/sound_click = 'sound/machines/click.ogg'
	var/area/syndicate_depot/depotarea
	var/alerts_when_broken = FALSE
	var/has_alerted = FALSE


/obj/machinery/computer/syndicate_depot/New()
	. = ..()
	depotarea = areaMaster

/obj/machinery/computer/syndicate_depot/attack_ai(mob/user)
	if(req_access.len && !("syndicate" in user.faction))
		to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
		return 1
	return ..()

/obj/machinery/computer/syndicate_depot/emp_act(severity)
	return

/obj/machinery/computer/syndicate_depot/emag_act(mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this console are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/computer/syndicate_depot/allowed(mob/user)
	if(user.can_advanced_admin_interact())
		return 1
	if(!isliving(user))
		return 0
	if(has_security_lockout(user))
		return 0
	return ..()

/obj/machinery/computer/syndicate_depot/proc/has_security_lockout(mob/user)
	if(security_lockout)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='warning'>[src] is under security lockout.</span>")
		return TRUE
	return FALSE

/obj/machinery/computer/syndicate_depot/proc/activate_security_lockout()
	security_lockout = TRUE
	disable_special_functions()

/obj/machinery/computer/syndicate_depot/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return
	user.set_machine(src)
	var/dat = get_menu(user)
	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")


/obj/machinery/computer/syndicate_depot/set_broken()
	. = ..()
	if(alerts_when_broken && !has_alerted)
		has_alerted = TRUE
		raise_alert("[src] damaged.")
	disable_special_functions()

/obj/machinery/computer/syndicate_depot/proc/disable_special_functions()
	return

/obj/machinery/computer/syndicate_depot/Topic(href, href_list)
	if(..())
		return 1
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
	if(href_list["primary"])
		primary(usr)
	if(href_list["secondary"])
		secondary(usr, text2num(href_list["secondary"]))
	add_fingerprint(usr)
	updateUsrDialog()

/obj/machinery/computer/syndicate_depot/Destroy()
	disable_special_functions()
	if(alerts_when_broken && !has_alerted)
		raise_alert("[src] destroyed.")
	return ..()


/obj/machinery/computer/syndicate_depot/proc/get_menu(mob/user)
	return ""

/obj/machinery/computer/syndicate_depot/proc/primary(mob/user)
	if(!allowed(user))
		return 1
	return 0

/obj/machinery/computer/syndicate_depot/proc/secondary(mob/user, subcommand)
	if(!allowed(user))
		return 1
	return 0

/obj/machinery/computer/syndicate_depot/proc/raise_alert(reason)
	if(depotarea)
		depotarea.increase_alert(reason)



// Door Control Computer

/obj/machinery/computer/syndicate_depot/doors
	name = "depot door control computer"

/obj/machinery/computer/syndicate_depot/doors/get_menu(mob/user)
	return {"<B>Syndicate Depot Door Control Computer</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Toggle Airlock Emergency Access</a>
	<BR><BR><a href='?src=[UID()];secondary=1'>Toggle Hidden Doors</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/doors/primary(mob/user)
	if(..())
		return
	if(depotarea)
		depotarea.toggle_door_locks(src)
		to_chat(user, "<span class='notice'>Door locks toggled.</span>")

/obj/machinery/computer/syndicate_depot/doors/secondary(mob/user, subcommand)
	if(..())
		return
	if(depotarea)
		depotarea.toggle_falsewalls(src)
		to_chat(user, "<span class='notice'>False walls toggled.</span>")


// Engineering AKA self destruct computer, no useful functions, just a trap for the people who can't resist pushing dangerous-sounding buttons.

/obj/machinery/computer/syndicate_depot/selfdestruct
	name = "reactor control computer"
	icon_screen = "explosive"
	req_access = list()
	alerts_when_broken = TRUE

/obj/machinery/computer/syndicate_depot/selfdestruct/get_menu(mob/user)
	var menutext = {"<B>Syndicate Depot Fusion Reactor Control</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Disable Containment Field</a>
	<BR>"}
	if(check_rights(R_ADMIN, 0, user))
		menutext += {"(ADMIN) Defense Shield: [depotarea.deployed_shields.len ? "ON" : "OFF"] (<a href='?src=[UID()];secondary=1'>[depotarea.deployed_shields.len ? "Disable" : "Enable"]</a>)<BR>"}
	return menutext

/obj/machinery/computer/syndicate_depot/selfdestruct/primary(mob/user)
	if(..())
		return
	if(depotarea.used_self_destruct)
		playsound(user, sound_no, 50, 0)
		return
	playsound(user, sound_click, 20, 1)
	if(depotarea)
		depotarea.activate_self_destruct("Fusion reactor containment field disengaged. All hands, evacuate. All hands, evacuate!", TRUE, user)


/obj/machinery/computer/syndicate_depot/selfdestruct/secondary(mob/user)
	if(..())
		return
	if(!check_rights(R_ADMIN, 0, user))
		return
	if(!istype(depotarea))
		return
	if(depotarea.deployed_shields.len)
		depotarea.shields_down()
	else
		depotarea.shields_up()


// Syndicate comms computer, used to activate visitor mode, and message syndicate. Traitor-only use.

/obj/machinery/computer/syndicate_depot/syndiecomms
	name = "syndicate communications computer"
	icon_screen = "syndishuttle"
	req_access = list()
	alerts_when_broken = TRUE
	var/message_sent = FALSE

/obj/machinery/computer/syndicate_depot/syndiecomms/New()
	. = ..()
	if(depotarea)
		depotarea.comms_computer = src

/obj/machinery/computer/syndicate_depot/syndiecomms/get_menu(mob/user)
	var/menu = "<B>Syndicate Communications Relay</B><HR>"
	menu += "<BR><BR>One-Time Uplink to Syndicate HQ: [message_sent ? "ALREADY USED" : "AVAILABLE (<a href='?src=[UID()];primary=1'>Open Channel</a>)"]"
	if(depotarea.on_peaceful)
		menu += "<BR><BR>Visiting Agents: VISIT IN PROGRESS. "
		if(user in depotarea.peaceful_visitors)
			menu += "[user] IS RECOGNIZED AS VISITING AGENT"
		else
			menu += "[user] NOT RECOGNIZED. (<a href='?src=[UID()];secondary=[DEPOT_VISITOR_ADD]'>Sign-in as Agent</a>)"
		if(check_rights(R_ADMIN, 0, user))
			menu += "<BR><BR>ADMIN: (<a href='?src=[UID()];secondary=[DEPOT_VISITOR_END]'>End Visitor Mode</a>)"

	else
		menu += "<BR><BR>Visiting Agents: NONE (<a href='?src=[UID()];secondary=[DEPOT_VISITOR_START]'>Sign-in as Agent</a>)"
	return menu

/obj/machinery/computer/syndicate_depot/syndiecomms/primary(mob/user)
	if(..())
		return
	if(!isliving(user))
		to_chat(user, "ERROR: No lifesigns detected at terminal, aborting.") // Safety to prevent aghosts accidentally pressing it and getting everyone killed.
		return
	if(message_sent)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='warning'>[src] has already been used to transmit a message to the Syndicate.</span>")
		return
	message_sent = TRUE
	if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
		var/input = stripped_input(user, "Please choose a message to transmit to Syndicate HQ via quantum entanglement.  Transmission does not guarantee a response. This function may only be used ONCE.", "To abort, send an empty message.", "") as text|null
		if(!input)
			message_sent = FALSE
			return
		Syndicate_announce(input, user)
		to_chat(user, "Message transmitted.")
		log_say("[key_name(user)] has sent a Syndicate comms message from the depot: [input]", user)
	else
		to_chat(user, "<span class='warning'>[src] requires authentication with syndicate codewords, which you do not know.</span>")
		raise_alert("Detected unauthorized access by [user] to [src]!")
	updateUsrDialog()

/obj/machinery/computer/syndicate_depot/syndiecomms/secondary(mob/user, subcommand)
	if(..())
		return
	if(has_security_lockout(user))
		return
	if(depotarea)
		if(depotarea.local_alarm || depotarea.called_backup || depotarea.used_self_destruct)
			to_chat(user, "<span class='warning'>Visitor sign-in is not possible while the depot is on security alert.</span>")
		else if(depotarea.on_peaceful)
			if(subcommand == DEPOT_VISITOR_END)
				if(check_rights(R_ADMIN, 0, user))
					depotarea.peaceful_mode(FALSE, TRUE)
			else if (subcommand == DEPOT_VISITOR_ADD)
				if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
					if(user in depotarea.peaceful_visitors)
						to_chat(user, "<span class='warning'>[user] is already signed in as a visiting agent.</span>")
					else
						grant_syndie_faction(user)
				else
					to_chat(user, "<span class='warning'>Only verified agents of the Syndicate may sign in as visitors. Everyone else will be shot on sight.</span>")
		else if(subcommand == DEPOT_VISITOR_START)
			if(depotarea.something_looted)
				to_chat(user, "<span class='warning'>Visitor sign-in is not possible after supplies have been taken from the depot.</span>")
			else if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
				grant_syndie_faction(user)
				depotarea.peaceful_mode(TRUE, TRUE)
			else
				to_chat(user, "<span class='warning'>Only verified agents of the Syndicate may sign in as visitors. Everyone else will be shot on sight.</span>")
		else
			to_chat(user, "<span class='warning'>Unrecognized subcommand: [subcommand]</span>")
	else
		to_chat(user, "<span class='warning'>ERROR: [src] is unable to uplink to depot network.</span>")
	updateUsrDialog()

/obj/machinery/computer/syndicate_depot/syndiecomms/proc/grant_syndie_faction(mob/user)
	user.faction += "syndicate"
	depotarea.peaceful_visitors += user
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
	name = "syndicate teleporter console"
	icon_screen = "telesci"
	icon_keyboard = "teleport_key"
	var/obj/machinery/bluespace_beacon/syndicate/mybeacon
	var/obj/effect/portal/myportal
	var/portal_enabled = FALSE
	var/portaldir = WEST

/obj/machinery/computer/syndicate_depot/teleporter/New()
	. = ..()
	spawn(10)
		findbeacon()
		choosetarget()
		update_portal()

/obj/machinery/computer/syndicate_depot/teleporter/Destroy()
	if(mybeacon)
		mybeacon.mycomputer = null
	return ..()

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

/obj/machinery/computer/syndicate_depot/teleporter/proc/choosetarget()
	var/list/eligible_turfs = list()
	for(var/obj/item/radio/beacon/R in beacons)
		var/turf/T = get_turf(R)
		if(!is_station_level(T.z))
			continue
		eligible_turfs += T
	if(eligible_turfs.len)
		return pick(eligible_turfs)
	else
		return FALSE

/obj/machinery/computer/syndicate_depot/teleporter/proc/update_portal()
	if(portal_enabled && !myportal)
		var/turf/tele_target = choosetarget()
		if(!tele_target)
			return
		var/turf/portal_turf = get_step(src, portaldir)
		var/obj/effect/portal/P = new(portal_turf, tele_target, src, 0)
		myportal = P
		P.failchance = 0
		P.icon_state = "portal1"
		P.name = get_area(tele_target) + " portal"
	else if(!portal_enabled && myportal)
		qdel(myportal)
		myportal = null

/obj/machinery/computer/syndicate_depot/teleporter/get_menu(mob/user)
	var/menutext = "<B>Syndicate Teleporter Control</B><HR>"
	findbeacon()
	if(mybeacon)
		menutext += {"<BR><BR>Incoming Teleport Beacon: [mybeacon.enabled ? "ON" : "OFF"] (<a href='?src=[UID()];primary=1'>[mybeacon.enabled ? "Disable" : "Enable"]</a>)<BR>"}
	else
		menutext += {"<BR><BR>Incoming Teleport Beacon: Reconnecting to beacon..."}
	menutext += {"<BR><BR>Outgoing Teleport Portal: [portal_enabled ? "ON" : "OFF"]"}
	if(check_rights(R_ADMIN, 0, user) || (depotarea.on_peaceful && !portal_enabled))
		menutext += {" (<a href='?src=[UID()];secondary=1'>[portal_enabled ? "Disable" : "Enable"]</a>)<BR>"}
	return menutext

/obj/machinery/computer/syndicate_depot/teleporter/primary(mob/user)
	if(..())
		return
	if(!mybeacon && user)
		to_chat(user, "<span class='notice'>Unable to connect to teleport beacon.</span>")
		return
	var/bresult = mybeacon.toggle()
	to_chat(user, "<span class='notice'>Syndicate Teleporter Beacon: [bresult ? "<span class='green'>ON</span>" : "<span class='red'>OFF</span>"]</span>")
	updateUsrDialog()

/obj/machinery/computer/syndicate_depot/teleporter/secondary(mob/user)
	if(..())
		return
	if(!check_rights(R_ADMIN, 0, user) && !(depotarea.on_peaceful && !portal_enabled))
		return
	if(!portal_enabled && myportal)
		to_chat(user, "<span class='notice'>Outgoing Teleport Portal: deactivating... please wait...</span>")
		return
	toggle_portal()
	to_chat(user, "<span class='notice'>Outgoing Teleport Portal: [portal_enabled ? "<span class='green'>ON</span>" : "<span class='red'>OFF</span>"]</span>")
	updateUsrDialog()

/obj/machinery/computer/syndicate_depot/teleporter/proc/toggle_portal()
	portal_enabled = !portal_enabled
	update_portal()


/obj/machinery/computer/syndicate_depot/aiterminal
	name = "syndicate ai terminal"
	icon_screen = "command"
	req_access = list()

/obj/machinery/computer/syndicate_depot/aiterminal/get_menu(mob/user)
	var/menutext = "<B>Syndicate AI Terminal</B><HR><BR>"
	if(!istype(depotarea))
		menutext += "<BR>ERROR: Unable to connect to AI network."
		return menutext

	if(depotarea.alert_log.len)
		menutext += "Event Log:<UL>"
		for(var/thisline in depotarea.alert_log)
			menutext += "<LI>[thisline]</LI>"
		menutext += "</UL>"
	else
		menutext += "Event Log: EMPTY"
	menutext += "<BR>"

	if(depotarea.hostiles_dead.len)
		menutext += "Terminated Intruders:<UL>"
		for(var/mob/thismob in depotarea.hostiles_dead)
			menutext += "<LI>[thismob]</LI>"
		menutext += "</UL>"
	else
		menutext += "Terminated Intruders: NONE"
	menutext += "<BR>"

	if(depotarea.guards_spawned.len)
		menutext += "Extra Security Forces:<UL>"
		for(var/mob/thismob in depotarea.guards_spawned)
			menutext += "<LI>[thismob]</LI>"
		menutext += "</UL>"
	else
		menutext += "Extra Security Forces: NONE"

	menutext += "<BR>"
	if(depotarea.peaceful_visitors.len)
		menutext += "Visiting Agents:<UL>"
		for(var/mob/thismob in depotarea.peaceful_visitors)
			menutext += "<LI>[thismob]</LI>"
		menutext += "</UL>"
	else
		menutext += "Visiting Agents: NONE"
	menutext += "<BR><BR>"
	if(check_rights(R_ADMIN, 0, user))
		if(depotarea.on_peaceful)
			menutext += "<BR><BR>ADMIN: (to end visitor mode, use comms console)"
		else
			menutext += "<BR><BR>ADMIN: (<a href='?src=[UID()];primary=1'>Reset Depot Alert Level</a>)"
	var/has_bot = FALSE
	for(var/mob/living/simple_animal/bot/ed209/syndicate/B in depotarea.guards_spawned)
		has_bot = TRUE
	if(has_bot)
		menutext += "<BR><BR>Sentry Bot: (<a href='?src=[UID()];secondary=1'>issue recall order</a>)"
	else
		menutext += "<BR><BR>Sentry Bot: (none present)"
	return menutext

/obj/machinery/computer/syndicate_depot/aiterminal/primary(mob/user)
	if(..())
		return
	if(!check_rights(R_ADMIN, 0, user))
		return
	if(depotarea)
		depotarea.reset_alert()
		to_chat(user, "Alert level reset.")

/obj/machinery/computer/syndicate_depot/aiterminal/secondary(mob/user)
	if(..())
		return
	for(var/mob/living/simple_animal/bot/ed209/syndicate/B in depotarea.guards_spawned)
		depotarea.guards_spawned -= B
		new /obj/effect/portal(get_turf(B))
		to_chat(user, "[B] has been recalled.")
		qdel(B)
		raise_alert("Sentry bot removed via emergency recall.")