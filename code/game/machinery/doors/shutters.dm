/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that open mechanically."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	dir = EAST

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/radiation
	name = "radiation shutters"
	desc = "Lead-lined shutters with a radiation hazard symbol. Whilst this won't stop you getting irradiated, especially by a supermatter crystal, it will stop radiation travelling as far."
	icon = 'icons/obj/doors/shutters_radiation.dmi'
	rad_insulation_beta = RAD_BETA_BLOCKER
	rad_insulation_gamma = RAD_VERY_EXTREME_INSULATION

/obj/machinery/door/poddoor/shutters/radiation/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE
	rad_insulation_beta = RAD_NO_INSULATION
	rad_insulation_gamma = RAD_NO_INSULATION

/obj/machinery/door/poddoor/shutters/radiation/open()
	. = ..()
	rad_insulation_beta = RAD_NO_INSULATION
	rad_insulation_gamma = RAD_NO_INSULATION

/obj/machinery/door/poddoor/shutters/radiation/close()
	. = ..()
	rad_insulation_beta = RAD_BETA_BLOCKER
	rad_insulation_gamma = RAD_VERY_EXTREME_INSULATION
