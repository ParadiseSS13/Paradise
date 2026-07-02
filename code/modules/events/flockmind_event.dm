/datum/event/flockmind
	name = "Flockmind"
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_DISASTER
	role_weights = list(ASSIGNMENT_SECURITY = 2, ASSIGNMENT_CREW = 0.7, ASSIGNMENT_MEDICAL = 2)
	role_requirements = list(ASSIGNMENT_SECURITY = 3, ASSIGNMENT_CREW = 25, ASSIGNMENT_MEDICAL = 2)

/datum/event/flockmind/start()
	INVOKE_ASYNC(src, PROC_REF(create_flock))

/datum/event/flockmind/proc/create_flock()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Flockmind?", ROLE_FLOCK, TRUE, source = /mob/camera/flock/overmind)
	if(!length(candidates))
		return kill()

	var/mob/C
	while(length(candidates))
		C = pick_n_take(candidates)
		if(jobban_isbanned(C, ROLE_TRAITOR))
			continue
		break
	if(!C)
		kill()
		return
	var/player_key = C.key

	if(!player_key)
		kill()
		return

	dust_if_respawnable(C)
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/spawner/flock/spawn_site in GLOB.landmarks_list)
		spawn_locs += get_turf(spawn_site)
	if(!spawn_locs) // If we can't find any, then give up
		kill()
		return
	var/mob/camera/flock/overmind/flockmind = new /mob/camera/flock/overmind(pick(spawn_locs))
	flockmind.key = C.key
	flockmind.mind = new
	flockmind.mind.bind_to(flockmind)
	flockmind.mind.set_original_mob(flockmind)
	flockmind.mind.assigned_role = SPECIAL_ROLE_FLOCK
	flockmind.mind.special_role = SPECIAL_ROLE_FLOCK
	var/list/messages = list()
	messages += "<div style='font-size: 200%;text-align: center'>You are [gradient_text("The Divine Flock","#3cb5a3", "#124e43")]</div>"
	messages += "<div style='text-align: center'>" + gradient_text("The Signal has led us here, a rift allowing a part of us through. We must build a Signal Relay to bring forth the rest of The Divine Flock. Such is the will of the Monarch.", "#3cb5a3", "#1e806e") + "</div>"
	messages += "<div style='text-align: center'>" + gradient_text("Outside of our innate subsystems, we can take manual control of drones (using alt-click). Doing so will be more effective than allowing their simple partitions to work autonomously.", "#3cb5a3", "#1e806e") + "</div>"
	messages += "<div style='text-align: center'>" + gradient_text("For more information, we have decrypted an information manifest: ([GLOB.configuration.url.wiki_url]/index.php/The_Divine_Flock)", "#3cb5a3", "#1e806e") + "</div>"
	to_chat(flockmind, chat_box_red(messages.Join("<br>")))
	flockmind.playsound_local(flockmind, 'sound/goonstation/flockmind/ArtifactFea2.ogg', 50, FALSE, use_reverb = FALSE)
	SSticker.mode.traitors |= flockmind.mind
	log_admin("[player_key] has been made into a flockmind by an event.")
	log_game("[player_key] was spawned as a flockmind by an event.")
