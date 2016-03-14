/obj/machinery/computer/drone_control
	name = "maintenance drone control console"
	desc = "Used to monitor the station's drone population and the assembler that services them."
	icon_screen = "power"
	icon_keyboard = "power_key"
	req_access = list(access_engine_equip)
	circuit = /obj/item/weapon/circuitboard/drone_control

	//Used when pinging drones.
	var/drone_call_area = "Engineering"
	//Used to enable or disable drone fabrication.
	var/obj/machinery/drone_fabricator/dronefab

/obj/machinery/computer/drone_control/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/drone_control/attack_hand(var/mob/user as mob)
	if(..())
		return

	if(!allowed(user))
		user << "<span class='warning'>Access denied.</span>"
		return

	interact(user)

/obj/machinery/computer/drone_control/attack_ghost(mob/user as mob)
	interact(user)

/obj/machinery/computer/drone_control/interact(mob/user)

	user.set_machine(src)
	var/dat
	dat += "<B>Maintenance Units</B><BR>"

	for(var/mob/living/silicon/robot/drone/D in world)
		dat += "<BR>[D.real_name] ([D.stat == 2 ? "<font color='red'>INACTIVE" : "<font color='green'>ACTIVE"]</FONT>)"
		dat += "<font dize = 9><BR>Cell charge: [D.cell.charge]/[D.cell.maxcharge]."
		dat += "<BR>Currently located in: [get_area(D)]."
		dat += "<BR><A href='?src=\ref[src];resync=\ref[D]'>Resync</A> | <A href='?src=\ref[src];shutdown=\ref[D]'>Shutdown</A></font>"

	dat += "<BR><BR><B>Request drone presence in area:</B> <A href='?src=\ref[src];setarea=1'>[drone_call_area]</A> (<A href='?src=\ref[src];ping=1'>Send ping</A>)"

	dat += "<BR><BR><B>Drone fabricator</B>: "
	dat += "[dronefab ? "<A href='?src=\ref[src];toggle_fab=1'>[(dronefab.produce_drones && !(dronefab.stat & NOPOWER)) ? "ACTIVE" : "INACTIVE"]</A>" : "<font color='red'><b>FABRICATOR NOT DETECTED.</b></font> (<A href='?src=\ref[src];search_fab=1'>search</a>)"]"
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return


/obj/machinery/computer/drone_control/Topic(href, href_list)
	if(..())
		return

	if(!allowed(usr))
		usr << "<span class='warning'>Access denied.</span>"
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	if (href_list["setarea"])

		//Probably should consider using another list, but this one will do.
		var/t_area = input("Select the area to ping.", "Set Target Area", null) as null|anything in TAGGERLOCATIONS

		if(!t_area || TAGGERLOCATIONS[t_area])
			return

		drone_call_area = t_area
		usr << "<span class='notice'>You set the area selector to [drone_call_area].</span>"

	else if (href_list["ping"])

		usr << "<span class='notice'>You issue a maintenance request for all active drones, highlighting [drone_call_area].</span>"
		for(var/mob/living/silicon/robot/drone/D in world)
			if(D.client && D.stat == 0)
				D << "-- Maintenance drone presence requested in: [drone_call_area]."

	else if (href_list["resync"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["resync"])

		if(D.stat != 2)
			usr << "<span class='warning'>You issue a law synchronization directive for the drone.</span>"
			D.law_resync()

	else if (href_list["shutdown"])

		var/mob/living/silicon/robot/drone/D = locate(href_list["shutdown"])

		if(D.stat != 2)
			usr << "<span class='warning'>You issue a kill command for the unfortunate drone.</span>"
			message_admins("[key_name_admin(usr)] issued kill order for drone [key_name_admin(D)] from control console.")
			log_game("[key_name(usr)] issued kill order for [key_name(src)] from control console.")
			D.shut_down()

	else if (href_list["search_fab"])
		if(dronefab)
			return

		for(var/obj/machinery/drone_fabricator/fab in oview(3,src))

			if(fab.stat & NOPOWER)
				continue

			dronefab = fab
			usr << "<span class='notice'>Drone fabricator located.</span>"
			return

		usr << "<span class='warning'>Unable to locate drone fabricator.</span>"

	else if (href_list["toggle_fab"])

		if(!dronefab)
			return

		if(get_dist(src,dronefab) > 3)
			dronefab = null
			usr << "<span class='warning'>Unable to locate drone fabricator.</span>"
			return

		dronefab.produce_drones = !dronefab.produce_drones
		usr << "\blue You [dronefab.produce_drones ? "enable" : "disable"] drone production in the nearby fabricator."

	src.updateUsrDialog()
