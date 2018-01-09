
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
	var/alerts_when_broken = TRUE


/obj/machinery/computer/syndicate_depot/New()
	. = ..()
	depotarea = areaMaster

/obj/machinery/computer/syndicate_depot/attack_ai(var/mob/user)
	if(req_access.len && !("syndicate" in user.faction))
		to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
		return 1
	return ..()

/obj/machinery/computer/syndicate_depot/emp_act(severity)
	return

/obj/machinery/computer/syndicate_depot/emag_act(var/mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this console are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/computer/syndicate_depot/allowed(var/mob/user)
	if(user.can_advanced_admin_interact())
		return 1
	if(!isliving(user))
		return 0
	if(has_security_lockout(user))
		return 0
	return ..()

/obj/machinery/computer/syndicate_depot/proc/has_security_lockout(var/mob/user)
	if(security_lockout)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='userdanger'>[src] is under security lockout.</span>")
		return TRUE
	return FALSE

/obj/machinery/computer/syndicate_depot/proc/activate_security_lockout()
	security_lockout = TRUE
	disable_special_functions()

/obj/machinery/computer/syndicate_depot/attack_hand(var/mob/user as mob)
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
	return


/obj/machinery/computer/syndicate_depot/set_broken()
	. = ..()
	if(alerts_when_broken)
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
	return

/obj/machinery/computer/syndicate_depot/Destroy()
	disable_special_functions()
	if(alerts_when_broken)
		raise_alert("[src] destroyed.")
	return ..()


/obj/machinery/computer/syndicate_depot/proc/get_menu(var/mob/user)
	return ""

/obj/machinery/computer/syndicate_depot/proc/primary(var/mob/user)
	if(!allowed(user))
		return 1
	return 0

/obj/machinery/computer/syndicate_depot/proc/secondary(var/mob/user, var/subcommand)
	if(!allowed(user))
		return 1
	return 0

/obj/machinery/computer/syndicate_depot/proc/raise_alert(var/reason)
	if(depotarea)
		depotarea.increase_alert(reason)



// Door Control Computer

/obj/machinery/computer/syndicate_depot/doors
	name = "depot door control computer"

/obj/machinery/computer/syndicate_depot/doors/get_menu(var/mob/user)
	return {"<B>Syndicate Depot Door Control Computer</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Toggle Airlocks</a>
	<BR><BR><a href='?src=[UID()];secondary=1'>Toggle Hidden Doors</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/doors/primary(var/mob/user)
	if(..())
		return
	if(depotarea)
		depotarea.toggle_door_locks(src)
		to_chat(user, "<span class='notice'>Door locks toggled.</span>")

/obj/machinery/computer/syndicate_depot/doors/secondary(var/mob/user, var/subcommand)
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

/obj/machinery/computer/syndicate_depot/selfdestruct/get_menu(var/mob/user)
	return {"<B>Syndicate Depot Fission Reactor Control</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Disable Containment Field</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/selfdestruct/primary(var/mob/user)
	if(..())
		return
	if(depotarea.used_self_destruct)
		playsound(user, sound_no, 50, 0)
		return
	playsound(user, sound_click, 20, 1)
	if(depotarea)
		depotarea.activate_self_destruct("Fusion reactor containment failure. All hands, evacuate. All hands, evacuate. Core breach imminent!", TRUE, user)



// Syndicate comms computer, used to activate visitor mode, and message syndicate. Traitor-only use.

/obj/machinery/computer/syndicate_depot/syndiecomms
	name = "syndicate communications computer"
	icon_screen = "syndishuttle"
	req_access = list()
	var/message_sent = FALSE

/obj/machinery/computer/syndicate_depot/syndiecomms/get_menu(var/mob/user)
	var/menu = "<B>Syndicate Communications Relay</B><HR>"
	if(message_sent)
		menu += "<BR><BR>Communications quota used. Unable to transmit messages at this time."
	else
		menu += "<BR><BR><a href='?src=[UID()];primary=1'>Contact Syndicate Command (one-time use)</a>"
	if(depotarea.on_peaceful)
		if(user in depotarea.peaceful_visitors)
			menu += "<BR><BR>[user] is recognized as a friendly visitor to the depot."
		else
			menu += "<BR><BR><span class='warning'>(SYNDIE AGENT)</span>  <a href='?src=[UID()];secondary=[DEPOT_VISITOR_ADD]'>Request visitor access (in addition to existing visitors)</a>"
		if(check_rights(R_ADMIN, 0, user))
			menu += "<BR><BR><span class='warning'>(ADMIN/DEBUG)</span> <a href='?src=[UID()];secondary=[DEPOT_VISITOR_END]'>End visit. Re-power defense grid.</a></a>"
	else
		menu += "<BR><BR><span class='warning'>(SYNDIE AGENT)</span> <a href='?src=[UID()];secondary=[DEPOT_VISITOR_START]'>Request visitor access</a>"
	return menu

/obj/machinery/computer/syndicate_depot/syndiecomms/primary(var/mob/user)
	if(..())
		return
	if(message_sent)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='userdanger'>[src] has already been used to transmit a message to the Syndicate.</span>")
		return
	message_sent = TRUE
	if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
		var/input = stripped_input(user, "Please choose a message to transmit to Syndicate HQ via quantum entanglement.  Transmission does not guarantee a response. This function may only be used ONCE.", "To abort, send an empty message.", "") as text|null
		if(!input)
			message_sent = FALSE
			return
		Syndicate_announce(input, user)
		to_chat(user, "Message transmitted.")
		log_say("[key_name(user)] has made a Syndicate announcement from the depot: [input]")
	else
		to_chat(user, "<span class='userdanger'>[src] requires authentication with syndicate codewords, which you do not know.</span>")
		raise_alert("Detected unauthorized access to [src]!")

/obj/machinery/computer/syndicate_depot/syndiecomms/secondary(var/mob/user, var/subcommand)
	if(..())
		return
	if(has_security_lockout(user))
		return
	if(depotarea)
		if(depotarea.local_alarm || depotarea.called_backup || depotarea.used_self_destruct)
			to_chat(user, "<span class='userdanger'>[src]: Request denied. Depot under security alert. No visitors permitted.</span>")
		else if(depotarea.on_peaceful)
			if(subcommand == DEPOT_VISITOR_END)
				if(check_rights(R_ADMIN, 0, user))
					depotarea.peaceful_mode(FALSE, TRUE)
			else if (subcommand == DEPOT_VISITOR_ADD)
				if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
					if(user in depotarea.peaceful_visitors)
						to_chat(user, "<span class='userdanger'>[src]: [user], you are already recognized as a depot visitor.</span>")
					else
						grant_syndie_faction(user)
				else
					to_chat(user, "<span class='userdanger'>[src]: Request denied. You are not recognized as an Agent of the Syndicate.</span>")
		else if(subcommand == DEPOT_VISITOR_START)
			if(depotarea.something_looted)
				to_chat(user, "<span class='userdanger'>[src]: Request denied. You have already stolen from us, and NOW you want to claim you are a friend? Die, scum!</span>")
				raise_alert("Thieving con-men detected!")
			else if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
				grant_syndie_faction(user)
				depotarea.peaceful_mode(TRUE, TRUE)
			else
				to_chat(user, "<span class='userdanger'>[src]: Request denied. You are not recognized as an Agent of the Syndicate.</span>")
		else
			to_chat(user, "<span class='userdanger'>[src]: Unrecognized subcommand: [subcommand]</span>")
	else
		to_chat(user, "<span class='userdanger'>[src]: Request denied. Unable to uplink to depot network.</span>")

/obj/machinery/computer/syndicate_depot/syndiecomms/proc/grant_syndie_faction(var/mob/user)
	user.faction += "syndicate"
	depotarea.peaceful_visitors += user
	to_chat(user, "<span class='userdanger'>[src]: Depot access granted for: [user]</span>")

/obj/machinery/computer/syndicate_depot/syndiecomms/power_change()
	. = ..()
	if(!security_lockout && (stat & NOPOWER))
		security_lockout = TRUE
		raise_alert("Powergrid failure.")


// Syndicate teleporter control, used to manage incoming/outgoing teleports

/obj/machinery/computer/syndicate_depot/teleporter
	name = "syndicate teleporter console"
	icon_screen = "telesci"
	icon_keyboard = "teleport_key"
	var/obj/machinery/bluespace_beacon/syndicate/mybeacon
	var/turf/tele_target
	var/tele_area
	var/obj/effect/portal/myportal
	var/portal_enabled = FALSE
	var/portaldir = WEST

/obj/machinery/computer/syndicate_depot/teleporter/New()
	. = ..()
	spawn(10)
		findbeacon()
		choosetarget()
		update_portal()

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
		return TRUE
	return FALSE

/obj/machinery/computer/syndicate_depot/teleporter/proc/choosetarget()
	var/list/possible_lms = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(!is_station_level(L.z))
			continue
		possible_lms |= L
	if(!possible_lms.len)
		message_admins("Error: [src] could not find any station LMs")
		return
	var/obj/effect/landmark/selected_lm = pick(possible_lms)
	tele_area = get_area(selected_lm)
	tele_target = get_turf(selected_lm)

/obj/machinery/computer/syndicate_depot/teleporter/proc/update_portal()
	if(portal_enabled && !myportal)
		if(!tele_target)
			return
		var/turf/portal_turf = get_step(src, portaldir)
		var/obj/effect/portal/P = new(portal_turf, tele_target, src, 0)
		myportal = P
		P.failchance = 0
		P.icon_state = "portal1"
		P.name = "[tele_area] portal"
	else if(!portal_enabled && myportal)
		qdel(myportal)

/obj/machinery/computer/syndicate_depot/teleporter/get_menu(var/mob/user)
	var/menutext = "<B>Syndicate Teleporter Control</B><HR>"
	findbeacon()
	if(mybeacon)
		menutext += {"<BR><BR>(SYNDIE AGENT) <a href='?src=[UID()];primary=1'>Syndicate Teleporter Beacon: [mybeacon.enabled ? "ON" : "OFF"]</a><BR>"}
	else
		menutext += {"<BR><BR>Status: Reconnecting to beacon..."}
	if(check_rights(R_ADMIN, 0, user))
		menutext += {"<BR><BR>(ADMIN/DEBUG) <a href='?src=[UID()];secondary=1'>Syndicate Agent Insertion Portal: [portal_enabled ? "ON" : "OFF"]</a><BR>"}
	return menutext

/obj/machinery/computer/syndicate_depot/teleporter/primary(var/mob/user)
	if(..())
		return
	if(!mybeacon && user)
		to_chat(user, "<span class='notice'>Unable to connect to teleport beacon.</span>")
		return
	var/bresult = mybeacon.toggle()
	to_chat(user, "<span class='notice'>Syndicate Teleporter Beacon: [bresult ? "ONLINE" : "OFFLINE"]</span>")

/obj/machinery/computer/syndicate_depot/teleporter/secondary(var/mob/user)
	if(..())
		return
	if(!check_rights(R_ADMIN, 0, user))
		return
	if(!portal_enabled && myportal)
		to_chat(user, "<span class='notice'>Syndicate Agent Insertion Portal: deactivating... please wait...</span>")
		return
	toggle_portal()
	to_chat(user, "<span class='notice'>Syndicate Agent Insertion Portal: [portal_enabled ? "ONLINE" : "OFFLINE"]</span>")

/obj/machinery/computer/syndicate_depot/teleporter/proc/toggle_portal()
	portal_enabled = !portal_enabled
	update_portal()