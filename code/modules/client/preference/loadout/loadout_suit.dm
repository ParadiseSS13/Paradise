/datum/gear/suit
	subtype_path = /datum/gear/suit
	slot = slot_wear_suit
	sort_category = "External Wear"
	
//WINTER COATS
/datum/gear/suit/coat
	subtype_path = /datum/gear/suit/coat

/datum/gear/suit/coat/grey
	display_name = "winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/suit/coat/sec
	display_name = "winter coat, security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/suit/coat/captain
	display_name = "winter coat, captain"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/coat/med
	display_name = "winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Brig Physician")

/datum/gear/suit/coat/sci
	display_name = "winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list("Scientist", "Research Director")

/datum/gear/suit/coat/engi
	display_name = "winter coat, engineering"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list("Chief Engineer", "Engineer", "Mechanic")

/datum/gear/suit/coat/atmos
	display_name = "winter coat, atmospherics"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/suit/coat/hydro
	display_name = "winter coat, hydroponics"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/coat/cargo
	display_name = "winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/coat/miner
	display_name = "winter coat, miner"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Quartermaster", "Miner")
//LABCOATS
/datum/gear/suit/labcoat_emt
	display_name = "labcoat, paramedic"
	path = /obj/item/clothing/suit/storage/labcoat/emt
	allowed_roles = list("Chief Medical Officer", "Paramedic")

//JACKETS
/datum/gear/suit/leather_jacket
	display_name = "leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/br_tcoat
	display_name = "trenchcoat, brown"
	path = /obj/item/clothing/suit/browntrenchcoat

/datum/gear/suit/bl_tcoat
	display_name = "trenchcoat, black"
	path = /obj/item/clothing/suit/blacktrenchcoat

/datum/gear/suit/bomber_jacket
	display_name = "bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/ol_miljacket
	display_name = "military jacket, olive"
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/suit/nv_miljacket
	display_name = "military jacket, navy"
	path = /obj/item/clothing/suit/jacket/miljacket/navy

/datum/gear/suit/ds_miljacket
	display_name = "military jacket, desert"
	path = /obj/item/clothing/suit/jacket/miljacket/desert

/datum/gear/suit/wh_miljacket
	display_name = "military jacket, white"
	path = /obj/item/clothing/suit/jacket/miljacket/white

/datum/gear/suit/secjacket
	display_name = "security jacket"
	path = /obj/item/clothing/suit/armor/secjacket
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")
