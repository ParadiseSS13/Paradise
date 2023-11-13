////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food
	possible_transfer_amounts = null
	visible_transfer_rate = FALSE
	volume = 50 //Sets the default container amount for all food items.
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/bitesize = 2
	var/consume_sound = 'sound/items/eatfood.ogg'
	var/apply_type = REAGENT_INGEST
	var/apply_method = "swallow"
	var/transfer_efficiency = 1.0
	var/instant_application = 0 //if we want to bypass the forcedfeed delay
	var/can_taste = TRUE//whether you can taste eating from this
	var/antable = TRUE // Will ants come near it?
	/// location checked every 5 minutes. If its the same place, the food has a chance to spawn ants
	var/ant_location
	/// Time we last checked for ants
	var/last_ant_time = 0
	///Name of the food to show up in kitchen machines (microwaves, ovens, etc)
	var/ingredient_name
	var/ingredient_name_plural
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	if(antable)
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
	var/turf/T = get_turf(src)
	if(!isturf(loc))
		return
	if((locate(/obj/structure/table) in T) || (locate(/obj/structure/rack) in T))
		return

	if(ant_location == T) //It must have been on the same floor since at least the last check_for_ants()
		if(prob(15))
			if(!locate(/obj/effect/decal/cleanable/ants) in T)
				new /obj/effect/decal/cleanable/ants(T)
				antable = FALSE
				desc += " It appears to be infested with ants. Yuck!"
				reagents.add_reagent("ants", 1) // Don't eat things with ants in it you weirdo.
	else
		ant_location = T
