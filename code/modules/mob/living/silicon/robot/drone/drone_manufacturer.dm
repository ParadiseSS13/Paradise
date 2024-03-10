// This currently does nothing except being there to delete drones
/obj/machinery/drone_fabricator
	name = "drone fabricator"
	desc = "A large automated factory for producing maintenance drones."
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"

	density = TRUE
	anchored = TRUE

/obj/machinery/drone_fabricator/update_icon_state()
	. = ..()
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/drone_fabricator/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)
