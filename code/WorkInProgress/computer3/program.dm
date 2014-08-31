
/*
Programs are a file that can be executed
*/

/datum/file/program
	name					= "Untitled"
	extension				= "prog"
	image					= 'icons/ntos/program.png'
	var/desc				= "An unidentifiable program."

	var/image/overlay		= null							// Icon to be put on top of the computer frame.

	var/active_state		= "generic"						// the icon_state that the computer goes to when the program is active

	drm						= 0								// prevents a program from being copied
	var/refresh				= 0								// if true, computer does screen updates during process().
	var/error				= 0								// set by background programs so an error pops up when used

	var/human_controls		= 0								// if true, non-human animals cannot interact with this program (monkeys, xenos, etc)
	var/ai_allowed			= 1								// if true, silicon mobs (AI/cyborg) are allowed to use this program.

	var/datum/browser/popup	= null

	// ID access: Note that computer3 does not normally check your ID.
	// By default this is only really used for inserted cards.
	var/list/req_access 	= list()						// requires all of these UNLESS below succeeds
	var/list/req_one_access = list()						// requires one of these


/datum/file/program/New()
	..()
	if(!active_state)
		active_state = "generic"
	overlay = image('icons/obj/computer3.dmi',icon_state = active_state)


/datum/file/program/proc/decode(text)
		//adds line breaks
		text = replacetext(text, "\n","<BR>")
		return text



/datum/file/program/execute(var/datum/file/source)
	if(computer && !computer.stat)
		computer.program = src
		computer.req_access = req_access
		computer.req_one_access = req_one_access
		update_icon()
		computer.update_icon()
		if(usr)
			usr << browse(null, "window=\ref[computer]")
			computer.attack_hand(usr)

	..()

/*
	Standard Topic() for links
*/

/datum/file/program/Topic(href, href_list)
	return

/*
	The computer object will transfer all empty-hand calls to the program (this includes AIs, Cyborgs, and Monkies)
*/
/datum/file/program/proc/interact()
	return

/*
	Standard receive_signal()
*/

/datum/file/program/proc/receive_signal(var/datum/signal/signal)
	return
/*
	The computer object will transfer all attackby() calls to the program
		If the item is a valid interactable object, return 1. Else, return 0.
		This helps identify what to use to actually hit the computer with, and
		what can be used to interact with it.

		Screwdrivers will, by default, never call program/attackby(). That's used
		for deconstruction instead.
*/


/datum/file/program/proc/attackby(O as obj, user as mob)
	return

/*
	Try not to overwrite this proc, I'd prefer we stayed
	with interact() as the main proc
*/
/datum/file/program/proc/attack_hand(mob/user as mob)
	usr = user
	interact()

/*
	Called when the computer is rebooted or the program exits/restarts.
	Be sure not to save any work.  Do NOT start the program again.
	If it is the os, the computer will run it again automatically.

	Also, we are deleting the browser window on the chance that this is happening
	when the computer is damaged or disassembled, causing us to lose our computer.
	The popup window's title is a reference to the computer, making it unique, so
	it could introduce bugs in that case.
*/
/datum/file/program/proc/Reset()
	error = 0
	update_icon()
	if(popup)
		popup.close()
		del popup
	return

/*
	The computer object will transfer process() calls to the program.
*/
/datum/file/program/proc/process()
	if(refresh && computer && !computer.stat)
		computer.updateDialog()
		update_icon()

/datum/file/program/proc/update_icon()
	return

/datum/file/program/proc/check_access(obj/item/I)
	if( (!istype(req_access) || !req_access.len) && (!istype(req_one_access) || !req_one_access.len) ) //no requirements
		return 1

	if(!I)
		return 0

	var/list/iAccess = I.GetAccess()
	if(!iAccess || !iAccess.len)
		return 0

	var/list/temp = req_one_access & iAccess
	if(temp.len) // a required access in item access list
		return 1
	temp = req_access - iAccess
	if(temp.len) // a required access not in item access list
		return 0
	return 1


