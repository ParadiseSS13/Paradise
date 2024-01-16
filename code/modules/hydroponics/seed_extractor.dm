///Base Cap of the max amount of seeds you can store in a seed extractor
#define BASE_MAX_SEEDS     1000
///Max Cap of the amount of seed we let players dispense at once
#define MAX_DISPENSE_SEEDS 25

///This proc could probably be scoped better, also it's logic is cursed and hard to understand
/proc/seedify(obj/item/O, t_max, obj/machinery/seed_extractor/extractor, mob/living/user)
	var/t_amount = 0
	if(t_max == -1)
		if(extractor)
			t_max = rand(1,4) * extractor.seed_multiplier
		else
			t_max = rand(1,4)

	var/seedloc = O.loc
	if(extractor)
		seedloc = extractor.loc

	if(istype(O, /obj/item/reagent_containers/food/snacks/grown/))
		var/obj/item/reagent_containers/food/snacks/grown/F = O
		if(F.seed)
			if(user && !user.drop_item()) //couldn't drop the item
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
			return TRUE

	else if(istype(O, /obj/item/grown))
		var/obj/item/grown/F = O //someone should really abstract this into its own proc
		if(F.seed)
			if(user && !user.drop_item())
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
		return TRUE

	return FALSE


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

/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		return
	if(exchange_parts(user, O))
		return
	if(default_unfasten_wrench(user, O, time = 4 SECONDS))
		return
	if(default_deconstruction_crowbar(user, O))
		return


	if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(length(contents) >= max_seeds)
				break
			loaded++
			add_seed(G, user)

		if(loaded)
			to_chat(user, "<span class='notice'>You transfer [loaded] seeds from [O] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in [O].</span>")
		return

	else if(seedify(O,-1, src, user))
		to_chat(user, "<span class='notice'>You extract some seeds.</span>")
		return
	else if(istype(O,/obj/item/seeds))
		if(add_seed(O, user))
			to_chat(user, "<span class='notice'>You add [O] to [name].</span>")
			updateUsrDialog()
		return
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>")
	else
		return ..()

/obj/machinery/seed_extractor/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SeedExtractor", name, 800, 400, master_ui, state)
		ui.open()

/obj/machinery/seed_extractor/ui_data(mob/user)
	var/list/data = list()

	for(var/datum/seed_pile/O in piles)
		var/obj/item/I = O.path
		var/list/seed_info = list(
			"image" = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1))]",
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
		data["stored_seeds"] += list(seed_info)

	data["vend_amount"] = vend_amount
	return data

/obj/machinery/seed_extractor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = FALSE
	switch(action)
		if("vend")
			vend_seed(text2num(params["seedid"]), params["seedvariant"], vend_amount)
			add_fingerprint(usr)
			. = TRUE
		if("set_vend_amount")
			if(!length(params["vend_amount"]))
				return
			vend_amount = clamp(text2num(params["vend_amount"]), 1, MAX_DISPENSE_SEEDS)
			add_fingerprint(usr)
			. = TRUE

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
	return

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
