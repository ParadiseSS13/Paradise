#define PROCESS_TIME 6

/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "A chef's 9th most powerful weapon, right after the grill. Used for grinding items into reagents."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/beaker = new /obj/item/reagent_containers/glass/beaker/large
	var/limit
	var/processTime = PROCESS_TIME
	var/efficiency
	var/obj/item/reagent_containers/internal = null

	// IMPORTANT NOTE! A negative number is a multiplier, a positive number is a flat amount to add. 0 means equal to the amount of the original reagent
	var/list/blend_items = list (
		// Sheets
		/obj/item/stack/sheet/mineral/plasma = list("plasma_dust" = 20),
		/obj/item/stack/sheet/metal = list("iron" = 20),
		/obj/item/stack/rods = list("iron" = 10),
		/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma_dust" = 20),
		/obj/item/stack/sheet/wood = list("carbon" = 20),
		/obj/item/stack/sheet/glass = list("silicon" = 20),
		/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
		/obj/item/stack/sheet/mineral/tranquillite = list("nothing" = 20),
		/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold = list("gold" = 20),

		/obj/item/grown/nettle/basic = list("wasabi" = 0),
		/obj/item/grown/nettle/death = list("facid" = 0, "sacid" = 0),
		/obj/item/grown/novaflower = list("capsaicin" = 0, "condensedcapsaicin" = 0),

		// Blender Stuff
		/obj/item/food/snacks/grown/tomato = list("ketchup" = 0),
		/obj/item/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/food/snacks/grown/oat = list("flour" = -5),
		/obj/item/food/snacks/grown/cherries = list("cherryjelly" = 0),
		/obj/item/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
		/obj/item/food/snacks/egg = list("egg" = -5),
		/obj/item/food/snacks/grown/rice = list("rice" = -5),
		/obj/item/food/snacks/grown/olive = list("olivepaste" = 0, "sodiumchloride" = 0),
		/obj/item/food/snacks/grown/peanuts = list("peanutbutter" = 0),

		// Grinder stuff, but only if dry
		/obj/item/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
		/obj/item/food/snacks/grown/coffee = list("coffeepowder" = 0),
		/obj/item/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		/obj/item/food/snacks/grown/tea = list("teapowder" = 0),

		// All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/slime_extract = list(),
		/obj/item/food = list(),
		/obj/item/reagent_containers/pill = list(),
		/obj/item/reagent_containers/patch = list(),
		/obj/item/clothing/mask/cigarette = list()
	)

	var/list/juice_items = list (
		// Juicer Stuff
		/obj/item/food/snacks/grown/soybeans = list("soymilk" = 0),
		/obj/item/food/snacks/grown/corn = list("corn_starch" = 0),
		/obj/item/food/snacks/grown/tomato = list("tomatojuice" = 0),
		/obj/item/food/snacks/grown/carrot = list("carrotjuice" = 0),
		/obj/item/food/snacks/grown/berries = list("berryjuice" = 0),
		/obj/item/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/food/snacks/grown/potato = list("potato" = 0),
		/obj/item/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
		/obj/item/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
		/obj/item/food/snacks/grown/citrus/lime = list("limejuice" = 0),
		/obj/item/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
		/obj/item/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
		/obj/item/food/snacks/grown/pumpkin/blumpkin = list("blumpkinjuice" = 0), // Order is important here as blumpkin is a subtype of pumpkin, if switched blumpkins will produce pumpkin juice
		/obj/item/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
		/obj/item/food/snacks/grown/apple = list("applejuice" = 0),
		/obj/item/food/snacks/grown/grapes = list("grapejuice" = 0),
		/obj/item/food/snacks/grown/pineapple = list("pineapplejuice" = 0)
	)

	var/list/dried_items = list(
		// Grinder stuff, but only if dry,
		/obj/item/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
		/obj/item/food/snacks/grown/coffee = list("coffeepowder" = 0),
		/obj/item/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		/obj/item/food/snacks/grown/tea = list("teapowder" = 0)
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
	limit = (internal ? 40 : 10) * H
	efficiency = 0.8 + T * 0.1
	//Faster by 1 second for every tier on both manipulators, down to 2 seconds at tier 4
	processTime = PROCESS_TIME - (internal ? T * 0.5 : 0)
	//Tank volume doubles with each tier of matter bin, starting at 1000.
	if(internal)
		internal.reagents.maximum_volume = 1000 * 2**(H-1)

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
		icon_state = internal?"botanitank_beaker":"juicer1"
	else
		icon_state = internal?"botanitank_empty":"juicer0"

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
	if(!anchored || beaker)
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, internal?"botanitank_open":"juicer_open", internal?"botanitank_empty":"juicer0", I)

