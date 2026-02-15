/datum/event/space_ninja
	name = "Space Ninja"
	role_weights = list(ASSIGNMENT_SECURITY = 2)
	//role_requirements = list(ASSIGNMENT_CREW = 20, ASSIGNMENT_SECURITY = 2)
	nominal_severity = EVENT_LEVEL_MAJOR

/datum/event/space_ninja/start()
	INVOKE_ASYNC(src, PROC_REF(poll_ninja))

/datum/event/space_ninja/proc/poll_ninja(list/potential_ninjas)
	var/list/candidates = list()
	if(!potential_ninjas)
		candidates = SSghost_spawns.poll_candidates("Do you want to play as a space ninja?", ROLE_NINJA, TRUE)
	else
		candidates = potential_ninjas
	if(!length(candidates))
		kill()
		return
	var/mob/new_ninja
	while(length(candidates))
		new_ninja = pick_n_take(candidates)
		if(jobban_isbanned(new_ninja, ROLE_TRAITOR))
			continue
		break
	if(!new_ninja)
		kill()
		return

	var/gender_pref = input_async(new_ninja, "Please select a gender (10 seconds):", list("Male", "Female"))
	addtimer(CALLBACK(src, PROC_REF(get_species), candidates, new_ninja, gender_pref), 10 SECONDS)

/datum/event/space_ninja/proc/get_species(list/potential_ninjas, mob/new_ninja, datum/async_input/gender_pref)
	gender_pref.close()
	var/sel_gender = gender_pref.result
	if(!sel_gender) // Player was AFK and did not select a gender
		poll_ninja(potential_ninjas)
		return
	var/species_pref = input_async(new_ninja, "Please select a species (10 seconds):", list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Skkulakin", "Vox", "Slime", "Machine", "Random"))
	addtimer(CALLBACK(src, PROC_REF(create_ninja), potential_ninjas, new_ninja, sel_gender, species_pref), 10 SECONDS)

/datum/event/space_ninja/proc/create_ninja(list/potential_ninjas, mob/new_ninja, sel_gender, datum/async_input/species_pref)
	species_pref.close()
	var/sel_species = species_pref.result
	if(!sel_species) // Player was AFK and did not select a species
		poll_ninja(potential_ninjas)
		return
	if(!new_ninja || !new_ninja.client)
		poll_ninja(potential_ninjas)
		return

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/spawner/ninja/N in GLOB.landmarks_list)
		spawn_locs += get_turf(N)
	if(!length(spawn_locs))
		message_admins("Unable to spawn ninja - no valid spawn locations.")
		return

	var/mob/living/carbon/human/M = new(pick(spawn_locs))

	M.ckey = new_ninja.ckey
	dust_if_respawnable(new_ninja)

	if(sel_gender == "Male")
		M.change_gender(MALE)
		M.change_body_type(MALE)
	else
		M.change_gender(FEMALE)
		M.change_body_type(FEMALE)

	if(sel_species == "Random")
		sel_species = pick("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Skkulakin", "Vox", "Slime", "Machine")
	var/datum/species/S = GLOB.all_species[sel_species]
	var/species = S.type
	M.set_species(species, TRUE)
	M.dna.ready_dna(M)
	M.cleanSE()
	M.overeatduration = 0
	M.age = rand(23, 35)
	M.regenerate_icons()

	M.mind = new
	M.mind.bind_to(M)
	M.mind.set_original_mob(M)
	M.mind.make_space_ninja()
