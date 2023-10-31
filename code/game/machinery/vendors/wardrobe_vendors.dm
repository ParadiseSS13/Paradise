//Departmental clothing vendors

/obj/machinery/economy/vending/secdrobe
	name = "\improper SecDrobe"
	desc = "A vending machine for security and security-related clothing!"
	icon_state = "secdrobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Beat perps in style!",
					"It's red so you can't see the blood!",
					"You have the right to be fashionable!",
					"Now you can be the fashion police you always wanted to be!")

	vend_reply = "Thank you for using the SecDrobe!"
	products = list(/obj/item/clothing/under/rank/security/officer/corporate = 4,
					/obj/item/clothing/under/rank/security/officer/skirt/corporate = 4,
					/obj/item/clothing/under/rank/security/officer/dispatch = 4,
					/obj/item/clothing/under/rank/security/officer/skirt = 4,
					/obj/item/clothing/under/rank/security/officer = 4,
					/obj/item/clothing/under/rank/security/officer/uniform = 4,
					/obj/item/clothing/under/rank/security/formal = 4,
					/obj/item/clothing/under/rank/security/officer/fancy = 4,
					/obj/item/clothing/under/rank/security/officer/skirt/fancy = 4,
					/obj/item/clothing/head/soft/sec/corp = 4,
					/obj/item/clothing/head/officer = 4,
					/obj/item/clothing/head/beret/sec = 4,
					/obj/item/clothing/head/soft/sec = 4,
					/obj/item/clothing/head/drillsgt = 4,
					/obj/item/clothing/mask/bandana/red = 4,
					/obj/item/clothing/mask/balaclava = 1,
					/obj/item/clothing/mask/gas/sechailer/swat = 2,
					/obj/item/clothing/suit/jacket/secbomber = 2,
					/obj/item/clothing/suit/armor/secjacket = 4,
					/obj/item/clothing/suit/hooded/wintercoat/security = 4,
					/obj/item/clothing/shoes/jackboots = 4,
					/obj/item/clothing/shoes/jackboots/jacksandals = 4,
					/obj/item/clothing/shoes/laceup = 4,
					/obj/item/storage/backpack/duffel/security = 2,
					/obj/item/storage/backpack/security = 2,
					/obj/item/storage/backpack/satchel_sec = 2,
					/obj/item/clothing/gloves/color/black = 4,
					/obj/item/clothing/accessory/armband/sec = 6)

	contraband = list(/obj/item/clothing/head/helmet/street_judge = 1,
					/obj/item/clothing/suit/armor/vest/street_judge = 1,
					/obj/item/toy/figure/crew/hos = 1,
					/obj/item/toy/figure/crew/secofficer = 1,
					/obj/item/clothing/shoes/jackboots/noisy = 3)

	prices = list(/obj/item/clothing/under/rank/security/officer/corporate = 50,
				/obj/item/clothing/under/rank/security/officer/skirt/corporate = 50,
				/obj/item/clothing/under/rank/security/officer/dispatch = 50,
				/obj/item/clothing/under/rank/security/officer/skirt = 50,
				/obj/item/clothing/under/rank/security/officer = 50,
				/obj/item/clothing/under/rank/security/officer/uniform = 50,
				/obj/item/clothing/under/rank/security/formal = 50,
				/obj/item/clothing/under/rank/security/officer/fancy = 50,
				/obj/item/clothing/under/rank/security/officer/skirt/fancy = 50,
				/obj/item/clothing/head/soft/sec/corp = 40,
				/obj/item/clothing/head/officer = 40,
				/obj/item/clothing/head/beret/sec = 40,
				/obj/item/clothing/head/soft/sec = 40,
				/obj/item/clothing/head/drillsgt = 40,
				/obj/item/clothing/mask/bandana/red = 40,
				/obj/item/clothing/mask/balaclava = 60,
				/obj/item/clothing/mask/gas/sechailer/swat = 60,
				/obj/item/clothing/suit/jacket/secbomber = 75,
				/obj/item/clothing/suit/armor/secjacket = 75,
				/obj/item/clothing/suit/hooded/wintercoat/security = 75,
				/obj/item/clothing/shoes/jackboots = 20,
				/obj/item/clothing/shoes/jackboots/jacksandals = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/head/helmet/street_judge = 75,
				/obj/item/clothing/suit/armor/vest/street_judge = 100,
				/obj/item/storage/backpack/duffel/security = 50,
				/obj/item/storage/backpack/security = 50,
				/obj/item/storage/backpack/satchel_sec = 50,
				/obj/item/clothing/gloves/color/black = 20,
				/obj/item/clothing/accessory/armband/sec = 20,
				/obj/item/clothing/shoes/jackboots/noisy = 200)

	refill_canister = /obj/item/vending_refill/secdrobe

