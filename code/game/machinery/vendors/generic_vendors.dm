//general-use clothing vendors, wardrobe vendors are in another file
/obj/machinery/economy/vending/hatdispenser
	name = "\improper Hatlord 9000"
	desc = "It doesn't seem the slightest bit unusual. This frustrates you immensely."
	icon_state = "hats"
	icon_lightmask = "hats"
	icon_panel = "syndi"
	icon_broken = "wide_vendor"
	ads_list = list("Warning, not all hats are dog/monkey compatible. Apply forcefully with care.","Apply directly to the forehead.","Who doesn't love spending cash on hats?!","From the people that brought you collectable hat crates, Hatlord!")
	products = list(/obj/item/clothing/head/bowlerhat = 10,
					/obj/item/clothing/head/beaverhat = 10,
					/obj/item/clothing/head/boaterhat = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/fez = 10,
					/obj/item/clothing/head/beret = 10)
	contraband = list(/obj/item/clothing/head/bearpelt = 5)
	premium = list(/obj/item/clothing/head/soft/rainbow = 1)
	refill_canister = /obj/item/vending_refill/hatdispenser

/obj/machinery/economy/vending/suitdispenser
	name = "\improper Suitlord 9000"
	desc = "You wonder for a moment why all of your shirts and pants come conjoined. This hurts your head and you stop thinking about it."
	icon_state = "suits"
	icon_lightmask = "suits"
	icon_panel = "syndi"
	icon_broken = "wide_vendor"
	ads_list = list("Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*","Blood of your enemies washes right out!","Who are YOU wearing?","Look dapper! Look like an idiot!","Dont carry your size? How about you shave off some pounds you fat lazy- *BZZT*")
	products = list(/obj/item/clothing/under/color/black = 10, /obj/item/clothing/under/color/grey = 10, /obj/item/clothing/under/color/white = 10, /obj/item/clothing/under/color/darkred = 10, /obj/item/clothing/under/color/red = 10, /obj/item/clothing/under/color/lightred = 10,
					/obj/item/clothing/under/color/brown = 10, /obj/item/clothing/under/color/orange = 10, /obj/item/clothing/under/color/lightbrown = 10, /obj/item/clothing/under/color/yellow = 10, /obj/item/clothing/under/color/yellowgreen = 10, /obj/item/clothing/under/color/lightgreen = 10,
					/obj/item/clothing/under/color/green = 10, /obj/item/clothing/under/color/aqua = 10, /obj/item/clothing/under/color/darkblue = 10, /obj/item/clothing/under/color/blue = 10, /obj/item/clothing/under/color/lightblue = 10, /obj/item/clothing/under/color/purple = 10,
					/obj/item/clothing/under/color/lightpurple = 10, /obj/item/clothing/under/color/pink = 10)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 5,/obj/item/clothing/under/color/orange/prison = 5)
	premium = list(/obj/item/clothing/under/color/rainbow = 1)
	refill_canister = /obj/item/vending_refill/suitdispenser

/obj/machinery/economy/vending/shoedispenser
	name = "\improper Shoelord 9000"
	desc = "Wow, hatlord looked fancy, suitlord looked streamlined, and this is just normal. The guy who designed these must be an idiot."
	icon_state = "shoes"
	icon_lightmask = "shoes"
	icon_panel = "syndi"
	icon_broken = "wide_vendor"
	ads_list = list("Put your foot down!","One size fits all!","IM WALKING ON SUNSHINE!","No hobbits allowed.","NO PLEASE WILLY, DONT HURT ME- *BZZT*")
	products = list(/obj/item/clothing/shoes/black = 10,/obj/item/clothing/shoes/brown = 10,/obj/item/clothing/shoes/blue = 10,/obj/item/clothing/shoes/green = 10,/obj/item/clothing/shoes/yellow = 10,/obj/item/clothing/shoes/purple = 10,/obj/item/clothing/shoes/red = 10,/obj/item/clothing/shoes/white = 10,/obj/item/clothing/shoes/sandal=10)
	contraband = list(/obj/item/clothing/shoes/orange = 5)
	premium = list(/obj/item/clothing/shoes/rainbow = 1)
	refill_canister = /obj/item/vending_refill/shoedispenser

