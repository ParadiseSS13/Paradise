/obj/structure/flock/fabricator
	name = "angled pedestal"
	desc = "A strange machine."

	flock_id = "Fabricator"
	flock_desc = "A converter that turns its contents into substrate cubes."

	max_integrity = 20

	var/production_interval = 10 SECONDS
	var/substrate_per_interval = 50

	var/tmp/datum/point_holder/substrate_remaining
	var/tmp/timer_id

/obj/structure/flock/fabricator/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	substrate_remaining = new()
	timer_id = addtimer(CALLBACK(src, PROC_REF(produce)), production_interval, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)

/obj/structure/flock/fabricator/Destroy()
	QDEL_NULL(substrate_remaining)
	deltimer(timer_id)
	return ..()

/obj/structure/flock/fabricator/update_icon_state()
	if(substrate_remaining.has_points())
		icon_state = "reclaimer"
	else
		icon_state = "reclaimer-off"
	. = ..()

/obj/structure/flock/fabricator/flock_structure_examine(mob/user)
	. = ..()
	. += span_flocksay("<b>Substrate remaining:</b> [substrate_remaining.has_points()].")

/obj/structure/flock/fabricator/update_info_tag()
	info_tag.set_text("Substrate remaining: [substrate_remaining.has_points()]")

/// Called every 10 seconds via looping timer until there's no substrate left.
/obj/structure/flock/fabricator/proc/produce()
	if(substrate_remaining.has_points())
		var/obj/item/flock_cube/cube = new(drop_location())
		cube.substrate = min(substrate_remaining.has_points(), substrate_per_interval)

		substrate_remaining.remove_points(cube.substrate)

	if(!substrate_remaining.has_points())
		stop_producing()

	update_info_tag()

/obj/structure/flock/fabricator/proc/stop_producing()
	deltimer(timer_id)
	timer_id = null
	if(QDELING(src))
		return

	flock_talk(src, "ALERT: No substrate remaining.", flock, involuntary = TRUE)
	update_appearance(UPDATE_ICON_STATE)

//
// All of the try_flock_convert shit
//
/obj/machinery/vending/try_flock_convert(datum/flock/flock, force)
	var/substrate
	for(var/datum/data/vending_product/product as anything in product_records)
		substrate += 3 * product.amount

	if(!substrate)
		qdel(src)
		return

	var/obj/structure/flock/fabricator/fab = new(get_turf(src), flock)
	fab.substrate_remaining.add_points(substrate)
	fab.update_info_tag()
	qdel(src)

/obj/machinery/chem_dispenser/try_flock_convert(datum/flock/flock, force)
	var/substrate = 3 * length(cartridges)

	if(!substrate)
		qdel(src)
		return

	var/obj/structure/flock/fabricator/fab = new(get_turf(src), flock)
	fab.substrate_remaining.add_points(substrate)
	fab.update_info_tag()
	qdel(src)

/obj/structure/reagent_dispensers/try_flock_convert(datum/flock/flock, force)
	var/substrate = reagents.total_volume / 10 // 100 substrate for a full tank of 1000u

	if(!substrate)
		qdel(src)
		return

	var/obj/structure/flock/fabricator/fab = new(get_turf(src), flock)
	fab.substrate_remaining.add_points(substrate)
	fab.update_info_tag()
	qdel(src)

/obj/structure/reagent_dispensers/try_flock_convert(datum/flock/flock, force)
	var/substrate
	for(var/obj/item/tank/tank in src)
		substrate += 3

	if(!substrate)
		qdel(src)
		return

	var/obj/structure/flock/fabricator/fab = new(get_turf(src), flock)
	fab.substrate_remaining.add_points(substrate)
	fab.update_info_tag()
	qdel(src)
