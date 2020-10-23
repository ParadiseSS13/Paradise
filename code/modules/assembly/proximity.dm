/obj/item/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	origin_tech = "magnets=1;engineering=1"

	secured = 0

	bomb_name = "proximity mine"

	var/scanning = 0
	var/timing = 0
	var/time = 10

/obj/item/assembly/prox_sensor/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/proximity_monitor)

/obj/item/assembly/prox_sensor/describe()
	if(timing)
		return "<span class='notice'>The proximity sensor is arming.</span>"
	return "The proximity sensor is [scanning ? "armed" : "disarmed"]."

/obj/item/assembly/prox_sensor/activate()
	if(!..())
		return FALSE //Cooldown check
	timing = !timing
	update_icon()
	return FALSE

/obj/item/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		scanning = 0
		timing = 0
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/assembly/prox_sensor/HasProximity(atom/movable/AM)
	if(!isobj(AM) && !isliving(AM))
		return
	if(istype(AM, /obj/effect))
		return
	if(AM.move_speed < 12)
		sense()

/obj/item/assembly/prox_sensor/proc/sense()
	if(!secured || !scanning || cooldown > 0)
		return FALSE
	cooldown = 2
	pulse(FALSE)
	visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	addtimer(CALLBACK(src, .proc/process_cooldown), 10)

/obj/item/assembly/prox_sensor/process()
	if(timing && (time >= 0))
		time--
	if(timing && time <= 0)
		timing = 0
		toggle_scan()
		time = 10

/obj/item/assembly/prox_sensor/dropped()
	..()
	spawn(0)
		sense()
		return

/obj/item/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	update_icon()

/obj/item/assembly/prox_sensor/update_icon()
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

/obj/item/assembly/prox_sensor/Move()
	..()
	sense()

/obj/item/assembly/prox_sensor/holder_movement()
	sense()

/obj/item/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message("<span class='warning'>The [name] is unsecured!</span>")
		return FALSE
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = text({"<meta charset="UTF-8"><TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=[UID()];tp=-30'>-</A> <A href='?src=[UID()];tp=-1'>-</A> <A href='?src=[UID()];tp=1'>+</A> <A href='?src=[UID()];tp=30'>+</A>\n</TT>"}, (timing ? "<A href='?src=[UID()];time=0'>Arming</A>" : "<A href='?src=[UID()];time=1'>Not Arming</A>"), minute, second)
	dat += "<BR><A href='?src=[UID()];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
	dat += "<BR><BR><A href='?src=[UID()];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=[UID()];close=1'>Close</A>"
	var/datum/browser/popup = new(user, "prox", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "prox")

/obj/item/assembly/prox_sensor/Topic(href, href_list)
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
