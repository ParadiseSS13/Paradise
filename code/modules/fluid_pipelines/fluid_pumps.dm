/*
  * The pump transfers fluids from the incoming.fluid_datum pipe datum to the fluid_datum one.
  * They have an internal fluid datum by inheritance, but this is unused and should not be set.
  * Pumps only work when both ends are connected, and move fluids immediately from one datum to another.
  * Because the pump is added to multiple datums, the pumpspeed is half of what is actually moved each tick.
  *
 */
/obj/machinery/fluid_pipe/pump
	name = "fluid pump"
	desc = "Pumps fluids from one pipe to another."
	icon_state = "pump_4"
	just_a_pipe = FALSE
	dir = EAST
	capacity = 0 // Safety
	/// How much fluid do we move each tick? The amount moved is the double of the variable.
	var/pump_speed = 50 // Enough to fully fill one pipe per tick
	/// The incoming pipeline
	var/obj/machinery/fluid_pipe/abstract/pump/incoming

// Start abstract pump

/obj/machinery/fluid_pipe/abstract/pump

/obj/machinery/fluid_pipe/abstract/pump/Initialize(mapload, direction, _parent)
	connect_dirs = list(REVERSE_DIR(direction))
	return ..()

// End abstract pump

/obj/machinery/fluid_pipe/pump/Initialize(mapload, direction)
	connect_dirs = list(dir)
	incoming = new(get_turf(src), dir, src)
	update_icon()
	return ..()

/obj/machinery/fluid_pipe/pump/update_icon_state()
	icon_state = "pump_[dir]"

/obj/machinery/fluid_pipe/pump/blind_connect()
	clear_pipenet_refs() // You have to clear these every time you attempt connecting, otherwise it might keep pumping even though it's not connected
	var/obj/machinery/fluid_pipe/pipe = locate(/obj/machinery/fluid_pipe) in get_step(src, dir) // Yes, a pump is also a valid place to transfer from
	if(pipe)
		connect_pipes(pipe)

/obj/machinery/fluid_pipe/pump/connect_pipes(obj/machinery/fluid_pipe/pipe_to_connect_to)
	if(isnull(pipe_to_connect_to.fluid_datum) && isnull(fluid_datum))
		pipe_to_connect_to.fluid_datum = new(pipe_to_connect_to)
	if(get_dir(src, pipe_to_connect_to) == dir)
		fluid_datum = pipe_to_connect_to.fluid_datum
		fluid_datum.add_pipe(src)

/obj/machinery/fluid_pipe/abstract/pump/special_connect_check(obj/machinery/fluid_pipe/pipe)
	return (pipe.fluid_datum == parent.fluid_datum) ^ parent.fluid_datum  // DGTODO Move this to abstract pipes?

/obj/machinery/fluid_pipe/pump/special_connect_check(obj/machinery/fluid_pipe/pipe)
	return (pipe.fluid_datum == incoming.fluid_datum) ^ incoming.fluid_datum

/obj/machinery/fluid_pipe/pump/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, "You start [anchored ? "un" : ""]wrenching [src].")
	if(!do_after(user, 3 SECONDS, TRUE, src))
		to_chat(user, "You stop.") // DGTODO: add span classes + message
		return

	if(!anchored)
		blind_connect()
	else
		incoming.fluid_datum.remove_pipe(src)
		incoming.fluid_datum = null
		fluid_datum.remove_pipe(src)
		fluid_datum = null

		for(var/direction in list (dir, REVERSE_DIR(dir)))
			var/obj/machinery/fluid_pipe/pipe = locate(/obj/machinery/fluid_pipe) in get_step(src, direction) // Yes, a pump is also a valid place to transfer from
			if(pipe)
				pipe.update_icon()

	anchored = !anchored

/obj/machinery/fluid_pipe/pump/clear_pipenet_refs()
	. = ..()
	incoming.fluid_datum = null
	fluid_datum = null

/obj/machinery/fluid_pipe/pump/process()
	if(fluid_datum?.total_capacity <= 0 || !incoming.fluid_datum)
		return
	incoming.fluid_datum.move_any_fluid(fluid_datum, 50) // DGTODO this doesn't work?

/obj/machinery/fluid_pipe/pump/north
	dir = NORTH

/obj/machinery/fluid_pipe/pump/south
	dir = SOUTH

/obj/machinery/fluid_pipe/pump/west
	dir = WEST
