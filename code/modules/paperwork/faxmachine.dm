GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command"))
GLOBAL_LIST_INIT(hidden_admin_departments, list("Syndicate"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(hidden_departments)
GLOBAL_LIST_EMPTY(fax_blacklist)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	desc = "Because just talking to your coworkers is too efficient."
	icon_state = "fax"
	insert_anim = "faxsend"
	var/receive_anim = "faxsend"
	pass_flags = PASSTABLE
	var/fax_network = "Local Fax Network"
	/// If true, prevents fax machine from sending messages to NT machines
	var/syndie_restricted = FALSE

	/// Can we send messages off-station?
	var/long_range_enabled = FALSE
	req_one_access = list(ACCESS_INTERNAL_AFFAIRS, ACCESS_HEADS, ACCESS_ARMORY)


	/// ID card inserted into the machine, used to log in with
	var/obj/item/card/id/scan = null

	/// Whether the machine is "logged in" or not
	var/authenticated = FALSE
	/// Next world.time at which this fax machine can send a message to CC/syndicate
	var/sendcooldown = 0
	/// After sending a message to CC/syndicate, cannot send another to them for this many deciseconds
	var/cooldown_time = 1800

	/// Our department, determines whether this machine gets faxes sent to a department
	var/department = "Unknown"

	/// Target department to send outgoing faxes to
	var/destination

/obj/machinery/photocopier/faxmachine/Initialize(mapload)
	. = ..()
	GLOB.allfaxes += src
	update_network()

/obj/machinery/photocopier/faxmachine/Destroy()
	GLOB.allfaxes -= src
	return ..()

/obj/machinery/photocopier/faxmachine/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt-Click</b> [src] to remove its currently stored ID.</span>"

/obj/machinery/photocopier/faxmachine/proc/update_network()
	if(department != "Unknown")
		if(!(("[department]" in GLOB.alldepartments) || ("[department]" in GLOB.hidden_departments) || ("[department]" in GLOB.admin_departments) || ("[department]" in GLOB.hidden_admin_departments)))
			GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/longrange
	name = "long range fax machine"
	desc = "A fax machine of the ancient days, now using modern entanglement networks, all the better to snitch on your coworkers."
	fax_network = "Central Command Quantum Entanglement Network"
	long_range_enabled = TRUE

/obj/machinery/photocopier/faxmachine/longrange/Initialize(mapload)
	. = ..()
	add_overlay("longfax")

/obj/machinery/photocopier/faxmachine/longrange/syndie
	name = "syndicate long range fax machine"
	desc = "For requesting supplies from your benefactors, not that they'll send you any."
	emagged = TRUE
	syndie_restricted = TRUE
	req_one_access = list(ACCESS_SYNDICATE)
	//No point setting fax network, being emagged overrides that anyway.

/obj/machinery/photocopier/faxmachine/longrange/syndie/Initialize(mapload)
	. = ..()
	add_overlay("syndiefax")

/obj/machinery/photocopier/faxmachine/longrange/syndie/update_network()
	if(department != "Unknown")
		GLOB.hidden_departments |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/card/id) && !scan)
		scan(used)
		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/paper) || istype(used, /obj/item/photo) || istype(used, /obj/item/paper_bundle))
		. = ..()
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE
	else if(istype(used, /obj/item/folder))
		to_chat(user, "<span class='warning'>The [src] can't accept folders!</span>")
		return ITEM_INTERACT_COMPLETE //early return so the parent proc doesn't suck up and items that a photocopier would take
	else
		return ..()

/obj/machinery/photocopier/faxmachine/MouseDrop_T()
	return //you should not be able to fax your ass without first copying it at an actual photocopier

/obj/machinery/photocopier/faxmachine/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		req_one_access = list()
		to_chat(user, "<span class='notice'>The transmitters realign to an unknown source!</span>")
		return TRUE
	else
		to_chat(user, "<span class='warning'>You swipe the card through [src], but nothing happens.</span>")

