/mob/living/silicon/pai/death(gibbed, cleanWipe)
	if(can_die())
		if(!cleanWipe)
			force_fold_out()

		visible_message("<span class=warning>[src] emits a dull beep before it loses power and collapses.</span>", "<span class=warning>You hear a dull beep followed by the sound of glass crunching.</span>")
		name = "pAI debris"
		desc = "The unfortunate remains of some poor personal AI device."
		icon_state = "[chassis]_dead"

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(icon_state != "[chassis]_dead" || cleanWipe)
		qdel(src)
