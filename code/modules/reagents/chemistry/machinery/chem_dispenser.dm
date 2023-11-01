/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	idle_power_consumption = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/ui_title = "Chem Dispenser 5000"
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/powerefficiency = 0.1
	var/amount = 10
	var/recharge_amount = 100
	var/recharge_counter = 0
	var/hackedcheck = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/list/dispensable_reagents = list("hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
	"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
	"copper", "mercury", "plasma", "radium", "water", "ethanol", "sugar", "iodine", "bromine", "silver", "chromium")
	var/list/upgrade_reagents = list("oil", "ash", "acetone", "saltpetre", "ammonia", "diethylamine", "fuel")
	var/list/hacked_reagents = list("toxin")
	var/hack_message = "You disable the safety safeguards, enabling the \"Mad Scientist\" mode."
	var/unhack_message = "You re-enable the safety safeguards, enabling the \"NT Standard\" mode."
	var/is_drink = FALSE

/obj/machinery/chem_dispenser/get_cell()
	return cell

/obj/machinery/chem_dispenser/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/machinery/chem_dispenser/mutagensaltpeter
	name = "botanical chemical dispenser"
	desc = "Creates and dispenses chemicals useful for botany."
	flags = NODECONSTRUCT

	dispensable_reagents = list(
		"mutagen",
		"saltpetre",
		"eznutriment",
		"left4zednutriment",
		"robustharvestnutriment",
		"water",
		"atrazine",
		"pestkiller",
		"cryoxadone",
		"ammonia",
		"ash",
		"diethylamine")
	upgrade_reagents = null

/obj/machinery/chem_dispenser/mutagensaltpeter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/machinery/chem_dispenser/RefreshParts()
	recharge_amount = initial(recharge_amount)
	var/newpowereff = 0.0666666
	for(var/obj/item/stock_parts/cell/P in component_parts)
		cell = P
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		newpowereff += 0.0166666666 * M.rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_amount *= C.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if(M.rating > 3)
			dispensable_reagents |= upgrade_reagents
	powerefficiency = round(newpowereff, 0.01)

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>[src]'s maintenance hatch is open!</span>"
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: <br>Recharging <b>[recharge_amount]</b> power units per interval.<br>Power efficiency increased by <b>[round((powerefficiency * 1000) - 100, 1)]%</b>.<span>"


/obj/machinery/chem_dispenser/process()
	if(recharge_counter >= 4)
		if(!is_operational())
			return
		var/usedpower = cell.give(recharge_amount)
		if(usedpower)
			use_power(15 * recharge_amount)
		recharge_counter = 0
		return
	recharge_counter++

/obj/machinery/chem_dispenser/update_icon_state()
	if(panel_open)
		icon_state = "[initial(icon_state)]-o"
		return
	if(!has_power() && !is_drink)
		icon_state = "dispenser_nopower"
		return
	icon_state = "[initial(icon_state)][beaker ? "_working" : ""]"

/obj/machinery/chem_dispenser/ex_act(severity)
	if(severity < 3)
		if(beaker)
			beaker.ex_act(severity)
		..()

/obj/machinery/chem_dispenser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null

/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemDispenser", ui_title, 390, 655)
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user)
	var/list/data = list()

	data["glass"] = is_drink
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * powerefficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * powerefficiency
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var/beakerContents[0]
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id"=R.id, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if(beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var/chemicals[0]
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	return data

