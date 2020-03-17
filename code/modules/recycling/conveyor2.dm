#define DIRECTION_FORWARDS	1
#define DIRECTION_OFF		0
#define DIRECTION_REVERSED	-1
#define IS_OPERATING		(operating && can_conveyor_run())

GLOBAL_LIST_INIT(conveyor_belts, list()) //Saves us having to look through the entire machines list for our things
GLOBAL_LIST_INIT(conveyor_switches, list())

//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//Except this is pretty heavily modified so it's more like conveyor2.5

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_stopped_cw"
	name = "conveyor belt"
	desc = "It's a conveyor belt, commonly used to transport large numbers of items elsewhere quite quickly."
	layer = CONVEYOR_LAYER 		// so they appear under stuff but not below stuff like vents
	anchored = TRUE
	move_force = MOVE_FORCE_DEFAULT
	var/operating = FALSE	//NB: this can be TRUE while the belt doesn't go
	var/forwards			// The direction the conveyor sends you in
	var/backwards			// hopefully self-explanatory
	var/clockwise = TRUE	// For corner pieces - do we go clockwise or counterclockwise?
	var/operable = TRUE		// Can this belt actually go?
	var/list/affecting		// the list of all items that will be moved this ptick
	var/reversed = FALSE	// set to TRUE to have the conveyor belt be reversed
	var/id					//ID of the connected lever

	// create a conveyor
/obj/machinery/conveyor/New(loc, new_dir, new_id)
	..(loc)
	GLOB.conveyor_belts += src
	if(new_id)
		id = new_id
	if(new_dir)
		dir = new_dir
	update_move_direction()
	for(var/I in GLOB.conveyor_switches)
		var/obj/machinery/conveyor_switch/S = I
		if(id == S.id)
			S.conveyors += src

/obj/machinery/conveyor/Destroy()
	GLOB.conveyor_belts -= src
	return ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/I, mob/user)
	if(stat & BROKEN)
		return ..()
	else if(istype(I, /obj/item/conveyor_switch_construct))
		var/obj/item/conveyor_switch_construct/S = I
		if(S.id == id)
			return ..()
		for(var/obj/machinery/conveyor_switch/CS in GLOB.conveyor_switches)
			if(CS.id == id)
				CS.conveyors -= src
		id = S.id
		to_chat(user, "<span class='notice'>You link [I] with [src].</span>")
	else if(user.a_intent != INTENT_HARM)
		if(user.drop_item())
			I.forceMove(loc)
	else
		return ..()


/obj/machinery/conveyor/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!(stat & BROKEN))
		var/obj/item/conveyor_construct/C = new(loc)
		C.id = id
		transfer_fingerprints_to(C)
	to_chat(user,"<span class='notice'>You remove [src].</span>")
	qdel(src)

/obj/machinery/conveyor/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	set_rotation(user)
	update_move_direction()

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

/obj/machinery/conveyor/update_icon()
	..()
	if(IS_OPERATING)
		icon_state = "conveyor_started_[clockwise ? "cw" : "ccw"]"
		if(reversed)
			icon_state += "_r"
	else
		icon_state = "conveyor_stopped_[clockwise ? "cw" : "ccw"]"

/obj/machinery/conveyor/proc/update_move_direction()
	update_icon()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = clockwise ? EAST : NORTH
			backwards = clockwise ? SOUTH : WEST
		if(SOUTHEAST)
			forwards = clockwise ? SOUTH : EAST
			backwards = clockwise ? WEST : NORTH
		if(SOUTHWEST)
			forwards = clockwise ? WEST : SOUTH
			backwards = clockwise ? NORTH : EAST
		if(NORTHWEST)
			forwards = clockwise ? NORTH : WEST
			backwards = clockwise ? EAST : SOUTH
	if(!reversed)
		return
	var/temporary_direction = forwards
	forwards = backwards
	backwards = temporary_direction

/obj/machinery/conveyor/proc/set_rotation(mob/user)
	dir = turn(reversed ? backwards : forwards, -90) //Fuck it, let's do it this way instead of doing something clever with dir
	var/turf/left = get_step(src, turn(dir, 90))	//We need to get conveyors to the right, left, and behind this one to be able to determine if we need to make a corner piece
	var/turf/right = get_step(src, turn(dir, -90))
	var/turf/back = get_step(src, turn(dir, 180))
	to_chat(user, "<span class='notice'>You rotate [src].</span>")
	var/obj/machinery/conveyor/CL = locate() in left
	var/obj/machinery/conveyor/CR = locate() in right
	var/obj/machinery/conveyor/CB = locate() in back
	var/link_to_left = FALSE
	var/link_to_right = FALSE
	var/link_to_back = FALSE
	if(CL)
		if(CL.id == id && get_step(CL, CL.reversed ? CL.backwards : CL.forwards) == loc)
			link_to_left = TRUE
	if(CR)
		if(CR.id == id && get_step(CR, CR.reversed ? CR.backwards : CR.forwards) == loc)
			link_to_right = TRUE
	if(CB)
		if(CB.id == id && get_step(CB, CB.reversed ? CB.backwards : CB.forwards) == loc)
			link_to_back = TRUE
	if(link_to_back) //Don't need to do anything because we can assume the conveyor carries on in a line
		return
	else if(!(link_to_left ^ link_to_right)) //Either no valid conveyors point here, or two point here (making a "junction" with this belt as the middle piece). Either way we don't need a corner
		return
	if(link_to_right)
		dir = turn(dir, 45)
		clockwise = TRUE
	else if(link_to_left)
		dir = turn(dir, -45)
		clockwise = FALSE

