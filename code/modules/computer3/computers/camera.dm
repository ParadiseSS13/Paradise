/*
	Camera monitoring computers

	NOTE: If we actually split the station camera network into regions that will help with sorting through the
	tediously large list of cameras.  The new camnet_key architecture lets you switch between keys easily,
	so you don't lose the capability of seeing everything, you just switch to a subnet.
*/

/obj/machinery/computer3/security
	default_prog		= /datum/file/program/security
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/cameras)
	spawn_files 		= list(/datum/file/camnet_key)
	icon_state			= "frame-sec"


/obj/machinery/computer3/security/wooden_tv
	name				= "security cameras console"
	desc				= "An old TV hooked into the stations camera network."
	icon				= 'icons/obj/computer.dmi'
	icon_state			= "security_det"

	legacy_icon			= 1
	allow_disassemble	= 0

	// No operating system
	New()
		..(built=0)
		os = program
		circuit.OS = os


/obj/machinery/computer3/security/mining
	name = "outpost cameras console"
	desc = "Used to access the various cameras on the outpost."
	spawn_files 		= list(/datum/file/camnet_key/miningoutpost)

/*
	Camera monitoring computers, wall-mounted
*/
/obj/machinery/computer3/wall_comp/telescreen
	default_prog		= /datum/file/program/security
	spawn_parts			= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/cameras)
	spawn_files 		= list(/datum/file/camnet_key)

/obj/machinery/computer3/wall_comp/telescreen/entertainment
	desc = "Damn, they better have Paradise Channel on these things."
	spawn_files 		= list(/datum/file/camnet_key/entertainment)


/*
	File containing an encrypted camera network key.

	(Where by encrypted I don't actually mean encrypted at all)
*/
/datum/file/camnet_key
	name = "Security Camera Network Main Key"
	var/title = "Station"
	var/desc = "Connects to station security cameras."
	var/list/networks = list("SS13")
	var/screen = "cameras"

	execute(var/datum/file/source)
		if(istype(source,/datum/file/program/security))
			var/datum/file/program/security/prog = source
			prog.key = src
			prog.camera_list = null
			return
		if(istype(source,/datum/file/program/ntos))
			for(var/obj/item/part/computer/storage/S in list(computer.hdd,computer.floppy))
				for(var/datum/file/F in S.files)
					if(istype(F,/datum/file/program/security))
						var/datum/file/program/security/Sec = F
						Sec.key = src
						Sec.camera_list = null
						Sec.execute(source)
						return
		computer.Crash(MISSING_PROGRAM)

/datum/file/camnet_key/telecomms
	name = "Telecomms Network Key"
	title = "telecommunications satellite"
	desc = "Connects to telecommunications satellite security cameras."
	networks = list("Telecomms")

/datum/file/camnet_key/researchoutpost
	name = "Research Outpost Network Key"
	title = "research outpost"
	desc = "Connects to research outpost security cameras."
	networks = list("Research Outpost")

/datum/file/camnet_key/miningoutpost
	name = "Mining Outpost Network Key"
	title = "mining outpost"
	desc = "Connects to mining outpost security cameras."
	networks = list("Mining Outpost")
	screen = "miningcameras"

/datum/file/camnet_key/research
	name = "Research Network Key"
	title = "research"
	desc = "Connects to research security cameras."
	networks = list("Research")

/datum/file/camnet_key/prison
	name = "Prison Network Key"
	title = "prison"
	desc = "Connects to prison security cameras."
	networks = list("Prison")

/datum/file/camnet_key/interrogation
	name = "Interrogation Network Key"
	title = "interrogation"
	desc = "Connects to interrogation security cameras."
	networks = list("Interrogation")

/datum/file/camnet_key/supermatter
	name = "Supermatter Network Key"
	title = "supermatter"
	desc = "Connects to supermatter security cameras."
	networks = list("Supermatter")

/datum/file/camnet_key/singularity
	name = "Singularity Network Key"
	title = "singularity"
	desc = "Connects to singularity security cameras."
	networks = list("Singularity")

/datum/file/camnet_key/anomalyisolation
	name = "Anomaly Isolation Network Key"
	title = "anomalyisolation"
	desc = "Connects to interrogation security cameras."
	networks = list("Anomaly Isolation")

/datum/file/camnet_key/toxins
	name = "Toxins Network Key"
	title = "toxins"
	desc = "Connects to toxins security cameras."
	networks = list("Toxins")

/datum/file/camnet_key/telepad
	name = "Telepad Network Key"
	title = "telepad"
	desc = "Connects to telepad security cameras."
	networks = list("Telepad")

/datum/file/camnet_key/ert
	name = "Emergency Response Team Network Key"
	title = "emergency response team"
	desc = "Connects to emergency response team security cameras."
	networks = list("ERT")

