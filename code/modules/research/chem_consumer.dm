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
	if(stat & NOPOWER)
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
		to_chat(user, "<span class='notice'>You set [I] on the machine.</span>")
		SStgui.update_uis(src) // update all UIs attached to src
		update_icon()
		return

	return ..()

/obj/machinery/research_chem_consumer/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/research_chem_consumer/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ResearchChemConsumer", name, 400, 300, master_ui, state)
		ui.open()

/obj/machinery/research_chem_consumer/tgui_data(mob/user)
	var/list/data = list()
	data["beaker_loaded"] = istype(beaker) ? TRUE : FALSE
	data["target_reagent"] = GLOB.chemical_reagents_list[SSresearch.complex_research_chem_id]
	return data
