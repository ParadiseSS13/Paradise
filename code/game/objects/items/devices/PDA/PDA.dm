
//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()


/obj/item/device/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 1.0
	slot_flags = SLOT_PDA | SLOT_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	var/lastmode = 0
	var/ui_tick = 0

	//Secondary variables
	var/scanmode = 0 //1 is medical scanner, 2 is forensics, 3 is reagent scanner.
	var/fon = 0 //Is the flashlight function on?
	var/f_lum = 2 //Luminosity for the flashlight function
	var/silent = 0 //To beep or not to beep, that is the question
	var/toff = 0 //If 1, messenger disabled
	var/tnote[0]  //Current Texts
	var/last_text //No text spamming
	var/last_honk //Also no honk spamming that's bad too

	var/ttone = "beep" //The ringtone!
	var/list/ttone_sound = list("beep" = 'sound/machines/twobeep.ogg',
								"boom" = 'sound/effects/explosionfar.ogg',
								"slip" = 'sound/misc/slip.ogg',
								"honk" = 'sound/items/bikehorn.ogg',
								"SKREE" = 'sound/voice/shriek1.ogg',
								"holy" = 'sound/items/PDA/ambicha4-short.ogg',
								"xeno" = 'sound/voice/hiss1.ogg')

	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/note = "Congratulations, your station has chosen the Thinktronic 5230 Personal Data Assistant!" //Current note in the notepad function
	var/notehtml = ""
	var/cart = "" //A place to stick cartridge menu information
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/active_conversation = null // New variable that allows us to only view a single conversation.
	var/list/conversations = list()    // For keeping up with who we have PDA messsages from.
	var/newmessage = 0			//To remove hackish overlay check

	var/list/cartmodes = list(40, 42, 43, 433, 44, 441, 45, 451, 46, 48, 47, 49) // If you add more cartridge modes add them to this list as well.
	var/list/no_auto_update = list(1, 40, 43, 44, 441, 45, 451)		     // These modes we turn off autoupdate
	var/list/update_every_five = list(3, 41, 433, 46, 47, 48, 49)			     // These we update every 5 ticks

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above
	var/ownrank = null // this one is rank, never alt title

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device
	var/retro_mode = 0

/obj/item/device/pda/medical
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-medical"

/obj/item/device/pda/viro
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-virology"

/obj/item/device/pda/engineering
	default_cartridge = /obj/item/weapon/cartridge/engineering
	icon_state = "pda-engineer"

/obj/item/device/pda/security
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-security"

/obj/item/device/pda/detective
	default_cartridge = /obj/item/weapon/cartridge/detective
	icon_state = "pda-security"

/obj/item/device/pda/warden
	default_cartridge = /obj/item/weapon/cartridge/security
	icon_state = "pda-warden"

/obj/item/device/pda/janitor
	default_cartridge = /obj/item/weapon/cartridge/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/device/pda/toxins
	default_cartridge = /obj/item/weapon/cartridge/signal/toxins
	icon_state = "pda-science"
	ttone = "boom"

/obj/item/device/pda/clown
	default_cartridge = /obj/item/weapon/cartridge/clown
	icon_state = "pda-clown"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/device/pda/mime
	default_cartridge = /obj/item/weapon/cartridge/mime
	icon_state = "pda-mime"
	silent = 1
	ttone = "silence"

/obj/item/device/pda/heads
	default_cartridge = /obj/item/weapon/cartridge/head
	icon_state = "pda-h"

/obj/item/device/pda/heads/hop
	default_cartridge = /obj/item/weapon/cartridge/hop
	icon_state = "pda-hop"

/obj/item/device/pda/heads/hos
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-hos"

/obj/item/device/pda/heads/ce
	default_cartridge = /obj/item/weapon/cartridge/ce
	icon_state = "pda-ce"

/obj/item/device/pda/heads/cmo
	default_cartridge = /obj/item/weapon/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/device/pda/heads/rd
	default_cartridge = /obj/item/weapon/cartridge/rd
	icon_state = "pda-rd"

/obj/item/device/pda/captain
	default_cartridge = /obj/item/weapon/cartridge/captain
	icon_state = "pda-captain"
	detonate = 0
	//toff = 1

/obj/item/device/pda/heads/ntrep
	default_cartridge = /obj/item/weapon/cartridge/supervisor
	icon_state = "pda-h"

/obj/item/device/pda/heads/magistrate
	default_cartridge = /obj/item/weapon/cartridge/supervisor
	icon_state = "pda-h"

/obj/item/device/pda/heads/blueshield
	default_cartridge = /obj/item/weapon/cartridge/hos
	icon_state = "pda-h"

