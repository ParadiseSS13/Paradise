/obj/machinery/ai_slipper
	name = "\improper AI liquid dispenser"
	icon = 'icons/obj/device.dmi'
	icon_state = "motion3"
	layer = 3
	anchored = 1.0
	var/uses = 20
	var/disabled = TRUE
	var/lethal = 0
	var/locked = TRUE
	var/cooldown_time = 0
	var/cooldown_timeleft = 0
	var/cooldown_on = FALSE
	req_access = list(access_ai_upload)

/obj/machinery/ai_slipper/power_change()
	if(stat & BROKEN)
		return
	else
		if( powered() )
			stat &= ~NOPOWER
		else
			icon_state = "motion0"
			stat |= NOPOWER
			disabled = TRUE

/obj/machinery/ai_slipper/proc/setState(var/enabled, var/uses)
	disabled = disabled
	uses = uses
	power_change()

/obj/machinery/ai_slipper/attackby(obj/item/weapon/W, mob/user, params)
	if(stat & (NOPOWER|BROKEN))
		return
	if(istype(user, /mob/living/silicon))
		return attack_hand(user)
	else // trying to unlock the interface
		if(allowed(usr))
			locked = !locked
			to_chat(user, "You [locked ? "lock" : "unlock"] the device.")
			if(locked)
				if(user.machine == src)
					user.unset_machine()
					user << browse(null, "window=ai_slipper")
			else
				if(user.machine == src)
					attack_hand(usr)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return
	return

/obj/machinery/ai_slipper/proc/ToggleOn()
	if(stat & (NOPOWER|BROKEN))
		return
	disabled = !disabled
	icon_state = disabled? "motion0":"motion3"

/obj/machinery/ai_slipper/proc/Activate()
	if(stat & (NOPOWER|BROKEN))
		return
	if(cooldown_on || disabled)
		return
	else
		new /obj/structure/foam(loc)
		uses--
		cooldown_on = TRUE
		cooldown_time = world.timeofday + 100
		slip_process()

/obj/machinery/ai_slipper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/ai_slipper/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/ai_slipper/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(get_dist(src, user) > 1 && (!issilicon(user) && !user.can_admin_interact()))
		to_chat(user, "<span class='warning'>Too far away.</span>")
		user.unset_machine()
		user << browse(null, "window=ai_slipper")
		return

	user.set_machine(src)
	var/area/myarea = get_area(src)
	var/t = "<TT><B>AI Liquid Dispenser</B> ([myarea.name])<HR>"

	if(locked && (!issilicon(user) && !user.can_admin_interact()))
		t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
	else
		t += text("Dispenser [] - <A href='?src=[UID()];toggleOn=1'>[]?</a><br>\n", disabled ? "deactivated" : "activated", disabled ? "Enable" : "Disable")
		t += text("Uses Left: [uses]. <A href='?src=[UID()];toggleUse=1'>Activate the dispenser?</A><br>\n")

	user << browse(t, "window=computer;size=575x450")
	onclose(user, "computer")

/obj/machinery/ai_slipper/Topic(href, href_list)
	if(..())
		return 1

	if(locked && (!issilicon(usr) && !usr.can_admin_interact()))
		to_chat(usr, "Control panel is locked!")
		return 1

	if(href_list["toggleOn"])
		ToggleOn()

	if(href_list["toggleUse"])
		Activate()

	attack_hand(usr)

/obj/machinery/ai_slipper/proc/slip_process()
	while(cooldown_time - world.timeofday > 0)
		var/ticksleft = cooldown_time - world.timeofday

		if(ticksleft > 1e5)
			cooldown_time = world.timeofday + 10	// midnight rollover


		cooldown_timeleft = (ticksleft / 10)
		sleep(5)
	if(uses <= 0)
		return
	if(uses >= 0)
		cooldown_on = FALSE
	power_change()