/datum/proximity_monitor/advanced/card_deck
	/// How far away you can be (in terms of table squares).
	var/max_table_distance
	/// How far away you can be (euclidean distance).
	var/max_total_distance
	/// The UID of the deck
	var/deck_uid

	var/debug = TRUE

/datum/proximity_monitor/advanced/card_deck/New(atom/host_, max_table_distance_ = 5, ignore_if_not_on_turf_ = TRUE)
	max_table_distance = max_table_distance_
	max_total_distance = max_table_distance_
	if(istype(host_, /obj/item/deck))
		// this is important for tracking traits and attacking multiple cards. so it's not a true UID, sue me
		var/obj/item/deck/D = host_
		deck_uid = D.main_deck_id
	else
		deck_uid = host_.UID()
	ignore_if_not_on_turf = ignore_if_not_on_turf_
	set_host(host_)

/datum/proximity_monitor/advanced/card_deck/set_range(range, force_rebuild)
	var/new_turfs = update_new_turfs()
	AddComponent(/datum/component/connect_turfgroup/direct, host, loc_connections, new_turfs[FIELD_TURFS_KEY])
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/card_deck/update_new_turfs()
	var/list/tables = list()
	var/list/prox_mon_spots = list()
	crawl_along(get_turf(host), tables, prox_mon_spots, 0)

	for(var/atom/table in tables)
		RegisterSignal(table, COMSIG_PARENT_QDELETING, PROC_REF(on_table_qdel), TRUE)

	return list(EDGE_TURFS_KEY = list(), FIELD_TURFS_KEY = prox_mon_spots.Copy())

/// Crawl along an extended table, and return a list of all turfs that we should start tracking.
/datum/proximity_monitor/advanced/card_deck/proc/crawl_along(turf/current_turf, list/visited_tables = list(), list/prox_mon_spots = list(), distance_from_start)
	var/obj/structure/current_table = locate(/obj/structure/table) in current_turf

	if(QDELETED(current_table))
		// if there's no table here, we're still adjacent to a table, so this is a spot you could play from
		prox_mon_spots |= current_turf
		return

	if(current_table in visited_tables)
		return

	visited_tables |= current_table
	prox_mon_spots |= current_turf

	if(distance_from_start + 1 > max_table_distance)
		return

	for(var/direction in GLOB.alldirs)
		var/turf/next_turf = get_step(current_table, direction)
		if(!istype(next_turf))
			continue
		if(get_dist_euclidian(get_turf(host), next_turf) > max_total_distance)
			continue
		.(next_turf, visited_tables, prox_mon_spots, distance_from_start + 1)

/datum/proximity_monitor/advanced/card_deck/proc/on_table_qdel(datum/source)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	recalculate_field(full_recalc = FALSE)

/datum/proximity_monitor/advanced/card_deck/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	var/mob/living/L = movable
	if(istype(L))
		ADD_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
		if(debug)
			new_location.color = "#ff0000"

/datum/proximity_monitor/advanced/card_deck/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	var/mob/living/L = movable
	if(istype(L))
		if(!(new_location in field_turfs))
			REMOVE_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
		if(debug)
			old_location.color = initial(old_location.color)

/datum/proximity_monitor/advanced/card_deck/setup_field_turf(turf/target)
	if(debug)
		target.color = "#ffaaff"

/datum/proximity_monitor/advanced/card_deck/cleanup_field_turf(turf/target)
	for(var/mob/living/L in target)
		REMOVE_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
	if(debug)
		target.color = initial(target.color)
