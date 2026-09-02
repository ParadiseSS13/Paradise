/obj/item/mounted/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"

	mount_requirements = MOUNTED_FRAME_SIMFLOOR
	///specifies which type of light fixture this frame will build
	var/fixture_type = "tube"

/obj/item/mounted/frame/light_fixture/do_build(turf/on_wall, mob/user)
	to_chat(user, "You begin attaching [src] to \the [on_wall].")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, 1)
	var/constrdir = user.dir
	var/constrloc = get_turf(user)
	if(!do_after(user, 30, target = on_wall))
		return
	var/obj/machinery/light_construct/newlight
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
		if("floor")
			newlight = new /obj/machinery/light_construct/floor(on_wall)
		if("clockwork_bulb")
			newlight = new /obj/machinery/light_construct/clockwork/small(constrloc)
		if("clockwork_tube")
			newlight = new /obj/machinery/light_construct/clockwork(constrloc)
		if("clockwork_floor")
			newlight = new /obj/machinery/light_construct/clockwork/floor(on_wall)
		else
			newlight = new /obj/machinery/light_construct/small(constrloc)
	newlight.dir = constrdir
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	user.visible_message("[user] attaches \the [src] to \the [on_wall].", \
		"You attach \the [src] to \the [on_wall].")
	qdel(src)

/obj/item/mounted/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon_state = "bulb-construct-item"
	fixture_type = "bulb"
	metal_sheets_refunded = 1

/obj/item/mounted/frame/light_fixture/floor
	name = "floor light fixture frame"
	desc = "Used for building floor lights."
	icon_state = "floor-construct-item"
	fixture_type = "floor"
	metal_sheets_refunded = 3
	buildon_types = list(/turf/simulated/floor)
	allow_floor_mounting = TRUE

/obj/item/mounted/frame/light_fixture/clockwork
	name = "brass light fixture frame"
	desc = "Used for building brass lights."
	icon_state = "clockwork_tube-construct-item"
	fixture_type = "clockwork_tube"
	metal_sheets_refunded = 0
	brass_sheets_refunded = 2

/obj/item/mounted/frame/light_fixture/clockwork/small
	name = "brass small light fixture frame"
	desc = "Used for building small brass lights."
	icon_state = "clockwork_bulb-construct-item"
	fixture_type = "clockwork_bulb"
	brass_sheets_refunded = 1

/obj/item/mounted/frame/light_fixture/clockwork/floor
	name = "brass floor light fixture frame"
	desc = "Used for building brass floor lights."
	icon_state = "clockwork_floor-construct-item"
	fixture_type = "clockwork_floor"
	brass_sheets_refunded = 3
	buildon_types = list(/turf/simulated/floor)
	allow_floor_mounting = TRUE
