/obj/machinery/door/firedoor/crush() // Detalle importante para que las firedoor de bordes no aplasten a la gente.
	if(can_crush)
		. = ..()
