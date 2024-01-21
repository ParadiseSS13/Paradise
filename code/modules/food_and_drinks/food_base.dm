////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	volume = 50
	/// Used by sandwiches
	var/filling_color = "#FFFFFF"
	/// Used by junk food to lower satiety
	var/junkiness = 0
	var/bitesize = 2
	var/consume_sound = 'sound/items/eatfood.ogg'
	/// Will ants infest it?
	var/antable = TRUE
	/// Location checked every 5 minutes. If its the same place, the food has a chance to spawn ants
	var/ant_location
	/// Things that suppress food from being infested by ants when on the same turf
	var/static/list/ant_suppressors
	/// Time we last checked for ants
	var/last_ant_time = 0
	/// Name of the food to show up in kitchen machines (microwaves, ovens, etc)
	var/ingredient_name
	var/ingredient_name_plural
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(!antable)
		return

	if(!ant_suppressors)
		ant_suppressors = typecacheof(list(
			/obj/structure/table,
			/obj/structure/rack,
			/obj/structure/closet
		))
	START_PROCESSING(SSobj, src)
	ant_location = get_turf(src)
	last_ant_time = world.time

/obj/item/reagent_containers/food/Destroy()
	ant_location = null
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/food/process()
	if(!antable)
		return PROCESS_KILL
	if(world.time > last_ant_time + 5 MINUTES)
		check_for_ants()

/obj/item/reagent_containers/food/proc/check_for_ants()
	last_ant_time = world.time

	// Are we unshielded from the fury of space ants?
	if(!prob(15)) // Ants are often not the smartest
		return
	if(!isturf(loc)) // Being inside something protects the food
		return

	var/turf/T = get_turf(src)

	if(T != ant_location) // Moving the food before a full ant swarm can arrive to the location also helps
		ant_location = T
		return

	for(var/obj/structure/S in T) // Check if some object on our turf protects the food from ants
		if(is_type_in_typecache(S, ant_suppressors))
			return

	// Dinner time!
	if(!locate(/obj/effect/decal/cleanable/ants) in T)
		new /obj/effect/decal/cleanable/ants(T)
	antable = FALSE
	desc += " It appears to be infested with ants. Yuck!"
	reagents.add_reagent("ants", 1) // Don't eat things with ants in it you weirdo.
