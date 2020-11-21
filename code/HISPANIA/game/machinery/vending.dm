//HISPANIA VENDING
/obj/machinery/vending
	var/list/hispa_products = list()
	var/list/hispa_contraband = list()
	var/list/hispa_premium = list()
	var/list/hispa_prices = list()
///Hispania Civilians Clothes

/obj/machinery/vending/proc/make_products()
	products |= hispa_products	// For each, use the following pattern:
	contraband |= hispa_contraband	// list(/type/path = amount,/type/path2 = amount2)
	premium |= hispa_premium
	prices |= hispa_prices

/obj/machinery/vending/boozeomat
	hispa_products = list(/obj/item/reagent_containers/food/drinks/bottle/hispania/fernet = 5,
					/obj/item/reagent_containers/food/drinks/bottle/hispania/mezcal = 5)
	hispa_contraband = list(/obj/item/reagent_containers/food/drinks/bottle/hispania/vampire_bestfriend = 5)

/obj/machinery/vending/coffee
	hispa_products = list(/obj/item/reagent_containers/food/drinks/cans/mr_coffe_brown = 10)
	hispa_prices = list(/obj/item/reagent_containers/food/drinks/cans/mr_coffe_brown = 25)

/obj/machinery/vending/security
	hispa_products = list(/obj/item/taperoll = 8, /obj/item/device/binoculars/security = 2)

/obj/machinery/vending/tool
	hispa_products = list(/obj/item/taperoll/engi = 10)

