#define CLOSE_DURATION 6
#define OPEN_DURATION 6
#define LAUNCH_COOLDOWN 50


// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.
/obj/structure/transit_tube/station
	name = "station tube station"
	icon = 'icons/obj/pipes/transit_tube_station.dmi'
	icon_state = "closed"
	exit_delay = 1
	enter_delay = 2
	var/pod_moving = FALSE
	var/launch_cooldown = 0
	var/reverse_launch = FALSE
	var/hatch_state = TRANSIT_TUBE_CLOSED

	var/list/disallowed_mobs = list(/mob/living/silicon/ai)

/obj/structure/transit_tube/station/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/transit_tube/station/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	reverse_launch = TRUE

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return TRUE

/obj/structure/transit_tube/station/Bumped(mob/living/L)
	if(!pod_moving && hatch_state == TRANSIT_TUBE_OPEN && isliving(L) && !is_type_in_list(L, disallowed_mobs))
		var/failed = FALSE
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(pod.contents.len)
				failed = TRUE
			else if(!pod.moving && (pod.dir in directions()))
				pod.move_into(L)
				return
		if(failed)
			to_chat(L, "<span class='warning'>The pod is already occupied.</span>")



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
		if(ismob(AM))
			var/mob/M = AM
			M.Weaken(5)


/obj/structure/transit_tube/station/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/grab) && hatch_state == TRANSIT_TUBE_OPEN)
		var/obj/item/grab/G = W
		if(ismob(G.affecting) && G.state >= GRAB_AGGRESSIVE)
			var/mob/GM = G.affecting
			for(var/obj/structure/transit_tube_pod/pod in loc)
				pod.visible_message("<span class='warning'>[user] starts putting [GM] into the [pod]!</span>")
				if(do_after(user, 30, target = GM) && GM && G && G.affecting == GM)
					GM.Weaken(5)
					Bumped(GM)
					qdel(G)
				break

/obj/structure/transit_tube/station/proc/open_hatch()
	if(hatch_state == TRANSIT_TUBE_CLOSED)
		icon_state = "opening"
		hatch_state = TRANSIT_TUBE_OPENING
		addtimer(CALLBACK(src, .proc/open_hatch_callback), OPEN_DURATION)

/obj/structure/transit_tube/station/proc/open_hatch_callback()
	if(hatch_state == TRANSIT_TUBE_OPENING)
		icon_state = "open"
		hatch_state = TRANSIT_TUBE_OPEN



/obj/structure/transit_tube/station/proc/close_hatch()
	if(hatch_state == TRANSIT_TUBE_OPEN)
		icon_state = "closing"
		hatch_state = TRANSIT_TUBE_CLOSING
		addtimer(CALLBACK(src, .proc/close_hatch_calllback), CLOSE_DURATION)

/obj/structure/transit_tube/station/proc/close_hatch_calllback()
	if(hatch_state == TRANSIT_TUBE_CLOSING)
		icon_state = "closed"
		hatch_state = TRANSIT_TUBE_CLOSED

/obj/structure/transit_tube/station/proc/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving && (pod.dir in directions()))
			addtimer(CALLBACK(src, .proc/launch_pod_callback, pod), 5)
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

	if(hatch_state == TRANSIT_TUBE_CLOSED && pod)
		pod.follow_tube()

	pod_moving = FALSE

/obj/structure/transit_tube/station/process()
	if(!pod_moving && launch_cooldown <= world.time)
		launch_pod()

/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = TRUE
	addtimer(CALLBACK(src, .proc/pod_stopped_callback, pod), 5)

/obj/structure/transit_tube/station/proc/pod_stopped_callback(obj/structure/transit_tube_pod/pod)
	launch_cooldown = world.time + LAUNCH_COOLDOWN
	open_hatch(pod)
	sleep(OPEN_DURATION + 2)
	pod.eject_mindless(dir)
	pod_moving = FALSE
	pod.mix_air()

// Tube station directions are simply 90 to either side of
//  the exit.
/obj/structure/transit_tube/station/init_dirs()
	tube_dirs = list(turn(dir, 90), turn(dir, -90))

#undef CLOSE_DURATION
#undef OPEN_DURATION
#undef LAUNCH_COOLDOWN
