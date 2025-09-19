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
	/// How much is the salvage worth?
	var/value = 100

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

/obj/item/salvage/ruin/soviet
	name = "armaments cache"
	desc = "A crate of old disused Belastrav ballistic firearms that have been weathered into uselessness. They still may be of value to collectors, however."
	icon_state = "weapon_crate"

/obj/item/salvage/ruin/brick
	name = "mysterious brick"
	desc = "A peculiar brick formed out of what appears to be plastic. This would make a fantastic collector's item."
	icon_state = "lego_brick"
	hitsound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'

/obj/item/salvage/ruin/brick/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 5, 10) // 5 to 10 damage, hits like a truck

/obj/item/salvage/ruin/nanotrasen
	name = "lost research notes"
	desc = "A collection of research notes penned by old Nanotrasen scientists from decades past, technology lost in time- until you found them. While quite dated, they may contain insights missed by today's researchers."
	icon_state = "research_doc"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'

/obj/item/salvage/ruin/nanotrasen/Initialize(mapload)
	. = ..()
	origin_tech = pick("combat=5", "materials=5", "engineering=5", "biotech=5", "powerstorage=5", "programming=5")

/obj/item/salvage/ruin/carp
	name = "carp scales"
	desc = "A collection of scales shed from a corrupted space carp. Their unique molecular composition may prove useful to material scientists."
	icon_state = "dragon_scales"
	hitsound = sound('sound/effects/hit_on_shattered_glass.ogg', 20)
	pickup_sound = sound('sound/hallucinations/im_here2.ogg', 10)
	drop_sound = sound('sound/hallucinations/look_up2.ogg', 10)

/obj/item/salvage/ruin/tablet
	name = "mysterious tablet"
	desc = "An old, weathered tablet made of dark stone. Merely looking at it sends chills down your spine."
	icon_state = "stone_tablet"
	hitsound = sound('sound/effects/break_stone.ogg', 20)
	pickup_sound =  sound('sound/hallucinations/im_here2.ogg', 10)
	drop_sound = sound('sound/hallucinations/look_up2.ogg', 10)

/// Loot salvage, gained from fighting space simplemobs.

/obj/item/salvage/loot
	desc = "If you can see this forbidden salvage, report it on GitHub."

/obj/item/salvage/loot/pirate
	name = "stolen jewellery"
	desc = "A collection of stolen jewellery and gemstones. Gold, silver, sapphire, amethyst, and more, this bounty will surely fetch a good price on the market."
	icon_state = "pirate_treasure"
	hitsound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'

/obj/item/salvage/loot/soviet
	name = "\improper Cygni manifesto"
	desc = "A small book, written in Cygni Standard, detailing the manifesto of Malfoy Ames, father of The Cygni Rebellion. Banned in Federation space, it may fetch a decent price on the black market."
	icon_state = "ussp_manual"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'

/obj/item/salvage/loot/syndicate
	name = "syndicate intel"
	desc = "A folder detailing Syndicate plans to infiltrate and sabotage operations in the Epsilon Eridani system. This sort of intelligence treasure will be highly valued by Company counterintelligence."
	icon_state = "syndie_doc"
	hitsound = 'sound/items/handling/paper_pickup.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	drop_sound = 'sound/items/handling/paper_drop.ogg'