/obj/machinery/chem_dispenser/ui_act(actions, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!anchored)
		return

	. = TRUE
	switch(actions)
		if("amount")
			amount = clamp(round(text2num(params["amount"]), 1), 0, 50) // round to nearest 1 and clamp to 0 - 50
		if("dispense")
			if(!is_operational() || QDELETED(cell))
				return
			if(!beaker || !dispensable_reagents.Find(params["reagent"]))
				return
			var/datum/reagents/R = beaker.reagents
			var/free = R.maximum_volume - R.total_volume
			var/actual = min(amount, (cell.charge * powerefficiency) * 10, free)
			if(!cell.use(actual / powerefficiency))
				atom_say("Not enough energy to complete operation!")
				return
			R.add_reagent(params["reagent"], actual)
		if("remove")
			var/amount = text2num(params["amount"])
			if(!beaker || !amount)
				return
			var/datum/reagents/R = beaker.reagents
			var/id = params["reagent"]
			if(amount > 0)
				R.remove_reagent(id, amount)
			else if(amount == -1) //Isolate instead
				R.isolate_reagent(id)
		if("ejectBeaker")
			if(!beaker)
				return
			beaker.forceMove(loc)
			if(Adjacent(usr) && !issilicon(usr))
				usr.put_in_hands(beaker)
			beaker = null
			update_icon(UPDATE_ICON_STATE)
		else
			return FALSE

	add_fingerprint(usr)

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		SStgui.update_uis(src)
		return

	if(isrobot(user))
		return

	if((istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks)) && user.a_intent != INTENT_HARM)
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
			return
		I.forceMove(src)
		if(beaker)
			user.put_in_hands(beaker)
			to_chat(user, "<span class='notice'>You swap [I] with [beaker].</span>")
		else
			to_chat(user, "<span class='notice'>You set [I] on the machine.</span>")
		beaker = I

		SStgui.update_uis(src) // update all UIs attached to src
		update_icon(UPDATE_ICON_STATE)
		return

	return ..()

/obj/machinery/chem_dispenser/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/chem_dispenser/deconstruct(disassembled)
	if(beaker)
		beaker.forceMove(loc)
		beaker = null
	if(cell)
		cell.forceMove(loc)
		cell = null
	return ..()


/obj/machinery/chem_dispenser/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!hackedcheck)
		to_chat(user, hack_message)
		dispensable_reagents += hacked_reagents
		hackedcheck = TRUE
	else
		to_chat(user, unhack_message)
		dispensable_reagents -= hacked_reagents
		hackedcheck = FALSE
	SStgui.update_uis(src)

/obj/machinery/chem_dispenser/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", "[initial(icon_state)]", I))
		return TRUE

/obj/machinery/chem_dispenser/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		return
	if(anchored)
		anchored = FALSE
		WRENCH_UNANCHOR_MESSAGE
	else if(!anchored)
		anchored = TRUE
		WRENCH_ANCHOR_MESSAGE

/obj/machinery/chem_dispenser/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_dispenser/attack_ghost(mob/user)
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user)
	if(stat & BROKEN)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] must be anchored first!</span>")
		return
	ui_interact(user)

/obj/machinery/chem_dispenser/AltClick(mob/user)
	if(!is_drink || !Adjacent(user))
		return
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(anchored)
		to_chat(user, "<span class='warning'>[src] is anchored to the floor!</span>")
		return
	pixel_x = 0
	pixel_y = 0
	setDir(turn(dir, 90))

/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	ui_title = "Soda Dispens-o-matic"
	dispensable_reagents = list("water", "ice", "milk", "soymilk", "coffee", "tea", "hot_coco", "cola", "spacemountainwind", "dr_gibb", "space_up",
	"tonic", "sodawater", "lemon_lime", "grapejuice", "sugar", "orangejuice", "lemonjuice", "limejuice", "tomatojuice", "banana",
	"watermelonjuice", "carrotjuice", "potato", "berryjuice")
	upgrade_reagents = list("bananahonk", "milkshake", "cafe_latte", "cafe_mocha", "triple_citrus", "icecoffe","icetea")
	hacked_reagents = list("thirteenloko")
	hack_message = "You change the mode from 'McNano' to 'Pizza King'."
	unhack_message = "You change the mode from 'Pizza King' to 'McNano'."
	is_drink = TRUE

