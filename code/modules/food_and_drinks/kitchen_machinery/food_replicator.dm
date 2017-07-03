
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
	//Tier 1 reagents are basic food reagents. These are available at all tiers of upgrades parts.
	//Tier 2 reagents are less common food reagents, including some condiments, flavorings, and juices. These are available beginning at second tier parts.
	//Tier 3 reagents are even less common, typically things found in very complex recipes and rarer ingredients. These are available beginning at third tier parts.
	//Tier 4 reagents are top-quality reagents found in only the best and most complex of recipes and reagents. These are only available with the best upgrade parts to avoid mass production of the chems without effort.
	var/list/reagent_tiers = list(
								"tier0" = list("water", "sodiumchloride", "blackpepper", "ice"),
								"tier1" = list("nutriment", "protein", "plantmatter", "rice", "sugar"),
								"tier2" = list("ketchup", "berryjuice", "egg", "cocoa", "soysauce", "capsaicin", "tomatojuice", "sprinkles", "cheese", "banana", "toxin",
												"mashedpotatoes", "poisonberryjuice", "chocolate", "cream", "milk", "soymilk", "lemonjuice", "limejuice", "grapejuice",
												"orangejuice", "cherryjelly", "watermelonjuice", "vanilla"),
								"tier3" = list("vitamin", "frostoil", "porktonium", "msg", "fake_cheese", "slimejelly", "coffee", "gravy", "salglu_solution", "amanitin",
												"psilocybin", "oculine", "blood", "cholestrol", "minttoxin", "space_drugs", "cola", "dr_gibb", "beans",
												"plasma", "ether", "morphine", "synaptizine", "mannitol"),
								"tier4" = list("omnizine", "weak_omnizine", "sulfonal")
								)

	//memory_slots is the number of memory slots you can save dishes to for replication. Upgrading the scanning module improves this, allowing for more stored dish options.
	var/memory_slots = 1
	var/max_slots = 4			//maximum number of memory_slots. Currently 4, we can change this if we add a 5th tier of stock_parts or want to make it so you unlock multiple slots per tier (you'll need to adjust the RefreshParts proc too for that)
	var/list/memory	= null		//this gets built in New(), so we can do with with a loop to cut down on what looks like copy-pasta in the defines
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
	if(!memory)
		memory = list()
		for(var/i in 1 to max_slots)
			//memory list breakdown:
				//"name" is the dish name, used to ensure replicated dishes copy even custom names
				//"desc" is the dish desc, used to ensure replicated dishes examine the same
				//"icon" is the dish icon file, used to ensure we can access the proper sprite
				//"state" is the dish icon_state, used to ensure we look like what we copied
				//"slice_path" is the dish's sliceable path, if one exists for the original food. This is so you can cut replicated cakes.
				//"slice_num" is the dish's slices_num, used to ensure we can slice into the proper number of pieces
				//"reagents" is the complete reagent_list of the dish when saved. This may include reagents we can't replicate at the time.
			var/list/temp_list = make_memory_entry()
			memory.Add(list("slot[i]" = temp_list))

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
	clear_memory(null, -1)		//just in case, probably don't need to do this.
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
		//adjust this if you change the number of max_slots to not be equal to the highest scanning module rating value
		memory_slots = SM.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		max_food_paste = MB.rating * 200

//make_memory_entry is used to quickly build a list from provided arguments for use in memory slots or other procs
//by default, this returns a blank version of the list with the proper associated values defined.
//calling this with use_loaded = 1 will set the associated values to those of the loaded item (if possible) and return the populated list
/obj/machinery/food_replicator/proc/make_memory_entry(use_loaded = 0)
	var/list/temp_list = list("name" = null, "desc" = null, "icon" = null, "state" = null, "slice_path" = null, "slice_num" = null, "reagents" = list())
	if(use_loaded && loaded)
		temp_list["name"] = loaded.name
		temp_list["desc"] = loaded.desc
		temp_list["icon"] = loaded.icon
		temp_list["state"] = loaded.icon_state
		temp_list["slice_path"] = loaded.slice_path
		temp_list["slice_num"] = loaded.slices_num
		var/list/temp_reagents = list()
		for(var/datum/reagent/R in loaded.reagents.reagent_list)
			temp_reagents["[R.id]"] = R.volume
		temp_list["reagents"] = temp_reagents
	return temp_list

