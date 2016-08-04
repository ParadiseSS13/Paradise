
//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()


/obj/item/device/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = 1
	slot_flags = SLOT_ID | SLOT_BELT | SLOT_PDA

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/datum/data/pda/app/current_app = null
	var/datum/data/pda/app/lastapp = null
	var/ui_tick = 0

	//Secondary variables
	var/model_name = "Thinktronic 5230 Personal Data Assistant"
	var/datum/data/pda/utility/scanmode/scanmode = null

	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/detonate = 1 // Can the PDA be blown up?
	var/ttone = "beep" //The ringtone!
	var/list/ttone_sound = list("beep" = 'sound/machines/twobeep.ogg',
								"boom" = 'sound/effects/explosionfar.ogg',
								"slip" = 'sound/misc/slip.ogg',
								"honk" = 'sound/items/bikehorn.ogg',
								"SKREE" = 'sound/voice/shriek1.ogg',
								"holy" = 'sound/items/PDA/ambicha4-short.ogg',
								"xeno" = 'sound/voice/hiss1.ogg')

	var/list/programs = list(
		new/datum/data/pda/app/main_menu,
		new/datum/data/pda/app/notekeeper,
		new/datum/data/pda/app/messenger,
		new/datum/data/pda/app/manifest,
		new/datum/data/pda/app/chatroom,
		new/datum/data/pda/app/atmos_scanner,
		new/datum/data/pda/utility/scanmode/notes,
		new/datum/data/pda/utility/flashlight)
	var/list/shortcut_cache = list()
	var/list/shortcut_cat_order = list()
	var/list/notifying_programs = list()

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above
	var/ownrank = null // this one is rank, never alt title

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device
	var/retro_mode = 0


/*
 *	The Actual PDA
 */
/obj/item/device/pda/New()
	..()
	PDAs += src
	PDAs = sortAtom(PDAs)
	update_programs()
	if(default_cartridge)
		cartridge = new default_cartridge(src)
		cartridge.update_programs(src)
	new /obj/item/weapon/pen(src)
	start_program(find_program(/datum/data/pda/app/main_menu))

/obj/item/device/pda/proc/can_use()
	if(!ismob(loc))
		return 0

	var/mob/M = loc
	if(M.incapacitated())
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

/obj/item/device/pda/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui_tick++
	var/datum/nanoui/old_ui = nanomanager.get_open_ui(user, src, "main")
	var/auto_update = 1
	if(!current_app)
		return

	if(current_app.update == PDA_APP_NOUPDATE && current_app == lastapp)
		auto_update = 0
	if(old_ui && (current_app == lastapp && ui_tick % 5 && current_app.update == PDA_APP_UPDATE_SLOW))
		return

	lastapp = current_app

	var/title = "Personal Data Assistant"

	var/data[0]  // This is the data that will be sent to the PDA


	data["owner"] = owner					// Who is your daddy...
	data["ownjob"] = ownjob					// ...and what does he do?

	// update list of shortcuts, only if they changed
	if(!shortcut_cache.len)
		shortcut_cache = list()
		shortcut_cat_order = list()
		var/prog_list = programs.Copy()
		if(cartridge)
			prog_list |= cartridge.programs

		for(var/A in prog_list)
			var/datum/data/pda/P = A

			if(P.hidden)
				continue
			var/list/cat
			if(P.category in shortcut_cache)
				cat = shortcut_cache[P.category]
			else
				cat = list()
				shortcut_cache[P.category] = cat
				shortcut_cat_order += P.category
			cat |= list(list(name = P.name, icon = P.icon, notify_icon = P.notify_icon, ref = "\ref[P]"))

		// force the order of a few core categories
		shortcut_cat_order = list("General") \
			+ sortList(shortcut_cat_order - list("General", "Scanners", "Utilities")) \
			+ list("Scanners", "Utilities")

	data["idInserted"] = (id ? 1 : 0)
	data["idLink"] = (id ? text("[id.registered_name], [id.assignment]") : "--------")

	data["useRetro"] = retro_mode

	data["cartridge_name"] = cartridge ? cartridge.name : ""
	data["stationTime"] = worldtime2text()

	data["app"] = list()
	current_app.update_ui(user, data)
	data["app"] |= list(
		"name" = current_app.title,
		"icon" = current_app.icon,
		"template" = current_app.template,
		"has_back" = current_app.has_back)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "pda.tmpl", title, 630, 600, state = inventory_state)
		ui.set_state_key("pda")

		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

	// auto update every Master Controller tick
	ui.set_auto_update(auto_update)

/obj/item/device/pda/attack_self(mob/user as mob)
	user.set_machine(src)
	if(active_uplink_check(user))
		return
	ui_interact(user) //NanoUI requires this proc

/obj/item/device/pda/proc/start_program(datum/data/pda/P)
	if(P && ((P in programs) || (cartridge && (P in cartridge.programs))))
		return P.start()
	return 0

/obj/item/device/pda/proc/find_program(type)
	var/datum/data/pda/A = locate(type) in programs
	if(A)
		return A
	if(cartridge)
		A = locate(type) in cartridge.programs
		if(A)
			return A
	return null

// force the cache to rebuild on update_ui
/obj/item/device/pda/proc/update_shortcuts()
	shortcut_cache.Cut()

/obj/item/device/pda/proc/update_programs()
	for(var/A in programs)
		var/datum/data/pda/P = A
		P.pda = src

