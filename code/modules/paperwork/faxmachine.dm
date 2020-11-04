GLOBAL_LIST_EMPTY(allfaxes)
GLOBAL_LIST_INIT(admin_departments, list("Central Command"))
GLOBAL_LIST_INIT(hidden_admin_departments, list("Syndicate"))
GLOBAL_LIST_EMPTY(alldepartments)
GLOBAL_LIST_EMPTY(hidden_departments)
GLOBAL_LIST_EMPTY(fax_blacklist)

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	pass_flags = PASSTABLE
	var/fax_network = "Local Fax Network"
	var/syndie_restricted = FALSE //is it a syndicate base fax restricted from contacting NT assets?

	var/long_range_enabled = 0 // Can we send messages off the station?
	req_one_access = list(ACCESS_LAWYER, ACCESS_HEADS, ACCESS_ARMORY)

	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200

	var/obj/item/card/id/scan = null // identification

	var/authenticated = 0
	var/sendcooldown = 0 // to avoid spamming fax messages
	var/cooldown_time = 1800

	var/department = "Unknown" // our department

	var/destination = "Not Selected" // the department we're sending to

/obj/machinery/photocopier/faxmachine/New()
	..()
	GLOB.allfaxes += src
	update_network()

/obj/machinery/photocopier/faxmachine/proc/update_network()
	if(department != "Unknown")
		if(!(("[department]" in GLOB.alldepartments) || ("[department]" in GLOB.hidden_departments) || ("[department]" in GLOB.admin_departments) || ("[department]" in GLOB.hidden_admin_departments)))
			GLOB.alldepartments |= department

/obj/machinery/photocopier/faxmachine/longrange
	name = "long range fax machine"
	fax_network = "Central Command Quantum Entanglement Network"
	long_range_enabled = 1

/obj/machinery/photocopier/faxmachine/longrange/syndie
	name = "syndicate long range fax machine"
	emagged = TRUE
	syndie_restricted = TRUE
	req_one_access = list(ACCESS_SYNDICATE)
	//No point setting fax network, being emagged overrides that anyway.

/obj/machinery/photocopier/faxmachine/longrange/syndie/update_network()
	if(department != "Unknown")
		GLOB.hidden_departments |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/photocopier/faxmachine/attackby(obj/item/item, mob/user, params)
	if(istype(item,/obj/item/card/id) && !scan)
		scan(item)
	else if(istype(item, /obj/item/paper) || istype(item, /obj/item/photo) || istype(item, /obj/item/paper_bundle))
		..()
		SSnanoui.update_uis(src)
	else
		return ..()

/obj/machinery/photocopier/faxmachine/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		req_one_access = list()
		to_chat(user, "<span class='notice'>The transmitters realign to an unknown source!</span>")
	else
		to_chat(user, "<span class='warning'>You swipe the card through [src], but nothing happens.</span>")

/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "faxmachine.tmpl", "Fax Machine UI", 540, 450)
		ui.open()

/obj/machinery/photocopier/faxmachine/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	var/is_authenticated = is_authenticated(user)

	if(scan)
		data["scan_name"] = scan.name
	else
		data["scan_name"] = "-----"
	data["authenticated"] = is_authenticated
	if(!is_authenticated)
		data["network"] = "Disconnected"
	else if(!emagged)
		data["network"] = fax_network
	else
		data["network"] = "ERR*?*%!*"
	if(copyitem)
		data["paper"] = copyitem.name
		data["paperinserted"] = 1
	else
		data["paper"] = "-----"
		data["paperinserted"] = 0
	data["destination"] = destination
	data["cooldown"] = sendcooldown
	if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments))
		data["respectcooldown"] = 1
	else
		data["respectcooldown"] = 0

	return data

/obj/machinery/photocopier/faxmachine/proc/is_authenticated(mob/user)
	if(authenticated)
		return TRUE
	else if(user.can_admin_interact())
		return TRUE
	return FALSE

