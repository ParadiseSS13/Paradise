/obj/item/bio_chip/uplink/ninja
	name = "spider clan uplink bio-chip"
	desc = "Purchase things from the spider clan with earned currency."

/obj/item/bio_chip/uplink/ninja/Initialize(mapload)
	. = ..()
	if(hidden_uplink)
		hidden_uplink.update_uplink_type(UPLINK_TYPE_NINJA)
		hidden_uplink.uses = 0

/datum/uplink_item/ninja
	category = "Spider Clan Provisions"
	surplus = 0
	uplinktypes = list(UPLINK_TYPE_NINJA)

/datum/uplink_item/ninja/shuriken_printer
	name = "Shuriken Printer"
	desc = "An advanced, tiny autofabricator that slowly creates and stores energy shurikens."
	reference = "SPR"
	item = /obj/item/shuriken_printer
	cost = 25

/datum/uplink_item/ninja/ninja_modsuit
	name = "'Shinobi' Stealth Modsuit"
	desc = "A specialized modsuit worn by the spider clan's elite ninja operatives."
	reference = "SNBMOD"
	item = /obj/item/mod/control/pre_equipped/ninja
	cost = 45

/datum/uplink_item/ninja/energy_katana
	name = "Energy Katana"
	desc = "A plastitanium katana with a reinforced emitter edge. A ninja's most reliable tool."
	reference = "EKAT"
	item = /obj/item/katana/energy
	cost = 20

/datum/uplink_item/ninja/energy_net
	name = "Energy Net Projector"
	desc = "A non-lethal weapon favored by the Spider Clan. Targets struck will find themselves trapped in an energy net."
	reference = "ENET"
	item = /obj/item/gun/energy/kinetic_accelerator/energy_net
	cost = 30


/datum/uplink_item/ninja/spider_bomb
	name = "Spider Bomb"
	desc = "An evil device fabricated by the Spider Clan. This bomb contains a large number of dehydrated spider-cubes that will all activate upon detonation. These spiders do not discern friend from foe - all non-spiders make for good food."
	reference = "SPBM"
	item = /obj/machinery/syndicatebomb/ninja/spiders
	cost = 65

/datum/uplink_item/ninja/hood
	name = "Ninja Scarf"
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	reference = "NJSC"
	item = /obj/item/clothing/head/helmet/space_ninja
	cost = 10

/datum/uplink_item/ninja/mask
	name = "Ninja Mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	reference = "NJMSK"
	item = /obj/item/clothing/mask/gas/space_ninja
	cost = 10

/datum/uplink_item/ninja/gloves
	name = "Ninja Gloves"
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	reference = "NJGL"
	item = /obj/item/clothing/gloves/space_ninja
	cost = 10

/datum/uplink_item/ninja/shoes
	name = "Ninja Shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	reference = "NJSH"
	item = /obj/item/clothing/shoes/space_ninja
	cost = 10

/datum/uplink_item/ninja/suit
	name = "Ninja Kabuto"
	desc = "A unique suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	reference = "NJKB"
	item = /obj/item/clothing/suit/space_ninja
	cost = 10

/datum/uplink_item/ninja/suit_bundle
	name = "Full Ninja Outfit"
	desc = "A bulk purchase of a full ninja outfit. Good for if you somehow lost the other set of highly advanced Spider Clan equipment."
	reference = "NJST"
	item = /obj/item/clothing/suit/space_ninja
	cost = 40