//este vending es gratis en paradise
/obj/machinery/vending/clothing
	hispa_products = list(/obj/item/clothing/under/suit_jacket = 2,
					/obj/item/clothing/under/suit_jacket/red = 2,
					/obj/item/clothing/under/suit_jacket/tan = 2,
					/obj/item/clothing/under/suit_jacket/burgundy = 2,
					/obj/item/clothing/under/suit_jacket/charcoal = 2)

	hispa_prices = list(/obj/item/clothing/head/that = 50,
					/obj/item/clothing/head/fedora = 200,
					/obj/item/clothing/glasses/monocle = 100,
					/obj/item/clothing/under/kilt = 200,
					/obj/item/clothing/under/overalls = 200,
					/obj/item/clothing/suit/storage/lawyer/blackjacket = 200,
					/obj/item/clothing/under/suit_jacket/navy = 300,
					/obj/item/clothing/under/suit_jacket/really_black = 300,
					/obj/item/clothing/under/suit_jacket = 300,
					/obj/item/clothing/under/suit_jacket/red = 300,
					/obj/item/clothing/under/suit_jacket/tan = 300,
					/obj/item/clothing/under/suit_jacket/burgundy = 300,
					/obj/item/clothing/under/suit_jacket/charcoal = 200,
					/obj/item/clothing/under/suit_jacket/checkered = 200,
					/obj/item/clothing/under/pants/jeans = 60,
					/obj/item/clothing/under/pants/classicjeans = 80,
					/obj/item/clothing/under/pants/camo = 75,
					/obj/item/clothing/under/pants/blackjeans = 50,
					/obj/item/clothing/under/pants/khaki = 89,
					/obj/item/clothing/under/pants/white = 59,
					/obj/item/clothing/under/pants/red = 52,
					/obj/item/clothing/under/pants/black = 52,
					/obj/item/clothing/under/pants/tan = 62,
					/obj/item/clothing/under/pants/blue = 64,
					/obj/item/clothing/under/pants/track = 63,
					/obj/item/clothing/suit/jacket/miljacket = 300,
					/obj/item/clothing/head/beanie = 50,
					/obj/item/clothing/head/beanie/black = 50,
					/obj/item/clothing/head/beanie/red = 50,
					/obj/item/clothing/head/beanie/green = 50,
					/obj/item/clothing/head/beanie/darkblue = 50,
					/obj/item/clothing/head/beanie/purple = 50,
					/obj/item/clothing/head/beanie/yellow = 50,
					/obj/item/clothing/head/beanie/orange = 50,
					/obj/item/clothing/head/beanie/cyan = 50,
					/obj/item/clothing/head/beanie/christmas = 60,
					/obj/item/clothing/head/beanie/striped = 62,
					/obj/item/clothing/head/beanie/stripedred = 62,
					/obj/item/clothing/head/beanie/stripedblue = 62,
					/obj/item/clothing/head/beanie/stripedgreen = 62,
					/obj/item/clothing/head/beanie/rasta = 420,
					/obj/item/clothing/accessory/scarf/red = 45,
					/obj/item/clothing/accessory/scarf/green = 45,
					/obj/item/clothing/accessory/scarf/darkblue = 45,
					/obj/item/clothing/accessory/scarf/purple = 45,
					/obj/item/clothing/accessory/scarf/yellow = 45,
					/obj/item/clothing/accessory/scarf/orange = 45,
					/obj/item/clothing/accessory/scarf/lightblue = 45,
					/obj/item/clothing/accessory/scarf/white = 45,
					/obj/item/clothing/accessory/scarf/black = 45,
					/obj/item/clothing/accessory/scarf/zebra = 45,
					/obj/item/clothing/accessory/scarf/christmas = 55,
					/obj/item/clothing/accessory/stripedredscarf = 55,
					/obj/item/clothing/accessory/stripedbluescarf = 55,
					/obj/item/clothing/accessory/stripedgreenscarf = 55,
					/obj/item/clothing/accessory/waistcoat = 75,
					/obj/item/clothing/under/sundress = 210,
					/obj/item/clothing/under/stripeddress = 150,
					/obj/item/clothing/under/sailordress = 300,
					/obj/item/clothing/under/redeveninggown = 250,
					/obj/item/clothing/under/blacktango = 400,
					/obj/item/clothing/suit/jacket = 300,
					/obj/item/clothing/glasses/regular = 80,
					/obj/item/clothing/glasses/sunglasses_fake = 90,
					/obj/item/clothing/head/sombrero = 50,
					/obj/item/clothing/suit/poncho = 150,
					/obj/item/clothing/suit/ianshirt = 200,
					/obj/item/clothing/shoes/laceup = 80,
					/obj/item/clothing/shoes/black = 80,
					/obj/item/clothing/shoes/sandal = 15,
					/obj/item/clothing/gloves/fingerless = 40,
					/obj/item/storage/belt/fannypack = 30,
					/obj/item/storage/belt/fannypack/blue = 30,
					/obj/item/storage/belt/fannypack/red = 30,
					/obj/item/clothing/suit/mantle = 200,
					/obj/item/clothing/suit/mantle/old = 200,
					/obj/item/clothing/suit/mantle/regal = 200)

//este vending es gratis en paradise
/obj/machinery/vending/artvend
	hispa_prices = list(/obj/item/stack/cable_coil/random = 10,
					/obj/item/camera = 350,
					/obj/item/camera_film = 50,
					/obj/item/storage/photo_album = 200,
					/obj/item/stack/wrapping_paper = 100,
					/obj/item/stack/tape_roll = 30,
					/obj/item/stack/packageWrap = 30,
					/obj/item/storage/fancy/crayons = 500,  ///Just like CM
					/obj/item/hand_labeler = 60,
					/obj/item/c_tube = 50,
					/obj/item/pen = 30,
					/obj/item/pen/blue = 30,
					/obj/item/pen/red = 30,
					/obj/item/paper_bin = 150)

