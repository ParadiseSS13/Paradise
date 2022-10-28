#define NO_DIRT 0
#define MAX_DIRT 100

/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	container_type = OPENCONTAINER
	var/operating = FALSE // Is it on?
	var/dirty = NO_DIRT // = {0..100} Does it need cleaning?
	var/efficiency = 0
	var/list/cook_verbs = list("Cooking")
	//Recipe & Item vars
	var/recipe_type		//Make sure to set this on the machine definition, or else you're gonna runtime on New()
	var/max_n_of_items = 25
	//Icon states
	var/off_icon
	var/on_icon
	var/dirty_icon
	var/open_icon
	///Sound used when starting and ending cooking
	var/datum/looping_sound/kitchen/soundloop
	var/soundloop_type

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/Initialize(mapload)
	. = ..()
	if(soundloop_type)
		soundloop = new soundloop_type(list(src), FALSE)
	create_reagents(100)
	reagents.set_reacting(FALSE)
	init_lists()

/obj/machinery/kitchen_machine/Destroy()
	QDEL_NULL(soundloop)
	return ..()

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
	if(dirty < MAX_DIRT)
		if(default_deconstruction_screwdriver(user, open_icon, off_icon, O))
			return
		if(exchange_parts(user, O))
			return

	default_deconstruction_crowbar(user, O)

	if(dirty == MAX_DIRT) // The machine is all dirty so can't be used!
		if(istype(O, /obj/item/reagent_containers/spray/cleaner) || istype(O, /obj/item/soap)) // If they're trying to clean it then let them
			user.visible_message("<span class='notice'>[user] starts to clean [src].</span>", "<span class='notice'>You start to clean [src].</span>")
			if(do_after(user, 20 * O.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] has cleaned [src].</span>", "<span class='notice'>You have cleaned [src].</span>")
				dirty = NO_DIRT
				update_icon(UPDATE_ICON_STATE)
				container_type = OPENCONTAINER
				return TRUE
		else //Otherwise bad luck!!
			to_chat(user, "<span class='alert'>It's dirty!</span>")
			return TRUE
	else if(is_type_in_list(O, GLOB.cooking_ingredients[recipe_type]) || istype(O, /obj/item/mixing_bowl))
		if(length(contents) >= max_n_of_items)
			to_chat(user, "<span class='alert'>This [src] is full of ingredients, you cannot put more.</span>")
			return TRUE
		if(istype(O,/obj/item/stack))
			var/obj/item/stack/S = O
			if(S.get_amount() > 1)
				var/obj/item/stack/to_add = S.split(user, 1)
				to_add.forceMove(src)
				user.visible_message("<span class='notice'>[user] adds one of [S] to [src].</span>", "<span class='notice'>You add one of [S] to [src].</span>")
			else
				add_item(S, user)
		else
			add_item(O, user)
	else if(is_type_in_list(O, list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/drinks, /obj/item/reagent_containers/food/condiment)))
		if(!O.reagents)
			return TRUE
		for(var/datum/reagent/R in O.reagents.reagent_list)
			if(!(R.id in GLOB.cooking_reagents[recipe_type]))
				to_chat(user, "<span class='alert'>Your [O] contains components unsuitable for cookery.</span>")
				return TRUE
	else if(istype(O,/obj/item/grab))
		return special_attack(O, user)
	else
		to_chat(user, "<span class='alert'>You have no idea what you can cook with [O].</span>")
		return TRUE

/obj/machinery/kitchen_machine/wrench_act(mob/living/user, obj/item/I)
	if(operating)
		return

	I.play_tool_sound(src)
	if(anchored)
		to_chat(user, "<span class='alert'>[src] can now be moved.</span>")
	else
		to_chat(user, "<span class='alert'>[src] is now secured.</span>")
	anchored = !anchored
	return TRUE

/obj/machinery/kitchen_machine/proc/add_item(obj/item/I, mob/user)
	if(!user.drop_item())
		to_chat(user, "<span class='notice'>[I] is stuck to your hand, you cannot put it in [src]</span>")
		return

	I.forceMove(src)
	user.visible_message("<span class='notice'>[user] adds [I] to [src].</span>", "<span class='notice'>You add [I] to [src].</span>")
	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/attack_ai(mob/user)
	return FALSE

