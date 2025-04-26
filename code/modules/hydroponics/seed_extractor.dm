///Base Cap of the max amount of seeds you can store in a seed extractor
#define BASE_MAX_SEEDS     1000
///Max Cap of the amount of seed we let players dispense at once
#define MAX_DISPENSE_SEEDS 25

/// Convert a grown object into seeds.
/proc/seedify(obj/item/source_item, seed_count, obj/machinery/seed_extractor/extractor, mob/living/user)
	var/output_loc = source_item.loc
	if(extractor)
		output_loc = extractor.loc

	var/original_seed = null
	if(istype(source_item, /obj/item/food/grown))
		var/obj/item/food/grown/F = source_item
		original_seed = F.unsorted_seed || F.seed
	else if(istype(source_item, /obj/item/grown))
		var/obj/item/grown/F = source_item
		original_seed = F.unsorted_seed || F.seed

	if(!original_seed)
		return FALSE

	if(user && !user.drop_item_to_ground(source_item, silent = TRUE)) //couldn't drop the item
		return FALSE

	if(seed_count == -1)
		if(istype(original_seed, /obj/item/unsorted_seeds))
			seed_count = 1
		else
			seed_count = rand(1,4)
		if(extractor)
			seed_count *= extractor.seed_multiplier

	for(var/i in 1 to seed_count)
		var/obj/item/new_seed
		if(istype(original_seed, /obj/item/seeds))
			var/obj/item/seeds/S = original_seed
			new_seed = S.Copy()
		else if(istype(original_seed, /obj/item/unsorted_seeds))
			var/obj/item/unsorted_seeds/S = original_seed
			new_seed = S.Copy()
		new_seed.forceMove(output_loc)
	qdel(source_item)
	return TRUE

/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = TRUE
	anchored = TRUE
	var/list/piles = list()
	var/max_seeds = BASE_MAX_SEEDS
	var/seed_multiplier = 1
	var/pile_count = 1 //used for tracking unique piles
	var/vend_amount = 1

/obj/machinery/seed_extractor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/seed_extractor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/seed_extractor/Destroy()
	QDEL_LIST_CONTENTS(piles)
	return ..()

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_seeds = BASE_MAX_SEEDS * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		seed_multiplier = M.rating

/obj/machinery/seed_extractor/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", used))
		return ITEM_INTERACT_COMPLETE

	if(default_unfasten_wrench(user, used, time = 4 SECONDS))
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/storage/part_replacer))
		. = ..()
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/storage/bag/plants))
		var/obj/item/storage/P = used
		var/loaded = 0
		for(var/obj/item/seeds/G in P)
			if(length(contents) >= max_seeds)
				break
			loaded++
			add_seed(G, user)

		if(loaded)
			to_chat(user, "<span class='notice'>You transfer [loaded] seeds from [used] into [src].</span>")
			SStgui.update_uis(src)
		else
			var/seedable = 0
			for(var/obj/item/food/grown/ignored in P)
				seedable++
			for(var/obj/item/grown/ignored in P)
				seedable++
			if(!seedable)
				to_chat(user, "<span class='notice'>There are no seeds or plants in [used].</span>")
				return ITEM_INTERACT_COMPLETE

			to_chat(user, "<span class='notice'>You dump the plants in [used] into [src].</span>")
			if(!used.use_tool(src, user, min(5, seedable/2) SECONDS))
				return ITEM_INTERACT_COMPLETE

			for(var/thing in P)
				seedify(thing,-1, src, user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/unsorted_seeds))
		to_chat(user, "<span class='warning'>You need to sort [used] first!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/seeds))
		add_seed(used, user)
		to_chat(user, "<span class='notice'>You add [used] to [name].</span>")
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	if(seedify(used,-1, src, user))
		to_chat(user, "<span class='notice'>You extract some seeds.</span>")
		return ITEM_INTERACT_COMPLETE

	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't extract any seeds from \the [used.name]!</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/seed_extractor/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/seed_extractor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedExtractor", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/seed_extractor/ui_data(mob/user)
	var/list/data = list()

	data["icons"] = list()
	data["seeds"] = list()
	for(var/datum/seed_pile/O in piles)
		var/obj/item/I = O.path
		var/icon/base64icon = GLOB.seeds_cached_base64_icons["[initial(I.icon)][initial(I.icon_state)]"]
		if(!base64icon)
			base64icon = icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1))
			GLOB.seeds_cached_base64_icons["[initial(I.icon)][initial(I.icon_state)]"] = base64icon
		data["icons"]["[initial(I.icon)][initial(I.icon_state)]"] = base64icon
		var/list/seed_info = list(
			"image" = "[initial(I.icon)][initial(I.icon_state)]",
			"id" = O.id,
			"name" = O.name,
			"variant" = O.variant,
			"lifespan" = O.lifespan,
			"endurance" = O.endurance,
			"maturation" = O.maturation,
			"production" = O.production,
			"yield" = O.yield,
			"potency" = O.potency,
			"amount" = O.amount,
		)
		data["seeds"] += list(seed_info)

	return data

