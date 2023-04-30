/datum/event/pirates
	var/highpop_trigger = 80
	var/spawncount = 5
	var/list/playercount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/pirates/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_pirates))

/datum/event/pirates/proc/spawn_pirates()
	log_world("Pirates have been spawned.")
	// Create a list of pirate spawn locations
	var/list/spawn_locations = list()
	for(var/spawn_point in GLOB.pirate_spawn)
		spawn_locations += spawn_point

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you wish to be considered for Space Pirates", ROLE_PIRATE, TRUE)
	if(!length(spawn_locations))
		message_admins("Warning: No suitable locations detected for spawning pirates!")
		return

	for(var/mob/dead/observer/C in candidates)
		world.log << "spawn_pirates() loop iteration, spawncount: [spawncount], spawn_locations: [length(spawn_locations)], candidates: [length(candidates)]"
		var/turf/location = pick_n_take(spawn_locations)
		C.remove_from_respawnable_list()
		var/mob/living/carbon/human/new_pirate = new(location) // Use the existing human type
		new_pirate.key = C.key
		new_pirate.forceMove(location)

		customize_pirate(new_pirate)
		equip_pirate(new_pirate)

		if(SSticker.mode)
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

/datum/event/pirates/proc/greet_pirate(pirate)
	to_chat(pirate, "<b>You are a space pirate, defend the data sipon at all cost and avoid leaving the ship.</b>")
	to_chat(pirate, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Ash_Walker)</span>")


/datum/event/pirates/proc/equip_pirate(mob/living/carbon/human/pirate, uplink_uses = 20)
	var/radio_freq = SYND_FREQ

	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate/alt(pirate)
	R.set_frequency(radio_freq)
	pirate.equip_to_slot_or_del(R, slot_l_ear)

	pirate.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(pirate), slot_w_uniform)
	pirate.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(pirate), slot_shoes)
	pirate.equip_or_collect(new /obj/item/clothing/gloves/combat(pirate), slot_gloves)
	pirate.equip_to_slot_or_del(new /obj/item/card/id/syndicate(pirate), slot_wear_id)
	pirate.equip_to_slot_or_del(new /obj/item/storage/backpack(pirate), slot_back)
	pirate.equip_to_slot_or_del(new /obj/item/gun/projectile/automatic/pistol(pirate), slot_belt)
	pirate.equip_to_slot_or_del(new /obj/item/storage/box/survival_syndi(pirate.back), slot_in_backpack)
	pirate.equip_to_slot_or_del(new /obj/item/pinpointer/nukeop(pirate), slot_wear_pda)
	var/obj/item/radio/uplink/nuclear/U = new /obj/item/radio/uplink/nuclear(pirate)
	U.hidden_uplink.uplink_owner="[pirate.key]"
	U.hidden_uplink.uses = uplink_uses
	pirate.equip_to_slot_or_del(U, slot_in_backpack)

	pirate.faction |= "syndicate"
	pirate.update_icons()
	return 1
