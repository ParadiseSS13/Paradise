/*
Science Analyzer

It is used to investigate hand-held objects and destroy them for research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/science_analyzer
	name = "Destructive Analyzer"
	desc = "Learn science by analyzing things!"
	icon_state = "d_analyzer"
	/// Typecache of items that can unlock illegal research
	var/list/illegal_item_typecache = list()
	/// Typecache of items that can unlock alien research
	var/list/alien_item_typecache = list()


/obj/machinery/r_n_d/science_analyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/science_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()


/obj/machinery/r_n_d/science_analyzer/Destroy()
	if(linked_console)
		linked_console.linked_analyzer = null

	return ..()


/obj/machinery/r_n_d/science_analyzer/attackby(obj/item/O as obj, mob/user as mob, params)
	if(default_deconstruction_screwdriver(user, "d_analyzer_t", "d_analyzer", O))
		if(linked_console)
			linked_console.linked_analyzer = null
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
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] is stuck to your hand, you cannot put it in [src]!</span>")
			return
		busy = TRUE
		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>You add [O] to [src]!</span>")
		flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, PROC_REF(unbusy)), 1 SECONDS)


/obj/machinery/r_n_d/science_analyzer/proc/unbusy()
	icon_state = "d_analyzer_l"
	busy = FALSE