//este vending es gratis en paradise
/obj/machinery/vending/autodrobe
	hispa_prices = list(/obj/item/clothing/suit/chickensuit = 150,
					/obj/item/clothing/head/chicken = 150,
					/obj/item/clothing/under/gladiator = 100,
					/obj/item/clothing/head/helmet/gladiator = 100,
					/obj/item/clothing/under/gimmick/rank/captain/suit = 120,
					/obj/item/clothing/head/flatcap = 50,
					/obj/item/clothing/suit/storage/labcoat/mad = 150,
					/obj/item/clothing/glasses/gglasses = 100,
					/obj/item/clothing/shoes/jackboots = 350,
					/obj/item/clothing/under/schoolgirl = 100,
					/obj/item/clothing/head/kitty = 100,
					/obj/item/clothing/under/blackskirt = 100,
					/obj/item/clothing/suit/toggle/owlwings = 150,
					/obj/item/clothing/under/owl = 150,
					/obj/item/clothing/mask/gas/owl_mask = 150,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 150,
					/obj/item/clothing/under/griffin = 150,
					/obj/item/clothing/shoes/griffin = 150,
					/obj/item/clothing/head/griffin = 150,
					/obj/item/clothing/accessory/waistcoat = 30,
					/obj/item/clothing/under/suit_jacket = 100,
					/obj/item/clothing/head/that = 200,
					/obj/item/clothing/under/kilt = 50,
					/obj/item/clothing/accessory/waistcoat = 30,
					/obj/item/clothing/glasses/monocle = 100,
					/obj/item/clothing/head/bowlerhat = 50,
					/obj/item/cane = 300,
					/obj/item/clothing/under/sl_suit = 100,
					/obj/item/clothing/mask/fakemoustache = 50,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 200,
					/obj/item/clothing/head/plaguedoctorhat = 200,
					/obj/item/clothing/mask/gas/plaguedoctor = 200,
					/obj/item/clothing/suit/apron = 60,
					/obj/item/clothing/under/waiter = 60,
					/obj/item/clothing/suit/jacket/miljacket = 400,
					/obj/item/clothing/suit/jacket/miljacket/white = 400,
					/obj/item/clothing/suit/jacket/miljacket/desert = 400,
					/obj/item/clothing/suit/jacket/miljacket/navy = 400,
					/obj/item/clothing/under/pirate = 150,
					/obj/item/clothing/suit/pirate_brown = 150,
					/obj/item/clothing/suit/pirate_black =150,
					/obj/item/clothing/under/pirate_rags =150,
					/obj/item/clothing/head/pirate = 70,
					/obj/item/clothing/head/bandana = 70,
					/obj/item/clothing/head/bandana = 70,
					/obj/item/clothing/under/soviet = 70,
					/obj/item/clothing/head/ushanka = 70,
					/obj/item/clothing/suit/imperium_monk = 150,
					/obj/item/clothing/mask/gas/cyborg = 50,
					/obj/item/clothing/suit/holidaypriest = 150,
					/obj/item/clothing/head/wizard/marisa/fake = 150,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 150,
					/obj/item/clothing/under/sundress = 200,
					/obj/item/clothing/head/witchwig = 200,
					/obj/item/twohanded/staff/broom = 300,
					/obj/item/clothing/suit/wizrobe/fake = 150,
					/obj/item/clothing/head/wizard/fake = 150,
					/obj/item/twohanded/staff = 300,
					/obj/item/clothing/mask/gas/clown_hat/sexy = 150,
					/obj/item/clothing/under/rank/clown/sexy = 150,
					/obj/item/clothing/mask/gas/sexymime = 150,
					/obj/item/clothing/under/sexymime = 150,
					/obj/item/clothing/mask/face/bat = 90,
					/obj/item/clothing/mask/face/bee = 90,
					/obj/item/clothing/mask/face/bear = 90,
					/obj/item/clothing/mask/face/raven = 90,
					/obj/item/clothing/mask/face/jackal = 90,
					/obj/item/clothing/mask/face/fox = 90,
					/obj/item/clothing/mask/face/tribal = 90,
					/obj/item/clothing/mask/face/rat = 90,
					/obj/item/clothing/suit/apron/overalls = 50,
					/obj/item/clothing/head/rabbitears = 100,
					/obj/item/clothing/head/sombrero = 100,
					/obj/item/clothing/suit/poncho = 150,
					/obj/item/clothing/suit/poncho/green = 150,
					/obj/item/clothing/suit/poncho/red = 150,
					/obj/item/clothing/accessory/blue = 30,
					/obj/item/clothing/accessory/red = 30,
					/obj/item/clothing/accessory/black = 30,
					/obj/item/clothing/accessory/horrible = 30,
					/obj/item/clothing/under/maid = 600,
					/obj/item/clothing/under/janimaid = 600,
					/obj/item/clothing/under/jester = 600,
					/obj/item/clothing/head/jester = 100,
					/obj/item/clothing/under/pants/camo = 50,
					/obj/item/clothing/mask/bandana = 30,
					/obj/item/clothing/mask/bandana/black = 30,
					/obj/item/clothing/shoes/singery = 320,
					/obj/item/clothing/under/singery = 320,
					/obj/item/clothing/shoes/singerb = 320,
					/obj/item/clothing/under/singerb = 320,
					/obj/item/clothing/suit/hooded/carp_costume = 150,
					/obj/item/clothing/suit/hooded/bee_costume = 150,
					/obj/item/clothing/suit/snowman = 150,
					/obj/item/clothing/head/snowman = 150,
					/obj/item/clothing/head/cueball = 150,
					/obj/item/clothing/under/scratch = 150,
					/obj/item/clothing/under/victdress = 150,
					/obj/item/clothing/under/victdress/red = 150,
					/obj/item/clothing/suit/victcoat = 150,
					/obj/item/clothing/suit/victcoat/red = 150,
					/obj/item/clothing/under/victsuit = 150,
					/obj/item/clothing/under/victsuit/redblk = 150,
					/obj/item/clothing/under/victsuit/red = 150,
					/obj/item/clothing/suit/tailcoat = 150,
					/obj/item/clothing/suit/draculacoat = 150,
					/obj/item/clothing/head/zepelli = 100,
					/obj/item/clothing/under/redhawaiianshirt = 52,
					/obj/item/clothing/under/pinkhawaiianshirt = 52,
					/obj/item/clothing/under/bluehawaiianshirt = 52,
					/obj/item/clothing/under/orangehawaiianshirt = 52)

