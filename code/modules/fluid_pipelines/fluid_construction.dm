// Fluid pipe construction
// just the unwrenched part that moves around
/obj/structure/fluid_construction
	name = "uninstalled fluid pipe"
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
	for(var/obj/turf_contents in T)
		if(istype(turf_contents, /obj/machinery/fluid_pipe) && turf_contents.density)
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
	installed_type = /obj/machinery/fluid_pipe/pumpjack
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "pumpjack_idle"

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
	installed_type = /obj/machinery/fluid_pipe
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "pipe"
	can_rotate = FALSE

/obj/structure/fluid_construction/underground
	name = "uninstalled underground pipe"
	installed_type = /obj/machinery/fluid_pipe/underground_pipe
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "underground"
	can_rotate = TRUE

/obj/structure/fluid_construction/pump
	name = "uninstalled fluid pump"
	installed_type = /obj/machinery/fluid_pipe/pump
	icon = 'icons/obj/pipes/fluid_pipes.dmi'
	icon_state = "fpump"
	can_rotate = TRUE

/obj/structure/fluid_construction/tank
	name = "uninstalled fluid tank"
	installed_type = /obj/machinery/fluid_pipe/tank
	icon = 'icons/obj/pipes/32x64fluid_machinery.dmi'
	icon_state = "tank"
	can_rotate = FALSE

/obj/structure/fluid_construction/barrel_filler
	name = "uninstalled barrel filler"
	installed_type = /obj/machinery/fluid_pipe/barrel_filler
	icon = 'icons/obj/pipes/fluid_machinery.dmi'
	icon_state = "filler"
	can_rotate = FALSE

/obj/structure/fluid_construction/refinery
	name = "uninstalled refinery"
	installed_type = /obj/machinery/fluid_pipe/refinery
	icon = 'icons/obj/pipes/64x64fluid_machinery.dmi'
	icon_state = "refinery_4"
	can_rotate = FALSE

/obj/structure/fluid_construction/refinery/rotate() // Same deal here, only two orientations
	if(dir == EAST)
		dir = WEST
	else
		dir = EAST
