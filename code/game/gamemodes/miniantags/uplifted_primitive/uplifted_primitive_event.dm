/datum/event/spawn_uplifted_primitive
	name = "Uplifted Primitive Spawn"
	nominal_severity = EVENT_LEVEL_MAJOR

	/// The list of species this event can spawn uplifted primitives of.
	var/list/allowed_species = list(
		/datum/species/monkey,
	)

/datum/event/spawn_uplifted_primitive/start()
	INVOKE_ASYNC(src, PROC_REF(make_uplifted_primitive))

/datum/event/spawn_uplifted_primitive/proc/make_uplifted_primitive()
	// disallow species which have existing players
	var/list/currently_allowed_species = allowed_species - SSticker.mode.uplifted_primitives
	if(!length(currently_allowed_species))
		message_admins("Warning: The uplifted primitives event could not be triggered because all allowed species already have an uplifted team.")
		kill()
		return
	var/datum/species/selected_species = pick(currently_allowed_species)

	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as an uplifted primitive?", ROLE_UPLIFTED_PRIMITIVE, TRUE, source = /obj/structure/uplifted_primitive/nest)
	if(!length(candidates))
		message_admins("no candidates were found for the uplifted primitive event.")
		kill()
		return

	var/mob/C = pick(candidates)
	var/key = C.key

	if(!key)
		kill()
		return

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning uplifted primitives. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
		if(!length(vents))
			message_admins("Warning: No vents detected for spawning uplifted primitives at all!")
			kill()
			return

	var/obj/selected_vent = pick(vents)

	dust_if_respawnable(C)

	var/datum/mind/player_mind = new /datum/mind(key)
	var/mob/living/carbon/human/primitive = new(selected_vent, selected_species)

	player_mind.active = TRUE
	player_mind.transfer_to(primitive)
	player_mind.add_antag_datum(/datum/antagonist/uplifted_primitive)

	SSticker.mode.uplifted_teams[selected_species].guaranteed_sentient_spawns = 2

	primitive.add_ventcrawl(selected_vent)

	message_admins("[key_name_admin(primitive)] has been made into an uplifted [initial(primitive.name)] by an event.")
	log_game("[key_name_admin(primitive)] was spawned as an uplifted [initial(primitive.name)] by an event.")