/obj/machinery/reagentgrinder/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		SStgui.update_uis(src)
		return

	if((istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER)) && user.a_intent != INTENT_HARM)
		if(beaker)
			to_chat(user, "<span class='warning'>There's already a container inside.</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
		else
			if(!user.drop_item())
				return FALSE
			beaker =  I
			beaker.loc = src
			update_icon(UPDATE_ICON_STATE)
			SStgui.update_uis(src)
		return TRUE // No afterattack

	if(is_type_in_list(I, dried_items))
		if(istype(I, /obj/item/food/snacks/grown))
			var/obj/item/food/snacks/grown/G = I
			if(!G.dry)
				to_chat(user, "<span class='warning'>You must dry that first!</span>")
				return FALSE

	if(length(holdingitems) >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return FALSE

	// Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/obj/item/storage/bag/B = I
		if(!length(B.contents))
			to_chat(user, "<span class='warning'>[B] is empty.</span>")
			return FALSE

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
			return FALSE
		else if(!length(B.contents))
			to_chat(user, "<span class='notice'>You empty all of [B]'s contents into the All-In-One grinder.</span>")
		else
			to_chat(user, "<span class='notice'>You empty some of [B]'s contents into the All-In-One grinder.</span>")

		SStgui.update_uis(src)
		return TRUE

	if(!is_type_in_list(I, blend_items) && !is_type_in_list(I, juice_items))
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>Cannot refine into a reagent!</span>")
			return TRUE

	if(user.drop_item())
		I.loc = src
		holdingitems += I
		SStgui.update_uis(src)
		return FALSE

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
	data["reagent_storage"] = internal ? TRUE : FALSE
	data["tank_contents"] = null

	if(internal)
		var/list/items = list()
		for(var/i in 1 to length(internal.reagents.reagent_list))
			var/datum/reagent/K = internal.reagents.reagent_list[i]
			if(K.volume > 0)
				items.Add(list(list("display_name" = K.name, "dispense" = i, "quantity" = K.volume)))

		if(length(items))
			data["tank_contents"] = items
		data["tank_current_volume"] = internal.reagents.total_volume
		data["tank_max_volume"]  = internal.reagents.maximum_volume

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
	if(internal)
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
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!beaker)
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

/obj/machinery/reagentgrinder/proc/get_special_juice(obj/item/food/snacks/O)
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

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/food/snacks/grown/O)
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
	var/obj/item/reagent_containers/B = null
	if(internal)
		B = internal
	else
		B = beaker
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!B || B.reagents.holder_full())
		return

	playsound(src.loc, 'sound/machines/juicer.ogg', 20, TRUE)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) // Start shaking
	operating = TRUE
	SStgui.update_uis(src)
	spawn((processTime - 1) SECONDS)
		pixel_x = initial(pixel_x) // Return to its spot after shaking
		operating = FALSE
		SStgui.update_uis(src)

	// Snacks
	for(var/obj/item/food/snacks/O in holdingitems)
		var/list/special_juice = get_special_juice(O)
		if(!length(special_juice))
			continue // Ignore food that doesn't juice into anything

		for(var/r_id in special_juice)
			var/space = B.reagents.maximum_volume - B.reagents.total_volume

			B.reagents.add_reagent(r_id, min(get_juice_amount(O) * efficiency, space))

			if(B.reagents.holder_full())
				break

		remove_object(O)
		if(B.reagents.holder_full())
			return

