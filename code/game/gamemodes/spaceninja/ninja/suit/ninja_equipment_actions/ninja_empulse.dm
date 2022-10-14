//Disables nearby tech equipment.

/datum/action/item_action/ninjapulse
	check_flags = AB_CHECK_CONSCIOUS
	name = "EM Burst"
	desc = "Disable any nearby technology with an electro-magnetic pulse. Energy cost: 5000"
	use_itemicon = FALSE
	button_icon_state = "emp"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Concentrated Electro-Magnetic Pulse Emitter"

/**
 * Proc called to allow the ninja to EMP the nearby area.  By default, costs 500E, which is half of the default battery's max charge.
 * Also affects the ninja as well.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjapulse()
	if(ninjacost(500,N_STEALTH_CANCEL))
		return
	var/mob/living/carbon/human/H = affecting
	playsound(H.loc, 'sound/effects/empulse.ogg', 60, TRUE)
	empulse(H, 4, 6, TRUE, "Ninja EM Burst") //Procs sure are nice. Slightly weaker than wizard's disable tch.
	s_coold = 4 SECONDS
