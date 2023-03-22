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
			return 1

	else if(istype(O, /obj/item/grown))
		var/obj/item/grown/F = O
		if(F.seed)
			if(user && !user.drop_item())
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
		return 1

	return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/list/piles = list()
	var/max_seeds = 1000
	var/seed_multiplier = 1

/obj/machinery/seed_extractor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/seed_extractor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/seed_extractor/Destroy()
	QDEL_LIST(piles)
	return ..()

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_seeds = 1000 * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		seed_multiplier = M.rating

/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user, params)

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if (istype(O,/obj/item/storage/bag/plants))
		var/obj/item/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(contents.len >= max_seeds)
				break
			++loaded
			add_seed(G)
		if (loaded)
			to_chat(user, "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in \the [O.name].</span>")
		return

	else if(seedify(O,-1, src, user))
		to_chat(user, "<span class='notice'>You extract some seeds.</span>")
		return
	else if (istype(O,/obj/item/seeds))
		if(add_seed(O))
			to_chat(user, "<span class='notice'>You add [O] to [name].</span>")
			updateUsrDialog()
		return
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>")
	else
		return ..()

/datum/seed_pile
	var/name = ""
	var/variant = ""
	var/lifespan = 0	//Saved stats
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = 0
	var/amount = 0

/datum/seed_pile/New(var/name, var/variant, var/life, var/endur, var/matur, var/prod, var/yie, var/poten, var/am = 1)
	src.name = name
	if (variant<>"" && !isnull(variant)) src.name += " ("+variant+")"
	src.variant = variant
	src.lifespan = life
	src.endurance = endur
	src.maturation = matur
	src.production = prod
	src.yield = yie
	src.potency = poten
	src.amount = am

/obj/machinery/seed_extractor/attack_hand(mob/user)
	interact(user)

/obj/machinery/seed_extractor/attack_ghost(mob/user)
	interact(user)

/obj/machinery/seed_extractor/interact(mob/user)
	if(stat)
		return 0

	add_fingerprint(user)
	user.set_machine(src)
	ui_interact(user)
	return

/obj/machinery/seed_extractor/Topic(var/href, var/list/href_list)
	if(..())
		return 1
	usr.set_machine(src)

	href_list["li"] = text2num(href_list["li"])
	href_list["en"] = text2num(href_list["en"])
	href_list["ma"] = text2num(href_list["ma"])
	href_list["pr"] = text2num(href_list["pr"])
	href_list["yi"] = text2num(href_list["yi"])
	href_list["pot"] = text2num(href_list["pot"])

	for (var/datum/seed_pile/N in piles)//Find the pile we need to reduce...
		if (href_list["name"] == N.name && href_list["variant"] == N.variant && href_list["li"] == N.lifespan && href_list["en"] == N.endurance && href_list["ma"] == N.maturation && href_list["pr"] == N.production && href_list["yi"] == N.yield && href_list["pot"] == N.potency)
			if(N.amount <= 0)
				return
			N.amount = max(N.amount - 1, 0)
			if (N.amount <= 0)
				piles -= N
				qdel(N)
			break

	for (var/obj/T in contents)//Now we find the seed we need to vend
		var/obj/item/seeds/O = T
		if (O.plantname == href_list["name"] && href_list["variant"] == O.variant && O.lifespan == href_list["li"] && O.endurance == href_list["en"] && O.maturation == href_list["ma"] && O.production == href_list["pr"] && O.yield == href_list["yi"] && O.potency == href_list["pot"])
			O.forceMove(loc)
			break

	updateUsrDialog()
	return

//Расширенный инвентарь и tgui
/datum/seed_pile/extended
	var/id_string = ""
	var/list/seeds = list() //Храним список объектов, чтобы не искать циклом по contents

/datum/seed_pile/extended/New(obj/item/seeds/O)
	..(O.plantname, O.variant, O.lifespan, O.endurance, O.maturation, O.production, O.yield, O.potency)

	src.seeds += O

