/obj/machinery/computer/prisoner
	name = "implant management console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "security_key"
	icon_screen = "explosive"
	req_access = list(ACCESS_ARMORY)
	circuit = /obj/item/circuitboard/prisoner
	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed
	var/obj/item/card/id/prisoner/inserted_id

	light_color = LIGHT_COLOR_DARKRED

/obj/machinery/computer/prisoner/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/prisoner/New()
 	GLOB.prisoncomputer_list += src
 	return ..()

/obj/machinery/computer/prisoner/Destroy()
 	GLOB.prisoncomputer_list -= src
 	return ..()

/obj/machinery/computer/prisoner/attack_hand(var/mob/user as mob)
	if(..())
		return 1
	user.set_machine(src)
	var/dat
	dat += "<B>Prisoner Implant Manager System</B><BR>"
	if(screen == 0)
		dat += "<HR><A href='?src=[UID()];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		if(istype(inserted_id))
			var/p = inserted_id:points
			var/g = inserted_id:goal
			dat += text("<A href='?src=[UID()];id=1'>[inserted_id]</A><br>")
			dat += text("Collected points: [p]. <A href='?src=[UID()];id=2'>Reset.</A><br>")
			dat += text("Card goal: [g].  <A href='?src=[UID()];id=3'>Set </A><br>")
			dat += text("Space Law recommends sentences of 100 points per minute they would normally serve in the brig.<BR>")
		else
			dat += text("<A href='?src=[UID()];id=0'>Insert Prisoner ID</A><br>")
		var/turf/Tr = null
		dat += "<HR>Chemical Implants<BR>"
		for(var/obj/item/implant/chem/C in GLOB.tracked_implants)
			Tr = get_turf(C)
			if((Tr) && (Tr.z != src.z))	continue//Out of range
			if(!C.implanted) continue
			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\prisoner.dm:41: dat += "[C.imp_in.name] | Remaining Units: [C.reagents.total_volume] | Inject: "
			dat += {"[C.imp_in.name] | Remaining Units: [C.reagents.total_volume] | Inject:
				<A href='?src=[UID()];inject1=\ref[C]'>(<font color=red>(1)</font>)</A>
				<A href='?src=[UID()];inject5=\ref[C]'>(<font color=red>(5)</font>)</A>
				<A href='?src=[UID()];inject10=\ref[C]'>(<font color=red>(10)</font>)</A><BR>
				********************************<BR>"}
			// END AUTOFIX
		dat += "<HR>Tracking Implants<BR>"
		for(var/obj/item/implant/tracking/T in GLOB.tracked_implants)
			Tr = get_turf(T)
			if((Tr) && (Tr.z != src.z))	continue//Out of range
			if(!T.implanted) continue
			var/mob/living/carbon/M = T.imp_in
			var/loc_display = "Unknown"
			var/health_display = "OK"
			var/total_loss = (M.maxHealth - M.health)
			if(M.stat == DEAD)
				health_display = "DEAD"
			else if(total_loss)
				health_display = "HURT ([total_loss])"
			if(is_station_level(Tr.z) && !istype(Tr.loc, /turf/space))
				loc_display = "[get_area(Tr)]"
			dat += "ID: [T.id] <BR>Subject: [M] <BR>Location: [loc_display] <BR>Health: [health_display] <BR>"
			dat += "<A href='?src=[UID()];warn=\ref[T]'>(<font color=red><i>Message Holder</i></font>)</A> |<BR>"
			dat += "********************************<BR>"
		dat += "<HR><A href='?src=[UID()];lock=1'>Lock Console</A>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/prisoner/process()
	if(!..())
		src.updateDialog()
	return

/obj/machinery/computer/prisoner/Topic(href, href_list)
	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["id"])
		switch(href_list["id"])
			if("0")
				var/obj/item/card/id/prisoner/I = usr.get_active_hand()
				if(istype(I))
					usr.drop_item()
					I.loc = src
					inserted_id = I
				else
					to_chat(usr, "<span class='warning'>No valid ID.</span>")
			if("1")
				inserted_id.loc = get_step(src,get_turf(usr))
				inserted_id = null
			if("2")
				inserted_id.points = 0
			if("3")
				var/num = round(input(usr, "Choose prisoner's goal:", "Input an Integer", null) as num|null)
				if(num >= 0)
					inserted_id.goal = num
	if(href_list["inject1"])
		var/obj/item/implant/I = locate(href_list["inject1"])
		if(I)	I.activate(1)

	else if(href_list["inject5"])
		var/obj/item/implant/I = locate(href_list["inject5"])
		if(I)	I.activate(5)

	else if(href_list["inject10"])
		var/obj/item/implant/I = locate(href_list["inject10"])
		if(I)	I.activate(10)

	else if(href_list["lock"])
		if(src.allowed(usr))
			screen = !screen
		else
			to_chat(usr, "<span class='warning'>Unauthorized access.</span>")

	else if(href_list["warn"])
		var/warning = sanitize(copytext(input(usr,"Message:","Enter your message here!",""),1,MAX_MESSAGE_LEN))
		if(!warning) return
		var/obj/item/implant/I = locate(href_list["warn"])
		if((I)&&(I.imp_in))
			var/mob/living/carbon/R = I.imp_in
			to_chat(R, "<span class='boldnotice'>You hear a voice in your head saying: '[warning]'</span>")

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return
