//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/power/emitter
	name = "Emitter"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)

	use_power = 0
	idle_power_usage = 10
	active_power_usage = 300

	var/active = 0
	var/powered = 0
	var/fire_delay = 100
	var/maximum_fire_delay = 100
	var/minimum_fire_delay = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = 0

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/power/emitter/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/emitter(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = 350
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_usage = power_usage

	//Radio remote control
/obj/machinery/power/emitter/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)


/obj/machinery/power/emitter/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/power/emitter/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	rotate()

/obj/machinery/power/emitter/initialize()
	..()
	if(state == 2 && anchored)
		connect_to_network()
	if(frequency)
		set_frequency(frequency)
/obj/machinery/power/emitter/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[1439]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag","set_id")]</a></li>
	</ul>
	"}

/obj/machinery/power/emitter/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/on=0
	switch(signal.data["command"])
		if("on")
			on=1

		if("off")
			on=0

		if("set")
			on = signal.data["state"] > 0

		if("toggle")
			on = !active

	if(anchored && state == 2 && on != active)
		active=on
		var/statestr=on?"on":"off"
		// Spammy message_admins("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in [formatJumpTo(src)]",0,1)
		log_game("Emitter turned [statestr] by radio signal ([signal.data["command"]] @ [frequency]) in ([x], [y], [z]) AAC prints: [jointext(signal.data["hiddenprints"], "")]")
		investigate_log("turned <font color='orange'>[statestr]</font> by radio signal ([signal.data["command"]] @ [frequency]) AAC prints: [jointext(signal.data["hiddenprints"], "")]","singulo")
		update_icon()

/obj/machinery/power/emitter/Destroy()
	msg_admin_attack("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	return ..()

/obj/machinery/power/emitter/update_icon()
	if(active && powernet && avail(active_power_usage))
		icon_state = "emitter_+a"
	else
		icon_state = "emitter"


/obj/machinery/power/emitter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if(state == 2)
		if(!powernet)
			to_chat(user, "The emitter isn't connected to a wire.")
			return 1
		if(!src.locked)
			if(src.active==1)
				src.active = 0
				to_chat(user, "You turn off the [src].")
				message_admins("Emitter turned off by [key_name_admin(user)] in ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned off by [key_name(user)] in [x], [y], [z]")
				investigate_log("turned <font color='red'>off</font> by [key_name(usr)]","singulo")
			else
				src.active = 1
				to_chat(user, "You turn on the [src].")
				src.shot_number = 0
				src.fire_delay = maximum_fire_delay
				message_admins("Emitter turned on by [key_name_admin(user)] in ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned on by [key_name(user)] in [x], [y], [z]")
				investigate_log("turned <font color='green'>on</font> by [key_name(usr)]","singulo")
			update_icon()
		else
			to_chat(user, "\red The controls are locked!")
	else
		to_chat(user, "\red The [src] needs to be firmly secured to the floor first.")
		return 1


/obj/machinery/power/emitter/emp_act(var/severity)//Emitters are hardened but still might have issues
//	add_load(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1	*/
	return 1


/obj/machinery/power/emitter/process()
	if(stat & (BROKEN))
		return
	if(src.state != 2 || (!powernet && active_power_usage))
		src.active = 0
		update_icon()
		return
	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))

		var/actual_load = draw_power(active_power_usage)
		if(actual_load >= active_power_usage) //does the laser have enough power to shoot?
			if(!powered)
				powered = 1
				update_icon()
				investigate_log("regained power and turned <font color='green'>on</font>","singulo")
		else
			if(powered)
				powered = 0
				update_icon()
				investigate_log("lost power and turned <font color='red'>off</font>","singulo")
			return

		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number++
		else
			src.fire_delay = rand(minimum_fire_delay,maximum_fire_delay)
			src.shot_number = 0

		var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter(src.loc)

		A.dir = src.dir
		playsound(get_turf(src), 'sound/weapons/emitter.ogg', 25, 1)
		if(prob(35))
			var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()

		switch(dir)
			if(NORTH)
				A.yo = 20
				A.xo = 0
			if(EAST)
				A.yo = 0
				A.xo = 20
			if(WEST)
				A.yo = 0
				A.xo = -20
			else // Any other
				A.yo = -20
				A.xo = 0
		A.fire()	//TODO: Carn: check this out


/obj/machinery/power/emitter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1

	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				to_chat(user, "\red The [src.name] needs to be unwelded from the floor.")
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				to_chat(user, "\red The [src.name] needs to be wrenched to the floor.")
			if(1)
				if(WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"You start to weld the [src] to the floor.", \
						"You hear welding")
					if(do_after(user,20, target = src))
						if(!src || !WT.isOn()) return
						state = 2
						to_chat(user, "You weld the [src] to the floor.")
						connect_to_network()
				else
					to_chat(user, "\red You need more welding fuel to complete this task.")
			if(2)
				if(WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"You start to cut the [src] free from the floor.", \
						"You hear welding")
					if(do_after(user,20, target = src))
						if(!src || !WT.isOn()) return
						state = 1
						to_chat(user, "You cut the [src] free from the floor.")
						disconnect_from_network()
				else
					to_chat(user, "\red You need more welding fuel to complete this task.")
		return

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "\red The lock seems to be broken")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "\red The controls can only be locked when the [src] is online")
		else
			to_chat(user, "\red Access denied.")
		return

	if(default_deconstruction_screwdriver(user, "emitter_open", "emitter", W))
		return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

	..()
	return

/obj/machinery/power/emitter/emag_act(var/mob/living/user as mob)
	if(!emagged)
		locked = 0
		emagged = 1
		if(user)
			user.visible_message("[user.name] emags the [src.name].","\red You short out the lock.")
