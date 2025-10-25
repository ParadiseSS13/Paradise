/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "A chef's 9th most powerful weapon, right after the grill. Used for grinding items into reagents."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = new /obj/item/reagent_containers/glass/beaker/large
	var/limit
	var/efficiency

	// IMPORTANT NOTE! A negative number is a multiplier, a positive number is a flat amount to add. 0 means equal to the amount of the original reagent
	var/list/blend_items = list (
		// Sheets
		/obj/item/stack/sheet/mineral/plasma = list("plasma_dust" = 20),
		/obj/item/stack/sheet/metal = list("iron" = 20),
		/obj/item/stack/rods = list("iron" = 10),
		/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma_dust" = 20),
		/obj/item/stack/sheet/wood = list("carbon" = 4),
		/obj/item/stack/sheet/glass = list("silicon" = 20),
		/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
		/obj/item/stack/sheet/mineral/tranquillite = list("nothing" = 20),
		/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
		/obj/item/stack/sheet/saltpetre_crystal = list("saltpetre" = 8),
		/obj/item/stack/sheet/plastic = list("plastic_dust" = 5),

		// Blender Stuff
		/obj/item/food/grown/tomato = list("ketchup" = 0),
		/obj/item/food/grown/wheat = list("flour" = -5),
		/obj/item/food/grown/oat = list("flour" = -5),
		/obj/item/food/grown/cherries = list("cherryjelly" = 0),
		/obj/item/food/grown/bluecherries = list("bluecherryjelly" = 0),
		/obj/item/food/egg = list("egg" = -5),
		/obj/item/food/grown/rice = list("rice" = -5),
		/obj/item/food/grown/olive = list("olivepaste" = 0, "sodiumchloride" = 0),
		/obj/item/food/grown/peanuts = list("peanutbutter" = 0),

		// Grinder stuff, but only if dry
		/obj/item/food/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
		/obj/item/food/grown/coffee = list("coffeepowder" = 0),
		/obj/item/food/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		/obj/item/food/grown/tea = list("teapowder" = 0),

		// All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/slime_extract = list(),
		/obj/item/food = list(),
		/obj/item/reagent_containers/pill = list(),
		/obj/item/reagent_containers/patch = list(),
		/obj/item/clothing/mask/cigarette = list(),
		/obj/item/grown = list()
	)

	var/list/juice_items = list (
		// Juicer Stuff
		/obj/item/food/grown/soybeans = list("soymilk" = 0),
		/obj/item/food/grown/corn = list("corn_starch" = 0),
		/obj/item/food/grown/tomato = list("tomatojuice" = 0),
		/obj/item/food/grown/carrot = list("carrotjuice" = 0),
		/obj/item/food/grown/berries = list("berryjuice" = 0),
		/obj/item/food/grown/banana = list("banana" = 0),
		/obj/item/food/grown/potato = list("potato" = 0),
		/obj/item/food/grown/citrus/lemon = list("lemonjuice" = 0),
		/obj/item/food/grown/citrus/orange = list("orangejuice" = 0),
		/obj/item/food/grown/citrus/lime = list("limejuice" = 0),
		/obj/item/food/grown/watermelon = list("watermelonjuice" = 0),
		/obj/item/food/sliced/watermelon = list("watermelonjuice" = 0),
		/obj/item/food/grown/berries/poison = list("poisonberryjuice" = 0),
		/obj/item/food/grown/pumpkin/blumpkin = list("blumpkinjuice" = 0), // Order is important here as blumpkin is a subtype of pumpkin, if switched blumpkins will produce pumpkin juice
		/obj/item/food/grown/pumpkin = list("pumpkinjuice" = 0),
		/obj/item/food/grown/apple = list("applejuice" = 0),
		/obj/item/food/grown/grapes = list("grapejuice" = 0),
		/obj/item/food/grown/pineapple = list("pineapplejuice" = 0),
		/obj/item/food/grown/bungofruit = list("bungojuice" = 0)
	)

	var/list/dried_items = list(
		// Grinder stuff, but only if dry,
		/obj/item/food/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
		/obj/item/food/grown/coffee = list("coffeepowder" = 0),
		/obj/item/food/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		/obj/item/food/grown/tea = list("teapowder" = 0)
	)

	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/empty
	icon_state = "juicer0"
	beaker = null

/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/reagentgrinder(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/reagentgrinder/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	limit = 10 * H
	efficiency = 0.8 + T * 0.1

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/reagentgrinder/ex_act(severity)
	if(beaker)
		beaker.ex_act(severity)
	..()

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	if(A == beaker)
		beaker = null
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/reagentgrinder/update_icon_state()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored || beaker)
		return
	if(!panel_open)
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/reagentgrinder/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored)
		return
	if(!I.tool_use_check(user, 0))
		return
	detach(user)
	default_deconstruction_screwdriver(user, "juicer_open", "juicer0", I)