/obj/machinery/seed_extractor/proc/generate_seedId(obj/item/seeds/O) //Генерация строки-идентификатора для поиска
	var/id_string = copytext("[O.type]",17)
	if (O.variant<>"") id_string += " ("+O.variant+")"
	id_string += "[O.lifespan]_[O.endurance]_[O.maturation]_[O.production]_[O.yield]_[O.potency]_[O.weed_rate]_[O.weed_chance]"

	for (var/datum/plant_gene/reagent/G in O.genes)
		id_string += "_[G.reagent_id]_[G.rate*100]"

	for (var/datum/plant_gene/trait/G in O.genes)
		if (istype(G,/datum/plant_gene/trait/plant_type))
			id_string += "_"+copytext("[G.type]",36)
		else
			id_string += "_"+copytext("[G.type]",25)

	return id_string

/obj/machinery/seed_extractor/proc/generate_strainText(obj/item/seeds/O) //Генерация отображаемого текста описания
	var/strain_text = ""

	for (var/datum/plant_gene/reagent/G in O.genes)
		if (strain_text !="")
			strain_text += ", "
		strain_text += "[G.get_name()]"

	for (var/datum/plant_gene/trait/G in O.genes)
		if (strain_text !="")
			strain_text += ", "
		strain_text += "[G.get_name()]"

	return strain_text

/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/O)

	if(contents.len >= 999)
		to_chat(usr, "<span class='notice'>\The [src] is full.</span>")
		return 0

	if(istype(O.loc,/mob))
		var/mob/M = O.loc
		if(!M.drop_item())
			return FALSE
	else if(istype(O.loc,/obj/item/storage))
		var/obj/item/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.forceMove(src)
	. = TRUE

	var/id_string = generate_seedId(O)
	for (var/datum/seed_pile/extended/N in piles)
		if (N.id_string == id_string)
			++N.amount
			N.seeds += O
			return

	var/datum/seed_pile/extended/NP = new(O)
	NP.id_string = id_string
	piles += NP
	return

/obj/machinery/seed_extractor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SeedExtractor", name, 900, 600)
		ui.open()

/obj/machinery/seed_extractor/ui_data(mob/user)
	var/list/data = list()

	data["contents"] = null
	data["total"] = contents.len
	data["capacity"] = max_seeds

	var/list/items = list()
	for(var/i in 1 to length(piles))
		var/datum/seed_pile/extended/P = piles[i]
		var/list/obj/item/seeds/Sl = P.seeds

		if (length(Sl) == 0)
			continue //Пустых куч быть не должно, но проверка не помешает
		var/strain_text=generate_strainText(Sl[1])

		items.Add(list(list("display_name" = html_encode(capitalize(P.name)), "variant" = html_encode(P.variant), "vend" = i, "quantity" = P.amount,"life"=P.lifespan,"endr"=P.endurance,"matr" = P.maturation,"prod" = P.production,"yld" = P.yield,"potn" = P.potency,"strain_text" = strain_text )))
	if(length(items))
		data["contents"] = items

	return data

/obj/machinery/seed_extractor/ui_act(action, params)
	if(..())
		return

	. = TRUE

	var/mob/user = usr

	switch(action)
		if("vend")
			var/index = text2num(params["index"])
			var/amount = text2num(params["amount"])

			if(isnull(index) || !ISINDEXSAFE(piles, index) || isnull(amount))
				return TRUE

			var/datum/seed_pile/extended/P = piles[index]
			var/list/Sl = P.seeds

			if (length(Sl)==0)
				piles.Remove(P)
				return TRUE

			var/i = amount

			if(i == 1 && Adjacent(user) && !issilicon(user))
				var/obj/item/seeds/O = Sl[1]

				if(!user.put_in_hands(O))
					O.forceMove(loc)
					adjust_item_drop_location(O)

				Sl.Remove(O)

			else
				for(var/cntr in 1 to i)
					var/obj/item/seeds/O = Sl[1]
					O.forceMove(loc)
					adjust_item_drop_location(O)
					Sl.Remove(O)

			if (length(Sl)==0)
				piles.Remove(P)
			else
				P.amount = length(Sl)
