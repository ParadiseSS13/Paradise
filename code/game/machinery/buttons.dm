
//////////////////////////////////////
//			Driver Button			//
//////////////////////////////////////

/obj/machinery/driver_button
	name = "mass driver button"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mass driver."
	var/id_tag = "default"
	var/active = 0
	anchored = 1.0
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 90, acid = 70)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	var/range = 7
	var/logic_id_tag = "default"					//Defines the ID tag to send logic signals to, so you don't have to unlink from doors and stuff
	var/logic_connect = 0							//Set this to allow the button to send out logic signals when pressed in addition to normal stuff

/obj/machinery/button/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/driver_button/New(turf/loc, var/w_dir=null)
	..()
	switch(w_dir)
		if(NORTH)
			pixel_y = 25
		if(SOUTH)
			pixel_y = -25
		if(EAST)
			pixel_x = 25
		if(WEST)
			pixel_x = -25
	if(SSradio)
		set_frequency(frequency)

/obj/machinery/driver_button/Initialize()
	..()
	set_frequency(frequency)

/obj/machinery/driver_button/init_multitool_menu()
	multitool_menu = new /datum/multitool_menu/idtag/driver_button(src)

/obj/machinery/driver_button/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/driver_button/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()


/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/driver_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/driver_button/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu.interact(user, I)

/obj/machinery/driver_button/wrench_act(mob/user, obj/item/I)
	. = TRUE
	playsound(get_turf(src), I.usesound, 50, 1)
	if(do_after(user, 30 * I.toolspeed * gettoolspeedmod(user), target = src))
		to_chat(user, "<span class='notice'>You detach [src] from the wall.</span>")
		new/obj/item/mounted/frame/driver_button(get_turf(src))
		qdel(src)

/obj/machinery/driver_button/attackby(obj/item/W, mob/user as mob, params)

	if(istype(W, /obj/item/detective_scanner))
		return

	return ..()

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)

	launch_sequence()

/obj/machinery/driver_button/proc/launch_sequence()
	active = 1
	icon_state = "launcheract"

	if(logic_connect)
		if(!radio_connection)		//can't output without this
			return

		if(logic_id_tag == null)	//Don't output to an undefined id_tag
			return

		var/datum/signal/signal = new
		signal.transmission_method = 1	//radio signal
		signal.source = src

		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_FLICKER,	//Buttons are a FLICKER source, since they only register as ON when you press it, then turn OFF after you release
		)

		radio_connection.post_signal(src, signal, filter = RADIO_LOGIC)

	if(!id_tag)
		// play animation, but do nothing if id_tag is null
		addtimer(CALLBACK(src, .proc/rearm), 7 SECONDS)
		return

	for(var/obj/machinery/door/poddoor/M in range(src,range))
		if(M.id_tag == id_tag && !M.protected)
			spawn()
				M.open()

	sleep(20)

	for(var/obj/machinery/mass_driver/M in range(src,range))
		if(M.id_tag == id_tag)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in range(src,range))
		if(M.id_tag == id_tag && !M.protected)
			spawn()
				M.close()
				return

	rearm()

/obj/machinery/driver_button/proc/rearm()
	icon_state = "launcherbtt"
	active = FALSE

//////////////////////////////////////
//			Ignition Switch			//
//////////////////////////////////////

/obj/machinery/ignition_switch
	name = "ignition switch"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	desc = "A remote control switch for a mounted igniter."
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/ignition_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in GLOB.machines)
		if(M.id == id)
			spawn( 0 )
				M.spark()

	for(var/obj/machinery/igniter/M in GLOB.machines)
		if(M.id == id)
			use_power(50)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
