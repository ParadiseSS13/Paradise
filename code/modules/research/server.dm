/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	var/datum/research/files
	var/health = 100
	var/list/id_with_upload = list()		//List of R&D consoles with upload to server access.
	var/list/id_with_download = list()	//List of R&D consoles with download from server access.
	var/id_with_upload_string = ""		//String versions for easy editing in map editor.
	var/id_with_download_string = ""
	var/server_id = 0
	var/heat_gen = 100
	var/heating_power = 40000
	var/delay = 10
	req_access = list(access_rd) //Only the R&D can change server settings.
	var/plays_sound = 0

/obj/machinery/r_n_d/server/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	initialize_serv(); //Agouri // fuck you agouri

/obj/machinery/r_n_d/server/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/rdserver(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()

/obj/machinery/r_n_d/server/Destroy()
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	heat_gen /= max(1, tot_rating)

/obj/machinery/r_n_d/server/proc/initialize_serv()
	if(!files)
		files = new /datum/research(src)
	var/list/temp_list
	if(!id_with_upload.len)
		temp_list = list()
		temp_list = splittext(id_with_upload_string, ";")
		for(var/N in temp_list)
			id_with_upload += text2num(N)
	if(!id_with_download.len)
		temp_list = list()
		temp_list = splittext(id_with_download_string, ";")
		for(var/N in temp_list)
			id_with_download += text2num(N)

/obj/machinery/r_n_d/server/process()
	if(prob(3) && plays_sound)
		playsound(loc, "computer_ambience", 50, 1)

	var/datum/gas_mixture/environment = loc.return_air()
	switch(environment.temperature)
		if(0 to T0C)
			health = min(100, health + 1)
		if(T0C to (T20C + 20))
			health = Clamp(health, 0, 100)
		if((T20C + 20) to (T0C + 70))
			health = max(0, health - 1)
	if(health <= 0)
		/*griefProtection() This seems to get called twice before running any code that deletes/damages the server or it's files anwyay.
							refreshParts and the hasReq procs that get called by this are laggy and do not need to be called by every server on the map every tick */
		var/updateRD = 0
		files.known_designs = list()
		for(var/v in files.known_tech)
			var/datum/tech/T = files.known_tech[v]
			// Slowly decrease research if health drops below 0
			if(prob(1))
				updateRD++
				T.level--
		if(updateRD)
			files.RefreshResearch()
	if(delay)
		delay--
	else
		produce_heat(heat_gen)
		delay = initial(delay)

/obj/machinery/r_n_d/server/emp_act(severity)
	griefProtection()
	..()


/obj/machinery/r_n_d/server/ex_act(severity)
	griefProtection()
	return ..()

/obj/machinery/r_n_d/server/blob_act(obj/structure/blob/B)
	griefProtection()
	return ..()

// Backup files to CentComm to help admins recover data after griefer attacks
/obj/machinery/r_n_d/server/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in GLOB.machines)
		files.push_data(C.files)

/obj/machinery/r_n_d/server/proc/produce_heat(heat_amt)
	if(!(stat & (NOPOWER|BROKEN))) // Blatantly stolen from space heater.
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt+T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000)

				env.merge(removed)
				air_update_turf()

/obj/machinery/r_n_d/server/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(disabled)
		return

	if(shocked)
		shock(user,50)

	if(istype(O, /obj/item/screwdriver))
		default_deconstruction_screwdriver(user, "server_o", "server", O)
		return 1

	if(exchange_parts(user, O))
		return 1

	if(panel_open)
		if(istype(O, /obj/item/crowbar))
			griefProtection()
			default_deconstruction_crowbar(O)
			return 1
	else
		return ..()

/obj/machinery/r_n_d/server/attack_hand(mob/user as mob)
	if(disabled)
		return

	if(shocked)
		shock(user,50)
	return

/obj/machinery/r_n_d/server/centcom
	name = "CentComm. Central R&D Database"
	server_id = -1

/obj/machinery/r_n_d/server/centcom/Initialize()
	..()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/r_n_d/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S

/obj/machinery/r_n_d/server/centcom/process()
	return PROCESS_KILL	//don't need process()