/obj/machinery/reagentgrinder/proc/grind()
	var/obj/item/reagent_containers/B = null
	if(internal)
		B = internal
	else
		B = beaker
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!B || B.reagents.holder_full())
		return

	playsound(loc, 'sound/machines/blender.ogg', 50, TRUE)
	animate(src, pixel_x = pick(-3, -2, 2, 3), pixel_y = pick(-3, -2, 2, 3), time = 1 DECISECONDS, loop = 20, easing = JUMP_EASING)
	animate(pixel_x = 0, pixel_y = 0, time = 1 DECISECONDS, easing = JUMP_EASING)
	operating = TRUE
	SStgui.update_uis(src)
	spawn(processTime SECONDS)
		pixel_x = initial(pixel_x) // Return to its spot after shaking
		operating = FALSE
		SStgui.update_uis(src)

	// Snacks and Plants
	for(var/obj/item/food/snacks/O in holdingitems)
		var/list/special_blend = get_special_blend(O)
		for(var/r_id in special_blend)
			var/space = B.reagents.maximum_volume - B.reagents.total_volume
			var/amount = special_blend[r_id]

			if(amount <= 0)
				if(amount == 0)
					if(O.reagents.has_reagent("nutriment"))
						B.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment") * efficiency, space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					if(O.reagents.has_reagent("plantmatter"))
						B.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("plantmatter") * efficiency, space))
						O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
				else
					if(O.reagents.has_reagent("nutriment"))
						B.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment") * abs(amount) * efficiency), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					if(O.reagents.has_reagent("plantmatter"))
						B.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("plantmatter") * abs(amount) * efficiency), space))
						O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
			else
				O.reagents.trans_id_to(B, r_id, min(amount, space))

			if(B.reagents.holder_full())
				break

		O.reagents.trans_to(B, O.reagents.total_volume)

		if(!O.reagents.total_volume)
			remove_object(O)
		if(B.reagents.holder_full())
			return

	// Sheets and rods(!)
	for(var/obj/item/stack/O in holdingitems)
		var/list/special_blend = get_special_blend(O)
		if(!length(special_blend))
			continue // Ignore stackables that don't grind into anything

		var/space = B.reagents.maximum_volume - B.reagents.total_volume
		while(O.amount)
			O.amount--

			for(var/r_id in special_blend)
				var/spaceused = min(special_blend[r_id] * efficiency, space)
				space -= spaceused
				B.reagents.add_reagent(r_id, spaceused)

			if(O.amount < 1) // If leftover small - destroy
				remove_object(O)
				break
			if(B.reagents.holder_full())
				return

	// Plants
	for(var/obj/item/grown/O in holdingitems)
		var/list/special_blend = get_special_blend(O)
		for(var/r_id in special_blend)
			var/space = B.reagents.maximum_volume - B.reagents.total_volume
			var/amount = special_blend[r_id]

			if(amount == 0)
				if(O.reagents.has_reagent(r_id))
					B.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount(r_id) * efficiency, space))
			else
				B.reagents.add_reagent(r_id, min(amount * efficiency, space))

			if(B.reagents.holder_full())
				break

		remove_object(O)
		if(B.reagents.holder_full())
			return

	// Slime Extracts
	for(var/obj/item/slime_extract/O in holdingitems)
		var/space = B.reagents.maximum_volume - B.reagents.total_volume

		if(O.reagents)
			var/amount = O.reagents.total_volume
			O.reagents.trans_to(B, min(amount, space))
		if(O.Uses > 0)
			B.reagents.add_reagent("slimejelly", min(20 * efficiency, space))

		remove_object(O)
		if(B.reagents.holder_full())
			return

