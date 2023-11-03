#define SOIL_COST 25
#define DECAY 0.2
#define MIN_CONVERSION 10
/**
  * # compost bin
  * used to make soil from plants.
  * Doesn't have components.
  */
/obj/machinery/compost_bin
	name = "compost bin"
	desc = "A wooden bin for composting."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "compost_bin-empty"
	power_state = NO_POWER_USE
	density = TRUE
	anchored = TRUE
	/// stage in the process, for timing purposes.
	var/process_counter = 0
	/// amount of biomass in the compost bin
	var/biomass = 0
	/// amount of compost in the compost bin
	var/compost = 0
	/// The maximum amount of biomass the compost bin can store.
	var/biomass_capacity = 1500
	/// The maximum amount of compost the compost bin can store.
	var/compost_capacity = 1500

/obj/machinery/compost_bin/on_deconstruction()
	// returns wood instead of the non-existent components
	new /obj/item/stack/sheet/wood(loc, 10)
	return ..()

/obj/machinery/compost_bin/screwdriver_act(mob/living/user, obj/item/I)
	// there are no screws either
	to_chat(user, "<span class='warning'>[src] has no screws!</span>")
	return TRUE

/obj/machinery/compost_bin/crowbar_act(mob/living/user, obj/item/I)
	// no panel either
	return default_deconstruction_crowbar(user, I, ignore_panel = TRUE)

// Accepts inserted plants and converts them to biomass
/obj/machinery/compost_bin/proc/make_biomass(obj/item/reagent_containers/food/snacks/grown/O)
	// calculate biomass from plant nutriment and plant matter
	var/plant_biomass = O.reagents.get_reagent_amount("nutriment") + O.reagents.get_reagent_amount("plantmatter")
	biomass += clamp(plant_biomass * 10, 1, biomass_capacity - biomass)
	//plant delenda est
	qdel(O)

// takes care of plant insertion and conversion to biomass, and start composting what was inserted
/obj/machinery/compost_bin/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(O, /obj/item/storage/bag/plants))
		if(biomass >= biomass_capacity)
			to_chat(user, "<span class='warning'>[src] can't hold any more biomass!</span>")
			return

		var/obj/item/storage/bag/plants/PB = O
		for(var/obj/item/reagent_containers/food/snacks/grown/G in PB.contents)

			PB.remove_from_storage(G, src)
			make_biomass(G)

			if(biomass >= biomass_capacity)
				to_chat(user, "<span class='info'>You fill [src] to its capacity.</span>")
				break

		if(biomass < biomass_capacity)
			to_chat(user, "<span class='info'>You empty [PB] into [src].</span>")

		SStgui.update_uis(src)
		update_icon_state()
		return TRUE

	if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		if(biomass >= biomass_capacity)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return
		if(!user.unEquip(O))
			return

		O.forceMove(src)
		make_biomass(O)
		to_chat(user, "<span class='info'>You put [O] in [src].</span>")
		SStgui.update_uis(src)
		update_icon_state()
		return TRUE

	to_chat(user, "<span class='warning'>You cannot put this in [name]!</span>")

//Compost compostable material if there is any
/obj/machinery/compost_bin/process()
	if(compost >= compost_capacity || biomass <= 0)
		return
	process_counter++
	if(process_counter < 5)
		return
	process_counter = 0
	//converts 20% of the biomass to compost each cycle, unless there isn't enough compost space or there is 10 or less biomass
	var/conversion_amount = clamp(DECAY * biomass, min(MIN_CONVERSION, biomass), compost_capacity - compost)
	biomass -= conversion_amount
	compost += conversion_amount
	update_icon_state()
	SStgui.update_uis(src)

// Makes soil from compost
/obj/machinery/compost_bin/proc/create_soil(amount)
	// Verify theres enough compost
	if(compost < (SOIL_COST * amount))
		return
	new /obj/item/stack/sheet/soil(loc, amount)
	compost -= SOIL_COST * amount
	update_icon_state()
	SStgui.update_uis(src)

/obj/machinery/compost_bin/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/compost_bin/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CompostBin", "Compost Bin", 390, 200, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/compost_bin/ui_data(mob/user)
	var/list/data = list()
	data["biomass"] = biomass
	data["biomass_capacity"] = biomass_capacity
	data["compost"] = compost
	data["compost_capacity"] = compost_capacity
	return data

// calls functions according to ui interaction(just making compost for now)
/obj/machinery/compost_bin/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("create")
			var/amount = clamp(text2num(params["amount"]), 1, 10)
			create_soil(amount)

// sets compost bin sprite according to the amount of compost in it
/obj/machinery/compost_bin/update_icon_state()
	if(!compost)
		icon_state = "compost_bin-empty"
	else if(compost <= compost_capacity / 3)
		icon_state = "compost_bin-1"
	else if(compost <= 2 * (compost_capacity) / 3)
		icon_state = "compost_bin-2"
	else
		icon_state = "compost_bin-3"

#undef SOIL_COST
#undef DECAY
#undef MIN_CONVERSION