//don't forget to change the refill size if you change the machine's contents!
/obj/machinery/economy/vending/clothing
	name = "\improper ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."
	icon_state = "clothes"
	icon_lightmask = "base_drobe"
	icon_panel = "drobe"
	slogan_list = list("Dress for success!","Prepare to look swagalicious!","Look at all this free swag!","Why leave style up to fate? Use the ClothesMate!")
	vend_delay = 15
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/that = 2,
					/obj/item/clothing/head/fedora = 1,
					/obj/item/clothing/glasses/monocle = 1,
					/obj/item/clothing/under/suit/navy = 2,
					/obj/item/clothing/under/costume/kilt = 1,
					/obj/item/clothing/under/misc/overalls = 1,
					/obj/item/clothing/under/suit/really_black = 2,
					/obj/item/clothing/suit/storage/lawyer/blackjacket = 2,
					/obj/item/clothing/under/pants/jeans = 3,
					/obj/item/clothing/under/pants/classicjeans = 2,
					/obj/item/clothing/under/pants/camo = 1,
					/obj/item/clothing/under/pants/blackjeans = 2,
					/obj/item/clothing/under/pants/khaki = 2,
					/obj/item/clothing/under/pants/white = 2,
					/obj/item/clothing/under/pants/red = 1,
					/obj/item/clothing/under/pants/black = 2,
					/obj/item/clothing/under/pants/tan = 2,
					/obj/item/clothing/under/pants/blue = 1,
					/obj/item/clothing/under/pants/track = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/head/beanie = 3,
					/obj/item/clothing/head/beanie/black = 3,
					/obj/item/clothing/head/beanie/red = 3,
					/obj/item/clothing/head/beanie/green = 3,
					/obj/item/clothing/head/beanie/darkblue = 3,
					/obj/item/clothing/head/beanie/purple = 3,
					/obj/item/clothing/head/beanie/yellow = 3,
					/obj/item/clothing/head/beanie/orange = 3,
					/obj/item/clothing/head/beanie/cyan = 3,
					/obj/item/clothing/head/beanie/christmas = 3,
					/obj/item/clothing/head/beanie/striped = 3,
					/obj/item/clothing/head/beanie/stripedred = 3,
					/obj/item/clothing/head/beanie/stripedblue = 3,
					/obj/item/clothing/head/beanie/stripedgreen = 3,
					/obj/item/clothing/head/beanie/rasta = 3,
					/obj/item/clothing/accessory/scarf/red = 1,
					/obj/item/clothing/accessory/scarf/green = 1,
					/obj/item/clothing/accessory/scarf/darkblue = 1,
					/obj/item/clothing/accessory/scarf/purple = 1,
					/obj/item/clothing/accessory/scarf/yellow = 1,
					/obj/item/clothing/accessory/scarf/orange = 1,
					/obj/item/clothing/accessory/scarf/lightblue = 1,
					/obj/item/clothing/accessory/scarf/white = 1,
					/obj/item/clothing/accessory/scarf/black = 1,
					/obj/item/clothing/accessory/scarf/zebra = 1,
					/obj/item/clothing/accessory/scarf/christmas = 1,
					/obj/item/clothing/accessory/stripedredscarf = 1,
					/obj/item/clothing/accessory/stripedbluescarf = 1,
					/obj/item/clothing/accessory/stripedgreenscarf = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/dress/sundress = 2,
					/obj/item/clothing/under/dress/stripeddress = 1,
					/obj/item/clothing/under/dress/sailordress = 1,
					/obj/item/clothing/under/dress/redeveninggown = 1,
					/obj/item/clothing/under/dress/blacktango = 1,
					/obj/item/clothing/suit/jacket = 3,
					/obj/item/clothing/suit/jacket/motojacket = 3,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/sunglasses_fake = 2,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/suit/poncho = 1,
					/obj/item/clothing/suit/ianshirt = 1,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/black = 4,
					/obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/gloves/fingerless = 2,
					/obj/item/storage/belt/fannypack = 1,
					/obj/item/storage/belt/fannypack/blue = 1,
					/obj/item/storage/belt/fannypack/red = 1,
					/obj/item/clothing/suit/mantle = 2,
					/obj/item/clothing/suit/mantle/old = 1,
					/obj/item/clothing/suit/mantle/regal = 2)

	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 1,
					  /obj/item/clothing/mask/balaclava = 1,
					  /obj/item/clothing/head/ushanka = 1,
					  /obj/item/clothing/under/costume/soviet = 1,
					  /obj/item/storage/belt/fannypack/black = 1)

	premium = list(/obj/item/clothing/under/suit/checkered = 1,
				   /obj/item/clothing/head/mailman = 1,
				   /obj/item/clothing/under/misc/mailman = 1,
				   /obj/item/clothing/suit/jacket/leather = 1,
				   /obj/item/clothing/under/pants/mustangjeans = 1)

	refill_canister = /obj/item/vending_refill/clothing

