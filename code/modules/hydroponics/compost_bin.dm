#define SOIL_COST 25
#define DECAY 0.2
#define MIN_CONVERSION 10
#define BIOMASS_AMMONIA_RATIO 3
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
	/// amount of ammonia in the compost bin
	var/ammonia = 0
	/// amount of saltpetre in the conpost bin
	var/saltpetre = 0
	/// The maximum amount of biomass the compost bin can store.
	var/biomass_capacity = 1500
	/// The maximum amount of compost the compost bin can store.
	var/compost_capacity = 1500
	/// The maximum amount of ammonia the compost bin can store.
	var/ammonia_capacity = 400

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
/obj/machinery/compost_bin/proc/make_biomass(obj/item/food/snacks/grown/O)
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
		for(var/obj/item/food/snacks/grown/G in PB.contents)

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

	if(istype(O, /obj/item/food/snacks/grown))
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
	if(istype(O, /obj/item/reagent_containers))
		var/proportion = 0
		var/obj/item/reagent_containers/B = O
		if(B.reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>[B] is empty!</span>")
			return
		if(ammonia >= ammonia_capacity)
			to_chat(user, "<span class='warning'>The contents of [src] are saturated with ammonia!</span>")
			return
		// Won't pour in more than the amount of ammonia that can be accepted, even if the beaker is not filled with pure ammonia.
		proportion = min(min(B.reagents.total_volume, B.amount_per_transfer_from_this),ammonia_capacity - ammonia) / B.reagents.total_volume

		// Since the character doesn't know what's in the beaker, I'm assuming it is assuming the beaker is full of pure ammonia and pours according to that.
		for(var/E in B.reagents.reagent_list)
			var/datum/reagent/R = E
			if(R.id == "ammonia")
				ammonia += min(R.volume * proportion, ammonia_capacity - ammonia)
			B.reagents.remove_reagent(R.id, R.volume*proportion)
		if(proportion == 1)
			to_chat(user, "<span class='info'>You empty [B] into [src].</span>")
		else
			to_chat(user, "<span class='info'>You pour some of [B] into [src].</span>")
		if(ammonia == ammonia_capacity)
			to_chat(user, "<span class='info'>You have saturated the contents of [src] with ammonia.</span>")
		else if(ammonia >= ammonia_capacity * 0.95)
			to_chat(user, "<span class='info'>You have very nearly saturated the contents of [src] with ammonia.</span>")

		SStgui.update_uis(src)
		update_icon_state()

		return TRUE

	to_chat(user, "<span class='warning'>You cannot put this in [src]!</span>")

//Compost compostable material if there is any
/obj/machinery/compost_bin/process()
	if((compost >= compost_capacity && ammonia <= 0) || biomass <= 0)
		return
	process_counter++
	if(process_counter < 5)
		return
	process_counter = 0
	//Converts up to 20% of the biomass to compost each cycle, minimum of 10 converted.
	//In the presence of ammonia will create saltpetre crystals instead. Using at most the amount of biomass that would've been used for compost
	//And making compost from whatever part of that amount it didn't use.
	var/conversion_amount = max(DECAY * biomass, min(MIN_CONVERSION, biomass))
	var/saltpetre_conversion_amont = 0
	var/used_ammonia = 0

	if(ammonia >= 0)
		saltpetre_conversion_amont = min(conversion_amount, ammonia * BIOMASS_AMMONIA_RATIO)
		used_ammonia = saltpetre_conversion_amont / BIOMASS_AMMONIA_RATIO
		saltpetre += used_ammonia
		if(saltpetre/4 >= 1)
			new /obj/item/stack/sheet/saltpetre_crystal(loc, round(saltpetre/4))
		saltpetre -= round(saltpetre)
		conversion_amount -= saltpetre_conversion_amont
		ammonia -= used_ammonia

	conversion_amount = min(conversion_amount, compost_capacity - compost)

	biomass -= conversion_amount + saltpetre_conversion_amont
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
	data["ammonia"] = ammonia
	data["ammonia_capacity"] = ammonia_capacity
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
#undef BIOMASS_AMMONIA_RATIO