//scan_food is used to determine the cost of replicating the loaded food item.
//if the recycling var is set, it includes reagents from all tiers, even if you can't replicate them yet. Non-tiered reagents still don't count though.
//this is so don't get double shafted by trying to recycle complex dishes in a low tier replicator (the recycle_rate already punishes you enough).
/obj/machinery/food_replicator/proc/scan_food(mob/user, recycling = 0)
	var/result = 0
	if(!loaded)
		return -1
	if(!loaded.reagents)
		log_runtime(EXCEPTION("[loaded] lacks a reagents holder"))
		return -1
	if(!loaded.reagents.total_volume)
		to_chat(user, "<span class='warning'>[loaded] contains no reagents at all!</span>")
		return -1
	var/list/reagent_memory = loaded.reagents.reagent_list.Copy()
	var/target_tier = reagent_tier
	if(recycling)
		target_tier = 4
	for(var/i in 1 to target_tier)
		var/list/this_tier = reagent_tiers["tier[i]"]
		for(var/datum/reagent/R in reagent_memory)
			if(R.id in this_tier)
				result += R.volume
	return result

//get_cost_from_list is used to determine the cost of replicating the reagents based on the list of reagents supplied.
/obj/machinery/food_replicator/proc/get_cost_from_list(list/reagent_memory)
	var/result = 0
	if(!reagent_memory)
		return -1
	for(var/i in 1 to reagent_tier)
		var/list/this_tier = reagent_tiers["tier[i]"]
		for(var/id in reagent_memory)
			if(id in this_tier)
				result += reagent_memory[id]
	return result

//save_food is used to store the loaded food item's path and all its reagents (regardless of current replication ability) to a memory slot for later use.
/obj/machinery/food_replicator/proc/save_food(mob/user, slot = 0)
	if(!loaded)
		return -1
	if(!loaded.reagents)
		log_runtime(EXCEPTION("[loaded] lacks a reagents holder"))
		return -1
	if(!loaded.reagents.total_volume)
		to_chat(user, "<span class='warning'>[loaded] contains no reagents at all!</span>")
		return -1
	if(loaded.duped)
		to_chat(user, "<span class='warning'>[loaded] exhibits signs of replication degradation, and cannot be saved to memory for future replication.</span>")
		return -1
	if(!slot || slot > memory_slots)	//nice try.
		return 0
	clear_memory(user, slot, 1)	//safety measure to ensure we don't somehow blend the old and new data
	if(slot <= memory_slots)
		memory["slot[slot]"] = make_memory_entry(1)
	else
		to_chat(user, "<span class='warning'>Unable to save food configuration: memory slot locked. Nice Topic exploit attempt!</span>")
		return 0
	return 1

//copy_food is used to create a replication of the loaded food
/obj/machinery/food_replicator/proc/copy_food(mob/user)
	if(!loaded)
		to_chat(user, "<span class='warning'>ERROR 404: SNACK NOT FOUND!</span>")
		return 0
	if(loaded.duped)
		to_chat(user, "<span class='warning'>[loaded] exhibits signs of replication degradation, and cannot be replicated.</span>")
	var/cost = scan_food(user)
	if(!check_cost(user, cost))
		return 0
	operating = 1
	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	var/list/temp_memory = make_memory_entry(1)
	sleep(20)	//this is to avoid the sounds overlapping
	create_dish(user, temp_memory, cost)
	operating = 0
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return 1

//create_dish is used to actually produce the desired food item.
//the supplied list is used to contain the original variables to copy or the path of the proper polygon if skip_rep is set.
//skip_rep is to be set when making food polyhedrons since they don't copy reagents and vars, and skip_power is to be set when you don't want to drain power (excess paste usage)
/obj/machinery/food_replicator/proc/create_dish(mob/user, list/dish_config = null, cost = 0, skip_rep = 0, skip_power = 0)
	if(!dish_config)
		return 0
	var/obj/item/weapon/reagent_containers/food/snacks/dupe
	if(!skip_rep)
		dupe = new /obj/item/weapon/reagent_containers/food/snacks/replica_dish()
		dupe.name = dish_config["name"]
		dupe.desc = dish_config["desc"]
		dupe.icon = dish_config["icon"]
		dupe.icon_state = dish_config["state"]
		dupe.slice_path = dish_config["slice_path"]
		dupe.slices_num = dish_config["slice_num"]
		replicate_reagents(user, dish_config["reagents"], dupe)
	else
		var/poly_path = dish_config["poly"]
		dupe = new poly_path()
	handle_emag_effect(dupe)
	adjust_paste(-cost)
	if(!skip_power)
		use_power(active_power_usage)
	dupe.forceMove(get_turf(src))
	return 1