/obj/machinery/kitchen_machine/proc/special_attack(obj/item/grab/G, mob/user)
	to_chat(user, "<span class='alert'>This is ridiculous. You can not fit [G.affecting] in this [src].</span>")
	return FALSE

/********************
*   Machine Menu	*
********************/

/obj/machinery/kitchen_machine/proc/format_content_descs()
	. = ""
	var/list/items_counts = list()
	var/list/name_overrides = list()
	for(var/obj/O in contents)
		var/display_name = O.name
		if(istype(O, /obj/item/reagent_containers/food))
			var/obj/item/reagent_containers/food/food = O
			if(!items_counts[display_name])
				if(food.ingredient_name)
					name_overrides[display_name] = food.ingredient_name
				else
					name_overrides[display_name] = display_name
			else
				if(food.ingredient_name_plural)
					name_overrides[display_name] = food.ingredient_name_plural
				else if(items_counts[display_name] == 1) // Must only add "s" once or you get stuff like "eggsssss"
					name_overrides[display_name] = "[name_overrides[display_name]]s" //name_overrides[display_name] Will be set on the first time as the singular form

		items_counts[display_name]++

	for(var/O in items_counts)
		var/N = items_counts[O]
		if(!(O in name_overrides))
			. += {"<b>[capitalize(O)]:</b> [N] [lowertext(O)]\s<br>"}
		else
			if(N==1)
				. += {"<b>[capitalize(O)]:</b> [N] [name_overrides[O]]<br>"}
			else
				. += {"<b>[capitalize(O)]:</b> [N] [name_overrides[O]]<br>"}

	for(var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if(R.id == "capsaicin")
			display_name = "Hotsauce"
		if(R.id == "frostoil")
			display_name = "Coldsauce"

		. += {"<b>[display_name]:</b> [R.volume] unit\s<br>"}

/************************************
*   Machine Menu Handling/Cooking	*
************************************/

/obj/machinery/kitchen_machine/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(!has_cookables()) //dry run
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
		if(prob(max(10, dirty * 5) || has_extra_item()))	// 5% failure per failed recipee, maxed at 10%, or it has an extra item
			if(!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			fail()
			return
		else	//otherwise just stop without requiring cleaning
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

/obj/machinery/kitchen_machine/proc/dispose(mob/user)
	for(var/obj/O in contents)
		O.forceMove(loc)
	if(reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	to_chat(user, "<span class='notice'>You eject the contents of [src].</span>")
	SStgui.update_uis(src)

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
					O.reagents.trans_to(temp_reagents, O.reagents.total_volume, no_react = TRUE) // Don't react with the abstract holder please
				qdel(O)
			source.reagents.clear_reagents()
			for(var/e=1 to efficiency)		//upgraded machine? make additional servings and split the ingredient reagents among each serving equally.
				var/obj/cooked = new recipe.result()
				temp_reagents.trans_to(cooked, temp_reagents.total_volume/efficiency, no_react = TRUE) // Don't react with the abstract holder please
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
			return FALSE
		use_power(500)
		sleep(10)
	return TRUE

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for(var/obj/O in contents)
		if(!is_type_in_list(O, list(/obj/item/reagent_containers/food, /obj/item/grown, /obj/item/mixing_bowl)))
			return TRUE
	return FALSE

/obj/machinery/kitchen_machine/proc/start()
	visible_message("<span class='notice'>[src] turns on.</span>", blind_message = "<span class='notice'>You hear \a [src].</span>")
	if(soundloop)
		soundloop.start()
	else
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
	operating = TRUE
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/kitchen_machine/proc/finish_sound()
	if(soundloop)
		soundloop.stop()
	else
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)

/obj/machinery/kitchen_machine/proc/abort()
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/kitchen_machine/proc/stop()
	finish_sound()
	operating = FALSE // Turn it off again aferwards
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	dirty = MAX_DIRT // Make it dirty so it can't be used until cleaned
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/kitchen_machine/proc/muck_finish()
	visible_message("<span class='alert'>[src] gets covered in muck!</span>")
	flags = null //So you can't add condiments
	stop()

/obj/machinery/kitchen_machine/proc/fail()
	var/amount = 0
	for(var/obj/item/mixing_bowl/mb in contents)	//fail and remove any mixing bowls present before making the burned mess from the machine itself (to avoid them being destroyed as part of the failure)
		mb.fail(src)
		mb.forceMove(get_turf(src))
	for(var/obj/O in contents)
		if(O.reagents?.total_volume)
			amount += O.reagents.total_volume
		qdel(O)
	if(reagents?.total_volume)
		amount += reagents.total_volume
	reagents.clear_reagents()
	if(amount)
		var/obj/item/reagent_containers/food/snacks/badrecipe/mysteryfood = new(src)
		mysteryfood.reagents.add_reagent("carbon", amount / 2)
		mysteryfood.reagents.add_reagent("????", amount / 15)
		mysteryfood.forceMove(get_turf(src))

/obj/machinery/kitchen_machine/update_icon_state()
	. = ..()
	if(dirty == MAX_DIRT)
		icon_state = dirty_icon
		return
	if(operating)
		icon_state = on_icon
	else
		icon_state = off_icon

/obj/machinery/kitchen_machine/build_reagent_description(mob/user)
	return

/obj/machinery/kitchen_machine/examine(mob/user)
	. = ..()
	var/dat = format_content_descs()
	if(dat)
		. += "It contains: <br>[dat]"

/obj/machinery/kitchen_machine/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER) || panel_open || !anchored)
		return

	ui_interact(user)

