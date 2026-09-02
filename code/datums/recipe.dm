/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * /datum/recipe by rastaf0            13 apr 2011 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is powerful and flexible recipe system.
 * It exists not only for food.
 * supports both reagents and objects as prerequisites.
 * In order to use this system you have to define a deriative from /datum/recipe
 * * reagents are reagents. Acid, milc, booze, etc.
 * * items are objects. Fruits, tools, circuit boards.
 * * result is type to create as new object
 * * time is optional parameter, you shall use in in your machine,
 *   default /datum/recipe/ procs does not rely on this parameter.
 *
 *  Functions you need:
 *  /datum/recipe/proc/make(var/obj/container as obj)
 *    Creates result inside container,
 *    deletes prerequisite reagents,
 *    transfers reagents from prerequisite objects,
 *    deletes all prerequisite objects (even not needed for recipe at the moment).
 *
 *  /proc/select_recipe(list/datum/recipe/avaiable_recipes, obj/obj as obj, exact = 1)
 *    Wonderful function that select suitable recipe for you.
 *    obj is a machine (or magik hat) with prerequisites,
 *    exact = 0 forces algorithm to ignore superfluous stuff.
 *
 *
 *  Functions you do not need to call directly but could:
 *  /datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
 *    //1=precisely,  0=insufficiently, -1=superfluous
 *
 *  /datum/recipe/proc/check_items(var/obj/container as obj)
 *    //1=precisely, 0=insufficiently, -1=superfluous
 *
 * */

/datum/recipe
	var/list/reagents // example:  = list("berryjuice" = 5) // do not list same reagent twice
	var/list/items // example: =list(/obj/item/crowbar, /obj/item/welder) // place /foo/bar before /foo
	var/result //example: = /obj/item/food/donut
	var/time = 100 // 1/10 part of second
	/// Whether or not an upgraded kitchen machine will create more products using the same amount of ingredients
	var/duplicate = TRUE
	var/byproduct		// example: = /obj/item/reagent_containers/cooking/mould		// byproduct to return, such as a mould or trash

/datum/recipe/proc/check_reagents(datum/reagents/avail_reagents)
	. = INGREDIENT_CHECK_EXACT
	for(var/r_r in reagents)
		var/aval_r_amnt = avail_reagents.get_reagent_amount(r_r)
		if(!(abs(aval_r_amnt - reagents[r_r])<0.5)) //if NOT equals
			if(aval_r_amnt>reagents[r_r])
				. = INGREDIENT_CHECK_SURPLUS
			else
				return INGREDIENT_CHECK_FAILURE
	if((reagents ? length(reagents) : 0) < length(avail_reagents.reagent_list))
		return INGREDIENT_CHECK_SURPLUS

/**
 * Similarly to the function above, this checks for reagents, except instead of being passed a reagent holder, we're passed
 * [reagent_id] = amount as num.
 * Returns INGREDIENT_CHECK_EXACT if we have the precise amount thats requested.
 * Returns INGREDIENT_CHECK_FAILURE if we do not have enough.
 * Returns INGREDIENT_CHECK_SURPLUS if we have MORE than requested.
 */
/datum/recipe/proc/check_reagents_assoc_list(list/avail_reagents)
	. = INGREDIENT_CHECK_EXACT
	for(var/required_reagent_id in reagents)
		var/provided_reagent_amount = avail_reagents[required_reagent_id]
		if(!provided_reagent_amount)
			return INGREDIENT_CHECK_FAILURE

		if(abs(provided_reagent_amount - reagents[required_reagent_id]) >= 0.5) // If amount is outside of the 0.5 unit tolerance
			if(provided_reagent_amount > reagents[required_reagent_id]) // we have more than necessary
				. = INGREDIENT_CHECK_SURPLUS
			else
				return INGREDIENT_CHECK_FAILURE // we don't have enough

	if(length(reagents) < length(avail_reagents))
		return INGREDIENT_CHECK_SURPLUS