/obj/item/device/pda/cargo
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/device/pda/quartermaster
	default_cartridge = /obj/item/weapon/cartridge/quartermaster
	icon_state = "pda-qm"

/obj/item/device/pda/shaftminer
	icon_state = "pda-miner"

/obj/item/device/pda/syndicate
	default_cartridge = /obj/item/weapon/cartridge/syndicate
	icon_state = "pda-syndi"
	name = "Military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/device/pda/chaplain
	icon_state = "pda-chaplain"
	ttone = "holy"

/obj/item/device/pda/lawyer
	default_cartridge = /obj/item/weapon/cartridge/lawyer
	icon_state = "pda-lawyer"
	ttone = "..."

/obj/item/device/pda/botanist
	//default_cartridge = /obj/item/weapon/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/device/pda/roboticist
	icon_state = "pda-roboticist"

/obj/item/device/pda/librarian
	icon_state = "pda-library"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = 1 //Quiet in the library!

/obj/item/device/pda/clear
	icon_state = "pda-transp"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This is model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/device/pda/chef
	icon_state = "pda-chef"

/obj/item/device/pda/bar
	icon_state = "pda-bartender"

/obj/item/device/pda/atmos
	default_cartridge = /obj/item/weapon/cartridge/atmos
	icon_state = "pda-atmos"

/obj/item/device/pda/chemist
	default_cartridge = /obj/item/weapon/cartridge/chemistry
	icon_state = "pda-chemistry"

/obj/item/device/pda/geneticist
	default_cartridge = /obj/item/weapon/cartridge/medical
	icon_state = "pda-genetics"

/obj/item/device/pda/centcom
	default_cartridge = /obj/item/weapon/cartridge/centcom
	icon_state = "pda-h"


// Special AI/pAI PDAs that cannot explode.
/obj/item/device/pda/ai
	icon_state = "NONE"
	ttone = "data"
	detonate = 0


/obj/item/device/pda/ai/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob
	name = newname + " (" + ownjob + ")"


