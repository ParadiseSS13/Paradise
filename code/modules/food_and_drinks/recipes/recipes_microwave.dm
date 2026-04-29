/datum/recipe/microwave/make_food(obj/machinery/kitchen_machine/container)
	var/datum/reagents/temp_reagents = new(500)
	for(var/obj/object in container.contents) // Process supplied ingredients
		if(object.reagents)
			object.reagents.del_reagent("nutriment")
			object.reagents.update_total()
			object.reagents.trans_to(temp_reagents, object.reagents.total_volume, no_react = TRUE) // Don't react with the abstract holder please

		qdel(object)
	container.reagents.clear_reagents()
	var/portions = 1
	if(istype(container) && duplicate)
		portions = container.efficiency
	var/reagents_per_serving = temp_reagents.total_volume / portions
	for(var/i in 1 to portions) // Extra servings when upgraded, ingredient reagents split equally
		var/obj/cooked = new result(container.loc)
		cooked.pixel_y = rand(-5, 5)
		cooked.pixel_x = rand(-5, 5)
		temp_reagents.trans_to(cooked, reagents_per_serving, no_react = TRUE) // Don't react with the abstract holder please
	temp_reagents.clear_reagents()

	var/obj/byproduct = get_byproduct()
	if(byproduct)
		new byproduct(container.loc)

/datum/recipe/microwave/warmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/donkpocket
	)
	result = /obj/item/food/warmdonkpocket

/datum/recipe/microwave/reheatwarmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/warmdonkpocket
	)
	result = /obj/item/food/warmdonkpocket

/// This recipe exists solely so that placing a brain in a microwave destroys it
/// for the purpose of round-removing antag assassination targets. Because an
/// effect can never be inserted into a microwave by hand, one hopes, the recipe
/// itself cannot be completed. However, it accepts a brain as an ingredient, so
/// microwaves can take that as input.
/datum/recipe/microwave/brain_disposal_method
	duplicate = FALSE
	items = list(
		/obj/item/organ/internal/brain,
		/obj/effect
	)
	result = /obj/item/food/badrecipe

// ----------- Recipe imports from Hispania!

/datum/recipe/microwave/mugcake
	duplicate = FALSE
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/drinks/mug, /obj/item/food/egg)
	result = /obj/item/food/mugcake

/datum/recipe/microwave/mugcake/check_reagents(datum/reagents/avail_reagents, checking_mug = FALSE)
	// we'll check the reagents in the mug rather than in the microwave.
	return checking_mug ? ..() : INGREDIENT_CHECK_EXACT

/datum/recipe/microwave/mugcake/check_reagents_assoc_list(list/avail_reagents, checking_mug = FALSE)
	// we'll check the reagents in the mug rather than in the microwave.
	return checking_mug ? ..() : INGREDIENT_CHECK_EXACT

/datum/recipe/microwave/mugcake/check_items(obj/container, list/ignored_items = null)
	. = ..()
	if(. != INGREDIENT_CHECK_EXACT)
		return
	// now that we know we have a mug, let's check that the cake ingredients are in there
	var/obj/item/reagent_containers/drinks/mug/base_mug = locate() in container
	return check_reagents(base_mug.reagents, checking_mug = TRUE)

/datum/recipe/microwave/mugcake/make_food(obj/machinery/kitchen_machine/container)
	var/datum/reagents/temp_reagents = new(500)
	var/obj/trash = null
	for(var/obj/object in container.contents) // Process supplied ingredients
		if(object.reagents)
			object.reagents.del_reagent("nutriment")
			object.reagents.update_total()
			object.reagents.trans_to(temp_reagents, object.reagents.total_volume, no_react = TRUE) // Don't react with the abstract holder please
			if(istype(object, /obj/item/reagent_containers/drinks/mug))
				trash = object
			else
				qdel(object)
		else
			qdel(object)
	var/obj/item/food/mugcake/cooked = new result(container.loc, trash)
	cooked.pixel_y = rand(-5, 5)
	cooked.pixel_x = rand(-5, 5)
	container.reagents.clear_reagents()
	temp_reagents.trans_to(cooked, temp_reagents.total_volume, no_react = TRUE) // Don't react with the abstract holder please
	temp_reagents.clear_reagents()

/datum/recipe/microwave/mugcake/vanilla
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5, "vanilla" = 5)
	result = /obj/item/food/mugcake/vanilla

/datum/recipe/microwave/mugcake/chocolate
	reagents = list("sugar" = 5, "chocolate_milk" = 10, "flour" = 5)
	result = /obj/item/food/mugcake/chocolate

/datum/recipe/microwave/mugcake/banana
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/drinks/mug, /obj/item/food/egg, /obj/item/food/grown/banana)
	result = /obj/item/food/mugcake/banana

/datum/recipe/microwave/mugcake/cherry
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/drinks/mug, /obj/item/food/egg, /obj/item/food/grown/cherries)
	result = /obj/item/food/mugcake/cherry

/datum/recipe/microwave/mugcake/bluecherry
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/drinks/mug, /obj/item/food/egg, /obj/item/food/grown/bluecherries)
	result = /obj/item/food/mugcake/bluecherry

/datum/recipe/microwave/mugcake/lime
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/drinks/mug, /obj/item/food/egg, /obj/item/food/grown/citrus/lime)
	result = /obj/item/food/mugcake/lime

/datum/recipe/microwave/mugcake/amanita
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/drinks/mug, /obj/item/food/egg, /obj/item/food/grown/mushroom/amanita)
	result = /obj/item/food/mugcake/amanita

//HoneyMugcake (for Luka) //
/datum/recipe/microwave/mugcake/honey
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 5,"honey" = 5)
	result = /obj/item/food/mugcake/honey

// ----------- END of recipe imports from Hispania!
