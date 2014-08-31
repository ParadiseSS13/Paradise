//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
/obj/machinery/computer3/prisoner
	default_prog = /datum/file/program/prisoner
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio)
	icon_state = "frame-sec"

/datum/file/program/prisoner
	name = "Prisoner Management Console"
	active_state = "explosive"
	req_access = list(access_armory)

	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed


	interact()
		if(!interactable())
			return
		var/dat
		dat += "<B>Prisoner Implant Manager System</B><BR>"
		if(screen == 0)
			dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
		else if(screen == 1)
			dat += "<HR>Chemical Implants<BR>"
			var/turf/Tr = null
			for(var/obj/item/weapon/implant/chem/C in world)
				Tr = get_turf(C)
				if((Tr) && (Tr.z != computer.z))	continue//Out of range
				if(!C.implanted) continue
				dat += "[C.imp_in.name] | Remaining Units: [C.reagents.total_volume] | Inject: "
				dat += "<A href='?src=\ref[src];inject1=\ref[C]'>(<font color=red>(1)</font>)</A>"
				dat += "<A href='?src=\ref[src];inject5=\ref[C]'>(<font color=red>(5)</font>)</A>"
				dat += "<A href='?src=\ref[src];inject10=\ref[C]'>(<font color=red>(10)</font>)</A><BR>"
				dat += "********************************<BR>"
			dat += "<HR>Tracking Implants<BR>"
			for(var/obj/item/weapon/implant/tracking/T in world)
				Tr = get_turf(T)
				if((Tr) && (Tr.z != computer.z))	continue//Out of range
				if(!T.implanted) continue
				var/loc_display = "Unknown"
				var/mob/living/carbon/M = T.imp_in
				if(M.z == 1 && !istype(M.loc, /turf/space))
					var/turf/mob_loc = get_turf(M)
					loc_display = mob_loc.loc
				if(T.malfunction)
					loc_display = pick(teleportlocs)
				dat += "ID: [T.id] | Location: [loc_display]<BR>"
				dat += "<A href='?src=\ref[src];warn=\ref[T]'>(<i>Send Message</i></font>)</A> |<BR>"
				dat += "********************************<BR>"
			dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"

		popup.width = 400
		popup.height = 500
		popup.set_content(dat)
		popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))
		popup.open()
		return


	process()
		if(!..())
			interact()
		return


	Topic(href, href_list)
		if(!interactable() || ..(href,href_list))
			return

		if(href_list["inject1"])
			var/obj/item/weapon/implant/I = locate(href_list["inject1"])
			if(istype(I))
				I.activate(1)

		else if(href_list["inject5"])
			var/obj/item/weapon/implant/I = locate(href_list["inject5"])
			if(istype(I))
				I.activate(5)

		else if(href_list["inject10"])
			var/obj/item/weapon/implant/I = locate(href_list["inject10"])
			if(istype(I))
				I.activate(10)

		else if(href_list["lock"])
			screen = !screen

		else if(href_list["warn"])
			var/warning = trim(copytext(sanitize(input(usr,"Message:","Enter your message here!","")),1,MAX_MESSAGE_LEN))
			if(!warning) return
			var/obj/item/weapon/implant/I = locate(href_list["warn"])
			if( istype(I) && I.imp_in)
				var/mob/living/carbon/R = I.imp_in
				log_say("PrisonComputer3 message: [key_name(usr)]->[key_name(R)] : [warning]")
				R << "\green You hear a voice in your head saying: '[warning]'"

		interact()
		return