//AI verb and proc for sending PDA messages.
/mob/living/silicon/ai/proc/cmd_send_pdamesg(mob/user as mob)
	if(user.stat == 2)
		user << "You can't send PDA messages because you are dead!"
		return
	var/list/plist = aiPDA.available_pdas()
	if (plist)
		var/c = input(user, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		aiPDA.create_message(user, selected)

/mob/living/silicon/ai/proc/cmd_show_message_log(mob/user as mob)
	if(user.stat == 2)
		user << "You can't do that because you are dead!"
		return
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in aiPDA.tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	user << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/obj/item/device/pda/ai/verb/cmd_send_pdamesg()
	set category = "AI IM"
	set name = "Send PDA Message"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't send PDA messages because you are dead!"
		return
	var/list/plist = available_pdas()
	if (plist)
		var/c = input(usr, "Please select a PDA") as null|anything in sortList(plist)
		if (!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		create_message(usr, selected)

/obj/item/device/pda/ai/verb/cmd_show_message_log()
	set category = "AI IM"
	set name = "Show Message Log"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	var/HTML = "<html><head><title>AI PDA Message Log</title></head><body>"
	for(var/index in tnote)
		if(index["sent"])
			HTML += addtext("<i><b>&rarr; To <a href='byond://?src=\ref[src];choice=Message;target=",index["src"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
		else
			HTML += addtext("<i><b>&larr; From <a href='byond://?src=\ref[src];choice=Message;target=",index["target"],"'>", index["owner"],"</a>:</b></i><br>", index["message"], "<br>")
	HTML +="</body></html>"
	usr << browse(HTML, "window=log;size=400x444;border=1;can_resize=1;can_close=1;can_minimize=0")

/obj/item/device/pda/ai/verb/cmd_toggle_pda_receiver()
	set category = "AI IM"
	set name = "Toggle Sender/Receiver"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	toff = !toff
	usr << "<span class='notice'>PDA sender/receiver toggled [(toff ? "Off" : "On")]!</span>"


/obj/item/device/pda/ai/verb/cmd_toggle_pda_silent()
	set category = "AI IM"
	set name = "Toggle Ringer"
	set src in usr
	if(usr.stat == 2)
		usr << "You can't do that because you are dead!"
		return
	silent=!silent
	usr << "<span class='notice'>PDA ringer toggled [(silent ? "Off" : "On")]!</span>"

/obj/item/device/pda/ai/can_use()
	return 1


/obj/item/device/pda/ai/attack_self(mob/user as mob)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return


/obj/item/device/pda/ai/pai
	ttone = "assist"


/*
 *	The Actual PDA
 */
/obj/item/device/pda/New()
	..()
	PDAs += src
	PDAs = sortAtom(PDAs)
	if(default_cartridge)
		cartridge = new default_cartridge(src)
	new /obj/item/weapon/pen(src)

/obj/item/device/pda/proc/can_use()

	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(M.stat || M.restrained() || M.paralysis || M.stunned || M.weakened)
		return 0
	if((src in M.contents) || ( istype(loc, /turf) && in_range(src, M) ))
		return 1
	else
		return 0

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/screen)) && can_use())
		return attack_self(M)
	return


/obj/item/device/pda/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui_tick++
	var/datum/nanoui/old_ui = nanomanager.get_open_ui(user, src, "main")
	var/auto_update = 1
	if(mode in no_auto_update)
		auto_update = 0
	if(old_ui && (mode == lastmode && ui_tick % 5 && mode in update_every_five))
		return

	lastmode = mode

	var/title = "Personal Data Assistant"

	var/data[0]  // This is the data that will be sent to the PDA


	data["owner"] = owner					// Who is your daddy...
	data["ownjob"] = ownjob					// ...and what does he do?

	data["mode"] = mode					// The current view
	data["scanmode"] = scanmode				// Scanners
	data["fon"] = fon					// Flashlight on?
	data["pai"] = (isnull(pai) ? 0 : 1)			// pAI inserted?
	data["note"] = note					// current pda notes
	data["silent"] = silent					// does the pda make noise when it receives a message?
	data["toff"] = toff					// is the messenger function turned off?
	data["active_conversation"] = active_conversation	// Which conversation are we following right now?


	data["idInserted"] = (id ? 1 : 0)
	data["idLink"] = (id ? text("[id.registered_name], [id.assignment]") : "--------")

	data["useRetro"] = retro_mode

	data["cart_loaded"] = cartridge ? 1:0
	if(cartridge)
		var/cartdata[0]

		cartdata["access"] = list(\
					"access_security" = cartridge.access_security,\
					"access_engine" = cartridge.access_engine,\
					"access_atmos" = cartridge.access_atmos,\
					"access_medical" = cartridge.access_medical,\
					"access_clown" = cartridge.access_clown,\
					"access_mime" = cartridge.access_mime,\
					"access_janitor" = cartridge.access_janitor,\
					"access_quartermaster" = cartridge.access_quartermaster,\
					"access_hydroponics" = cartridge.access_hydroponics,\
					"access_reagent_scanner" = cartridge.access_reagent_scanner,\
					"access_remote_door" = cartridge.access_remote_door,\
					"access_status_display" = cartridge.access_status_display,\
					"access_detonate_pda" = cartridge.access_detonate_pda\
			)

		if(mode in cartmodes)
			data["records"] = cartridge.create_NanoUI_values()

		if(mode == 0)
			cartdata["name"] = cartridge.name
			if(isnull(cartridge.radio))
				cartdata["radio"] = 0
			else
				if(istype(cartridge.radio, /obj/item/radio/integrated/beepsky))
					cartdata["radio"] = 1
				if(istype(cartridge.radio, /obj/item/radio/integrated/signal))
					cartdata["radio"] = 2
				if(istype(cartridge.radio, /obj/item/radio/integrated/mule))
					cartdata["radio"] = 3

		if(mode == 2)
			cartdata["charges"] = cartridge.charges ? cartridge.charges : 0
		data["cartridge"] = cartdata
	data["stationTime"] = worldtime2text()
	data["newMessage"] = newmessage

	if(mode==2)
		var/convopdas[0]
		var/pdas[0]
		var/count = 0
		for (var/obj/item/device/pda/P in PDAs)
			if (!P.owner||P.toff||P == src||P.hidden)       continue
			if(conversations.Find("\ref[P]"))
				convopdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "1")))
			else
				pdas.Add(list(list("Name" = "[P]", "Reference" = "\ref[P]", "Detonate" = "[P.detonate]", "inconvo" = "0")))
			count++

		data["convopdas"] = convopdas
		data["pdas"] = pdas
		data["pda_count"] = count

	if(mode==21)
		data["messagescount"] = tnote.len
		data["messages"] = tnote
	else
		data["messagescount"] = null
		data["messages"] = null

	if(active_conversation)
		for(var/c in tnote)
			if(c["target"] == active_conversation)
				data["convo_name"] = sanitize(c["owner"])
				data["convo_job"] = sanitize(c["job"])
				break
	if(mode==41)
		data_core.get_manifest_json()


	if(mode==3)
		var/turf/T = get_turf(user.loc)
		if(!isnull(T))
			var/datum/gas_mixture/environment = T.return_air()

			var/pressure = environment.return_pressure()
			var/total_moles = environment.total_moles()

			if (total_moles)
				var/o2_level = environment.oxygen/total_moles
				var/n2_level = environment.nitrogen/total_moles
				var/co2_level = environment.carbon_dioxide/total_moles
				var/plasma_level = environment.toxins/total_moles
				var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
				data["aircontents"] = list(\
					"pressure" = "[round(pressure,0.1)]",\
					"nitrogen" = "[round(n2_level*100,0.1)]",\
					"oxygen" = "[round(o2_level*100,0.1)]",\
					"carbon_dioxide" = "[round(co2_level*100,0.1)]",\
					"plasma" = "[round(plasma_level*100,0.01)]",\
					"other" = "[round(unknown_level, 0.01)]",\
					"temp" = "[round(environment.temperature-T0C,0.1)]",\
					"reading" = 1\
					)
		if(isnull(data["aircontents"]))

			data["aircontents"] = list("reading" = 0)


	data["manifest"] = list("__json_cache" = ManifestJSON)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "pda.tmpl", title, 630, 600, state = inventory_state)

		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
	// auto update every Master Controller tick
	ui.set_auto_update(auto_update)

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)
	user.set_machine(src)
	if(active_uplink_check(user))
		return
	ui_interact(user) //NanoUI requires this proc
	return

