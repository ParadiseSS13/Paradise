/datum/buildmode_mode/clean_radiation
	key = "rad"

/datum/buildmode_mode/clean_radiation/show_help(mob/user)
	var/list/messages = list(
		"***********************************************************",
		"Left Mouse Button on obj/turf/mob = Remove radiation of selected target.",
		"Ctrl-Left Mouse Button on screen = Remove all radiation in your sight.",
		"Right Mouse Button on obj/turf/mob = Deep clean: Remove radiation of all recursive contents of turf.",
		"Ctrl-Right Mouse Button on screen = Deep clean: Remove radiation of all recursive contents in your sight.",
		"***********************************************************"
	)
	to_chat(user, messages.Join("<br>"))

/datum/buildmode_mode/clean_radiation/handle_click(mob/user, params, atom/target)
	var/list/pa = params2list(params)
	var/deep_clean = pa.Find("right")
	var/clean_screen = pa.Find("ctrl")

	if(!clean_screen)
		if(!deep_clean)
			if(SEND_SIGNAL(target, COMSIG_ADMIN_DECONTAMINATE))
				to_chat(user, "<span class='notice'>Decontaminated [target].</span>")
				log_admin("Build Mode: [key_name(user)] decontaminated radiation at ([target.x],[target.y],[target.z])")
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
		log_admin("Build Mode: [key_name(user)] deep-clean decontaminated radiation at ([target.x],[target.y],[target.z])")
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
	log_admin("Build Mode: [key_name(user)] [deep_clean ? "deep-clean " : ""]decontaminated their screen of radiation at ([target.x],[target.y],[target.z])")
