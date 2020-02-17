
/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	layer = 2.9
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	container_type = OPENCONTAINER
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/efficiency = 0
	var/list/cook_verbs = list("Cooking")
	//Recipe & Item vars
	var/recipe_type		//Make sure to set this on the machine definition, or else you're gonna runtime on New()
	var/max_n_of_items = 25
	//Icon states
	var/off_icon
	var/on_icon
	var/broken_icon
	var/dirty_icon
	var/open_icon

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/New()
	..()
	create_reagents(100)
	reagents.set_reacting(FALSE)
	init_lists()

/obj/machinery/kitchen_machine/proc/init_lists()
	if(!GLOB.cooking_recipes[recipe_type])
		GLOB.cooking_recipes[recipe_type] = list()
		GLOB.cooking_ingredients[recipe_type] = list()
		GLOB.cooking_reagents[recipe_type] = list()
	if(!length(GLOB.cooking_recipes[recipe_type]))
		for(var/type in subtypesof(GLOB.cooking_recipe_types[recipe_type]))
			var/datum/recipe/recipe = new type
			if(recipe in GLOB.cooking_recipes[recipe_type])
				qdel(recipe)
				continue
			if(recipe.result) // Ignore recipe subtypes that lack a result
				GLOB.cooking_recipes[recipe_type] += recipe
				for(var/item in recipe.items)
					GLOB.cooking_ingredients[recipe_type] |= item
				for(var/reagent in recipe.reagents)
					GLOB.cooking_reagents[recipe_type] |= reagent
			else
				qdel(recipe)
		GLOB.cooking_ingredients[recipe_type] |= /obj/item/reagent_containers/food/snacks/grown

/*******************
*   Item Adding
********************/

