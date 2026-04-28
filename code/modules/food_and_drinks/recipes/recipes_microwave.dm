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