/obj/machinery/chem_dispenser/soda/Initialize(mapload)
	. = ..()
	QDEL_LIST_CONTENTS(component_parts)
	component_parts += new /obj/item/circuitboard/chem_dispenser/soda(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

/obj/machinery/chem_dispenser/soda/upgraded/Initialize(mapload)
	. = ..()
	QDEL_LIST_CONTENTS(component_parts)
	component_parts += new /obj/item/circuitboard/chem_dispenser/soda(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	ui_title = "Booze Portal 9001"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila", "vermouth", "cognac", "ale", "mead", "synthanol")
	upgrade_reagents = list("iced_beer", "irishcream", "manhattan", "antihol", "synthignon", "bravebull")
	hacked_reagents = list("goldschlager", "patron", "absinthe", "ethanol", "nothing", "sake")
	hack_message = "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes."
	unhack_message = "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes."
	is_drink = TRUE

/obj/machinery/chem_dispenser/beer/Initialize(mapload)
	. = ..()
	QDEL_LIST_CONTENTS(component_parts)
	component_parts += new /obj/item/circuitboard/chem_dispenser/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

/obj/machinery/chem_dispenser/beer/upgraded/Initialize(mapload)
	. = ..()
	QDEL_LIST_CONTENTS(component_parts)
	component_parts += new /obj/item/circuitboard/chem_dispenser/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

// Handheld chem dispenser
/obj/item/handheld_chem_dispenser
	name = "handheld chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	item_state = "handheld_chem"
	icon_state = "handheld_chem"
	flags = NOBLUDGEON
	var/obj/item/stock_parts/cell/high/cell = null
	var/amount = 10
	var/mode = "dispense"
	var/is_drink = FALSE
	var/list/dispensable_reagents = list("hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
	"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
	"copper", "mercury", "plasma", "radium", "water", "ethanol", "sugar", "iodine", "bromine", "silver", "chromium")
	var/current_reagent = null
	var/efficiency = 0.2
	var/recharge_rate = 1 // Keep this as an integer

/obj/item/handheld_chem_dispenser/Initialize()
	..()
	cell = new(src)
	dispensable_reagents = sortList(dispensable_reagents)
	current_reagent = pick(dispensable_reagents)
	update_icon(UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/item/handheld_chem_dispenser/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/handheld_chem_dispenser/get_cell()
	return cell

/obj/item/handheld_chem_dispenser/afterattack(obj/target, mob/user, proximity)
	if(!proximity || !current_reagent || !amount)
		return

	if(!check_allowed_items(target,target_self = TRUE) || !target.is_refillable())
		return
	switch(mode)
		if("dispense")
			var/free = target.reagents.maximum_volume - target.reagents.total_volume
			var/actual = min(amount, round(cell.charge * efficiency), free)
			if(actual)
				target.reagents.add_reagent(current_reagent, actual)
				cell.charge -= actual / efficiency
				to_chat(user, "<span class='notice'>You dispense [actual] unit\s of [current_reagent] into [target].</span>")
				update_icon(UPDATE_OVERLAYS)
			else if(free) // If actual is nil and there's still free space, it means we're out of juice
				to_chat(user, "<span class='warning'>Insufficient energy to complete operation.</span>")
		if("remove")
			if(!target.reagents.remove_reagent(current_reagent, amount))
				to_chat(user, "<span class='notice'>You remove [amount] unit\s of [current_reagent] from [target].</span>")
		if("isolate")
			if(!target.reagents.isolate_reagent(current_reagent))
				to_chat(user, "<span class='notice'>You remove all but [current_reagent] from [target].</span>")

/obj/item/handheld_chem_dispenser/attack_self(mob/user)
	if(cell)
		ui_interact(user)
	else
		to_chat(user, "<span class='warning'>[src] lacks a power cell!</span>")


/obj/item/handheld_chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "HandheldChemDispenser", name, 390, 500)
		ui.open()

/obj/item/handheld_chem_dispenser/ui_data(mob/user)
	var/list/data = list()

	data["glass"] = is_drink
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * efficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * efficiency
	data["current_reagent"] = current_reagent
	data["mode"] = mode

	return data

/obj/item/handheld_chem_dispenser/ui_static_data()
	var/list/data = list()
	var/list/chemicals = list()
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals


	return data

/obj/item/handheld_chem_dispenser/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("amount")
			amount = clamp(round(text2num(params["amount"])), 1, 50) // round to nearest 1 and clamp to 1 - 50
		if("dispense")
			if(params["reagent"] in dispensable_reagents)
				current_reagent = params["reagent"]
				update_icon(UPDATE_OVERLAYS)
		if("mode")
			switch(params["mode"])
				if("remove")
					mode = "remove"
				if("dispense")
					mode = "dispense"
				if("isolate")
					mode = "isolate"
			update_icon(UPDATE_OVERLAYS)
		else
			return FALSE

	add_fingerprint(usr)

/obj/item/handheld_chem_dispenser/update_overlays()
	. = ..()
	if(cell && cell.charge)
		var/image/power_light = image('icons/obj/chemical.dmi', src, "light_low")
		var/percent = round((cell.charge / cell.maxcharge) * 100)
		switch(percent)
			if(0 to 33)
				power_light.icon_state = "light_low"
			if(34 to 66)
				power_light.icon_state = "light_mid"
			if(67 to INFINITY)
				power_light.icon_state = "light_full"
		. += power_light

		var/image/mode_light = image('icons/obj/chemical.dmi', src, "light_remove")
		mode_light.icon_state = "light_[mode]"
		. += mode_light

		var/image/chamber_contents = image('icons/obj/chemical.dmi', src, "reagent_filling")
		var/datum/reagent/R = GLOB.chemical_reagents_list[current_reagent]
		chamber_contents.icon += R.color
		. += chamber_contents

/obj/item/handheld_chem_dispenser/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	if(isrobot(loc) && cell.charge < cell.maxcharge)
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell && R.cell.charge > recharge_rate / efficiency)
			var/actual = min(recharge_rate / efficiency, cell.maxcharge - cell.charge)
			R.cell.charge -= actual
			cell.charge += actual

	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/item/handheld_chem_dispenser/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < 100)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.unEquip(W))
				return
			W.loc = src
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon(UPDATE_OVERLAYS)

