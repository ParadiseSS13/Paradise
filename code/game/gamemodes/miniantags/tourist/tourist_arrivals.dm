/datum/event/tourist_arrivals

	/// Maximum number of spawns.
	var/max_spawn = 10
	var/sucess_run = 0
	/// Number of tots spawned in
	var/tot_number = 0
	/// Number of player spawned in
	var/spawned_in = 0

/datum/event/tourist_arrivals/start()
	var/datum/tourist/T = new /datum/tourist/C
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA) // Who would send more people to somewhere that's not safe?
		return

	var/list/spawn_where = list()
	for(var/obj/effect/landmark/start/S in GLOB.landmarks_list)
		spawn_where += get_turf(S)
	if(!length(spawn_where))
		return

	INVOKE_ASYNC(src, PROC_REF(spawn_arrivals), spawn_where, T)

/datum/event/tourist_arrivals/proc/spawn_arrivals(list/spawn_where, datum/tourist/T)
	var/list/candidates = SSghost_spawns.poll_candidates("Testing", null, FALSE, 30 SECONDS, TRUE)
	var/index = 1
	while(max_spawn > 0 && length(candidates))
		if(index > length(spawn_where))
			index = 1

		var/turf/picked_loc = spawn_where[index]
		index++
		var/mob/P = pick_n_take(candidates)
		max_spawn--
		if(P)
			var/mob/living/carbon/human/M = new T.tourist_species(picked_loc)
			var/objT = pick(subtypesof(/datum/objective/tourist/))
			var/datum/objective/tourist/O = new objT()
			M.ckey = P.ckey
			if(prob(20) && tot_number < 3)
				tot_number++
				M.mind.add_antag_datum(/datum/antagonist/traitor)

			if(M.mind.special_role != SPECIAL_ROLE_TRAITOR)
				M.mind.add_mind_objective(O)

			M.equipOutfit(T.tourist_outfit)
			M.dna.species.after_equip_job(null, M)
			sucess_run = TRUE
			spawned_in++
	if(sucess_run)
		GLOB.minor_announcement.Announce("Success")
	else
		GLOB.minor_announcement.Announce("Something went wrong")

/datum/tourist
	var/tourist_outfit
	var/tourist_species

/datum/tourist/C
	tourist_outfit = /datum/outfit/job/assistant
	tourist_species = /mob/living/carbon/human