/obj/item/device/pda/Topic(href, href_list)
	if(href_list["cartmenu"] && !isnull(cartridge))
		cartridge.Topic(href, href_list)
		return 1
	if(href_list["radiomenu"] && !isnull(cartridge) && !isnull(cartridge.radio))
		cartridge.radio.Topic(href, href_list)
		return 1


	..()
	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
	var/mob/living/U = usr
	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )
	if (usr.stat == DEAD)
		return 0
	if(!can_use()) //Why reinvent the wheel? There's a proc that does exactly that.
		U.unset_machine()
		if(ui)
			ui.close()
		return 0

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])

//BASIC FUNCTIONS===================================

		if("Close")//Self explanatory
			U.unset_machine()
			ui.close()
			return 0
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(mode<=9)
				mode = 0
			else
				mode = round(mode/10)
				if(mode==2)
					active_conversation = null
				if(mode==4)//Fix for cartridges. Redirects to hub.
					mode = 0
				else if(mode >= 40 && mode <= 49)//Fix for cartridges. Redirects to refresh the menu.
					cartridge.mode = mode
		if("Retro")
			retro_mode = !retro_mode
			ui_interact(user)
		if ("Authenticate")//Checks for ID
			id_check(U, 1)
		if("UpdateInfo")
			ownjob = id.assignment
			ownrank = id.rank
			name = "PDA-[owner] ([ownjob])"
		if("Eject")//Ejects the cart, only done from hub.
			if (!isnull(cartridge))
				var/turf/T = loc
				if(ismob(T))
					T = T.loc
				cartridge.loc = T
				mode = 0
				scanmode = 0
				if (cartridge.radio)
					cartridge.radio.hostpda = null
				cartridge = null

//MENU FUNCTIONS===================================

		if("0")//Hub
			mode = 0
		if("1")//Notes
			mode = 1
		if("2")//Messenger
			mode = 2
		if("21")//Read messages
			mode = 21
		if("3")//Atmos scan
			mode = 3
		if("4")//Redirects to hub
			mode = 0
		if("chatroom") // chatroom hub
			mode = 5
		if("41") //Manifest
			mode = 41


//MAIN FUNCTIONS===================================

		if("Light")
			if(fon)
				fon = 0
				set_light(0)
			else
				fon = 1
				set_light(f_lum)
		if("Medical Scan")
			if(scanmode == 1)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_medical))
				scanmode = 1
		if("Reagent Scan")
			if(scanmode == 3)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_reagent_scanner))
				scanmode = 3
		if("Halogen Counter")
			if(scanmode == 4)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_engine))
				scanmode = 4
		if("Honk")
			if ( !(last_honk && world.time < last_honk + 20) )
				playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
				last_honk = world.time
		if("Gas Scan")
			if(scanmode == 5)
				scanmode = 0
			else if((!isnull(cartridge)) && (cartridge.access_atmos))
				scanmode = 5

