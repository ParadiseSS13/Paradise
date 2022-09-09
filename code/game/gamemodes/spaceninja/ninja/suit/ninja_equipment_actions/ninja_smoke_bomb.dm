/datum/action/item_action/ninja_smoke_bomb
	check_flags = AB_CHECK_CONSCIOUS
	name = "Integrated smoke bomb"
	desc = "Generates a big cloud of smoke to hide yourself from enemies. Use with your mask's thermal mode for the killer combination. Energy cost: 1000"
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "smoke"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Integrated Smoke Generator"

/obj/item/clothing/suit/space/space_ninja/proc/prime_smoke()
	if(!ninjacost(100))
		playsound(src.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		smoke_system.start()
		s_coold = 3 SECONDS
