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
	slot = ITEM_SLOT_OUTER_SUIT
	sort_category = "External Wear"

/datum/gear/suit/job
	main_typepath = /datum/gear/suit/job

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
	display_name = "Winter coat, captain, blue"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain
	allowed_roles = list("Captain")

/datum/gear/suit/coat/job/captain/white
	display_name = "Winter coat, captain, white"
	path = /obj/item/clothing/suit/hooded/wintercoat/captain/white
	allowed_roles = list("Captain")

/datum/gear/suit/coat/job/hop
	display_name = "Winter coat, head of personnel"
	path = /obj/item/clothing/suit/hooded/wintercoat/hop
	allowed_roles = list("Head of Personnel")

/datum/gear/suit/coat/job/med
	display_name = "Winter coat, medical"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")

/datum/gear/suit/coat/job/med/paramed
	display_name = "Winter coat, paramedic"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	allowed_roles = list("Chief Medical Officer", "Paramedic")

/datum/gear/suit/coat/job/med/coroner
	display_name = "Winter coat, coroner"
	path = /obj/item/clothing/suit/hooded/wintercoat/medical/coroner
	allowed_roles = list("Chief Medical Officer", "Coroner")

/datum/gear/suit/coat/job/chemist
	display_name = "Winter coat, chemist"
	path = /obj/item/clothing/suit/hooded/wintercoat/chemistry
	allowed_roles = list("Chief Medical Officer", "Chemist")

/datum/gear/suit/coat/job/sci
	display_name = "Winter coat, science"
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	allowed_roles = list("Scientist", "Research Director", "Geneticist")

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

/datum/gear/suit/coat/job/chef
	display_name = "Winter coat, chef"
	path = /obj/item/clothing/suit/hooded/wintercoat/chef
	allowed_roles = list("Chef")

/datum/gear/suit/coat/job/cargo
	display_name = "Winter coat, cargo"
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/coat/job/miner
	display_name = "Winter coat, mining"
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	allowed_roles = list("Quartermaster", "Shaft Miner")

/datum/gear/suit/coat/job/explorer
	display_name = "Winter coat, expedition"
	path = /obj/item/clothing/suit/hooded/wintercoat/explorer
	allowed_roles = list("Quartermaster", "Explorer")

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
	path = /obj/item/clothing/suit/jacket/bomber

/datum/gear/suit/bomber/job
	main_typepath = /datum/gear/suit/bomber/job
	subtype_selection_cost = FALSE

/datum/gear/suit/bomber/job/sec
	display_name = "Bomber jacket, security"
	path = /obj/item/clothing/suit/jacket/bomber/sec
	allowed_roles = list("Head of Security", "Warden", "Detective", "Security Officer")

/datum/gear/suit/bomber/job/cargo
	display_name = "Bomber jacket, cargo"
	path = /obj/item/clothing/suit/jacket/bomber/cargo
	allowed_roles = list("Quartermaster", "Cargo Technician")

/datum/gear/suit/bomber/job/miner
	display_name = "Bomber jacket, mining"
	path = /obj/item/clothing/suit/jacket/bomber/mining
	allowed_roles = list("Quartermaster", "Shaft Miner")

/datum/gear/suit/bomber/job/expedition
	display_name = "Bomber jacket, expedition"
	path = /obj/item/clothing/suit/jacket/bomber/expedition
	allowed_roles = list("Quartermaster", "Explorer")

/datum/gear/suit/bomber/job/smith
	display_name = "Bomber jacket, smith"
	path = /obj/item/clothing/suit/jacket/bomber/smith
	allowed_roles = list("Quartermaster", "Smith")

/datum/gear/suit/bomber/job/engi
	display_name = "Bomber jacket, engineering"
	path = /obj/item/clothing/suit/jacket/bomber/engi
	allowed_roles = list("Chief Engineer", "Station Engineer")

/datum/gear/suit/bomber/job/atmos
	display_name = "Bomber jacket, atmospherics"
	path = /obj/item/clothing/suit/jacket/bomber/atmos
	allowed_roles = list("Chief Engineer", "Life Support Specialist")

/datum/gear/suit/bomber/job/hydro
	display_name = "Bomber jacket, hydroponics"
	path = /obj/item/clothing/suit/jacket/bomber/hydro
	allowed_roles = list("Botanist")

/datum/gear/suit/bomber/job/medical
	display_name = "Bomber jacket, medical"
	path = /obj/item/clothing/suit/jacket/bomber/med
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")

/datum/gear/suit/bomber/job/chemist
	display_name = "Bomber jacket, chemist"
	path = /obj/item/clothing/suit/jacket/bomber/chem
	allowed_roles = list("Chemist")

/datum/gear/suit/bomber/job/coroner
	display_name = "Bomber jacket, coroner"
	path = /obj/item/clothing/suit/jacket/bomber/coroner
	allowed_roles = list("Coroner")

/datum/gear/suit/bomber/job/science
	display_name = "Bomber jacket, science"
	path = /obj/item/clothing/suit/jacket/bomber/sci
	allowed_roles = list("Research Director", "Scientist", "Geneticist")

/datum/gear/suit/bomber/job/robotics
	display_name = "Bomber jacket, robotics"
	path = /obj/item/clothing/suit/jacket/bomber/robo
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

//Robes!

/datum/gear/suit/witch
	display_name = "Witch robes"
	path = /obj/item/clothing/suit/wizrobe/marisa/fake

/datum/gear/suit/wizard
	display_name = "Wizard robes"
	path = /obj/item/clothing/suit/wizrobe/fake

//Tracksuits

/datum/gear/suit/tracksuit
	display_name = "Tracksuit"
	path = /obj/item/clothing/suit/tracksuit

/datum/gear/suit/tracksuitgreen
		display_name = "Tracksuit, green"
		path = /obj/item/clothing/suit/tracksuit/green

/datum/gear/suit/tracksuitred
	display_name = "Tracksuit, red"
	path = /obj/item/clothing/suit/tracksuit/red

/datum/gear/suit/tracksuitwhite
	display_name = "Tracksuit, white"
	path = /obj/item/clothing/suit/tracksuit/white

// Chaplain
/datum/gear/suit/job/chaplain
	main_typepath = /datum/gear/suit/job/chaplain

/datum/gear/suit/job/chaplain/dark_robes
	display_name = "Dark robes"
	path = /obj/item/clothing/suit/hooded/dark_robes
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/cassock
	display_name = "Chaplain, cassock"
	path = /obj/item/clothing/suit/hooded/chaplain_cassock
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/nun
	display_name = "Chaplain, habit"
	path = /obj/item/clothing/suit/hooded/nun
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/monk
	display_name = "Chaplain, monk robes"
	path = /obj/item/clothing/suit/hooded/monk
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/bana
	display_name = "Chaplain, bana"
	path = /obj/item/clothing/suit/bana
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/joue
	display_name = "Chaplain, joue"
	path = /obj/item/clothing/suit/joue
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/miko
	display_name = "Chaplain, miko clothing"
	path = /obj/item/clothing/suit/miko
	allowed_roles = list("Chaplain")

/datum/gear/suit/job/chaplain/hasidic_coat
	display_name = "Chaplain, hasidic coat"
	path = /obj/item/clothing/suit/hasidic_coat
	allowed_roles = list("Chaplain")
