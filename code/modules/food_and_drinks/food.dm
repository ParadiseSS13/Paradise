////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Sets the default container amount for all food items.
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/bitesize = 2
	var/consume_sound = 'sound/items/eatfood.ogg'
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/transfer_efficiency = 1.0
	var/instant_application = 0 //if we want to bypass the forcedfeed delay
	var/taste = TRUE//whether you can taste eating from this
	var/antable = TRUE // Will ants come near it?
	var/ant_location = null
	var/ant_timer = null
	burn_state = FLAMMABLE
	container_type = INJECTABLE

/obj/item/reagent_containers/food/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5) //Randomizes postion
	pixel_y = rand(-5, 5)
	if(antable)
		ant_location = get_turf(src)
		ant_timer = addtimer(CALLBACK(src, .proc/check_for_ants), 3000, TIMER_STOPPABLE)

/obj/item/reagent_containers/food/Destroy()
	ant_location = null
	if(ant_timer)
		deltimer(ant_timer)
	return ..()

/obj/item/reagent_containers/food/proc/check_for_ants()
	if(!antable)
		return
	var/turf/T = get_turf(src)
	if(isturf(loc) && !locate(/obj/structure/table) in T)
		if(ant_location == T)
			if(prob(15))
				if(!locate(/obj/effect/decal/ants) in T)
					new /obj/effect/decal/ants(T)
					antable = FALSE
					desc += " It appears to be infested with ants. Yuck!"
					reagents.add_reagent("ants", 1) // Don't eat things with ants in i you weirdo.
					if(ant_timer)
						deltimer(ant_timer)
		else
			ant_location = T
	if(ant_timer)
		deltimer(ant_timer)
	ant_timer = addtimer(CALLBACK(src, .proc/check_for_ants), 3000, TIMER_STOPPABLE)