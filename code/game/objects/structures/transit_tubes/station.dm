#define CLOSE_DURATION 6
#define OPEN_DURATION 6
#define LAUNCH_COOLDOWN 50


// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.
/obj/structure/transit_tube/station
	name = "station tube station"
	desc = "The lynchpin of the transit system."
	icon = 'icons/obj/pipes/transit_tube_station.dmi'
	icon_state = "closed_station0"
	base_icon_state = "station0"
	exit_delay = 1
	enter_delay = 2
	var/pod_moving = FALSE
	var/launch_cooldown = 0
	var/reverse_launch = FALSE
	var/hatch_state = TRANSIT_TUBE_CLOSED

	var/list/disallowed_mobs = list(/mob/living/silicon/ai)
	/// Direction by which you can board the tube
	var/boarding_dir

/obj/structure/transit_tube/station/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/transit_tube/station/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/transit_tube/station/init_tube_dirs()
	// Tube station directions are simply 90 to either side of
	//  the exit.
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST, WEST)
		if(SOUTH)
			tube_dirs = list(EAST, WEST)
		if(EAST)
			tube_dirs = list(NORTH, SOUTH)
		if(WEST)
			tube_dirs = list(NORTH, SOUTH)
	boarding_dir = reverse_direction(dir)

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return TRUE

/obj/structure/transit_tube/station/Bumped(mob/living/L)
	if(!pod_moving && L.dir == boarding_dir && hatch_state == TRANSIT_TUBE_OPEN && isliving(L) && !is_type_in_list(L, disallowed_mobs))
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(length(pod.contents))
				to_chat(L, "<span class='warning'>The pod is already occupied.</span>")
				return
			if(!pod.moving && ((pod.dir in directions()) || (reverse_launch && (turn(pod.dir, 180) in directions()))))
				pod.move_into(L)
				return



/obj/structure/transit_tube/station/attack_hand(mob/user)
	if(pod_moving)
		return
	var/obj/structure/transit_tube_pod/pod = locate() in loc
	if(!pod)
		return
	// Can't get in moving pods. Or pods that have openings on the other side
	if(pod.moving || !(pod.dir in directions()))
		return
	if(hatch_state != TRANSIT_TUBE_OPEN)
		return
	// Can't empty it when inside or when there is nothing inside
	if(!length(pod.contents) || user.loc == pod)
		return
	user.visible_message("<span class='warning'>[user] starts emptying [pod]'s contents onto the floor!</span>", \
		"<span class='notice'>You start emptying [pod]'s contents onto the floor.</span>", "<span class='warning'>You hear a loud noise! As if somebody is throwing stuff on the floor!</span>")
	if(!do_after(user, 20, target = pod))
		return
	for(var/atom/movable/AM in pod)
		pod.eject(AM)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Weaken(10 SECONDS)


/obj/structure/transit_tube/station/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/grab) && hatch_state == TRANSIT_TUBE_OPEN)
		var/obj/item/grab/G = W
		if(ismob(G.affecting) && G.state >= GRAB_AGGRESSIVE)
			var/mob/living/GM = G.affecting
			for(var/obj/structure/transit_tube_pod/pod in loc)
				pod.visible_message("<span class='warning'>[user] starts putting [GM] into [pod]!</span>")
				if(do_after(user, 30, target = GM) && GM && G && G.affecting == GM)
					GM.Weaken(10 SECONDS)
					Bumped(GM)
					qdel(G)
				break

/obj/structure/transit_tube/station/proc/open_hatch()
	if(hatch_state == TRANSIT_TUBE_CLOSED)
		icon_state = "opening_[base_icon_state]"
		hatch_state = TRANSIT_TUBE_OPENING
		addtimer(CALLBACK(src, PROC_REF(finish_animation)), OPEN_DURATION)

/obj/structure/transit_tube/station/proc/close_hatch()
	if(hatch_state == TRANSIT_TUBE_OPEN)
		icon_state = "closing_[base_icon_state]"
		hatch_state = TRANSIT_TUBE_CLOSING
		addtimer(CALLBACK(src, PROC_REF(finish_animation)), CLOSE_DURATION)

/obj/structure/transit_tube/station/proc/finish_animation()
	switch(hatch_state)
		if(TRANSIT_TUBE_OPENING)
			icon_state = "open_[base_icon_state]"
			hatch_state = TRANSIT_TUBE_OPEN
			for(var/obj/structure/transit_tube_pod/pod in loc)
				for(var/thing in pod)
					if(ismob(thing))
						var/mob/mob_content = thing
						if(mob_content.client && mob_content.stat < UNCONSCIOUS)
							continue // Let the mobs with clients decide what they want to do themselves.
					var/atom/movable/movable_content = thing
					movable_content.forceMove(loc) //Everything else is moved out of.
		if(TRANSIT_TUBE_CLOSING)
			icon_state = "closed_[base_icon_state]"
			hatch_state = TRANSIT_TUBE_CLOSED