/obj/machinery/economy/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	slogan_list = list("Sling spells the proper way with MagiVend!","Be your own Houdini! Use MagiVend!")
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	ads_list = list("FJKLFJSD","AJKFLBJAKL","1234 LOONIES LOL!",">MFW","Kill them fuckers!","GET DAT FUKKEN DISK","HONK!","EI NATH","Destroy the station!","Admin conspiracies since forever!","Space-time bending hardware!")
	products = list(/obj/item/clothing/head/wizard = 1,
					/obj/item/clothing/suit/wizrobe = 1,
					/obj/item/clothing/head/wizard/red = 1,
					/obj/item/clothing/suit/wizrobe/red = 1,
					/obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/suit/wizrobe/clown = 1,
					/obj/item/clothing/head/wizard/clown = 1,
					/obj/item/clothing/mask/gas/clownwiz = 1,
					/obj/item/clothing/shoes/clown_shoes/magical = 1,
					/obj/item/clothing/suit/wizrobe/mime = 1,
					/obj/item/clothing/head/wizard/mime = 1,
					/obj/item/clothing/mask/gas/mime/wizard = 1,
					/obj/item/clothing/shoes/sandal/marisa = 1,
					/obj/item/twohanded/staff = 2)
	contraband = list(/obj/item/reagent_containers/glass/bottle/wizarditis = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/economy/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_lightmask = "theater"
	icon_deny = "theater_deny"
	slogan_list = list("Dress for success!","Suited and booted!","It's show time!","Why leave style up to fate? Use AutoDrobe!")
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 1,
					/obj/item/clothing/head/chicken = 1,
					/obj/item/clothing/under/costume/gladiator = 1,
					/obj/item/clothing/head/helmet/gladiator = 1,
					/obj/item/clothing/under/misc/gimmick/rank/captain/suit = 1,
					/obj/item/clothing/head/flatcap = 1,
					/obj/item/clothing/suit/storage/labcoat/mad = 1,
					/obj/item/clothing/glasses/gglasses = 1,
					/obj/item/clothing/shoes/jackboots = 1,
					/obj/item/clothing/under/dress/schoolgirl = 1,
					/obj/item/clothing/under/dress/blackskirt = 1,
					/obj/item/clothing/suit/toggle/owlwings = 1,
					/obj/item/clothing/under/costume/owl = 1,
					/obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 1,
					/obj/item/clothing/under/costume/griffin = 1,
					/obj/item/clothing/shoes/griffin = 1,
					/obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/suit/black = 1,
					/obj/item/clothing/head/that =1,
					/obj/item/clothing/under/costume/kilt = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/glasses/monocle =1,
					/obj/item/clothing/head/bowlerhat = 1,
					/obj/item/cane = 1,
					/obj/item/clothing/under/misc/sl_suit = 1,
					/obj/item/clothing/mask/fakemoustache = 1,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,
					/obj/item/clothing/head/plaguedoctorhat = 1,
					/obj/item/clothing/mask/gas/plaguedoctor = 1,
					/obj/item/clothing/suit/apron = 1,
					/obj/item/clothing/under/misc/waiter = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/suit/jacket/miljacket/white = 1,
					/obj/item/clothing/suit/jacket/miljacket/desert = 1,
					/obj/item/clothing/suit/jacket/miljacket/navy = 1,
					/obj/item/clothing/under/costume/pirate = 1,
					/obj/item/clothing/suit/pirate_brown = 1,
					/obj/item/clothing/suit/pirate_black =1,
					/obj/item/clothing/under/costume/pirate_rags =1,
					/obj/item/clothing/head/pirate = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/under/costume/soviet = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1,
					/obj/item/clothing/suit/holidaypriest = 1,
					/obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1,
					/obj/item/clothing/under/dress/sundress = 1,
					/obj/item/clothing/head/witchwig = 1,
					/obj/item/twohanded/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1,
					/obj/item/clothing/head/wizard/fake = 1,
					/obj/item/twohanded/staff = 3,
					/obj/item/clothing/mask/gas/clown_hat/sexy = 1,
					/obj/item/clothing/under/rank/civilian/clown/sexy = 1,
					/obj/item/clothing/mask/gas/sexymime = 1,
					/obj/item/clothing/under/rank/civilian/mime/sexy = 1,
					/obj/item/clothing/mask/face/bat = 1,
					/obj/item/clothing/mask/face/bee = 1,
					/obj/item/clothing/mask/face/bear = 1,
					/obj/item/clothing/mask/face/raven = 1,
					/obj/item/clothing/mask/face/jackal = 1,
					/obj/item/clothing/mask/face/fox = 1,
					/obj/item/clothing/mask/face/tribal = 1,
					/obj/item/clothing/mask/face/rat = 1,
					/obj/item/clothing/suit/apron/overalls = 1,
					/obj/item/clothing/head/rabbitears =1,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/suit/poncho = 1,
					/obj/item/clothing/suit/poncho/green = 1,
					/obj/item/clothing/suit/poncho/red = 1,
					/obj/item/clothing/accessory/blue = 1,
					/obj/item/clothing/accessory/red = 1,
					/obj/item/clothing/accessory/black = 1,
					/obj/item/clothing/accessory/horrible = 1,
					/obj/item/clothing/under/costume/maid = 1,
					/obj/item/clothing/under/costume/janimaid = 1,
					/obj/item/clothing/under/costume/jester = 1,
					/obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/pants/camo = 1,
					/obj/item/clothing/mask/bandana = 1,
					/obj/item/clothing/mask/bandana/black = 1,
					/obj/item/clothing/shoes/singery = 1,
					/obj/item/clothing/under/costume/singery = 1,
					/obj/item/clothing/shoes/singerb = 1,
					/obj/item/clothing/under/costume/singerb = 1,
					/obj/item/clothing/suit/hooded/carp_costume = 1,
					/obj/item/clothing/suit/hooded/bee_costume = 1,
					/obj/item/clothing/suit/snowman = 1,
					/obj/item/clothing/head/snowman = 1,
					/obj/item/clothing/head/cueball = 1,
					/obj/item/clothing/under/misc/scratch = 1,
					/obj/item/clothing/under/dress/victdress = 1,
					/obj/item/clothing/under/dress/victdress/red = 1,
					/obj/item/clothing/suit/victcoat = 1,
					/obj/item/clothing/suit/victcoat/red = 1,
					/obj/item/clothing/under/suit/victsuit = 1,
					/obj/item/clothing/under/suit/victsuit/redblk = 1,
					/obj/item/clothing/under/suit/victsuit/red = 1,
					/obj/item/clothing/suit/tailcoat = 1,
					/obj/item/clothing/under/costume/tourist_suit = 1,
					/obj/item/clothing/suit/draculacoat = 1,
					/obj/item/clothing/head/zepelli = 1,
					/obj/item/clothing/under/misc/redhawaiianshirt = 1,
					/obj/item/clothing/under/misc/pinkhawaiianshirt = 1,
					/obj/item/clothing/under/misc/bluehawaiianshirt = 1,
					/obj/item/clothing/under/misc/orangehawaiianshirt = 1)
	contraband = list(/obj/item/clothing/suit/judgerobe = 1,
					  /obj/item/clothing/head/powdered_wig = 1,
					  /obj/item/gun/magic/wand = 1,
					  /obj/item/clothing/mask/balaclava=1,
					  /obj/item/clothing/mask/horsehead = 2)
	premium = list(/obj/item/clothing/suit/hgpirate = 1,
				   /obj/item/clothing/head/hgpiratecap = 1,
				   /obj/item/clothing/head/helmet/roman/fake = 1,
				   /obj/item/clothing/head/helmet/roman/legionaire/fake = 1,
				   /obj/item/clothing/under/costume/roman = 1,
				   /obj/item/clothing/shoes/roman = 1,
				   /obj/item/shield/riot/roman/fake = 1,
				   /obj/item/clothing/under/costume/cuban_suit = 1,
				   /obj/item/clothing/head/cuban_hat = 1)
	refill_canister = /obj/item/vending_refill/autodrobe


