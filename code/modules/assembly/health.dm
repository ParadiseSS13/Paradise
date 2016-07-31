/obj/item/device/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	secured = 0

	var/scanning = 0
	var/health_scan
	var/alarm_health = 0



/obj/item/device/assembly/health/activate()
	if(!..())	return 0//Cooldown check
	toggle_scan()
	return 0

/obj/item/device/assembly/health/toggle_secure()
	secured = !secured
	if(secured && scanning)
		processing_objects.Add(src)
	else
		scanning = 0
		processing_objects.Remove(src)
	update_icon()
	return secured

/obj/item/device/assembly/health/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/multitool))
		if(alarm_health == 0)
			alarm_health = -90
			user.show_message("You toggle [src] to \"detect death\" mode.")
		else
			alarm_health = 0
			user.show_message("You toggle [src] to \"detect critical state\" mode.")
		return
	else
		return ..()

/obj/item/device/assembly/health/process()
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
			pulse()
			audible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
			toggle_scan()
		return
	return

/obj/item/device/assembly/health/proc/toggle_scan()
	if(!secured)	return 0
	scanning = !scanning
	if(scanning)
		processing_objects.Add(src)
	else
		processing_objects.Remove(src)
	return

/obj/item/device/assembly/health/interact(mob/user as mob)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message("<span class='warning'>The [name] is unsecured!</span>")
		return 0
	var/dat = text("<TT><B>Health Sensor</B> <A href='?src=\ref[src];scanning=1'>[scanning?"On":"Off"]</A>")
	if(scanning && health_scan)
		dat += "<BR>Health: [health_scan]"
	var/datum/browser/popup = new(user, "hscan", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "hscan")
	return


/obj/item/device/assembly/health/Topic(href, href_list)
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