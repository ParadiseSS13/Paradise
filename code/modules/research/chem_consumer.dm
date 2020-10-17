// 100 research points for 1 unit of the output chem. Seems balanced considering each node is 2500 points
// An entire beaker of something can speed unlock 4 entire nodes
#define RESEARCHPOINTS_PER_UNIT 100

/obj/machinery/research_chem_consumer
	name = "research chemical consumer"
	desc = "Consumes chemicals to gain research points"
	icon_state = "chemical_idle"
	icon = 'icons/obj/machines/research_consumers.dmi'
	anchored = TRUE
	density = TRUE
	var/obj/item/reagent_containers/beaker

/obj/machinery/research_chem_consumer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/research_chem_consumer(null)

/obj/machinery/research_chem_consumer/update_icon()
	if(panel_open)
		icon_state = "chemical_open"
	else if(stat & NOPOWER)
		icon_state = "chemical_powerless"
	else if(istype(beaker))
		icon_state = "chemical_on"
	else
		icon_state = "chemical_idle"

/obj/machinery/research_chem_consumer/power_change()
	..()
	update_icon()

/obj/machinery/research_chem_consumer/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	update_icon()

/obj/machinery/research_chem_consumer/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/research_chem_consumer/attackby(obj/item/I, mob/user, params)
	if(isrobot(user))
		return

	if(beaker)
		to_chat(user, "<span class='warning'>Something is already loaded into the machine.</span>")
		return

	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks))
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
			return
		beaker =  I
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		SStgui.update_uis(src) // update all UIs attached to src
		update_icon()
		return

	return ..()

/obj/machinery/research_chem_consumer/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/research_chem_consumer/proc/eject_beaker()
	if(beaker)
		beaker.forceMove(get_turf(src))
		if(Adjacent(usr) && !issilicon(usr))
			usr.put_in_hands(beaker)
		beaker = null
		update_icon()

/obj/machinery/research_chem_consumer/deconstruct()
	if(beaker)
		beaker.forceMove(get_turf(src))
		beaker = null
	return ..()

/obj/machinery/research_chem_consumer/AltClick(mob/user)
	if(!ishuman(usr))
		return
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	eject_beaker()

/obj/machinery/research_chem_consumer/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ResearchChemConsumer", name, 600, 300, master_ui, state)
		ui.open()

/obj/machinery/research_chem_consumer/tgui_data(mob/user)
	var/list/data = list()
	data["beaker_loaded"] = istype(beaker) ? TRUE : FALSE
	data["target_reagent"] = GLOB.chemical_reagents_list[SSresearch.complex_research_chem_id]
	data["points_per_unit"] = RESEARCHPOINTS_PER_UNIT

	var/list/beaker_contents = list()
	// How much of the required reagent is loaded
	var/required_amount = 0
	if(length(beaker?.reagents?.reagent_list))
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_contents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			if(R.id == SSresearch.complex_research_chem_id)
				required_amount += R.volume
	data["beaker_contents"] = beaker_contents
	data["required_amount"] = required_amount
	return data

/obj/machinery/research_chem_consumer/tgui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("eject_beaker")
			eject_beaker()
		if("consume")
			var/reagent_amount = beaker.reagents.get_reagent_amount(SSresearch.complex_research_chem_id)
			if(!(reagent_amount > 0))
				return
			beaker.reagents.remove_reagent(SSresearch.complex_research_chem_id, reagent_amount)
			SSresearch.science_tech.research_points += (reagent_amount * RESEARCHPOINTS_PER_UNIT)


#undef RESEARCHPOINTS_PER_UNIT