/obj/machinery/conveyor/power_change()
	..()
	update_icon()

/obj/machinery/conveyor/process()
	if(!IS_OPERATING)
		return
	use_power(100)
	affecting = loc.contents - src // moved items will be all in loc
	var/still_stuff_to_move = FALSE
	for(var/atom/movable/AM in affecting)
		if(AM.anchored)
			continue
		still_stuff_to_move = TRUE
		addtimer(CALLBACK(src, .proc/move_thing, AM), 1)
		CHECK_TICK
	if(!still_stuff_to_move && speed_process)
		makeNormalProcess()
	else if(still_stuff_to_move && !speed_process)
		makeSpeedProcess()

/obj/machinery/conveyor/Crossed(atom/movable/AM, oldloc)
	if(!speed_process && !AM.anchored)
		makeSpeedProcess()
	..()

/obj/machinery/conveyor/proc/move_thing(atom/movable/AM)
	if(move_force < (AM.move_resist))
		return FALSE
	if(!AM.anchored && AM.loc == loc)
		step(AM, forwards)


/obj/machinery/conveyor/proc/can_conveyor_run()
	if(stat & BROKEN)
		return FALSE
	else if(stat & NOPOWER)
		return FALSE
	else if(!operable)
		return FALSE
	return TRUE

// make the conveyor broken and propagate inoperability to any connected conveyor with the same conveyor datum
/obj/machinery/conveyor/proc/make_broken()
	stat |= BROKEN
	operable = FALSE
	update_icon()
	var/obj/machinery/conveyor/C = locate() in get_step(src, forwards)
	if(C)
		C.set_operable(TRUE, id, FALSE)
	C = locate() in get_step(src, backwards)
	if(C)
		C.set_operable(FALSE, id, FALSE)

/obj/machinery/conveyor/proc/set_operable(propagate_forwards, match_id, op) //Sets a conveyor inoperable if ID matches it, and propagates forwards / backwards
	if(id != match_id)
		return
	operable = op
	update_icon()
	var/obj/machinery/conveyor/C = locate() in get_step(src, propagate_forwards ? forwards : backwards)
	if(C)
		C.set_operable(propagate_forwards ? TRUE : FALSE, id, op)

// the conveyor control switch

/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "This switch controls any and all conveyor belts it is linked to."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = DIRECTION_OFF
	var/reversed = TRUE
	var/one_way = FALSE	// Do we go in one direction?
	anchored = TRUE
	var/id
	var/list/conveyors = list()

/obj/machinery/conveyor_switch/New(newloc, new_id)
	..(newloc)
	GLOB.conveyor_switches += src
	if(!id)
		id = new_id
	for(var/I in GLOB.conveyor_belts)
		var/obj/machinery/conveyor/C = I
		if(C.id == id)
			conveyors += C

/obj/machinery/conveyor_switch/Destroy()
	GLOB.conveyor_switches -= src
	return ..()

// update the icon depending on the position

/obj/machinery/conveyor_switch/update_icon()
	overlays.Cut()
	if(!position)
		icon_state = "switch-off"
	else if(position == DIRECTION_REVERSED)
		icon_state = "switch-rev"
		if(!(stat & NOPOWER))
			overlays += "redlight"
	else if(position == DIRECTION_FORWARDS)
		icon_state = "switch-fwd"
		if(!(stat & NOPOWER))
			overlays += "greenlight"

/obj/machinery/conveyor_switch/oneway
	one_way = TRUE

// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	if(..())
		return TRUE
	toggle(user)

/obj/machinery/conveyor_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

/obj/machinery/conveyor_switch/proc/toggle(mob/user)
	add_fingerprint(user)
	if(!allowed(user) && !user.can_advanced_admin_interact()) //this is in Para but not TG. I don't think there's any which are set anyway.
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	if(position)
		position = DIRECTION_OFF
	else
		reversed = one_way ? FALSE : !reversed
		position = reversed ? DIRECTION_REVERSED : DIRECTION_FORWARDS
	update_icon()
	for(var/obj/machinery/conveyor/C in conveyors)
		C.operating = abs(position)
		if(C.reversed != reversed)
			C.reversed = reversed
			C.update_move_direction()
		else
			C.update_icon()
		CHECK_TICK
	for(var/I in GLOB.conveyor_switches) // find any switches with same id as this one, and set their positions to match us
		var/obj/machinery/conveyor_switch/S = I
		if(S == src || S.id != id)
			continue
		S.position = position
		S.one_way = one_way //Break everything!!1!
		S.reversed = reversed
		S.update_icon()
		CHECK_TICK

