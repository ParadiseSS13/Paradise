/*
######################################################################################
##																					##
##								IMPORTANT README									##
##																					##
##	  Changing any /datum/gear typepaths --WILL-- break people's loadouts.			##
##	The typepaths are stored directly in the `characters.gear` column of the DB.	##
##		Please inform the server host if you wish to modify any of these.			##
##																					##
######################################################################################
*/


/datum/gear/suit
	main_typepath = /datum/gear/suit
	slot = SLOT_HUD_OUTER_SUIT
	sort_category = "External Wear"

//WINTER COATS
/datum/gear/suit/coat
	main_typepath = /datum/gear/suit/coat

/datum/gear/suit/coat/grey
	display_name = "Winter coat"
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/suit/coat/job
	main_typepath = /datum/gear/suit/coat/job
	subtype_selection_cost = FALSE

/datum/gear/suit/coat/job/sec
	display_name = "Winter coat, security"
	path = /obj/item/clothing/suit/hooded/wintercoat/security
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/suit/coat/job/captain
	display_name = "Winter coat, captain"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/coat/job/med
	display_name = "Winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")

/datum/gear/suit/coat/job/sci
	display_name = "Winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list("Scientist", "Research Director")

/datum/gear/suit/coat/job/engi
	display_name = "Winter coat, engineering"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	allowed_roles = list("Chief Engineer", "Station Engineer")

/datum/gear/suit/coat/job/atmos
	display_name = "Winter coat, atmospherics"
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/suit/coat/job/hydro
	display_name = "Winter coat, hydroponics"
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/coat/job/cargo
	display_name = "Winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/coat/job/miner
	display_name = "Winter coat, mining"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Quartermaster", "Shaft Miner")

//LABCOATS
/datum/gear/suit/labcoat_emt
	display_name = "Labcoat, paramedic"
	path = /obj/item/clothing/suit/storage/labcoat/emt
	allowed_roles = list("Chief Medical Officer", "Paramedic")

//BOMBER JACKETS
/datum/gear/suit/bomber
	main_typepath = /datum/gear/suit/bomber

/datum/gear/suit/bomber/basic
	display_name = "Bomber jacket"
	path = /obj/item/clothing/suit/jacket

/datum/gear/suit/bomber/job
	main_typepath = /datum/gear/suit/bomber/job
	subtype_selection_cost = FALSE

/datum/gear/suit/bomber/job/sec
	display_name = "Bomber jacket, security"
	path = /obj/item/clothing/suit/jacket/secbomber
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/suit/bomber/job/cargo
	display_name = "Bomber jacket, cargo"
	path = /obj/item/clothing/suit/jacket/cargobomber
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/bomber/job/miner
	display_name = "Bomber jacket, mining"
	path = /obj/item/clothing/suit/jacket/miningbomber
	allowed_roles = list("Quartermaster", "Shaft Miner")

/datum/gear/suit/bomber/job/expedition
	display_name = "Bomber jacket, expedition"
	path = /obj/item/clothing/suit/jacket/expeditionbomber
	allowed_roles = list("Quartermaster", "Explorer")

/datum/gear/suit/bomber/job/engi
	display_name = "Bomber jacket, engineering"
	path = /obj/item/clothing/suit/jacket/engibomber
	allowed_roles = list("Chief Engineer", "Station Engineer")

/datum/gear/suit/bomber/job/atmos
	display_name = "Bomber jacket, atmospherics"
	path = /obj/item/clothing/suit/jacket/atmosbomber
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/suit/bomber/job/hydro
	display_name = "Bomber jacket, hydroponics"
	path = /obj/item/clothing/suit/jacket/hydrobomber
	allowed_roles = list("Botanist")

/datum/gear/suit/bomber/job/medical
	display_name = "Bomber jacket, medical"
	path = /obj/item/clothing/suit/jacket/medbomber
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")

/datum/gear/suit/bomber/job/chemist
	display_name = "Bomber jacket, chemist"
	path = /obj/item/clothing/suit/jacket/chembomber
	allowed_roles = list("Chemist")

/datum/gear/suit/bomber/job/coroner
	display_name = "Bomber jacket, coroner"
	path = /obj/item/clothing/suit/jacket/coronerbomber
	allowed_roles = list("Coroner")

/datum/gear/suit/bomber/job/science
	display_name = "Bomber jacket, science"
	path = /obj/item/clothing/suit/jacket/scibomber
	allowed_roles = list("Research Director", "Scientist")

/datum/gear/suit/bomber/job/robotics
	display_name = "Bomber jacket, robotics"
	path = /obj/item/clothing/suit/jacket/robobomber
	allowed_roles = list("Research Director", "Roboticist")

//JACKETS
/datum/gear/suit/leather_jacket
	display_name = "Leather jacket"
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/suit/motojacket
	display_name = "Leather motorcycle jacket"
	path = /obj/item/clothing/suit/jacket/motojacket

/datum/gear/suit/br_tcoat
	display_name = "Trenchcoat, brown"
	path = /obj/item/clothing/suit/browntrenchcoat

