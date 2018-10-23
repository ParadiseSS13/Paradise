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
	burn_state = FLAMMABLE
	container_type = INJECTABLE

/obj/item/reagent_containers/food/New()
	..()
	pixel_x = rand(-5, 5) //Randomizes postion
	pixel_y = rand(-5, 5)
