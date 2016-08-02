////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50 //Sets the default container amount for all food items.
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/bitesize = 1
	var/consume_sound = 'sound/items/eatfood.ogg'
	var/apply_type = INGEST
	var/apply_method = "swallow"
	var/transfer_efficiency = 1.0
	var/instant_application = 0 //if we want to bypass the forcedfeed delay
	burn_state = FLAMMABLE

/obj/item/weapon/reagent_containers/food/New()
	..()
	pixel_x = rand(-10, 10) //Randomizes postion
	pixel_y = rand(-10, 10)