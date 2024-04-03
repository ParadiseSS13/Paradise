/datum/buildmode_mode/clean_radiation
	key = "rad"

/datum/buildmode_mode/clean_radiation/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/turf/mob = Remove radiation of selected target.</span>")
	to_chat(user, "<span class='notice'>Ctrl-Left Mouse Button on screen = Remove all radiation in your sight.</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj/turf/mob = Deep clean: Remove radiation of all recursive contents of turf.</span>")
	to_chat(user, "<span class='notice'>Ctrl-Right Mouse Button on screen = Deep clean: Remove radiation of all recursive contents in your sight.</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/clean_radiation/handle_click(mob/user, params, atom/target)
	var/list/pa = params2list(params)
	var/deep_clean = pa.Find("right")
	var/clean_screen = pa.Find("ctrl")

	if(!clean_screen)
		if(!deep_clean)
			if(SEND_SIGNAL(target, COMSIG_ADMIN_DECONTAMINATE))
				to_chat(user, "<span class='notice'>Decontaminated [target].</span>")
			return

		var/counter = 0
		var/turf/T = get_turf(target)
		counter += SEND_SIGNAL(T, COMSIG_ADMIN_DECONTAMINATE)
		for(var/atom/movable/cleanable in T)
			counter += SEND_SIGNAL(cleanable, COMSIG_ADMIN_DECONTAMINATE)
			CHECK_TICK

			if(isliving(cleanable))
				var/mob/living/L = cleanable
				for(var/atom/movable/cleanable2 in L.get_contents())
					counter += SEND_SIGNAL(cleanable2, COMSIG_ADMIN_DECONTAMINATE)
					CHECK_TICK
		to_chat(user, "<span class='notice'>Decontaminated [counter] atom\s.</span>")
		return

	var/counter = 0
	for(var/turf/T in range(user.client.view, user))
		counter += SEND_SIGNAL(T, COMSIG_ADMIN_DECONTAMINATE)
		for(var/atom/movable/cleanable in T)
			counter += SEND_SIGNAL(cleanable, COMSIG_ADMIN_DECONTAMINATE)
			CHECK_TICK
			if(deep_clean && isliving(cleanable))
				var/mob/living/L = cleanable
				for(var/atom/movable/cleanable2 in L.get_contents())
					counter += 	SEND_SIGNAL(cleanable2, COMSIG_ADMIN_DECONTAMINATE)
					CHECK_TICK
	to_chat(user, "<span class='notice'>Decontaminated [counter] atom\s.</span>")