/obj/machinery/kitchen_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "KitchenMachine",  name, 400, 300, master_ui, state)
		ui.open()

/obj/machinery/kitchen_machine/ui_data(mob/user)
	var/list/data = list()
	data["operating"] = operating
	data["inactive"] = FALSE
	data["no_eject"] = FALSE
	data["tooltip"] = ""
	if(dirty >= MAX_DIRT)
		data["inactive"] = TRUE
		data["tooltip"] = "It's too dirty."
	else if(!has_cookables())
		data["inactive"] = TRUE
		data["no_eject"] = TRUE
		data["tooltip"] = "There are no contents."

	var/list/items_counts = list()
	var/list/name_overrides = list()
	for(var/obj/O in contents)
		var/display_name = O.name
		if(istype(O, /obj/item/reagent_containers/food))
			var/obj/item/reagent_containers/food/food = O
			if(!items_counts[display_name])
				if(food.ingredient_name)
					name_overrides[display_name] = food.ingredient_name
				else
					name_overrides[display_name] = display_name
			else
				if(food.ingredient_name_plural)
					name_overrides[display_name] = food.ingredient_name_plural
				else
					name_overrides[display_name] = "[name_overrides[display_name]]\s" //name_overrides[display_name] Will be set on the first time as the singular form

		items_counts[display_name]++

	data["ingredients"] = list()
	for(var/food in items_counts)
		var/N = items_counts[food]
		var/units
		if(!(food in name_overrides))
			units = "[lowertext(food)]"
		else
			units = "[name_overrides[food]]"

		var/list/data_pr = list(
			"name" = capitalize(food),
			"amount" = N,
			"units" = units
		)

		data["ingredients"] += list(data_pr)

	for(var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if(R.id == "capsaicin")
			display_name = "Hotsauce"
		if(R.id == "frostoil")
			display_name = "Coldsauce"

		var/unitamt = "unit"
		if(R.volume > 1)
			unitamt = "units"

		var/list/data_pr = list(
			"name" = display_name,
			"amount" = R.volume,
			"units" = unitamt
		)

		data["ingredients"] += list(data_pr)

	return data

/obj/machinery/kitchen_machine/ui_static_data(mob/user)
	var/list/data = list()
	data["name"] = name
	return data

/obj/machinery/kitchen_machine/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("cook")
			cook()
		if("eject")
			dispose(ui.user)

/obj/machinery/kitchen_machine/AltClick(mob/user)
	if(dirty >= MAX_DIRT)
		to_chat(user, "<span class='warning'>It's too dirty.</span>")
		return
	if(!has_cookables())
		to_chat(user, "<span class='warning'>It's empty!</span>")
		return

	cook()
	to_chat(user, "<span class='notice'>You activate [src].</span>")

/obj/machinery/kitchen_machine/proc/has_cookables()
	return reagents.total_volume > 0 || length(contents)

#undef NO_DIRT
#undef MAX_DIRT
