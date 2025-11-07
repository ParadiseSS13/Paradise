// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				// Unknown plant seed - these shouldn't exist in-game.
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/plantname = "Plants"		// Name of plant when planted.
	var/product						// A type path. The thing that is created when the plant is harvested.
	var/species = ""				// Used to update icons. Should match the name in the sprites unless all icon_* are overriden.
	var/variant = null				// Optional custom name to track modified plants. Can be set with pen or from gene modder.

	var/growing_icon = 'icons/obj/hydroponics/growing.dmi' //the file that stores the sprites of the growing plant from this seed.
	var/icon_grow					// Used to override grow icon (default is "[species]-grow"). You can use one grow icon for multiple closely related plants with it.
	var/icon_dead					// Used to override dead icon (default is "[species]-dead"). You can use one dead icon for multiple closely related plants with it.
	var/icon_harvest				// Used to override harvest icon (default is "[species]-harvest"). If null, plant will use [icon_grow][growthstages].

	var/lifespan = 25				// How long before the plant begins to take damage from age.
	var/endurance = 15				// Amount of health the plant has.
	var/maturation = 6				// Used to determine which sprite to switch to when growing.
	var/production = 6				// Changes the amount of time needed for a plant to become harvestable.
	var/yield = 3					// Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/potency = 10				// The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/growthstages = 6			// Amount of growth sprites the plant has.
	var/rarity = 0					// How rare the plant is. Used for giving points to cargo when shipping off to Centcom.
	var/list/mutatelist = list()	// The type of plants that this plant can mutate into.
	var/list/genes = list()			// Plant genes are stored here, see plant_genes.dm for more info.
	var/list/reagents_add = list()
	// A list of reagents to add to product.
	// Format: "reagent_id" = potency multiplier
	// Stronger reagents must always come first to avoid being displaced by weaker ones.
	// Total amount of any reagent in plant is calculated by formula: 1 + round(potency * multiplier)

	/// Percentage chance per tray update to grow weeds
	var/weed_chance = 5
	/// If weed chance passes, this many weeds sprout during growth
	var/weed_rate = 1

	/// The size of a small mutation for each stat.
	var/static/list/stat_mutation_sizes = list(
		"potency" = 20,
		"yield" = 1,
		"production speed" = 1,
		"endurance" = 20,
		"lifespan" = 20,
		"weed rate" = 1,
		"weed chance" = 20)

	/// Whether each stat is better at smaller values.
	var/static/list/stat_better_if_small = list(
		"potency" = FALSE,
		"yield" = FALSE,
		"production speed" = TRUE,
		"endurance" = FALSE,
		"lifespan" = FALSE,
		"weed rate" = TRUE,
		"weed chance" = TRUE)

/obj/item/seeds/Initialize(mapload, nogenes = FALSE)
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(-6, 6)

	if(!icon_grow)
		icon_grow = "[species]-grow"

	if(!icon_dead)
		icon_dead = "[species]-dead"

	if(!icon_harvest && !get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism) && yield != -1)
		icon_harvest = "[species]-harvest"

	if(!nogenes) // not used on Copy()
		genes += new /datum/plant_gene/core/lifespan(lifespan)
		genes += new /datum/plant_gene/core/endurance(endurance)
		genes += new /datum/plant_gene/core/weed_rate(weed_rate)
		genes += new /datum/plant_gene/core/weed_chance(weed_chance)
		if(yield != -1)
			genes += new /datum/plant_gene/core/yield(yield)
			genes += new /datum/plant_gene/core/production(production)
		if(potency != -1)
			genes += new /datum/plant_gene/core/potency(potency)

		for(var/p in genes)
			if(ispath(p))
				genes -= p
				genes += new p

		for(var/reag_id in reagents_add)
			genes += new /datum/plant_gene/reagent(reag_id, reagents_add[reag_id])

/obj/item/seeds/Destroy()
	QDEL_LIST_CONTENTS(genes)
	return ..()

/obj/item/seeds/proc/Copy()
	var/obj/item/seeds/S = new type(null, 1)
	// Copy all the stats
	S.lifespan = lifespan
	S.endurance = endurance
	S.maturation = maturation
	S.production = production
	S.yield = yield
	S.potency = potency
	S.weed_rate = weed_rate
	S.weed_chance = weed_chance
	S.variant = variant
	S.apply_variant_name()
	S.genes = list()
	for(var/g in genes)
		var/datum/plant_gene/G = g
		S.genes += G.Copy()
	S.reagents_add = reagents_add.Copy() // Faster than grabbing the list from genes.
	return S

