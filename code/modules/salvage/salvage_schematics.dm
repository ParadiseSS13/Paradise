#define SALVAGE_TIER_1_REQUIREMENTS list(/obj/item/salvage/salvage_component/common = 2, /obj/item/stock_parts/scanning_module = 1)
#define SALVAGE_TIER_2_REQUIREMENTS list(/obj/item/salvage/salvage_component/common = 5, /obj/item/stock_parts/scanning_module = 1)
#define SALVAGE_TIER_3_REQUIREMENTS list(/obj/item/salvage/salvage_component/common = 4, /obj/item/salvage/salvage_component/uncommon = 1, /obj/item/stock_parts/scanning_module/adv = 1)
#define SALVAGE_TIER_4_REQUIREMENTS list(/obj/item/salvage/salvage_component/common = 4, /obj/item/salvage/salvage_component/uncommon = 2, /obj/item/salvage/salvage_component/rare = 1, /obj/item/stock_parts/scanning_module/phasic = 1)
#define SALVAGE_TIER_5_REQUIREMENTS list(/obj/item/salvage/salvage_component/common = 3, /obj/item/salvage/salvage_component/uncommon = 3, /obj/item/salvage/salvage_component/rare = 2, /obj/item/stock_parts/scanning_module/phasic = 2)
#define SALVAGE_TIER_6_REQUIREMENTS list(/obj/item/salvage/salvage_component/uncommon = 5, /obj/item/salvage/salvage_component/rare = 5, /obj/item/stock_parts/scanning_module/triphasic = 2)

// MARK: Salvage Schematics
/obj/item/salvage_decryptor_schematic
	name = "salvage decryptor schematic"
	desc = "A schematic that can be used to assemble a salvage decryptor."
	icon = 'icons/obj/salvage/salvage_tools.dmi'
	w_class = WEIGHT_CLASS_SMALL
	new_attack_chain = TRUE
	/// What root icon do we use
	var/icon_root = ""
	/// What decryptor do we make
	var/obj/item/salvage_decryptor/decryptor_type
	/// What materials do we need to assemble the decryptor
	var/list/required_items = list()
	/// List of additional requirements specific to a crate type
	var/list/extra_requirements = list()

/obj/item/salvage_decryptor_schematic/Initialize(mapload)
	. = ..()
	required_items += extra_requirements
	icon_state = "mod_decryptor_" + icon_root + "_schematic"
	update_icon()

/obj/item/salvage_decryptor_schematic/examine(mob/user)
	. = ..()
	if(LAZYLEN(required_items))
		var/list/nice_list = list()
		for(var/B in required_items)
			var/atom/A = B
			if(!ispath(A))
				continue
			nice_list += list("- [initial(A.name)] x[required_items[A]]")
		. += SPAN_NOTICE("Required components:")
		for(var/S in nice_list)
			. += SPAN_NOTICE(S)

/obj/item/salvage_decryptor_schematic/illegal
	name = "dead drop decryptor schematic"
	icon_root = "drop"
	required_items = SALVAGE_TIER_1_REQUIREMENTS
	extra_requirements = list(/obj/item/stack/telecrystal = 1)
	decryptor_type = /obj/item/salvage_decryptor/illegal

/obj/item/salvage_decryptor_schematic/parts
	name = "spare parts decryptor schematic"
	icon_root = "parts"
	required_items = SALVAGE_TIER_2_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/parts

/obj/item/salvage_decryptor_schematic/cooler
	name = "cooler decryptor schematic"
	icon_root = "cooler"
	required_items = SALVAGE_TIER_2_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/cooler

/obj/item/salvage_decryptor_schematic/lost
	name = "lost and found decryptor schematic"
	icon_root = "lost"
	required_items = SALVAGE_TIER_2_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/lost

/obj/item/salvage_decryptor_schematic/service
	name = "service decryptor schematic"
	icon_root = "service"
	required_items = SALVAGE_TIER_2_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/service

/obj/item/salvage_decryptor_schematic/industrial
	name = "industrial decryptor schematic"
	icon_root = "industrial"
	required_items = SALVAGE_TIER_3_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/industrial

/obj/item/salvage_decryptor_schematic/freezer
	name = "deep freezer decryptor schematic"
	icon_root = "freezer"
	required_items = SALVAGE_TIER_3_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/freezer

