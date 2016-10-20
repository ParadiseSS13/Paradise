//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//Few global vars to track the blob
var/list/blobs = list()
var/list/blob_cores = list()
var/list/blob_nodes = list()


/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"

	required_players = 10
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = list("Cyborg", "AI")

	var/declared = 0
	var/burst = 0

	var/cores_to_spawn = 1
	var/players_per_core = 30
	var/blob_point_rate = 3

	var/blobwincount = 350

	var/list/infected_crew = list()

/datum/game_mode/blob/pre_setup()

	var/list/possible_blobs = get_players_for_role(ROLE_BLOB)

	// stop setup if no possible traitors
	if(!possible_blobs.len)
		return 0

	cores_to_spawn = max(round(num_players()/players_per_core, 1), 1)

	blobwincount = initial(blobwincount) * cores_to_spawn


	for(var/j = 0, j < cores_to_spawn, j++)
		if(!possible_blobs.len)
			break
		var/datum/mind/blob = pick(possible_blobs)
		infected_crew += blob
		blob.special_role = SPECIAL_ROLE_BLOB
		blob.restricted_roles = restricted_jobs
		log_game("[blob.key] (ckey) has been selected as a Blob")
		possible_blobs -= blob

	if(!infected_crew.len)
		return 0

	return 1

/datum/game_mode/blob/proc/get_blob_candidates()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(!player.stat && player.mind && !player.mind.special_role && !jobban_isbanned(player, "Syndicate") && (ROLE_BLOB in player.client.prefs.be_special))
			candidates += player
	return candidates


/datum/game_mode/blob/proc/blobize(var/mob/living/carbon/human/blob)
	var/datum/mind/blobmind = blob.mind
	if(!istype(blobmind))
		return 0
	infected_crew += blobmind
	blobmind.special_role = SPECIAL_ROLE_BLOB
	log_game("[blob.key] (ckey) has been selected as a Blob")
	greet_blob(blobmind)
	to_chat(blob, "<span class='userdanger'>You feel very tired and bloated!  You don't have long before you burst!</span>")
	spawn(600)
		burst_blob(blobmind)
	return 1

/datum/game_mode/blob/proc/make_blobs(var/count)
	var/list/candidates = get_blob_candidates()
	var/mob/living/carbon/human/blob = null
	count=min(count, candidates.len)
	for(var/i = 0, i < count, i++)
		blob = pick(candidates)
		candidates -= blob
		blobize(blob)
	return count



/datum/game_mode/blob/announce()
	to_chat(world, "<B>The current game mode is - <font color='green'>Blob</font>!</B>")
	to_chat(world, "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>")
	to_chat(world, "You must kill it all while minimizing the damage to the station.")


/datum/game_mode/blob/proc/greet_blob(var/datum/mind/blob)
	to_chat(blob.current, "<span class='userdanger'>You are infected by the Blob!</span>")
	to_chat(blob.current, "<b>Your body is ready to give spawn to a new blob core which will eat this station.</b>")
	to_chat(blob.current, "<b>Find a good location to spawn the core and then take control and overwhelm the station!</b>")
	to_chat(blob.current, "<b>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</b>")
	to_chat(blob.current, "<b>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</b>")
	return

/datum/game_mode/blob/proc/show_message(var/message)
	for(var/datum/mind/blob in infected_crew)
		to_chat(blob.current, message)

/datum/game_mode/blob/proc/burst_blobs()
	for(var/datum/mind/blob in infected_crew)
		burst_blob(blob)

/datum/game_mode/blob/proc/burst_blob(var/datum/mind/blob, var/warned=0)
	var/client/blob_client = null
	var/turf/location = null

	if(iscarbon(blob.current))
		var/mob/living/carbon/C = blob.current
		if(directory[ckey(blob.key)])
			blob_client = directory[ckey(blob.key)]
			location = get_turf(C)
			if(!is_station_level(location.z) || istype(location, /turf/space))
				if(!warned)
					to_chat(C, "<span class='userdanger'>You feel ready to burst, but this isn't an appropriate place!  You must return to the station!</span>")
					message_admins("[key_name_admin(C)] was in space when the blobs burst, and will die if he doesn't return to the station.")
					spawn(300)
						burst_blob(blob, 1)
				else
					burst++
					log_admin("[key_name(C)] was in space when attempting to burst as a blob.")
					message_admins("[key_name_admin(C)] was in space when attempting to burst as a blob.")
					C.gib()
					make_blobs(1)
					check_finished() //Still needed in case we can't make any blobs

			else if(blob_client && location)
				burst++
				C.gib()
				var/obj/effect/blob/core/core = new(location, 200, blob_client, blob_point_rate)
				if(core.overmind && core.overmind.mind)
					core.overmind.mind.name = blob.name
					infected_crew -= blob
					infected_crew += core.overmind.mind
					core.overmind.mind.special_role = SPECIAL_ROLE_BLOB_OVERMIND

/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in infected_crew)
		greet_blob(blob)

	if(shuttle_master)
		shuttle_master.emergencyNoEscape = 1

	spawn(0)

		var/wait_time = rand(waittime_l, waittime_h)

		sleep(wait_time)

		send_intercept(0)

		sleep(100)

		show_message("<span class='userdanger'>You feel tired and bloated.</span>")

		sleep(wait_time)

		show_message("<span class='userdanger'>You feel like you are about to burst.</span>")

		sleep(wait_time / 2)

		burst_blobs()

		// Stage 0
		sleep(wait_time)
		stage(0)

		// Stage 1
		sleep(wait_time)
		stage(1)

		// Stage 2
		sleep(30000)
		stage(2)

	return ..()

/datum/game_mode/blob/proc/stage(var/stage)

	switch(stage)
		if(0)
			send_intercept(1)
			declared = 1

		if(1)
			command_announcement.Announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')

		if(2)
			send_intercept(2)

	return