/obj/machinery/photocopier/faxmachine/proc/is_authenticated(mob/user)
	if(authenticated)
		return TRUE
	else if(user.can_admin_interact())
		return TRUE
	return FALSE

/obj/machinery/photocopier/faxmachine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaxMachine",  name)
		ui.open()

/obj/machinery/photocopier/faxmachine/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = is_authenticated(user)
	data["realauth"] = authenticated
	data["scan_name"] = scan ? scan.name : FALSE
	data["nologin"] = !data["scan_name"] && !data["realauth"]
	if(!data["authenticated"])
		data["network"] = "Disconnected"
	else if(!emagged)
		data["network"] = fax_network
	else
		data["network"] = "ERR*?*%!*"
	data["paper"] = copyitem ? copyitem.name : FALSE
	data["paperinserted"] = copyitem ? TRUE : FALSE
	data["destination"] = destination ? destination : FALSE
	data["sendError"] = FALSE
	if(stat & (BROKEN|NOPOWER))
		data["sendError"] = "No Power"
	else if(!data["authenticated"])
		data["sendError"] = "Not Logged In"
	else if(!data["paper"])
		data["sendError"] = "Nothing Inserted"
	else if(!data["destination"])
		data["sendError"] = "Destination Not Set"
	else if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments))
		var/cooldown_seconds = cooldown_seconds()
		if(cooldown_seconds)
			data["sendError"] = "Re-aligning in [cooldown_seconds] seconds..."
	return data


/obj/machinery/photocopier/faxmachine/ui_act(action, params)
	if(isnull(..())) // isnull(..()) here because the parent photocopier proc returns null as opposed to TRUE if the ui should not be interacted with.
		return
	var/is_authenticated = is_authenticated(usr)
	. = TRUE
	switch(action)
		if("scan") // insert/remove your ID card
			scan()
		if("auth") // log in/out
			if(!is_authenticated && scan)
				if(scan.registered_name in GLOB.fax_blacklist)
					to_chat(usr, "<span class='warning'>Login rejected: individual is blacklisted from fax network.</span>")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					. = FALSE
				else if(check_access(scan))
					authenticated = TRUE
				else // ID doesn't have access to this machine
					to_chat(usr, "<span class='warning'>Login rejected: ID card does not have required access.</span>")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					. = FALSE
			else if(is_authenticated)
				authenticated = FALSE
		if("paper") // insert/eject paper/paperbundle/photo
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				if(ishuman(usr))
					if(!usr.get_active_hand() && Adjacent(usr))
						usr.put_in_hands(copyitem)
				to_chat(usr, "<span class='notice'>You eject [copyitem] from [src].</span>")
				copyitem = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
					usr.drop_item()
					copyitem = I
					I.forceMove(src)
					to_chat(usr, "<span class='notice'>You insert [I] into [src].</span>")
					flick(insert_anim, src)
				else
					to_chat(usr, "<span class='warning'>[src] only accepts paper, paper bundles, and photos.</span>")
					. = FALSE
		if("rename") // rename the item that is currently in the fax machine
			if(copyitem)
				var/n_name = tgui_input_text(usr, "What would you like to label the fax?", "Fax Labelling", copyitem.name)
				if(!n_name)
					return
				if(copyitem && copyitem.loc == src && usr.stat == CONSCIOUS)
					if(istype(copyitem, /obj/item/paper))
						copyitem.name = "[(n_name ? "[n_name]" : initial(copyitem.name))]"
						copyitem.desc = "This is a paper titled '" + copyitem.name + "'."
					else if(istype(copyitem, /obj/item/photo))
						copyitem.name = "[(n_name ? "[n_name]" : "photo")]"
					else if(istype(copyitem, /obj/item/paper_bundle))
						copyitem.name = "[(n_name ? "[n_name]" : "paper")]"
					else
						. = FALSE
				else
					. = FALSE
			else
				. = FALSE
		if("dept") // choose which department receives the fax
			if(is_authenticated)
				var/lastdestination = destination
				var/list/combineddepartments = GLOB.alldepartments.Copy()
				if(long_range_enabled)
					combineddepartments += GLOB.admin_departments.Copy()
				if(emagged)
					combineddepartments += GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
				if(syndie_restricted)
					combineddepartments = GLOB.hidden_admin_departments.Copy()
					combineddepartments += GLOB.hidden_departments.Copy()
					for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
						if(F.emagged)//we can contact emagged faxes on the station
							combineddepartments |= F.department
				destination = tgui_input_list(usr, "To which department?", "Choose a department", combineddepartments)
				if(!destination)
					destination = lastdestination
		if("send") // actually send the fax
			if(!copyitem || !is_authenticated || !destination)
				return
			if(stat & (BROKEN|NOPOWER))
				return
			if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments))
				var/cooldown_seconds = cooldown_seconds()
				if(cooldown_seconds > 0)
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
					to_chat(usr, "<span class='warning'>[src] is not ready for another [cooldown_seconds] seconds.</span>")
					return
				send_admin_fax(usr, destination)
				sendcooldown = world.time + cooldown_time
			else
				sendfax(destination, usr)
	if(.)
		add_fingerprint(usr)

