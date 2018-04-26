
// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.
/obj/structure/transit_tube/station
	name = "station tube station"
	icon = 'icons/obj/pipes/transit_tube_station.dmi'
	icon_state = "closed"
	exit_delay = 1
	enter_delay = 2
	var/pod_moving = 0
	var/cooldown_delay = 50
	var/launch_cooldown = 0
	var/reverse_launch = 0

	var/const/OPEN_DURATION = 6
	var/const/CLOSE_DURATION = 6
	var/list/disallowed_mobs = list(/mob/living/silicon/ai)

/obj/structure/transit_tube/station/New()
	..()
	processing_objects += src

/obj/structure/transit_tube/station/Destroy()
	processing_objects -= src
	return ..()

// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	reverse_launch = 1

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return 1

/obj/structure/transit_tube/station/Bumped(mob/AM as mob|obj)
	if(!pod_moving && icon_state == "open" && istype(AM, /mob/living) && !is_type_in_list(AM, disallowed_mobs))
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(pod.contents.len)
				to_chat(AM, "<span class=The pod is already occupied.</span>")
				return
			else if(!pod.moving && pod.dir in directions())
				AM.forceMove(pod)
				return



/obj/structure/transit_tube/station/attack_hand(mob/user as mob)
	if(!pod_moving)
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving && pod.dir in directions())
				if(icon_state == "closed")
					open_animation()

				else if(icon_state == "open")
					if(pod.contents.len && user.loc != pod)
						user.visible_message("<span class='warning'>[user] starts emptying [pod]'s contents onto the floor!</span>")
						if(do_after(user, 40, target = src)) //So it doesn't default to close_animation() on fail
							if(pod.loc == loc)
								for(var/atom/movable/AM in pod)
									AM.loc = get_turf(user)
									if(ismob(AM))
										var/mob/M = AM
										M.Weaken(5)

					else
						close_animation()
			break


/obj/structure/transit_tube/station/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/grab) && icon_state == "open")
		var/obj/item/grab/G = W
		if(ismob(G.affecting) && G.state >= GRAB_AGGRESSIVE)
			var/mob/GM = G.affecting
			for(var/obj/structure/transit_tube_pod/pod in loc)
				pod.visible_message("<span class='warning'>[user] starts putting [GM] into the [pod]!</span>")
				if(do_after(user, 60, target = GM) && GM && G && G.affecting == GM)
					GM.Weaken(5)
					src.Bumped(GM)
					qdel(G)
				break

/obj/structure/transit_tube/station/proc/open_animation()
	if(icon_state == "closed")
		icon_state = "opening"
		spawn(OPEN_DURATION)
			if(icon_state == "opening")
				icon_state = "open"



/obj/structure/transit_tube/station/proc/close_animation()
	if(icon_state == "open")
		icon_state = "closing"
		spawn(CLOSE_DURATION)
			if(icon_state == "closing")
				icon_state = "closed"



/obj/structure/transit_tube/station/proc/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving && pod.dir in directions())
			spawn(5)
				pod_moving = 1
				close_animation()
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

				if(icon_state == "closed" && pod)
					pod.follow_tube()

				pod_moving = 0

			return

/obj/structure/transit_tube/station/process()
	if(!pod_moving)
		launch_pod()

/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = 1
	spawn(5)
		launch_cooldown = world.time + cooldown_delay
		open_animation()
		sleep(OPEN_DURATION + 2)
		pod_moving = 0
		pod.mix_air()

// Tube station directions are simply 90 to either side of
//  the exit.
/obj/structure/transit_tube/station/init_dirs()
	tube_dirs = list(turn(dir, 90), turn(dir, -90))