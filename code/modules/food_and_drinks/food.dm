////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
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
	burn_state = FLAMMABLE
	var/duped = 0	//if set, this food item is a replication and thus cannot be replicated in the food replicator. Seems silly, but means you need an original food item to copy (sorry science, you still gotta see the chef!)

/obj/item/weapon/reagent_containers/food/New()
	..()
	pixel_x = rand(-5, 5) //Randomizes postion
	pixel_y = rand(-5, 5)