#define SOIL_COST 25
#define DECAY 0.2
#define MIN_CONVERSION 10
#define BIOMASS_POTASH_RATIO 6
#define BIOMASS_POTASSIUM_RATIO 8
#define POTASH_SALPETRE_MULT 2

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
	/// amount of potassium in the compost bin
	var/potassium = 0
	/// amount of potash in the compost bin
	var/potash = 0
	/// amount of saltpetre in the compost bin
	var/saltpetre = 0
	/// The maximum amount of biomass the compost bin can store.
	var/biomass_capacity = 1500
	/// The maximum amount of compost the compost bin can store.
	var/compost_capacity = 1500
	/// The maximum amount of potassium the compost bin can store.
	var/potassium_capacity = 200
	/// The maximum amount of potash the compost bin can store.
	var/potash_capacity = 500

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

// Accepts inserted plants and converts them to biomass and potassium
/obj/machinery/compost_bin/proc/make_biomass(obj/item/food/grown/O)
	// calculate biomass from plant nutriment and plant matter
	var/plant_biomass = O.reagents.get_reagent_amount("nutriment") + O.reagents.get_reagent_amount("plantmatter")
	var/plant_potassium = O.reagents.get_reagent_amount("potassium")
	var/plant_potash = O.reagents.get_reagent_amount("ash")
	biomass += min(max(plant_biomass * 10, 1), biomass_capacity - biomass)
	potassium += min(potassium_capacity - potassium, plant_potassium)
	potash += min(potash_capacity - potash, plant_potash)
	//plant delenda est
	qdel(O)

