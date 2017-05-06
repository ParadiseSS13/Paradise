
/obj/machinery/food_replicator
	name = "Food Replicator"
	desc = "Reconfigure food into paste and paste into food. Finally a use for brussel sprouts!"
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "food_rep_on"
	anchored = 1
	density = 1
	idle_power_usage = 10
	active_power_usage = 1000
	var/off_icon = "food_rep_off"
	var/on_icon = "food_rep_on"
	var/broken_icon = "food_rep_broken"
	var/open_icon = "food_rep_open"
	var/operating = 0
	//food_paste is the resource stored and consumed by the food replicator to create copies. It's like biomass in the biogenerator.
	var/food_paste = 0
	//max_food_paste is the maximum amount of food paste the food replicator can store. Upgrading the matter bin improves this.
	var/max_food_paste = 200
	//recycle_rate is the conversion rate of reagents into food_paste when recycling foods. Upgrading the manipulator improves this, making the recycling more efficient.
	var/recycle_rate = 0.7
	//reagent_tier is the current tier of unlocked reagent replication. Upgrading the micro-laser improves this, making replications more accurate.
	var/reagent_tier = 1

	//Tier 0 reagents are free: they don't use food paste to replicate, but are still replicated. These are available at all tiers of upgrade parts.
	var/list/reagent_tier0 = list("water", "sodiumchloride", "blackpepper", "ice")
	//Tier 1 reagents are basic food reagents. These are available at all tiers of upgrades parts.
	var/list/reagent_tier1 = list("nutriment", "protein", "plantmatter", "rice", "sugar")
	//Tier 2 reagents are less common food reagents, including some condiments, flavorings, and juices. These are available beginning at second tier parts.
	var/list/reagent_tier2 = list(
						"ketchup", "berryjuice", "egg", "cocoa", "soysauce", "capsaicin", "tomatojuice", "sprinkles", "cheese", "banana", "toxin",
						"mashedpotatoes", "poisonberryjuice", "chocolate", "cream", "milk", "soymilk", "lemonjuice", "limejuice", "grapejuice",
						"orangejuice", "cherryjelly", "watermelonjuice", "vanilla")
	//Tier 3 reagents are even less common, typically things found in very complex recipes and rarer ingredients. These are available beginning at third tier parts.
	var/list/reagent_tier3 = list(
						"vitamin", "frostoil", "porktonium", "msg", "fake_cheese", "slimejelly", "coffee", "gravy", "salglu_solution", "amanitin",
						"psilocybin", "oculine", "blood", "cholestrol", "minttoxin", "space_drugs", "cola", "dr_gibb", "beans",
						"plasma", "ether", "morphine", "synaptizine", "mannitol")
	//Tier 4 reagents are top-quality reagents found in only the best and most complex of recipes and reagents. These are only available with the best upgrade parts to avoid mass production of the chems without effort.
	var/list/reagent_tier4 = list("omnizine", "weak_omnizine", "sulfonal")

	//memory_slots is the number of memory slots you can save dishes to for replication. Upgrading the scanning module improves this, allowing for more stored dish options.
	var/memory_slots = 1

	//Memory slot breakdown:
	//"name" stores the dish's displayed name, forn ensuring replicated dishes also are named the same as the original (for renamed dishes mostly)
	//"item" stores the food item path, for creating the replicated items of the correct type.
	//"reagents" is a list of all the reagents in the food when it was scanned, though not all reagents may be replicated depending on the reagent_tier and reagents present.
	var/list/memory1 = list("name" = null, "item" = null, "reagents" = list())
	var/list/memory2 = list("name" = null, "item" = null, "reagents" = list())
	var/list/memory3 = list("name" = null, "item" = null, "reagents" = list())
	var/list/memory4 = list("name" = null, "item" = null, "reagents" = list())
	var/obj/item/weapon/reagent_containers/food/snacks/loaded = null