/*
	Because this does sanity checks I have added the code to make a popup here.
	It also does sanity checks there that should prevent some edge case madness.
*/
/datum/file/program/proc/interactable(var/mob/user = usr)
	if(computer && computer.interactable(user))
		if(!popup)
			popup = new(user, "\ref[computer]", name, nref=src)
			popup.set_title_image(usr.browse_rsc_icon(overlay.icon, overlay.icon_state))
			popup.set_title_buttons(topic_link(src,"quit","<img src=\ref['icons/ntos/tb_close.png']>"))
		if(popup.user != user)
			popup.user = user
			popup.set_title_image(usr.browse_rsc_icon(overlay.icon, overlay.icon_state))
		popup.set_title(name)
		return 1
	return 0


/datum/file/program/proc/fake_link(var/text)
	return "<span class='linkOff'>[text]</span>"

/*
	Meant for text (not icons) -
	lists all installed drives and their files

	I am NOT adding a computer sanity check here,
	because why the flying fuck would you get to this
	proc before having run it at least once?
	If you cause runtimes with this function
	may the shame of all ages come upon you.
*/
/datum/file/program/proc/list_all_files_by_drive(var/typekey,var/linkop = "runfile")
	var/dat = ""
	if(!typekey) typekey = /datum/file
	if(computer.hdd)
		dat += "<h3>[computer.hdd]</h3>"
		for(var/datum/file/F in computer.hdd.files)
			if(istype(F,typekey))
				dat += topic_link(src,"[linkop]=\ref[F]",F.name) + "<br>"
		if(computer.hdd.files.len == 0)
			dat += "<i>No files</i><br>"
		dat += "<br>"

	if(computer.floppy)
		if(!computer.floppy.inserted)
			dat += "<h3>[computer.floppy] - <span class='linkOff'>Eject</span></h3><br><br>"
		else
			dat += "<h3>[computer.floppy] - [topic_link(src,"eject_disk","Eject")]</h3>"
			for(var/datum/file/F in computer.floppy.inserted.files)
				dat += topic_link(src,"[linkop]=\ref[F]",F.name) + "<br>"
			if(computer.floppy.inserted.files.len == 0)
				dat += "<i>No files</i><br>"
			dat += "<br>"

	if(computer.cardslot && istype(computer.cardslot.reader,/obj/item/weapon/card/data))
		dat += "<h3>[computer.cardslot.reader] - [topic_link(src,"eject_card=reader","Eject")]</h3>"
		var/obj/item/weapon/card/data/D = computer.cardslot.reader
		for(var/datum/file/F in D.files)
			dat += topic_link(src,"[linkop]=\ref[F]",F.name) + "<br>"
		if(D.files.len == 0)
			dat += "<i>No files</i><br>"
	return dat

// You don't NEED to use this version of topic() for this, you can do it yourself if you prefer
// If you do, do the interactable() check first, please, I don't want to repeat it here.  It's not hard.
/datum/file/program/Topic(var/href,var/list/href_list)
	if(!computer)
		return 0

	//
	// usage: eject_disk
	// only functions if there is a removable drive
	//
	if("eject_disk" in href_list)
		if(computer.floppy)
			computer.floppy.eject_disk()
		return 1
	//
	// usage: eject_card | eject_card=reader | eject_card=writer
	// only functions if there is a cardslot
	//
	if("eject_card" in href_list)
		if(computer.cardslot)
			if(computer.cardslot.dualslot && href_list["eject_card"] == "writer")
				computer.cardslot.remove(computer.cardslot.writer)
			else
				computer.cardslot.remove(computer.cardslot.reader)
		return 1
	//
	// usage: runfile=\ref[file]
	// executes the file
	//
	if("runfile" in href_list)
		var/datum/file/F = locate(href_list["runfile"])
		if(istype(F) && F.computer == computer)
			F.execute(src)
		return 1

	if("close" in href_list)
		usr.unset_machine()
		popup.close()
		return 1
	//
	// usage: quit
	// unloads the program, returning control to the OS
	//
	if("quit" in href_list)
		computer.program = null
		usr << browse(null,"window=\ref[computer]") // ntos will need to resize the window
		computer.update_icon()
		computer.updateDialog()
		return 1
	return 0