/obj/machinery/computer/rdservercontrol
	name = "\improper R&D server controller"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdservercontrol
	var/screen = 0
	var/obj/machinery/r_n_d/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)
	if(!src.allowed(usr) && !emagged)
		to_chat(usr, "<span class='warning'>You do not have the required access level</span>")
		return

	if(href_list["main"])
		screen = 0

	else if(href_list["access"] || href_list["data"] || href_list["transfer"])
		temp_server = null
		consoles = list()
		servers = list()
		for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
			if(S.server_id == text2num(href_list["access"]) || S.server_id == text2num(href_list["data"]) || S.server_id == text2num(href_list["transfer"]))
				temp_server = S
				break
		if(href_list["access"])
			screen = 1
			for(var/obj/machinery/computer/rdconsole/C in GLOB.machines)
				if(C.sync)
					consoles += C
		else if(href_list["data"])
			screen = 2
		else if(href_list["transfer"])
			screen = 3
			for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
				if(S == src)
					continue
				servers += S

	else if(href_list["upload_toggle"])
		var/num = text2num(href_list["upload_toggle"])
		if(num in temp_server.id_with_upload)
			temp_server.id_with_upload -= num
		else
			temp_server.id_with_upload += num

	else if(href_list["download_toggle"])
		var/num = text2num(href_list["download_toggle"])
		if(num in temp_server.id_with_download)
			temp_server.id_with_download -= num
		else
			temp_server.id_with_download += num

	else if(href_list["reset_tech"])
		var/choice = alert("Technology Data Reset", "Are you sure you want to reset this technology to its default data? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			for(var/I in temp_server.files.known_tech)
				var/datum/tech/T = temp_server.files.known_tech[I]
				if(T.id == href_list["reset_tech"])
					T.level = 1
					break
		temp_server.files.RefreshResearch()

	else if(href_list["reset_design"])
		var/choice = alert("Design Data Deletion", "Are you sure you want to delete this design? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			for(var/I in temp_server.files.known_designs)
				var/datum/design/D = temp_server.files.known_designs[I]
				if(D.id == href_list["reset_design"])
					temp_server.files.known_designs -= D.id
					break
		temp_server.files.RefreshResearch()

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	var/dat = ""

	switch(screen)
		if(0) //Main Menu
			dat += "Connected Servers:<BR><BR>"

			for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
				if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
					continue
				dat += "[S.name] || "
				dat += "<A href='?src=[UID()];access=[S.server_id]'>Access Rights</A> | "
				dat += "<A href='?src=[UID()];data=[S.server_id]'>Data Management</A>"
				if(badmin) dat += " | <A href='?src=[UID()];transfer=[S.server_id]'>Server-to-Server Transfer</A>"
				dat += "<BR>"

		if(1) //Access rights menu
			dat += "[temp_server.name] Access Rights<BR><BR>"
			dat += "Consoles with Upload Access<BR>"
			for(var/obj/machinery/computer/rdconsole/C in consoles)
				var/turf/console_turf = get_turf(C)
				dat += "* <A href='?src=[UID()];upload_toggle=[C.id]'>[console_turf.loc]" //FYI, these are all numeric ids, eventually.
				if(C.id in temp_server.id_with_upload)
					dat += " (Remove)</A><BR>"
				else
					dat += " (Add)</A><BR>"
			dat += "Consoles with Download Access<BR>"
			for(var/obj/machinery/computer/rdconsole/C in consoles)
				var/turf/console_turf = get_turf(C)
				dat += "* <A href='?src=[UID()];download_toggle=[C.id]'>[console_turf.loc]"
				if(C.id in temp_server.id_with_download)
					dat += " (Remove)</A><BR>"
				else
					dat += " (Add)</A><BR>"
			dat += "<HR><A href='?src=[UID()];main=1'>Main Menu</A>"

		if(2) //Data Management menu
			dat += "[temp_server.name] Data Management<BR><BR>"
			dat += "Known Technologies<BR>"
			for(var/I in temp_server.files.known_tech)
				var/datum/tech/T = temp_server.files.known_tech[I]
				if(T.level <= 0)
					continue
				dat += "* [T.name] "
				dat += "<A href='?src=[UID()];reset_tech=[T.id]'>(Reset)</A><BR>" //FYI, these are all strings.
			dat += "Known Designs<BR>"
			for(var/I in temp_server.files.known_designs)
				var/datum/design/D = temp_server.files.known_designs[I]
				dat += "* [D.name] "
				dat += "<A href='?src=[UID()];reset_design=[D.id]'>(Delete)</A><BR>"
			dat += "<HR><A href='?src=[UID()];main=1'>Main Menu</A>"

		if(3) //Server Data Transfer
			dat += "[temp_server.name] Server to Server Transfer<BR><BR>"
			dat += "Send Data to what server?<BR>"
			for(var/obj/machinery/r_n_d/server/S in servers)
				dat += "[S.name] <A href='?src=[UID()];send_to=[S.server_id]'> (Transfer)</A><BR>"
			dat += "<HR><A href='?src=[UID()];main=1'>Main Menu</A>"
	user << browse("<TITLE>R&D Server Control</TITLE><HR>[dat]", "window=server_control;size=575x400")
	onclose(user, "server_control")
	return

/obj/machinery/computer/rdservercontrol/emag_act(user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You you disable the security protocols</span>")
	src.updateUsrDialog()

/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"
	id_with_upload_string = "1;3"
	id_with_download_string = "1;3"
	server_id = 1
	plays_sound = 1

/obj/machinery/r_n_d/server/robotics
	name = "Robotics and Mechanic R&D Server"
	id_with_upload_string = "1;2;4"
	id_with_download_string = "1;2;4"
	server_id = 2