//MESSENGER/NOTE FUNCTIONS===================================

		if ("Edit")
			var/n = input(U, "Please enter message", name, notehtml) as message
			if (in_range(src, U) && loc == U)
				n = copytext(adminscrub(n), 1, MAX_MESSAGE_LEN)
				if (mode == 1)
					note = html_decode(n)
					notehtml = note
					note = replacetext(note, "\n", "<br>")
			else
				ui.close()
		if("Toggle Messenger")
			toff = !toff
		if("Toggle Ringer")//If viewing texts then erase them, if not then toggle silent status
			silent = !silent
		if("Clear")//Clears messages
			if(href_list["option"] == "All")
				tnote.Cut()
				conversations.Cut()
			if(href_list["option"] == "Convo")
				var/new_tnote[0]
				for(var/i in tnote)
					if(i["target"] != active_conversation)
						new_tnote[++new_tnote.len] = i
				tnote = new_tnote
				conversations.Remove(active_conversation)

			active_conversation = null
			if(mode==21)
				mode=2

		if("Ringtone")
			var/t = input(U, "Please enter new ringtone", name, ttone) as text
			if (in_range(src, U) && loc == U)
				if (t)
					if(src.hidden_uplink && hidden_uplink.check_trigger(U, lowertext(t), lowertext(lock_code)))
						U << "The PDA softly beeps."
						ui.close()
					else
						t = sanitize(copytext(t, 1, 20))
						ttone = t
			else
				ui.close()
				return 0
		if("Message")

			var/obj/item/device/pda/P = locate(href_list["target"])
			src.create_message(U, P)
			if(mode == 2)
				if(href_list["target"] in conversations)            // Need to make sure the message went through, if not welp.
					active_conversation = href_list["target"]
					mode = 21

		if("Select Conversation")
			var/P = href_list["convo"]
			for(var/n in conversations)
				if(P == n)
					active_conversation=P
					mode=21
		if("Send Honk")//Honk virus
			if(istype(cartridge, /obj/item/weapon/cartridge/clown))//Cartridge checks are kind of unnecessary since everything is done through switch.
				var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("\blue Virus sent!", 1)
						P.honkamt = (rand(15,20))
				else
					U << "PDA not found."
			else
				ui.close()
				return 0
		if("Send Silence")//Silent virus
			if(istype(cartridge, /obj/item/weapon/cartridge/mime))
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--
						U.show_message("\blue Virus sent!", 1)
						P.silent = 1
						P.ttone = "silence"
				else
					U << "PDA not found."
			else
				ui.close()
				return 0


//SYNDICATE FUNCTIONS===================================

		if("Toggle Door")
			if(cartridge && cartridge.access_remote_door)
				for(var/obj/machinery/door/poddoor/M in world)
					if(M.id_tag == cartridge.remote_door_id)
						if(M.density)
							M.open()
						else
							M.close()

		if("Detonate")//Detonate PDA
			if(istype(cartridge, /obj/item/weapon/cartridge/syndicate))
				var/obj/item/device/pda/P = locate(href_list["target"])
				if(!isnull(P))
					if (!P.toff && cartridge.charges > 0)
						cartridge.charges--

						var/difficulty = 0

						if(P.cartridge)
							difficulty += P.cartridge.access_medical
							difficulty += P.cartridge.access_security
							difficulty += P.cartridge.access_engine
							difficulty += P.cartridge.access_clown
							difficulty += P.cartridge.access_janitor
						else
							difficulty += 2

						if(prob(difficulty * 12) || (P.hidden_uplink))
							U.show_message("\red An error flashes on your [src].", 1)
						else if (prob(difficulty * 3))
							U.show_message("\red Energy feeds back into your [src]!", 1)
							ui.close()
							explode()
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up")
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge but failed, blowing themselves up", 1)
						else
							U.show_message("\blue Success!", 1)
							log_admin("[key_name(U)] just attempted to blow up [P] with the Detomatix cartridge and succeded")
							message_admins("[key_name_admin(U)] just attempted to blow up [P] with the Detomatix cartridge and succeded", 1)
							P.explode()
				else
					U << "PDA not found."
			else
				U.unset_machine()
				ui.close()
				return 0

//pAI FUNCTIONS===================================
		if("pai")
			if(pai)
				if(pai.loc != src)
					pai = null
				else
					switch(href_list["option"])
						if("1")		// Configure pAI device
							pai.attack_self(U)
						if("2")		// Eject pAI device
							var/turf/T = get_turf_or_move(src.loc)
							if(T)
								pai.loc = T
								pai = null

		else
			mode = text2num(href_list["choice"])
			if(cartridge)
				cartridge.mode = mode

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 21)//To clear message overlays.
		overlays.Cut()
		newmessage = 0

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	return 1 // return 1 tells it to refresh the UI in NanoUI

/obj/item/device/pda/verb/verb_reset_pda()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		mode = 0
		nanomanager.update_uis(src)
		usr << "<span class='notice'>You press the reset button on \the [src].</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			usr << "<span class='notice'>You remove the ID from the [name].</span>"
		else
			id.loc = get_turf(src)
		id = null