/obj/item/seeds/proc/get_gene(typepath)
	return (locate(typepath) in genes)

/obj/item/seeds/proc/reagents_from_genes()
	reagents_add = list()
	for(var/datum/plant_gene/reagent/R in genes)
		reagents_add[R.reagent_id] = R.rate

/obj/item/seeds/proc/mutate(level, focus = list())
	for(var/stat in stat_mutation_sizes)
		if(stat in focus)
			mutate_stat(stat, level * 2, stat_mutation_sizes[stat])
		else if(length(focus))
			mutate_stat(stat, level / 2, stat_mutation_sizes[stat])
		else
			mutate_stat(stat, level, stat_mutation_sizes[stat])
	if(prob(level - 40))
		add_random_traits(1, 1)

/obj/item/seeds/proc/mutate_stat(stat, level, mutation_size)
	// 50% chance to do nothing to each stat even if mutation level is nonzero.
	if(level <= 0 || prob(50))
		return

	var/mod = 0
	// Roll for a bit of change every 10 mutation level.
	while(level > 10)
		mod += rand(0, mutation_size)
		level -= 10
	// And a partial chance if there's any mutation level left over.
	if(level > 0 && prob(level * 10))
		mod += rand(0, mutation_size)

	// Ensure we change it at least a bit if we passed the initial prob(50).
	mod = max(1, mod)

	// 50% chance of going either way.
	if(prob(50))
		mod = -mod

	adjust_by_name(stat, mod)

/obj/item/seeds/proc/adjust_by_name(stat, mod)
	switch(stat)
		if("potency")
			adjust_potency(mod)
		if("yield")
			adjust_yield(mod)
		if("production speed")
			adjust_production(mod)
		if("endurance")
			adjust_endurance(mod)
		if("lifespan")
			adjust_lifespan(mod)
		if("weed rate")
			adjust_weed_rate(mod)
		if("weed chance")
			adjust_weed_chance(mod)

/obj/item/seeds/bullet_act(obj/item/projectile/Proj) // Works with the Somatoray to modify plant variables.
	if(istype(Proj, /obj/item/projectile/energy/florayield))
		var/rating = 1
		if(istype(loc, /obj/machinery/hydroponics))
			var/obj/machinery/hydroponics/H = loc
			rating = H.rating

		if(yield == 0) // Oh god don't divide by zero you'll doom us all.
			adjust_yield(1 * rating)
		else if(prob(1/(yield * yield) * 100)) // This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			adjust_yield(1 * rating)
	else
		return ..()

