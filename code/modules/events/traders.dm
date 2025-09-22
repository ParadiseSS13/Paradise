GLOBAL_LIST_INIT(unused_trade_stations, list("sol"))

// Traders event.
// Heavily copy-pasted from "heist" gamemode.

/datum/event/traders
	var/success_spawn = 0
	var/station = null
	var/spawn_count = 2
	var/list/trader_objectives = list()

/datum/event/traders/setup()
	if(length(GLOB.unused_trade_stations))
		station = pick_n_take(GLOB.unused_trade_stations)

/datum/event/traders/fake_announce()
	. = TRUE
	var/datum/traders/T = pick(/datum/traders/sol,
								/datum/traders/cyber,
								/datum/traders/commie,
								/datum/traders/unathi,
								/datum/traders/vulp,
								/datum/traders/ipc,
								/datum/traders/vox,
								/datum/traders/skrell,
								/datum/traders/grey,
								/datum/traders/nian)

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		GLOB.minor_announcement.Announce("A trading shuttle from [T.trader_location] has been denied docking permission due to the heightened security alert aboard [station_name()].", "Trader Shuttle Docking Request Refused", 'sound/AI/traderdeny.ogg')
		return
	GLOB.minor_announcement.Announce("A trading shuttle from [T.trader_location] has been granted docking permission at [station_name()] arrivals port 4.", "Trader Shuttle Docking Request Accepted", 'sound/AI/tradergranted.ogg')


/datum/event/traders/start()
	if(!station) // If there are no unused stations, just no.
		return

	var/datum/traders/T = pick(/datum/traders/sol,
								/datum/traders/cyber,
								/datum/traders/commie,
								/datum/traders/unathi,
								/datum/traders/vulp,
								/datum/traders/ipc,
								/datum/traders/vox,
								/datum/traders/skrell,
								/datum/traders/grey,
								/datum/traders/nian)

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		GLOB.minor_announcement.Announce("A trading shuttle from [T.trader_location] has been denied docking permission due to the heightened security alert aboard [station_name()].", "Trader Shuttle Docking Request Refused", 'sound/AI/traderdeny.ogg')
		// if the docking request was refused, fire another major event in 60 seconds
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return

	//Get the list of spawn locations for traders
	var/list/spawnlocs = list()
	for(var/obj/effect/landmark/spawner/trader/S in GLOB.landmarks_list)
		spawnlocs += get_turf(S)
	if(!length(spawnlocs))
		return

	trader_objectives = forge_trader_objectives()

	INVOKE_ASYNC(src, PROC_REF(spawn_traders), spawnlocs, T)

/datum/event/traders/proc/spawn_traders(list/spawnlocs, datum/traders/T)
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [T.trader_type] Trader?", ROLE_TRADER, TRUE)
	var/index = 1
	while(spawn_count > 0 && length(candidates))
		if(index > length(spawnlocs))
			index = 1

		var/turf/picked_loc = spawnlocs[index]
		index++
		var/mob/C = pick_n_take(candidates)
		spawn_count--
		if(C)
			var/mob/living/carbon/human/M = new T.trader_species(picked_loc)
			M.ckey = C.ckey // must be before equipOutfit, or that will runtime due to lack of mind
			dust_if_respawnable(C)
			M.equipOutfit(T.trader_outfit)
			M.add_language("Tradeband")
			M.dna.species.after_equip_job(null, M)
			for(var/datum/objective/O in trader_objectives)
				M.mind.objective_holder.add_objective(O) // traders dont have a team, so we manually have to add this objective to all of their minds, without setting an owner
			M.mind.offstation_role = TRUE
			greet_trader(M, T)
			success_spawn = TRUE
	if(success_spawn)
		var/template = new T.ship_template()
		SSshuttle.set_trader_shuttle(template)
		GLOB.minor_announcement.Announce("A trading shuttle from [T.trader_location] has been granted docking permission at [station_name()] arrivals port 4.", "Trader Shuttle Docking Request Accepted", 'sound/AI/tradergranted.ogg')
		// Get the list of spawn locations for company specific items, spawn gear
		for(var/obj/effect/landmark/spawner/tradergearminor/A in GLOB.landmarks_list)
			var/obj/structure/closet/locker = new /obj/structure/closet(get_turf(A))
			locker.open()
			new T.trader_minor_special(locker)
			locker.close()

		for(var/obj/effect/landmark/spawner/tradergearmajor/B in GLOB.landmarks_list)
			var/obj/structure/closet/locker = new /obj/structure/closet(get_turf(B))
			locker.open()
			new T.trader_major_special(locker)
			locker.close()
	else
		GLOB.unused_trade_stations += station // Return the station to the list of usable stations.

/datum/event/traders/proc/greet_trader(mob/living/carbon/human/M, datum/traders/T)
	var/list/messages = list()
	messages.Add("<span class='boldnotice'>You are a trader!</span> <span class='notice'>You are currently docked at [T.dock_site].<br>You are about to trade with [station_name()].</span><br>")
	messages.Add(M.mind.prepare_announce_objectives())
	to_chat(M, chat_box_green(messages.Join("<br>")))
	M.create_log(MISC_LOG, "[M] was made into a [T.trader_type] Trader")

/datum/event/traders/proc/forge_trader_objectives()
	var/list/objs = list()

	objs += new /datum/objective/trade/plasma
	objs += new /datum/objective/trade/credits

	return objs

