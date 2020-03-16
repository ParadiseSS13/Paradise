/obj/machinery/power/emitter
	name = "Emitter"
	desc = "A heavy duty industrial laser"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)

	use_power = NO_POWER_USE
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
	var/projectile_type = /obj/item/projectile/beam/emitter
	var/projectile_sound = 'sound/weapons/emitter.ogg'
	var/datum/radio_frequency/radio_connection
	var/datum/effect_system/spark_spread/sparks

/obj/machinery/power/emitter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/emitter(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	if(state == 2 && anchored)
		connect_to_network()
	sparks = new
	sparks.attach(src)
	sparks.set_up(5, 1, src)
	if(frequency)
		set_frequency(frequency)

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = 350
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_usage = power_usage

	//Radio remote control
/obj/machinery/power/emitter/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)


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

/obj/machinery/power/emitter/multitool_menu(var/mob/user,var/obj/item/multitool/P)
	return {"
	<ul>
		<li><b>Frequency:</b> <a href="?src=[UID()];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=[UID()];set_freq=[ENGINE_FREQ]">Reset</a>)</li>
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
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	msg_admin_attack("Emitter deleted at ([x],[y],[z] - [ADMIN_JMP(src)])", ATKLOG_FEW)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	QDEL_NULL(sparks)
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
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
	else
		to_chat(user, "<span class='warning'>The [src] needs to be firmly secured to the floor first.</span>")
		return 1


/obj/machinery/power/emitter/emp_act(var/severity)//Emitters are hardened but still might have issues
//	add_load(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = IDLE_POWER_USE	*/
	return 1

/obj/machinery/power/emitter/attack_animal(mob/living/simple_animal/M)
	if(ismegafauna(M) && anchored)
		state = 0
		anchored = FALSE
		M.visible_message("<span class='warning'>[M] rips [src] free from its moorings!</span>")
	else
		..()
	if(!anchored)
		step(src, get_dir(M, src))

/obj/machinery/power/emitter/process()
	if(stat & (BROKEN))
		return
	if(src.state != 2 || (!powernet && active_power_usage))
		src.active = 0
		update_icon()
		return
	if(active == TRUE)
		if(!active_power_usage || surplus() >= active_power_usage)
			add_load(active_power_usage)
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

		if(!check_delay())
			return FALSE
		fire_beam()

/obj/machinery/power/emitter/proc/check_delay()
	if((last_shot + fire_delay) <= world.time)
		return TRUE
	return FALSE

/obj/machinery/power/emitter/proc/fire_beam()
	var/obj/item/projectile/P = new projectile_type(get_turf(src))
	playsound(get_turf(src), projectile_sound, 50, TRUE)
	if(prob(35))
		sparks.start()
	switch(dir)
		if(NORTH)
			P.yo = 20
			P.xo = 0
		if(NORTHEAST)
			P.yo = 20
			P.xo = 20
		if(EAST)
			P.yo = 0
			P.xo = 20
		if(SOUTHEAST)
			P.yo = -20
			P.xo = 20
		if(WEST)
			P.yo = 0
			P.xo = -20
		if(SOUTHWEST)
			P.yo = -20
			P.xo = -20
		if(NORTHWEST)
			P.yo = 20
			P.xo = -20
		else // Any other
			P.yo = -20
			P.xo = 0

	last_shot = world.time
	if(shot_number < 3)
		fire_delay = 20
		shot_number ++
	else
		fire_delay = rand(minimum_fire_delay, maximum_fire_delay)
		shot_number = 0
	P.setDir(dir)
	P.starting = loc
	P.Angle = null
	P.fire()
	return P

/obj/machinery/power/emitter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1

	if(istype(W, /obj/item/wrench))
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(src.loc, W.usesound, 75, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc,W.usesound, 75, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				to_chat(user, "<span class='warning'>The [src.name] needs to be unwelded from the floor.</span>")
		return

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock seems to be broken</span>")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when the [src] is online</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	if(default_deconstruction_screwdriver(user, "emitter_open", "emitter", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_deconstruction_crowbar(user, W))
		return

	return ..()

/obj/machinery/power/emitter/emag_act(var/mob/living/user as mob)
	if(!emagged)
		locked = 0
		emagged = 1
		if(user)
			user.visible_message("[user.name] emags the [src.name].","<span class='warning'>You short out the lock.</span>")


/obj/machinery/power/emitter/welder_act(mob/user, obj/item/I)
	if(active)
		to_chat(user, "<span class='notice'>Turn off [src] first.</span>")
		return
	if(state == 0)
		to_chat(user, "<span class='warning'>[src] needs to be wrenched to the floor.</span>")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(state == 1)
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
	else if(state == 2)
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	if(state == 1)
		WELDER_FLOOR_WELD_SUCCESS_MESSAGE
		connect_to_network()
		state = 2
	else if(state == 2)
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		disconnect_from_network()
		state = 1
