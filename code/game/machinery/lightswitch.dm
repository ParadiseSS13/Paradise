// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/on = 1
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1
	var/light_connect = 1							//Allows the switch to control lights in its associated areas. When set to 0, using the switch won't affect the lights.
	var/logic_id_tag = "default"					//Defines the ID tag to send logic signals to.
	var/logic_connect = 0							//Set this to allow the switch to send out logic signals.


/obj/machinery/light_switch/New(turf/loc, var/w_dir=null)
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
	spawn(5)
		src.area = get_area(src)

		if(otherarea)
			src.area = locate(text2path("/area/[otherarea]"))

		if(!name)
			name = "light switch([area.name])"

		src.on = src.area.lightswitch
		updateicon()

/obj/machinery/light_switch/Initialize()
	..()
	set_frequency(frequency)

/obj/machinery/light_switch/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_LOGIC)
	return

/obj/machinery/light_switch/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/light_switch/proc/updateicon()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "light-p"
		set_light(0)
	else
		if(on)
			icon_state = "light1"
		else
			icon_state = "light0"
		set_light(2, 0.3, on ? COLOR_APC_GREEN : COLOR_APC_RED)

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A light switch. It is [on? "on" : "off"].</span>"

/obj/machinery/light_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	on = !on
	updateicon()

	if(light_connect)
		area.lightswitch = on
		area.updateicon()

	if(logic_connect && powered(LIGHT))		//Don't bother sending a signal if we aren't set to send them or we have no power to send with.
		handle_output()

	if(light_connect)
		for(var/obj/machinery/light_switch/L in area)
			L.on = on
			L.updateicon()

		area.power_change()

/obj/machinery/light_switch/proc/handle_output()
	if(!radio_connection)		//can't output without this
		return

	if(logic_id_tag == null)	//Don't output to an undefined id_tag
		return

	var/datum/signal/signal = new
	signal.transmission_method = 1	//radio signal
	signal.source = src

	//Light switches are continuous signal sources, since they register as ON or OFF and stay that way until adjusted again
	if(on)
		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_ON,
		)
	else
		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_OFF,
		)

	radio_connection.post_signal(src, signal, filter = RADIO_LOGIC)
	if(on)
		use_power(5, LIGHT)			//Use a tiny bit of power every time we send an ON signal. Draws from the local APC's lighting circuit, since this is a LIGHT switch.

/obj/machinery/light_switch/power_change()
	if(!otherarea)
		if(powered(LIGHT))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER

		updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)

/obj/machinery/light_switch/process()
	if(logic_connect && powered(LIGHT))		//We won't send signals while unpowered, but the last signal will remain valid for anything that received it before we went dark
		handle_output()

/obj/machinery/light_switch/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

/obj/machinery/light_switch/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] starts unwrenching [src] from the wall...</span>", "<span class='notice'>You are unwrenching [src] from the wall...</span>", "<span class='warning'>You hear ratcheting.</span>")
	. = TRUE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/light_switch(get_turf(src))
	qdel(src)
