
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
	use_power = 1
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

/obj/machinery/driver_button/initialize()
	..()
	set_frequency(frequency)

/obj/machinery/driver_button/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/driver_button/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src,frequency)
	return ..()


/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user as mob, params)

	if(istype(W, /obj/item/device/detective_scanner))
		return

	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1

	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You detach \the [src] from the wall.</span>")
			new/obj/item/mounted/frame/driver_button(get_turf(src))
			qdel(src)
		return 1

	return src.attack_hand(user)

/obj/machinery/driver_button/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
	<li><b>ID Tag:</b> [format_tag("ID Tag","id_tag")]</li>
	<li><b>Logic Connection:</b> <a href='?src=[UID()];toggle_logic=1'>[logic_connect ? "On" : "Off"]</a></li>
	<li><b>Logic ID Tag:</b> [format_tag("Logic ID Tag", "logic_id_tag")]</li>
	</ul>"}

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)

	launch_sequence()

	return

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
		if(M.id_tag == src.id_tag && !M.protected)
			spawn()
				M.open()

	sleep(20)

	for(var/obj/machinery/mass_driver/M in range(src,range))
		if(M.id_tag == src.id_tag)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in range(src,range))
		if(M.id_tag == src.id_tag && !M.protected)
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
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/ignition_switch/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attackby(obj/item/weapon/W, mob/user as mob, params)
	return src.attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in world)
		if(M.id == src.id)
			spawn( 0 )
				M.spark()

	for(var/obj/machinery/igniter/M in world)
		if(M.id == src.id)
			use_power(50)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return

//////////////////////////////////////
//			Flasher Button			//
//////////////////////////////////////

/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

//////////////////////////////////////
//		Crematorium Switch			//
//////////////////////////////////////

/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(access_crematorium)
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1