/obj/item/salvage_decryptor_schematic/med
	name = "dated medicine decryptor schematic"
	icon_root = "med"
	required_items = SALVAGE_TIER_3_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/med

/obj/item/salvage_decryptor_schematic/backlog
	name = "undelivered backlog decryptor schematic"
	icon_root = "backlog"
	required_items = SALVAGE_TIER_3_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/backlog

/obj/item/salvage_decryptor_schematic/hazmat
	name = "hazmat decryptor schematic"
	icon_root = "hazmat"
	required_items = SALVAGE_TIER_4_REQUIREMENTS
	extra_requirements = list(/obj/item/geiger_counter = 1)
	decryptor_type = /obj/item/salvage_decryptor/hazmat

/obj/item/salvage_decryptor_schematic/clown
	name = "failed comedian decryptor schematic"
	icon_root = "comedian"
	required_items = SALVAGE_TIER_3_REQUIREMENTS
	extra_requirements = list(/obj/item/bikehorn = 1)
	decryptor_type = /obj/item/salvage_decryptor/clown

/obj/item/salvage_decryptor_schematic/unstable
	name = "unstable samples decryptor schematic"
	icon_root = "unstable"
	required_items = SALVAGE_TIER_4_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/unstable

/obj/item/salvage_decryptor_schematic/contain
	name = "long term containment decryptor schematic"
	icon_root = "contain"
	required_items = SALVAGE_TIER_4_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/contain

/obj/item/salvage_decryptor_schematic/live
	name = "live samples decryptor schematic"
	icon_root = "live"
	required_items = SALVAGE_TIER_4_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/live

/obj/item/salvage_decryptor_schematic/exotic
	name = "exotic decryptor schematic"
	icon_root = "exotic"
	required_items = SALVAGE_TIER_4_REQUIREMENTS
	decryptor_type = /obj/item/salvage_decryptor/exotic

/obj/item/salvage_decryptor_schematic/dno
	name = "'Do Not Open' decryptor schematic"
	icon_root = "donot"
	required_items = SALVAGE_TIER_5_REQUIREMENTS
	extra_requirements = list(/obj/item/stack/sheet/mineral/palladium = 2)
	decryptor_type = /obj/item/salvage_decryptor/dno

/obj/item/salvage_decryptor_schematic/bluespace
	name = "bluespace decryptor schematic"
	icon_root = "bluespace"
	required_items = SALVAGE_TIER_5_REQUIREMENTS
	extra_requirements = list(/obj/item/stack/ore/bluespace_crystal = 2)
	decryptor_type = /obj/item/salvage_decryptor/bluespace

/obj/item/salvage_decryptor_schematic/ancient
	name = "ancient decryptor schematic"
	icon_root = "ancient"
	required_items = SALVAGE_TIER_5_REQUIREMENTS
	extra_requirements = list(/obj/item/stack/sheet/animalhide/goliath_hide = 2, /obj/item/stack/sheet/sinew = 1)
	decryptor_type = /obj/item/salvage_decryptor/ancient

/obj/item/salvage_decryptor_schematic/deposit
	name = "deposit decryptor schematic"
	icon_root = "deposit"
	required_items = SALVAGE_TIER_5_REQUIREMENTS
	extra_requirements = list(/obj/item/stack/sheet/mineral/platinum = 2)
	decryptor_type = /obj/item/salvage_decryptor/deposit

/obj/item/salvage_decryptor_schematic/pandora
	name = "'Pandora' decryptor schematic"
	icon_root = "pandora"
	required_items = SALVAGE_TIER_6_REQUIREMENTS
	extra_requirements = list(/obj/item/dice/d20 = 1)
	decryptor_type = /obj/item/salvage_decryptor/pandora

// MARK: Salvage Decryptors
/obj/item/salvage_decryptor
	name = "salvage decryptor"
	desc = "A thrown together upgrade for a salvage scanner that will seek out more specialized crates. The circuitry is delicate and prone to overloading."
	icon = 'icons/obj/salvage/salvage_tools.dmi'
	w_class = WEIGHT_CLASS_SMALL
	new_attack_chain = TRUE
	/// What root icon do we use
	var/icon_root = ""
	/// What crate do we help find
	var/crate_type
	/// How much do we improve our odds of finding the crate we want
	var/weight_increase = 1500 // Huge bonus
	/// What is our durability
	var/durability = 5 // 5 uses