//este vending es gratis en paradise
/obj/machinery/vending/hatdispenser
	hispa_products = list(/obj/item/clothing/head/collectable/petehat = 2,
					/obj/item/clothing/head/collectable/xenom = 2,
					/obj/item/clothing/head/collectable/paper = 2,
					/obj/item/clothing/head/collectable/slime = 2,
					/obj/item/clothing/head/collectable/pirate = 2,
					/obj/item/clothing/head/collectable/thunderdome = 2,
   					/obj/item/clothing/head/collectable/rabbitears = 2)
	hispa_prices = list(/obj/item/clothing/head/bowlerhat = 50,
					/obj/item/clothing/head/beaverhat = 35,
					/obj/item/clothing/head/boaterhat = 35,
					/obj/item/clothing/head/fedora = 200,
					/obj/item/clothing/head/fez = 120,
					/obj/item/clothing/head/beret = 100,
    				/obj/item/clothing/head/collectable/petehat = 2000,
					/obj/item/clothing/head/collectable/xenom = 2000,
					/obj/item/clothing/head/collectable/paper = 2000,
					/obj/item/clothing/head/collectable/slime = 2000,
					/obj/item/clothing/head/collectable/pirate = 2000,
					/obj/item/clothing/head/collectable/thunderdome = 2000,
   					/obj/item/clothing/head/collectable/rabbitears = 2000)

//este vending es gratis en paradise
/obj/machinery/vending/suitdispenser
	hispa_prices = list(/obj/item/clothing/under/color/black = 50,
					/obj/item/clothing/under/color/blue = 50,
					/obj/item/clothing/under/color/green = 50,
					/obj/item/clothing/under/color/grey = 50,
					/obj/item/clothing/under/color/pink = 50,
					/obj/item/clothing/under/color/red = 50,
					/obj/item/clothing/under/color/white = 50,
					/obj/item/clothing/under/color/yellow = 50,
					/obj/item/clothing/under/color/lightblue = 50,
					/obj/item/clothing/under/color/aqua = 50,
					/obj/item/clothing/under/color/purple = 50,
					/obj/item/clothing/under/color/lightgreen = 50,
					/obj/item/clothing/under/color/lightblue = 50,
					/obj/item/clothing/under/color/lightbrown = 50,
					/obj/item/clothing/under/color/brown = 50,
					/obj/item/clothing/under/color/yellowgreen = 50,
					/obj/item/clothing/under/color/darkblue = 50,
					/obj/item/clothing/under/color/lightred = 50,
					/obj/item/clothing/under/color/darkred = 50)

	hispa_contraband = list(/obj/item/clothing/under/soviet = 5)

