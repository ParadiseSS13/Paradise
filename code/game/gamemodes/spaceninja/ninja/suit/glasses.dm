#define NINJA_NIGHTVISION 		"nightvision"
#define NINJA_THERMALS			"thermals"
#define NINJA_FLASHPROTECTION	"flashprotection"

/obj/item/clothing/glasses/ninja
	name = "ninja visor"
	desc = "A specialized visor capable of working in 3 separated modes. Thermals/Flash protection/Night vision. Specifically for Spider Clan assassins!"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "night"
	item_state = "night"
	//Абилка
	actions_types = list(/datum/action/item_action/ninja_glasses_toggle)
	//Флаги
	flash_protect = -1
	vision_flags = 0
	see_in_dark = 8 //Base human is 2
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/current_mode = NINJA_NIGHTVISION
	///The space ninja's mask.
	var/obj/item/clothing/mask/gas/space_ninja/n_mask
	/// Флаг дающий защиту от некоторых способностей вампира пока на нас костюм
	var/vamp_protection_active = FALSE

/obj/item/clothing/glasses/ninja/Destroy()
	n_mask = null
	return ..()

/obj/item/clothing/glasses/ninja/ui_action_click(mob/user, action)
	if(action == /datum/action/item_action/ninja_glasses_toggle)
		toggle_modes(user)
		return TRUE
	return FALSE

#undef NINJA_NIGHTVISION
#undef NINJA_THERMALS
#undef NINJA_FLASHPROTECTION