/obj/machinery/seed_extractor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE
	switch(action)
		if("vend")
			vend_seed(params["seed_id"], params["seed_variant"], params["vend_amount"])
			add_fingerprint(usr)
		if("set_vend_amount")
			vend_amount = clamp(params["vend_amount"], 1, MAX_DISPENSE_SEEDS)
			add_fingerprint(usr)

/obj/machinery/seed_extractor/proc/vend_seed(seed_id, seed_variant, amount)
	if(!seed_id)
		return
	var/datum/seed_pile/selected_pile
	for(var/datum/seed_pile/N in piles)
		if(N.id == seed_id && (N.variant == seed_variant || !seed_variant))
			amount = clamp(amount, 0, N.amount)
			N.amount -= amount
			selected_pile = N
			if(N.amount <= 0)
				piles -= N
			break
	if(!selected_pile)
		return
	var/amount_dispensed = 0
	for(var/obj/item/seeds/O in contents)
		if(amount_dispensed >= amount)
			break
		if(O.plantname == selected_pile.name && O.variant == selected_pile.variant && O.lifespan == selected_pile.lifespan && O.endurance == selected_pile.endurance && O.maturation == selected_pile.maturation && O.production == selected_pile.production && O.yield == selected_pile.yield && O.potency == selected_pile.potency)
			O.forceMove(loc)
			amount_dispensed++

/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/O, mob/user)
	if(!O || !ishuman(usr) || !Adjacent(usr))
		return
	if(length(contents) >= max_seeds)
		to_chat(user, "<span class='notice'>[src] is full.</span>")
		return

	if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.drop_item())
			to_chat(user,"<span class='warning'>[O] appears to be stuck to your hand!</span>")
			return
	else if(isstorage(O.loc))
		var/obj/item/storage/S = O.loc
		if(!S.removal_allowed_check(user))
			return

		S.remove_from_storage(O, src)

	for(var/datum/seed_pile/N in piles) //this for loop physically hurts me
		if(O.plantname == N.name && O.variant == N.variant && O.lifespan == N.lifespan && O.endurance == N.endurance && O.maturation == N.maturation && O.production == N.production && O.yield == N.yield && O.potency == N.potency)
			N.amount++
			O.forceMove(src)
			return

	var/datum/seed_pile/new_pile = new(O.type, pile_count, O.plantname, O.variant, O.lifespan, O.endurance, O.maturation, O.production, O.yield, O.potency)
	pile_count++
	piles += new_pile
	O.forceMove(src)

/datum/seed_pile
	var/path
	var/id
	var/name = ""
	var/variant = ""
	var/lifespan = 0	//Saved stats
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = 0
	var/amount = 0

/datum/seed_pile/New(path, id, name, variant, life, endurance, maturity, production, yield, potency, amount = 1)
	src.path = path
	src.id = id
	src.name = name
	src.variant = variant
	src.lifespan = life
	src.endurance = endurance
	src.maturation = maturity
	src.production = production
	src.yield = yield
	src.potency = potency
	src.amount = amount

#undef BASE_MAX_SEEDS
#undef MAX_DISPENSE_SEEDS