/obj/item/salvage_decryptor/Initialize(mapload)
	. = ..()
	icon_state = "mod_decryptor_" + icon_root
	update_icon()

/obj/item/salvage_decryptor/illegal
	name = "dead drop decryptor"
	icon_root = "drop"
	crate_type = /obj/item/storage/salvage_crate/illegal

/obj/item/salvage_decryptor/parts
	name = "spare parts decryptor"
	icon_root = "parts"
	crate_type = /obj/item/storage/salvage_crate/parts

/obj/item/salvage_decryptor/cooler
	name = "cooler decryptor"
	icon_root = "cooler"
	crate_type = /obj/item/storage/salvage_crate/cooler

/obj/item/salvage_decryptor/lost
	name = "lost and found decryptor"
	icon_root = "lost"
	crate_type = /obj/item/storage/salvage_crate/lost

/obj/item/salvage_decryptor/service
	name = "service decryptor"
	icon_root = "service"
	crate_type = /obj/item/storage/salvage_crate/service

/obj/item/salvage_decryptor/industrial
	name = "industrial decryptor"
	icon_root = "industrial"
	crate_type = /obj/item/storage/salvage_crate/industrial

/obj/item/salvage_decryptor/freezer
	name = "deep freezer decryptor"
	icon_root = "freezer"
	crate_type = /obj/item/storage/salvage_crate/freezer

/obj/item/salvage_decryptor/med
	name = "dated medicine decryptor"
	icon_root = "med"
	crate_type = /obj/item/storage/salvage_crate/med

/obj/item/salvage_decryptor/backlog
	name = "undelivered backlog decryptor"
	icon_root = "backlog"
	crate_type = /obj/item/storage/salvage_crate/backlog

/obj/item/salvage_decryptor/hazmat
	name = "hazmat decryptor"
	icon_root = "hazmat"
	crate_type = /obj/item/storage/salvage_crate/hazmat

/obj/item/salvage_decryptor/clown
	name = "failed comedian decryptor"
	icon_root = "comedian"
	crate_type = /obj/item/storage/salvage_crate/clown

/obj/item/salvage_decryptor/unstable
	name = "unstable samples decryptor"
	icon_root = "unstable"
	crate_type = /obj/item/storage/salvage_crate/unstable

/obj/item/salvage_decryptor/contain
	name = "long term containment decryptor"
	icon_root = "contain"
	crate_type = /obj/item/storage/salvage_crate/contain

/obj/item/salvage_decryptor/live
	name = "live samples decryptor"
	icon_root = "live"
	crate_type = /obj/item/storage/salvage_crate/live

/obj/item/salvage_decryptor/exotic
	name = "exotic decryptor"
	icon_root = "exotic"
	crate_type = /obj/item/storage/salvage_crate/exotic

/obj/item/salvage_decryptor/dno
	name = "'Do Not Open' decryptor"
	icon_root = "donot"
	crate_type = /obj/item/storage/salvage_crate/dno

/obj/item/salvage_decryptor/bluespace
	name = "bluespace decryptor"
	icon_root = "bluespace"
	crate_type = /obj/item/storage/salvage_crate/bluespace

/obj/item/salvage_decryptor/ancient
	name = "ancient decryptor"
	icon_root = "ancient"
	crate_type = /obj/item/storage/salvage_crate/ancient

/obj/item/salvage_decryptor/deposit
	name = "deposit decryptor"
	icon_root = "deposit"
	crate_type = /obj/item/storage/salvage_crate/deposit

/obj/item/salvage_decryptor/pandora
	name = "'Pandora' decryptor"
	icon_root = "pandora"
	crate_type = /obj/item/storage/salvage_crate/pandora

/obj/item/broken_decryptor
	name = "burned-out salvage decryptor"
	desc = SPAN_WARNING("The board is charred and smells of burnt plastic. It has been rendered useless.")
	icon = 'icons/obj/module.dmi'
	icon_state = "command_broken"
	materials = list(MAT_PLASTIC = 250)

#undef SALVAGE_TIER_1_REQUIREMENTS
#undef SALVAGE_TIER_2_REQUIREMENTS
#undef SALVAGE_TIER_3_REQUIREMENTS
#undef SALVAGE_TIER_4_REQUIREMENTS
#undef SALVAGE_TIER_5_REQUIREMENTS
#undef SALVAGE_TIER_6_REQUIREMENTS