/datum/recipe/proc/check_items(obj/container, list/ignored_items = null) //1=precisely, 0=insufficiently, -1=superfluous
	. = INGREDIENT_CHECK_EXACT
	var/list/checklist = items ? items.Copy() : list()
	for(var/obj/O in container)
		if(ignored_items && is_type_in_list(O, ignored_items))	//skip if this is something we are ignoring
			continue
		if(!items)
			return INGREDIENT_CHECK_SURPLUS
		var/found = 0
		for(var/type in checklist)
			if(istype(O,type))
				checklist -= type
				found = 1
				break
		if(!found)
			. = INGREDIENT_CHECK_SURPLUS
	if(length(checklist))
		return INGREDIENT_CHECK_FAILURE

/**
 * Similarly to the function above, this checks for items, except instead of being passed a reagent holder, we're passed
 * [type_path] = amount as num.
 * Returns INGREDIENT_CHECK_EXACT if we have the precise amount thats requested.
 * Returns INGREDIENT_CHECK_FAILURE if we do not have enough.
 * Returns INGREDIENT_CHECK_SURPLUS if we have MORE than requested.
 */
/datum/recipe/proc/check_items_assoc_list(list/given_objects)
	. = INGREDIENT_CHECK_EXACT
	var/list/checklist = items ? items.Copy() : list()
	for(var/obj/item/I as anything in given_objects) // path
		var/amount_given = given_objects[I]
		if(!length(checklist))
			return INGREDIENT_CHECK_SURPLUS

		for(var/i in 1 to amount_given)
			if(I in checklist)
				checklist -= I
			else if(I in items) // make sure the recipe requires this item before declaring it surplus
				. = INGREDIENT_CHECK_SURPLUS
	if(length(checklist)) // we didnt get everything
		return INGREDIENT_CHECK_FAILURE

//general version
/datum/recipe/proc/make(obj/container)
	var/obj/result_obj = new result(container)
	for(var/obj/O in (container.contents-result_obj))
		O.reagents.trans_to(result_obj, O.reagents.total_volume)
		qdel(O)
	container.reagents.clear_reagents()
	return result_obj

// food-related
/datum/recipe/proc/make_food(obj/container)
	var/obj/result_obj = new result(container)
	for(var/obj/O in (container.contents-result_obj))
		if(O.reagents)
			O.reagents.del_reagent("nutriment")
			O.reagents.update_total()
			O.reagents.trans_to(result_obj, O.reagents.total_volume)
		qdel(O)
	container.reagents.clear_reagents()
	return result_obj

/proc/select_recipe(list/datum/recipe/available_recipes, obj/obj, exact = INGREDIENT_CHECK_EXACT, list/ignored_items = null)
	if(!exact)
		exact = -1
	var/list/datum/recipe/possible_recipes = list()
	for(var/datum/recipe/recipe in available_recipes)
		if(recipe.check_reagents(obj.reagents) == exact && recipe.check_items(obj, ignored_items) == exact)
			possible_recipes += recipe
	if(length(possible_recipes) == 0)
		return null
	else if(length(possible_recipes) == 1)
		return possible_recipes[1]
	else //okay, let's select the most complicated recipe
		var/r_count = 0
		var/i_count = 0
		. = possible_recipes[1]
		for(var/datum/recipe/recipe in possible_recipes)
			var/N_i = (recipe.items)?(length(recipe.items)):0
			var/N_r = (recipe.reagents)?(length(recipe.reagents)):0
			if(N_i > i_count || (N_i== i_count && N_r > r_count))
				r_count = N_r
				i_count = N_i
				. = recipe

/datum/recipe/proc/get_byproduct()
	if(byproduct)
		return byproduct
	else
		return null

/datum/recipe/proc/count_n_items()
	var/count = 0
	if(items && length(items))
		count += length(items)
	return count