/obj/machinery/photocopier/faxmachine/proc/scan(obj/item/card/id/card = null)
	if(scan) // Card is in machine
		if(ishuman(usr))
			scan.forceMove(get_turf(src))
			if(!usr.get_active_hand() && Adjacent(usr))
				usr.put_in_hands(scan)
			scan = null
		else
			scan.forceMove(get_turf(src))
			scan = null
	else if(Adjacent(usr))
		if(!card)
			var/obj/item/I = usr.get_active_hand()
			if(istype(I, /obj/item/card/id))
				usr.drop_item()
				I.forceMove(src)
				scan = I
		else if(istype(card))
			usr.drop_item()
			card.forceMove(src)
			scan = card
	SStgui.update_uis(src)

/obj/machinery/photocopier/faxmachine/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(scan)
		to_chat(user, "<span class='notice'>You remove [scan] from [src].</span>")
		if(!user.get_active_hand())
			user.put_in_hands(scan)
		else if(!user.put_in_inactive_hand(scan))
			scan.forceMove(get_turf(src))
		scan = null
	else
		to_chat(user, "<span class='notice'>There is nothing to remove from [src].</span>")

/obj/machinery/photocopier/faxmachine/proc/sendfax(destination, mob/sender)
	use_power(active_power_consumption)
	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			var/datum/fax/A = new /datum/fax()
			A.name = copyitem.name
			A.from_department = department
			A.to_department = destination
			A.origin = src
			A.message = copyitem
			A.sent_by = sender
			A.sent_at = world.time

			success = F.receivefax(A)
	if(success)
		visible_message("[src] beeps, \"Message transmitted successfully.\"")
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/receivefax(datum/fax/incoming)
	if(stat & (BROKEN|NOPOWER))
		return FALSE

	if(department == "Unknown")
		return FALSE //You can't send faxes to "Unknown"

	flick(receive_anim, src)

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
	addtimer(CALLBACK(src, PROC_REF(print_fax), incoming), 2 SECONDS)
	return TRUE

/obj/machinery/photocopier/faxmachine/proc/print_fax(datum/fax/incoming)
	var/obj/item/new_copy = null
	if(istype(incoming.message, /obj/item/paper))
		new_copy = papercopy(incoming.message)
	else if(istype(incoming.message, /obj/item/photo))
		new_copy = photocopy(incoming.message)
	else if(istype(incoming.message, /obj/item/paper_bundle))
		new_copy = bundlecopy(incoming.message)
	else
		return

	// Store the fax that was received in the admin room in adminfaxes
	// Fixes issue where deleting the original would make it unreadable in the admin panel
	if(istype(incoming, /datum/fax/admin))
		var/datum/fax/admin/A = new /datum/fax/admin()
		A.name = new_copy.name
		A.from_department = incoming.from_department
		A.to_department = incoming.to_department
		A.origin = incoming.origin
		A.message = new_copy
		A.sent_by = incoming.sent_by
		A.sent_at = incoming.sent_at

		GLOB.adminfaxes += A

	use_power(active_power_consumption)