// Harvest procs
/obj/item/seeds/proc/getYield()
	var/return_yield = yield

	if(istype(loc, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/parent = loc
		if(parent.yieldmod == 0)
			return_yield = min(return_yield, 1) // 1 if above zero, 0 otherwise
		else
			return_yield *= (parent.yieldmod)
		if(parent.yield_beamed)
			return_yield += rand(1,3)

	return CEILING(return_yield, 1) // No decimal plants, please

/obj/item/seeds/proc/get_mutated_seed(obj/machinery/hydroponics/tray)
	var/mutation_level = tray?.get_mutation_level()
	if(!mutation_level)
		return src

	return new /obj/item/unsorted_seeds(src, src, mutation_level, tray.get_mutation_focus())

/obj/item/seeds/proc/harvest(mob/user, obj/item/storage/bag/plants/bag)
	var/obj/machinery/hydroponics/tray = loc
	var/output_loc = tray.Adjacent(user) ? user.loc : tray.loc // Needed for TK

	var/mutated_seed = get_mutated_seed(tray)

	var/product_name
	var/product_count = getYield()
	for(var/i in 1 to product_count)
		var/obj/item/produce = new product(output_loc, mutated_seed)
		if(!produce)
			return
		if(bag && bag.can_be_inserted(produce))
			bag.handle_item_insertion(produce, user, TRUE)

		product_name = produce.name

	if(product_count)
		SSblackbox.record_feedback("tally", "food_harvested", product_count, product_name)

	tray.update_tray(user, product_count)

/obj/item/seeds/proc/prepare_result(obj/item/T)
	if(!T.reagents)
		CRASH("[T] has no reagents.")

	for(var/rid in reagents_add)
		var/amount = max(round(potency * reagents_add[rid], 1), 1)

		var/list/data = null
		if(rid == "blood") // Hack to make blood in plants always O-
			data = list("blood_type" = "O-")
		if(rid == "nutriment" || rid == "vitamin" || rid == "protein" || rid == "plantmatter")
			// Apple tastes of apple.
			if(istype(T, /obj/item/food/grown))
				var/obj/item/food/grown/grown_edible = T
				data = grown_edible.tastes.Copy()

		T.reagents.add_reagent(rid, amount, data)


/// Setter procs ///
/obj/item/seeds/proc/adjust_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = clamp(yield + adjustamt, 0, 10)

		if(yield <= 0 && get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/obj/item/seeds/proc/adjust_lifespan(adjustamt)
	lifespan = clamp(lifespan + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/obj/item/seeds/proc/adjust_endurance(adjustamt)
	endurance = clamp(endurance + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/obj/item/seeds/proc/adjust_production(adjustamt)
	if(yield != -1)
		production = clamp(production + adjustamt, 1, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/obj/item/seeds/proc/adjust_potency(adjustamt)
	if(potency != -1)
		potency = clamp(potency + adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency

/obj/item/seeds/proc/adjust_weed_rate(adjustamt)
	weed_rate = clamp(weed_rate + adjustamt, 0, 10)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/obj/item/seeds/proc/adjust_weed_chance(adjustamt)
	weed_chance = clamp(weed_chance + adjustamt, 0, 67)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance

// Directly setting stats

/obj/item/seeds/proc/set_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = clamp(adjustamt, 0, 10)

		if(yield <= 0 && get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/obj/item/seeds/proc/set_lifespan(adjustamt)
	lifespan = clamp(adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/obj/item/seeds/proc/set_endurance(adjustamt)
	endurance = clamp(adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/obj/item/seeds/proc/set_production(adjustamt)
	if(yield != -1)
		production = clamp(adjustamt, 1, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/obj/item/seeds/proc/set_potency(adjustamt)
	if(potency != -1)
		potency = clamp(adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency

/obj/item/seeds/proc/set_weed_rate(adjustamt)
	weed_rate = clamp(adjustamt, 0, 10)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/obj/item/seeds/proc/set_weed_chance(adjustamt)
	weed_chance = clamp(adjustamt, 0, 67)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance


/obj/item/seeds/proc/get_analyzer_text(show_detail = TRUE)  // In case seeds have something special to tell to the analyzer
	var/list/text = list()
	if(show_detail)
		if(!get_gene(/datum/plant_gene/trait/plant_type/weed_hardy) && !get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism) && !get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
			text += "- Plant type: Normal plant"
		if(get_gene(/datum/plant_gene/trait/plant_type/weed_hardy))
			text += "- Plant type: Weed. Can grow in nutrient-poor soil."
		if(get_gene(/datum/plant_gene/trait/plant_type/fungal_metabolism))
			text += "- Plant type: Mushroom. Can grow in dry soil."
		if(get_gene(/datum/plant_gene/trait/plant_type/alien_properties))
			text += "- Plant type: <span class='warning'>UNKNOWN</span> "
	if(potency != -1)
		text += "- Potency: [potency]"
	if(yield != -1)
		var/obj/machinery/hydroponics/tray = loc
		if(istype(tray) && tray.yield_beamed)
			text += "- Yield: [yield] (+1-3 from somatoray)"
		else
			text += "- Yield: [yield]"
	text += "- Maturation speed: [maturation]"
	if(yield != -1)
		text += "- Production speed: [production]"
	text += "- Endurance: [endurance]"
	text += "- Lifespan: [lifespan]"
	text += "- Weed Growth Rate: [weed_rate]"
	text += "- Weed Vulnerability: [weed_chance]"
	if(!show_detail)
		return text.Join("<br>")
	if(rarity)
		text += "- Species Discovery Value: [rarity]"
	var/all_traits = ""
	for(var/datum/plant_gene/trait/traits in genes)
		if(istype(traits, /datum/plant_gene/trait/plant_type))
			continue
		all_traits += " [traits.get_name()]"
	text += "- Plant Traits:[all_traits]"

	return text.Join("<br>")

/obj/item/seeds/proc/on_chem_reaction(datum/reagents/S)  // In case seeds have some special interaction with special chems
	return

/obj/item/seeds/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/plant_analyzer))
		to_chat(user, "<span class='notice'>This is \a <span class='name'>[src].</span></span>")
		var/text = get_analyzer_text()
		if(text)
			to_chat(user, "<span class='notice'>[text]</span>")

		return
	if(is_pen(O))
		variant_prompt(user)
		return
	..() // Fallthrough to item/attackby() so that bags can pick seeds up


/obj/item/seeds/proc/variant_prompt(mob/user, obj/item/container = null)
	var/prev = variant
	var/V = tgui_input_text(user, "Choose variant name:", "Plant Variant Naming", variant, encode = FALSE)
	if(isnull(V)) // Did the user cancel?
		return
	if(container && (loc != container)) // Was the seed removed from the container, if there is a container?
		return
	if(!(container ? container : src).Adjacent(user)) // Is the user next to the seed/container?
		return
	variant = html_encode(copytext(trim(V), 1, 64))
	if(variant == "")
		variant = null
	if(prev != variant)
		to_chat(user, "<span class='notice'>You [variant ? "change" : "remove"] the [plantname]'s variant designation.</span>")
	apply_variant_name()

/obj/item/seeds/proc/apply_variant_name()
	var/V = variant ? " \[[variant]]" : "" // If we have a non-empty variant add it to the name
	var/N = initial(name)
	if(copytext(name, 1, 13) == "experimental") // Don't delete 'experimental'
		N = "experimental " + N
	name = N + V
	update_appearance(UPDATE_NAME) //Append name additives such as from labels





// Checks plants for broken tray icons. Use Advanced Proc Call to activate.
// Maybe some day it would be used as unit test.
/proc/check_plants_growth_stages_icons()
	var/list/states = icon_states('icons/obj/hydroponics/growing.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_fruits.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_flowers.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_mushrooms.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_vegetables.dmi')
	var/list/paths = typesof(/obj/item/seeds) - /obj/item/seeds - typesof(/obj/item/seeds/sample)

	for(var/seedpath in paths)
		var/obj/item/seeds/seed = new seedpath

		for(var/i in 1 to seed.growthstages)
			if("[seed.icon_grow][i]" in states)
				continue
			stack_trace("[seed.name] ([seed.type]) lacks the [seed.icon_grow][i] icon!")

		if(!(seed.icon_dead in states))
			stack_trace("[seed.name] ([seed.type]) lacks the [seed.icon_dead] icon!")

		if(seed.icon_harvest) // Mushrooms have no grown sprites, same for items with no product
			if(!(seed.icon_harvest in states))
				stack_trace("[seed.name] ([seed.type]) lacks the [seed.icon_harvest] icon!")

/obj/item/seeds/proc/randomize_stats()
	set_lifespan(rand(25, 60))
	set_endurance(rand(15, 35))
	set_production(rand(2, 10))
	set_yield(rand(1, 10))
	set_potency(rand(10, 35))
	set_weed_rate(rand(1, 10))
	set_weed_chance(rand(5, 100))
	maturation = rand(6, 12)

/obj/item/seeds/proc/add_random_reagents(lower = 0, upper = 2)
	var/amount_random_reagents = rand(lower, upper)
	for(var/i in 1 to amount_random_reagents)
		var/random_amount = rand(4, 15) * 0.01 // This must be multiplied by 0.01, otherwise, it will not properly associate
		var/datum/plant_gene/reagent/R = new(get_random_reagent_id(), random_amount)
		if(R.can_add(src))
			genes += R
		else
			qdel(R)
	reagents_from_genes()

/obj/item/seeds/proc/add_random_traits(lower = 0, upper = 2)
	var/amount_random_traits = rand(lower, upper)
	var/list/name_to_path = list(
	"Liquid Contents" = /datum/plant_gene/trait/squash,
	"Slippery Skin" = /datum/plant_gene/trait/slip,
	"Electrical Activity" = /datum/plant_gene/trait/cell_charge,
	"Bioluminescence" = /datum/plant_gene/trait/glow,
	"Shadow Emission" = /datum/plant_gene/trait/glow/shadow,
	"Red Electrical Glow" = /datum/plant_gene/trait/glow/red,
	"Strong Bioluminescence" = /datum/plant_gene/trait/glow/berry,
	"Bluespace Activity" = /datum/plant_gene/trait/teleport,
	"Densified Chemicals" = /datum/plant_gene/trait/maxchem,
	"Perennial Growth" = /datum/plant_gene/trait/repeated_harvest,
	"Capacitive Cell Production" = /datum/plant_gene/trait/battery,
	"Hypodermic Prickles" = /datum/plant_gene/trait/stinging,
	"gaseous decomposition" = /datum/plant_gene/trait/smoke,
	"Fire Resistance" = /datum/plant_gene/trait/fire_resistance,
	)
	for(var/i in 1 to amount_random_traits)
		var/list/possible_traits = (subtypesof(/datum/plant_gene/trait) - typesof(/datum/plant_gene/trait/plant_type))
		//removing existing traits and conflicting traits be added from the list of traits to choose from
		for(var/datum/plant_gene/trait/j in genes)
			var/trait_name = j.name
			possible_traits -= list(name_to_path[trait_name])
			if(trait_name == "Red Electrical Glow"|| trait_name == "Strong Bioluminescence"||trait_name == "Shadow Emission"||trait_name == "Bioluminescence")
				possible_traits -= typesof(/datum/plant_gene/trait/glow)
		var/random_trait = pick(possible_traits)
		var/datum/plant_gene/trait/T = new random_trait
		if(T.can_add(src))
			genes += T
		else
			qdel(T)

/obj/item/seeds/proc/add_random_plant_type(normal_plant_chance = 75)
	if(prob(normal_plant_chance))
		var/random_plant_type = pick(subtypesof(/datum/plant_gene/trait/plant_type))
		var/datum/plant_gene/trait/plant_type/P = new random_plant_type
		if(P.can_add(src))
			genes += P
		else
			qdel(P)

/obj/item/seeds/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.ghost_flags & GHOST_PLANT_ANALYZER)
		to_chat(user, get_analyzer_text())

/obj/item/seeds/openTip()
	var/datum/atom_hud/hydrohud = GLOB.huds[DATA_HUD_HYDROPONIC]
	if(usr in hydrohud.hudusers)
		return  // Suppress the default tooltip.
	return ..()

/obj/item/seeds/MouseEntered(location, control, params)
	. = ..()
	var/datum/atom_hud/hydrohud = GLOB.huds[DATA_HUD_HYDROPONIC]
	if(usr in hydrohud.hudusers)
		openToolTip(usr, src, params, title = name, content = get_analyzer_text(FALSE))

/obj/item/seeds/should_stack_with(obj/item/O)
	if(!..())
		return FALSE
	var/obj/item/seeds/other = O
	if(potency != other.potency)
		return FALSE
	if(yield != other.yield)
		return FALSE
	if(production != other.production)
		return FALSE
	if(endurance != other.endurance)
		return FALSE
	if(lifespan != other.lifespan)
		return FALSE
	if(weed_rate != other.weed_rate)
		return FALSE
	if(weed_chance != other.weed_chance)
		return FALSE
	return TRUE

/datum/unsorted_seed
	var/obj/item/seeds/original_seed
	var/mutation_level
	var/list/mutation_focus

/datum/unsorted_seed/New(obj/item/seeds/original_seed_in, mutation_level_in, list/mutation_focus_in)
	..()
	original_seed = original_seed_in
	mutation_level = mutation_level_in
	mutation_focus = mutation_focus_in

/datum/unsorted_seed/Destroy()
	original_seed = null
	mutation_focus = null
	return ..()

/datum/unsorted_seed/proc/transform(obj/item/unsorted_seeds/unsorted_seed, sort_depth = 1)
	var/seed_mutation_level = mutation_level
	var/species_mutation_chance = 0
	switch(sort_depth)
		if(0 to 4)
			// Default mutation level.
			species_mutation_chance = (mutation_level - 20) * 10
		if(5 to 8)
			seed_mutation_level *= 1.5
			species_mutation_chance = (mutation_level - 15) * 10
		else
			seed_mutation_level *= 2
			species_mutation_chance = (mutation_level - 10) * 10

	var/obj/item/seeds/mutant
	if(prob(species_mutation_chance) && length(original_seed.mutatelist))
		var/mutant_type = pick(original_seed.mutatelist)
		mutant = new mutant_type
		mutant.mutate(seed_mutation_level)
	else
		mutant = original_seed.Copy()
		mutant.mutate(seed_mutation_level, mutation_focus)

	if(istype(unsorted_seed.loc, /mob))
		var/mob/M = unsorted_seed.loc
		M.drop_item()
		M.put_in_active_hand(mutant)
	if(istype(unsorted_seed.loc, /obj/item/storage))
		var/obj/item/storage/S = unsorted_seed.loc
		S.remove_from_storage(unsorted_seed)
		S.handle_item_insertion(mutant, usr, TRUE)
	qdel(unsorted_seed)

/obj/item/unsorted_seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				// Unknown plant seed - these shouldn't exist in-game.
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

	var/datum/unsorted_seed/seed_data

/obj/item/unsorted_seeds/Initialize(mapload, obj/item/seeds/template, mutation_level, list/mutation_focus, seed_data_in = null)
	. = ..()
	template = template.Copy()
	scatter_atom()
	if(seed_data_in)
		seed_data = seed_data_in
	else
		seed_data = new(template, mutation_level, mutation_focus)
	name = "unsorted [template.name]"
	icon_state = template.icon_state
	// The grammar looks odd here because template.name is "pack of Xes".
	desc = "A [template.name] that have mutated and need to be sorted out before use. The best method is to use a plant analyzer on a bag full of unsorted seed packs. If you don't have a plant analyzer, you can place unsorted seeds into a sorting tray and use it in hand, or even use them directly in hand. The more you sort at once, the stronger the mutations you'll discover."

/obj/item/unsorted_seeds/Destroy()
	seed_data = null
	return ..()

/obj/item/unsorted_seeds/proc/Copy()
	return new /obj/item/unsorted_seeds(seed_data.original_seed, seed_data.original_seed, seed_data.mutation_level, seed_data.mutation_focus, seed_data)

/obj/item/unsorted_seeds/proc/sort(depth = 1)
	seed_data.transform(src, depth)

/obj/item/unsorted_seeds/attack_self__legacy__attackchain(mob/user)
	user.visible_message("<span class='notice'>[user] crudely sorts through [src] by hand.</span>", "<span class='notice'>You crudely sort through [src] by hand. This would be easier and more effective with some sort of tool.")
	if(do_after(user, 3 SECONDS, TRUE, src, must_be_held = TRUE))
		sort()

/obj/item/unsorted_seeds/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/plant_analyzer))
		to_chat(user, "<span class='notice'>This is \a <span class='name'>[src].</span></span>")
		var/text = get_analyzer_text()
		if(text)
			to_chat(user, "<span class='notice'>[text]</span>")

		return
	if(is_pen(O))
		to_chat(user, "<span class='notice'>Sort it first.</span>")
		return
	..() // Fallthrough to item/attackby() so that bags can pick seeds up

/obj/item/unsorted_seeds/proc/get_analyzer_text(show_detail = TRUE)
	var/list/output = list()
	output += seed_data.original_seed.get_analyzer_text(show_detail)
	output += "- Mutation level: [seed_data.mutation_level]"
	output += "- Mutation focus: [english_list(seed_data.mutation_focus, "None.")]"
	output += "<span class='notice'>Data may change after sorting.</span>"
	return output.Join("<br>")

/obj/item/unsorted_seeds/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.ghost_flags & GHOST_PLANT_ANALYZER)
		to_chat(user, get_analyzer_text())

/obj/item/unsorted_seeds/openTip()
	var/datum/atom_hud/hydrohud = GLOB.huds[DATA_HUD_HYDROPONIC]
	if(usr in hydrohud.hudusers)
		return  // Suppress the default tooltip.
	return ..()

/obj/item/unsorted_seeds/MouseEntered(location, control, params)
	. = ..()
	var/datum/atom_hud/hydrohud = GLOB.huds[DATA_HUD_HYDROPONIC]
	if(usr in hydrohud.hudusers)
		openToolTip(usr, src, params, title = name, content = get_analyzer_text(FALSE))

/obj/item/unsorted_seeds/should_stack_with(obj/item/O)
	if(!..())
		return FALSE
	var/obj/item/unsorted_seeds/other = O
	if(!seed_data.original_seed.should_stack_with(other.seed_data.original_seed))
		return FALSE
	if(seed_data.mutation_level != other.seed_data.mutation_level)
		return FALSE
	if(length(seed_data.mutation_focus) != length(other.seed_data.mutation_focus))
		return FALSE
	return length(seed_data.mutation_focus - other.seed_data.mutation_focus) == 0
