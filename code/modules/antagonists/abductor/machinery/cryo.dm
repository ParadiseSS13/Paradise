/obj/machinery/atmospherics/unary/cryo_cell/abductor
	name = "Regenerative Tank"
	desc = "A large tube full of unidentifiable chemicals."
	//icon = 'icons/obj/abductor.dmi'
	//icon_state = "cryo"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags = NODECONSTRUCT
	need_pipe_network = FALSE
	exit_direction = WEST
	light_color = LIGHT_COLOR_BLUE
	transfer_delay = 2

/obj/machinery/atmospherics/unary/cryo_cell/abductor/New()
	..()
	air_contents.temperature = T20C
	air_contents.oxygen = (25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

/obj/machinery/atmospherics/unary/cryo_cell/abductor/process_occupant()
    if(next_trans == 0 && on)
        occupant.reagents.add_reagent("nanites", 1) //Renamed adminorazine, heals everything
    ..()