/obj/machinery/conveyor_switch/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/obj/item/conveyor_switch_construct/C = new(loc, id)
	transfer_fingerprints_to(C)
	to_chat(user,"<span class='notice'>You detach [src].</span>")
	qdel(src)

/obj/machinery/conveyor_switch/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	one_way = !one_way
	to_chat(user, "<span class='notice'>[src] will now go [one_way ? "forwards only" : "both forwards and backwards"].</span>")

/obj/machinery/conveyor_switch/power_change()
	..()
	update_icon()

// CONVEYOR CONSTRUCTION STARTS HERE

/obj/item/conveyor_construct
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_loose"
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly, used for the assembly of conveyor belt systems."
	w_class = WEIGHT_CLASS_BULKY
	var/id

/obj/item/conveyor_construct/attackby(obj/item/I, mob/user, params)
	..()
	if(!istype(I, /obj/item/conveyor_switch_construct))
		return
	var/obj/item/conveyor_switch_construct/C = I
	to_chat(user, "<span class='notice'>You link [src] to [C].</span>")
	id = C.id

/obj/item/conveyor_construct/afterattack(turf/T, mob/user, proximity)
	if(!proximity)
		return
	if(user.incapacitated())
		return
	if(!istype(T, /turf/simulated/floor))
		return
	if(T == get_turf(user))
		to_chat(user, "<span class='notice'>You cannot place [src] under yourself.</span>")
		return
	if(locate(/obj/machinery/conveyor) in T) //Can't put conveyors beneath conveyors
		to_chat(user, "<span class='notice'>There's already a conveyor there!</span>")
		return
	var/obj/machinery/conveyor/C = new(T, user.dir, id)
	transfer_fingerprints_to(C)
	qdel(src)

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly. When set up, it'll control any and all conveyor belts it is linked to."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch"
	w_class = WEIGHT_CLASS_BULKY
	var/id

/obj/item/conveyor_switch_construct/New(loc, new_id)
	..(loc)
	if(new_id)
		id = new_id
	else
		id = world.time + rand() //this couldn't possibly go wrong


/obj/item/conveyor_switch_construct/afterattack(turf/T, mob/user, proximity)
	if(!proximity)
		return
	if(user.incapacitated())
		return
	if(!istype(T, /turf/simulated/floor))
		return
	var/found = FALSE
	for(var/obj/machinery/conveyor/C in view())
		if(C.id == id)
			found = TRUE
			break
	if(!found)
		to_chat(user, "<span class='notice'>[src] did not detect any linked conveyor belts in range.</span>")
		return
	var/obj/machinery/conveyor_switch/NC = new(T, id)
	transfer_fingerprints_to(NC)
	qdel(src)

/obj/item/conveyor_switch_construct/attackby(obj/item/I, mob/user)
	if(!istype(I, /obj/item/conveyor_switch_construct))
		return ..()
	var/obj/item/conveyor_switch_construct/S = I
	id = S.id
	to_chat(user, "<span class='notice'>You link the two switch constructs.</span>")

/obj/item/paper/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	info = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! \
	We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined \
	assembly procedure that puts all other mail-order products to shame!</p>\
	<p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt \
	assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! </p>\
	<p> Set single directional switches by using your multitool on the switch after you've installed the switch assembly.</p>\
	<p> This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"

/obj/machinery/conveyor/counterclockwise
	clockwise = FALSE
	icon_state = "conveyor_stopped_ccw"

/obj/machinery/conveyor/auto/New(loc, newdir)
	..(loc, newdir)
	operating = TRUE
	update_icon()

//Other types of conveyor, mostly for saving yourself a headache during mapping

/obj/machinery/conveyor/north
	dir = NORTH

/obj/machinery/conveyor/northeast
	dir = NORTHEAST

/obj/machinery/conveyor/east
	dir = EAST

/obj/machinery/conveyor/southeast
	dir = SOUTHEAST

/obj/machinery/conveyor/south
	dir = SOUTH

/obj/machinery/conveyor/southwest
	dir = SOUTHWEST

/obj/machinery/conveyor/west
	dir = WEST

/obj/machinery/conveyor/northwest
	dir = NORTHWEST

/obj/machinery/conveyor/north/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/northeast/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/east/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/southeast/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/south/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/southwest/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/west/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

/obj/machinery/conveyor/northwest/ccw
	icon_state = "conveyor_stopped_ccw"
	clockwise = FALSE

#undef DIRECTION_FORWARDS
#undef DIRECTION_OFF
#undef DIRECTION_REVERSED
#undef IS_OPERATING