//copy_food_from_memory is used to create a replication of a previously saved food item from the given memory slot
/obj/machinery/food_replicator/proc/copy_food_from_memory(mob/user, slot = 0)
	var/list/temp_memory = list()
	if(slot > memory_slots)		//nice try.
		return 0
	if(slot <= max_slots)
		temp_memory = memory["slot[slot]"]
	else
		to_chat(user, "<span class='warning'>ERROR 404: MEMORY ADDRESS NOT FOUND!</span>")
		return 0
	if(!temp_memory["name"])
		to_chat(user, "<span class='warning'>Memory slot [slot] appears to lack a saved food item. Alert a coder if something is saved in that slot!</span>")
		return 0
	var/cost = get_cost_from_list(temp_memory["reagents"])
	if(!check_cost(user, cost))
		return 0
	operating = 1
	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	sleep(20)	//this is to avoid the sounds overlapping
	create_dish(user, temp_memory, cost)
	operating = 0
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return 1

//check_cost is used to check if the cost has been set and the machine contains enough food paste to meet it. Mostly here to cut down on copied lines
/obj/machinery/food_replicator/proc/check_cost(mob/user, cost = 0)
	if(cost == -1)
		to_chat(user, "<span class='warning'>There was an error while scanning, aborting replication.</span>")
		return 0
	if(!cost)
		to_chat(user, "<span class='warning'>Scans indicate that the replicator is currently unable to replicate this dish due to hardware constraints.</span>")
		return 0
	if(cost > food_paste)
		to_chat(user, "<span class='warning'>Scans indicate that the replicator lacks sufficient food paste to replicate this dish. Please recycle more food or insert a less complex dish.</span>")
		return 0
	return 1

//clear_memory is used to clear out a memory slot's data without replacing it.
/obj/machinery/food_replicator/proc/clear_memory(mob/user, slot = 0, silent = 0)
	var/cleared = 0
	if(slot == -1)	//slot = -1 will clear all slots and won't set cleared so it won't announce (used in Destroy and emp_act)
		for(var/i in 1 to max_slots)
			memory["slot[i]"] = make_memory_entry()
	else if(slot <= max_slots)
		memory["slot[slot]"] = make_memory_entry()
		cleared = 1
	if(cleared && !silent && user)
		to_chat(user, "<span class='notice'>Memory Slot [slot] erased and awaiting a new saved dish.</span>")

//replicate_reagents is used to handle the replication and filling of reagents from the supplied reagent list to supplied target copy
/obj/machinery/food_replicator/proc/replicate_reagents(mob/user, list/reagent_list = null, obj/item/weapon/reagent_containers/food/snacks/target = null)
	if(!reagent_list || !target)
		to_chat(user, "<span class='warning'>Error in reagent replication subroutines: missing argument(s). Alert a coder!</span>")
		return 0
	target.reagents.clear_reagents()
	for(var/i in 0 to reagent_tier)
		var/list/this_tier = reagent_tiers["tier[i]"]
		for(var/id in reagent_list)
			if(id in this_tier)
				target.reagents.add_reagent(id, reagent_list[id])
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
/obj/machinery/food_replicator/proc/recycle_food(mob/user)
	if(!loaded)
		return 0
	if(food_paste >= max_food_paste)
		to_chat(user, "<span class='warning'>Food paste stores filled. Please replicate a dish or produce a food polyhedron before recycling.</span>")
		return 0
	var/base_amount = scan_food(user, 1)
	if(base_amount < 0)
		to_chat(user, "<span class='warning'>Error encountered while scanning dish to be recycled, aborting recycle subroutine.</span>")
		return 0
	var/recycle_value = base_amount * recycle_rate
	qdel(loaded)
	loaded = null
	adjust_paste(recycle_value)
	use_power(active_power_usage/2)		//uses half the power to break down a dish that it takes to produce one
	playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	to_chat(user, "<span class='notice'>Recycling complete: [recycle_value] units of food paste salvaged.</span>")
	return 1