/obj/machinery/economy/vending/detdrobe
	name = "\improper DetDrobe"
	desc = "A machine for all your detective needs, as long as you only need clothes."
	icon_state = "detdrobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Apply your brilliant deductive methods in style!",
					"They already smell of cigarettes!")

	vend_reply = "Thank you for using the DetDrobe!"
	products = list(/obj/item/clothing/under/rank/security/detective = 2,
					/obj/item/clothing/under/rank/security/detective/black = 1,
					/obj/item/clothing/under/rank/security/detective/skirt = 1,
					/obj/item/clothing/suit/storage/det_suit = 2,
					/obj/item/clothing/suit/storage/det_suit/forensics/red = 1,
					/obj/item/clothing/suit/storage/det_suit/forensics/blue = 1,
					/obj/item/clothing/suit/storage/det_suit/forensics/black = 1,
					/obj/item/clothing/suit/armor/vest/det_suit = 1,
					/obj/item/clothing/glasses/sunglasses/noir = 2,
					/obj/item/clothing/head/det_hat = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/brown = 2,
					/obj/item/clothing/shoes/jackboots = 2,
					/obj/item/clothing/head/fedora = 1,
					/obj/item/clothing/head/fedora/brownfedora = 1,
					/obj/item/clothing/head/fedora/whitefedora = 1,
					/obj/item/clothing/gloves/color/black = 2,
					/obj/item/clothing/gloves/color/latex = 2,
					/obj/item/reagent_containers/food/drinks/flask/detflask = 2,
					/obj/item/storage/fancy/cigarettes/dromedaryco = 5)

	prices = list(/obj/item/clothing/under/rank/security/detective = 50,
				/obj/item/clothing/under/rank/security/detective/black = 75,
				/obj/item/clothing/under/rank/security/detective/skirt = 75,
				/obj/item/clothing/suit/storage/det_suit = 75,
				/obj/item/clothing/suit/storage/det_suit/forensics/red = 75,
				/obj/item/clothing/suit/storage/det_suit/forensics/blue = 75,
				/obj/item/clothing/suit/storage/det_suit/forensics/black = 75,
				/obj/item/clothing/suit/armor/vest/det_suit = 75,
				/obj/item/clothing/head/det_hat = 40,
				/obj/item/clothing/glasses/sunglasses/noir = 30,
				/obj/item/clothing/accessory/waistcoat = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/brown = 20,
				/obj/item/clothing/shoes/jackboots = 20,
				/obj/item/clothing/head/fedora = 20,
				/obj/item/clothing/head/fedora/brownfedora = 20,
				/obj/item/clothing/head/fedora/whitefedora = 20,
				/obj/item/clothing/gloves/color/black = 20,
				/obj/item/clothing/gloves/color/latex = 20,
				/obj/item/reagent_containers/food/drinks/flask/detflask = 50,
				/obj/item/storage/fancy/cigarettes/dromedaryco = 5)

	contraband = list(/obj/item/toy/figure/crew/detective = 1)

	refill_canister = /obj/item/vending_refill/detdrobe

