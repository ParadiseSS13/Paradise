/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/Destroy()
	if(linked_console)
		linked_console.linked_destroy = null
	return ..()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/storage/part_replacer))
		return ..()

	if(default_deconstruction_screwdriver(user, "d_analyzer_t", "d_analyzer", O))
		if(linked_console)
			linked_console.linked_destroy = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(!linked_console)
		to_chat(user, "<span class='warning'>[src] must be linked to an R&D console first!</span>")
		return

	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")
		return

	if(isitem(O) && !loaded_item)
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return

		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if(length(temp_tech) == 0)
			to_chat(user, "<span class='warning'>You cannot deconstruct this item!</span>")
			return

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] is stuck to your hand, you cannot put it in [src]!</span>")
			return

		busy = TRUE
		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>You add [O] to [src]!</span>")
		SStgui.update_uis(linked_console)
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = FALSE