/obj/item/handheld_chem_dispenser/screwdriver_act(mob/user, obj/item/I)
	if(!isrobot(loc) && cell)
		cell.update_icon()
		cell.loc = get_turf(src)
		cell = null
		to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
		update_icon(UPDATE_OVERLAYS)
		return
	..()

/obj/item/handheld_chem_dispenser/booze
	name = "handheld bar tap"
	item_state = "handheld_booze"
	icon_state = "handheld_booze"
	is_drink = TRUE
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila",
		"vermouth", "cognac", "ale", "mead", "synthanol")

/obj/item/handheld_chem_dispenser/soda
	name = "handheld soda fountain"
	item_state = "handheld_soda"
	icon_state = "handheld_soda"
	is_drink = TRUE
	dispensable_reagents = list("water", "ice", "milk", "soymilk", "coffee", "tea", "hot_coco", "cola", "spacemountainwind", "dr_gibb", "space_up",
	"tonic", "sodawater", "lemon_lime", "grapejuice", "sugar", "orangejuice", "lemonjuice", "limejuice", "tomatojuice", "banana",
	"watermelonjuice", "carrotjuice", "potato", "berryjuice")

/obj/item/handheld_chem_dispenser/botanical
	name = "handheld botanical chemical dispenser"
	dispensable_reagents = list(
		"mutagen",
		"saltpetre",
		"eznutriment",
		"left4zednutriment",
		"robustharvestnutriment",
		"water",
		"atrazine",
		"pestkiller",
		"cryoxadone",
		"ammonia",
		"ash",
		"diethylamine")
