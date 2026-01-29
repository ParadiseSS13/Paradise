// DRONE ABILITIES

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
		H.worn_icon = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.icon_state = icon_state
	else if(emagged)
		H.icon_state = "drone-emagged"
	else
		H.icon_state = "drone"

	return H