//print_poly is used to produce food polys, a polyhedric snack of pure nutriment, from food paste. Food replicators can always make this without a dish loaded or saved to memory.
/obj/machinery/food_replicator/proc/print_poly(mob/user, sides = 1, silent = 0)
	if(food_paste < sides)
		if(!silent && user)
			to_chat(user, "<span class='warning'>Scans indicate that the replicator lacks sufficient food paste to produce the desired food polyhedron. Please recycle more food or select fewer sides.</span>")
		return 0
	operating = 1
	if(!silent)
		playsound(loc, 'sound/misc/interference.ogg', 50, 1)
	var/list/temp_memory = list("poly" = null)
	switch(sides)
		if(1)
			temp_memory["poly"] = /obj/item/weapon/reagent_containers/food/snacks/food_poly
		if(4)
			temp_memory["poly"] = /obj/item/weapon/reagent_containers/food/snacks/food_poly/tetrahedron
		if(6)
			temp_memory["poly"] = /obj/item/weapon/reagent_containers/food/snacks/food_poly/cube
		if(8)
			temp_memory["poly"] = /obj/item/weapon/reagent_containers/food/snacks/food_poly/octahedron
		if(12)
			temp_memory["poly"] = /obj/item/weapon/reagent_containers/food/snacks/food_poly/dodecahedron
		if(20)
			temp_memory["poly"] = /obj/item/weapon/reagent_containers/food/snacks/food_poly/icosahedron
		else
			//i'm not unsetting the operating var here on purpose.
			//attempting to Topic exploit this for free paste is gonna lock down the machine until manually var-editted by an admin.
			message_admins("[src] in [get_area(loc)] has been operating-locked due to suspected Topic exploiting. The machine cannot be used until the operating var is manually reset as punishment.")
			log_admin("[src] in [get_area(loc)] has been operating-locked due to suspected Topic exploiting. The machine cannot be used until the operating var is manually reset as punishment.")
			return 0
	create_dish(user, temp_memory, sides, skip_rep = 1, skip_power = silent)
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
			print_poly(null, 20, 1)
		else if(paste_to_waste >= 12)
			print_poly(null, 12, 1)
		else if(paste_to_waste >= 8)
			print_poly(null, 8, 1)
		else if(paste_to_waste >= 6)
			print_poly(null,6, 1)
		else if(paste_to_waste >= 4)
			print_poly(null, 4, 1)
		else
			print_poly(null, 1, 1)

/obj/machinery/food_replicator/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/food_replicator/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)
	ui_interact(user)

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
		if(!user.canUnEquip(O, 0))
			to_chat(user, "<span class='warning'>[O] is stuck to your hand, you can't seem to put it down!</span>")
			return
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/icecream))
			to_chat(user, "<span class='warning'>[O] would melt instantly in the replicator, so you decide to not waste it.</span>")
			return
		user.unEquip(O)
		O.forceMove(src)
		loaded = O
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
				clear_memory(null, rand(1, memory_slots), 1)
			//break the machine so they have to repair it with cables
			set_broken()
		if(2)
			if(prob(50))	//50% chance to wipe all memory slots, otherwise it wipes a random one we have access to
				clear_memory(-1)
			else
				clear_memory(null, rand(1,memory_slots), 1)
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
		var/recycle_value = scan_food(user, 1) * recycle_rate
		var/rep_cost = scan_food(user)

		var/list/loaded_data = list()
		loaded_data["name"] = loaded.name
		loaded_data["duped"] = loaded.duped
		loaded_data["recycle_value"] = recycle_value
		loaded_data["rep_cost"] = rep_cost

		data["loaded"] = loaded_data

	var/list/memory_data = list()
	for(var/i in 1 to max_slots)
		var/list/temp_data = memory["slot[i]"]
		var/list/reagent_list = temp_data["reagents"]
		var/cost = get_cost_from_list(reagent_list)
		memory_data.Add(list(list("slot" = i, "item_name" = temp_data["name"], "cost" = cost)))
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
		recycle_food(user)
		return 1
	if(href_list["eject"])
		eject_dish()
		return 1
	if(href_list["replicate"])
		var/which = text2num(href_list["replicate"])
		if(which == 5)
			copy_food(user)
		else
			copy_food_from_memory(user, which)
		return 1
	if(href_list["save"])
		var/which = text2num(href_list["save"])
		to_chat(user, "<span class='notice'>Saving to slot [which]...</span>")
		save_food(user, which)
		return 1
	if(href_list["erase"])
		var/which = text2num(href_list["erase"])
		to_chat(user, "<span class='notice'>Erasing slot [which]...</span>")
		clear_memory(user, which)
		return 1
	if(href_list["poly"])
		var/faces = text2num(href_list["poly"])
		to_chat(user, "<span class='notice'>Printing food poly with [faces] faces...</span>")
		print_poly(user, faces)
		return 1
	return 0