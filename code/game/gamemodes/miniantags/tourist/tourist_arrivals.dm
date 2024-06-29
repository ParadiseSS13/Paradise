/datum/event/tourist_arrivals

	/// Maximum number of spawns.
	var/max_spawn = 10
	/// If the event ran successfully
	var/sucess_run = null
	/// Number of tots spawned in
	var/tot_number = 0
	/// Number of player spawned in
	var/spawned_in = 0

/datum/event/tourist_arrivals/start()
	var/datum/tourist/T = new /datum/tourist/C
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA) // Who would send more people to somewhere that's not safe?
		return

	INVOKE_ASYNC(src, PROC_REF(spawn_arrivals), T)

/datum/event/tourist_arrivals/proc/spawn_arrivals(datum/tourist/T)
	var/list/candidates = SSghost_spawns.poll_candidates("Testing", null, FALSE, 30 SECONDS, TRUE)
	while(max_spawn > 0 && length(candidates))
		var/turf/picked_loc = pick(GLOB.latejoin)
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
				greeting(M)
			M.equipOutfit(T.tourist_outfit)
			M.dna.species.after_equip_job(null, M)
			sucess_run = TRUE
			spawned_in++
	if(sucess_run)
		var/raffle_name = pick("Galactic Getaway Raffle", "Cosmic Jackpot Raffle", "Nebula Nonsense Raffle", "Greytide Giveaway Raffle", "Toolbox Treasure Raffle")
		GLOB.minor_announcement.Announce("The lucky winners of the Nanotrasen raffle, 'Nanotrasen [raffle_name],' are arriving at [station_name()] shortly. Please welcome them warmly and assist them in any way possible during their exclusive tour.")
	else
		message_admins("Oops! Something went wrong with the event, make sure to open a github issue if you see this!")

/datum/event/tourist_arrivals/proc/greeting(mob/living/carbon/human/M)
	var/list/greeting = list()
	greeting.Add("<span class='boldnotice'><font size=3>You are a tourist!</font></span>")
	greeting.Add("<b>You were chosen as a lucky winner of Nanotrasen's exclusive raffle! Winning a visit to a nearby Nanotrasen Research Station!</b>")
	greeting.Add("<b>Enjoy your exclusive tour and make the most of your time exploring our state-of-the-art facilities!</b>")
	greeting.Add("<span class='notice'><br>Your current objectives are:</span>")
	greeting.Add(M.mind.prepare_announce_objectives(FALSE))
	to_chat(M, chat_box_green(greeting.Join("<br>")))

/datum/tourist
	var/tourist_outfit
	var/tourist_species

/datum/tourist/C
	tourist_outfit = /datum/outfit/admin/tourist
	tourist_species = /mob/living/carbon/human