//Generic food vendors
/obj/machinery/economy/vending/syndicigs
	name = "\improper Suspicious Cigarette Machine"
	desc = "Smoke 'em if you've got 'em."
	slogan_list = list("Space cigs taste good like a cigarette should.","I'd rather toolbox than switch.","Smoke!","Don't believe the reports - smoke today!")
	ads_list = list("Probably not bad for you!","Don't believe the scientists!","It's good for you!","Don't quit, buy more!","Smoke!","Nicotine heaven.","Best cigarettes since 2150.","Award-winning cigs.")
	vend_delay = 34
	icon_state = "cigs"
	icon_lightmask = "cigs"
	products = list(/obj/item/storage/fancy/cigarettes/syndicate = 10,/obj/item/lighter/random = 5)

/obj/machinery/economy/vending/syndisnack
	name = "\improper Getmore Chocolate Corp"
	desc = "A modified snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	slogan_list = list("Try our new nougat bar!","Twice the calories for half the price!")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")
	icon_state = "snack"
	icon_lightmask = "nutri"
	icon_off = "nutri"
	icon_panel = "thin_vendor"
	products = list(/obj/item/reagent_containers/food/snacks/chips =6,/obj/item/reagent_containers/food/snacks/sosjerky = 6,
					/obj/item/reagent_containers/food/snacks/syndicake = 6, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 6)

