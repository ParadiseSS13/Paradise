/obj/structure/construction/transit_tube
	name = "uninstalled transit tube segment"
	desc = "An uninstalled piece of a transit tube network."
	anchored = FALSE
	density = FALSE

	icon = 'icons/obj/pipes/transit_tube_rpd.dmi'

	var/installed_type = null
	var/installed_type_flipped = null
	var/flipped = FALSE

/obj/structure/construction/transit_tube/Initialize(mapload)
	. = ..()
	update_icon_state()

/obj/structure/construction/transit_tube/proc/rotate()
	setDir(turn(dir, -90))

/obj/structure/construction/transit_tube/update_icon_state()
	icon_state = "[base_icon_state][flipped ? "_flipped" : ""]"

/obj/structure/construction/transit_tube/proc/flip()
	if(!installed_type_flipped)
		return

	flipped = !flipped
	update_icon_state()

/obj/structure/construction/transit_tube/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/T = get_turf(src)
	if(!isfloorturf(T)
		to_chat(user, "<span class='notice'>You can only install [src] on a floor.</span>")
		return
	for(var/obj/turf_contents in T)
		var/is_tube_part = (istype(turf_contents, /obj/structure/construction/transit_tube) || istype(turf_contents, /obj/structure/transit_tube))
		if(!(is_tube_part) && turf_contents.density >= 1)
			to_chat(user, "<span class='notice'>There is not enough space to install [src] here.</span>")
			return

	var/install_type = flipped ? installed_type_flipped : installed_type
	var/atom/installed = new install_type(T)
	installed.dir = dir
	to_chat(user, "<span class='notice'>You install [src].</span>")

	qdel(src)

/obj/structure/construction/transit_tube/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "You disassemble [src].")
		new /obj/item/stack/sheet/glass(get_turf(src))
		qdel(src)

/obj/structure/construction/transit_tube/pod
	name = "uninstalled transit pod"
	layer = 3.2 // Necessary to be able to install them if on the same tile as tube/construction
	installed_type = /obj/structure/transit_tube_pod
	base_icon_state = "transit_pod"

/obj/structure/construction/transit_tube/straight
	installed_type = /obj/structure/transit_tube
	base_icon_state = "transit_straight"

/obj/structure/construction/transit_tube/straight/crossing
	installed_type = /obj/structure/transit_tube/crossing
	base_icon_state = "transit_straight_crossing"

/obj/structure/construction/transit_tube/diagonal
	installed_type = /obj/structure/transit_tube/diagonal
	base_icon_state = "transit_diagonal"

/obj/structure/construction/transit_tube/diagonal/crossing
	installed_type = /obj/structure/transit_tube/diagonal/crossing
	base_icon_state = "transit_diagonal_crossing"

/obj/structure/construction/transit_tube/curved
	installed_type = /obj/structure/transit_tube/curved
	installed_type_flipped = /obj/structure/transit_tube/curved/flipped
	base_icon_state = "transit_curved"

/obj/structure/construction/transit_tube/junction
	installed_type = /obj/structure/transit_tube/junction
	installed_type_flipped = /obj/structure/transit_tube/junction/flipped
	base_icon_state = "transit_junction"

/obj/structure/construction/transit_tube/terminus
	installed_type = /obj/structure/transit_tube/station/reverse
	installed_type_flipped = /obj/structure/transit_tube/station/reverse/flipped
	base_icon_state = "transit_terminus"

/obj/structure/construction/transit_tube/station
	installed_type = /obj/structure/transit_tube/station
	base_icon_state = "transit_station"

/obj/structure/construction/transit_tube/terminus/dispenser
	installed_type = /obj/structure/transit_tube/station/dispenser/reverse
	installed_type_flipped = /obj/structure/transit_tube/station/dispenser/reverse/flipped
	base_icon_state = "transit_dispenser_terminus"

/obj/structure/construction/transit_tube/station/dispenser
	installed_type = /obj/structure/transit_tube/station/dispenser
	base_icon_state = "transit_dispenser_station"
