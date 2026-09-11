/// Action given to antag clowns.
/datum/action/innate/toggle_clumsy
	name = "Toggle Clown Clumsy"
	button_icon_state = "clown"

/datum/action/innate/toggle_clumsy/Activate()
	var/mob/living/carbon/human/H = owner
	H.dna.SetSEState(GLOB.clumsyblock, TRUE)
	singlemutcheck(H, GLOB.clumsyblock, MUTCHK_FORCED)
	active = TRUE
	background_icon_state = "bg_spell"
	build_all_button_icons()
	to_chat(H, SPAN_NOTICE("You start acting clumsy to throw suspicions off. Focus again before using weapons."))

/datum/action/innate/toggle_clumsy/Deactivate()
	var/mob/living/carbon/human/H = owner
	H.dna.SetSEState(GLOB.clumsyblock, FALSE)
	singlemutcheck(H, GLOB.clumsyblock, MUTCHK_FORCED)
	active = FALSE
	background_icon_state = "bg_default"
	build_all_button_icons()
	to_chat(H, SPAN_NOTICE("You focus and can now use weapons regularly."))

