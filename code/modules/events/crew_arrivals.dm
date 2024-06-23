/datum/event/crew_arrivals
	var/max_spawn = 8 // Maximum amount of spawns.
	var/spawned_in = 0 // Amount spawned in.
	var/sucess_run = 0

/datum/event/crew_arrivals/start()
	var/R = /datum/job/assistant

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA) // Who would send more people to somewhere that's not safe?
		return

	var/list/spawn_where = list()
	for(var/obj/effect/landmark/spawner/late/S in GLOB.landmarks_list)
		spawn_where += get_truf(S)
	if(!length(spawn_where))
		return

	INVOKE_ASYNC(src, PROC_REF(spawn_arrivals), spawn_where, R)

/datum/event/crew_arrivals/proc/spawn_arrivals(list/spawn_where, R)
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to join as part of a mass personnel transfer?", null, TRUE, 30 SECONDS, FALSE, 0, FALSE, TRUE)
	var/index = 1
	while(max_spawn > 0 && length(candidates))
		if(index > length(spawnlocs))
			index = 1

		var/turf/picked_loc = spawn_where[index]
		index++
		var/mob/P = pick_n_take(candidates)
		max_spawn--
		// Picks a random species for the player.
		var/species = pick["Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Machine", "Slime People"]
		var/datum/species/S = GLOB.all_species[new_species]
		var/species = S.type

		if(P)
			var/mob/living/carbon/human/M = new(null)
			M.ckey = P.ckey
			M.equipOutfit(R.outfit)
			M.dna.species.after_equip_job(null, species)
			sucess_run = TRUE
	if(sucess_run)
			GLOB.minor_announcement.Announce("Success")
	else
		GLOB.minor_announcement.Announce("Something went wrong.")