/obj/machinery/economy/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	slogan_list = list("Enjoy your meal.","Enough calories to support strenuous labor.")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")
	icon_state = "sustenance"
	icon_lightmask = "nutri"
	icon_off = "nutri"
	icon_panel = "thin_vendor"
	products = list(/obj/item/reagent_containers/food/snacks/tofu = 24,
					/obj/item/reagent_containers/food/drinks/ice = 12,
					/obj/item/reagent_containers/food/snacks/candy/candy_corn = 6)
	contraband = list(/obj/item/kitchen/knife = 6,
					  /obj/item/reagent_containers/food/drinks/coffee = 12,
					  /obj/item/tank/internals/emergency_oxygen = 6,
					  /obj/item/clothing/mask/breath = 6)
	refill_canister = /obj/item/vending_refill/sustenance

/obj/machinery/economy/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine."
	icon_state = "sovietsoda"
	icon_lightmask = "sovietsoda"
	ads_list = list("For Tsar and Country.","Have you fulfilled your nutrition quota today?","Very nice!","We are simple people, for this is all we eat.","If there is a person, there is a problem. If there is no person, then there is no problem.")
	products = list(/obj/item/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/reagent_containers/food/drinks/drinkingglass/cola = 20)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/sovietsoda

/obj/machinery/economy/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	slogan_list = list("Try our new nougat bar!","Twice the calories for half the price!")
	ads_list = list("The healthiest!","Award-winning chocolate bars!","Mmm! So good!","Oh my god it's so juicy!","Have a snack.","Snacks are good for you!","Have some more Getmore!","Best quality snacks straight from mars.","We love chocolate!","Try our new jerky!")
	icon_state = "snack"
	icon_lightmask = "nutri"
	icon_off = "nutri"
	icon_panel = "thin_vendor"
	products = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 6,/obj/item/reagent_containers/food/drinks/dry_ramen = 6,/obj/item/reagent_containers/food/snacks/chips =6,
					/obj/item/reagent_containers/food/snacks/sosjerky = 6,/obj/item/reagent_containers/food/snacks/no_raisin = 6,/obj/item/reagent_containers/food/snacks/pistachios =6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6,/obj/item/reagent_containers/food/snacks/cheesiehonkers = 6,/obj/item/reagent_containers/food/snacks/tastybread = 6)
	premium = list(/obj/item/reagent_containers/food/snacks/stroopwafel = 2)
	contraband = list(/obj/item/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 20,/obj/item/reagent_containers/food/drinks/dry_ramen = 30,
					/obj/item/reagent_containers/food/snacks/chips =25,/obj/item/reagent_containers/food/snacks/sosjerky = 30,/obj/item/reagent_containers/food/snacks/no_raisin = 20,
					/obj/item/reagent_containers/food/snacks/pistachios = 35, /obj/item/reagent_containers/food/snacks/spacetwinkie = 30,/obj/item/reagent_containers/food/snacks/cheesiehonkers = 25,/obj/item/reagent_containers/food/snacks/tastybread = 30)
	refill_canister = /obj/item/vending_refill/snack

