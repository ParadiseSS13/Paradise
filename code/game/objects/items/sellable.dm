/obj/item/sellable/salvage
	name = "Salvage"
	desc = "A tonne of salvage looted from bad mapping practices. Who spawned the base type? Report this on the github."
	icon = 'icons/obj/sellable.dmi'
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	hitsound = 'sound/items/handling/salvagepickup.ogg'
	pickup_sound = 'sound/items/handling/salvagepickup.ogg'
	drop_sound = 'sound/items/handling/salvagedrop.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/sellable/salvage/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can bring this back to Cargo to sell to Central Command onboard the 'NTV Arion' Supply shuttle.</span>"

/// Ruin Salvage, misc loot gained from looking around ruins.

/obj/item/sellable/salvage/ruin
	name = "Salvage"
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/ruin/pirate
	name = "Rum Keg"
	desc = "A highly valued keg of aged space rum. Limited edition and sure to be a collector's item."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	color = "#7e5c00" // So that it's slightly different from normal kegs

/obj/item/sellable/salvage/ruin/russian
	name = "Armaments Cache"
	desc = "A crate of old disused Belastrav ballistic firearms clearly long past their usability. This crate would make good scrap metal for shuttle construction."
	icon_state = "weapon_crate"

/obj/item/sellable/salvage/ruin/brick
	name = "Mysterious brick"
	desc = "A peculier brick formed out of what appears to be plastic. This would make a fantastic collector's item."
	icon_state = "lego_brick"
	hitsound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'

/obj/item/sellable/salvage/ruin/brick/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 5, 10) // 5 to 10 damage, hits like a truck

/obj/item/sellable/salvage/ruin/nanotrasen
	name = "Lost Research Notes"
	desc = "A collection of research notes penned by old Nanotrasen scientists from decades past, technology lost in time- until you found them. It is a mystery what technology Central Command will push if they could just get their hands on these notes."
	icon_state = "research_doc"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'

/obj/item/sellable/salvage/ruin/carp
	name = "Space Dragon Scales"
	desc = "A collection of scales shed from a corrupted space carp. Their culinary potential could mean untold riches for Nanotrasen."
	icon_state = "dragon_scales"
	hitsound = sound('sound/hallucinations/wail.ogg', 20)
	pickup_sound = sound('sound/hallucinations/im_here2.ogg', 20)
	drop_sound = sound('sound/hallucinations/look_up2.ogg', 20)

/obj/item/sellable/salvage/ruin/tablet
	name = "Mysterious tablet"
	desc = "A mysterious and old stone tablet. When you read the text on it, you start getting chills."
	icon_state = "stone_tablet"
	hitsound = sound('sound/hallucinations/wail.ogg', 20)
	pickup_sound =  sound('sound/hallucinations/im_here2.ogg', 20)
	drop_sound = sound('sound/hallucinations/look_up2.ogg', 20)

/// Loot salvage, gained from fighting space simplemobs.

/obj/item/sellable/salvage/loot
	name = "Salvage"
	desc = "A tonne of salvage looted from a fallen foe. Who spawned the base type? Report this on the github."

/obj/item/sellable/salvage/loot/pirate
	name = "Stolen Jewellery"
	desc = "A collection of stolen jewellery, fashioned from pilfered bluespace crystals and gems. Rumour has it, local pirates have been known to use these accessories to avoid capture."
	icon_state = "pirate_treasure"
	hitsound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'

/obj/item/sellable/salvage/loot/russian
	name = "SIOSP Manual"
	desc = "A small manual, written in Neo-Russkyia, detailing the manifesto of Malfoy Ames, father of The Cygni Rebellion. Central Command may wish to share this with their allies in the Trans-Solar Federation."
	icon_state = "ussp_manual"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'

/obj/item/sellable/salvage/loot/syndicate
	name = "Syndicate Intel"
	desc = "A folder detailing Syndicate plans to infiltrate and sabotage operations in the Epsilon Eridani sector. Central Command may find use of this to aid them in counter-intelligence."
	icon_state = "syndie_doc"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'
