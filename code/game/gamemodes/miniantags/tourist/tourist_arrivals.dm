/datum/event/tourist_arrivals

	/// Maximum number of spawns.
	var/max_spawn = 10
	/// If the event ran successfully
	var/success_run
	/// Number of tots spawned in
	var/tot_number = 0
	/// Number of players spawned in
	var/spawned_in = 0
	/// Number of crew
	var/crew_count = 0
	/// Number of antags
	var/antag_count = 0
	/// Antag limit defined by crew/10 + 1
	var/max_antag = 0
	/// Chance of being antag
	var/chance = 20

/datum/event/tourist_arrivals/setup()
	// Getting a list of players that are logged in and not dead.
	// Checking if they're an antag or not and defining a 'max_antag' number.
	for(var/mob/living/player in GLOB.mob_list)
		if(player.mind && player.stat != DEAD)
			crew_count++
			if(player.mind.special_role)
				antag_count++
				continue
	max_antag = round(crew_count / 10, 1) + 1
	if(SSticker && istype(SSticker.mode, /datum/game_mode/extended))
		chance = 100

/datum/event/tourist_arrivals/start()
	// Let's just avoid trouble, sending people into those is probably bad.
	if(GAMEMODE_IS_CULT || GAMEMODE_IS_WIZARD || GAMEMODE_IS_NUCLEAR)
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + 1 MINUTES
		log_debug("Tourist Arrivals roll canceled due to gamemode. Rolling another midround in 60 seconds.")
		return
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA) // Who would send more people to somewhere that's not safe?
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + 1 MINUTES
		log_debug("Tourist Arrivals roll canceled due to heightened alert. Rolling another midround in 60 seconds.")
		return

	INVOKE_ASYNC(src, PROC_REF(spawn_arrivals))

/datum/event/tourist_arrivals/proc/spawn_arrivals()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Tourist?", null, TRUE)
	// We'll keep spawning new tourists until we hit the max_spawn cap of tourists.
	while(max_spawn > 0 && length(candidates))
		var/turf/picked_loc = pick(GLOB.latejoin)
		// Taking a random player from the candidate list.
		var/mob/P = pick_n_take(candidates)
		max_spawn--
		var/datum/tourist/T = pick(/datum/tourist/human,
								/datum/tourist/unathi,
								/datum/tourist/vulp,
								/datum/tourist/ipc,
								/datum/tourist/skrell,
								/datum/tourist/grey,
								/datum/tourist/nian)
		if(!istype(P))
			continue
		var/mob/living/carbon/human/M = new T.tourist_species(picked_loc)
		// Picking a random objective, as all objectives are a subtype of /objective/tourist.
		var/obj_tourist = pick(subtypesof(/datum/objective/tourist))
		var/datum/objective/tourist/O = new obj_tourist()
		// Handles outfit, account and other stuff.
		M.ckey = P.ckey
		M.dna.species.after_equip_job(null, M)
		M.age = rand(21, 50)
		if(prob(50))
			M.change_gender(FEMALE)
		set_appearance(M)
		M.equipOutfit(T.tourist_outfit)
		GLOB.data_core.manifest_inject(M) // Proc checks if they have a special role before adding to the manifest, if they do, they aren't added. This needs to be done before adding the special role.
		M.mind.special_role = SPECIAL_ROLE_TOURIST
		// Rolls a 20% probability, checks if 3 tourists have been made into tot and check if there's space for a new tot!
		// If any is false, we don't make a new tourist tot
		if(prob(chance) && tot_number < 3 && antag_count < max_antag && (ROLE_TRAITOR in M.client.prefs.be_special) && !jobban_isbanned(M, ROLE_TRAITOR))
			if(player_old_enough_antag(M.client, ROLE_TRAITOR))
				tot_number++
				M.mind.add_antag_datum(/datum/antagonist/traitor)

		// If they're a tot, they don't get tourist objectives neither the tourist greeting!
		if(M.mind.special_role != SPECIAL_ROLE_TRAITOR)
			M.mind.add_mind_objective(O)
			greeting(M)
		success_run = TRUE
		spawned_in++
	if(success_run)
		log_debug("Tourist event made: [tot_number] traitors.")
		var/raffle_name = pick("Galactic Getaway Raffle", "Cosmic Jackpot Raffle", "Nebula Nonsense Raffle", "Greytide Giveaway Raffle", "Toolbox Treasure Raffle")
		GLOB.minor_announcement.Announce("The lucky winners of the Nanotrasen raffle, 'Nanotrasen [raffle_name],' are arriving at [station_name()] shortly. Please welcome them warmly, they'll be staying with you until the end of your shift!")

// Greets the player, announces objectives!
/datum/event/tourist_arrivals/proc/greeting(mob/living/carbon/human/M)
	var/list/greeting = list()
	greeting.Add("<span class='boldnotice'><font size=3>You are a tourist!</font></span>")
	greeting.Add("<b>You were chosen as a lucky winner of Nanotrasen's exclusive raffle! Winning a visit to a nearby Nanotrasen Research Station!</b>")
	greeting.Add("<b>Enjoy your exclusive tour and make the most of your time exploring our state-of-the-art facilities!</b>")
	greeting.Add("<span class='notice'><br>Your current objectives are:</span>")
	greeting.Add(M.mind.prepare_announce_objectives(FALSE))
	to_chat(M, chat_box_green(greeting.Join("<br>")))

// All of this code down here is from ert.dm.
/datum/event/tourist_arrivals/proc/set_appearance(mob/living/carbon/human/M)

	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	var/hair_c = pick("#8B4513", "#000000", "#FF4500", "#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000", "#8B4513", "1E90FF") // Black, brown, blue
	var/skin_tone = rand(-120, 20)

	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	M.change_eye_color(eye_c)
	M.s_tone = skin_tone
	head_organ.h_style = random_hair_style(M.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.dna.species.name)

	M.regenerate_icons()
	M.update_body()
	M.update_dna()

// Tourist datum stuff, mostly being species and outfit.
/datum/tourist
	var/tourist_outfit
	var/tourist_species

/datum/tourist/human
	tourist_species = /mob/living/carbon/human
	tourist_outfit = /datum/outfit/admin/tourist

/datum/tourist/unathi
	tourist_species = /mob/living/carbon/human/unathi
	tourist_outfit = /datum/outfit/admin/tourist

/datum/tourist/vulp
	tourist_species = /mob/living/carbon/human/vulpkanin
	tourist_outfit = /datum/outfit/admin/tourist

/datum/tourist/ipc
	tourist_species = /mob/living/carbon/human/machine
	tourist_outfit = /datum/outfit/admin/tourist

/datum/tourist/skrell
	tourist_species = /mob/living/carbon/human/skrell
	tourist_outfit = /datum/outfit/admin/tourist

/datum/tourist/grey
	tourist_species = /mob/living/carbon/human/grey
	tourist_outfit = /datum/outfit/admin/tourist

/datum/tourist/nian
	tourist_species = /mob/living/carbon/human/moth
	tourist_outfit = /datum/outfit/admin/tourist

