////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/food
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/bitesize = 2
	var/consume_sound = 'sound/items/eatfood.ogg'
	/// Will ants come near it?
	var/antable = TRUE
	/// location checked every 5 minutes. If its the same place, the food has a chance to spawn ants
	var/ant_location
	/// Time we last checked for ants
	var/last_ant_time = 0
	/// Name of the food to show up in kitchen machines (microwaves, ovens, etc)
	var/ingredient_name
	var/ingredient_name_plural
	/// Sets the default container amount for all food items.
	var/volume = 50
	/// The list of reagents to create on Initialize()
	var/list/list_reagents = list()

	var/temperature_min = 0 // To limit the temperature of a reagent container can atain when exposed to heat/cold
	var/temperature_max = 10000

/obj/item/food/Initialize(mapload)
	. = ..()
	if(antable)
		START_PROCESSING(SSobj, src)
		ant_location = get_turf(src)
		last_ant_time = world.time
	if(!reagents) // Some subtypes create their own reagents
		create_reagents(volume, temperature_min, temperature_max)
	add_initial_reagents()

/obj/item/food/Destroy()
	ant_location = null
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/food/proc/add_initial_reagents() // This literally only is a proc for junk food
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/food/process()
	if(!antable)
		return PROCESS_KILL
	if(world.time > last_ant_time + 5 MINUTES)
		check_for_ants()

/obj/item/food/proc/check_for_ants()
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

/obj/item/food/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()
