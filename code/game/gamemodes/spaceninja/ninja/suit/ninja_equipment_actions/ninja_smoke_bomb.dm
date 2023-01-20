/datum/action/item_action/advanced/ninja/ninja_smoke_bomb
	name = "Integrated smoke bomb"
	desc = "Generates a big cloud of smoke to hide yourself from enemies. Use with your mask's thermal mode for the killer combination. Energy cost: 1000"
	check_flags = AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_RECHARGE
	charge_max = 3 SECONDS
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "smoke"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Integrated Smoke Generator"

/datum/action/item_action/advanced/ninja/ninja_smoke_bomb_toggle_auto
	name = "Toggle smoke auto use"
	desc = "Toggles if your other modules will try to use smoke automatically. Auto-use energy cost: 250"
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_TOGGLE
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "smoke_auto"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = null

/obj/item/clothing/suit/space/space_ninja/proc/prime_smoke(lowcost = FALSE)
	var/datum/action/item_action/advanced/ninja/ninja_smoke_bomb/ninja_action = locate() in actions
	if(!ninja_action.IsAvailable(show_message = FALSE))
		return
	var/cost = lowcost ? 250 : 1000
	if(!ninjacost(cost))
		playsound(src.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		var/smoke_amount = lowcost ? 5 : 20
		smoke_system.set_up(smoke_amount, 0, src)
		smoke_system.start()
		ninja_action.use_action()

/obj/item/clothing/suit/space/space_ninja/proc/toggle_smoke()
	for(var/datum/action/item_action/advanced/ninja/ninja_smoke_bomb_toggle_auto/ninja_action in actions)
		ninja_action.use_action()
		auto_smoke = !auto_smoke
		break
