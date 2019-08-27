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

/datum/gear/suit/coat/job
	subtype_path = /datum/gear/suit/coat/job
	subtype_cost_overlap = FALSE

/datum/gear/suit/coat/job/sec
	display_name = "winter coat, security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer", "Security Pod Pilot")

/datum/gear/suit/coat/job/captain
	display_name = "winter coat, captain"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/coat/job/med
	display_name = "winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Brig Physician" , "Coroner")

/datum/gear/suit/coat/job/sci
	display_name = "winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list("Scientist", "Research Director")

/datum/gear/suit/coat/job/engi
	display_name = "winter coat, engineering"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list("Chief Engineer", "Station Engineer", "Mechanic")

/datum/gear/suit/coat/job/atmos
	display_name = "winter coat, atmospherics"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/suit/coat/job/hydro
	display_name = "winter coat, hydroponics"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/coat/job/cargo
	display_name = "winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/coat/job/miner
	display_name = "winter coat, miner"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Shaft Miner")

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

/datum/gear/suit/ianshirt
	display_name = "Ian Shirt"
	path = /obj/item/clothing/suit/ianshirt

/datum/gear/suit/poncho
	display_name = "poncho, classic"
	path = /obj/item/clothing/suit/poncho

/datum/gear/suit/grponcho
	display_name = "poncho, green"
	path = /obj/item/clothing/suit/poncho/green

/datum/gear/suit/rdponcho
	display_name = "poncho, red"
	path = /obj/item/clothing/suit/poncho/red

/datum/gear/suit/tphoodie
	display_name = "hoodie, Tharsis Polytech"
	path = /obj/item/clothing/suit/hooded/hoodie/tp

/datum/gear/suit/nthoodie
	display_name = "hoodie, Nanotrasen"
	path = /obj/item/clothing/suit/hooded/hoodie/nt

/datum/gear/suit/lamhoodie
	display_name = "hoodie, Lunar Academy of Medicine"
	path = /obj/item/clothing/suit/hooded/hoodie/lam

/datum/gear/suit/cuthoodie
	display_name = "hoodie, Canaan University of Technology"
	path = /obj/item/clothing/suit/hooded/hoodie/cut

/datum/gear/suit/mithoodie
	display_name = "hoodie, Martian Institute of Technology"
	path = /obj/item/clothing/suit/hooded/hoodie/mit

/datum/gear/suit/bluehoodie
	display_name = "hoodie, blue"
	path = /obj/item/clothing/suit/hooded/hoodie/blue

/datum/gear/suit/blackhoodie
	display_name = "hoodie, black"
	path = /obj/item/clothing/suit/hooded/hoodie

//SUITS!

/datum/gear/suit/blacksuit
	display_name = "suit jacket, black"
	path = /obj/item/clothing/suit/storage/lawyer/blackjacket

/datum/gear/suit/bluesuit
	display_name = "suit jacket, blue"
	path = /obj/item/clothing/suit/storage/lawyer/bluejacket

/datum/gear/suit/purplesuit
	display_name = "suit jacket, purple"
	path = /obj/item/clothing/suit/storage/lawyer/purpjacket

//Mantles!
/datum/gear/suit/mantle
	display_name = "mantle"
	path = /obj/item/clothing/suit/mantle

/datum/gear/suit/old_scarf
	display_name = "old scarf"
	path = /obj/item/clothing/suit/mantle/old

/datum/gear/suit/regal_shawl
	display_name = "regal shawl"
	path = /obj/item/clothing/suit/mantle/regal

/datum/gear/suit/captain_cloak
	display_name = "mantle, captain"
	path = /obj/item/clothing/suit/mantle/armor/captain
	allowed_roles = list("Captain")

/datum/gear/suit/ce_mantle
	display_name = "mantle, chief engineer"
	path = /obj/item/clothing/suit/mantle/chief_engineer
	allowed_roles = list("Chief Engineer")

/datum/gear/suit/cmo_mantle
	display_name = "mantle, chief medical officer"
	path = /obj/item/clothing/suit/mantle/labcoat/chief_medical_officer
	allowed_roles = list("Chief Medical Officer")

/datum/gear/suit/armored_shawl
	display_name = "mantle, head of security"
	path = /obj/item/clothing/suit/mantle/armor
	allowed_roles = list("Head of Security")

/datum/gear/suit/hop_shawl
	display_name = "mantle, head of personnel"
	path = /obj/item/clothing/suit/mantle/armor/head_of_personnel
	allowed_roles = list("Head of Personnel")

/datum/gear/suit/rd_mantle
	display_name = "mantle, research director"
	path = /obj/item/clothing/suit/mantle/labcoat
	allowed_roles = list("Research Director")
