/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to station areas."
	icon_state = "guest"

	var/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/reason = "NOT SPECIFIED"

/obj/item/card/id/guest/attach_guest_pass(/obj/item/card/id/guest/G, mob/user)
	return

/obj/item/card/id/guest/GetAccess()
	if(world.time > expiration_time)
		return access
	else
		return temp_access

/obj/item/card/id/guest/examine(mob/user)
	. = ..()
	if(world.time < expiration_time)
		. += "<span class='notice'>This pass expires at [station_time_timestamp("hh:mm:ss", expiration_time)].</span>"
	else
		. += "<span class='warning'>It expired at [station_time_timestamp("hh:mm:ss", expiration_time)].</span>"
	. += "<span class='notice'>It grants access to following areas:</span>"
	for(var/A in temp_access)
		. += "<span class='notice'>[get_access_desc(A)].</span>"
	. += "<span class='notice'>Issuing reason: [reason].</span>"

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	desc = "This console allows staff to give out temporary access to their coworkers."
	icon_state = "guest"
	icon_screen = "pass"
	icon_keyboard = null
	density = FALSE


	var/obj/item/card/id/scan
	var/list/accesses = list()
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/duration = 5
	var/print_cooldown = 0

	var/static/global_terminal_id = 0
	var/my_terminal_id

	var/list/internal_log = list()
	var/mode = FALSE  // FALSE - making pass, TRUE - viewing logs

/obj/machinery/computer/guestpass/Initialize(mapload)
	. = ..()
	my_terminal_id = ++global_terminal_id

/obj/machinery/computer/guestpass/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/card/id/nct_data_chip))
		to_chat(user, "<span class='warning'>[used] does not seem compatible with this terminal!</span>")
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/card/id))
		if(!scan)
			if(user.drop_item())
				used.forceMove(src)
				scan = used
				SStgui.update_uis(src)
		else
			to_chat(user, "<span class='warning'>There is already ID card inside.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/computer/guestpass/proc/get_changeable_accesses()
	return scan.access

/obj/machinery/computer/guestpass/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/computer/guestpass/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/guestpass/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/guestpass/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GuestPass",  name)
		ui.open()

/obj/machinery/computer/guestpass/ui_data(mob/user)
	var/list/data = list()
	data["showlogs"] = mode
	data["scan_name"] = scan ? scan.name : FALSE
	data["issue_log"] = internal_log ? internal_log : list()
	data["giv_name"] = giv_name
	data["reason"] = reason
	data["duration"] = duration
	if(scan && !(ACCESS_CHANGE_IDS in scan.access))
		data["grantableList"] = scan ? scan.access : list()
	data["canprint"] = FALSE
	if(!scan)
		data["printmsg"] = "No card inserted."
	else if(!length(scan.access))
		data["printmsg"] = "Card has no access."
	else if(!length(accesses))
		data["printmsg"] = "No access types selected."
	else if(print_cooldown > world.time)
		data["printmsg"] = "Busy for [(round((print_cooldown - world.time) / 10))]s.."
	else
		data["printmsg"] = "Print Pass"
		data["canprint"] = TRUE

	data["selectedAccess"] = accesses ? accesses : list()
	return data

/obj/machinery/computer/guestpass/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(REGION_GENERAL, REGION_COMMAND)
	return data

/obj/machinery/computer/guestpass/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE
	switch(action)
		if("scan") // insert/remove your ID card
			if(scan)
				if(ishuman(usr))
					scan.forceMove(get_turf(usr))
					usr.put_in_hands(scan)
					scan = null
				else
					scan.forceMove(get_turf(src))
					scan = null
				accesses.Cut()
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id))
					if(usr.drop_item())
						I.forceMove(src)
						scan = I
		if("mode")
			mode = !mode
	if(!scan || !scan.access)
		return // everything below here requires card auth
	switch(action)
		if("giv_name")
			var/nam = strip_html_simple(input("Person pass is issued to", "Name", giv_name) as text | null)
			if(nam)
				giv_name = nam
		if("reason")
			var/reas = strip_html_simple(input("Reason why pass is issued", "Reason", reason) as text | null)
			if(reas)
				reason = reas
		if("duration")
			var/dur = input("Duration (in minutes) during which pass is valid (up to 30 minutes).", "Duration") as num | null
			if(dur)
				if(dur > 0 && dur <= 30)
					duration = dur
				else
					to_chat(usr, "<span class='warning'>Invalid duration.</span>")
		if("print")
			var/dat = "<h3>Activity log of guest pass terminal #[global_terminal_id]</h3><br>"
			for(var/entry in internal_log)
				dat += "[entry]<br><hr>"
			var/obj/item/paper/P = new /obj/item/paper(loc)
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			P.name = "activity log"
			P.info = dat
		if("issue")
			if(!length(accesses))
				return
			if(print_cooldown > world.time)
				return
			var/number = add_zero("[rand(0, 9999)]", 4)
			var/entry = "\[[station_time()]\] Pass #[number] issued by [scan.registered_name] ([scan.assignment]) to [giv_name]. Reason: [reason]. Grants access to following areas: "
			for(var/i in 1 to length(accesses))
				var/A = accesses[i]
				if(A)
					var/area = get_access_desc(A)
					entry += "[i > 1 ? ", [area]" : "[area]"]"
			var/obj/item/card/id/guest/pass = new(get_turf(src))
			if(Adjacent(ui.user))
				ui.user.put_in_hands(pass)
			pass.temp_access = accesses.Copy()
			pass.registered_name = giv_name
			pass.expiration_time = world.time + duration MINUTES
			pass.reason = reason
			pass.name = "guest pass #[number]"
			print_cooldown = world.time + 10 SECONDS
			entry += ". Expires at [station_time_timestamp("hh:mm:ss", pass.expiration_time)]."
			internal_log += entry
		if("access")
			var/A = text2num(params["access"])
			if(A in accesses)
				accesses.Remove(A)
			else if(ACCESS_CHANGE_IDS in scan.access)
				accesses += A
			else if(A in get_changeable_accesses())
				accesses += A
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			if(ACCESS_CHANGE_IDS in scan.access)
				accesses |= get_region_accesses(region)
			else
				var/list/new_accesses = get_region_accesses(region)
				for(var/A in new_accesses)
					if(A in scan.access)
						accesses.Add(A)
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses -= get_region_accesses(region)
		if("clear_all")
			accesses = list()
		if("grant_all")
			if(ACCESS_CHANGE_IDS in scan.access)
				accesses = get_all_accesses()
			else
				var/list/new_accesses = get_all_accesses()
				for(var/A in new_accesses)
					if(A in scan.access)
						accesses += A
	if(.)
		add_fingerprint(usr)

/obj/machinery/computer/guestpass/hop
	name = "\improper HoP guest pass terminal"
	desc = "The Head of Personnel's guest pass terminal allows the HoP to temporarily allow anyone into places they probably shouldn't be."

/obj/machinery/computer/guestpass/hop/get_changeable_accesses()
	. = ..()
	if(. && (ACCESS_CHANGE_IDS in .))
		return get_all_accesses()
