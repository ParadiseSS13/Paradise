/mob/living/silicon/pai/death(gibbed, cleanWipe)
	if(can_die())
		if(!cleanWipe)
			force_fold_out()

		visible_message(SPAN_WARNING("[src] emits a dull beep before it loses power and collapses."), SPAN_WARNING("You hear a dull beep followed by the sound of glass crunching."))
		name = "pAI debris"
		desc = "The unfortunate remains of some poor personal AI device."
		icon_state = "[chassis]_dead"

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	diag_hud_set_status()
	diag_hud_set_health()

	if(icon_state != "[chassis]_dead" || cleanWipe)
		qdel(src)
