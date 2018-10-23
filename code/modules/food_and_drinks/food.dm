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
	var/taste_description = list() // list of tastes copied to nutriments inside of this thing on New()
	burn_state = FLAMMABLE
	container_type = INJECTABLE

/obj/item/reagent_containers/food/New()
	..()
	apply_taste_desc()
	pixel_x = rand(-5, 5) //Randomizes postion
	pixel_y = rand(-5, 5)

/obj/item/reagent_containers/food/proc/apply_taste_desc()
	for(var/datum/reagent/R in reagents.reagent_list)
		if(istype(R, /datum/reagent/consumable))
			R.data["tastes"] = taste_description