/obj/machinery/food_replicator/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/food_replicator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/food_replicator/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/food_replicator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/quadultra(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module/triphasic(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/food_replicator/Destroy()
	clear_memory(-1)		//just in case, probably don't need to do this.
	eject_dish()
	if(food_paste)			//if we have food paste left, let's just dump a pile of goop on the floor to represent it being wasted
		if(food_paste >= 100)	//a lot of food paste, better make it a big pile of goop
			new /obj/effect/decal/cleanable/molten_object/large(get_turf(src))
		else
			new /obj/effect/decal/cleanable/molten_object(get_turf(src))
	return ..()

/obj/machinery/food_replicator/RefreshParts()
	recycle_rate = 0.7
	reagent_tier = 1
	memory_slots = 1
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		recycle_rate = 0.6 + (M.rating * 0.1)	//70% at tier 1, 80% at tier 2, 90% at tier 3, 100% at tier 4
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		reagent_tier = ML.rating
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		memory_slots = SM.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		max_food_paste = MB.rating * 200

//scan_food is used to determine the cost of replicating the loaded food item.
//if the recycling var is set, it includes reagents from all tiers, even if you can't replicate them yet. Non-tiered reagents still don't count though.
//this is so don't get double shafted by trying to recycle complex dishes in a low tier replicator (the recycle_rate already punishes you enough).
/obj/machinery/food_replicator/proc/scan_food(recycling = 0)
	var/result = 0
	if(!loaded)
		return -1
	if(!loaded.reagents)
		visible_message("<span class='warning'>[loaded] lacks a reagents holder! Alert a coder!</span>")
		return -1
	if(!loaded.reagents.total_volume)
		visible_message("<span class='warning'>[loaded] contains no reagents at all!</span>")
		return -1
	for(var/datum/reagent/R in loaded.reagents.reagent_list)
		if(reagent_tier == 4 || recycling)
			if(R.id in reagent_tier4)
				result += R.volume
		if(reagent_tier >= 3 || recycling)
			if(R.id in reagent_tier3)
				result += R.volume
		if(reagent_tier >= 2 || recycling)
			if(R.id in reagent_tier2)
				result += R.volume
		if(R.id in reagent_tier1)
			result += R.volume
	return result

//get_cost_from_memory is used to determine the cost of replicating the reagents based on the list of reagents supplied.
/obj/machinery/food_replicator/proc/get_cost_from_memory(list/reagent_memory)
	var/result = 0
	if(!reagent_memory)
		return -1
	for(var/datum/reagent/R in reagent_memory)
		if(reagent_tier == 4)
			if(R.id in reagent_tier4)
				result += R.volume
		if(reagent_tier >= 3)
			if(R.id in reagent_tier3)
				result += R.volume
		if(reagent_tier >= 2)
			if(R.id in reagent_tier2)
				result += R.volume
		if(reagent_tier >= 1)
			if(R.id in reagent_tier1)
				result += R.volume
	return result

//save_food is used to store the loaded food item's path and all its reagents (regardless of current replication ability) to a memory slot for later use.
/obj/machinery/food_replicator/proc/save_food(slot = 0)
	if(!loaded)
		return -1
	if(!loaded.reagents)
		visible_message("<span class='warning'>[loaded] lacks a reagents holder! Alert a coder!</span>")
		return -1
	if(!loaded.reagents.total_volume)
		visible_message("<span class='warning'>[loaded] contains no reagents at all!</span>")
		return -1
	if(loaded.duped)
		visible_message("<span class='warning'>[loaded] exhibits signs of replication degradation, and cannot be saved to memory for future replication.</span>")
		return -1
	if(!slot)
		return 0
	clear_memory(slot, 1)	//safety measure to ensure we don't somehow blend the old and new data
	var/food_item = loaded.type
	var/reagent_memory = loaded.reagents.reagent_list.Copy()
	switch(slot)
		if(1)
			memory1["name"] = loaded.name
			memory1["item"] = food_item
			memory1["reagents"] = reagent_memory
		if(2)
			memory2["name"] = loaded.name
			memory2["item"] = food_item
			memory2["reagents"] = reagent_memory
		if(3)
			memory3["name"] = loaded.name
			memory3["item"] = food_item
			memory3["reagents"] = reagent_memory
		if(4)
			memory4["name"] = loaded.name
			memory4["item"] = food_item
			memory4["reagents"] = reagent_memory
		else
			visible_message("<span class='warning'>Unable to save food configuration: memory index out of bounds. Alert a coder!</span>")
			return 0
	return 1

//copy_food is used to create a replication of the loaded food
/obj/machinery/food_replicator/proc/copy_food()
	if(!loaded)
		visible_message("<span class='warning'>ERROR 404: SNACK NOT FOUND!</span>")
		return 0
	if(loaded.duped)
		visible_message("<span class='warning'>[loaded] exhibits signs of replication degradation, and cannot be replicated.</span>")
	var/cost = scan_food()
	if(cost == -1)
		visible_message("<span class='warning'>There was an error while scanning, aborting replication.</span>")
		return 0
	if(!cost)
		visible_message("<span class='warning'>Scans indicate that the replicator is currently unable to replicate this dish due to hardware constraints.</span>")
		return 0
	if(cost > food_paste)
		visible_message("<span class='warning'>Scans indicate that the replicator lacks sufficient food paste to replicate this dish. Please recycle more food or insert a less complex dish.</span>")
		return 0
	operating = 1
	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	var/path_to_dupe = loaded.type
	var/obj/item/weapon/reagent_containers/food/snacks/dupe = new path_to_dupe()
	dupe.name = loaded.name		//we even replicate renamed dishes' names!
	dupe.duped = 1
	replicate_reagents(loaded.reagents.reagent_list, dupe)
	handle_emag_effect(dupe)
	sleep(20)
	adjust_paste(-cost)
	use_power(active_power_usage)
	dupe.forceMove(get_turf(src))
	operating = 0
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return 1

//copy_food_from_memory is used to create a replication of a previously saved food item from the given memory slot
/obj/machinery/food_replicator/proc/copy_food_from_memory(slot = 0)
	var/food_item
	var/dish_name
	var/list/reagent_memory = list()
	switch(slot)
		if(1)
			dish_name = memory1["name"]
			food_item = memory1["item"]
			reagent_memory = memory1["reagents"]
		if(2)
			dish_name = memory2["name"]
			food_item = memory2["item"]
			reagent_memory = memory2["reagents"]
		if(3)
			dish_name = memory3["name"]
			food_item = memory3["item"]
			reagent_memory = memory3["reagents"]
		if(4)
			dish_name = memory4["name"]
			food_item = memory4["item"]
			reagent_memory = memory4["reagents"]
		else
			visible_message("<span class='warning'>ERROR 404: MEMORY ADDRESS NOT FOUND!</span>")
			return 0
	if(!food_item)
		visible_message("<span class='warning'>Memory slot [slot] appears to lack a saved food item. Alert a coder if something is saved in that slot!</span>")
		return 0
	var/cost = get_cost_from_memory(reagent_memory)
	if(cost == -1)
		visible_message("<span class='warning'>There was an error while calculating necessary resources, aborting replication.</span>")
		return 0
	if(!cost)
		visible_message("<span class='warning'>Scans indicate that the replicator is currently unable to replicate this dish due to hardware constraints.</span>")
		return 0
	if(cost > food_paste)
		visible_message("<span class='warning'>Scans indicate that the replicator lacks sufficient food paste to replicate this dish. Please recycle more food or select a less complex dish.</span>")
		return 0
	operating = 1
	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	var/obj/item/weapon/reagent_containers/food/snacks/dupe = new food_item()
	dupe.name = dish_name		//we even replicate renamed dishes' names!
	dupe.duped = 1
	replicate_reagents(reagent_memory, dupe)
	handle_emag_effect(dupe)
	sleep(20)
	adjust_paste(-cost)
	use_power(active_power_usage)
	dupe.forceMove(get_turf(src))
	operating = 0
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return 1

//clear_memory is used to clear out a memory slot's data without replacing it.
/obj/machinery/food_replicator/proc/clear_memory(slot = 0, silent = 0)
	var/cleared = 0
	switch(slot)
		if(-1)	//slot = -1 will clear all slots and won't set cleared so it won't announce
			memory1["name"] = null
			memory1["item"] = null
			memory1["reagents"] = list()

			memory2["name"] = null
			memory2["item"] = null
			memory2["reagents"] = list()

			memory3["name"] = null
			memory3["item"] = null
			memory3["reagents"] = list()

			memory4["name"] = null
			memory4["item"] = null
			memory4["reagents"] = list()
		if(1)
			memory1["name"] = null
			memory1["item"] = null
			memory1["reagents"] = list()
			cleared = 1
		if(2)
			memory2["name"] = null
			memory2["item"] = null
			memory2["reagents"] = list()
			cleared = 1
		if(3)
			memory3["name"] = null
			memory3["item"] = null
			memory3["reagents"] = list()
			cleared = 1
		if(4)
			memory4["name"] = null
			memory4["item"] = null
			memory4["reagents"] = list()
			cleared = 1
	if(cleared && !silent)
		visible_message("<span class='notice'>Memory Slot [slot] erased and awaiting a new saved dish.</span>")

//replicate_reagents is used to handle the replication and filling of reagents from the supplied reagent list to supplied target copy
/obj/machinery/food_replicator/proc/replicate_reagents(list/reagent_list = null, obj/item/weapon/reagent_containers/food/snacks/target = null)
	if(!reagent_list || !target)
		visible_message("<span class='warning'>Error in reagent replication subroutines: missing argument(s). Alert a coder!</span>")
		return 0
	target.reagents.clear_reagents()
	for(var/datum/reagent/R in reagent_list)
		//Tier 4 reagents require reagent_tier to be 4 to be added
		if(reagent_tier == 4)
			if(R.id in reagent_tier4)
				target.reagents.add_reagent(R.id, R.volume)
		//Tier 3 reagents require reagent_tier to be at least 3 to be added
		if(reagent_tier >= 3)
			if(R.id in reagent_tier3)
				target.reagents.add_reagent(R.id, R.volume)
		//Tier 2 reagents require reagent_tier to be at least 2 to be added
		if(reagent_tier >= 2)
			if(R.id in reagent_tier2)
				target.reagents.add_reagent(R.id, R.volume)
		//Tier 1 reagents are always able to be added (if reagent_tier is ever less than 1, you're missing parts or someone var-editted badly!)
		if(R.id in reagent_tier1)
			target.reagents.add_reagent(R.id, R.volume)
		//Tier 0 reagents are always able to be added, and they also don't cost anything to replicate so the system ignores them for costs!
		if(R.id in reagent_tier0)
			target.reagents.add_reagent(R.id, R.volume)
	return 1

//handle_emag_effect is used to handle the emagged machine replacing all nutriment, protein, and plantmatter in the produced food with poisons. Delicious...
/obj/machinery/food_replicator/proc/handle_emag_effect(obj/item/weapon/reagent_containers/food/snacks/bait = null)
	if(!bait || !emagged)
		return
	for(var/datum/reagent/R in bait.reagents.reagent_list)
		if(R.id in list("nutriment", "protein", "plantmatter"))
			var/vol = R.volume
			bait.reagents.remove_reagent(R.id, vol)
			//what a delicious mixture of reagents to poison our victims with: instant food poisoning, increased hunger, and toxin damage.
			bait.reagents.add_reagent("????", vol/3)
			bait.reagents.add_reagent("lipolicide", vol/3)
			bait.reagents.add_reagent("carpotoxin", vol/3)

//recycle_food is used to convert the loaded food item into raw food_paste to replicate with
/obj/machinery/food_replicator/proc/recycle_food()
	if(!loaded)
		return 0
	if(food_paste >= max_food_paste)
		visible_message("<span class='warning'>Food paste stores filled. Please replicate a dish or produce a food polyhedron before recycling.</span>")
		return 0
	var/base_amount = scan_food(1)
	if(base_amount < 0)
		visible_message("<span class='warning'>Error encountered while scanning dish to be recycled, aborting recycle subroutine.</span>")
		return 0
	var/recycle_value = base_amount * recycle_rate
	qdel(loaded)
	loaded = null
	adjust_paste(recycle_value)
	use_power(active_power_usage/2)		//uses half the power to break down a dish that it takes to produce one
	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	visible_message("<span class='notice'>Recycling complete: [recycle_value] units of food paste salvaged.</span>")
	return 1

//print_poly is used to produce food polys, a polyhedric snack of pure nutriment, from food paste. Food replicators can always make this without a dish loaded or saved to memory.
/obj/machinery/food_replicator/proc/print_poly(sides = 1, silent = 0)
	if(food_paste < sides)
		visible_message("<span class='warning'>Scans indicate that the replicator lacks sufficient food paste to produce the desired food polyhedron. Please recycle more food or select fewer sides.</span>")
		return 0
	operating = 1
	if(!silent)
		playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	var/obj/item/weapon/reagent_containers/food/snacks/food_poly/poly = null
	switch(sides)
		if(1)
			poly = new /obj/item/weapon/reagent_containers/food/snacks/food_poly()
		if(4)
			poly = new /obj/item/weapon/reagent_containers/food/snacks/food_poly/tetrahedron()
		if(6)
			poly = new /obj/item/weapon/reagent_containers/food/snacks/food_poly/cube()
		if(8)
			poly = new /obj/item/weapon/reagent_containers/food/snacks/food_poly/octahedron()
		if(12)
			poly = new /obj/item/weapon/reagent_containers/food/snacks/food_poly/dodecahedron()
		if(20)
			poly = new /obj/item/weapon/reagent_containers/food/snacks/food_poly/icosahedron()
	//food_polys are always considered duplicated since they are only made by the replicator, so we don't need to set the duped var since it is set in the food_poly define
	//food_polys don't replicate reagents since they aren't being replicated from something else.
	handle_emag_effect(poly)
	sleep(20)
	adjust_paste(-sides)
	if(!silent)		//won't use power when we spit out excess (since that runs silently)
		use_power(active_power_usage)
	poly.forceMove(get_turf(src))
	operating = 0
	if(!silent)
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return 1

//adjust_paste is used to alter and sanity check the food_paste value.
//if food_paste is above the max_food_paste, it will begin printing off a pile of food polys until it is at or below max again.
/obj/machinery/food_replicator/proc/adjust_paste(amount = 0)
	food_paste = max(0, (food_paste + amount))

	if(food_paste > max_food_paste)
		var/paste_to_waste = food_paste - max_food_paste
		if(paste_to_waste >= 20)
			print_poly(20, 1)
		else if(paste_to_waste >= 12)
			print_poly(12, 1)
		else if(paste_to_waste >= 8)
			print_poly(8, 1)
		else if(paste_to_waste >= 6)
			print_poly(6, 1)
		else if(paste_to_waste >= 4)
			print_poly(4, 1)
		else
			print_poly(1, 1)

/obj/machinery/food_replicator/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/food_replicator/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	ui_interact(user)

/obj/machinery/food_replicator/interact(mob/user)
	if(panel_open || !anchored)
		return
	//todo

/obj/machinery/food_replicator/attackby(obj/item/O, mob/user, params)
	if(operating)
		return
	if(default_deconstruction_screwdriver(user, open_icon, off_icon, O))
		return
	if(default_unfasten_wrench(user, O))
		return
	if(exchange_parts(user, O))
		return
	default_deconstruction_crowbar(O)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		if(loaded)
			to_chat(user, "<span class='warning'>There is already a dish loaded. Recycle or eject it before adding a new dish.</span>")
			return
		var/obj/item/weapon/reagent_containers/food/snacks/to_load = O
		if(!user.canUnEquip(to_load, 0))
			to_chat(user, "<span class='warning'>[to_load] is stuck to your hand, you can't seem to put it down!</span>")
			return
		user.unEquip(to_load)
		to_load.forceMove(src)
		loaded = to_load
		nanomanager.update_uis(src)
		return 1

	if(panel_open && iswire(O))
		var/obj/item/stack/cable_coil/C = O
		if(stat & BROKEN)
			if(C.amount >= 5)
				if(do_after(user, 40, target = src))
					to_chat(user, "<span class='notice'>You replace the burnt out wiring, restoring functionality.</span>")
					C.use(5)
					set_fix()
			else
				to_chat(user, "<span class='warning'>You don't have enough cable to repair the wiring.</span>")
		else
			to_chat(user, "<span class='notice'>The wiring doesn't require replacing at this time.</span>")
		return 1

	if(istype(O, /obj/item/weapon/card/emag))
		emag_act(user)
		return 1

/obj/machinery/food_replicator/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You corrupt the reagent replication subroutine to lace created dishes with poisons.</span>")
		emagged = 1
	else
		to_chat(user, "<span class='warning'>The reagent replication subroutines are already corrupted!</span>")

/obj/machinery/food_replicator/proc/set_broken()
	stat |= BROKEN
	//make a shower of sparks to communicate the wires burned out
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	use_power = 0	//while we are busted, we won't draw power
	update_icon()

/obj/machinery/food_replicator/proc/set_fix()
	stat &= ~BROKEN
	use_power = 1	//let the power flow through you!
	update_icon()

/obj/machinery/food_replicator/emp_act(severity)
	..()
	switch(severity)
		if(1)
			if(prob(50))	//50% chance to wipe a random memory slot we have access to
				clear_memory(rand(1, memory_slots), 1)
			//break the machine so they have to repair it with cables
			set_broken()
		if(2)
			if(prob(50))	//50% chance to wipe all memory slots, otherwise it wipes a random one we have access to
				clear_memory(-1)
			else
				clear_memory(rand(1,memory_slots), 1)
			//break the machine so they have to repair it with cables
			set_broken()

/obj/machinery/food_replicator/power_change()
	..()
	update_icon()

/obj/machinery/food_replicator/update_icon()
	if(stat & BROKEN)
		icon_state = broken_icon
	else if(panel_open)		//this is so open panels won't magically appear to close just because the power changed
		icon_state = open_icon
	else
		if(stat & NOPOWER)
			spawn(rand(0, 15))
				icon_state = off_icon
		else
			icon_state = on_icon

/obj/machinery/food_replicator/proc/eject_dish()
	if(!loaded)
		return
	loaded.forceMove(get_turf(src))
	loaded = null

/obj/machinery/food_replicator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "food_replicator.tmpl", name, 400, 500)
		ui.open()

/obj/machinery/food_replicator/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["points"] = food_paste
	data["loaded"] = null
	data["memory"] = null
	data["slots"] = memory_slots

	if(loaded)
		var/recycle_value = scan_food(1) * recycle_rate
		var/rep_cost = scan_food()

		var/list/loaded_data = list()
		loaded_data["name"] = loaded.name
		loaded_data["duped"] = loaded.duped
		loaded_data["recycle_value"] = recycle_value
		loaded_data["rep_cost"] = rep_cost

		data["loaded"] = loaded_data

	var/list/memory_data = list()
	memory_data.Add(list(list("slot" = 1, "item_name" = memory1["name"], "cost" = get_cost_from_memory(memory1["reagents"]))))
	memory_data.Add(list(list("slot" = 2, "item_name" = memory2["name"], "cost" = get_cost_from_memory(memory2["reagents"]))))
	memory_data.Add(list(list("slot" = 3, "item_name" = memory3["name"], "cost" = get_cost_from_memory(memory3["reagents"]))))
	memory_data.Add(list(list("slot" = 4, "item_name" = memory4["name"], "cost" = get_cost_from_memory(memory4["reagents"]))))
	data["memory"] = memory_data

	return data

/obj/machinery/food_replicator/Topic(href, href_list)
	if(..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	add_fingerprint(user)

	if(href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	if(operating)
		to_chat(user, "<span class='warning'>This device is busy.</span>")
		return 0

	if(href_list["recycle"])
		recycle_food()
		return 1
	if(href_list["eject"])
		eject_dish()
		return 1
	if(href_list["replicate"])
		var/which = text2num(href_list["replicate"])
		if(which == 5)
			copy_food()
		else
			copy_food_from_memory(which)
		return 1
	if(href_list["save"])
		var/which = text2num(href_list["save"])
		to_chat(user, "<span class='notice'>Saving to slot [which]...</span>")
		save_food(which)
		return 1
	if(href_list["erase"])
		var/which = text2num(href_list["erase"])
		to_chat(user, "<span class='notice'>Erasing slot [which]...</span>")
		clear_memory(which)
		return 1
	if(href_list["poly"])
		var/faces = text2num(href_list["poly"])
		to_chat(user, "<span class='notice'>Printing food poly with [faces] faces...</span>")
		print_poly(faces)
		return 1
	return 0