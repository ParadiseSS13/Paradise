//Note to future generations: I didn't write this god-awful code I just ported it to the event system and tried to make it less moon-speaky.
//Don't judge me D; ~Carn //Maximum judging occuring - Remie.
// Tut tut Remie, let's keep our comments constructive. - coiax

/*

Contents:
- The Ninja "Random" Event
- Ninja creation code
*/

/datum/event/ninja
	var/helping_station
	var/spawn_loc
	var/give_objectives = TRUE

/datum/event/ninja/setup()
	helping_station = rand(0, 1)

/datum/event/ninja/start()
	//spawn Ninja
	processing = 0 //so it won't fire again in next tick

	//selecting a spawn_loc
	if(!spawn_loc)
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("ninjaspawn","carpspawn")
						spawn_locs += L.loc
		if(!spawn_locs.len)
			return kill()
		spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return

	//selecting a candidate player
	var/list/candidates = get_candidate_ghosts(ROLE_NINJA)
	if(!candidates.len)
		message_admins("Ninja event failed to find players.")

	var/mob/dead/selected_candidate = pick_n_take(candidates)
	var/key = selected_candidate.key

	//Prepare ninja player mind
	var/datum/mind/Mind = create_ninja_mind(key)
	Mind.active = TRUE

	//generate objectives - You'll generally get 6 objectives (Ninja is meant to be hardmode!)
	var/list/possible_targets = list()
	for(var/datum/mind/M in ticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.special_role)
					possible_targets[M] = 0						//bad-guy
				else if(M.assigned_role in command_positions)
					possible_targets[M] = 1						//good-guy

	var/list/objectives = list(1, 2, 3, 4)
	while(give_objectives && Mind.objectives.len < 6)
		switch(pick_n_take(objectives))
			if(1)	//research
				var/datum/objective/download/O = new /datum/objective/download()
				O.owner = Mind
				O.gen_amount_goal()
				Mind.objectives += O

			if(2)	//steal
				var/datum/objective/steal/O = new /datum/objective/steal()
				O.owner = Mind
				Mind.objectives += O

			if(3)	//protect/kill
				if(!possible_targets.len)
					continue
				var/index = rand(1, possible_targets.len)
				var/datum/mind/M = possible_targets[index]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(index, index + 1)

				if(is_bad_guy ^ helping_station)			//kill (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/assassinate/O = new /datum/objective/assassinate()
					O.owner = Mind
					O.target = M
					O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
					Mind.objectives += O
				else										//protect
					var/datum/objective/protect/O = new /datum/objective/protect()
					O.owner = Mind
					O.target = M
					O.explanation_text = "Protect \the [M.current.real_name], the [M.assigned_role], from harm."
					Mind.objectives += O
			if(4)	//debrain/capture
				if(!possible_targets.len)
					continue
				var/selected = rand(1, possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(selected, selected + 1)

				if(is_bad_guy ^ helping_station)			//debrain (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/debrain/O = new /datum/objective/debrain()
					O.owner = Mind
					O.target = M
					O.explanation_text = "Steal the brain of [M.current.real_name]."
					Mind.objectives += O
				else										//capture
					var/datum/objective/capture/O = new /datum/objective/capture()
					O.owner = Mind
					O.gen_amount_goal()
					Mind.objectives += O
			else
				break

	//Add a survival objective since it's usually broad enough for any round type.
	if(give_objectives)
		var/datum/objective/O = new /datum/objective/survive()
		O.owner = Mind
		Mind.objectives += O

	//add some RP-fluff
	Mind.store_memory("I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	Mind.store_memory("Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	Mind.store_memory("Officially, [helping_station ? "Nanotrasen" : "The Syndicate"] is my employer.")

	//spawn the ninja and assign the candidate
	var/mob/living/carbon/human/Ninja = create_space_ninja(spawn_loc)
	Mind.transfer_to(Ninja)

	if(Ninja.mind != Mind)			//something has gone wrong!
		log_runtime(EXCEPTION("Ninja created with incorrect mind"))
		return

	Ninja << sound('sound/effects/ninja_greeting.ogg') //so ninja you probably wouldn't even know if you were made one
	ticker.mode.update_ninja_icons_added(Ninja)
	message_admins("[key_name_admin(Ninja)] has been made into a ninja by an event.")
	log_game("[key_name(Ninja)] was spawned as a ninja by an event.")


//=======//NINJA CREATION PROCS//=======//

/proc/create_space_ninja(spawn_loc)
	var/mob/living/carbon/human/new_ninja = new(spawn_loc)
	var/datum/preferences/A = new() //Randomize appearance for the ninja.
	A.real_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	A.copy_to(new_ninja)
	new_ninja.equipOutfit(/datum/outfit/ninja)
	return new_ninja


/proc/create_ninja_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = "Space Ninja"
	Mind.special_role = "Space Ninja"
	ticker.mode.traitors |= Mind			//Adds them to current traitor list. Which is really the extra antagonist list.
	return Mind

/datum/game_mode/proc/update_ninja_icons_added(mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = huds[ANTAG_HUD_NINJA]
	ninjahud.join_hud(ninja)
	set_antag_hud(ninja, "ninja")

/datum/game_mode/proc/update_ninja_icons_removed(datum/mind/ninja_mind)
	var/datum/atom_hud/antag/ninjahud = huds[ANTAG_HUD_NINJA]
	ninjahud.leave_hud(ninja_mind.current)
	set_antag_hud(ninja_mind.current, null)