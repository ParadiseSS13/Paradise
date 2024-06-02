/obj/item/salvage
	name = "salvage"
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

/obj/item/salvage/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can bring this back to Cargo to sell to Central Command onboard the 'NTV Arion' Supply shuttle.</span>"

/// Ruin Salvage, misc loot gained from looking around ruins.

/obj/item/salvage/ruin
	desc = "A tonne of salvage recovered from an abandoned ruin. Who spawned the base type? Report this on the github."

/obj/item/salvage/ruin/pirate
	name = "rum keg"
	desc = "A highly valued keg of aged space rum. Limited edition and sure to be a collector's item."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	color = "#7e5c00" // So that it's slightly different from normal kegs

/obj/item/salvage/ruin/russian
	name = "armaments cache"
	desc = "A crate of old disused Belastrav ballistic firearms clearly long past their usability. This crate would make good scrap metal for shuttle construction."
	icon_state = "weapon_crate"

/obj/item/salvage/ruin/brick
	name = "mysterious brick"
	desc = "A peculier brick formed out of what appears to be plastic. This would make a fantastic collector's item."
	icon_state = "lego_brick"
	hitsound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'

/obj/item/salvage/ruin/brick/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 5, 10) // 5 to 10 damage, hits like a truck

/obj/item/salvage/ruin/nanotrasen
	name = "lost research notes"
	desc = "A collection of research notes penned by old Nanotrasen scientists from decades past, technology lost in time- until you found them. It is a mystery what technology Central Command will push if they could just get their hands on these notes."
	icon_state = "research_doc"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'

/obj/item/salvage/ruin/nanotrasen/Initialize(mapload)
	. = ..()
	origin_tech = pick("combat=5", "materials=5", "engineering=5", "biotech=5", "powerstorage=5", "programming=5")

/obj/item/salvage/ruin/carp
	name = "carp scales"
	desc = "A collection of scales shed from a corrupted space carp. Their culinary potential could mean untold riches for Nanotrasen."
	icon_state = "dragon_scales"
	hitsound = sound('sound/effects/hit_on_shattered_glass.ogg', 20)
	pickup_sound = sound('sound/hallucinations/im_here2.ogg', 10)
	drop_sound = sound('sound/hallucinations/look_up2.ogg', 10)

/obj/item/salvage/ruin/tablet
	name = "mysterious tablet"
	desc = "A mysterious and old stone tablet. When you read the text on it, you start getting chills."
	icon_state = "stone_tablet"
	hitsound = sound('sound/effects/break_stone.ogg', 20)
	pickup_sound =  sound('sound/hallucinations/im_here2.ogg', 10)
	drop_sound = sound('sound/hallucinations/look_up2.ogg', 10)

/// Loot salvage, gained from fighting space simplemobs.

/obj/item/salvage/loot
	desc = "A tonne of salvage looted from a fallen foe. Who spawned the base type? Report this on the github."

/obj/item/salvage/loot/pirate
	name = "stolen jewellery"
	desc = "A collection of stolen jewellery, fashioned from pilfered bluespace crystals and gems. Rumour has it, local pirates have been known to use these accessories to avoid capture."
	icon_state = "pirate_treasure"
	hitsound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'

/obj/item/salvage/loot/russian
	name = "siosp manual"
	desc = "A small manual, written in Neo-Russkyia, detailing the manifesto of Malfoy Ames, father of The Cygni Rebellion. Central Command may wish to share this with their allies in the Trans-Solar Federation."
	icon_state = "ussp_manual"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'

/obj/item/salvage/loot/syndicate
	name = "syndicate intel"
	desc = "A folder detailing Syndicate plans to infiltrate and sabotage operations in the Epsilon Eridani sector. Central Command may find use of this to aid them in counter-intelligence."
	icon_state = "syndie_doc"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'
