var/bomb_set

/obj/machinery/nuclearbomb
	name = "\improper Nuclear Fission Explosive"
	desc = "Uh oh. RUN!!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nuclearbomb0"
	density = 1
	var/deployable = 0.0
	var/extended = 0.0
	var/lighthack = 0
	var/opened = 0.0
	var/timeleft = 60.0
	var/timing = 0.0
	var/r_code = "ADMIN"
	var/code = ""
	var/yes_code = 0.0
	var/safety = 1.0
	var/obj/item/weapon/disk/nuclear/auth = null
	var/list/wires = list()
	var/light_wire
	var/safety_wire
	var/timing_wire
	var/removal_stage = 0 // 0 is no removal, 1 is covers removed, 2 is covers open, 3 is sealant open, 4 is unwrenched, 5 is removed from bolts.
	var/lastentered
	var/is_syndicate = 0
	use_power = 0
	unacidable = 1
	
/obj/machinery/nuclearbomb/syndicate
	is_syndicate = 1

/obj/machinery/nuclearbomb/New()
	..()
	r_code = "[rand(10000, 99999.0)]"//Creates a random code upon object spawn.
	src.wires["Red"] = 0
	src.wires["Blue"] = 0
	src.wires["Green"] = 0
	src.wires["Marigold"] = 0
	src.wires["Fuschia"] = 0
	src.wires["Black"] = 0
	src.wires["Pearl"] = 0
	var/list/w = list("Red","Blue","Green","Marigold","Black","Fuschia","Pearl")
	src.light_wire = pick(w)
	w -= src.light_wire
	src.timing_wire = pick(w)
	w -= src.timing_wire
	src.safety_wire = pick(w)
	w -= src.safety_wire

/obj/machinery/nuclearbomb/process()
	if (src.timing)
		bomb_set = 1 //So long as there is one nuke timing, it means one nuke is armed.
		src.timeleft--
		if (src.timeleft <= 0)
			explode()
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				nanomanager.update_uis(src)
	return

