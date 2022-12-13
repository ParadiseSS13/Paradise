#define NINJA_NIGHTVISION 		"nightvision"
#define NINJA_THERMALS			"thermals"
#define NINJA_FLASHPROTECTION	"flashprotection"

/datum/action/item_action/ninja_glasses_toggle
	name = "Toggle Visor Mode"
	desc = "Toggles Visor mode to the next one. Available modes: Thermals, Blind protection, Night vision"
	use_itemicon = TRUE
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"

/obj/item/clothing/glasses/ninja/proc/toggle_modes(mob/user, var/mode = null)
	current_mode = mode ? mode : next_mode()
	switch(current_mode)
		if(NINJA_NIGHTVISION)
			see_in_dark = 8
			lighting_alpha = 160
			flash_protect = -1
			vision_flags &= ~SEE_MOBS
			icon_state = "[initial(icon_state)]"
			item_state = "[initial(item_state)]"
			to_chat(user, span_notice("Night Vision mode Active"))
		if(NINJA_THERMALS)
			see_in_dark = 2
			lighting_alpha = 220
			flash_protect = -1
			vision_flags |= SEE_MOBS
			icon_state = "[initial(icon_state)]_red"
			item_state = "[initial(item_state)]_red"
			to_chat(user, span_notice("Thermal Vision mode Active"))
		if(NINJA_FLASHPROTECTION)
			see_in_dark = 2
			lighting_alpha = null
			flash_protect = 1
			vision_flags &= ~SEE_MOBS
			icon_state = "[initial(icon_state)]_blue"
			item_state = "[initial(item_state)]_blue"
			to_chat(user, span_notice("Blindness Protection mode Active"))

	if(n_mask && istype(user.wear_mask, /obj/item/clothing/mask/gas/space_ninja))
		n_mask.icon_state = "ninja_mask_[n_mask.visuals_type]_[current_mode]"
		n_mask.item_state = "ninja_mask_[n_mask.visuals_type]_[current_mode]"
	user.update_sight()
	user.update_action_buttons_icon()
	user.update_inv_glasses()
	user.update_inv_wear_mask()

/obj/item/clothing/glasses/ninja/proc/next_mode()
	switch(current_mode)
		if(NINJA_NIGHTVISION)
			return NINJA_THERMALS
		if(NINJA_THERMALS)
			return NINJA_FLASHPROTECTION
		if(NINJA_FLASHPROTECTION)
			return NINJA_NIGHTVISION

#undef NINJA_NIGHTVISION
#undef NINJA_THERMALS
#undef NINJA_FLASHPROTECTION
