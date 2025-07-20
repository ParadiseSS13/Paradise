/datum/event/disposals_clog
	announceWhen	= 0
	startWhen		= 10
	endWhen			= 35
	var/list/bins  = list()

/datum/event/disposals_clog/announce()
	GLOB.minor_announcement.Announce("The waste disposal network has experienced a clog. Purging the source bin.", "Waste alert", 'sound/AI/alert.ogg')

/datum/event/disposals_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/disposal/temp_disposal in SSmachines.get_by_type(/obj/machinery/disposal))
		if(is_station_level(temp_disposal.loc.z))
			bins += temp_disposal

/datum/event/disposals_clog/start()
	var/list/possible_trash = typecacheof(/obj/item/trash)
	var/obj/machinery/disposal/bin
	for(var/i in 1 to 6)
		bin = pick_n_take(bins)
		var/trash_amount = rand(4, 8)
		for(var/j in 1 to trash_amount)
			var/trash_type = pick(possible_trash)
			var/obj/item/trash/trash_item = new trash_type(bin.loc)
			var/throw_dir = pick(GLOB.alldirs)
			var/turf/general_direction = get_edge_target_turf(bin, throw_dir)
			trash_item.throw_at(general_direction, 3, 2)
		playsound(bin.loc, 'sound/machines/warning-buzzer.ogg', 50, TRUE, -3)

	// Final bin spews hostile mobs
	var/list/possible_mobs = list(
		// Hostile mobs
		/mob/living/basic/space_bear = 5,
		/mob/living/basic/carp = 5,
		/mob/living/simple_animal/hostile/hivebot = 5,
		/mob/living/basic/scarybat = 5,
		/mob/living/basic/giant_spider/hunter = 5,
		/mob/living/simple_animal/hostile/alien = 2,
		// Retaliate mobs
		/mob/living/basic/clown = 5,
		/mob/living/basic/clown/goblin = 5,
		/mob/living/simple_animal/hostile/retaliate/goat = 5,
		// Friendly
		/mob/living/simple_animal/mouse = 5,
		/mob/living/simple_animal/diona = 5,
		/mob/living/simple_animal/crab = 5,
		/mob/living/simple_animal/pet/dog/corgi = 5,
		/mob/living/simple_animal/hostile/retaliate/carp/koi = 5
	)
	var/selected_mob_type = pickweight(possible_mobs)
	var/amount = rand(3, 10)
	var/possible_locs = view(1, bin.loc)
	for(var/i in 1 to amount)
		var/turf/spawn_loc = pick(possible_locs)
		var/mob/living/new_mob = new selected_mob_type(spawn_loc)