/obj/structure/transit_tube/station/proc/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving && ((pod.dir in directions()) || (reverse_launch && (turn(pod.dir, 180) in directions()))))
			addtimer(CALLBACK(src, PROC_REF(launch_pod_callback), pod), 5)
			return

/obj/structure/transit_tube/station/proc/launch_pod_callback(obj/structure/transit_tube_pod/pod)
	pod_moving = TRUE
	close_hatch()
	sleep(CLOSE_DURATION + 2)

	//reverse directions for automated cycling
	var/turf/next_loc = get_step(loc, pod.dir)
	var/obj/structure/transit_tube/nexttube
	for(var/obj/structure/transit_tube/tube in next_loc)
		if(tube.has_entrance(pod.dir))
			nexttube = tube
			break
	if(!nexttube)
		pod.dir = turn(pod.dir, 180)

	if(hatch_state == TRANSIT_TUBE_CLOSED && pod && pod.loc == loc)
		pod.follow_tube()

	pod_moving = FALSE

/obj/structure/transit_tube/station/process()
	if(!pod_moving && launch_cooldown <= world.time)
		launch_pod()

/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = TRUE
	pod.stop_following()
	addtimer(CALLBACK(src, PROC_REF(pod_stopped_callback), pod), 5)

/obj/structure/transit_tube/station/proc/pod_stopped_callback(obj/structure/transit_tube_pod/pod)
	launch_cooldown = world.time + LAUNCH_COOLDOWN
	open_hatch(pod)
	sleep(OPEN_DURATION + 2)
	pod.eject_mindless(dir)
	pod_moving = FALSE
	pod.mix_air()

/obj/structure/transit_tube/station/flipped
	icon_state = "closed_station1"
	base_icon_state = "station1"

/obj/structure/transit_tube/station/flipped/init_tube_dirs()
	..()
	boarding_dir = dir

// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	icon_state = "closed_terminus0"
	base_icon_state = "terminus0"
	reverse_launch = TRUE

/obj/structure/transit_tube/station/reverse/init_tube_dirs()
	tube_dirs = list(turn(dir, -90))
	boarding_dir = reverse_direction(dir)

/obj/structure/transit_tube/station/reverse/flipped
	icon_state = "closed_terminus1"
	base_icon_state = "terminus1"

/obj/structure/transit_tube/station/reverse/flipped/init_tube_dirs()
	..()
	boarding_dir = dir

//special dispenser station, it creates a pod for you to enter when you bump into it.

/obj/structure/transit_tube/station/dispenser
	name = "station tube pod dispenser"
	icon_state = "open_dispenser0"
	desc = "The lynchpin of a GOOD transit system."
	enter_delay = 1
	base_icon_state = "dispenser0"
	hatch_state = TRANSIT_TUBE_OPEN

/obj/structure/transit_tube/station/dispenser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This station will create a pod for you to ride, no need to wait for one.</span>"
	. += "<span class='notice'>Any pods arriving at this station will be reclaimed.</span>"

/obj/structure/transit_tube/station/dispenser/close_hatch()
	. = ..()
	return

/obj/structure/transit_tube/station/dispenser/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving)
			pod_moving = TRUE
			pod.follow_tube()
			pod_moving = FALSE
			return TRUE
	return FALSE

/obj/structure/transit_tube/station/dispenser/Bumped(mob/living/L)
	if(!(istype(L) && L.dir == boarding_dir) || L.anchored)
		return

	if(isliving(L) && !is_type_in_list(L, disallowed_mobs))
		var/obj/structure/transit_tube_pod/dispensed/pod = new(loc)
		L.visible_message("<span class='notice'>[pod] forms around [L].</span>", "<span class='notice'>[pod] materializes around you.</span>")
		playsound(src, 'sound/weapons/emitter2.ogg', 50, TRUE)
		pod.dir = turn(dir, -90)
		pod.move_into(L)
		launch_pod()

/obj/structure/transit_tube/station/dispenser/pod_stopped(obj/structure/transit_tube_pod/pod)
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	qdel(pod)



/obj/structure/transit_tube/station/dispenser/flipped
	icon_state = "open_dispenser1"
	base_icon_state = "dispenser1"

/obj/structure/transit_tube/station/dispenser/flipped/init_tube_dirs()
	..()
	boarding_dir = dir


/obj/structure/transit_tube/station/dispenser/reverse
	reverse_launch = TRUE
	icon_state = "open_terminusdispenser0"
	base_icon_state = "terminusdispenser0"

/obj/structure/transit_tube/station/dispenser/reverse/init_tube_dirs()
	tube_dirs = list(turn(dir, 90))
	boarding_dir = reverse_direction(dir)

/obj/structure/transit_tube/station/dispenser/reverse/flipped
	icon_state = "open_terminusdispenser1"
	base_icon_state = "terminusdispenser1"

/obj/structure/transit_tube/station/dispenser/reverse/flipped/init_tube_dirs()
	..()
	boarding_dir = dir



#undef CLOSE_DURATION
#undef OPEN_DURATION
#undef LAUNCH_COOLDOWN