// takes care of plant insertion and conversion to biomass, and start composting what was inserted
/obj/machinery/compost_bin/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	// TODO: This feels off, no where else do we have a blanket "print a
	// message for any other kind of item interaction attempt" that's keyed to intent
	// See if this can be made more sensible after everything's been migrated
	// to the new attack chain
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(used, /obj/item/storage/bag/plants))
		if(biomass >= biomass_capacity && potassium >= potassium_capacity)
			to_chat(user, "<span class='warning'>[src] can't hold any more biomass, and it's contents are saturated with potassium!</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/storage/bag/plants/PB = used
		for(var/obj/item/food/grown/G in PB.contents)
			// if the plant contains either potassium, plantmatter and nutriment and the compost bin has space for any of those.
			if((G.reagents.get_reagent_amount("potassium") && potassium <= potassium_capacity) || ((G.reagents.get_reagent_amount("plantmatter") || G.reagents.get_reagent_amount("nutriment")) && biomass <= biomass_capacity))
				PB.remove_from_storage(G, src)
				make_biomass(G)

			if(biomass >= biomass_capacity && potassium >= potassium_capacity)
				break

		if(biomass >= biomass_capacity)
			to_chat(user, "<span class='notice'>You fill [src] to its capacity.</span>")
		else
			to_chat(user, "<span class='notice'>You empty [PB] into [src].</span>")

		if(potassium == potassium_capacity)
			to_chat(user, "<span class='notice'>You have saturated the contents of [src] with potassium.</span>")
		else if(potassium >= potassium_capacity * 0.95)
			to_chat(user, "<span class='notice'>You have very nearly saturated the contents of [src] with potassium.</span>")

		SStgui.update_uis(src)
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/food/grown))
		if(biomass >= biomass_capacity && potassium >= potassium_capacity)
			to_chat(user, "<span class='warning'>[src] can't hold any more biomass, and its contents are saturated with potassium!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.transfer_item_to(used, src))
			return ITEM_INTERACT_COMPLETE

		make_biomass(used)
		to_chat(user, "<span class='notice'>You put [used] in [src].</span>")
		SStgui.update_uis(src)
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/reagent_containers))
		var/proportion = 0
		var/obj/item/reagent_containers/B = used
		if(B.reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>[B] is empty!</span>")
			return ITEM_INTERACT_COMPLETE
		if(potassium >= potassium_capacity && potash >= potash_capacity)
			to_chat(user, "<span class='warning'>The contents of [src] are saturated with potassium and it cannot hold more potash!</span>")
			return ITEM_INTERACT_COMPLETE
		// Won't pour in more than the amount of potassium that can be accepted, even if the beaker is not filled with pure potassium.
		proportion = min(min(B.reagents.total_volume, B.amount_per_transfer_from_this), potassium_capacity - potassium) / B.reagents.total_volume

		// Since the character may not know what's in the beaker, I'm assuming it is assuming the beaker is full of pure potassium and pours according to that.
		for(var/E in B.reagents.reagent_list)
			var/datum/reagent/R = E
			switch(R.id)
				if("potassium")
					potassium += min(R.volume * proportion, potassium_capacity - potassium)
				if("ash")
					potash += min(R.volume * proportion, potash_capacity - potash)
				if("nutriment")
					biomass += min(R.volume * proportion, biomass_capacity - biomass)
				if("plantmatter")
					biomass += min(R.volume * proportion, biomass_capacity - biomass)

			B.reagents.remove_reagent(R.id, R.volume * proportion)

		if(proportion == 1)
			to_chat(user, "<span class='notice'>You empty [B] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>You pour some of [B] into [src].</span>")
		if(potassium == potassium_capacity)
			to_chat(user, "<span class='notice'>You have saturated the contents of [src] with potassium.</span>")
		else if(potassium >= potassium_capacity * 0.95)
			to_chat(user, "<span class='notice'>You have very nearly saturated the contents of [src] with potassium.</span>")

		if(potash == potash_capacity)
			to_chat(user, "<span class='notice'>[src] has been filled with potash.</span>")
		else if(potash >= potash_capacity * 0.95)
			to_chat(user, "<span class='notice'>[src] has been nearly filled with potash.</span>")

		SStgui.update_uis(src)
		update_icon(UPDATE_ICON_STATE)

		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='warning'>You cannot put this in [src]!</span>")
	return ITEM_INTERACT_COMPLETE

//Compost compostable material if there is any
/obj/machinery/compost_bin/process()
	if((compost >= compost_capacity && potassium <= 0) || biomass <= 0)
		return
	process_counter++
	if(process_counter < 5)
		return
	process_counter = 0
	//Converts up to 20% of the biomass to compost each cycle, minimum of 10 converted.
	//In the presence of potassium will create saltpetre crystals instead. Using at most the amount of biomass that would've been used for compost
	//And making compost from whatever part of that amount it didn't use.
	var/conversion_amount = max(DECAY * biomass, min(MIN_CONVERSION, biomass))
	var/potash_saltpetre_conversion = 0
	var/potassium_saltpetre_conversion = 0
	var/used_potassium = 0
	var/used_potash = 0

	if(potash > 0)
		potash_saltpetre_conversion = min(conversion_amount, potash * BIOMASS_POTASH_RATIO)
		used_potash = potash_saltpetre_conversion / BIOMASS_POTASH_RATIO
		saltpetre += used_potash * POTASH_SALPETRE_MULT
		conversion_amount -= potash_saltpetre_conversion
		potash -= used_potash

	if(potassium > 0)
		potassium_saltpetre_conversion = min(conversion_amount, potassium * BIOMASS_POTASSIUM_RATIO)
		used_potassium = potassium_saltpetre_conversion / BIOMASS_POTASSIUM_RATIO
		saltpetre += used_potassium
		conversion_amount -= potassium_saltpetre_conversion
		potassium -= used_potassium

	if(saltpetre / 4 >= 1)
		new /obj/item/stack/sheet/saltpetre_crystal(loc, round(saltpetre / 4))
		saltpetre -= round(saltpetre)

	conversion_amount = min(conversion_amount, compost_capacity - compost)

	biomass -= conversion_amount + potash_saltpetre_conversion + potassium_saltpetre_conversion
	compost += conversion_amount
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

// Makes soil from compost
/obj/machinery/compost_bin/proc/create_soil(amount)
	// Verify theres enough compost
	if(compost < (SOIL_COST * amount))
		return
	new /obj/item/stack/sheet/soil(loc, amount)
	compost -= SOIL_COST * amount
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)

/obj/machinery/compost_bin/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/compost_bin/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/compost_bin/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CompostBin", "Compost Bin")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/compost_bin/ui_data(mob/user)
	var/list/data = list()
	data["biomass"] = biomass
	data["biomass_capacity"] = biomass_capacity
	data["compost"] = compost
	data["compost_capacity"] = compost_capacity
	data["potassium"] = potassium
	data["potassium_capacity"] = potassium_capacity
	data["potash"] = potash
	data["potash_capacity"] = potash_capacity
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
#undef BIOMASS_POTASH_RATIO
#undef BIOMASS_POTASSIUM_RATIO
#undef POTASH_SALPETRE_MULT
