/obj/item/sellable/salvage
	name = "Salvage"
	desc = "A tonne of salvage looted from bad mapping practices. Who spawned the base type? Report this on the github."
	force = 5
	throwforce = 15
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	throw_speed = 1
	throw_range = 4
	hitsound = 'sound/items/salvagepickup.ogg'
	pickup_sound = 'sound/items/salvagepickup.ogg'
	drop_sound = 'sound/items/salvagedrop.ogg'
	w_class = WEIGHT_CLASS_HUGE

/obj/item/sellable/salvage/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/sellable/salvage/ruin
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. The Quartermaster may be able to make a steady profit from exporting this."

/obj/item/sellable/salvage/loot
	name = "Salvage"
	desc = "A tonne of salvage looted from a fallen foe. The Quartermaster may be able to make a steady profit from exporting this."
