var/list/obj/machinery/photocopier/faxmachine/allfaxes = list()
var/list/admin_departments = list("Central Command")
var/list/alldepartments = list()

var/list/adminfaxes = list()	//cache for faxes that have been sent to admins

/obj/machinery/photocopier/faxmachine
	name = "fax machine"
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	insert_anim = "faxsend"
	req_one_access = list(access_lawyer, access_heads, access_armory) 

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200

	var/obj/item/weapon/card/id/scan = null // identification
	var/authenticated = 0
	var/sendcooldown = 0 // to avoid spamming fax messages

	var/department = "Unknown" // our department

	var/destination = "Central Command" // the department we're sending to
	
	var/data[0]

/obj/machinery/photocopier/faxmachine/New()
	..()
	allfaxes += src

	if( !(("[department]" in alldepartments) || ("[department]" in admin_departments)) )
		alldepartments |= department

/obj/machinery/photocopier/faxmachine/attack_hand(mob/user as mob)
	ui_interact(user)
	
/obj/machinery/photocopier/faxmachine/attackby(obj/item/weapon/item, mob/user)
	if(istype(item,/obj/item/weapon/card/id) && !scan)
		scan(item)
	else if(istype(item, /obj/item/weapon/paper) || istype(item, /obj/item/weapon/photo) || istype(item, /obj/item/weapon/paper_bundle))
		..()
		nanomanager.update_uis(src)
	else
		return ..()
	
/obj/machinery/photocopier/faxmachine/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(scan)
		data["scan_name"] = scan.name
	else
		data["scan_name"] = "-----"
	data["authenticated"] = authenticated
	if(!authenticated)
		data["network"] = "Disconnected"
	else if(!emagged)
		data["network"] = "Central Command Quantum Entanglement Network"
	else
		data["network"] = "ERR?*!!*"
	if(copyitem)
		data["paper"] = copyitem.name
		data["paperinserted"] = 1
	else
		data["paper"] = "-----"
		data["paperinserted"] = 0
	data["destination"] = destination
	data["cooldown"] = sendcooldown

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)	
	if (!ui)
		ui = new(user, src, ui_key, "faxmachine.tmpl", "Fax Machine UI", 540, 450)
		ui.set_initial_data(data)		
		ui.open()

/obj/machinery/photocopier/faxmachine/Topic(href, href_list)
	if(..())
		return 1
		
	if(href_list["send"])
		if(copyitem && authenticated)
			if (destination in admin_departments)
				send_admin_fax(usr, destination)
			else
				sendfax(destination)
			
			if (sendcooldown)
				spawn(sendcooldown) // cooldown time
					sendcooldown = 0
					nanomanager.update_uis(src)

	if(href_list["paper"])
		if(copyitem)
			copyitem.loc = usr.loc
			usr.put_in_hands(copyitem)
			usr << "<span class='notice'>You take \the [copyitem] out of \the [src].</span>"
			copyitem = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/weapon/paper_bundle))
				usr.drop_item()
				copyitem = I
				I.loc = src
				usr << "<span class='notice'>You insert \the [I] into \the [src].</span>"
				flick(insert_anim, src)

	if(href_list["scan"])
		scan()

	if(href_list["dept"])
		if(authenticated)
			var/lastdestination = destination
			destination = input(usr, "Which department?", "Choose a department", "") as null|anything in (alldepartments + admin_departments)
			if(!destination) 
				destination = lastdestination

	if(href_list["auth"])
		if((!authenticated) && scan)
			if(check_access(scan))
				authenticated = 1
		else if(authenticated)
			authenticated = 0
			
	if(href_list["rename"])
		if(copyitem)
			var/n_name = copytext(sanitize(input(usr, "What would you like to label the fax?", "Fax Labelling", copyitem.name)  as text), 1, MAX_MESSAGE_LEN)
			if((copyitem && copyitem.loc == src && usr.stat == 0))
				if (istype(copyitem, /obj/item/weapon/paper)) 
					copyitem.name = "[(n_name ? text("[n_name]") : initial(copyitem.name))]"		
					copyitem.desc = "This is a paper titled '" + copyitem.name + "'."					
				else if(istype(copyitem, /obj/item/weapon/photo)) 
					copyitem.name = "[(n_name ? text("[n_name]") : "photo")]"
				else if(istype(copyitem, /obj/item/weapon/paper_bundle))
					copyitem.name = "[(n_name ? text("[n_name]") : "paper")]"
				data["name"] = copyitem.name				

	nanomanager.update_uis(src)
	