/obj/machinery/nuclearbomb/attackby(obj/item/weapon/O as obj, mob/user as mob, params)
	if (istype(O, /obj/item/weapon/screwdriver))
		src.add_fingerprint(user)
		if (src.auth)
			if (src.opened == 0)
				src.opened = 1
				overlays += image(icon, "npanel_open")
				user << "You unscrew the control panel of [src]."
			else
				src.opened = 0
				overlays -= image(icon, "npanel_open")
				user << "You screw the control panel of [src] back on."
		else
			if (src.opened == 0)
				user << "[src] emits a buzzing noise, the panel staying locked in."
			if (src.opened == 1)
				src.opened = 0
				overlays -= image(icon, "npanel_open")
				user << "You screw the control panel of [src] back on."
			flick("nuclearbombc", src)
		ui_interact(user)
		return

	if (istype(O, /obj/item/device/multitool) || istype(O, /obj/item/weapon/wirecutters))
		ui_interact(user)

	if (src.extended)
		if (istype(O, /obj/item/weapon/disk/nuclear))
			usr.drop_item()
			O.loc = src
			src.auth = O
			src.add_fingerprint(user)
			ui_interact(user)
			return

	if (src.anchored)
		switch(removal_stage)
			if(0)
				if(istype(O,/obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = O
					if(!WT.isOn()) return
					if (WT.get_fuel() < 5) // uses up 5 fuel.
						user << "\red You need more fuel to complete this task."
						return

					user.visible_message("[user] starts cutting loose the anchoring bolt covers on [src].", "You start cutting loose the anchoring bolt covers with [O]...")

					if(do_after(user,40))
						if(!src || !user || !WT.remove_fuel(5, user)) return
						user.visible_message("[user] cuts through the bolt covers on [src].", "You cut through the bolt cover.")
						removal_stage = 1
				return

			if(1)
				if(istype(O,/obj/item/weapon/crowbar))
					user.visible_message("[user] starts forcing open the bolt covers on [src].", "You start forcing open the anchoring bolt covers with [O]...")

					if(do_after(user,15))
						if(!src || !user) return
						user.visible_message("[user] forces open the bolt covers on [src].", "You force open the bolt covers.")
						removal_stage = 2
				return

			if(2)
				if(istype(O,/obj/item/weapon/weldingtool))

					var/obj/item/weapon/weldingtool/WT = O
					if(!WT.isOn()) return
					if (WT.get_fuel() < 5) // uses up 5 fuel.
						user << "\red You need more fuel to complete this task."
						return

					user.visible_message("[user] starts cutting apart the anchoring system sealant on [src].", "You start cutting apart the anchoring system's sealant with [O]...")

					if(do_after(user,40))
						if(!src || !user || !WT.remove_fuel(5, user)) return
						user.visible_message("[user] cuts apart the anchoring system sealant on [src].", "You cut apart the anchoring system's sealant.")
						removal_stage = 3
				return

			if(3)
				if(istype(O,/obj/item/weapon/wrench))

					user.visible_message("[user] begins unwrenching the anchoring bolts on [src].", "You begin unwrenching the anchoring bolts...")

					if(do_after(user,50))
						if(!src || !user) return
						user.visible_message("[user] unwrenches the anchoring bolts on [src].", "You unwrench the anchoring bolts.")
						removal_stage = 4
				return

			if(4)
				if(istype(O,/obj/item/weapon/crowbar))

					user.visible_message("[user] begins lifting [src] off of the anchors.", "You begin lifting the device off the anchors...")

					if(do_after(user,80))
						if(!src || !user) return
						user.visible_message("[user] crowbars [src] off of the anchors. It can now be moved.", "You jam the crowbar under the nuclear device and lift it off its anchors. You can now move it!")
						anchored = 0
						removal_stage = 5
				return
	..()


/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	if (src.extended)
		if (src.opened)
			nukehack_win(user,50)
		user.set_machine(src)
		ui_interact(user)
	else if (src.deployable)
		if(removal_stage < 5)
			src.anchored = 1
			visible_message("\red With a steely snap, bolts slide out of [src] and anchor it to the flooring!")
		else
			visible_message("\red \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.")
		if(!src.lighthack)
			flick("nuclearbombc", src)
			src.icon_state = "nuclearbomb1"
		src.extended = 1
	return

obj/machinery/nuclearbomb/proc/nukehack_win(mob/user as mob)
	ui_interact(user)

/obj/machinery/nuclearbomb/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	var/uiwidth
	var/uiheight
	var/uititle
	data["is_syndicate"] = is_syndicate
	if(!src.opened)
		data["hacking"] = 0
		data["auth"] = src.auth
		if (src.auth)
			if (src.yes_code)
				data["authstatus"] = src.timing ? "Functional/Set" : "Functional"
			else
				data["authstatus"] = "Auth. S2"
		else
			if (src.timing)
				data["authstatus"] = "Set"
			else
				data["authstatus"] = "Auth. S1"
		data["safe"] = src.safety ? "Safe" : "Engaged"
		data["time"] = src.timeleft
		data["timer"] = src.timing
		data["safety"] = src.safety
		data["anchored"] = src.anchored
		data["yescode"] = src.yes_code
		data["message"] = "AUTH"
		if (src.auth)
			data["message"] = src.code
			if (src.yes_code)
				data["message"] = "*****"
		uiwidth = 300
		uiheight = 510
		uititle = "Nuke Control Panel"
	else
		data["hacking"] = 1
		var/list/tempwires[0]
		for(var/wire in src.wires)
			tempwires.Add(list(list("name" = wire, "cut" = src.wires[wire])))
		data["wires"] = tempwires
		data["timing"] = src.timing
		data["safety"] = src.safety
		data["lighthack"] = src.lighthack
		uiwidth = 420
		uiheight = 440
		uititle = "Nuclear Bomb Defusion"
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "nuclear_bomb.tmpl", uititle, uiwidth, uiheight)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/nuclearbomb/verb/make_deployable()
	set category = "Object"
	set name = "Make Deployable"
	set src in oview(1)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if (src.deployable)
		usr << "\red You close several panels to make [src] undeployable."
		src.deployable = 0
	else
		usr << "\red You adjust some panels to make [src] deployable."
		src.deployable = 1
	return

/obj/machinery/nuclearbomb/Topic(href, href_list)
	if(..())
		return
	if (!usr.canmove || usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if(href_list["act"])
			var/temp_wire = href_list["wire"]
			if(href_list["act"] == "pulse")
				if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
					usr << "You need a multitool!"
				else
					if(src.wires[temp_wire])
						usr << "You can't pulse a cut wire."
					else
						if(src.light_wire == temp_wire)
							src.lighthack = !src.lighthack
							spawn(100) src.lighthack = !src.lighthack
						if(src.timing_wire == temp_wire)
							if(src.timing)
								explode()
						if(src.safety_wire == temp_wire)
							src.safety = !src.safety
							spawn(100) src.safety = !src.safety
							if(src.safety == 1)
								visible_message("\blue The [src] quiets down.")
								if(!src.lighthack)
									if (src.icon_state == "nuclearbomb2")
										src.icon_state = "nuclearbomb1"
							else
								visible_message("\blue The [src] emits a quiet whirling noise!")
			if(href_list["act"] == "wire")
				if (!istype(usr.get_active_hand(), /obj/item/weapon/wirecutters))
					usr << "You need wirecutters!"
				else
					wires[temp_wire] = !wires[temp_wire]
					if(src.safety_wire == temp_wire)
						if(src.timing)
							explode()
					if(src.timing_wire == temp_wire)
						if(!src.lighthack)
							if (src.icon_state == "nuclearbomb2")
								src.icon_state = "nuclearbomb1"
						src.timing = 0
						bomb_set = 0
					if(src.light_wire == temp_wire)
						src.lighthack = !src.lighthack

		if (href_list["auth"])
			if (src.auth)
				src.auth.loc = src.loc
				src.yes_code = 0
				src.auth = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/disk/nuclear))
					usr.drop_item()
					I.loc = src
					src.auth = I
		if (src.auth)
			if (href_list["type"])
				if (href_list["type"] == "E")
					if (src.code == src.r_code)
						src.yes_code = 1
						src.code = null
					else
						src.code = "ERROR"
				else
					if (href_list["type"] == "R")
						src.yes_code = 0
						src.code = null
					else
						lastentered = text("[]", href_list["type"])
						if (text2num(lastentered) == null)
							var/turf/LOC = get_turf(usr)
							message_admins("[key_name_admin(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: <a href='?_src_=vars;Vars=\ref[src]'>[lastentered]</a>! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
							log_admin("EXPLOIT: [key_name(usr)] tried to exploit a nuclear bomb by entering non-numerical codes: [lastentered]!")
						else
							src.code += lastentered
							if (length(src.code) > 5)
								src.code = "ERROR"
			if (src.yes_code)
				if (href_list["time"])
					var/time = text2num(href_list["time"])
					src.timeleft += time
					src.timeleft = min(max(round(src.timeleft), 60), 600)
				if (href_list["timer"])
					if (src.timing == -1.0)
						return
					if (src.safety)
						usr << "\red The safety is still on."
						nanomanager.update_uis(src)
						return
					src.timing = !( src.timing )
					if (src.timing)
						if(!src.lighthack)
							src.icon_state = "nuclearbomb2"
						if(!src.safety)
							bomb_set = 1//There can still be issues with this reseting when there are multiple bombs. Not a big deal tho for Nuke/N
						else
							bomb_set = 0
					else
						bomb_set = 0
						if(!src.lighthack)
							src.icon_state = "nuclearbomb1"
				if (href_list["safety"])
					src.safety = !( src.safety )
					if(safety)
						src.timing = 0
						bomb_set = 0
				if (href_list["anchor"])
					if(removal_stage == 5)
						src.anchored = 0
						visible_message("\red \The [src] makes a highly unpleasant crunching noise. It looks like the anchoring bolts have been cut.")
						return

					src.anchored = !( src.anchored )
					if(src.anchored)
						visible_message("\red With a steely snap, bolts slide out of [src] and anchor it to the flooring.")
					else
						visible_message("\red The anchoring bolts slide back into the depths of [src].")

		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				nanomanager.update_uis(src)
	else
		return
	return


/obj/machinery/nuclearbomb/ex_act(severity)
	return

/obj/machinery/nuclearbomb/blob_act()
	if (src.timing == -1.0)
		return
	else
		return ..()
	return


#define NUKERANGE 80
/obj/machinery/nuclearbomb/proc/explode()
	if (src.safety)
		src.timing = 0
		return
	src.timing = -1.0
	src.yes_code = 0
	src.safety = 1
	if(!src.lighthack)
		src.icon_state = "nuclearbomb3"
	playsound(src,'sound/machines/Alarm.ogg',100,0,5)
	if (ticker && ticker.mode)
		ticker.mode.explosion_in_progress = 1
	sleep(100)

	enter_allowed = 0

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	if( bomb_location && (bomb_location.z in config.station_levels) )
		if( (bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)) )
			off_station = 1
	else
		off_station = 2

	if(ticker)
		if(ticker.mode && ticker.mode.name == "nuclear emergency")
			var/obj/machinery/computer/shuttle_control/multi/syndicate/syndie_location = locate(/obj/machinery/computer/shuttle_control/multi/syndicate)
			if(syndie_location)
				ticker.mode:syndies_didnt_escape = (syndie_location.z > 1 ? 0 : 1)	//muskets will make me change this, but it will do for now
			ticker.mode:nuke_off_station = off_station
		ticker.station_explosion_cinematic(off_station,null)
		if(ticker.mode)
			ticker.mode.explosion_in_progress = 0
			if(ticker.mode.name == "nuclear emergency")
				ticker.mode:nukes_left --
			else if(off_station == 1)
				world << "<b>A nuclear device was set off, but the explosion was out of reach of the station!</b>"
			else if(off_station == 2)
				world << "<b>A nuclear device was set off, but the device was not on the station!</b>"
			else
				world << "<b>The station was destoyed by the nuclear blast!</b>"

			ticker.mode.station_was_nuked = (off_station<2)	//offstation==1 is a draw. the station becomes irradiated and needs to be evacuated.
															//kinda shit but I couldn't  get permission to do what I wanted to do.

			if(!ticker.mode.check_finished())//If the mode does not deal with the nuke going off so just reboot because everyone is stuck as is
				world << "<B>Resetting in 30 seconds!</B>"

				feedback_set_details("end_error","nuke - unhandled ending")

				if(blackbox)
					blackbox.save_all_data_to_sql()
				sleep(300)
				log_game("Rebooting due to nuclear detonation.")
				world.Reboot()
				return
	return