// Everything else - Transfers reagents from the items into the container
	for(var/obj/item/O in holdingitems)
		O.reagents.trans_to(B, O.reagents.total_volume)

		if(!O.reagents.total_volume)
			remove_object(O)
		if(B.reagents.holder_full())
			return

//The Botanitank, a bigger, faster grinder complete with integrated chem storage tank.

/obj/machinery/reagentgrinder/Botanitank
	name = "\improper Botanitank"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "botanitank_beaker"
	layer = 2.9
	anchored = TRUE
	density = TRUE
	idle_power_consumption = 5
	active_power_consumption = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	internal = new /obj/item/reagent_containers/glass/beaker/noreact
	processTime = PROCESS_TIME


//empty version

/obj/machinery/reagentgrinder/Botanitank/empty
	icon_state = "botanitank_empty"
	beaker = null

//different initializer for different componenets

/obj/machinery/reagentgrinder/Botanitank/Initialize(mapload)
	. = ..()
	component_parts = list()
	var/obj/item/circuitboard/reagentgrinder/board = new(null)
	board.set_type(null,replacetext(name, "\improper", ""))
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/noreact
	component_parts += board
	RefreshParts()


//doing stuff with input from the ui

/obj/machinery/reagentgrinder/Botanitank/ui_act(action, params, datum/tgui/ui)
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
		if("dispense")
			var/index = text2num(params["index"])
			var/amount = text2num(params["amount"])
			dispense(amount,index)
		if("dispense_mix")
			var/amount = text2num(params["amount"])
			dispense_mix(amount)
		if("dump")
			var/index = text2num(params["index"])
			var/amount = text2num(params["amount"])
			dump(amount, index)
		if("clear")
			clearTank()

//dispense chems from the internal tank to the inserted container

/obj/machinery/reagentgrinder/Botanitank/proc/dispense(amount, index,mob/user)
	if(!beaker)
		to_chat(user, "<span class='warning'>No beaker detected!</span>")
		return FALSE
	if(beaker.reagents.total_volume == beaker.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>The beaker is already full!</span>")
		return FALSE
	if(isnull(index) || !ISINDEXSAFE(internal.reagents.reagent_list, index) || !amount)
		return FALSE
	var/datum/reagent/K = internal.reagents.reagent_list[index]
	var/count = K.volume
	var/dispensed = min(count, min(amount, beaker.reagents.maximum_volume - beaker.reagents.total_volume))

	internal.reagents.remove_reagent(K.id,dispensed,1)
	beaker.reagents.add_reagent(K.id,dispensed)

//dispense a proportional mixture of the stored chems into the inserted beaker.

/obj/machinery/reagentgrinder/Botanitank/proc/dispense_mix(amount,mob/user)
	if(internal.reagents.total_volume == 0)
		to_chat(user, "<span class = 'warning'>The internal tank is empty!</span>")
		return
	if(beaker.reagents.total_volume == beaker.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>The beaker is already full!</span>")
		return
	var/dispensed = min(internal.reagents.total_volume, min(amount, beaker.reagents.maximum_volume - beaker.reagents.total_volume))
	internal.reagents.trans_to(beaker,dispensed)
	return

//dump a specified amount of a specified reagent

/obj/machinery/reagentgrinder/Botanitank/proc/dump(amount, index)
	if(isnull(index) || !ISINDEXSAFE(internal.reagents.reagent_list, index) || !amount)
		return FALSE
	var/dumpAmount = min(amount, internal.reagents.reagent_list[index].volume)
	internal.reagents.remove_reagent(internal.reagents.reagent_list[index].id, dumpAmount)

//Empties the internal tank completely

/obj/machinery/reagentgrinder/Botanitank/proc/clearTank()
	for(var/datum/reagent/E in internal.reagents.reagent_list)
		internal.reagents.remove_reagent(E.id,E.volume)


#undef PROCESS_TIME
