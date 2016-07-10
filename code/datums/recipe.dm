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
     default /datum/recipe/ procs does not rely on this parameter.
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
	var/list/reagents	// example: = list("berryjuice" = 5) // do not list same reagent twice
	var/list/items		// example: = list(/obj/item/weapon/crowbar, /obj/item/weapon/welder) // place /foo/bar before /foo
	var/list/fruit		// example: = list("fruit" = 3)
	var/result			// example: = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
	var/time = 100		// 1/10 part of second
	var/byproduct		// example: = /obj/item/weapon/kitchen/mould		// byproduct to return, such as a mould or trash


/datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents) //1=precisely, 0=insufficiently, -1=superfluous
	. = 1
	for(var/r_r in reagents)
		var/aval_r_amnt = avail_reagents.get_reagent_amount(r_r)
		if(!(abs(aval_r_amnt - reagents[r_r])<0.5)) //if NOT equals
			if(aval_r_amnt>reagents[r_r])
				. = -1
			else
				return 0
	if((reagents?(reagents.len):(0)) < avail_reagents.reagent_list.len)
		return -1
	return .

/datum/recipe/proc/check_fruit(var/obj/container)
	. = 1
	if(fruit && fruit.len)
		var/list/checklist = list()
		 // You should trust Copy().
		checklist = fruit.Copy()
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in container)
			if(!G.seed || !G.seed.kitchen_tag || isnull(checklist[G.seed.kitchen_tag]))
				continue
			checklist[G.seed.kitchen_tag]--
		for(var/ktag in checklist)
			if(!isnull(checklist[ktag]))
				if(checklist[ktag] < 0)
					. = 0
				else if(checklist[ktag] > 0)
					. = -1
					break
	return .

/datum/recipe/proc/check_items(var/obj/container as obj)
	. = 1
	if(items && items.len)
		var/list/checklist = list()
		checklist = items.Copy() // You should really trust Copy
		for(var/obj/O in container)
			if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown))
				continue // Fruit is handled in check_fruit().
			var/found = 0
			for(var/i = 1; i < checklist.len+1; i++)
				var/item_type = checklist[i]
				if(istype(O,item_type))
					checklist.Cut(i, i+1)
					found = 1
					break
			if(!found)
				. = 0
		if(checklist.len)
			. = -1
	return .

//general version
/datum/recipe/proc/make(var/obj/container as obj)
	var/obj/result_obj = new result(container)
	for(var/obj/O in (container.contents-result_obj))
		O.reagents.trans_to(result_obj, O.reagents.total_volume)
		qdel(O)
	container.reagents.clear_reagents()
	score_meals++
	return result_obj

// food-related
/datum/recipe/proc/make_food(var/obj/container as obj)
	var/obj/result_obj = new result(container)
	for(var/obj/O in (container.contents-result_obj))
		if(O.reagents)
			O.reagents.del_reagent("nutriment")
			O.reagents.update_total()
			O.reagents.trans_to(result_obj, O.reagents.total_volume)
		qdel(O)
	container.reagents.clear_reagents()
	score_meals++
	return result_obj

/proc/select_recipe(var/list/datum/recipe/avaiable_recipes, var/obj/obj as obj, var/exact = 1 as num)
	if(!exact)
		exact = -1
	var/list/datum/recipe/possible_recipes = new
	for(var/datum/recipe/recipe in avaiable_recipes)
		if(recipe.check_reagents(obj.reagents)==exact && recipe.check_items(obj)==exact && recipe.check_fruit(obj)==exact)
			possible_recipes+=recipe
	if(possible_recipes.len==0)
		return null
	else if(possible_recipes.len==1)
		return possible_recipes[1]
	else //okay, let's select the most complicated recipe
		var/highest_count = 0
		. = possible_recipes[1]
		for(var/datum/recipe/recipe in possible_recipes)
			var/count = ((recipe.items)?(recipe.items.len):0) + ((recipe.reagents)?(recipe.reagents.len):0) + ((recipe.fruit)?(recipe.fruit.len):0)
			if(count >= highest_count)
				highest_count = count
				. = recipe
		return .

/datum/recipe/proc/get_byproduct()
	if(byproduct)
		return byproduct
	else
		return null

/datum/recipe/proc/count_n_items()
	var/count = 0
	if(items && items.len)
		count += items.len
	if(fruit && fruit.len)
		for(var/ktag in fruit)
			count += fruit[ktag]
	return count
