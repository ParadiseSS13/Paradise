#define NO_DIRT 0
#define MAX_DIRT 100

/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 100
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
	/// Time between special attacks
	var/special_attack_cooldown_time = 7 SECONDS
	/// Whether or not a special attack can be performed right now
	var/special_attack_on_cooldown = FALSE

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
		GLOB.cooking_ingredients[recipe_type] |= /obj/item/food/grown

/*******************
*   Item Adding
********************/

/obj/machinery/kitchen_machine/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(operating)
		return ITEM_INTERACT_COMPLETE

	if(dirty < MAX_DIRT)
		if(default_deconstruction_screwdriver(user, open_icon, off_icon, used))
			return ITEM_INTERACT_COMPLETE

		if(istype(used, /obj/item/storage/part_replacer))
			return ..()

	default_deconstruction_crowbar(user, used)

	if(dirty == MAX_DIRT) // The machine is all dirty so can't be used!
		if(istype(used, /obj/item/reagent_containers/spray/cleaner) || istype(used, /obj/item/soap) || istype(used, /obj/item/reagent_containers/glass/rag)) // If they're trying to clean it then let them
			user.visible_message("<span class='notice'>[user] starts to clean [src].</span>", "<span class='notice'>You start to clean [src].</span>")
			if(do_after(user, 20 * used.toolspeed, target = src))
				user.visible_message("<span class='notice'>[user] has cleaned [src].</span>", "<span class='notice'>You have cleaned [src].</span>")
				dirty = NO_DIRT
				update_icon(UPDATE_ICON_STATE)
				container_type = OPENCONTAINER
				return ITEM_INTERACT_COMPLETE

		else //Otherwise bad luck!!
			to_chat(user, "<span class='alert'>It's dirty!</span>")
			return ITEM_INTERACT_COMPLETE

	if(is_type_in_list(used, GLOB.cooking_ingredients[recipe_type]))
		if(length(contents) >= max_n_of_items)
			to_chat(user, "<span class='alert'>This [src] is full of ingredients, you cannot put more.</span>")
			return ITEM_INTERACT_COMPLETE

		if(istype(used,/obj/item/stack))
			var/obj/item/stack/S = used
			if(S.get_amount() > 1)
				var/obj/item/stack/to_add = S.split(user, 1)
				to_add.forceMove(src)
				user.visible_message("<span class='notice'>[user] adds one of [S] to [src].</span>", "<span class='notice'>You add one of [S] to [src].</span>")
			else
				add_item(S, user)
		else
			add_item(used, user)

		return ITEM_INTERACT_COMPLETE
	else if(is_type_in_list(used, list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/drinks, /obj/item/reagent_containers/condiment)))
		if(!used.reagents)
			return ITEM_INTERACT_COMPLETE

		for(var/datum/reagent/R in used.reagents.reagent_list)
			if(!(R.id in GLOB.cooking_reagents[recipe_type]))
				to_chat(user, "<span class='alert'>Your [used.name] contains components unsuitable for cookery.</span>")
				return ITEM_INTERACT_COMPLETE
		return ..()
	else if(istype(used, /obj/item/storage))
		var/obj/item/storage/S = used
		if(!S.allow_quick_empty)
			to_chat(user, "<span class='alert'>[used] is too awkward a shape to dump into [src].</span>")
			return ITEM_INTERACT_COMPLETE
		if(length(S.contents) + length(contents) >= max_n_of_items)
			to_chat(user, "<span class='alert'>You can't fit everything from [used] into [src].</span>")
			return ITEM_INTERACT_COMPLETE
		if(length(S.contents) == 0)
			to_chat(user, "<span class='alert'>[used] is empty!</span>")
			return ITEM_INTERACT_COMPLETE
		for(var/obj/item/ingredient in used.contents)
			if(!is_type_in_list(ingredient, GLOB.cooking_ingredients[recipe_type]))
				to_chat(user, "<span class='alert'>Your [used.name] contains contents unsuitable for cookery.</span>")
				return ITEM_INTERACT_COMPLETE
		S.hide_from(user)
		user.visible_message("<span class='notice'>[user] dumps [used] into [src].</span>", "<span class='notice'>You dump [used] into [src].</span>")
		for(var/obj/item/ingredient in used.contents)
			S.remove_from_storage(ingredient, src)
			CHECK_TICK
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/grab))
		var/obj/item/grab/G = used
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='danger'>Slamming [G.affecting] into [src] might hurt them!</span>")
			return ITEM_INTERACT_COMPLETE
		special_attack_grab(G, user)
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='alert'>You have no idea what you can cook with [used].</span>")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/kitchen_machine/wrench_act(mob/living/user, obj/item/I)
	if(operating)
		return

	default_unfasten_wrench(user, I, 0)
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