/datum/file/program/RD
	name = "R&D Manager"
	image = 'icons/ntos/research.png'
	desc = "A software suit for generic research and development machinery interaction. Comes pre-packaged with extensive cryptographic databanks for secure connections with external devices."
	active_state = "rdcomp"
	volume = 11000

/datum/file/program/RDserv
	name = "R&D Server"
	image = 'icons/ntos/server.png'
	active_state = "rdcomp"
	volume = 9000

/datum/file/program/SuitSensors
	name = "Crew Monitoring"
	image = 'icons/ntos/monitoring.png'
	active_state = "crew"
	volume = 3400

/datum/file/program/Genetics
	name = "Genetics Suite"
	image = 'icons/ntos/genetics.png'
	desc = "A sophisticated software suite containing read-only genetics hardware specifications and a highly compressed genome databank."
	active_state = "dna"
	volume = 8000

/datum/file/program/Cloning
	name = "Cloning Platform"
	image = 'icons/ntos/cloning.png'
	desc = "A software platform for accessing external cloning apparatus."
	active_state = "dna"
	volume = 7000

/datum/file/program/TCOMmonitor
	name = "TComm Monitor"
	image = 'icons/ntos/tcomms.png'
	active_state = "comm_monitor"
	volume = 5500

/datum/file/program/TCOMlogs
	name = "TComm Log View"
	image = 'icons/ntos/tcomms.png'
	active_state = "comm_logs"
	volume = 5230

/datum/file/program/TCOMtraffic
	name = "TComm Traffic"
	image = 'icons/ntos/tcomms.png'
	active_state = "generic"
	volume = 8080

/datum/file/program/securitycam
	name = "Sec-Cam Viewport"
	image = 'icons/ntos/camera.png'
	drm = 1
	active_state = "cameras"
	volume = 2190

/datum/file/program/securityrecords
	name = "Security Records"
	image = 'icons/ntos/records.png'
	drm = 1
	active_state = "security"
	volume = 2520

/datum/file/program/medicalrecords
	name = "Medical Records"
	image = 'icons/ntos/medical.png'
	drm = 1
	active_state = "medcomp"
	volume = 5000

/datum/file/program/SMSmonitor
	name = "Messaging Monitor"
	image = 'icons/ntos/pda.png'
	active_state = "comm_monitor"
	volume = 3070

/datum/file/program/OperationMonitor
	name = "OR Monitor"
	image = 'icons/ntos/operating.png'
	active_state = "operating"
	volume = 4750

/datum/file/program/PodLaunch
	name = "Pod Launch"
	active_state = "computer_generic"
	volume = 520

/datum/file/program/powermon
	name = "Power Grid"
	image = 'icons/ntos/power.png'
	active_state = "power"
	volume = 7200

/datum/file/program/prisoner
	name = "Prisoner Control"
	image = 'icons/ntos/prison.png'
	drm = 1
	active_state = "power"
	volume = 5000

/datum/file/program/borg_control
	name = "Cyborg Maint"
	image = 'icons/ntos/borgcontrol.png'
	active_state = "robot"
	volume = 9050

/datum/file/program/AIupload
	name = "AI Upload"
	image = 'icons/ntos/aiupload.png'
	active_state = "command"
	volume = 5000

/datum/file/program/Cyborgupload
	name = "Cyborg Upload"
	image = 'icons/ntos/borgupload.png'
	active_state = "command"
	volume = 5000

/datum/file/program/Exosuit
	name = "Exosuit Monitor"
	image = 'icons/ntos/exocontrol.png'
	active_state = "mecha"
	volume = 7000

/datum/file/program/EmergencyShuttle
	name = "Shuttle Console"
	active_state = "shuttle"
	volume = 10000

/datum/file/program/Stationalert
	name = "Alert Monitor"
	image = 'icons/ntos/alerts.png'
	active_state = "computer_generic"
	volume = 10150