/obj/machinery/economy/vending/medidrobe
	name = "\improper MediDrobe"
	desc = "A vending machine rumoured to be capable of dispensing clothing for medical personnel."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "medidrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Make those blood stains look fashionable!")

	vend_reply = "Thank you for using the MediDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/doctor = 3,
					/obj/item/clothing/under/rank/medical/doctor/skirt = 3,
					/obj/item/clothing/under/rank/medical/scrubs = 3,
					/obj/item/clothing/under/rank/medical/scrubs/green = 3,
					/obj/item/clothing/under/rank/medical/scrubs/purple = 3,
					/obj/item/clothing/under/rank/medical/nurse = 3,
					/obj/item/clothing/under/rank/medical/gown = 3,
					/obj/item/clothing/head/beret/med = 3,
					/obj/item/clothing/head/surgery/blue = 3,
					/obj/item/clothing/head/surgery/green = 3,
					/obj/item/clothing/head/surgery/purple = 3,
					/obj/item/clothing/head/nursehat = 3,
					/obj/item/clothing/head/headmirror = 3,
					/obj/item/clothing/suit/hooded/wintercoat/medical = 3,
					/obj/item/clothing/suit/storage/fr_jacket = 3,
					/obj/item/clothing/suit/storage/labcoat = 3,
					/obj/item/clothing/suit/apron/surgical = 3,
					/obj/item/clothing/accessory/armband/med = 3,
					/obj/item/clothing/accessory/armband/medgreen = 3,
					/obj/item/clothing/shoes/laceup = 3,
					/obj/item/clothing/shoes/white = 3,
					/obj/item/clothing/shoes/sandal/white = 3,
					/obj/item/storage/backpack/medic = 2,
					/obj/item/storage/backpack/satchel_med = 2,
					/obj/item/storage/backpack/duffel/medical = 2,
					/obj/item/clothing/gloves/color/latex/nitrile = 3)

	contraband = list(/obj/item/toy/figure/crew/md = 1)

	prices = list(/obj/item/clothing/under/rank/medical/doctor = 50,
				/obj/item/clothing/under/rank/medical/doctor/skirt = 50,
				/obj/item/clothing/under/rank/medical/scrubs = 50,
				/obj/item/clothing/under/rank/medical/scrubs/green = 50,
				/obj/item/clothing/under/rank/medical/scrubs/purple = 50,
				/obj/item/clothing/under/rank/medical/nurse = 50,
				/obj/item/clothing/under/rank/medical/gown = 50,
				/obj/item/clothing/head/beret/med = 20,
				/obj/item/clothing/head/surgery/blue = 20,
				/obj/item/clothing/head/surgery/green = 20,
				/obj/item/clothing/head/surgery/purple = 20,
				/obj/item/clothing/head/nursehat = 20,
				/obj/item/clothing/head/headmirror = 20,
				/obj/item/clothing/suit/hooded/wintercoat/medical = 75,
				/obj/item/clothing/suit/storage/fr_jacket = 75,
				/obj/item/clothing/suit/storage/labcoat = 75,
				/obj/item/clothing/suit/apron/surgical = 75,
				/obj/item/clothing/accessory/armband/med = 20,
				/obj/item/clothing/accessory/armband/medgreen = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/sandal/white = 20,
				/obj/item/storage/backpack/medic = 50,
				/obj/item/storage/backpack/satchel_med = 50,
				/obj/item/storage/backpack/duffel/medical = 50,
				/obj/item/clothing/gloves/color/latex/nitrile = 50)

	refill_canister = /obj/item/vending_refill/medidrobe

/obj/machinery/economy/vending/virodrobe
	name = "\improper ViroDrobe"
	desc = "An unsterilized machine for dispending virology related clothing."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "virodrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Viruses getting you down? Nothing a change of clothes can't fix!",
					"Upgrade to sterilized clothing today!")

	vend_reply = "Thank you for using the ViroDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/virologist = 2,
					/obj/item/clothing/under/rank/medical/virologist/skirt = 2,
					/obj/item/clothing/head/beret/med = 2,
					/obj/item/clothing/suit/storage/labcoat/virologist = 2,
					/obj/item/clothing/accessory/armband/med = 2,
					/obj/item/clothing/mask/surgical = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/white = 2,
					/obj/item/clothing/shoes/sandal/white = 2,
					/obj/item/storage/backpack/virology = 2,
					/obj/item/storage/backpack/satchel_vir = 2,
					/obj/item/storage/backpack/duffel/virology = 2)

	contraband = list(/obj/item/toy/figure/crew/virologist = 1)

	prices = list(/obj/item/clothing/under/rank/medical/virologist = 50,
				/obj/item/clothing/under/rank/medical/virologist/skirt = 50,
				/obj/item/clothing/head/beret/med = 20,
				/obj/item/clothing/suit/storage/labcoat/virologist = 75,
				/obj/item/clothing/accessory/armband/med = 20,
				/obj/item/clothing/mask/surgical = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/sandal/white = 20,
				/obj/item/storage/backpack/virology = 50,
				/obj/item/storage/backpack/satchel_vir = 50,
				/obj/item/storage/backpack/duffel/virology = 50)

	refill_canister = /obj/item/vending_refill/virodrobe