//este vending es gratis en paradise
/obj/machinery/vending/shoedispenser
	hispa_prices = list(/obj/item/clothing/shoes/black = 150,
					/obj/item/clothing/shoes/brown = 400,
					/obj/item/clothing/shoes/blue = 150,
					/obj/item/clothing/shoes/green = 50,
					/obj/item/clothing/shoes/yellow = 50,
					/obj/item/clothing/shoes/purple = 50,
					/obj/item/clothing/shoes/red = 100,
					/obj/item/clothing/shoes/white = 100,
					/obj/item/clothing/shoes/sandal = 15)

/obj/machinery/vending/cola
	hispa_products = list(/obj/item/reagent_containers/food/drinks/cans/space_mundet = 10, /obj/item/reagent_containers/food/drinks/cans/behemoth_energy = 2,
					/obj/item/reagent_containers/food/drinks/cans/behemoth_energy_lite = 1)
	hispa_prices = list(/obj/item/reagent_containers/food/drinks/cans/space_mundet = 20, /obj/item/reagent_containers/food/drinks/cans/behemoth_energy = 50,
					/obj/item/reagent_containers/food/drinks/cans/behemoth_energy_lite = 50)

/obj/machinery/vending/wallmed
	hispa_products = list(/obj/item/reagent_containers/food/pill/patch/styptic = 1, /obj/item/reagent_containers/food/pill/patch/silver_sulf = 1)

/obj/machinery/vending/hydroseeds
	hispa_products = list(/obj/item/seeds/agave = 3, /obj/item/seeds/aloe = 3,
					/obj/item/seeds/anonna = 3, /obj/item/seeds/avocado = 3,
					/obj/item/seeds/bell_pepper = 3, /obj/item/seeds/kiwi = 3,
					/obj/item/seeds/fungus = 3,/obj/item/seeds/ricinus = 3,
					/obj/item/seeds/strawberry = 3,/obj/item/seeds/mango = 3,
					/obj/item/seeds/prickly_pear = 3,/obj/item/seeds/coconut = 3,
					/obj/item/seeds/mate = 3,/obj/item/seeds/nispero = 3,
					/obj/item/seeds/peach = 3)

	hispa_contraband = list(/obj/item/seeds/money = 2)

/obj/machinery/vending/dinnerware
	hispa_products = list(/obj/item/storage/bag/kitchenbag = 3)

/obj/machinery/vending/engivend
	hispa_products = list(/obj/item/storage/bag/component/inge = 5)

/obj/machinery/vending/shoedispenser
	hispa_products = list(/obj/item/clothing/shoes/jackboots = 5)

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//code by Danaleja2005
/obj/machinery/vending/walldrobe
	name = "\improper WallDrobe"
	desc = "Wall-mounted Clothes dispenser. Made by D&N Corp."
	ads_list =list("Dress up in fashion and wear our amazing uniforms, hats, suits made of the best material, only with us N&D Corp!.")
	icon = 'icons/hispania/obj/vending.dmi'
	icon_state = "walldrobe"
	icon_deny = "walldrobe-deny"
	icon_vend = "walldrobe-vend"
	density = FALSE //It is wall-mounted, and thus, not dense. --SuperxpdudeS
	vend_delay = 12

