/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	origin_tech = "magnets=1"

	secured = 0

	bomb_name = "proximity mine"

	var/scanning = 0
	var/timing = 0
	var/time = 10

	proc
		toggle_scan()
		sense()

	describe()
		if(timing)
			return "\blue The proximity sensor is arming."
		return "The proximity sensor is [scanning?"armed":"disarmed"]."

	activate()
		if(!..())	return 0//Cooldown check
		timing = !timing
		update_icon()
		return 0


	toggle_secure()
		secured = !secured
		if(secured)
			processing_objects.Add(src)
		else
			scanning = 0
			timing = 0
			processing_objects.Remove(src)
		update_icon()
		return secured


	HasProximity(atom/movable/AM as mob|obj)
		if(!isobj(AM) && !isliving(AM))
			return
		if(istype(AM, /obj/effect))	return
		if(AM.move_speed < 12)	sense()
		return


	sense()
		if((!secured)||(!scanning)||(cooldown > 0))	return 0
		pulse(0)
		visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	process()
		if(timing && (time >= 0))
			time--
		if(timing && time <= 0)
			timing = 0
			toggle_scan()
			time = 10
		return


	dropped()
		..()
		spawn(0)
			sense()
			return
		return


	toggle_scan()
		if(!secured)	return 0
		scanning = !scanning
		update_icon()
		return


	update_icon()
		overlays.Cut()
		attached_overlays = list()
		if(timing)
			overlays += "prox_timing"
			attached_overlays += "prox_timing"
		if(scanning)
			overlays += "prox_scanning"
			attached_overlays += "prox_scanning"
		if(holder)
			holder.update_icon()
		return


	Move()
		..()
		sense()
		return

	holder_movement()
		sense()


	interact(mob/user as mob)//TODO: Change this to the wires thingy
		if(!secured)
			user.show_message("\red The [name] is unsecured!")
			return 0
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=[UID()];tp=-30'>-</A> <A href='?src=[UID()];tp=-1'>-</A> <A href='?src=[UID()];tp=1'>+</A> <A href='?src=[UID()];tp=30'>+</A>\n</TT>", (timing ? "<A href='?src=[UID()];time=0'>Arming</A>" : "<A href='?src=[UID()];time=1'>Not Arming</A>"), minute, second)
		dat += "<BR><A href='?src=[UID()];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR><BR><A href='?src=[UID()];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=[UID()];close=1'>Close</A>"
		var/datum/browser/popup = new(user, "prox", name, 400, 400)
		popup.set_content(dat)
		popup.open(0)
		onclose(user, "prox")
		return


	Topic(href, href_list)
		..()
		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=prox")
			onclose(usr, "prox")
			return

		if(href_list["scanning"])
			toggle_scan()

		if(href_list["time"])
			timing = text2num(href_list["time"])
			update_icon()

		if(href_list["tp"])
			var/tp = text2num(href_list["tp"])
			time += tp
			time = min(max(round(time), 0), 600)

		if(href_list["close"])
			usr << browse(null, "window=prox")
			return

		if(usr)
			attack_self(usr)


		return