/obj/machinery/economy/vending/chemdrobe
	name = "\improper ChemDrobe"
	desc = "A vending machine for dispensing chemistry related clothing."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "chemdrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Our clothes are 0.5% more resistant to acid spills! Get yours now!")
	vend_reply = "Thank you for using the ChemDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/chemist = 2,
					/obj/item/clothing/under/rank/medical/chemist/skirt = 2,
					/obj/item/clothing/head/beret/med = 2,
					/obj/item/clothing/suit/storage/labcoat/chemist = 2,
					/obj/item/clothing/accessory/armband/med = 2,
					/obj/item/clothing/mask/gas = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/white = 2,
					/obj/item/clothing/shoes/sandal/white = 2,
					/obj/item/storage/bag/chemistry = 2,
					/obj/item/storage/backpack/chemistry = 2,
					/obj/item/storage/backpack/satchel_chem = 2,
					/obj/item/storage/backpack/duffel/chemistry = 2)

	prices = list(/obj/item/clothing/under/rank/medical/chemist = 50,
				/obj/item/clothing/under/rank/medical/chemist/skirt = 50,
				/obj/item/clothing/head/beret/med = 20,
				/obj/item/clothing/suit/storage/labcoat/chemist = 75,
				/obj/item/clothing/accessory/armband/med = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/sandal/white = 20,
				/obj/item/storage/backpack/chemistry = 50,
				/obj/item/storage/backpack/satchel_chem = 50,
				/obj/item/storage/backpack/duffel/chemistry = 50)

	contraband = list(/obj/item/toy/figure/crew/chemist = 1)

	refill_canister = /obj/item/vending_refill/chemdrobe

/obj/machinery/economy/vending/genedrobe
	name = "\improper GeneDrobe"
	desc = "A machine for dispensing clothing related to genetics."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "genedrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = "Perfect for the mad scientist in you!"
	vend_reply = "Thank you for using the GeneDrobe!"
	products = list(/obj/item/clothing/under/rank/rnd/geneticist = 3,
					/obj/item/clothing/suit/storage/labcoat/genetics = 3,
					/obj/item/clothing/shoes/laceup = 3,
					/obj/item/clothing/shoes/white = 3,
					/obj/item/clothing/shoes/sandal/white = 3,
					/obj/item/storage/backpack/genetics = 2,
					/obj/item/storage/backpack/satchel_gen = 2,
					/obj/item/storage/backpack/duffel/genetics = 2)

	contraband = list(/obj/item/toy/figure/crew/geneticist = 1)

	prices = list(/obj/item/clothing/under/rank/rnd/geneticist = 50,
				/obj/item/clothing/suit/storage/labcoat/genetics = 75,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/sandal/white = 20,
				/obj/item/storage/backpack/genetics = 50,
				/obj/item/storage/backpack/satchel_gen = 50,
				/obj/item/storage/backpack/duffel/genetics = 50)

	refill_canister = /obj/item/vending_refill/genedrobe


/obj/machinery/economy/vending/scidrobe
	name = "\improper SciDrobe"
	desc = "A simple vending machine suitable to dispense well tailored science clothing. Endorsed by Space Cubans."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "scidrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Longing for the smell of plasma burnt flesh?",
					"Buy your science clothing now!",
					"Made with 10% Auxetics, so you don't have to worry about losing your arm!")

	vend_reply = "Thank you for using the SciDrobe!"
	products = list(/obj/item/clothing/under/rank/rnd/scientist = 6,
					/obj/item/clothing/under/rank/rnd/scientist/skirt = 3,
					/obj/item/clothing/suit/hooded/wintercoat/science = 3,
					/obj/item/clothing/suit/storage/labcoat/science = 3,
					/obj/item/clothing/head/beret/sci = 3,
					/obj/item/clothing/accessory/armband/science = 6,
					/obj/item/clothing/shoes/laceup = 3,
					/obj/item/clothing/shoes/white = 3,
					/obj/item/clothing/shoes/sandal/white = 3,
					/obj/item/storage/backpack/science = 2,
					/obj/item/storage/backpack/satchel_tox = 2,
					/obj/item/storage/backpack/duffel/science = 2)

	contraband = list(/obj/item/toy/figure/crew/rd = 1,
					/obj/item/toy/figure/crew/scientist = 1)

	prices = list(/obj/item/clothing/under/rank/rnd/scientist = 50,
				/obj/item/clothing/under/rank/rnd/scientist/skirt = 50,
				/obj/item/clothing/suit/hooded/wintercoat/science = 75,
				/obj/item/clothing/suit/storage/labcoat/science = 75,
				/obj/item/clothing/head/beret/sci = 20,
				/obj/item/clothing/accessory/armband/science = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/sandal/white = 20,
				/obj/item/storage/backpack/science = 50,
				/obj/item/storage/backpack/satchel_tox = 50,
				/obj/item/storage/backpack/duffel/science = 50)

	refill_canister = /obj/item/vending_refill/scidrobe