/obj/machinery/kitchen_machine/proc/special_attack_grab(obj/item/grab/G, mob/user)
	if(special_attack_on_cooldown)
		return FALSE
	if(!istype(G))
		return FALSE
	if(!iscarbon(G.affecting))
		to_chat(user, "<span class='warning'>You can't shove that in there!</span>")
		return FALSE
	if(G.state < GRAB_AGGRESSIVE)
		to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
		return FALSE
	var/result = special_attack(user, G.affecting, TRUE)
	user.changeNext_move(CLICK_CD_MELEE)
	special_attack_on_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, special_attack_on_cooldown, FALSE), special_attack_cooldown_time)
	if(result && !isnull(G) && !QDELETED(G))
		qdel(G)

	return TRUE

/**
 * Perform the special grab interaction.
 * Return TRUE to drop the grab or FALSE to keep the grab afterwards.
 */
/obj/machinery/kitchen_machine/proc/special_attack(mob/user, mob/living/carbon/target, obj/item/grab/G)
	to_chat(user, "<span class='alert'>This is ridiculous. You can not fit [target] in this [src].</span>")
	return FALSE

/obj/machinery/kitchen_machine/shove_impact(mob/living/target, mob/living/attacker)
	if(special_attack_on_cooldown)
		return FALSE

	if(!operating)
		// only do a special interaction if it's actually cooking something
		return FALSE

	return special_attack_shove(target, attacker)

/**
 * Perform a special shove attack.
 * The return value of this proc gets passed up to shove_impact, so returning TRUE will prevent any further shove handling (like knockdown).
 */
/obj/machinery/kitchen_machine/proc/special_attack_shove(mob/living/target, mob/living/attacker)
	return FALSE

/**
 * Check if the machine is running when trying to add reagents to it.
 */
/obj/machinery/kitchen_machine/is_refillable()
	if(operating)
		return FALSE
	. = ..()

/********************
*   Machine Menu	*
********************/

