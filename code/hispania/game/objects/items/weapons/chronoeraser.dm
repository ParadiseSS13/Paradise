/obj/item/chrono_eraser/bow
	name = "TED Bow"
	desc = "This variant of the TED works by firing an arrow from an energy bow that eliminates targets from the timeline with deadly accuracy. Never Existed."
	icon = 'icons/hispania/obj/chronos.dmi'
	icon_state = "pchronobackpack"
	item_state = "pchronobackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)

/obj/item/chrono_eraser/needle
	hispania_icon = TRUE
	name = "TED Needle"
	desc = "This variant of the classical TED fires projectiles from a long needle-like gun for precission strikes againts timeline criminals."
	icon = 'icons/hispania/obj/chronos.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)

/obj/item/chrono_eraser/chronored
	hispania_icon = TRUE
	name = "TED mk. II"
	desc = "A more powerful version of the standard TED. This one comes painted in red, which means danger. Or meant. Or will mean. Or will have meant. Time travel messes up grammar..."
	icon = 'icons/hispania/obj/chronos.dmi'
	icon_state = "normalbackpack"
	item_state = "normalbackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)

/obj/item/chrono_eraser/shotgun
	hispania_icon = TRUE
	name = "TED Launcher"
	desc = "This TED has a more classical approach to design, by dispensing time-ripper grenades at the user's target. It won't just erase time-travel crimnals from the timeline, they will also loose a toof."
	icon = 'icons/hispania/obj/chronos.dmi'
	icon_state = "preybackpack"
	item_state = "preybackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)

/obj/item/chrono_eraser/staff
	hispania_icon = TRUE
	name = "TED Staff"
	desc = "This variant of the TED deploys a long staff that can be used to fire time-rip projectiles. It's not magic, it's just science."
	icon = 'icons/hispania/obj/chronos.dmi'
	icon_state = "normalbackpack"
	item_state = "normalbackpack"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/equip_unequip_TED_Gun)

////CHRONO GUNS BELOW ////
/obj/item/gun/energy/chrono_gun/bow
	name = "T.E.D. Projection Apparatus"
	desc = "It's as if they never existed in the first place."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL
	flags = NODROP | DROPDEL
	ammo_type = list(/obj/item/ammo_casing/energy/chrono_beam)
	can_charge = 0
	fire_delay = 50
