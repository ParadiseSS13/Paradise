/obj/structure/transit_tube_construction
	name = "transit tube segment"
	desc = "An uninstalled piece of a transit tube network."

	icon = 'icons/obj/pipes/transit_tube_rpd.dmi'

	var/installed_type = null
	var/installed_type_flipped = null
	var/flipped = FALSE
	var/is_station = FALSE

/obj/structure/transit_tube_construction/proc/rotate()
	setDir(turn(dir, -90))

/obj/structure/transit_tube_construction/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt-Click</b> to rotate it, <b>Alt-Shift-Click</b> to flip it.</span>"

/obj/structure/transit_tube_construction/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	rotate()

/obj/structure/transit_tube_construction/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	flip()

/obj/structure/transit_tube_construction/update_icon_state()
	icon_state = "[base_icon_state][flipped ? "_flipped" : ""]"

/obj/structure/transit_tube_construction/proc/flip()
	if(!installed_type_flipped)
		return

	flipped = !flipped
	update_icon(UPDATE_ICON_STATE)

/obj/structure/transit_tube_construction/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!isfloorturf(T) && !isspaceturf(T))
		to_chat(user, "<span class='warning'>You cannot install [src] here.</span>")
		return
	for(var/obj/turf_contents in T)
		// It's okay for tube parts to be installed over existing pods.
		if(!istype(turf_contents, /obj/structure/transit_tube_pod) && turf_contents.density)
			to_chat(user, "<span class='warning'>There is not enough space to install [src] here.</span>")
			return
	if(is_station && !user.can_reach(src))
		to_chat(user, "<span class='warning'>[src] must be installed manually.</span>")
		return

	var/install_type = flipped ? installed_type_flipped : installed_type
	var/atom/installed = new install_type(T)
	installed.dir = dir
	user.visible_message("<span class='notice'>[user] installs [src].</span>")

	I.play_tool_sound(src, I.tool_volume)
	qdel(src)
	. |= RPD_TOOL_SUCCESS

/obj/structure/transit_tube_construction/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume))
		user.visible_message("<span class='notice'>[user] disassembles [src].</span>")
		qdel(src)

/obj/structure/transit_tube_construction/rpd_act(mob/user, obj/item/rpd/our_rpd)
	. = TRUE
	if(our_rpd.mode == RPD_ROTATE_MODE)
		rotate()
	else if(our_rpd.mode == RPD_FLIP_MODE)
		flip()
	else if(our_rpd.mode == RPD_DELETE_MODE)
		our_rpd.delete_single_pipe(user, src)
	else
		return ..()

/obj/structure/transit_tube_construction/pod
	name = "uninstalled transit pod"
	layer = 3.2 // Necessary to be able to install them if on the same tile as tube/construction
	installed_type = /obj/structure/transit_tube_pod
	base_icon_state = "transit_pod"
	icon_state = "transit_pod"

/obj/structure/transit_tube_construction/pod/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	for(var/obj/turf_contents in T)
		if(istype(turf_contents, /obj/structure/transit_tube))
			var/atom/installed = new installed_type(T)
			installed.dir = dir
			user.visible_message("<span class='notice'>[user] installs [src].</span>")

			qdel(src)

	to_chat(user, "<span class='warning'>[src] can only be installed in a transit tube!</span>")

/obj/structure/transit_tube_construction/straight
	installed_type = /obj/structure/transit_tube
	base_icon_state = "transit_straight"
	icon_state = "transit_straight"

/obj/structure/transit_tube_construction/diagonal
	installed_type = /obj/structure/transit_tube/diagonal
	base_icon_state = "transit_diagonal"
	icon_state = "transit_diagonal"

/obj/structure/transit_tube_construction/curved
	installed_type = /obj/structure/transit_tube/curved
	installed_type_flipped = /obj/structure/transit_tube/curved/flipped
	base_icon_state = "transit_curved"
	icon_state = "transit_curved"

/obj/structure/transit_tube_construction/junction
	installed_type = /obj/structure/transit_tube/junction
	installed_type_flipped = /obj/structure/transit_tube/junction/flipped
	base_icon_state = "transit_junction"
	icon_state = "transit_junction"

/obj/structure/transit_tube_construction/station
	installed_type = /obj/structure/transit_tube/station
	base_icon_state = "transit_station"
	icon_state = "transit_station"
	is_station = TRUE

/obj/structure/transit_tube_construction/terminus/dispenser
	installed_type = /obj/structure/transit_tube/station/dispenser/reverse
	installed_type_flipped = /obj/structure/transit_tube/station/dispenser/reverse/flipped
	base_icon_state = "transit_dispenser_terminus"
	icon_state = "transit_dispenser_terminus"
	is_station = TRUE

/obj/structure/transit_tube_construction/station/dispenser
	installed_type = /obj/structure/transit_tube/station/dispenser
	base_icon_state = "transit_dispenser_station"
	icon_state = "transit_dispenser_station"