/obj/machinery/photocopier/faxmachine/proc/scan(var/obj/item/weapon/card/id/card = null)
	if (scan) // Card is in machine
		if(ishuman(usr))
			scan.loc = usr.loc
			if(!usr.get_active_hand())
				usr.put_in_hands(scan)
			scan = null
		else
			scan.loc = src.loc
			scan = null
	else
		if(!card)
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				usr.drop_item()
				I.loc = src
				scan = I
		else
			if(istype(card))
				usr.drop_item()
				card.loc = src
				scan = card
	nanomanager.update_uis(src)

/obj/machinery/photocopier/faxmachine/proc/sendfax(var/destination)
	if(stat & (BROKEN|NOPOWER))
		return
	
	use_power(200)
	
	var/success = 0
	for(var/obj/machinery/photocopier/faxmachine/F in allfaxes)
		if( F.department == destination )
			success = F.recievefax(copyitem)
	
	if (success)
		visible_message("[src] beeps, \"Message transmitted successfully.\"")
		//sendcooldown = 600
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")

/obj/machinery/photocopier/faxmachine/proc/recievefax(var/obj/item/incoming)
	if(stat & (BROKEN|NOPOWER))
		return 0
	
	if(department == "Unknown")
		return 0	//You can't send faxes to "Unknown"

	flick("faxreceive", src)
	playsound(loc, "sound/items/polaroid1.ogg", 50, 1)
	
	// give the sprite some time to flick
	sleep(20)
	
	if (istype(incoming, /obj/item/weapon/paper))
		copy(incoming)
	else if (istype(incoming, /obj/item/weapon/photo))
		photocopy(incoming)
	else if (istype(incoming, /obj/item/weapon/paper_bundle))
		bundlecopy(incoming)
	else
		return 0

	use_power(active_power_usage)
	return 1

/obj/machinery/photocopier/faxmachine/proc/send_admin_fax(var/mob/sender, var/destination)
	if(stat & (BROKEN|NOPOWER))
		return
	
	use_power(200)

	var/obj/item/rcvdcopy
	if (istype(copyitem, /obj/item/weapon/paper))
		rcvdcopy = copy(copyitem)
	else if (istype(copyitem, /obj/item/weapon/photo))
		rcvdcopy = photocopy(copyitem)
	else if (istype(copyitem, /obj/item/weapon/paper_bundle))
		rcvdcopy = bundlecopy(copyitem)
	else
		visible_message("[src] beeps, \"Error transmitting message.\"")
		return
	
	rcvdcopy.loc = null //hopefully this shouldn't cause trouble
	adminfaxes += rcvdcopy
	
	//message badmins that a fax has arrived
	switch(destination)
		if ("Central Command")
			message_admins(sender, "CENTCOMM FAX", rcvdcopy, "CentcommFaxReply", "#006100")
	
	sendcooldown = 1800
	sleep(50)
	visible_message("[src] beeps, \"Message transmitted successfully.\"")
	

/obj/machinery/photocopier/faxmachine/proc/message_admins(var/mob/sender, var/faxname, var/obj/item/sent, var/reply_type, font_colour="#006100")
	var/msg = "\blue <b><font color='[font_colour]'>[faxname]: </font>[key_name(sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<a href='?_src_=holder;[reply_type]=\ref[sender];originfax=\ref[src]'>REPLY</a>)</b>: Receiving '[sent.name]' via secure connection ... <a href='?_src_=holder;AdminFaxView=\ref[sent]'>view message</a>"

	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			C << msg