/obj/machinery/economy/vending/snack/free
	prices = list()

/obj/machinery/economy/vending/chinese
	name = "\improper Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	slogan_list = list("Taste 5000 years of culture!","Mr. Chang, approved for safe consumption in over 10 sectors!","Chinese food is great for a date night, or a lonely night!","You can't go wrong with Mr. Chang's authentic Chinese food!")
	icon_state = "chang"
	icon_lightmask = "chang"
	products = list(/obj/item/reagent_containers/food/snacks/chinese/chowmein = 6, /obj/item/reagent_containers/food/snacks/chinese/tao = 6, /obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6, /obj/item/reagent_containers/food/snacks/chinese/newdles = 6,
					/obj/item/reagent_containers/food/snacks/chinese/rice = 6, /obj/item/reagent_containers/food/snacks/fortunecookie = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/chinese/chowmein = 50, /obj/item/reagent_containers/food/snacks/chinese/tao = 50, /obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 50, /obj/item/reagent_containers/food/snacks/chinese/newdles = 50,
					/obj/item/reagent_containers/food/snacks/chinese/rice = 50, /obj/item/reagent_containers/food/snacks/fortunecookie = 50)
	refill_canister = /obj/item/vending_refill/chinese

/obj/machinery/economy/vending/chinese/free
	prices = list()

/obj/machinery/economy/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	icon_lightmask = "Cola_Machine"
	icon_panel = "thin_vendor"
	slogan_list = list("Robust Softdrinks: More robust than a toolbox to the head!")
	ads_list = list("Refreshing!","Hope you're thirsty!","Over 1 million drinks sold!","Thirsty? Why not cola?","Please, have a drink!","Drink up!","The best drinks in space.")
	products = list(/obj/item/reagent_containers/food/drinks/cans/cola = 10,/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 10,/obj/item/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 10,/obj/item/reagent_containers/food/drinks/cans/grape_juice = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 5)
	prices = list(/obj/item/reagent_containers/food/drinks/cans/cola = 20,/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 20,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 20,/obj/item/reagent_containers/food/drinks/cans/starkist = 20,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 20,/obj/item/reagent_containers/food/drinks/cans/grape_juice = 20)
	refill_canister = /obj/item/vending_refill/cola

/obj/machinery/economy/vending/cola/free
	prices = list()

