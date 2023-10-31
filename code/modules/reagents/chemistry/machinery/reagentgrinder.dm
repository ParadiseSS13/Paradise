/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
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
	var/limit = null
	var/efficiency = null

	//IMPORTANT NOTE! A negative number is a multiplier, a positive number is a flat amount to add. 0 means equal to the amount of the original reagent
	var/list/blend_items = list (

		//Sheets
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

		//Blender Stuff
		/obj/item/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
		/obj/item/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/reagent_containers/food/snacks/grown/oat = list("flour" = -5),
		/obj/item/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
		/obj/item/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
		/obj/item/reagent_containers/food/snacks/egg = list("egg" = -5),
		/obj/item/reagent_containers/food/snacks/grown/rice = list("rice" = -5),
		/obj/item/reagent_containers/food/snacks/grown/olive = list("olivepaste" = 0, "sodiumchloride" = 0),
		/obj/item/reagent_containers/food/snacks/grown/peanuts = list("peanutbutter" = 0),

		//Grinder stuff, but only if dry
		/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
		/obj/item/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
		/obj/item/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		/obj/item/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0),

		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/slime_extract = list(),
		/obj/item/reagent_containers/food = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff
		/obj/item/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
		/obj/item/reagent_containers/food/snacks/grown/corn = list("corn_starch" = 0),
		/obj/item/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime = list("limejuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
		/obj/item/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/pumpkin/blumpkin = list("blumpkinjuice" = 0), //order is important here as blumpkin is a subtype of pumpkin, if switched blumpkins will produce pumpkin juice
		/obj/item/reagent_containers/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/apple = list("applejuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/grapes = list("grapejuice" = 0),
		/obj/item/reagent_containers/food/snacks/grown/pineapple = list("pineapplejuice" = 0)
	)

	var/list/dried_items = list(

		//Grinder stuff, but only if dry,
		/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
		/obj/item/reagent_containers/food/snacks/grown/coffee = list("coffeepowder" = 0),
		/obj/item/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		/obj/item/reagent_containers/food/snacks/grown/tea = list("teapowder" = 0)
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
	limit = 10*H
	efficiency = 0.8+T*0.1

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
	if(!anchored || beaker)
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "juicer_open", "juicer0", I)

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
		return TRUE //no afterattack

	if(is_type_in_list(I, dried_items))
		if(istype(I, /obj/item/reagent_containers/food/snacks/grown))
			var/obj/item/reagent_containers/food/snacks/grown/G = I
			if(!G.dry)
				to_chat(user, "<span class='warning'>You must dry that first!</span>")
				return FALSE

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return FALSE

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/obj/item/storage/bag/B = I
		if(!B.contents.len)
			to_chat(user, "<span class='warning'>[B] is empty.</span>")
			return FALSE

		var/original_contents_len = B.contents.len

		for(var/obj/item/G in B.contents)
			if(is_type_in_list(G, blend_items) || is_type_in_list(G, juice_items))
				B.remove_from_storage(G, src)
				holdingitems += G
				if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
					to_chat(user, "<span class='notice'>You fill the All-In-One grinder to the brim.</span>")
					break

		if(B.contents.len == original_contents_len)
			to_chat(user, "<span class='warning'>Nothing in [B] can be put into the All-In-One grinder.</span>")
			return FALSE
		else if(!B.contents.len)
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

/obj/machinery/reagentgrinder/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ReagentGrinder", name, 400, 500, master_ui, state)
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
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
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
					name_overrides[display_name] = "[name_overrides[display_name]]s" //name_overrides[display_name] Will be set on the first time as the singular form

			items_counts[display_name] += S.amount
			continue

		else if(istype(O, /obj/item/reagent_containers/food))
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
	if(holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.forceMove(loc)
		holdingitems -= O
	holdingitems = list()
	SStgui.update_uis(src)

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/reagent_containers/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return TRUE
	return FALSE

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/reagent_containers/food/snacks/O)
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

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/reagent_containers/food/snacks/grown/O)
	if(!istype(O) || !O.seed)
		return 5
	else if(O.seed.potency == -1)
		return 5
	else
		return round(5*sqrt(O.seed.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = TRUE
	SStgui.update_uis(src)
	spawn(50)
		pixel_x = initial(pixel_x) //return to its spot after shaking
		operating = FALSE
		SStgui.update_uis(src)

	//Snacks
	for(var/obj/item/reagent_containers/food/snacks/O in holdingitems)
		if(beaker.reagents.holder_full())
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for(var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount * efficiency, space))

			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if(!beaker || (beaker && beaker.reagents.holder_full()))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = TRUE
	SStgui.update_uis(src)
	spawn(60)
		pixel_x = initial(pixel_x) //return to its spot after shaking
		operating = FALSE
		SStgui.update_uis(src)

	//Snacks and Plants
	for(var/obj/item/reagent_containers/food/snacks/O in holdingitems)
		if(beaker.reagents.holder_full())
			break

		var/allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for(var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if(O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment") * efficiency, space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					if(O.reagents != null && O.reagents.has_reagent("plantmatter"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("plantmatter") * efficiency, space))
						O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))
				else
					if(O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment") * abs(amount) * efficiency), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
					if(O.reagents != null && O.reagents.has_reagent("plantmatter"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("plantmatter") * abs(amount) * efficiency), space))
						O.reagents.remove_reagent("plantmatter", min(O.reagents.get_reagent_amount("plantmatter"), space))


			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if(beaker.reagents.holder_full())
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets and rods(!)
	for(var/obj/item/stack/O in holdingitems)
		if(beaker.reagents.holder_full())
			break

		var/allowed = get_allowed_by_id(O)
		if(isnull(allowed))
			break

		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		while(O.amount) //Grind until there's no more reagents
			if(!space) //if no free space - exit
				break
			O.amount -= 1 //remove one from stack
			for(var/r_id in allowed)
				var/spaceused = min(allowed[r_id] * efficiency, space)
				space -= spaceused
				beaker.reagents.add_reagent(r_id, spaceused)
			if(O.amount < 1) //if leftover small - destroy
				remove_object(O)
				break

	//Plants
	for(var/obj/item/grown/O in holdingitems)
		if(beaker.reagents.holder_full())
			break
		var/allowed = get_allowed_by_id(O)
		for(var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount == 0)
				if(O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id) * efficiency, space))
			else
				beaker.reagents.add_reagent(r_id,min(amount * efficiency, space))

			if(beaker.reagents.holder_full())
				break
		remove_object(O)

	//Slime Extractis
	for(var/obj/item/slime_extract/O in holdingitems)
		if(beaker.reagents.holder_full())
			break
		var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
		if(O.reagents != null)
			var/amount = O.reagents.total_volume
			O.reagents.trans_to(beaker, min(amount, space))
		if(O.Uses > 0)
			beaker.reagents.add_reagent("slimejelly",min(20 * efficiency, space))
		remove_object(O)

	//Everything else - Transfers reagents from it into beaker
	for(var/obj/item/reagent_containers/O in holdingitems)
		if(beaker.reagents.holder_full())
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)
