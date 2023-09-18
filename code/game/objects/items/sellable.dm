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
	w_class = WEIGHT_CLASS_NORMAL

/// Ruin Salvage, misc loot gained from looking around ruins.

/obj/item/sellable/salvage/ruin
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/pirate
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/russian
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/syndicate
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/nanotrasen
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/carp
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/pirate
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."


/// Loot salvage, gained from fighting space simplemobs.

/obj/item/sellable/salvage/loot
	name = "Salvage"
	desc = "A tonne of salvage looted from a fallen foe. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/loot/pirate
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/loot/russian
	name = "Sovereignty and the Intergalactic Obligations of Socialist Planets"
	desc = "A small red manual, written in Neo-Russkyia, detailing the manifesto of Malfoy Ames. Central Command may wish to share this with their allies in the Trans-Solar Federation."

/obj/item/sellable/salvage/loot/syndicate
	name = "Syndicate Battle Plans"
	desc = "A folder detailing Syndicate plans to infiltrate and sabotage operations onboard the [station_name()]. Central Command may find use of this to aid them in counter-intelligence."

/obj/item/sellable/salvage/loot/syndicate/Initialize(mapload)
	. = ..()
[station_name()]

