
/obj/machinery/computer/syndicate_depot
	name = "depot door control computer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "syndishuttle"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(access_syndicate)
	var/activated = FALSE

/obj/machinery/computer/syndicate_depot/attack_ai(var/mob/user as mob)
	to_chat(user, "<span class='warning'>A firewall blocks your access.</span>")
	return 1

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

/obj/machinery/computer/syndicate_depot/Topic(href, href_list)
	if(..())
		return 1
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
	if(href_list["activate"])
		activate(usr)
	//if(href_list["activate2"])
	//	activate2(usr)
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

/obj/machinery/computer/syndicate_depot/set_broken()
	return
	//summon()
	..()

/obj/machinery/computer/syndicate_depot/proc/get_menu()
	return {"<B>Syndicate Depot Door Control Computer</B><HR>
	<BR><BR><a href='?src=[UID()];activate=1'>Toggle Door Security</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/proc/activate(var/mob/user)
	var/area/syndicate_depot/D = get_area(src)
	if(D)
		D.toggle_door_locks(src)

/obj/machinery/computer/syndicate_depot/proc/raise_alert()
	var/area/syndicate_depot/D = get_area(src)
	if(D)
		D.increase_alert()

/obj/machinery/computer/syndicate_depot/selfdestruct
	name = "reactor control computer"
	req_access = list()
	var/landmark_name = "syndi_depot_reactor"

/obj/machinery/computer/syndicate_depot/selfdestruct/get_menu()
	return {"<B>Syndicate Depot Fission Reactor Control</B><HR>
	<BR><BR><a href='?src=[UID()];activate=1'>Disable Containment Field</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/selfdestruct/activate(var/mob/user)
	if(activated)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return
	activated = TRUE
	playsound(user, 'sound/machines/click.ogg', 20, 1)
	sleep(5)
	var/area/syndicate_depot/D = get_area(src)
	if(D)
		D.activate_self_destruct(TRUE, user)




/obj/machinery/computer/syndicate_depot/syndiecomms
	name = "syndicate communications computer"
	icon_state = "computer"
	req_access = list(access_syndicate)

/obj/machinery/computer/syndicate_depot/syndiecomms/get_menu()
	return {"<B>Syndicate Communications Relay</B><HR>
	<BR><BR><a href='?src=[UID()];activate=1'>Contact Syndicate Command</a>
	<BR>"}

/obj/machinery/computer/syndicate_depot/syndiecomms/activate(var/mob/user)
	if(activated)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(user, "<span class='userdanger'>ERROR: terminal already used.</span>")
		return
	activated = TRUE
	var/is_syndie = FALSE
	if(user.mind && user.mind.special_role == SPECIAL_ROLE_TRAITOR)
		is_syndie = TRUE
	if(is_syndie)
		var/input = stripped_input(user, "Please choose a message to transmit to Syndicate HQ via quantum entanglement.  Transmission does not guarantee a response. This terminal may only be used ONCE.", "To abort, send an empty message.", "") as text|null
		if(!input)
			activated = FALSE
			return
		Syndicate_announce(input, user)
		to_chat(user, "Message transmitted.")
		log_say("[key_name(user)] has made a Syndicate announcement: [input]")
	else
		to_chat(user, "<span class='userdanger'>ERROR: unauthorized access detected. [user] does not work for us.</span>")
		raise_alert()