/obj/machinery/kitchen_machine/proc/format_content_descs()
	. = ""
	var/list/items_counts = list()
	var/list/name_overrides = list()
	for(var/obj/O in contents)
		var/display_name = O.name
		if(isfood(O))
			var/obj/item/food/food = O
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

	if(length(recipes_to_make) == 1 && recipes_to_make[1][2] == RECIPE_FAIL)
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
		O.pixel_y = rand(-5, 5)
		O.pixel_x = rand(-5, 5)
	if(reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	to_chat(user, "<span class='notice'>You eject the contents of [src].</span>")
	SStgui.update_uis(src)

//choose_recipes(): picks out recipes for the machine and any mixing bowls it may contain.
	//builds a list of the selected recipes to be made in a later proc by associating the "source" of the ingredients (mixing bowl, machine) with the recipe for that source
/obj/machinery/kitchen_machine/proc/choose_recipes()
	var/list/recipes_to_make = list()

	//check the machine's directly-inserted ingredients for possible recipes as well
	var/datum/recipe/recipe_src = select_recipe(GLOB.cooking_recipes[recipe_type], src)
	if(recipe_src)	//if we found a valid recipe for directly-inserted ingredients, add that to our list
		recipes_to_make.Add(list(list(src, recipe_src)))
	else if(!length(recipes_to_make))	//if the machine has no mixing bowls to make recipes from AND also doesn't have a valid recipe of directly-inserted ingredients, return a failure so we can make a burned mess
		recipes_to_make.Add(list(list(src, RECIPE_FAIL)))
	return recipes_to_make

//make_recipes(recipes_to_make): cycles through the supplied list of recipes and creates each recipe associated with the "source" for that entry
/obj/machinery/kitchen_machine/proc/make_recipes(list/recipes_to_make)
	if(!recipes_to_make)
		return

	var/datum/reagents/temp_reagents = new(500)
	for(var/list/L as anything in recipes_to_make)
		var/obj/source = L[1] // The machine or a mixing bowl
		var/datum/recipe/recipe = L[2] // Valid recipe or RECIPE_FAIL

		if(recipe == RECIPE_FAIL)
			fail()
			continue

		for(var/obj/O in source.contents) // Process supplied ingredients
			if(O.reagents)
				O.reagents.del_reagent("nutriment")
				O.reagents.update_total()
				O.reagents.trans_to(temp_reagents, O.reagents.total_volume, no_react = TRUE) // Don't react with the abstract holder please

			qdel(O)
		source.reagents.clear_reagents()
		var/portions = recipe.duplicate ? efficiency : 1
		var/reagents_per_serving = temp_reagents.total_volume / portions
		for(var/i in 1 to portions) // Extra servings when upgraded, ingredient reagents split equally
			var/obj/cooked = new recipe.result(loc)
			cooked.pixel_y = rand(-5, 5)
			cooked.pixel_x = rand(-5, 5)
			temp_reagents.trans_to(cooked, reagents_per_serving, no_react = TRUE) // Don't react with the abstract holder please
		temp_reagents.clear_reagents()

		var/obj/byproduct = recipe.get_byproduct()
		if(byproduct)
			new byproduct(loc)

	stop()

/obj/machinery/kitchen_machine/proc/wzhzhzh(seconds)
	for(var/i=1 to seconds)
		if(stat & (NOPOWER|BROKEN))
			return FALSE
		use_power(500)
		sleep(10)
	return TRUE

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for(var/obj/O in contents)
		if(!is_type_in_list(O, list(/obj/item/food, /obj/item/grown)))
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
	for(var/obj/O in contents)
		if(O.reagents?.total_volume)
			amount += O.reagents.total_volume
		qdel(O)
	if(reagents?.total_volume)
		amount += reagents.total_volume
	reagents.clear_reagents()
	if(amount)
		var/obj/item/food/badrecipe/mysteryfood = new(src)
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

	if(!HAS_MIND_TRAIT(user, TRAIT_KNOWS_COOKING_RECIPES))
		return

	var/list/recipes = choose_recipes()
	if(length(recipes) == 1 && recipes[1][2] != RECIPE_FAIL)
		var/datum/recipe/recipe = recipes[1][2]
		var/obj/item/result = recipe.result
		. += "<span class='notice'>Your expert chef knowledge tells you that this would make \a [initial(result.name)].</span>"

/obj/machinery/kitchen_machine/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER) || panel_open || !anchored)
		return

	ui_interact(user)

/obj/machinery/kitchen_machine/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/kitchen_machine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/kitchen_machine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KitchenMachine",  name)
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
		if(istype(O, /obj/item/food))
			var/obj/item/food/food = O
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

/obj/machinery/kitchen_machine/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("cook")
			if(!check_useable(ui.user))
				return

			cook()
		if("eject")
			dispose(ui.user)

/obj/machinery/kitchen_machine/AltClick(mob/user)
	if(!Adjacent(user) || !check_useable(user))
		return

	cook()
	to_chat(user, "<span class='notice'>You activate [src].</span>")

/obj/machinery/kitchen_machine/proc/has_cookables()
	return reagents.total_volume > 0 || length(contents)

/obj/machinery/kitchen_machine/proc/check_useable(mob/user)
	if(dirty >= MAX_DIRT)
		to_chat(user, "<span class='warning'>It's too dirty.</span>")
		return FALSE
	if(!has_cookables())
		to_chat(user, "<span class='warning'>It's empty!</span>")
		return FALSE
	if(stat & BROKEN)
		to_chat(user, "<span class='warning'>It's broken!</span>")
		return FALSE
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>It's depowered!</span>")
		return FALSE
	if(panel_open)
		to_chat(user, "<span class='warning'>Its panel is open!</span>")
		return FALSE
	if(!anchored)
		to_chat(user, "<span class='warning'>It's unanchored!</span>")
		return FALSE
	if(operating)
		to_chat(user, "<span class='warning'>Its already cooking!</span>")
		return FALSE
	return TRUE

#undef NO_DIRT
#undef MAX_DIRT
