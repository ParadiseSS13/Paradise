//Disables nearby tech equipment.

/datum/action/item_action/advanced/ninja/ninjapulse

	name = "EM Burst"
	desc = "Disable any nearby technology with an electro-magnetic pulse. Energy cost: 5000"
	check_flags = AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_RECHARGE
	charge_max = 4 SECONDS
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
	if(ninjacost(5000,N_STEALTH_CANCEL))
		return
	var/mob/living/carbon/human/H = affecting
	playsound(H.loc, 'sound/effects/empulse.ogg', 60, TRUE)
	empulse(H, 4, 6, TRUE, "Ninja EM Burst") //Procs sure are nice. Slightly weaker than wizard's disable tch.
	if(auto_smoke)
		if(locate(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb) in actions)
			prime_smoke(lowcost = TRUE)
	for(var/datum/action/item_action/advanced/ninja/ninjapulse/ninja_action in actions)
		ninja_action.use_action()
		break