///General miscellanious vendors
/obj/machinery/economy/vending/artvend
	name = "\improper ArtVend"
	desc = "A vending machine for art supplies."
	slogan_list = list("Stop by for all your artistic needs!","Color the floors with crayons, not blood!","Don't be a starving artist, use ArtVend. ","Don't fart, do art!")
	ads_list = list("Just like Kindergarten!","Now with 1000% more vibrant colors!","Screwing with the janitor was never so easy!","Creativity is at the heart of every spessman.")
	vend_delay = 15
	icon_state = "artvend"
	icon_lightmask = "artvend"
	icon_panel = "screen_vendor"
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/camera = 4,/obj/item/camera_film = 6,
	/obj/item/storage/photo_album = 2,/obj/item/stack/wrapping_paper = 4,/obj/item/stack/tape_roll = 5,/obj/item/stack/packageWrap = 4,
	/obj/item/storage/fancy/crayons = 4,/obj/item/hand_labeler = 4,/obj/item/paper = 10,
	/obj/item/c_tube = 10,/obj/item/pen = 5,/obj/item/pen/blue = 5,
	/obj/item/pen/red = 5)
	contraband = list(/obj/item/toy/crayon/mime = 1,/obj/item/toy/crayon/rainbow = 1)
	premium = list(/obj/item/poster/random_contraband = 5)

/obj/machinery/economy/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool_deny"
	icon_lightmask = "tool"
	icon_panel = "generic"
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/crowbar = 5,/obj/item/weldingtool = 3,/obj/item/wirecutters = 5,
					/obj/item/wrench = 5,/obj/item/analyzer = 5,/obj/item/t_scanner = 5,/obj/item/screwdriver = 5)
	contraband = list(/obj/item/weldingtool/hugetank = 2,/obj/item/clothing/gloves/color/fyellow = 2)
	premium = list(/obj/item/clothing/gloves/color/yellow = 1)
	refill_canister = /obj/item/vending_refill/youtool

/obj/machinery/economy/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	slogan_list = list("Stop by for all your animal's needs!","Cuddly pets deserve a stylish collar!","Pets in space, what could be more adorable?","Freshest fish eggs in the system!","Rocks are the perfect pet, buy one today!")
	ads_list = list("House-training costs extra!","Now with 1000% more cat hair!","Allergies are a sign of weakness!","Dogs are man's best friend. Remember that Vulpkanin!"," Heat lamps for Unathi!"," Vox-y want a cracker?")
	vend_delay = 15
	icon_state = "crittercare"
	icon_lightmask = "crittercare"
	icon_panel = "drobe"
	products = list(/obj/item/clothing/accessory/petcollar = 5, /obj/item/storage/firstaid/aquatic_kit/full =5, /obj/item/fish_eggs/goldfish = 5,
					/obj/item/fish_eggs/clownfish = 5, /obj/item/fish_eggs/shark = 5, /obj/item/fish_eggs/feederfish = 10,
					/obj/item/fish_eggs/salmon = 5, /obj/item/fish_eggs/catfish = 5, /obj/item/fish_eggs/glofish = 5,
					/obj/item/fish_eggs/electric_eel = 5, /obj/item/fish_eggs/shrimp = 10, /obj/item/toy/pet_rock = 5,
					)
	prices = list(/obj/item/clothing/accessory/petcollar = 50, /obj/item/storage/firstaid/aquatic_kit/full = 60, /obj/item/fish_eggs/goldfish = 10,
					/obj/item/fish_eggs/clownfish = 10, /obj/item/fish_eggs/shark = 10, /obj/item/fish_eggs/feederfish = 5,
					/obj/item/fish_eggs/salmon = 10, /obj/item/fish_eggs/catfish = 10, /obj/item/fish_eggs/glofish = 10,
					/obj/item/fish_eggs/electric_eel = 10, /obj/item/fish_eggs/shrimp = 5, /obj/item/toy/pet_rock = 100,
					)
	contraband = list(/obj/item/fish_eggs/babycarp = 5)
	premium = list(/obj/item/toy/pet_rock/fred = 1, /obj/item/toy/pet_rock/roxie = 1)
	refill_canister = /obj/item/vending_refill/crittercare

/obj/machinery/economy/vending/crittercare/free
	prices = list()

/obj/machinery/economy/vending/hydroseeds/syndicate_druglab
	products = list(/obj/item/seeds/ambrosia/deus = 2,
					/obj/item/seeds/cannabis = 2,
					/obj/item/seeds/coffee = 3,
					/obj/item/seeds/liberty = 2,
					/obj/item/seeds/cannabis/rainbow = 1,
					/obj/item/seeds/reishi = 2,
					/obj/item/seeds/tobacco = 1)
	contraband = list()
	premium = list()
	refill_canister = null