/datum/file/camnet_key/centcom
	name = "Central Command Network Key"
	title = "central command"
	desc = "Connects to central command security cameras."
	networks = list("CentCom")

/datum/file/camnet_key/thunderdome
	name = "Thunderdome Network Key"
	title = "thunderdome"
	desc = "Connects to thunderdome security cameras."
	networks = list("Thunderdome")

/datum/file/camnet_key/entertainment
	name = "Entertainment Network Key"
	title = "entertainment"
	desc = "Connects to entertainment security cameras."
	networks = list("news")


/*
	Computer part needed to connect to cameras
*/

/obj/item/part/computer/networking/cameras
	name = "camera network access module"
	desc = "Connects a computer to the camera network."

	// I have no idea what the following does
	var/mapping = 0//For the overview file, interesting bit of code.

	//proc/camera_list(var/datum/file/camnet_key/key)
	get_machines(var/datum/file/camnet_key/key)
		if(!computer || !is_away_level(computer.z))
			return null

		var/list/L = list()
		for(var/obj/machinery/camera/C in cameranet.cameras)
			var/list/temp = C.network & key.networks
			if(temp.len)
				L.Add(C)


		return L
	verify_machine(var/obj/machinery/camera/C,var/datum/file/camnet_key/key = null)
		if(!istype(C) || !C.can_use())
			return 0

		if(key)
			var/list/temp = C.network & key.networks
			if(!temp.len)
				return 0
		return 1

/*
	Camera monitoring program

	The following things should break you out of the camera view:
	* The computer resetting, being damaged, losing power, etc
	* The program quitting
	* Closing the window
	* Going out of range of the computer
	* Becoming incapacitated
	* The camera breaking, emping, disconnecting, etc
*/

/datum/file/program/security
	name			= "camera monitor"
	desc			= "Connets to the Nanotrasen Camera Network"
	image			= 'icons/ntos/camera.png'
	active_state	= "camera-static"

	var/datum/file/camnet_key/key = null
	var/last_pic = 1.0
	var/last_camera_refresh = 0
	var/camera_list = null

	var/obj/machinery/camera/current = null

	execute(var/datum/file/program/caller)
		..(caller)
		if(computer && !key)
			var/list/fkeys = computer.list_files(/datum/file/camnet_key)
			if(fkeys && fkeys.len)
				key = fkeys[1]
			update_icon()
			computer.update_icon()
			for(var/mob/living/L in viewers(1))
				if(!istype(L,/mob/living/silicon/ai) && L.machine == src)
					L.reset_view(null)


	Reset()
		..()
		current = null
		for(var/mob/living/L in viewers(1))
			if(!istype(L,/mob/living/silicon/ai) && L.machine == src)
				L.reset_view(null)

	interact()
		if(!interactable())
			return

		if(!computer.camnet)
			computer.Crash(MISSING_PERIPHERAL)
			return

		if(!key)
			var/list/fkeys = computer.list_files(/datum/file/camnet_key)
			if(fkeys && fkeys.len)
				key = fkeys[1]
			update_icon()
			computer.update_icon()
			if(!key)
				return

		if(computer.camnet.verify_machine(current))
			usr.reset_view(current)

		if(world.time - last_camera_refresh > 50 || !camera_list)
			last_camera_refresh = world.time

			var/list/temp_list = computer.camnet.get_machines(key)

			camera_list = "Network Key: [key.title] [topic_link(src,"keyselect","\[ Select key \]")]<hr>"
			for(var/obj/machinery/camera/C in temp_list)
				if(C.status)
					camera_list += "[C.c_tag] - [topic_link(src,"show=\ref[C]","Show")]<br>"
				else
					camera_list += "[C.c_tag] - <b>DEACTIVATED</b><br>"
			//camera_list += "<br>" + topic_link(src,"close","Close")

		popup.set_content(camera_list)
		popup.open()


	update_icon()
		if(key)
			overlay.icon_state = key.screen
			name = key.title + " Camera Monitor"
		else
			overlay.icon_state = "camera-static"
			name = initial(name)



	Topic(var/href,var/list/href_list)
		if(!interactable() || !computer.camnet || ..(href,href_list))
			return

		if("show" in href_list)
			var/obj/machinery/camera/C = locate(href_list["show"])
			if(istype(C) && C.status)
				current = C
				usr.reset_view(C)
				interact()
				return

		if("keyselect" in href_list)
			current = null
			usr.reset_view(null)
			key = input(usr,"Select a camera network key:", "Key Select", null) as null|anything in computer.list_files(/datum/file/camnet_key)
			camera_list = null
			update_icon()
			computer.update_icon()
			if(key)
				interact()
			else
				to_chat(usr, "The screen turns to static.")
			return

			// Atlantis: Required for camnetkeys to work.
/datum/file/program/security/hidden
	hidden_file = 1