/obj/item/device/pda/proc/create_message(var/mob/living/U = usr, var/obj/item/device/pda/P)

	var/t = input(U, "Please enter message", name, null) as text|null
	if(!t)
		return
	t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
	t = readd_quotes(t)
	if (!t || !istype(P))
		return
	if (!in_range(src, U) && loc != U)
		return

	if (isnull(P)||P.toff || toff)
		return

	if (last_text && world.time < last_text + 5)
		return

	if(!can_use())
		return

	last_text = world.time
	// check if telecomms I/O route 1459 is stable
	//var/telecomms_intact = telecomms_process(P.owner, owner, t)
	var/obj/machinery/message_server/useMS = null
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
		//PDAs are now dependent on the Message Server.
			if(MS.active)
				useMS = MS
				break

	var/datum/signal/signal = src.telecomms_process()

	var/useTC = 0
	if(signal)
		if(signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(P)
			if(pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if(signal.data["compression"] > 0)
					t = Gibberish(t, signal.data["compression"] + 50)

	if(useMS && useTC) // only send the message if it's stable
		if(useTC != 2) // Does our recipient have a broadcaster on their level?
			U << "ERROR: Cannot reach recipient."
			return
		useMS.send_pda_message("[P.owner]","[owner]","[t]")
		tnote.Add(list(list("sent" = 1, "owner" = "[P.owner]", "job" = "[P.ownjob]", "message" = "[t]", "target" = "\ref[P]")))
		P.tnote.Add(list(list("sent" = 0, "owner" = "[owner]", "job" = "[ownjob]", "message" = "[t]", "target" = "\ref[src]")))
/*		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTEARS)) // src.client is so that ghosts don't have to listen to mice
				if(istype(M, /mob/new_player))
					continue
				M.show_message("<span class='game say'>PDA Message - <span class='name'>[owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>") */
		investigate_log("<span class='game say'>PDA Message - <span class='name'>[U.key] - [owner]</span> -> <span class='name'>[P.owner]</span>: <span class='message'>[t]</span></span>", "pda")
		if(!conversations.Find("\ref[P]"))
			conversations.Add("\ref[P]")
		if(!P.conversations.Find("\ref[src]"))
			P.conversations.Add("\ref[src]")

/*
		if (prob(15)) //Give the AI a chance of intercepting the message
			var/who = src.owner
			if(prob(50))
				who = P.owner
			for(var/mob/living/silicon/ai/ai in mob_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if(ai.aiPDA != P && ai.aiPDA != src)
					ai.show_message("<i>Intercepted message from <b>[who]</b>: [t]</i>")
*/

		P.play_ringtone()
		//Search for holder of the PDA.
		var/mob/living/L = null
		if(P.loc && isliving(P.loc))
			L = P.loc
		//Maybe they are a pAI!
		else
			L = get(P, /mob/living/silicon)


		if(L)
			L << "\icon[P] <b>Message from [src.owner] ([ownjob]), </b>\"[t]\" (<a href='byond://?src=\ref[P];choice=Message;skiprefresh=1;target=\ref[src]'>Reply</a>)"
			nanomanager.update_user_uis(L, P) // Update the receiving user's PDA UI so that they can see the new message

		nanomanager.update_user_uis(U, P) // Update the sending user's PDA UI so that they can see the new message

		log_pda("[usr] (PDA: [src.name]) sent \"[t]\" to [P.name]")
		P.overlays.Cut()
		P.overlays += image('icons/obj/pda.dmi', "pda-r")
		P.newmessage = 1
	else
		U << "<span class='notice'>ERROR: Messaging server is not responding.</span>"

/obj/item/device/pda/proc/play_ringtone()
	if (!silent)
		var/sound/S = sound('sound/machines/twobeep.ogg')

		if(ttone in ttone_sound)
			S = ttone_sound[ttone]
		playsound(loc, S, 50, 1)
	for (var/mob/O in hearers(3, loc))
		if(!silent) O.show_message(text("\icon[src] *[ttone]*"))

/obj/item/device/pda/verb/verb_remove_id()
	set category = null
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
		else
			usr << "<span class='notice'>This PDA does not have an ID in it.</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"


/obj/item/device/pda/verb/verb_remove_pen()
	set category = null
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					usr << "<span class='notice'>You remove \the [O] from \the [src].</span>"
					return
			O.loc = get_turf(src)
		else
			usr << "<span class='notice'>This PDA does not have a pen in it.</span>"
	else
		usr << "<span class='notice'>You cannot do this while restrained.</span>"


/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				user.drop_item()
				I.loc = src
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.loc = src
			id = I
			user.put_in_hands(old_id)
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob, params)
	..()
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = C
		user.drop_item()
		cartridge.loc = src
		user << "<span class='notice'>You insert [cartridge] into [src].</span>"
		nanomanager.update_uis(src) // update all UIs attached to src
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			user << "<span class='notice'>\The [src] rejects the ID.</span>"
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			ownrank = idcard.rank
			name = "PDA-[owner] ([ownjob])"
			user << "<span class='notice'>Card scanned.</span>"
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if( can_use(user) )//If they can still act.
					id_check(user, 2)
					user << "<span class='notice'>You put the ID into \the [src]'s slot.</span>"
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		user.drop_item()
		C.loc = src
		pai = C
		user << "<span class='notice'>You slot \the [C] into [src].</span>"
		nanomanager.update_uis(src) // update all UIs attached to src
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			user << "<span class='notice'>There is already a pen in \the [src].</span>"
		else
			user.drop_item()
			C.loc = src
			user << "<span class='notice'>You slide \the [C] into \the [src].</span>"
	return

/obj/item/device/pda/attack(mob/living/C as mob, mob/living/user as mob)
	if (istype(C, /mob/living/carbon))
		switch(scanmode)
			if(1)
				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s vitals!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				user.show_message("\blue \t Overall Status: [C.stat > 1 ? "dead" : "[C.health - C.halloss]% healthy"]", 1)
				user.show_message("\blue \t Damage Specifics: [C.getOxyLoss() > 50 ? "\red" : "\blue"][C.getOxyLoss()]-[C.getToxLoss() > 50 ? "\red" : "\blue"][C.getToxLoss()]-[C.getFireLoss() > 50 ? "\red" : "\blue"][C.getFireLoss()]-[C.getBruteLoss() > 50 ? "\red" : "\blue"][C.getBruteLoss()]", 1)
				user.show_message("\blue \t Key: Suffocation/Toxin/Burns/Brute", 1)
				user.show_message("\blue \t Body Temperature: [C.bodytemperature-T0C]&deg;C ([C.bodytemperature*1.8-459.67]&deg;F)", 1)
				if(C.timeofdeath && (C.stat == DEAD || (C.status_flags & FAKEDEATH)))
					user.show_message("\blue \t Time of Death: [C.timeofdeath]")
				if(istype(C, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = C
					var/list/damaged = H.get_damaged_organs(1,1)
					user.show_message("\blue Localized Damage, Brute/Burn:",1)
					if(length(damaged)>0)
						for(var/obj/item/organ/external/org in damaged)
							user.show_message(text("\blue \t []: []\blue-[]",capitalize(org.name),(org.brute_dam > 0)?"\red [org.brute_dam]":0,(org.burn_dam > 0)?"\red [org.burn_dam]":0),1)
					else
						user.show_message("\blue \t Limbs are OK.",1)

			if(2)
				if (!istype(C:dna, /datum/dna))
					user << "\blue No fingerprints found on [C]"
				else
					user << text("\blue [C]'s Fingerprints: [md5(C:dna.uni_identity)]")
				if ( !(C:blood_DNA) )
					user << "\blue No blood found on [C]"
					if(C:blood_DNA)
						qdel(C:blood_DNA)
				else
					user << "\blue Blood found on [C]. Analysing..."
					spawn(15)
						for(var/blood in C:blood_DNA)
							user << "\blue Blood type: [C:blood_DNA[blood]]\nDNA: [blood]"

			if(4)
				for (var/mob/O in viewers(C, null))
					O.show_message("\red [user] has analyzed [C]'s radiation levels!", 1)

				user.show_message("\blue Analyzing Results for [C]:")
				if(C.radiation)
					user.show_message("\green Radiation Level: \black [C.radiation]")
				else
					user.show_message("\blue No radiation detected.")

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(!proximity) return
	switch(scanmode)

		if(3)
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					user << "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>"
					for (var/re in A.reagents.reagent_list)
						user << "<span class='notice'>\t [re]</span>"
				else
					user << "<span class='notice'>No active chemical agents found in [A].</span>"
			else
				user << "<span class='notice'>No significant chemical agents found in [A].</span>"

		if(5)
			if (istype(A, /obj/item/weapon/tank))
				var/obj/item/weapon/tank/T = A
				atmosanalyzer_scan(T.air_contents, user, T)
			else if (istype(A, /obj/machinery/portable_atmospherics))
				var/obj/machinery/portable_atmospherics/T = A
				atmosanalyzer_scan(T.air_contents, user, T)
			else if (istype(A, /obj/machinery/atmospherics/pipe))
				var/obj/machinery/atmospherics/pipe/T = A
				atmosanalyzer_scan(T.parent.air, user, T)
			else if (istype(A, /obj/machinery/power/rad_collector))
				var/obj/machinery/power/rad_collector/T = A
				if(T.P) atmosanalyzer_scan(T.P.air_contents, user, T)
			else if (istype(A, /obj/item/weapon/flamethrower))
				var/obj/item/weapon/flamethrower/T = A
				if(T.ptank) atmosanalyzer_scan(T.ptank.air_contents, user, T)
			else if (istype(A, /obj/machinery/portable_atmospherics/scrubber/huge))
				var/obj/machinery/portable_atmospherics/scrubber/huge/T = A
				atmosanalyzer_scan(T.air_contents, user, T)
			else if (istype(A, /obj/machinery/atmospherics/unary/tank))
				var/obj/machinery/atmospherics/unary/tank/T = A
				atmosanalyzer_scan(T.air_contents, user, T)

	if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		// JMO 20140705: Makes scanned document show up properly in the notes. Not pretty for formatted documents,
		// as this will clobber the HTML, but at least it lets you scan a document. You can restore the original
		// notes by editing the note again. (Was going to allow you to edit, but scanned documents are too long.)
		var/raw_scan = (A:info)
		var/formatted_scan = ""
		// Scrub out the tags (replacing a few formatting ones along the way)
		// Find the beginning and end of the first tag.
		var/tag_start = findtext(raw_scan,"<")
		var/tag_stop = findtext(raw_scan,">")
		// Until we run out of complete tags...
		while(tag_start&&tag_stop)
			var/pre = copytext(raw_scan,1,tag_start) // Get the stuff that comes before the tag
			var/tag = lowertext(copytext(raw_scan,tag_start+1,tag_stop)) // Get the tag so we can do intellegent replacement
			var/tagend = findtext(tag," ") // Find the first space in the tag if there is one.
			// Anything that's before the tag can just be added as is.
			formatted_scan = formatted_scan+pre
			// If we have a space after the tag (and presumably attributes) just crop that off.
			if (tagend)
				tag=copytext(tag,1,tagend)
			if (tag=="p"||tag=="/p"||tag=="br") // Check if it's I vertical space tag.
				formatted_scan=formatted_scan+"<br>" // If so, add some padding in.
			raw_scan = copytext(raw_scan,tag_stop+1) // continue on with the stuff after the tag
			// Look for the next tag in what's left
			tag_start = findtext(raw_scan,"<")
			tag_stop = findtext(raw_scan,">")
		// Anything that is left in the page. just tack it on to the end as is
		formatted_scan=formatted_scan+raw_scan
    	// If there is something in there already, pad it out.
		if (length(note)>0)
			note = note + "<br><br>"
    	// Store the scanned document to the notes
		note = "Scanned Document. Edit to restore previous notes/delete scan.<br>----------<br>" + formatted_scan + "<br>"
		// notehtml ISN'T set to allow user to get their old notes back. A better implementation would add a "scanned documents"
		// feature to the PDA, which would better convey the availability of the feature, but this will work for now.
		// Inform the user
		user << "\blue Paper scanned and OCRed to notekeeper." //concept of scanning paper copyright brainoblivion 2009

/obj/item/device/pda/proc/explode() //This needs tuning.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='danger'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3)
	qdel(src)
	return

/obj/item/device/pda/Destroy()
	PDAs -= src
	if (src.id)
		src.id.loc = get_turf(src.loc)
	if(src.pai)
		src.pai.loc = get_turf(src.loc)
	return ..()

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if ((istype(M, /mob/living/carbon/human) && (istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP)) || M.m_intent == "walk")
			return

		if ((istype(M, /mob/living/carbon/human) && (M.real_name != src.owner) && (istype(src.cartridge, /obj/item/weapon/cartridge/clown))))
			if (src.cartridge.charges < 5)
				src.cartridge.charges++

		M.stop_pulling()
		M << "\blue You slipped on the PDA!"
		playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
		M.Stun(8)
		M.Weaken(5)

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	if (toff)
		usr << "Turn on your receiver in order to send messages."
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else if (P.toff)
			continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist

//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

	New()
		..()
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/device/pda(src)
		new /obj/item/weapon/cartridge/head(src)

		var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
							/obj/item/weapon/cartridge/security,
							/obj/item/weapon/cartridge/medical,
							/obj/item/weapon/cartridge/signal/toxins,
							/obj/item/weapon/cartridge/quartermaster)
		new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)
