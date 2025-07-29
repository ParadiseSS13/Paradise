/obj/item/gun/energy/gun/advtaser/mounted
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "taser"
	inhand_icon_state = "armcannonstun4"
	selfcharge = TRUE
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses neural signals instead

/obj/item/gun/energy/laser/mounted
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers."
	icon = 'icons/obj/items_cyborg.dmi'
	inhand_icon_state = "armcannonlase"
	selfcharge = TRUE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