/obj/machinery/vending/walldrobe/cap
	name = "\improper Captain's WallDrobe"
	req_access = list(ACCESS_CAPTAIN)
	products = list(/obj/item/clothing/under/rank/command/captain/formal/light = 1,
					/obj/item/clothing/under/rank/command/captain/formal/dark = 1,
					/obj/item/clothing/head/caphat/dark = 1,
					/obj/item/clothing/head/caphat/light = 1,
					/obj/item/clothing/suit/armor/vest/captrenchcoat = 1,
					/obj/item/clothing/suit/captunic = 1,
					/obj/item/clothing/suit/captunic/capjacket = 1,
					/obj/item/clothing/under/captainparade = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/head/caphat/parade = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/under/dress/dress_cap = 1,
					/obj/item/clothing/under/dress/dress_cap = 1,
					/obj/item/clothing/suit/armor/vest/capcarapace/alt = 1,
					/obj/item/clothing/shoes/brown = 1,
					/obj/item/clothing/shoes/laceup = 1,
					/obj/item/clothing/suit/mantle/armor/captain = 1,
					/obj/item/clothing/gloves/color/captain = 1)

/obj/machinery/vending/walldrobe/rd
	name = "\improper Research Director's WallDrobe"
	req_access = list(ACCESS_RD)
	products = list(/obj/item/clothing/suit/storage/labcoat/rdlargedark = 1,
					/obj/item/clothing/suit/storage/labcoat/rdlargeroundcutdark = 1,
					/obj/item/clothing/suit/bio_suit/scientist = 1,
					/obj/item/clothing/head/bio_hood/scientist = 1,
					/obj/item/clothing/under/rank/research_director = 1,
					/obj/item/clothing/suit/storage/labcoat = 1,
					/obj/item/clothing/suit/mantle/labcoat = 1,
					/obj/item/clothing/mask/gas = 1,
					/obj/item/clothing/shoes/white = 1,
					/obj/item/clothing/gloves/color/latex = 1)

/obj/machinery/vending/walldrobe/hos
	name = "\improper Head of Security's Walldrobe"
	req_access = list(ACCESS_HOS)
	products = list(/obj/item/clothing/under/rank/head_of_security = 1,
					/obj/item/clothing/under/rank/head_of_security/formal = 1,
					/obj/item/clothing/under/rank/head_of_security/corp = 1,
					/obj/item/clothing/under/rank/head_of_security/skirt = 1,
					/obj/item/clothing/suit/armor/hos = 1,
					/obj/item/clothing/suit/armor/hos/alt = 1,
					/obj/item/clothing/suit/armor/hos/ranger = 1,
					/obj/item/clothing/head/HoS = 1,
					/obj/item/clothing/head/HoS/beret = 1,
					/obj/item/clothing/head/helmet/riot/rangerh = 1,
					/obj/item/clothing/suit/mantle/armor = 1,
					/obj/item/clothing/gloves/color/black/hos = 1)

/obj/machinery/vending/walldrobe/ce
	name = "\improper Chief Enginner's Walldrobe"
	req_access = list(ACCESS_CE)
	products = list(/obj/item/clothing/under/rank/chief_engineer = 1,
					/obj/item/clothing/under/rank/chief_engineer/skirt = 1,
					/obj/item/clothing/suit/mantle/chief_engineer = 1,
					/obj/item/clothing/gloves/color/yellow = 1,
					/obj/item/clothing/head/hardhat/white = 1,
					/obj/item/clothing/shoes/brown = 1,
					/obj/item/clothing/suit/storage/hazardvest = 1,
					/obj/item/clothing/head/beret/ce = 1)

/obj/machinery/vending/walldrobe/cmo
	name = "\improper Chief Medical Officer's Walldrobe"
	req_access = list(ACCESS_CMO)
	products = list(/obj/item/clothing/shoes/white = 1,
					/obj/item/clothing/under/rank/medical/blue = 1,
					/obj/item/clothing/head/surgery/blue = 1,
					/obj/item/clothing/under/rank/medical/green = 1,
					/obj/item/clothing/head/surgery/green = 1,
					/obj/item/clothing/under/rank/medical/purple = 1,
					/obj/item/clothing/head/surgery/purple = 1,
					/obj/item/clothing/suit/storage/labcoat/cmo = 1,
					/obj/item/clothing/under/rank/chief_medical_officer = 1,
					/obj/item/clothing/suit/mantle/labcoat/chief_medical_officer = 1,
					/obj/item/clothing/shoes/brown = 1)

