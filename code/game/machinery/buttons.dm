
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
	settagwhitelist = list("id_tag", "logic_id_tag")
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	var/range = 7

	var/datum/radio_frequency/radio_connection
	var/frequency = 0
	var/logic_id_tag = "default"					//Defines the ID tag to send logic signals to, so you don't have to unlink from doors and stuff
	var/logic_connect = 0							//Set this to allow the button to send out logic signals when pressed in addition to normal stuff

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
	if(radio_controller)
		set_frequency(frequency)

/obj/machinery/driver_button/Initialize()
	..()
	set_frequency(frequency)

/obj/machinery/driver_button/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/driver_button/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	radio_connection = null
	return ..()


/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/driver_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/W, mob/user as mob, params)

	if(istype(W, /obj/item/detective_scanner))
		return

	if(istype(W, /obj/item/multitool))
		update_multitool_menu(user)
		return 1

	if(istype(W, /obj/item/wrench))
		playsound(get_turf(src), W.usesound, 50, 1)
		if(do_after(user, 30 * W.toolspeed, target = src))
			to_chat(user, "<span class='notice'>You detach \the [src] from the wall.</span>")
			new/obj/item/mounted/frame/driver_button(get_turf(src))
			qdel(src)
		return 1

	return attack_hand(user)

/obj/machinery/driver_button/multitool_menu(var/mob/user, var/obj/item/multitool/P)
	return {"
	<ul>
	<li><b>ID Tag:</b> [format_tag("ID Tag","id_tag")]</li>
	<li><b>Logic Connection:</b> <a href='?src=[UID()];toggle_logic=1'>[logic_connect ? "On" : "Off"]</a></li>
	<li><b>Logic ID Tag:</b> [format_tag("Logic ID Tag", "logic_id_tag")]</li>
	</ul>"}

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

	icon_state = "launcherbtt"
	active = 0

/obj/machinery/driver_button/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	..()
	if("toggle_logic" in href_list)
		logic_connect = !logic_connect

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

/obj/machinery/ignition_switch/attackby(obj/item/W, mob/user, params)
	return attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in world)
		if(M.id == id)
			spawn( 0 )
				M.spark()

	for(var/obj/machinery/igniter/M in world)
		if(M.id == id)
			use_power(50)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
