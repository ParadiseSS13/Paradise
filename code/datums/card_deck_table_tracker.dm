#define COMSIG_CARD_DECK_FIELD_CLEAR "card_deck_field_clear"

/datum/card_deck_table_tracker
	/// How far away you can be (in terms of table squares).
	var/max_table_distance
	/// How far away you can be (euclidean distance).
	var/max_total_distance
	/// The UID of the deck
	var/deck_uid
	/// Indicate field activity with colors on the field's turfs.
	var/debug = FALSE
	/// The deck we're tracking.
	var/atom/host

	/// The list of floors from which a player can access the card field.
	var/list/floors = list()
	/// The list of tables that the card deck's location is contiguous with.
	var/list/tables = list()

/datum/card_deck_table_tracker/New(atom/host_, max_table_distance_ = 5)
	max_table_distance = max_table_distance_
	max_total_distance = max_table_distance_
	if(istype(host_, /obj/item/deck))
		// this is important for tracking traits and attacking multiple cards. so it's not a true UID, sue me
		var/obj/item/deck/D = host_
		deck_uid = D.main_deck_id
	else
		deck_uid = host_.UID()

	host = host_
	RegisterSignal(host, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))
	lay_out_field()

/datum/card_deck_table_tracker/proc/on_movable_moved(datum/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER // COMSIG_MOVABLE_MOVED
	lay_out_field()

/datum/card_deck_table_tracker/proc/lay_out_field()
	for(var/turf/floor in floors)
		SEND_SIGNAL(floor, COMSIG_CARD_DECK_FIELD_CLEAR)

	if(!isturf(host.loc))
		return

	floors.Cut()
	tables.Cut()

	crawl_along(host.loc, 0)

	for(var/obj/structure/table in tables)
		if(istype(table))
			RegisterSignal(table, COMSIG_PARENT_QDELETING, PROC_REF(on_table_qdel), override = TRUE)

	for(var/turf/turf in floors)
		if(!istype(turf))
			continue

		if(debug)
			turf.color = "#ffaaff"

		RegisterSignal(turf, COMSIG_ATOM_ENTERED, PROC_REF(on_atom_entered))
		RegisterSignal(turf, COMSIG_ATOM_EXITED, PROC_REF(on_atom_exited))
		RegisterSignal(turf, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_new_atom_at_loc))
		RegisterSignal(turf, COMSIG_CARD_DECK_FIELD_CLEAR, PROC_REF(on_card_deck_field_clear))

		for(var/mob/living/L in turf)
			on_atom_entered(turf, L)

/datum/card_deck_table_tracker/Destroy(force, ...)
	host = null
	for(var/turf/floor in floors)
		SEND_SIGNAL(floor, COMSIG_CARD_DECK_FIELD_CLEAR)
		for(var/mob/living/L in floor)
			REMOVE_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")

	floors.Cut()
	tables.Cut()

	return ..()

/datum/card_deck_table_tracker/proc/on_atom_entered(turf/source, atom/movable/entered, old_loc)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	var/mob/living/L = entered
	if(istype(L))
		ADD_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
		if(debug)
			source.color = "#ff0000"

/datum/card_deck_table_tracker/proc/on_atom_exited(turf/source, atom/movable/exited, direction)
	SIGNAL_HANDLER // COMSIG_ATOM_EXITED

	var/mob/living/L = exited
	if(istype(L))
		REMOVE_TRAIT(L, TRAIT_PLAYING_CARDS, "deck_[deck_uid]")
		if(debug)
			source.color = "#ffaaff"

/datum/card_deck_table_tracker/proc/on_table_qdel(datum/source)
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	lay_out_field()

/datum/card_deck_table_tracker/proc/on_new_atom_at_loc(turf/location, atom/created, init_flags)
	SIGNAL_HANDLER // COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON
	if(istable(created))
		lay_out_field()

/datum/card_deck_table_tracker/proc/on_card_deck_field_clear(atom/target)
	SIGNAL_HANDLER // COMSIG_CARD_DECK_FIELD_CLEAR
	if(debug)
		target.color = initial(target.color)

	UnregisterSignal(target, list(
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED,
		COMSIG_CARD_DECK_FIELD_CLEAR,
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON,
	))

/datum/card_deck_table_tracker/proc/crawl_along(turf/current_turf, distance_from_start)
	var/obj/structure/current_table = locate(/obj/structure/table) in current_turf

	if(QDELETED(current_table))
		// if there's no table here, we're still adjacent to a table, so this is a spot you could play from
		floors |= current_turf
		return

	if(current_table in tables)
		return

	tables |= current_table
	floors |= current_turf

	if(distance_from_start + 1 > max_table_distance)
		return

	for(var/direction in GLOB.alldirs)
		var/turf/next_turf = get_step(current_table, direction)
		if(!istype(next_turf))
			continue
		if(get_dist_euclidian(get_turf(host), next_turf) > max_total_distance)
			continue
		.(next_turf, distance_from_start + 1)

#undef COMSIG_CARD_DECK_FIELD_CLEAR
