/obj/item/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)

	secured = FALSE

	bomb_name = "proximity mine"

	var/scanning = FALSE
	var/timing = FALSE
	COOLDOWN_DECLARE(timing_cd)
	var/timing_cd_duration = 10 SECONDS
	/// Proximity monitor associated with this atom, needed for it to work.
	var/datum/proximity_monitor/proximity_monitor

/obj/item/assembly/prox_sensor/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 0, FALSE)
	COOLDOWN_RESET(src, timing_cd)

/obj/item/assembly/prox_sensor/Destroy()
	. = ..()
	QDEL_NULL(proximity_monitor)

/obj/item/assembly/prox_sensor/examine(mob/user)
	. = ..()
	if(timing)
		. += "<span class='notice'>The proximity sensor is arming.</span>"
	else
		. += "The proximity sensor is [scanning ? "armed" : "disarmed"]."

/obj/item/assembly/prox_sensor/activate()
	if(!..())
		return FALSE //Cooldown check
	timing = !timing
	update_icon()
	return FALSE

/obj/item/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSfastprocess, src)
	else
		scanning = FALSE
		timing = FALSE
		STOP_PROCESSING(SSfastprocess, src)
	update_icon()
	return secured

/obj/item/assembly/prox_sensor/HasProximity(atom/movable/AM)
	if(!isobj(AM) && !isliving(AM))
		return
	if(iseffect(AM))
		return
	if(AM.move_speed < 12)
		sense()

/obj/item/assembly/prox_sensor/proc/sense()
	if(!secured || !scanning || cooldown > 0)
		return FALSE
	cooldown = 2
	pulse(FALSE)
	visible_message("[bicon(src)] *beep* *beep* *beep*", "*beep* *beep* *beep*")
	playsound(src, 'sound/machines/triple_beep.ogg', 40, extrarange = -10)
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 10)

/obj/item/assembly/prox_sensor/process()
	if(timing && COOLDOWN_FINISHED(src, timing_cd))
		COOLDOWN_RESET(src, timing_cd)
		timing = FALSE
		toggle_scan()

/obj/item/assembly/prox_sensor/dropped()
	. = ..()
	// Pick the first valid object in this list:
	// Wiring datum's owner
	// assembly holder's attached object
	// assembly holder itself
	// us
	proximity_monitor?.set_host(connected?.holder || holder?.master || holder || src, src)

/obj/item/assembly/prox_sensor/on_attach()
	. = ..()
	// Pick the first valid object in this list:
	// Wiring datum's owner
	// assembly holder's attached object
	// assembly holder itself
	// us
	proximity_monitor.set_host(connected?.holder || holder?.master || holder || src, src)

/obj/item/assembly/prox_sensor/on_detach()
	. = ..()
	if(!.)
		return
	else
		// Pick the first valid object in this list:
		// Wiring datum's owner
		// assembly holder's attached object
		// assembly holder itself
		// us
		proximity_monitor.set_host(connected?.holder || holder?.master || holder || src, src)

/obj/item/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	proximity_monitor.set_range(scanning ? 1 : 0)
	update_icon()

/obj/item/assembly/prox_sensor/proc/set_timing(timing_)
	if(timing == timing_)
		return
	timing = timing_
	if(timing)
		COOLDOWN_START(src, timing_cd, timing_cd_duration)

/obj/item/assembly/prox_sensor/update_overlays()
	. = ..()
	attached_overlays = list()
	if(timing)
		. += "prox_timing"
		attached_overlays += "prox_timing"
	if(scanning)
		. += "prox_scanning"
		attached_overlays += "prox_scanning"
	if(holder)
		holder.update_icon()

/obj/item/assembly/prox_sensor/Move()
	. = ..()
	sense()

/obj/item/assembly/prox_sensor/holder_movement()
	sense()

/obj/item/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message("<span class='warning'>[src] is unsecured!</span>")
		return FALSE
	var/timing_ui = ""
	var/time_display = ""
	if(timing)
		var/time_left = COOLDOWN_TIMELEFT(src, timing_cd)
		time_display = deciseconds_to_time_stamp(time_left)
		timing_ui = "<a href='byond://?src=[UID()];time=0'>Arming</a>"
	else
		var/time_left = timing_cd_duration
		time_display = deciseconds_to_time_stamp(time_left)
		timing_ui = "<a href='byond://?src=[UID()];time=1'>Not Arming</a>"
	var/dat = "<tt><b>Proximity Sensor</b>\n[timing_ui] [time_display]\n<a href='byond://?src=[UID()];tp=-300'>-</a> <a href='byond://?src=[UID()];tp=-10'>-</a> <a href='byond://?src=[UID()];tp=10'>+</a> <a href='byond://?src=[UID()];tp=300'>+</a>\n</tt>"
	dat += "<br><a href='byond://?src=[UID()];scanning=1'>[scanning?"Armed":"Unarmed"]</a> (Movement sensor active when armed!)"
	dat += "<br><br><a href='byond://?src=[UID()];refresh=1'>Refresh</a>"
	dat += "<br><br><a href='byond://?src=[UID()];close=1'>Close</a>"
	var/datum/browser/popup = new(user, "prox", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "prox")

/obj/item/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=prox")
		onclose(usr, "prox")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["time"])
		set_timing(text2num(href_list["time"]))
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		timing_cd_duration += tp
		timing_cd_duration = min(max(round(timing_cd_duration), 0), 1 MINUTES)

	if(href_list["close"])
		usr << browse(null, "window=prox")
		return

	if(usr)
		attack_self__legacy__attackchain(usr)