/obj/machinery/kitchen_machine/attackby(obj/item/O, mob/user, params)
	if(operating)
		return
	if(!broken && dirty < 100)
		if(default_deconstruction_screwdriver(user, open_icon, off_icon, O))
			return
		if(exchange_parts(user, O))
			return
	if(!broken && istype(O, /obj/item/wrench))
		playsound(src, O.usesound, 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class='alert'>\The [src] can now be moved.</span>")
			return
		else if(!anchored)
			anchored = 1
			to_chat(user, "<span class='alert'>\The [src] is now secured.</span>")
			return

	default_deconstruction_crowbar(user, O)

	if(broken > 0)
		if(broken == 2 && istype(O, /obj/item/screwdriver)) // If it's broken and they're using a screwdriver
			user.visible_message("<span class='notice'>[user] starts to fix part of [src].</span>", "<span class='notice'>You start to fix part of [src].</span>")
			if(do_after(user, 20 * O.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] fixes part of [src].</span>", "<span class='notice'>You have fixed part of \the [src].</span>")
				broken = 1 // Fix it a bit
		else if(broken == 1 && istype(O, /obj/item/wrench)) // If it's broken and they're doing the wrench
			user.visible_message("<span class='notice'>[user] starts to fix part of [src].</span>", "<span class='notice'>You start to fix part of [src].</span>")
			if(do_after(user, 20 * O.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] fixes [src].</span>", "<span class='notice'>You have fixed [src].</span>")
				icon_state = off_icon
				broken = 0 // Fix it!
				dirty = 0 // just to be sure
				container_type = OPENCONTAINER
		else
			to_chat(user, "<span class='alert'>It's broken!</span>")
			return 1
	else if(dirty==100) // The machine is all dirty so can't be used!
		if(istype(O, /obj/item/reagent_containers/spray/cleaner) || istype(O, /obj/item/soap)) // If they're trying to clean it then let them
			user.visible_message("<span class='notice'>[user] starts to clean [src].</span>", "<span class='notice'>You start to clean [src].</span>")
			if(do_after(user, 20 * O.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] has cleaned [src].</span>", "<span class='notice'>You have cleaned [src].</span>")
				dirty = 0 // It's clean!
				broken = 0 // just to be sure
				icon_state = off_icon
				container_type = OPENCONTAINER
		else //Otherwise bad luck!!
			to_chat(user, "<span class='alert'>It's dirty!</span>")
			return 1
	else if(is_type_in_list(O, GLOB.cooking_ingredients[recipe_type]) || istype(O, /obj/item/mixing_bowl))
		if(contents.len>=max_n_of_items)
			to_chat(user, "<span class='alert'>This [src] is full of ingredients, you cannot put more.</span>")
			return 1
		if(istype(O,/obj/item/stack))
			var/obj/item/stack/S = O
			if(S.amount > 1)
				var/obj/item/stack/to_add = S.split(user, 1)
				to_add.forceMove(src)
				user.visible_message("<span class='notice'>[user] adds one of [S] to [src].</span>", "<span class='notice'>You add one of [S] to [src].</span>")
			else
				add_item(S, user)
		else
			add_item(O, user)
	else if(is_type_in_list(O, list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/drinks, /obj/item/reagent_containers/food/condiment)))
		if(!O.reagents)
			return 1
		for(var/datum/reagent/R in O.reagents.reagent_list)
			if(!(R.id in GLOB.cooking_reagents[recipe_type]))
				to_chat(user, "<span class='alert'>Your [O] contains components unsuitable for cookery.</span>")
				return 1
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/grab))
		return special_attack(O, user)
	else
		to_chat(user, "<span class='alert'>You have no idea what you can cook with this [O].</span>")
		return 1
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/add_item(obj/item/I, mob/user)
	if(!user.drop_item())
		to_chat(user, "<span class='notice'>\The [I] is stuck to your hand, you cannot put it in [src]</span>")
		//return 0
	else
		I.forceMove(src)
		user.visible_message("<span class='notice'>[user] adds [I] to [src].</span>", "<span class='notice'>You add [I] to [src].</span>")

/obj/machinery/kitchen_machine/attack_ai(mob/user)
	return 0

/obj/machinery/kitchen_machine/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/kitchen_machine/proc/special_attack(obj/item/grab/G, mob/user)
	to_chat(user, "<span class='alert'>This is ridiculous. You can not fit [G.affecting] in this [src].</span>")
	return 0

/********************
*   Machine Menu	*
********************/

/obj/machinery/kitchen_machine/interact(mob/user) // The microwave Menu
	if(panel_open || !anchored)
		return
	var/dat = ""
	if(broken > 0)
		dat = {"<code>Bzzzzttttt</code>"}
	else if(operating)
		dat = {"<code>[pick(cook_verbs)] in progress!<BR>Please wait...!</code>"}
	else if(dirty==100)
		dat = {"<code>This [src] is dirty!<BR>Please clean it before use!</code>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for(var/obj/O in contents)
			var/display_name = O.name
			if(istype(O,/obj/item/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if(istype(O,/obj/item/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if(istype(O,/obj/item/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if(istype(O,/obj/item/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if(istype(O,/obj/item/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for(var/O in items_counts)
			var/N = items_counts[O]
			if(!(O in items_measures))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if(N==1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for(var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if(R.id == "capsaicin")
				display_name = "Hotsauce"
			if(R.id == "frostoil")
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if(items_counts.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The [src] is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]"}
		dat += {"<HR><BR>\
<A href='?src=[UID()];action=cook'>Turn on!</A><BR>\
<A href='?src=[UID()];action=dispose'>Eject ingredients!</A><BR>\
"}

	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "[name]")
	return



/************************************
*   Machine Menu Handling/Cooking	*
************************************/

/obj/machinery/kitchen_machine/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if(!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/list/recipes_to_make = choose_recipes()

	if(recipes_to_make.len == 1 && recipes_to_make[1][2] == RECIPE_FAIL)
		//This only runs if there is a single recipe source to be made and it is a failure (the machine was loaded with only 1 mixing bowl that results in failure OR was directly loaded with ingredients that results in failure).
		//If there are multiple sources, this bit gets skipped.
		dirty += 1
		if(prob(max(10,dirty*5)))	//chance to get so dirty we require cleaning before next use
			if(!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			fail()
			return
		else if(has_extra_item())	//if extra items present, break down and require repair before next use
			if(!wzhzhzh(4))
				abort()
				return
			broke()
			fail()
			return
		else	//otherwise just stop without requiring cleaning/repair
			if(!wzhzhzh(10))
				abort()
				return
			stop()
			fail()
			return
	else
		if(!wzhzhzh(5))
			abort()
			return
		if(!wzhzhzh(5))
			abort()
			fail()
			return
		make_recipes(recipes_to_make)

//choose_recipes(): picks out recipes for the machine and any mixing bowls it may contain.
	//builds a list of the selected recipes to be made in a later proc by associating the "source" of the ingredients (mixing bowl, machine) with the recipe for that source
/obj/machinery/kitchen_machine/proc/choose_recipes()
	var/list/recipes_to_make = list()
	for(var/obj/item/mixing_bowl/mb in contents)	//if we have mixing bowls present, check each one for possible recipes from its respective contents. Mixing bowls act like a wrapper for recipes and ingredients, isolating them from other ingredients and mixing bowls within a machine.
		var/datum/recipe/recipe = select_recipe(GLOB.cooking_recipes[recipe_type], mb)
		if(recipe)
			recipes_to_make.Add(list(list(mb, recipe)))
		else	//if the ingredients of the mixing bowl don't make a valid recipe, we return a fail recipe to generate the burned mess
			recipes_to_make.Add(list(list(mb, RECIPE_FAIL)))

	var/datum/recipe/recipe_src = select_recipe(GLOB.cooking_recipes[recipe_type], src, ignored_items = list(/obj/item/mixing_bowl))	//check the machine's directly-inserted ingredients for possible recipes as well, ignoring the mixing bowls when selecting recipe
	if(recipe_src)	//if we found a valid recipe for directly-inserted ingredients, add that to our list
		recipes_to_make.Add(list(list(src, recipe_src)))
	else if(!recipes_to_make.len)	//if the machine has no mixing bowls to make recipes from AND also doesn't have a valid recipe of directly-inserted ingredients, return a failure so we can make a burned mess
		recipes_to_make.Add(list(list(src, RECIPE_FAIL)))
	return recipes_to_make

//make_recipes(recipes_to_make): cycles through the supplied list of recipes and creates each recipe associated with the "source" for that entry
/obj/machinery/kitchen_machine/proc/make_recipes(list/recipes_to_make)
	if(!recipes_to_make)
		return
	var/datum/reagents/temp_reagents = new(500)
	for(var/i=1 to recipes_to_make.len)		//cycle through each entry on the recipes_to_make list for processing
		var/list/L = recipes_to_make[i]
		var/obj/source = L[1]	//this is the source of the recipe entry (mixing bowl or the machine)
		var/datum/recipe/recipe = L[2]	//this is the recipe associated with the source (a valid recipe or null)
		if(recipe == RECIPE_FAIL)		//we have a failure and create a burned mess
			//failed recipe
			fail()
		else	//we have a valid recipe to begin making
			for(var/obj/O in source.contents)	//begin processing the ingredients supplied
				if(istype(O, /obj/item/mixing_bowl))	//ignore mixing bowls present among the ingredients in our source (only really applies to machine sourced recipes)
					continue
				if(O.reagents)
					O.reagents.del_reagent("nutriment")
					O.reagents.update_total()
					O.reagents.trans_to(temp_reagents, O.reagents.total_volume)
				qdel(O)
			source.reagents.clear_reagents()
			for(var/e=1 to efficiency)		//upgraded machine? make additional servings and split the ingredient reagents among each serving equally.
				var/obj/cooked = new recipe.result()
				temp_reagents.trans_to(cooked, temp_reagents.total_volume/efficiency)
				cooked.forceMove(loc)
			temp_reagents.clear_reagents()
			var/obj/byproduct = recipe.get_byproduct()	//if the recipe has a byproduct, handle returning that (such as re-usable candy moulds)
			if(byproduct)
				new byproduct(loc)
			if(istype(source, /obj/item/mixing_bowl))	//if the recipe's source was a mixing bowl, make it a little dirtier and return that for re-use.
				var/obj/item/mixing_bowl/mb = source
				mb.make_dirty(5 * efficiency)
				mb.forceMove(loc)
	stop()
	return

/obj/machinery/kitchen_machine/proc/wzhzhzh(seconds)
	for(var/i=1 to seconds)
		if(stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for(var/obj/O in contents)
		if(!is_type_in_list(O, list(/obj/item/reagent_containers/food, /obj/item/grown, /obj/item/mixing_bowl)))
			return 1
	return 0

/obj/machinery/kitchen_machine/proc/start()
	visible_message("<span class='notice'>\The [src] turns on.</span>", "<span class='notice'>You hear \a [src].</span>")
	operating = 1
	icon_state = on_icon
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/abort()
	operating = 0 // Turn it off again aferwards
	icon_state = off_icon
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/stop()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	operating = 0 // Turn it off again aferwards
	icon_state = off_icon
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/dispose()
	for(var/obj/O in contents)
		O.forceMove(loc)
	if(reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of \the [src]'s contents.</span>")
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	icon_state = dirty_icon // Make it look dirty!!

/obj/machinery/kitchen_machine/proc/muck_finish()
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	visible_message("<span class='alert'>\The [src] gets covered in muck!</span>")
	dirty = 100 // Make it dirty so it can't be used util cleaned
	flags = null //So you can't add condiments
	icon_state = dirty_icon // Make it look dirty too
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/broke()
	do_sparks(2, 1, src)
	icon_state = broken_icon // Make it look all busted up and shit
	visible_message("<span class='alert'>The [src] breaks!</span>") //Let them know they're stupid
	broken = 2 // Make it broken so it can't be used util fixed
	flags = null //So you can't add condiments
	operating = 0 // Turn it off again aferwards
	updateUsrDialog()

/obj/machinery/kitchen_machine/proc/fail()
	var/amount = 0
	for(var/obj/item/mixing_bowl/mb in contents)	//fail and remove any mixing bowls present before making the burned mess from the machine itself (to avoid them being destroyed as part of the failure)
		mb.fail(src)
		mb.forceMove(get_turf(src))
	for(var/obj/O in contents)
		amount++
		if(O.reagents)	//this is reagents in inserted objects (like chems in produce)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	if(reagents && reagents.total_volume)	//this is directly-added reagents (like water added directly into the machine)
		var/id = reagents.get_master_reagent_id()
		if(id)
			amount += reagents.get_reagent_amount(id)
	reagents.clear_reagents()
	if(amount)
		var/obj/item/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
		ffuu.reagents.add_reagent("carbon", amount)
		ffuu.reagents.add_reagent("????", amount/10)
		ffuu.forceMove(get_turf(src))

/obj/machinery/kitchen_machine/Topic(href, href_list)
	if(..() || panel_open)
		return

	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if("cook")
			cook()

		if("dispose")
			dispose()
	return