/obj/item/device/pda/Topic(href, href_list)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
	var/mob/living/U = usr
	if(usr.stat == DEAD)
		return 0
	if(!can_use()) //Why reinvent the wheel? There's a proc that does exactly that.
		U.unset_machine()
		if(ui)
			ui.close()
		return 0

	add_fingerprint(U)
	U.set_machine(src)

	if(href_list["radiomenu"] && !isnull(cartridge) && !isnull(cartridge.radio))
		cartridge.radio.Topic(href, href_list)
		return 1

	. = 1

	switch(href_list["choice"])
		if("Home")//Go home, largely replaces the old Return
			var/datum/data/pda/app/main_menu/A = find_program(/datum/data/pda/app/main_menu)
			if(A)
				start_program(A)
		if("StartProgram")
			if(href_list["program"])
				var/datum/data/pda/app/A = locate(href_list["program"])
				if(A)
					start_program(A)
		if("Eject")//Ejects the cart, only done from hub.
			if(!isnull(cartridge))
				var/turf/T = loc
				if(ismob(T))
					T = T.loc
				var/obj/item/weapon/cartridge/C = cartridge
				C.forceMove(T)
				if(scanmode in C.programs)
					scanmode = null
				if(current_app in C.programs)
					start_program(find_program(/datum/data/pda/app/main_menu))
				if(C.radio)
					C.radio.hostpda = null
				for(var/datum/data/pda/P in notifying_programs)
					if(P in C.programs)
						P.unnotify()
				cartridge = null
				update_shortcuts()
		if("Authenticate")//Checks for ID
			id_check(usr, 1)
		if("Retro")
			retro_mode = !retro_mode
		if("Ringtone")
			return set_ringtone()
		else
			if(current_app)
				. = current_app.Topic(href, href_list)

//EXTRA FUNCTIONS===================================
	if((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	return // return 1 tells it to refresh the UI in NanoUI

/obj/item/device/pda/proc/close(mob/user)
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
	ui.close()

/obj/item/device/pda/verb/verb_reset_pda()
	set category = "Object"
	set name = "Reset PDA"
	set src in usr

	if(issilicon(usr))
		return

	if(can_use(usr))
		start_program(find_program(/datum/data/pda/app/main_menu))
		notifying_programs.Cut()
		overlays -= image('icons/obj/pda.dmi', "pda-r")
		to_chat(usr, "<span class='notice'>You press the reset button on \the [src].</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/pda/AltClick(mob/user)
	..()
	if(issilicon(usr))
		return

	if(can_use(user))
		if(id)
			remove_id()
		else
			to_chat(user, "<span class='warning'>This PDA does not have an ID in it!</span>")

/obj/item/device/pda/proc/remove_id()
	if(id)
		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			to_chat(usr, "<span class='notice'>You remove the ID from the [name].</span>")
		else
			id.forceMove(get_turf(src))
		overlays -= image('icons/goonstation/objects/pda_overlay.dmi', id.icon_state)
		id = null

/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if( can_use(usr) )
		if(id)
			remove_id()
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if( can_use(usr) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if(istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					to_chat(usr, "<span class='notice'>You remove \the [O] from \the [src].</span>")
					return
			O.forceMove(get_turf(src))
		else
			to_chat(usr, "<span class='notice'>This PDA does not have a pen in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")


/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if(id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if(istype(I, /obj/item/weapon/card/id))
				user.drop_item()
				I.forceMove(src)
				id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if(istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			user.drop_item()
			I.forceMove(src)
			id = I
			user.put_in_hands(old_id)
	return

/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob, params)
	..()
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		cartridge = C
		user.drop_item()
		cartridge.forceMove(src)
		cartridge.update_programs(src)
		update_shortcuts()
		to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
		if(cartridge.radio)
			cartridge.radio.hostpda = src

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			ownrank = idcard.rank
			name = "PDA-[owner] ([ownjob])"
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if( can_use(user) )//If they can still act.
					id_check(user, 2)
					to_chat(user, "<span class='notice'>You put the ID into \the [src]'s slot.<br>You can remove it with ALT click.</span>")
					overlays += image('icons/goonstation/objects/pda_overlay.dmi', C.icon_state)

	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		user.drop_item()
		C.forceMove(src)
		pai = C
		to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			user.drop_item()
			C.forceMove(src)
			to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")

/obj/item/device/pda/attack(mob/living/C as mob, mob/living/user as mob)
	if(istype(C, /mob/living/carbon) && scanmode)
		scanmode.scan_mob(C, user)

/obj/item/device/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(proximity && scanmode)
		scanmode.scan_atom(A, user)

/obj/item/device/pda/proc/explode() //This needs tuning.
	if(!src.detonate) return
	var/turf/T = get_turf(src.loc)

	if(ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='danger'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3)
	qdel(src)
	return

/obj/item/device/pda/Destroy()
	PDAs -= src
	var/T = get_turf(loc)
	if(id)
		id.forceMove(T)
	if(pai)
		pai.forceMove(T)
	current_app = null
	scanmode = null
	for(var/A in programs)
		qdel(A)
	programs.Cut()
	if(cartridge)
		qdel(cartridge)
		cartridge = null
	return ..()

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/obj/item/device/pda/proc/play_ringtone()
	var/S

	if(ttone in ttone_sound)
		S = ttone_sound[ttone]
	else
		S = 'sound/machines/twobeep.ogg'
	playsound(loc, S, 50, 1)
	for(var/mob/O in hearers(3, loc))
		O.show_message(text("[bicon(src)] *[ttone]*"))

/obj/item/device/pda/proc/set_ringtone()
	var/t = input("Please enter new ringtone", name, ttone) as text
	if(in_range(src, usr) && loc == usr)
		if(t)
			if(hidden_uplink && hidden_uplink.check_trigger(usr, lowertext(t), lowertext(lock_code)))
				to_chat(usr, "The PDA softly beeps.")
				close(usr)
			else
				t = sanitize(copytext(t, 1, 20))
				ttone = t
			return 1
	else
		close(usr)
	return 0