/obj/machinery/economy/vending/robodrobe
	name = "\improper RoboDrobe"
	desc = "A vending machine designed to dispense clothing known only to roboticists."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "robodrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("You turn me TRUE, use defines!",
					"01000011011011000110111101110100011010000110010101110011001000000110100001100101011100100110010100100001") //This translates to "Clothes here!"

	vend_reply = "Thank you for using the RoboDrobe!"
	products = list(/obj/item/clothing/under/rank/rnd/roboticist = 3,
					/obj/item/clothing/under/rank/rnd/roboticist/skirt = 3,
					/obj/item/clothing/suit/storage/labcoat/roboblack = 3,
					/obj/item/clothing/suit/storage/labcoat/robowhite = 3,
					/obj/item/clothing/head/beret/roboblack = 3,
					/obj/item/clothing/head/beret/robowhite = 3,
					/obj/item/clothing/head/soft/black = 3,
					/obj/item/clothing/gloves/fingerless = 3,
					/obj/item/clothing/shoes/laceup = 3,
					/obj/item/clothing/shoes/white = 3,
					/obj/item/clothing/shoes/black = 3)

	contraband = list(/obj/item/toy/figure/crew/roboticist = 1,
					/obj/item/toy/figure/crew/borg = 1)

	prices = list(/obj/item/clothing/under/rank/rnd/roboticist = 50,
				/obj/item/clothing/under/rank/rnd/roboticist/skirt = 50,
				/obj/item/clothing/suit/storage/labcoat/roboblack = 75,
				/obj/item/clothing/suit/storage/labcoat/robowhite = 75,
				/obj/item/clothing/head/beret/roboblack = 20,
				/obj/item/clothing/head/beret/robowhite = 20,
				/obj/item/clothing/head/soft/black = 20,
				/obj/item/clothing/gloves/fingerless = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/black = 20)

	refill_canister = /obj/item/vending_refill/robodrobe

/obj/machinery/economy/vending/engidrobe
	name = "\improper EngiDrobe"
	desc = "A vending machine renowned for vending industrial grade clothing."
	icon_state = "yellow_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "engidrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Guaranteed to protect your feet from industrial accidents!",
					"Afraid of radiation? Then wear yellow!")

	vend_reply = "Thank you for using the EngiDrobe!"
	products = list(/obj/item/clothing/under/rank/engineering/engineer = 6,
					/obj/item/clothing/under/rank/engineering/engineer/skirt = 3,
					/obj/item/clothing/suit/hooded/wintercoat/engineering = 3,
					/obj/item/clothing/suit/jacket/engibomber = 3,
					/obj/item/clothing/suit/storage/hazardvest = 3,
					/obj/item/clothing/head/beret/eng = 3,
					/obj/item/clothing/head/hardhat = 2,
					/obj/item/clothing/head/hardhat/orange = 2,
					/obj/item/clothing/head/hardhat/dblue = 2,
					/obj/item/clothing/accessory/armband/engine = 6,
					/obj/item/clothing/shoes/laceup = 3,
					/obj/item/clothing/shoes/workboots = 3,
					/obj/item/storage/backpack/industrial = 2,
					/obj/item/storage/backpack/satchel_eng = 2,
					/obj/item/storage/backpack/duffel/engineering = 2,
					/obj/item/clothing/gloves/color/yellow = 2,
					/obj/item/storage/belt/utility = 2)

	contraband = list(/obj/item/toy/figure/crew/ce = 1,
					/obj/item/toy/figure/crew/engineer = 1)

	prices = list(/obj/item/clothing/under/rank/engineering/engineer = 50,
				/obj/item/clothing/under/rank/engineering/engineer/skirt = 50,
				/obj/item/clothing/suit/hooded/wintercoat/engineering = 75,
				/obj/item/clothing/suit/jacket/engibomber = 75,
				/obj/item/clothing/suit/storage/hazardvest = 75,
				/obj/item/clothing/head/beret/eng = 20,
				/obj/item/clothing/head/hardhat = 20,
				/obj/item/clothing/head/hardhat/orange = 30,
				/obj/item/clothing/head/hardhat/dblue = 30,
				/obj/item/clothing/accessory/armband/engine = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/workboots = 20,
				/obj/item/storage/backpack/industrial = 50,
				/obj/item/storage/backpack/satchel_eng = 50,
				/obj/item/storage/backpack/duffel/engineering = 50,
				/obj/item/clothing/gloves/color/yellow = 250,
				/obj/item/storage/belt/utility = 75)

	refill_canister = /obj/item/vending_refill/engidrobe