/obj/machinery/economy/vending/cigarette
	name = "\improper ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	slogan_list = list("Space cigs taste good like a cigarette should.","I'd rather toolbox than switch.","Smoke!","Don't believe the reports - smoke today!")
	ads_list = list("Probably not bad for you!","Don't believe the scientists!","It's good for you!","Don't quit, buy more!","Smoke!","Nicotine heaven.","Best cigarettes since 2150.","Award-winning cigs.")
	vend_delay = 34
	icon_state = "cigs"
	icon_lightmask = "cigs"
	products = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 12,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
		/obj/item/reagent_containers/food/pill/patch/nicotine = 10,
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/random = 4,
		/obj/item/storage/fancy/rollingpapers = 5)
	contraband = list(/obj/item/lighter/zippo = 4)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1)
	prices = list(/obj/item/storage/fancy/cigarettes/cigpack_robust = 60,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 80,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 100,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 120,
		/obj/item/reagent_containers/food/pill/patch/nicotine = 70,
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/random = 60,
		/obj/item/storage/fancy/rollingpapers = 20)
	refill_canister = /obj/item/vending_refill/cigarette

/obj/machinery/economy/vending/cigarette/free
	prices = list()

/obj/machinery/economy/vending/cigarette/syndicate
	products = list(/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 7,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 2,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 1,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/zippo = 4,
					/obj/item/storage/fancy/rollingpapers = 5)

/obj/machinery/economy/vending/cigarette/syndicate/free
	prices = list()

/obj/machinery/economy/vending/cigarette/beach //Used in the lavaland_biodome_beach.dmm ruin
	name = "\improper ShadyCigs Ultra"
	desc = "Now with extra premium products!"
	ads_list = list("Probably not bad for you!","Dope will get you through times of no money better than money will get you through times of no dope!","It's good for you!")
	slogan_list = list("Turn on, tune in, drop out!","Better living through chemistry!","Toke!","Don't forget to keep a smile on your lips and a song in your heart!")
	products = list(/obj/item/storage/fancy/cigarettes = 5,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/random = 4,
					/obj/item/storage/fancy/rollingpapers = 5)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2,
				   /obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
				   /obj/item/lighter/zippo = 3)
	prices = list()

/obj/machinery/economy/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	ads_list = list("Go save some lives!","The best stuff for your medbay.","Only the finest tools.","Natural chemicals!","This stuff saves lives.","Don't you want some?")
	icon_state = "wallmed"
	icon_deny = "wallmed_deny"
	icon_lightmask = "wallmed"
	icon_panel = "wallmed"
	icon_broken = "wallmed"
	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2, /obj/item/stack/medical/ointment = 2, /obj/item/reagent_containers/hypospray/autoinjector = 4, /obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4, /obj/item/reagent_containers/syringe/antiviral = 4, /obj/item/reagent_containers/food/pill/tox = 1)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/wallmed

/obj/machinery/economy/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDA's."
	slogan_list = list("Carts to go!")
	icon_state = "cart"
	icon_lightmask = "med"
	icon_deny = "cart_deny"
	icon_panel = "wide_vendor"
	products = list(/obj/item/pda =10,/obj/item/cartridge/mob_hunt_game = 25,/obj/item/cartridge/medical = 10,/obj/item/cartridge/chemistry = 10,
					/obj/item/cartridge/engineering = 10,/obj/item/cartridge/atmos = 10,/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10,/obj/item/cartridge/signal = 10)
	contraband = list(/obj/item/cartridge/clown = 1,/obj/item/cartridge/mime = 1)
	prices = list(/obj/item/pda =300,/obj/item/cartridge/mob_hunt_game = 50,/obj/item/cartridge/medical = 200,/obj/item/cartridge/chemistry = 150,/obj/item/cartridge/engineering = 100,
					/obj/item/cartridge/atmos = 75,/obj/item/cartridge/janitor = 100,/obj/item/cartridge/signal/toxins = 150,
					/obj/item/cartridge/signal = 75)
	refill_canister = /obj/item/vending_refill/cart

/obj/machinery/economy/vending/cart/free
	prices = list()



