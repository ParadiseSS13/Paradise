/datum/event/pirates
	var/highpop_trigger = 80
	var/spawncount = 5
	var/list/playercount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/pirates/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_pirates))

/datum/event/pirates/proc/spawn_pirates()
	world.log << "spawn_pirates() called"
	// Create a list of pirate spawn locations
	var/list/spawn_locations = list()
	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/L = thing
		if(istype(L, /obj/effect/landmark/spawner/pirate))
			spawn_locations += L

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for Space Pirates", ROLE_PIRATE, TRUE)
	if(!length(spawn_locations))
		message_admins("Warning: No suitable locations detected for spawning pirates!")
		return

	while(spawncount && length(spawn_locations) && length(candidates))
		world.log << "spawn_pirates() loop iteration, spawncount: [spawncount], spawn_locations: [length(spawn_locations)], candidates: [length(candidates)]"
		var/turf/location = pick_n_take(spawn_locations)
		var/mob/dead/observer/C = pick_n_take(candidates)
		if(C)
			C.remove_from_respawnable_list()
			var/mob/living/carbon/human/new_pirate = new(location) // Use the existing human type
			new_pirate.key = C.key
			new_pirate.forceMove(location)

			customize_pirate(new_pirate)

			if(SSticker && SSticker.mode)
				SSticker.mode.pirates += new_pirate.mind

			spawncount--
			successSpawn = TRUE

/datum/event/pirates/proc/customize_pirate(mob/living/carbon/human/pirate)
	pirate.set_species(/datum/species/human, TRUE)
	pirate.dna.ready_dna(pirate)
	pirate.dna.species.create_organs(pirate)
	pirate.cleanSE()

	var/obj/item/organ/external/head/head_organ = pirate.get_organ("head")
	var/hair_c = pick("#8B4513","#000000","#FF4500","#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000","#8B4513","1E90FF") // Black, brown, blue
	var/skin_tone = pick(-50, -30, -10, 0, 0, 0, 10) // Caucasian/black
	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	pirate.change_eye_color(eye_c)
	pirate.s_tone = skin_tone
	head_organ.h_style = random_hair_style(pirate.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(pirate.gender, head_organ.dna.species.name)
	pirate.body_accessory = null
	pirate.regenerate_icons()
	pirate.update_body()
