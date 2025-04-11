// the light switch
// can have multiple per area
/obj/machinery/light_switch
	name = "light switch"
	desc = "A switch for turning the lights on and off for an entire room."
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = TRUE
	power_channel = PW_CHANNEL_LIGHTING

/obj/machinery/light_switch/Initialize(mapload, build_dir)
	. = ..()
	name = "light switch" // Needed to remove the "(dir) bump" naming
	switch(build_dir)
		if(NORTH)
			pixel_y = 25
			dir = NORTH
		if(SOUTH)
			pixel_y = -25
			dir = SOUTH
		if(EAST)
			pixel_x = 25
			dir = EAST
		if(WEST)
			pixel_x = -25
			dir = WEST

	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	var/area/A = get_area(src)
	// Yes, we're listening to the area to update its signal.
	RegisterSignal(A, COMSIG_ATOM_UPDATED_ICON, PROC_REF(signal_lightswitch_icon_update))
	RegisterSignal(A, COMSIG_AREA_LIGHTSWITCH_DELETING, PROC_REF(lightswitch_cancel_autoswitch))

/obj/machinery/light_switch/Destroy()
	var/area/A = get_area(src)
	UnregisterSignal(A, COMSIG_AREA_LIGHTSWITCH_DELETING) // make sure src isnt included, if we're the last light switch to go the lights will turn back on
	if(SEND_SIGNAL(A, COMSIG_AREA_LIGHTSWITCH_DELETING) & COMSIG_AREA_LIGHTSWITCH_CANCEL)
		return ..()

	// Toggle the lights on if there are no other light switches
	set_area_lightswitch(TRUE)
	return ..()

/obj/machinery/light_switch/proc/signal_lightswitch_icon_update()
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/machinery/light_switch/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "light-p"
		return
	var/area/our_area = get_area(src)
	icon_state = "light[our_area.lightswitch]"

/obj/machinery/light_switch/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return
	var/area/our_area = get_area(src)
	. += "light[our_area.lightswitch]"
	underlays += emissive_appearance(icon, "light_lightmask")

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	var/area/our_area = get_area(src)
	. += "<span class='notice'>It is [our_area.lightswitch ? "on" : "off"].</span>"

/obj/machinery/light_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	var/area/A = get_area(src)
	set_area_lightswitch(!A.lightswitch)
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)

/obj/machinery/light_switch/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, 0.5)

	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	power_change()
	..(severity)

/obj/machinery/light_switch/wrench_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.tool_use_check(user, 0))
		return

	user.visible_message("<span class='notice'>[user] starts unwrenching [src] from the wall...</span>", "<span class='notice'>You are unwrenching [src] from the wall...</span>", "<span class='warning'>You hear ratcheting.</span>")
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return

	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/light_switch(get_turf(src))
	qdel(src)

/obj/machinery/light_switch/proc/set_area_lightswitch(new_state)
	var/area/A = get_area(src)
	if(A.lightswitch == new_state)
		return
	A.lightswitch = new_state
	// Sends an area signal to all lightswitches in our area to update their icons and overlays
	A.update_icon(UPDATE_ICON_STATE)

	// Update all the lights in our area
	machine_powernet.power_change()

/obj/machinery/light_switch/proc/lightswitch_cancel_autoswitch()
	SIGNAL_HANDLER // COMSIG_AREA_LIGHTSWITCH_DELETING
	return COMSIG_AREA_LIGHTSWITCH_CANCEL

/obj/machinery/light_switch/off/Initialize(mapload, build_dir)
	. = ..()
	set_area_lightswitch(FALSE)