/obj/machinery/photocopier/faxmachine/Topic(href, href_list)
	if(..())
		return 1

	var/is_authenticated = is_authenticated(usr)
	if(href_list["send"])
		if(copyitem && is_authenticated)
			if((destination in GLOB.admin_departments) || (destination in GLOB.hidden_admin_departments))
				send_admin_fax(usr, destination)
			else
				sendfax(destination, usr)

			if(sendcooldown)
				spawn(sendcooldown) // cooldown time
					sendcooldown = 0
					SSnanoui.update_uis(src)

	if(href_list["paper"])
		if(copyitem)
			copyitem.forceMove(get_turf(src))
			if(ishuman(usr))
				if(!usr.get_active_hand() && Adjacent(usr))
					usr.put_in_hands(copyitem)
			to_chat(usr, "<span class='notice'>You eject \the [copyitem] from \the [src].</span>")
			copyitem = null
		else
			var/obj/item/I = usr.get_active_hand()
			if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/paper_bundle))
				usr.drop_item()
				copyitem = I
				I.forceMove(src)
				to_chat(usr, "<span class='notice'>You insert \the [I] into \the [src].</span>")
				flick(insert_anim, src)

	if(href_list["scan"])
		scan()

	if(href_list["dept"])
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

			destination = input(usr, "To which department?", "Choose a department", "") as null|anything in combineddepartments
			if(!destination)
				destination = lastdestination

	if(href_list["auth"])
		if(!is_authenticated && scan)
			if(scan.registered_name in GLOB.fax_blacklist)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			else if(check_access(scan))
				authenticated = 1
		else if(is_authenticated)
			authenticated = 0

	if(href_list["rename"])
		if(copyitem)
			var/n_name = sanitize(copytext(input(usr, "What would you like to label the fax?", "Fax Labelling", copyitem.name)  as text, 1, MAX_MESSAGE_LEN))
			if((copyitem && copyitem.loc == src && usr.stat == 0))
				if(istype(copyitem, /obj/item/paper))
					copyitem.name = "[(n_name ? text("[n_name]") : initial(copyitem.name))]"
					copyitem.desc = "This is a paper titled '" + copyitem.name + "'."
				else if(istype(copyitem, /obj/item/photo))
					copyitem.name = "[(n_name ? text("[n_name]") : "photo")]"
				else if(istype(copyitem, /obj/item/paper_bundle))
					copyitem.name = "[(n_name ? text("[n_name]") : "paper")]"

	SSnanoui.update_uis(src)

/obj/machinery/photocopier/faxmachine/proc/scan(var/obj/item/card/id/card = null)
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
	SSnanoui.update_uis(src)

/obj/machinery/photocopier/faxmachine/verb/eject_id()
	set category = null
	set name = "Eject ID Card"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.forceMove(get_turf(src))
		if(!usr.get_active_hand() && Adjacent(usr))
			usr.put_in_hands(scan)
		scan = null
	else
		to_chat(usr, "There is nothing to remove from \the [src].")

/obj/machinery/photocopier/faxmachine/proc/sendfax(var/destination,var/mob/sender)
	if(stat & (BROKEN|NOPOWER))
		return

	use_power(200)

	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in GLOB.allfaxes)
		if(F.department == destination)
			success = F.receivefax(copyitem)

	if(success)
		var/datum/fax/F = new /datum/fax()
		F.name = copyitem.name
		F.from_department = department
		F.to_department = destination
		F.origin = src
		F.message = copyitem
		F.sent_by = sender
		F.sent_at = world.time

		visible_message("[src] beeps, \"Message transmitted successfully.\"")
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/receivefax(var/obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return 0

	if(department == "Unknown")
		return 0	//You can't send faxes to "Unknown"

	flick("faxreceive", src)

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

	// give the sprite some time to flick
	sleep(20)

	if(istype(incoming, /obj/item/paper))
		copy(incoming)
	else if(istype(incoming, /obj/item/photo))
		photocopy(incoming)
	else if(istype(incoming, /obj/item/paper_bundle))
		bundlecopy(incoming)
	else
		return 0

	use_power(active_power_usage)
	return 1

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(var/mob/sender, var/destination)
	if(stat & (BROKEN|NOPOWER))
		return

	if(sendcooldown)
		return

	use_power(200)

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
			F.receivefax(copyitem)
	sendcooldown = cooldown_time
	spawn(50)
		visible_message("[src] beeps, \"Message transmitted successfully.\"")


/obj/machinery/photocopier/faxmachine/proc/message_admins(var/mob/sender, var/faxname, var/faxtype, var/obj/item/sent, font_colour="#9A04D1")
	var/msg = "<span class='boldnotice'><font color='[font_colour]'>[faxname]: </font> [key_name_admin(sender)] | REPLY: (<A HREF='?_src_=holder;[faxname == "SYNDICATE FAX" ? "SyndicateReply" : "CentcommReply"]=[sender.UID()]'>RADIO</A>) (<a href='?_src_=holder;AdminFaxCreate=\ref[sender];originfax=\ref[src];faxtype=[faxtype];replyto=\ref[sent]'>FAX</a>) ([ADMIN_SM(sender,"SM")]) | REJECT: (<A HREF='?_src_=holder;FaxReplyTemplate=[sender.UID()];originfax=\ref[src]'>TEMPLATE</A>) ([ADMIN_BSA(sender,"BSA")]) (<A HREF='?_src_=holder;EvilFax=[sender.UID()];originfax=\ref[src]'>EVILFAX</A>) </span>: Receiving '[sent.name]' via secure connection... <a href='?_src_=holder;AdminFaxView=\ref[sent]'>view message</a>"
	for(var/client/C in GLOB.admins)
		if(check_rights(R_EVENT, 0, C.mob))
			to_chat(C, msg)
			if(C.prefs.sound & SOUND_ADMINHELP)
				C << 'sound/effects/adminhelp.ogg'

/obj/machinery/photocopier/faxmachine/proc/become_mimic()
	if(scan)
		scan.forceMove(get_turf(src))
	var/mob/living/simple_animal/hostile/mimic/copy/M = new(loc, src, null, 1) // it will delete src on creation and override any machine checks
	M.name = "angry fax machine"
