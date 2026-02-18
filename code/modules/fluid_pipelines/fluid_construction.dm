// Fluid pipe construction
// just the unwrenched part that moves around
/obj/structure/fluid_construction
	name = "unset uninstalled pipe name"
	desc = "An incomplete fluid pipe, someone should wrench it."
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	max_integrity = 100
	/// Should our construction ignore rotation?
	var/can_rotate = TRUE
	/// The type it will be turned into after wrenching
	var/installed_type

/obj/structure/fluid_construction/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<b>Alt-Click</b> to rotate it.")

/obj/structure/fluid_construction/proc/rotate()
	if(can_rotate)
		setDir(turn(dir, -90)) // subtypes will handle illegal turns

/obj/structure/fluid_construction/AltClick(mob/user)
	if(user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	rotate()

/obj/structure/fluid_construction/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!isfloorturf(T) && !isspaceturf(T))
		to_chat(user, SPAN_WARNING("You cannot install [src] here."))
		return
	for(var/obj/machinery/fluid_pipe in T)
		if(fluid_pipe.density)
			to_chat(user, SPAN_WARNING("There isn't enough space to install [src] here."))
			return

	var/obj/machinery/fluid_pipe/installed = new installed_type(T, dir)
	user.visible_message(SPAN_NOTICE("[user] installs [installed]."))

	I.play_tool_sound(src, I.tool_volume)
	. |= RPD_TOOL_SUCCESS
	qdel(src)

/obj/structure/fluid_construction/rpd_act(mob/user, obj/item/rpd/our_rpd)
	. = TRUE
	if(our_rpd.mode == RPD_ROTATE_MODE)
		rotate()
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
	else
		return ..()

/obj/structure/fluid_construction/pumpjack
	name = "uninstalled pump jack"
	desc = "Looks about the right size to fit over a geyser."
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "pumpjack_idle"
	installed_type = /obj/machinery/fluid_pipe/pumpjack

/obj/structure/fluid_construction/pumpjack/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	for(var/obj/structure/geyser/geysers in T)
		var/obj/machinery/fluid_pipe/installed = new installed_type(T, dir)
		user.visible_message(SPAN_NOTICE("[user] installs [installed], over the [geysers] as it whirrs to life."))
		qdel(src)
		return
	to_chat(user, SPAN_WARNING("[src] can only be installed over a geyser!"))

/obj/structure/fluid_construction/pumpjack/rotate() // Only has two orientations, lets not break it
	if(dir == EAST)
		dir = WEST
	else
		dir = EAST

/obj/structure/fluid_construction/pipe
	name = "uninstalled fluid pipe"
	icon_state = "pipe"
	installed_type = /obj/machinery/fluid_pipe
	can_rotate = FALSE

/obj/structure/fluid_construction/underground
	name = "uninstalled underground pipe"
	icon_state = "underground"
	installed_type = /obj/machinery/fluid_pipe/underground_pipe

/obj/structure/fluid_construction/pump
	name = "uninstalled fluid pump"
	icon_state = "fpump"
	installed_type = /obj/machinery/fluid_pipe/pump

/obj/structure/fluid_construction/tank
	name = "uninstalled fluid tank"
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "tank"
	installed_type = /obj/machinery/fluid_pipe/tank
	can_rotate = FALSE

/obj/structure/fluid_construction/barrel_filler
	name = "uninstalled barrel filler"
	icon = 'icons/obj/pipes/fluid_machinery.dmi'
	icon_state = "filler"
	installed_type = /obj/machinery/fluid_pipe/barrel_filler
	can_rotate = FALSE

/obj/structure/fluid_construction/refinery
	name = "uninstalled refinery"
	icon = 'icons/obj/pipes/64x64fluid_machinery.dmi'
	icon_state = "refinery_4"
	installed_type = /obj/machinery/fluid_pipe/refinery

/obj/structure/fluid_construction/refinery/rotate() // Same deal here, only two orientations
	if(dir == EAST)
		dir = WEST
	else
		dir = EAST