//==========DAT FUKKEN DISK===============
/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon = 'icons/obj/items.dmi'
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = 1.0

/obj/item/weapon/disk/nuclear/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/disk/nuclear/process()
	var/turf/disk_loc = get_turf(src)
	if(disk_loc.z != ZLEVEL_STATION && disk_loc.z != ZLEVEL_CENTCOMM)
		get(src, /mob) << "<span class='danger'>You can't help but feel that you just lost something back there...</span>"
		qdel(src)

/obj/item/weapon/disk/nuclear/Destroy()
	if(blobstart.len > 0)
		var/obj/item/weapon/disk/nuclear/NEWDISK = new(pick(blobstart))
		transfer_fingerprints_to(NEWDISK)
		var/turf/diskturf = get_turf(src)
		message_admins("[src] has been destroyed in ([diskturf.x], [diskturf.y] ,[diskturf.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[diskturf.x];Y=[diskturf.y];Z=[diskturf.z]'>JMP</a>). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[NEWDISK.x];Y=[NEWDISK.y];Z=[NEWDISK.z]'>JMP</a>).")
		log_game("[src] has been destroyed in ([diskturf.x], [diskturf.y] ,[diskturf.z]). Moving it to ([NEWDISK.x], [NEWDISK.y], [NEWDISK.z]).")
		return QDEL_HINT_HARDDEL_NOW
	else
		error("[src] was supposed to be destroyed, but we were unable to locate a blobstart landmark to spawn a new one.")
	return QDEL_HINT_LETMELIVE // Cancel destruction.