/datum/gear/suit/bl_tcoat
	display_name = "Trenchcoat, black"
	path = /obj/item/clothing/suit/blacktrenchcoat

/datum/gear/suit/ol_miljacket
	display_name = "Military jacket, olive"
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/suit/nv_miljacket
	display_name = "Military jacket, navy"
	path = /obj/item/clothing/suit/jacket/miljacket/navy

/datum/gear/suit/ds_miljacket
	display_name = "Military jacket, desert"
	path = /obj/item/clothing/suit/jacket/miljacket/desert

/datum/gear/suit/wh_miljacket
	display_name = "Military jacket, white"
	path = /obj/item/clothing/suit/jacket/miljacket/white

/datum/gear/suit/secjacket
	display_name = "Security jacket"
	path = /obj/item/clothing/suit/armor/secjacket
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/suit/ianshirt
	display_name = "Ian Shirt"
	path = /obj/item/clothing/suit/ianshirt

/datum/gear/suit/poncho
	display_name = "Poncho, classic"
	path = /obj/item/clothing/suit/poncho

/datum/gear/suit/grponcho
	display_name = "Poncho, green"
	path = /obj/item/clothing/suit/poncho/green

/datum/gear/suit/rdponcho
	display_name = "Poncho, red"
	path = /obj/item/clothing/suit/poncho/red

/datum/gear/suit/secponcho
	display_name = "Poncho, security"
	path = /obj/item/clothing/suit/armor/secponcho
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/suit/tphoodie
	display_name = "Hoodie, Tharsis Polytech"
	path = /obj/item/clothing/suit/hooded/hoodie/tp

/datum/gear/suit/nthoodie
	display_name = "Hoodie, Nanotrasen"
	path = /obj/item/clothing/suit/hooded/hoodie/nt

/datum/gear/suit/lamhoodie
	display_name = "Hoodie, Lunar Academy of Medicine"
	path = /obj/item/clothing/suit/hooded/hoodie/lam

/datum/gear/suit/cuthoodie
	display_name = "Hoodie, Canaan University of Technology"
	path = /obj/item/clothing/suit/hooded/hoodie/cut

/datum/gear/suit/mithoodie
	display_name = "Hoodie, Martian Institute of Technology"
	path = /obj/item/clothing/suit/hooded/hoodie/mit

/datum/gear/suit/bluehoodie
	display_name = "Hoodie, blue"
	path = /obj/item/clothing/suit/hooded/hoodie/blue

/datum/gear/suit/blackhoodie
	display_name = "Hoodie, black"
	path = /obj/item/clothing/suit/hooded/hoodie

//SUITS!

/datum/gear/suit/blacksuit
	display_name = "Suit jacket, black"
	path = /obj/item/clothing/suit/storage/iaa/blackjacket

/datum/gear/suit/bluesuit
	display_name = "Suit jacket, blue"
	path = /obj/item/clothing/suit/storage/iaa/bluejacket

/datum/gear/suit/purplesuit
	display_name = "Suit jacket, purple"
	path = /obj/item/clothing/suit/storage/iaa/purplejacket

//Mantles!
/datum/gear/suit/mantle
	display_name = "Mantle"
	path = /obj/item/clothing/suit/mantle

/datum/gear/suit/old_scarf
	display_name = "Old scarf"
	path = /obj/item/clothing/suit/mantle/old

/datum/gear/suit/regal_shawl
	display_name = "Regal shawl"
	path = /obj/item/clothing/suit/mantle/regal

/datum/gear/suit/mantle/job
	main_typepath = /datum/gear/suit/mantle/job
	subtype_selection_cost = FALSE

/datum/gear/suit/mantle/job/captain
	display_name = "Mantle, captain"
	path = /obj/item/clothing/suit/mantle/armor/captain
	allowed_roles = list("Captain")

/datum/gear/suit/mantle/job/ce
	display_name = "Mantle, chief engineer"
	path = /obj/item/clothing/suit/mantle/chief_engineer
	allowed_roles = list("Chief Engineer")

/datum/gear/suit/mantle/job/cmo
	display_name = "Mantle, chief medical officer"
	path = /obj/item/clothing/suit/mantle/labcoat/chief_medical_officer
	allowed_roles = list("Chief Medical Officer")

/datum/gear/suit/mantle/job/hos
	display_name = "Mantle, head of security"
	path = /obj/item/clothing/suit/mantle/armor
	allowed_roles = list("Head of Security")

/datum/gear/suit/mantle/job/hop
	display_name = "Mantle, head of personnel"
	path = /obj/item/clothing/suit/mantle/armor/hop
	allowed_roles = list("Head of Personnel")

/datum/gear/suit/mantle/job/rd
	display_name = "Mantle, research director"
	path = /obj/item/clothing/suit/mantle/labcoat
	allowed_roles = list("Research Director")

//Robes!

/datum/gear/suit/witch
	display_name = "Witch robes"
	path = /obj/item/clothing/suit/wizrobe/marisa/fake