/obj/machinery/reagentgrinder/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/reagentgrinder/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		. = ..()
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	if((istype(used, /obj/item/reagent_containers) && (used.container_type & OPENCONTAINER)) && user.a_intent != INTENT_HARM)
		if(beaker)
			to_chat(user, "<span class='warning'>There's already a container inside.</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
		else if(user.transfer_item_to(used, src))
			beaker = used
			update_icon(UPDATE_ICON_STATE)
			SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	if(is_type_in_list(used, dried_items))
		if(istype(used, /obj/item/food/grown))
			var/obj/item/food/grown/G = used
			if(!G.dry)
				to_chat(user, "<span class='warning'>You must dry that first!</span>")
				return ITEM_INTERACT_COMPLETE

	if(length(holdingitems) >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return ITEM_INTERACT_COMPLETE

	// Fill machine with a bag!
	if(istype(used, /obj/item/storage/bag))
		var/obj/item/storage/bag/B = used
		if(!length(B.contents))
			to_chat(user, "<span class='warning'>[B] is empty.</span>")
			return ITEM_INTERACT_COMPLETE

		var/original_contents_len = length(B.contents)

		for(var/obj/item/G in B.contents)
			if(is_type_in_list(G, blend_items) || is_type_in_list(G, juice_items))
				B.remove_from_storage(G, src)
				holdingitems += G
				if(length(holdingitems) >= limit) // Sanity checking so the blender doesn't overfill
					to_chat(user, "<span class='notice'>You fill the All-In-One grinder to the brim.</span>")
					break

		if(length(B.contents) == original_contents_len)
			to_chat(user, "<span class='warning'>Nothing in [B] can be put into the All-In-One grinder.</span>")
			return ITEM_INTERACT_COMPLETE

		else if(!length(B.contents))
			to_chat(user, "<span class='notice'>You empty all of [B]'s contents into the All-In-One grinder.</span>")
		else
			to_chat(user, "<span class='notice'>You empty some of [B]'s contents into the All-In-One grinder.</span>")

		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	if(!is_type_in_list(used, blend_items) && !is_type_in_list(used, juice_items))
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>Cannot refine into a reagent!</span>")
			return ITEM_INTERACT_COMPLETE

	if(user.transfer_item_to(used, src))
		holdingitems += used
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/reagentgrinder/attack_ai(mob/user)
	return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/reagentgrinder/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/reagentgrinder/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/reagentgrinder/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReagentGrinder", name)
		ui.open()

/obj/machinery/reagentgrinder/ui_data(mob/user)
	var/list/data = list()
	data["operating"] = operating
	data["inactive"] = length(holdingitems) == 0 ? TRUE : FALSE
	data["limit"] = limit
	data["count"] = length(holdingitems)
	data["beaker_loaded"] = beaker ? TRUE : FALSE
	data["beaker_current_volume"] = beaker ? beaker.reagents.total_volume : null
	data["beaker_max_volume"] = beaker ? beaker.reagents.maximum_volume : null
	var/list/beakerContents = list()
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // List in a list because Byond merges the first list...
	data["beaker_contents"] = beakerContents

	var/list/items_counts = list()
	var/list/name_overrides = list()
	for(var/obj/O in holdingitems)
		var/display_name = O.name
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/S = O
			if(!items_counts[display_name])
				items_counts[display_name] = 0
				if(S.singular_name)
					name_overrides[display_name] = S.singular_name
				else
					name_overrides[display_name] = display_name
				if(S.amount > 1)
					name_overrides[display_name] = "[name_overrides[display_name]]s" // name_overrides[display_name] Will be set on the first time as the singular form

			items_counts[display_name] += S.amount
			continue

		else if(isfood(O))
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
					name_overrides[display_name] = "[name_overrides[display_name]]s" // name_overrides[display_name] Will be set on the first time as the singular form

		items_counts[display_name]++

	data["contents"] = list()
	for(var/item in items_counts)
		var/N = items_counts[item]
		var/units
		if(!(item in name_overrides))
			units = "[lowertext(item)]"
		else
			units = "[name_overrides[item]]"

		var/list/data_pr = list(
			"name" = capitalize(item),
			"amount" = N,
			"units" = units
		)

		data["contents"] += list(data_pr)
	return data

/obj/machinery/reagentgrinder/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("detach")
			detach(ui.user)
		if("eject")
			eject(ui.user)
		if("grind")
			grind()
		if("juice")
			juice()

/obj/machinery/reagentgrinder/proc/detach(mob/user)
	if(!beaker)
		return
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	beaker.forceMove(loc)
	beaker = null
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!length(holdingitems))
		return

	for(var/obj/item/O in holdingitems)
		O.forceMove(loc)
		holdingitems -= O
	holdingitems = list()
	SStgui.update_uis(src)

/obj/machinery/reagentgrinder/proc/get_special_blend(obj/item/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_special_juice(obj/item/food/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/grown/O)
	if(!istype(O) || !O.seed)
		return 5
	else if(O.seed.potency == -1)
		return 5
	else
		return round(O.seed.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/food/grown/O)
	if(!istype(O) || !O.seed)
		return 5
	else if(O.seed.potency == -1)
		return 5
	else
		return round(5 * sqrt(O.seed.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beaker || beaker.reagents.holder_full())
		return

	playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) // Start shaking
	operating = TRUE
	SStgui.update_uis(src)
	spawn(5 SECONDS)
		pixel_x = initial(pixel_x) // Return to its spot after shaking
		operating = FALSE
		SStgui.update_uis(src)

	// Snacks
	for(var/obj/item/food/O in holdingitems)
		var/list/special_juice = get_special_juice(O)
		if(!length(special_juice))
			continue // Ignore food that doesn't juice into anything

		for(var/r_id in special_juice)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume

			beaker.reagents.add_reagent(r_id, min(get_juice_amount(O) * efficiency, space))

			if(beaker.reagents.holder_full())
				break

		remove_object(O)
		if(beaker.reagents.holder_full())
			return

/obj/machinery/reagentgrinder/proc/grind()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beaker || beaker.reagents.holder_full())
		return

	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	animate(src, pixel_x = pick(-3, -2, 2, 3), pixel_y = pick(-3, -2, 2, 3), time = 1 DECISECONDS, loop = 20, easing = JUMP_EASING)
	animate(pixel_x = 0, pixel_y = 0, time = 1 DECISECONDS, easing = JUMP_EASING)
	operating = TRUE
	SStgui.update_uis(src)
	spawn(6 SECONDS)
		pixel_x = initial(pixel_x) // Return to its spot after shaking
		operating = FALSE
		SStgui.update_uis(src)

	// Snacks and Plants
	for(var/obj/item/food/O in holdingitems)
		var/list/special_blend = get_special_blend(O)
		for(var/r_id in special_blend)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = special_blend[r_id]


			if(amount == 0)
				if(O.reagents.has_reagent("nutriment"))
					beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment") * efficiency, space))
					O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				if(O.reagents.has_reagent("plantmatter"))
					beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("plantmatter") * efficiency, space))
					O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
			else if(amount < 0)
				if(O.reagents.has_reagent("nutriment"))
					beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment") * abs(amount) * efficiency), space))
					O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				if(O.reagents.has_reagent("plantmatter"))
					beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("plantmatter") * abs(amount) * efficiency), space))
					O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if(beaker.reagents.holder_full())
				break

		O.reagents.trans_to(beaker, O.reagents.total_volume)

		if(!O.reagents.total_volume)
			remove_object(O)
		if(beaker.reagents.holder_full())
			return
	// Inedible Plants
	for(var/obj/item/grown/O in holdingitems)
		var/list/special_blend = get_special_blend(O)
		for(var/r_id in special_blend)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = special_blend[r_id]

			if(amount == 0)
				if(O.reagents.has_reagent("nutriment"))
					beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment") * efficiency, space))
					O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				if(O.reagents.has_reagent("plantmatter"))
					beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("plantmatter") * efficiency, space))
					O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
			else if(amount < 0)
				if(O.reagents.has_reagent("nutriment"))
					beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment") * abs(amount) * efficiency), space))
					O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				if(O.reagents.has_reagent("plantmatter"))
					beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("plantmatter") * abs(amount) * efficiency), space))
					O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if(beaker.reagents.holder_full())
				break

		O.reagents.trans_to(beaker, O.reagents.total_volume)

		if(!O.reagents.total_volume)
			remove_object(O)
		if(beaker.reagents.holder_full())
			return

	// Sheets and rods(!)
	for(var/obj/item/stack/O in holdingitems)
		var/list/special_blend = get_special_blend(O)
		if(!length(special_blend))
			continue // Ignore stackables that don't grind into anything

		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		while(O.amount)
			O.amount--

			for(var/r_id in special_blend)
				var/spaceused = min(special_blend[r_id] * efficiency, space)
				space -= spaceused
				beaker.reagents.add_reagent(r_id, spaceused)

			if(O.amount < 1) // If leftover small - destroy
				remove_object(O)
				break
			if(beaker.reagents.holder_full())
				return

	// Slime Extracts
	for(var/obj/item/slime_extract/O in holdingitems)
		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume

		if(O.reagents)
			var/amount = O.reagents.total_volume
			O.reagents.trans_to(beaker, min(amount, space))
		if(O.Uses > 0)
			beaker.reagents.add_reagent("slimejelly", min(20 * efficiency, space))

		remove_object(O)
		if(beaker.reagents.holder_full())
			return

	// Everything else - Transfers reagents from the items into the beaker
	for(var/obj/item/O in holdingitems)
		O.reagents.trans_to(beaker, O.reagents.total_volume)
		if(!O.reagents.total_volume)
			remove_object(O)
		if(beaker.reagents.holder_full())
			return
