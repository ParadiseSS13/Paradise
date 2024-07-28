// MARK: Miscellaneous
/obj/item/clothing/head/helmet/bike_helmet
	name = "байкерский шлем"
	desc = "Крутой шлем."
	icon = 'modular_ss220/clothing/icons/object/hats.dmi'
	icon_state = "bike_helmet"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	toggle_message = "Вы опустили защитное стекло"
	alt_toggle_message = "Вы подняли защитное стекло"
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	can_toggle = TRUE
	toggle_sound = 'sound/weapons/tap.ogg'
	dog_fashion = null
	sprite_sheets = list(
		"Abductor" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Ancient Skeleton" 	= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Diona" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Drask" 			= 	'modular_ss220/clothing/icons/mob/species/drask/helmet.dmi',
		"Golem" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Grey" 				= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Human" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Kidan" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Machine"			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Monkey" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Nian" 				= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Plasmaman" 		= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Shadow" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Skrell" 			= 	'modular_ss220/clothing/icons/mob/species/skrell/helmet.dmi',
		"Slime People" 		= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Tajaran" 			= 	'modular_ss220/clothing/icons/mob/species/tajaran/helmet.dmi',
		"Unathi" 			= 	'modular_ss220/clothing/icons/mob/species/unathi/helmet.dmi',
		"Vox" 				= 	'modular_ss220/clothing/icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" 		= 	'modular_ss220/clothing/icons/mob/species/vulpkanin/helmet.dmi',
		"Nucleation"		=	'modular_ss220/clothing/icons/mob/helmet.dmi',
		)

/obj/item/clothing/head/helmet/bike_helmet/replica
	desc = "Крутой шлем. На вид хлипкий..."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

// MARK: ERT
/obj/item/clothing/head/helmet/ert
	icon = 'modular_ss220/clothing/icons/object/helmet.dmi'
	icon_state = "ember_sec"
	item_state = "ember_sec"
	sprite_sheets = list(
		"Abductor" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Ancient Skeleton" 	= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Diona" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Drask" 			= 	'modular_ss220/clothing/icons/mob/species/drask/helmet.dmi',
		"Golem" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Grey" 				= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Human" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Kidan" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Machine"			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Monkey" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Nian" 				= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Plasmaman" 		= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Shadow" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Skrell" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Slime People" 		= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Tajaran" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Unathi" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Vox" 				= 	'modular_ss220/clothing/icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" 		= 	'modular_ss220/clothing/icons/mob/species/vulpkanin/helmet.dmi',
		"Lich" 				= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Nucleation"		=	'modular_ss220/clothing/icons/mob/helmet.dmi',
		)

/obj/item/clothing/head/helmet/ert/command
	icon_state = "ember_com"
	item_state = "ember_com"
	actions_types = list(/datum/action/item_action/toggle_nvg)
	/// Is night vision goggles enabled?
	var/nvg_enabled = FALSE

/datum/action/item_action/toggle_nvg
	name = "Toggle Nightvision"

/obj/item/clothing/head/helmet/ert/command/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/toggle_nvg)
		toggle_nvg(user)

/obj/item/clothing/head/helmet/ert/command/item_action_slot_check(slot)
	if(slot == SLOT_HUD_HEAD)
		return TRUE

/obj/item/clothing/head/helmet/ert/command/equipped(mob/user, slot, initial)
	. = ..()
	if(nvg_enabled && slot == SLOT_HUD_HEAD)
		ADD_TRAIT(user, TRAIT_NIGHT_VISION, "ert_commander_helmet[UID()]")

/obj/item/clothing/head/helmet/ert/command/dropped(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_NIGHT_VISION, "ert_commander_helmet[UID()]")

/obj/item/clothing/head/helmet/ert/command/update_icon_state()
	. = ..()
	if(nvg_enabled)
		icon_state = initial(icon_state) + "_nvg"
		item_state = initial(item_state) + "_nvg"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)

/obj/item/clothing/head/helmet/ert/command/proc/toggle_nvg(mob/user)
	var/msg
	if(!HAS_TRAIT_FROM(user, TRAIT_NIGHT_VISION, "ert_commander_helmet[UID()]"))
		ADD_TRAIT(user, TRAIT_NIGHT_VISION, "ert_commander_helmet[UID()]")
		msg = "You lowered your night-vision goggles over your eyes."
		nvg_enabled = TRUE
	else
		REMOVE_TRAIT(user, TRAIT_NIGHT_VISION, "ert_commander_helmet[UID()]")
		msg = "You raised your night-vision goggles."
		nvg_enabled = FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.head == src)
			H.update_sight()

	update_icon(UPDATE_ICON_STATE)
	user.update_inv_head()
	to_chat(user, span_notice("[msg]"))

/obj/item/clothing/head/helmet/ert/security
	icon_state = "ember_sec"
	item_state = "ember_sec"

/obj/item/clothing/head/helmet/space/ert_engineer
	name = "emergency response team engineer space helmet"
	desc = "Space helmet worn by engineering members of the Nanotrasen Emergency Response Team. Has orange highlights."
	icon = 'modular_ss220/clothing/icons/object/helmet.dmi'
	icon_state = "ember_eng"
	item_state = "ember_eng"
	sprite_sheets = list(
		"Abductor" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Ancient Skeleton" 	= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Diona" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Drask" 			= 	'modular_ss220/clothing/icons/mob/species/drask/helmet.dmi',
		"Golem" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Grey" 				= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Human" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Kidan" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Machine"			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Monkey" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Nian" 				= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Plasmaman" 		= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Shadow" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Skrell" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Slime People" 		= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Tajaran" 			= 	'modular_ss220/clothing/icons/mob/species/tajaran/helmet.dmi',
		"Unathi" 			= 	'modular_ss220/clothing/icons/mob/helmet.dmi',
		"Vox" 				= 	'modular_ss220/clothing/icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" 		= 	'modular_ss220/clothing/icons/mob/species/vulpkanin/helmet.dmi',
		"Nucleation"		=	'modular_ss220/clothing/icons/mob/helmet.dmi',
		)
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 10, RAD = 50, FIRE = 200, ACID = 115)

/obj/item/clothing/head/helmet/ert/medical
	icon_state = "ember_med"
	item_state = "ember_med"

/obj/item/clothing/head/helmet/ert/janitor
	icon_state = "ember_jan"
	item_state = "ember_jan"