/obj/machinery/economy/vending/atmosdrobe
	name = "\improper AtmosDrobe"
	desc = "This relatively unknown vending machine delivers clothing for Atmospherics Technicians, an equally unknown job."
	icon_state = "yellow_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "atmosdrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Guaranteed to protect your feet from atmospheric accidents!",
					"Get your inflammable clothing right here!")

	vend_reply = "Thank you for using the AtmosDrobe!"
	products = list(/obj/item/clothing/under/rank/engineering/atmospheric_technician  = 6,
					/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt = 3,
					/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 3,
					/obj/item/clothing/suit/jacket/atmosbomber = 3,
					/obj/item/clothing/suit/storage/hazardvest = 3,
					/obj/item/clothing/head/beret/atmos = 3,
					/obj/item/clothing/head/hardhat = 2,
					/obj/item/clothing/head/hardhat/red = 2,
					/obj/item/clothing/head/hardhat/orange = 2,
					/obj/item/clothing/head/hardhat/dblue = 2,
					/obj/item/clothing/gloves/color/black = 3,
					/obj/item/clothing/accessory/armband/engine = 3,
					/obj/item/clothing/shoes/laceup = 3,
					/obj/item/clothing/shoes/workboots = 3,
					/obj/item/storage/backpack/industrial/atmos = 2,
					/obj/item/storage/backpack/satchel_atmos = 2,
					/obj/item/storage/backpack/duffel/atmos = 2,
					/obj/item/storage/belt/utility = 2)

	contraband = list(/obj/item/toy/figure/crew/atmos = 1)

	prices = list(/obj/item/clothing/under/rank/engineering/atmospheric_technician = 50,
				/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt = 50,
				/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 75,
				/obj/item/clothing/suit/jacket/atmosbomber = 75,
				/obj/item/clothing/suit/storage/hazardvest = 50,
				/obj/item/clothing/head/beret/atmos = 20,
				/obj/item/clothing/head/hardhat = 20,
				/obj/item/clothing/head/hardhat/red = 30,
				/obj/item/clothing/head/hardhat/orange = 30,
				/obj/item/clothing/head/hardhat/dblue = 30,
				/obj/item/clothing/gloves/color/black = 20,
				/obj/item/clothing/accessory/armband/engine = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/workboots = 30,
				/obj/item/storage/backpack/industrial/atmos = 50,
				/obj/item/storage/backpack/satchel_atmos = 50,
				/obj/item/storage/backpack/duffel/atmos = 50,
				/obj/item/storage/belt/utility = 75)

	refill_canister = /obj/item/vending_refill/atmosdrobe

/obj/machinery/economy/vending/cargodrobe
	name = "\improper CargoDrobe"
	desc = "A highly advanced vending machine for buying cargo related clothing for free... most of the time."
	icon_state = "yellow_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "cargodrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Upgraded Assistant Style! Pick yours today!",
					"These shorts are comfy and easy to wear, get yours now!")

	vend_reply = "Thank you for using the CargoDrobe!"
	products = list(/obj/item/clothing/under/rank/cargo/tech = 6,
					/obj/item/clothing/under/rank/cargo/tech/skirt = 3,
					/obj/item/clothing/under/rank/cargo/deliveryboy = 2,
					/obj/item/clothing/head/soft/deliverysoft = 2,
					/obj/item/clothing/suit/hooded/wintercoat/cargo = 3,
					/obj/item/clothing/suit/jacket/cargobomber = 3,
					/obj/item/clothing/suit/storage/hazardvest = 3,
					/obj/item/clothing/head/soft = 3,
					/obj/item/clothing/head/hardhat/orange = 2,
					/obj/item/clothing/gloves/fingerless = 6,
					/obj/item/clothing/accessory/armband/cargo = 6,
					/obj/item/clothing/shoes/black = 3,
					/obj/item/clothing/shoes/workboots = 3)

	contraband = list(/obj/item/toy/figure/crew/qm = 1,
					/obj/item/toy/figure/crew/cargotech = 1)

	prices = list(/obj/item/clothing/under/rank/cargo/tech = 50,
				/obj/item/clothing/under/rank/cargo/tech/skirt = 50,
				/obj/item/clothing/under/rank/cargo/deliveryboy = 100,
				/obj/item/clothing/head/soft/deliverysoft = 50,
				/obj/item/clothing/suit/hooded/wintercoat/cargo = 75,
				/obj/item/clothing/suit/jacket/cargobomber = 75,
				/obj/item/clothing/suit/storage/hazardvest = 50,
				/obj/item/clothing/head/soft = 20,
				/obj/item/clothing/head/hardhat/orange = 30,
				/obj/item/clothing/gloves/fingerless = 20,
				/obj/item/clothing/accessory/armband/cargo = 20,
				/obj/item/clothing/shoes/black = 20,
				/obj/item/clothing/shoes/workboots = 20)

	refill_canister = /obj/item/vending_refill/cargodrobe