/obj/machinery/photocopier/faxmachine/proc/log_fax(mob/sender, destination)
	// Logging for sending photos
	if(istype(copyitem, /obj/item/photo))
		log_admin("[key_name(sender)] has sent a photo by fax to [destination]")
		return

	// Logging for single paper message
	if(istype(copyitem, /obj/item/paper))
		var/obj/item/paper/fax_message = copyitem
		log_admin("[key_name(sender)] has sent a message by fax to [destination] reading [fax_message.info]")
		return

	// Logging for paper bundle messages
	if(istype(copyitem, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/paper_bundle = copyitem
		// Incremented by one for each paper in the bundle
		var/page_count = 1

		// Loop through the contents of the paper bundle and grab the message from each page
		for(var/obj/item/paper/page in paper_bundle.contents)
			log_admin("[key_name(sender)] has sent a bundled message by fax to [destination] - Page [page_count]: [page.info]")
			page_count ++
		return

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(mob/sender, destination)
	use_power(active_power_consumption)

	if(!(istype(copyitem, /obj/item/paper) || istype(copyitem, /obj/item/paper_bundle) || istype(copyitem, /obj/item/photo)))
		visible_message("[src] beeps, \"Error transmitting message.\"")
		return

	var/datum/fax/admin/A = new /datum/fax/admin()
	A.name = copyitem.name
	A.from_department = department
	A.to_department = destination
	A.origin = src
	A.message = copyitem
	A.sent_by = sender
	A.sent_at = world.time

	//message badmins that a fax has arrived
	switch(destination)
		if("Central Command")
			message_admins(sender, "CENTCOM FAX", destination, copyitem, "#006100")
		if("Syndicate")
			message_admins(sender, "SYNDICATE FAX", destination, copyitem, "#DC143C")
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			F.receivefax(A)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")
	log_fax(sender, destination)

/obj/machinery/photocopier/faxmachine/proc/cooldown_seconds()
	if(sendcooldown < world.time)
		return 0
	return round((sendcooldown - world.time) / 10)

/obj/machinery/photocopier/faxmachine/proc/message_admins(mob/sender, faxname, faxtype, obj/item/sent, font_colour="#9A04D1")
	var/msg = "<span class='boldnotice'><font color='[font_colour]'>[faxname]: </font> [key_name_admin(sender)] | REPLY: (<A href='byond://?_src_=holder;[faxname == "SYNDICATE FAX" ? "SyndicateReply" : "CentcommReply"]=[sender.UID()]'>RADIO</A>) (<a href='byond://?_src_=holder;AdminFaxCreate=\ref[sender];originfax=\ref[src];faxtype=[faxtype];replyto=\ref[sent]'>FAX</a>) ([ADMIN_SM(sender,"SM")]) | REJECT: (<A href='byond://?_src_=holder;FaxReplyTemplate=[sender.UID()];originfax=\ref[src]'>TEMPLATE</A>) ([ADMIN_BSA(sender,"BSA")]) (<A href='byond://?_src_=holder;EvilFax=[sender.UID()];originfax=\ref[src]'>EVILFAX</A>) </span>: Receiving '[sent.name]' via secure connection... <a href='byond://?_src_=holder;AdminFaxView=\ref[sent]'>view message</a>"
	var/fax_sound = sound('sound/effects/adminhelp.ogg')
	for(var/client/C in GLOB.admins)
		if(check_rights(R_EVENT, 0, C.mob))
			to_chat(C, msg, MESSAGE_TYPE_ADMINPM)
			if(C.prefs.sound & SOUND_ADMINHELP)
				SEND_SOUND(C, fax_sound)

/obj/machinery/photocopier/faxmachine/proc/become_mimic()
	if(scan)
		scan.forceMove(get_turf(src))
	var/mob/living/simple_animal/hostile/mimic/copy/M = new(loc, src, null, 1) // it will delete src on creation and override any machine checks
	M.name = "angry fax machine"