/obj/machinery/vending/walldrobe/sec
	name = "\improper Security's Walldrobe"
	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/clothing/under/rank/security/private = 1,
					/obj/item/clothing/head/beret/sec/private = 1,
					/obj/item/clothing/head/officer/hat = 1,
					/obj/item/clothing/under/rank/security/private/red = 4,
					/obj/item/clothing/head/beret/sec/private/red = 3,
					/obj/item/clothing/head/officer/hat/red = 3,
					/obj/item/clothing/head/soft/sec = 3,
					/obj/item/clothing/suit/armor/secjacket = 3,
					/obj/item/clothing/suit/hooded/wintercoat/security = 3)
	prices = list(/obj/item/clothing/under/rank/security/private = 580,
				  /obj/item/clothing/head/beret/sec/private = 450,
				  /obj/item/clothing/head/officer/hat = 500)

/obj/machinery/vending/walldrobe/sec/podpilot
	name = "\improper Security Pod Pilot's Walldrobe"
	req_access = list(ACCESS_PILOT)
	products = list(/obj/item/clothing/head/beret/sec/private = 1,
					/obj/item/clothing/head/beret/sec/private/red = 1,
					/obj/item/clothing/under/rank/security/pod_pilot/formal = 1,
					/obj/item/clothing/under/rank/security/pod_pilot = 1,
					/obj/item/clothing/suit/armor/secjacket = 1,
					/obj/item/clothing/suit/hooded/wintercoat/security = 1)
	prices = list(/obj/item/clothing/head/beret/sec/private = 450)

/obj/machinery/vending/accesories
	name = "\improper Xtra"
	desc = "Accessories dispenser. Made by NT Corp."
	ads_list = list("Get fashion and useful, funny accessories for make your work better an happy, only with us NT Corp!, Remember Work is the most important.")
	icon = 'icons/hispania/obj/vending.dmi'
	icon_state = "Xtra"
	icon_vend = "Xtra-vend"
	density = TRUE
	vend_delay = 12

	products = list(/obj/item/storage/wallet = 15,
					/obj/item/clothing/glasses/monocle = 5,
					/obj/item/clothing/glasses/regular = 5,
					/obj/item/clothing/ears/headphones = 5,
					/obj/item/clothing/accessory/necklace = 5,
					/obj/item/clothing/accessory/necklace = 5,
					/obj/item/clothing/accessory/necklace/dope = 5,
					/obj/item/clothing/accessory/necklace/locket = 5,
					/obj/item/clothing/accessory/armband = 5,
					/obj/item/lipstick = 5,
					/obj/item/lipstick/blue = 5,
				  	/obj/item/lipstick/lime= 5,
					/obj/item/lipstick/purple = 5,
					/obj/item/lipstick/jade = 5,
   					/obj/item/lipstick/black = 5,
   					/obj/item/lipstick/white = 5,
    				/obj/item/lipstick/green = 5,
    				/obj/item/clothing/head/collectable/petehat = 2,
					/obj/item/clothing/head/collectable/xenom = 2,
					/obj/item/clothing/head/collectable/paper = 2,
					/obj/item/clothing/head/collectable/slime = 2,
					/obj/item/clothing/head/collectable/pirate = 2,
					/obj/item/clothing/head/collectable/thunderdome = 2,
   					/obj/item/clothing/head/kitty = 10,
   					/obj/item/clothing/head/kitty/mouse= 10,
   					/obj/item/clothing/head/collectable/rabbitears = 2,
					/obj/item/clothing/head/hairflower = 5,
    				/obj/item/stack/sheet/animalhide/monkey = 5,
    				/obj/item/stack/sheet/animalhide/lizard = 5)
	contraband = list(		/obj/item/stack/sheet/animalhide/human = 5)
	prices = list(/obj/item/storage/wallet = 300,
					/obj/item/clothing/glasses/monocle = 400,
					/obj/item/clothing/glasses/regular = 400,
					/obj/item/clothing/ears/headphones = 450,
					/obj/item/clothing/accessory/necklace = 300,
					/obj/item/clothing/accessory/necklace/dope = 500,
					/obj/item/clothing/accessory/necklace/locket = 1200,
					/obj/item/clothing/accessory/armband = 250,
					/obj/item/lipstick = 200,
					/obj/item/lipstick/green = 200,
					/obj/item/lipstick/blue = 200,
					/obj/item/lipstick/lime= 220,
					/obj/item/lipstick/purple = 200,
					/obj/item/lipstick/jade = 220,
    				/obj/item/lipstick/black = 200,
    				/obj/item/lipstick/white = 200,
    				/obj/item/clothing/head/kitty = 350,
    				/obj/item/clothing/head/kitty/mouse = 350,
   					/obj/item/clothing/head/collectable/rabbitears = 2000,
    				/obj/item/clothing/head/hairflower = 200,
    				/obj/item/clothing/head/collectable/petehat = 2000,
					/obj/item/clothing/head/collectable/xenom = 2000,
					/obj/item/clothing/head/collectable/paper = 2000,
					/obj/item/clothing/head/collectable/slime = 2000,
					/obj/item/clothing/head/collectable/pirate = 2000,
					/obj/item/clothing/head/collectable/thunderdome = 2000,
    				/obj/item/stack/sheet/animalhide/monkey = 500,
    				/obj/item/kitchen/knife/folding/wood = 300,
    				/obj/item/kitchen/knife/folding/normal = 550,
    				/obj/item/kitchen/knife/folding/butterfly = 550,
    				/obj/item/stack/sheet/animalhide/lizard = 500)
	premium = list(/obj/item/kitchen/knife/folding/wood =5,/obj/item/kitchen/knife/folding/normal =5,/obj/item/kitchen/knife/folding/butterfly =5)