/obj/machinery/economy/vending/chefdrobe
	name = "\improper ChefDrobe"
	desc = "This vending machine might not dispense meat, but it certainly dispenses chef related clothing."
	icon_state = "base_drobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_addon = "chefdrobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Our clothes are guaranteed to protect you from food splatters!",
					"Comfortable enough for a CQC practice!")

	vend_reply = "Thank you for using the ChefDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/chef = 2,
					/obj/item/clothing/under/misc/waiter = 2,
					/obj/item/clothing/suit/chef = 2,
					/obj/item/clothing/suit/chef/classic = 2,
					/obj/item/clothing/head/chefhat = 2,
					/obj/item/clothing/head/soft/mime = 2,
					/obj/item/clothing/head/beret/white = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/white = 2,
					/obj/item/clothing/shoes/black = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/reagent_containers/glass/rag = 3,
					/obj/item/storage/box/dish_drive = 1)

	contraband = list(/obj/item/toy/figure/crew/chef = 1)

	prices = list(/obj/item/clothing/under/rank/civilian/chef = 50,
				/obj/item/clothing/under/misc/waiter = 50,
				/obj/item/clothing/suit/chef = 50,
				/obj/item/clothing/suit/chef/classic = 50,
				/obj/item/clothing/head/chefhat = 50,
				/obj/item/clothing/head/soft/mime = 30,
				/obj/item/clothing/head/beret/white = 20,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/black = 20,
				/obj/item/clothing/accessory/waistcoat = 20,
				/obj/item/reagent_containers/glass/rag = 5,
				/obj/item/storage/box/dish_drive = 100)

	refill_canister = /obj/item/vending_refill/chefdrobe

/obj/machinery/economy/vending/bardrobe
	name = "\improper BarDrobe"
	desc = "A stylish vendor to dispense the most stylish bar clothing!"
	icon_state = "bardrobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Guaranteed to prevent stains from spilled drinks!")

	vend_reply = "Thank you for using the BarDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/bartender = 2,
					/obj/item/clothing/under/misc/sl_suit = 2,
					/obj/item/clothing/head/that = 2,
					/obj/item/clothing/head/soft/black = 2,
					/obj/item/clothing/head/beret/black = 2,
					/obj/item/clothing/suit/blacktrenchcoat = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/black = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/reagent_containers/glass/rag = 3,
					/obj/item/storage/box/dish_drive = 1)

	contraband = list(/obj/item/toy/figure/crew/bartender = 1)

	prices = list(/obj/item/clothing/under/rank/civilian/bartender = 50,
				/obj/item/clothing/under/misc/sl_suit = 50,
				/obj/item/clothing/head/that = 20,
				/obj/item/clothing/head/soft/black = 20,
				/obj/item/clothing/head/beret/black = 20,
				/obj/item/clothing/suit/blacktrenchcoat = 75,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/black = 20,
				/obj/item/clothing/accessory/waistcoat = 20,
				/obj/item/reagent_containers/glass/rag = 5,
				/obj/item/storage/box/dish_drive = 100)

	refill_canister = /obj/item/vending_refill/bardrobe

/obj/machinery/economy/vending/hydrodrobe
	name = "\improper HydroDrobe"
	desc = "A machine with a catchy name. It dispenses botany related clothing and gear."
	icon_state = "hydrobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Do you love soil? Then buy our clothes!",
					"Get outfits to match your green thumb here!")

	vend_reply = "Thank you for using the HydroDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/hydroponics = 3,
					/obj/item/reagent_containers/glass/bucket = 3,
					/obj/item/clothing/suit/apron = 3,
					/obj/item/clothing/suit/apron/overalls = 3,
					/obj/item/clothing/suit/hooded/wintercoat/hydro = 3,
					/obj/item/clothing/suit/storage/labcoat/hydro = 3,
					/obj/item/clothing/mask/bandana/botany = 3,
					/obj/item/clothing/accessory/armband/hydro = 3,
					/obj/item/storage/backpack/botany = 2,
					/obj/item/storage/backpack/satchel_hyd = 2,
					/obj/item/storage/backpack/duffel/hydro = 2)

	contraband = list(/obj/item/toy/figure/crew/botanist = 1)

	prices = list(/obj/item/clothing/under/rank/civilian/hydroponics = 50,
				/obj/item/reagent_containers/glass/bucket = 15,
				/obj/item/clothing/suit/apron = 50,
				/obj/item/clothing/suit/apron/overalls = 50,
				/obj/item/clothing/suit/hooded/wintercoat/hydro = 75,
				/obj/item/clothing/suit/storage/labcoat/hydro = 75,
				/obj/item/clothing/mask/bandana/botany = 20,
				/obj/item/clothing/accessory/armband/hydro = 20,
				/obj/item/storage/backpack/botany = 50,
				/obj/item/storage/backpack/satchel_hyd = 50,
				/obj/item/storage/backpack/duffel/hydro = 50)

	refill_canister = /obj/item/vending_refill/hydrodrobe