//Datums that handle the various announcements, species, outfits, and item lists.
/datum/traders
	/// What faction the trader is
	var/trader_type
	/// Where the traders originate from
	var/trader_location
	/// What specific station the traders came from
	var/dock_site
	/// What species the traders consist of
	var/trader_species
	/// What outfit do the traders spawn with
	var/trader_outfit
	/// What standard faction gear do they start with
	var/trader_minor_special
	/// What big ticket faction gear do they start with
	var/trader_major_special
	/// The type of shuttle the traders get
	var/datum/map_template/shuttle/ship_template

/datum/traders/sol
	trader_type = "Trans-Solar Federation"
	trader_location = "Kayani Station"
	dock_site = "Kayani Station"
	trader_species = /mob/living/carbon/human
	trader_outfit = /datum/outfit/admin/trader/sol
	trader_minor_special = /obj/effect/spawner/random/traders/federation_minor
	trader_major_special = /obj/effect/spawner/random/traders/federation_major
	ship_template = /datum/map_template/shuttle/trader/sol

/datum/traders/cyber
	trader_type = "Cybersun Industries"
	trader_location = "-=ERROR: Unregistered Station Charter=-"
	dock_site = "an undercover robotics factory"
	trader_species = /mob/living/carbon/human
	trader_outfit = /datum/outfit/admin/trader/cyber
	trader_minor_special = /obj/effect/spawner/random/traders/cybersun_minor
	trader_major_special = /obj/effect/spawner/random/traders/cybersun_major
	ship_template = /datum/map_template/shuttle/trader/cybersun

/datum/traders/commie
	trader_type = "USSP"
	trader_location = "Belastrav"
	dock_site = "Belastrav Station"
	trader_species = /mob/living/carbon/human
	trader_outfit = /datum/outfit/admin/trader/commie
	trader_minor_special = /obj/effect/spawner/random/traders/ussp_minor
	trader_major_special = /obj/effect/spawner/random/traders/ussp_major
	ship_template = /datum/map_template/shuttle/trader/ussp

/datum/traders/unathi
	trader_type = "Glint Scales"
	trader_location = "Moghes"
	dock_site = "a Glint-Scale outpost"
	trader_species = /mob/living/carbon/human/unathi
	trader_outfit = /datum/outfit/admin/trader/unathi
	trader_minor_special = /obj/effect/spawner/random/traders/glintscale_minor
	trader_major_special = /obj/effect/spawner/random/traders/glintscale_major
	ship_template = /datum/map_template/shuttle/trader/glint_scale

/datum/traders/vulp
	trader_type = "Steadfast Trading Co."
	trader_location = "Vazzend"
	dock_site = "the MV Steadfast Platinum"
	trader_species = /mob/living/carbon/human/vulpkanin
	trader_outfit = /datum/outfit/admin/trader/vulp
	trader_minor_special = /obj/effect/spawner/random/traders/steadfast_minor
	trader_major_special = /obj/effect/spawner/random/traders/steadfast_major
	ship_template = /datum/map_template/shuttle/trader/steadfast

/datum/traders/ipc
	trader_type = "Synthetic Union"
	trader_location = "Cadraenov Epsilon"
	dock_site = "Cadraenov Station"
	trader_species = /mob/living/carbon/human/machine
	trader_outfit = /datum/outfit/admin/trader/ipc
	trader_minor_special = /obj/effect/spawner/random/traders/syntheticunion_minor
	trader_major_special = /obj/effect/spawner/random/traders/syntheticunion_major
	ship_template = /datum/map_template/shuttle/trader/synthetic

/datum/traders/vox
	trader_type = "Skipjack"
	trader_location = "a nearby skipjack"
	dock_site = "a trading skipjack"
	trader_species = /mob/living/carbon/human/vox
	trader_outfit = /datum/outfit/admin/trader/vox
	trader_minor_special = /obj/effect/spawner/random/traders/skipjack_minor
	trader_major_special = /obj/effect/spawner/random/traders/skipjack_major
	ship_template = /datum/map_template/shuttle/trader/skipjack

/datum/traders/skrell
	trader_type = "Skrellian Central Authority"
	trader_location = "the Crown"
	dock_site = "Crown Station"
	trader_species = /mob/living/carbon/human/skrell
	trader_outfit = /datum/outfit/admin/trader/skrell
	trader_minor_special = /obj/effect/spawner/random/traders/solarcentral_minor
	trader_major_special = /obj/effect/spawner/random/traders/solarcentral_major
	ship_template = /datum/map_template/shuttle/trader/skrell

/datum/traders/grey
	trader_type = "Technocracy"
	trader_location = "Mauna-b"
	dock_site = "Orbital Commerce Outpost 58"
	trader_species = /mob/living/carbon/human/grey
	trader_outfit = /datum/outfit/admin/trader/grey
	trader_minor_special = /obj/effect/spawner/random/traders/technocracy_minor
	trader_major_special = /obj/effect/spawner/random/traders/technocracy_major
	ship_template = /datum/map_template/shuttle/trader/technocracy

/datum/traders/nian
	trader_type = "Merchant Guild"
	trader_location = "the Nian Merchant Guild"
	dock_site = "Guild Subsidiary Station 'Gilded Comet'"
	trader_species = /mob/living/carbon/human/moth
	trader_outfit = /datum/outfit/admin/trader/nian
	trader_minor_special = /obj/effect/spawner/random/traders/merchantguild_minor
	trader_major_special = /obj/effect/spawner/random/traders/merchantguild_major
	ship_template = /datum/map_template/shuttle/trader/guild
