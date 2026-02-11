/obj/machinery/science_satellite
	name = "satellite chassis"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wooden_tv"
	var/list/parts
	desc = "A satellite chassis constructected from plassteel."
	anchored = FALSE
	density = 1

/obj/machinery/science_satellite/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, SPAN_DEBUG("screwdriver act. Panel: [panel_open]"))

/obj/machinery/science_satellite/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, SPAN_DEBUG("multitool act. Panel: [panel_open]"))