/obj/machinery/economy/vending/janidrobe
	name = "\improper JaniDrobe"
	desc = "A self cleaning vending machine capable of dispensing clothing for janitors."
	icon_state = "janidrobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_broken = "base_drobe"
	icon_off = "base_drobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("Come and get your janitorial clothing, now endorsed by janitors everywhere!")

	vend_reply = "Thank you for using the JaniDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/janitor = 3,
					/obj/item/clothing/head/soft/purple = 3,
					/obj/item/clothing/gloves/color/black = 3,
					/obj/item/clothing/shoes/galoshes = 3,
					/obj/item/storage/belt/janitor = 3)

	contraband = list(/obj/item/toy/figure/crew/janitor = 1)

	prices = list(/obj/item/clothing/under/rank/civilian/janitor = 50)

	refill_canister = /obj/item/vending_refill/janidrobe

/obj/machinery/economy/vending/lawdrobe
	name = "\improper LawDrobe"
	desc = "Objection! This wardrobe dispenses the rule of law... and lawyer clothing."
	icon_state = "lawdrobe"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	icon_broken = "base_drobe"
	icon_off = "base_drobe"
	category = VENDOR_TYPE_CLOTHING
	ads_list = list("OBJECTION! Get the rule of law for yourself!")

	vend_reply = "Thank you for using the LawDrobe!"
	products = list(/obj/item/clothing/under/rank/procedure/iaa = 2,
					/obj/item/clothing/under/rank/procedure/iaa/blue = 2,
					/obj/item/clothing/under/rank/procedure/iaa/purple = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/black = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/black/skirt = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/red = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/red/skirt = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/blue = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/blue/skirt = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/goodman = 2,
					/obj/item/clothing/under/rank/procedure/lawyer/goodman/skirt = 2,
					/obj/item/clothing/under/suit/female = 2,
					/obj/item/clothing/suit/storage/iaa/blackjacket = 2,
					/obj/item/clothing/suit/storage/iaa/bluejacket = 2,
					/obj/item/clothing/suit/storage/iaa/purplejacket = 2,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/black = 2,
					/obj/item/clothing/shoes/brown = 2,
					/obj/item/clothing/glasses/sunglasses/big = 2,
					/obj/item/clothing/accessory/lawyers_badge = 2,
					/obj/item/clothing/accessory/armband/procedure = 2)

	contraband = list(/obj/item/toy/figure/crew/lawyer = 1)

	prices = list(/obj/item/clothing/under/rank/procedure/iaa = 50,
				/obj/item/clothing/under/rank/procedure/iaa/blue = 50,
				/obj/item/clothing/under/rank/procedure/iaa/purple = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/black = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/black/skirt = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/red = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/red/skirt = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/blue = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/blue/skirt = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/goodman = 50,
				/obj/item/clothing/under/rank/procedure/lawyer/goodman/skirt = 50,
				/obj/item/clothing/under/suit/female = 50,
				/obj/item/clothing/suit/storage/iaa/blackjacket = 75,
				/obj/item/clothing/suit/storage/iaa/bluejacket = 75,
				/obj/item/clothing/suit/storage/iaa/purplejacket = 75,
				/obj/item/clothing/shoes/laceup = 30,
				/obj/item/clothing/shoes/black = 20,
				/obj/item/clothing/shoes/brown = 20,
				/obj/item/clothing/glasses/sunglasses/big = 30,
				/obj/item/clothing/accessory/lawyers_badge = 50,
				/obj/item/clothing/accessory/armband/procedure = 20)

	refill_canister = /obj/item/vending_refill/lawdrobe
