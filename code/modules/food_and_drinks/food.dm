////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////

#define MEAT 		1
#define VEGETABLES 	2
#define RAW 		4
#define JUNKFOOD 	8
#define GRAIN 		16
#define FRUIT 		32
#define DAIRY 		64
#define FRIED 		128
#define ALCOHOL 	256
#define SUGAR 		512
#define GROSS 		1024
#define TOXIC 		2048

/obj/item/reagent_containers/food
	possible_transfer_amounts = null
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
	var/ant_location = null
	var/ant_timer = null
	var/foodtype = NONE
	var/last_check_time
	resistance_flags = FLAMMABLE
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

/obj/item/reagent_containers/food/set_APTFT()
	set hidden = TRUE
	..()

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
					desc += " It appears to be infested with space ants. Yuck!"
					reagents.add_reagent("ants", 1) // Don't eat things with ants in i you weirdo.
					if(ant_timer)
						deltimer(ant_timer)
		else
			ant_location = T
	if(ant_timer)
		deltimer(ant_timer)
	ant_timer = addtimer(CALLBACK(src, .proc/check_for_ants), 3000, TIMER_STOPPABLE)

/obj/item/reagent_containers/food/proc/checkLiked(var/fraction, mob/M)
	if(last_check_time + 50 < world.time)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(foodtype & H.dna.species.toxic_food)
				var/type_string = matched_type(foodtype & H.dna.species.toxic_food)
				to_chat(H,"<span class='warning'>[toxic_message(type_string)]</span>")

				H.AdjustDisgust(25 + 30 * fraction)
			else if(foodtype & H.dna.species.disliked_food)
				var/type_string = matched_type(foodtype & H.dna.species.disliked_food)
				to_chat(H,"<span class='notice'>[dislike_message(type_string)]</span>")

				H.AdjustDisgust(11 + 15 * fraction)
			else if(foodtype & H.dna.species.liked_food)
				var/type_string = matched_type(foodtype & H.dna.species.liked_food)
				to_chat(H,"<span class='notice'>[love_message(type_string)]</span>")

				H.AdjustDisgust(-5 + -2.5 * fraction)
			last_check_time = world.time

/obj/item/reagent_containers/food/proc/toxic_message(type)
	var/plural = cmptext(type[length(type)], "s") ? "are" : "is"

	return pick(
		"What the hell was that?! I hate <b>[type]</b>!",
		"That was awful! I hate <b>[type]</b>.",
		"God, that was outright dangerous! <b>[capitalize(type)]</b> [plural] awful!")

/obj/item/reagent_containers/food/proc/dislike_message(type)
	var/plural = cmptext(type[length(type)], "s") ? "are" : "is"

	return pick(
		"That wasn't very good. I should probably stay away from <b>[type]</b>.",
		"Not a fan of <b>[type]</b>. Let's not eat that again.",
		"Eugh. <b>[capitalize(type)]</b> really [plural]n't something I should be eating.")

/obj/item/reagent_containers/food/proc/love_message(type)
	var/plural = cmptext(type[length(type)], "s") ? "are" : "is"

	return pick(
		"Delicious! I love <b>[type]</b>.",
		"Scrump. I was born to eat <b>[type]</b>.",
		"I love this taste. <b>[capitalize(type)]</b> [plural] great.",
		"<b>[capitalize(type)]</b> [plural] amazing. I should eat more of this stuff.")

/obj/item/reagent_containers/food/proc/matched_type(var/bitmap)
	if(bitmap & MEAT)
		return pick("meat", "flesh", "dead animals")
	if(bitmap & VEGETABLES)
		return pick("vegetables", "veggies")
	if(bitmap & RAW)
		return pick("raw food", "uncooked food", "tartare")
	if(bitmap & FRUIT)
		return pick("fruit")
	if(bitmap & DAIRY)
		return pick("dairy")
	if(bitmap & FRIED)
		return pick("fried food", "deep fried stuff")
	if(bitmap & ALCOHOL)
		return pick("alcohol", "booze")
	if(bitmap & SUGAR)
		return pick("sugary food", "sweets")
	if(bitmap & GRAIN)
		return pick("grain products", "carbs")
	if(bitmap & GROSS)
		return pick("gross stuff", "garbage")
	if(bitmap & TOXIC)
		return pick("toxic garbage", "toxins", "literally poison")
	if(bitmap & JUNKFOOD)
		return pick("junk food")
