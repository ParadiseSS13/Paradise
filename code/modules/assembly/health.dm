/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	origin_tech = "magnets=1;biotech=1"
	secured = FALSE

	var/scanning = FALSE
	var/health_scan
	var/alarm_health = 0



/obj/item/assembly/health/activate()
	if(!..())
		return FALSE//Cooldown check
	toggle_scan()
	return FALSE

/obj/item/assembly/health/toggle_secure()
	secured = !secured
	if(secured && scanning)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/assembly/health/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(alarm_health == 0)
		alarm_health = -90
		user.show_message("You toggle [src] to \"detect death\" mode.")
	else
		alarm_health = 0
		user.show_message("You toggle [src] to \"detect critical state\" mode.")

/obj/item/assembly/health/process()
	if(!scanning || !secured)
		return

	var/atom/A = src
	if(connected && connected.holder)
		A = connected.holder

	for(A, A && !ismob(A), A=A.loc);
	// like get_turf(), but for mobs.
	var/mob/living/M = A

	if(M)
		health_scan = M.health
		if(health_scan <= alarm_health)
			pulse(FALSE, M)
			audible_message("[bicon(src)] *beep* *beep*")
			toggle_scan()
		return
	return

/obj/item/assembly/health/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	return

/obj/item/assembly/health/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message("<span class='warning'>The [name] is unsecured!</span>")
		return FALSE
	var/dat = text({"<meta charset="UTF-8"><TT><B>Health Sensor</B> <A href='?src=[UID()];scanning=1'>[scanning?"On":"Off"]</A>"})
	if(scanning && health_scan)
		dat += "<BR>Health: [health_scan]"
	var/datum/browser/popup = new(user, "hscan", name, 400, 400, src)
	popup.set_content(dat)
	popup.open()
	return


/obj/item/assembly/health/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	var/mob/user = usr

	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=hscan")
		onclose(usr, "hscan")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["close"])
		usr << browse(null, "window=hscan")
		return

	attack_self(user)
	return
