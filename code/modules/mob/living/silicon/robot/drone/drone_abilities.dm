// DRONE ABILITIES
/datum/action/innate/drone_hide
	name = "Hide"
	desc = "Allows to hide beneath tables or certain items. Toggled on or off. While hiding you can fit under unbolted airlocks."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "repairbot"

/datum/action/innate/drone_hide/Activate()
	if(owner.layer != TURF_LAYER + 0.2)
		owner.layer = TURF_LAYER + 0.2
		to_chat(owner, "<span class='notice'>You are now hiding.</span>")
		owner.pass_flags |= PASSDOOR
		return

	owner.layer = MOB_LAYER
	to_chat(owner, "<span class='notice'>You have stopped hiding.</span>")
	owner.pass_flags &= ~PASSDOOR

//Actual picking-up event.
/mob/living/silicon/robot/drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	else
		..()

/mob/living/silicon/robot/drone/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(IS_HORIZONTAL(src))
		stand_up()
	if(custom_sprite)
		H.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		H.icon_override = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.icon_state = "[icon_state]"
		H.item_state = "[icon_state]_hand"
	else if(emagged)
		H.icon_state = "drone-emagged"
		H.item_state = "drone-emagged"
	else
		H.icon_state = "drone"
		H.item_state = "drone"
	grabber.put_in_active_hand(H)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H
