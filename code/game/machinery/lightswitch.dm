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

/obj/machinery/light_switch/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "light-p"
		return
	icon_state = "light[get_area(src).lightswitch]"

/obj/machinery/light_switch/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	. += "light[get_area(src).lightswitch]"
	underlays += emissive_appearance(icon, "light_lightmask")

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [get_area(src).lightswitch ? "on" : "off"].</span>"

/obj/machinery/light_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

	var/area/A = get_area(src)

	A.lightswitch = !A.lightswitch
	A.update_icon(UPDATE_ICON_STATE)

	for(var/obj/machinery/light_switch/L in A)
		L.update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

	machine_powernet.power_change()

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
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return

	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/light_switch(get_turf(src))
	qdel(src)
