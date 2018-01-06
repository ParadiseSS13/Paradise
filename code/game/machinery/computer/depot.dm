
/obj/machinery/computer/syndicate_depot
	name = "depot door control computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "tcboss"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(access_syndicate)
	var/activated = FALSE
	var/sound_yes = 'sound/machines/twobeep.ogg'
	var/sound_no = 'sound/machines/buzz-sigh.ogg'
	var/sound_click = 'sound/machines/click.ogg'
	var/area/syndicate_depot/depotarea
	var/alerts_when_broken = TRUE

/obj/machinery/computer/syndicate_depot/New()
	. = ..()
	depotarea = areaMaster

/obj/machinery/computer/syndicate_depot/attack_ai(var/mob/user as mob)
	if(req_access.len)
		to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
		return 1
	..()

/obj/machinery/computer/syndicate_depot/emp_act(severity)
	return

/obj/machinery/computer/syndicate_depot/attackby(I as obj, user as mob, params)
	if(istype(I,/obj/item/weapon/card/emag))
		to_chat(user, "<span class='notice'>The electronic systems in this console is far too advanced for your primitive hacking peripherals.</span>")
	else
		return attack_hand(user)

/obj/machinery/computer/syndicate_depot/allowed(var/mob/user)
	if(user.can_admin_interact())
		return 1
	return ..()

/obj/machinery/computer/syndicate_depot/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return
	user.set_machine(src)
	var/dat = get_menu()
	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/syndicate_depot/set_broken()
	. = ..()
	if(alerts_when_broken)
		raise_alert("[src] destroyed.")

/obj/machinery/computer/syndicate_depot/Topic(href, href_list)
	if(..())
		return 1
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
	if(href_list["primary"])
		primary(usr)
	if(href_list["secondary"])
		secondary(usr)
	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/syndicate_depot/proc/summon()
	var/area/syndicate_depot/A = areaMaster
	if(A)
		A.call_backup(src)

/obj/machinery/computer/syndicate_depot/Destroy()
	summon()
	return ..()

/obj/machinery/computer/syndicate_depot/proc/get_menu()
	return {"<B>Syndicate Depot Door Control Computer</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Toggle Airlocks</a>
	<BR><BR><a href='?src=[UID()];secondary=1'>Toggle Hidden Doors</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/proc/primary(var/mob/user)
	if(depotarea)
		depotarea.toggle_door_locks(src)
		to_chat(user, "<span class='notice'>Door locks toggled.</span>")

/obj/machinery/computer/syndicate_depot/proc/secondary(var/mob/user)
	if(depotarea)
		depotarea.toggle_falsewalls(src)
		to_chat(user, "<span class='notice'>False walls toggled.</span>")

/obj/machinery/computer/syndicate_depot/proc/raise_alert(var/reason)
	if(depotarea)
		depotarea.increase_alert(reason)



/obj/machinery/computer/syndicate_depot/selfdestruct
	name = "reactor control computer"
	icon_screen = "explosive"
	req_access = list()

/obj/machinery/computer/syndicate_depot/selfdestruct/get_menu()
	return {"<B>Syndicate Depot Fission Reactor Control</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Disable Containment Field</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/selfdestruct/primary(var/mob/user)
	if(activated)
		playsound(user, sound_no, 50, 0)
		return
	activated = TRUE
	playsound(user, sound_click, 20, 1)
	if(depotarea)
		depotarea.activate_self_destruct("Fusion reactor containment failure. All hands, evacuate. All hands, evacuate. Core breach imminent!", TRUE, user)




/obj/machinery/computer/syndicate_depot/syndiecomms
	name = "syndicate communications computer"
	icon_screen = "syndishuttle"
	req_access = list()

/obj/machinery/computer/syndicate_depot/syndiecomms/get_menu()
	return {"<B>Syndicate Communications Relay</B><HR>
	<BR><BR><a href='?src=[UID()];primary=1'>Contact Syndicate Command</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/syndiecomms/primary(var/mob/user)
	if(activated)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='userdanger'>ERROR: terminal already used.</span>")
		return
	activated = TRUE
	if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
		var/input = stripped_input(user, "Please choose a message to transmit to Syndicate HQ via quantum entanglement.  Transmission does not guarantee a response. This terminal may only be used ONCE.", "To abort, send an empty message.", "") as text|null
		if(!input)
			activated = FALSE
			return
		Syndicate_announce(input, user)
		to_chat(user, "Message transmitted.")
		log_say("[key_name(user)] has made a Syndicate announcement from the depot: [input]")
	else
		to_chat(user, "<span class='userdanger'>ERROR: unauthorized access detected.</span>")
		raise_alert("Detected unauthorized access to [src]!")

/obj/machinery/computer/syndicate_depot/syndiecomms/power_change()
	. = ..()
	if(!activated && (stat & NOPOWER))
		activated = TRUE
		raise_alert("Powergrid failure.")

/obj/machinery/computer/syndicate_depot/teleporter
	name = "syndicate teleporter console"
	icon_screen = "telesci"
	icon_keyboard = "teleport_key"
	var/obj/machinery/bluespace_beacon/syndicate/mybeacon

/obj/machinery/computer/syndicate_depot/teleporter/New()
	. = ..()
	spawn(10)
		findbeacon()

/obj/machinery/computer/syndicate_depot/teleporter/proc/findbeacon()
	for(var/obj/machinery/bluespace_beacon/syndicate/B in myArea)
		mybeacon = B
		playsound(loc, sound_yes, 50, 0)
		return TRUE
	playsound(loc, sound_no, 50, 0)
	return FALSE

/obj/machinery/computer/syndicate_depot/teleporter/get_menu()
	var/menutext = "<B>Syndicate Teleporter Control</B><HR>"
	if(mybeacon)
		menutext += {"<BR><BR><a href='?src=[UID()];primary=1'>Syndicate Teleporter Beacon: [mybeacon.enabled ? "ON" : "OFF"]</a><BR>"}
	else
		findbeacon()
		menutext += {"<BR><BR>Status: Reconnecting to beacon..."}
	return menutext

/obj/machinery/computer/syndicate_depot/teleporter/primary(var/mob/user)
	activated = TRUE
	if(!mybeacon && user)
		to_chat(user, "<span class='notice'>Unable to connect to teleport beacon.</span>")
		return
	var/bresult = mybeacon.toggle()
	to_chat(user, "<span class='notice'>Syndicate Teleporter Beacon: [bresult ? "ONLINE" : "OFFLINE"]</span>")