/obj/machinery/vending/artvend/free
	prices = list()
	hispa_prices = list()

/obj/machinery/vending/discdan
	name = "\improper Discount Dan's"
	desc = "A vending machine containing discount snacks. It is owned by the infamous 'Discount Dan' franchise."
	ads_list = list("Discount Dan, he's the man!","There ain't nothing better in this world than a bite of mystery.","Don't listen to those other machines, buy my product!","Quantity over Quality!","Don't listen to those eggheads from MedBay, buy now!","Discount Dan's: We're good for you! Nope, couldn't say it with a straight face.","Discount Dan's: Only the best quality produ-*BZZT*")
	icon = 'icons/hispania/obj/vending.dmi'
	slogan_list = list("Discount Dan(tm) is not responsible for any damages caused by misuse of his product.")
	vend_reply = "No refunds."
	icon_state = "discount"
	icon_vend = "discount-vend"
	density = TRUE
	vend_delay = 12
	products = list(		/obj/item/reagent_containers/food/snacks/discountburger = 6,
					/obj/item/reagent_containers/food/snacks/danitos = 6,
					/obj/item/reagent_containers/food/snacks/discountburrito = 10,
					/obj/item/reagent_containers/food/snacks/donitos = 3,
					/obj/item/reagent_containers/food/snacks/discountbar = 10,
					/obj/item/reagent_containers/food/snacks/discountpie = 8,
					/obj/item/reagent_containers/food/condiment/pack/discount_sauce = 5
					)
	premium = list(		/obj/item/reagent_containers/food/snacks/discountpie/self_heating = 5)
	prices = list(			/obj/item/reagent_containers/food/snacks/discountburger = 30,
					/obj/item/reagent_containers/food/snacks/danitos = 25,
					/obj/item/reagent_containers/food/snacks/discountburrito = 40,
					/obj/item/reagent_containers/food/snacks/donitos = 60,
					/obj/item/reagent_containers/food/snacks/discountbar = 15,
					/obj/item/reagent_containers/food/snacks/discountpie = 50,
					/obj/item/reagent_containers/food/condiment/pack/discount_sauce = 10
					)
