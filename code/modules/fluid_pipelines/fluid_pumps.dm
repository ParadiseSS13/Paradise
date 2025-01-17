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
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pump_4"
	anchored = FALSE
	just_a_pipe = FALSE
	capacity = 0 // Safety
	/// How much fluid do we move each tick? The amount moved is the double of the variable.
	var/pump_speed = 50 // Enough to fully fill one pipe per tick
	/// The incoming pipeline
	var/obj/machinery/fluid_pipe/abstract/pump/incoming

/obj/machinery/fluid_pipe/abstract/pump

/obj/machinery/fluid_pipe/abstract/pump/Initialize(mapload, direction)
	connect_dirs = list(direction)
	return ..()

/obj/machinery/fluid_pipe/pump/Initialize(mapload)
	connect_dirs = list(dir)
	incoming = new(get_turf(src), src, REVERSE_DIR(dir))
	update_icon()
	return ..()

/obj/machinery/fluid_pipe/pump/update_icon_state()
	icon_state = "pump_[dir]"

/obj/machinery/fluid_pipe/pump/blind_connect()
	clear_pipenet_refs() // You have to clear these every time you attempt connecting, otherwise it might keep pumping even though it's not connected
	for(var/direction in list(dir, REVERSE_DIR(dir)))
		var/obj/machinery/fluid_pipe/pipe = locate(/obj/machinery/fluid_pipe) in get_step(src, direction) // Yes, a pump is also a valid place to transfer from
		if(pipe)
			connect_pipes(pipe)

/obj/machinery/fluid_pipe/pump/connect_pipes(obj/machinery/fluid_pipe/pipe_to_connect_to)
	if(isnull(pipe_to_connect_to.fluid_datum))
		pipe_to_connect_to.fluid_datum = new(pipe_to_connect_to)
	if(get_dir(src, pipe_to_connect_to) == dir)
		fluid_datum = pipe_to_connect_to.fluid_datum
		fluid_datum.add_pipe(src)
	else
		incoming.fluid_datum = pipe_to_connect_to.fluid_datum
		incoming.fluid_datum.add_pipe(src)

/obj/machinery/fluid_pipe/pump/wrench_act(mob/living/user, obj/item/I)
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
