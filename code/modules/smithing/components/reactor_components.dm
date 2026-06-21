/obj/item/smithed_item/component/rod_housing
	name = "Debug rod housing"
	desc = ABSTRACT_TYPE_DESC
	icon_state = "rod_housing"
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/rod_housing/plasma_agitator
	name = "plasma agitator cladding"
	desc = "The primary structural housing of a plasma agitator."
	materials = list(MAT_METAL = 6000, MAT_GOLD = 2000)
	finished_product = /obj/item/nuclear_rod/moderator/plasma_agitator

/obj/item/smithed_item/component/rod_housing/aluminum_reflector
	name = "aluminum reflector cladding"
	desc = "The primary structural housing of an aluminum reflector."
	materials = list(MAT_METAL = 6000, MAT_GOLD = 2000)
	finished_product = /obj/item/nuclear_rod/moderator/aluminum_reflector

/obj/item/smithed_item/component/rod_housing/molten_salt
	name = "molten salt circulator cladding"
	desc = "The primary structural housing of a molten salt circultor."
	materials = list(MAT_METAL = 6000, MAT_GLASS = 4000)
	finished_product = /obj/item/nuclear_rod/coolant/molten_salt

/obj/item/smithed_item/component/rod_housing/steam_hammerjet
	name = "steam hammerjet cladding"
	desc = "The primary structural housing of a steam hammerjet."
	materials = list(MAT_METAL = 6000, MAT_GLASS = 4000)
	finished_product = /obj/item/nuclear_rod/coolant/steam_hammerjet

/obj/item/smithed_item/component/rod_housing/platinum_refelctor
	name = "platinum plate cladding"
	desc = "The primary structural housing of a platinum reflector plate."
	materials = list(MAT_METAL = 6000, MAT_TITANIUM = 2000)
	finished_product = /obj/item/nuclear_rod/moderator/platinum_plating

/obj/item/smithed_item/component/rod_housing/iridium_conductor
	name = "iridium conductor cladding"
	desc = "The primary structural housing of an iridium conductor."
	materials = list(MAT_METAL = 6000, MAT_TITANIUM = 2000)
	finished_product = /obj/item/nuclear_rod/coolant/iridium_conductor

/obj/item/smithed_item/component/rod_core
	name = "Debug rod core"
	desc = ABSTRACT_TYPE_DESC
	icon_state = "rod_core"
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/rod_core/plasma_agitator
	name = "plasma agitator core"
	desc = "This is the primary core structure of a plasma agitator."
	materials = list(MAT_TITANIUM = 2000, MAT_PLASMA = 6000)
	finished_product = /obj/item/nuclear_rod/moderator/plasma_agitator

/obj/item/smithed_item/component/rod_core/aluminum_reflector
	name = "aluminum reflector core"
	desc = "This is the primary core structure of an aluminum reflector."
	materials = list(MAT_TITANIUM = 2000, MAT_SILVER = 4000)
	finished_product = /obj/item/nuclear_rod/moderator/aluminum_reflector

/obj/item/smithed_item/component/rod_core/molten_salt
	name = "molten salt circulator core"
	desc = "This is the primary core structure of a molten salt circulator."
	materials = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/nuclear_rod/coolant/molten_salt

/obj/item/smithed_item/component/rod_core/steam_hammerjet
	name = "steam hammerjet core"
	desc = "This is the primary core structure of a steam hammerjet."
	materials = list(MAT_TITANIUM = 2000, MAT_GOLD = 2000)
	finished_product = /obj/item/nuclear_rod/coolant/steam_hammerjet

/obj/item/smithed_item/component/rod_core/platinum_refelctor
	name = "platinum reflector core"
	desc = "This is the primary core structure of a platinum reflector."
	materials = list(MAT_TITANIUM = 2000, MAT_PLATINUM = 2000)
	finished_product = /obj/item/nuclear_rod/moderator/platinum_plating

/obj/item/smithed_item/component/rod_core/iridium_conductor
	name = "iridium conductor core"
	desc = "This is the primary core structure of an iridium conductor."
	materials = list(MAT_TITANIUM = 2000, MAT_IRIDIUM = 2000)
	finished_product = /obj/item/nuclear_rod/coolant/iridium_conductor
