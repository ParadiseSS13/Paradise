//general-use clothing vendors, wardrobe vendors are in another file
/obj/machinery/economy/vending/assist
	ads_list = list("Only the finest!",  "Have some tools.",  "The most robust equipment.",  "The finest gear in space!")
	products = list(/obj/item/assembly/prox_sensor = 4, /obj/item/assembly/igniter = 4, /obj/item/assembly/signaler = 4,
						/obj/item/wirecutters = 2, /obj/item/cartridge/signal = 4)
	contraband = list(/obj/item/flashlight = 4, /obj/item/assembly/timer = 2, /obj/item/assembly/voice = 2, /obj/item/assembly/health = 2)
	prices = list(/obj/item/assembly/prox_sensor = 20, /obj/item/assembly/igniter = 20, /obj/item/assembly/signaler = 30,
					/obj/item/wirecutters = 50, /obj/item/cartridge/signal = 75, /obj/item/flashlight = 40,
					/obj/item/assembly/timer = 20, /obj/item/assembly/voice = 20, /obj/item/assembly/health = 20)
	refill_canister = /obj/item/vending_refill/assist

/obj/machinery/economy/vending/assist/free
	prices = list()

/obj/machinery/economy/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat_deny"
	icon_lightmask = "smartfridge"
	icon_panel = "smartfridge"
	icon_broken = "smartfridge"
	products = list(/obj/item/reagent_containers/food/drinks/bottle/gin = 5,
					/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,
					/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,
					/obj/item/reagent_containers/food/drinks/bag/goonbag = 3,
					/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,
					/obj/item/reagent_containers/food/drinks/cans/beer = 6,
					/obj/item/reagent_containers/food/drinks/cans/ale = 6,
					/obj/item/reagent_containers/food/drinks/cans/synthanol = 15,
					/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 4,
					/obj/item/reagent_containers/food/drinks/cans/tonic = 8,
					/obj/item/reagent_containers/food/drinks/cans/cola = 8,
					/obj/item/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 30,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass = 30,
					/obj/item/reagent_containers/food/drinks/ice = 9)
	contraband = list(/obj/item/reagent_containers/food/drinks/tea = 10,
					/obj/item/reagent_containers/food/drinks/bottle/fernet = 5)
	vend_delay = 15
	slogan_list = list("I hope nobody asks me for a bloody cup o' tea...","Alcohol is humanity's friend. Would you abandon a friend?","Quite delighted to serve you!","Is nobody thirsty on this station?")
	ads_list = list("Drink up!","Booze is good for you!","Alcohol is humanity's best friend.","Quite delighted to serve you!","Care for a nice, cold beer?","Nothing cures you like booze!","Have a sip!","Have a drink!","Have a beer!","Beer is good for you!","Only the finest alcohol!","Best quality booze since 2053!","Award-winning wine!","Maximum alcohol!","Man loves beer.","A toast for progress!")
	refill_canister = /obj/item/vending_refill/boozeomat

/obj/machinery/economy/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)


/obj/machinery/economy/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses hot drinks."
	ads_list = list("Have a drink!","Drink up!","It's good for you!","Would you like a hot joe?","I'd kill for some coffee!","The best beans in the galaxy.","Only the finest brew for you.","Mmmm. Nothing like a coffee.","I like coffee, don't you?","Coffee helps you work!","Try some tea.","We hope you like the best!","Try our new chocolate!","Admin conspiracies")
	icon_state = "coffee"
	icon_lightmask = "coffee"
	icon_vend = "coffee_vend"
	icon_panel = "screen_vendor"
	item_slot = TRUE
	vend_delay = 34
	products = list(/obj/item/reagent_containers/food/drinks/coffee = 25, /obj/item/reagent_containers/food/drinks/tea = 25, /obj/item/reagent_containers/food/drinks/h_chocolate = 25,
					/obj/item/reagent_containers/food/drinks/chocolate = 10, /obj/item/reagent_containers/food/drinks/chicken_soup = 10, /obj/item/reagent_containers/food/drinks/weightloss = 10,
					/obj/item/reagent_containers/food/drinks/mug = 15, /obj/item/reagent_containers/food/drinks/mug/novelty = 5)
	contraband = list(/obj/item/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/reagent_containers/food/drinks/coffee = 80, /obj/item/reagent_containers/food/drinks/tea = 80, /obj/item/reagent_containers/food/drinks/h_chocolate = 64, /obj/item/reagent_containers/food/drinks/chocolate = 120,
				/obj/item/reagent_containers/food/drinks/chicken_soup = 100, /obj/item/reagent_containers/food/drinks/weightloss = 50, /obj/item/reagent_containers/food/drinks/mug = 75, /obj/item/reagent_containers/food/drinks/mug/novelty = 100)
	refill_canister = /obj/item/vending_refill/coffee

/obj/machinery/economy/vending/coffee/free
	prices = list()

/obj/machinery/economy/vending/coffee/item_slot_check(mob/user, obj/item/I)
	if(!(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks)))
		return FALSE
	if(!..())
		return FALSE
	if(!I.is_open_container())
		to_chat(user, "<span class='warning'>You need to open [I] before inserting it.</span>")
		return FALSE
	return TRUE

/obj/machinery/economy/vending/coffee/do_vend(datum/data/vending_product/R, mob/user)
	if(..())
		return
	var/obj/item/reagent_containers/food/drinks/vended = new R.product_path()

	if(istype(vended, /obj/item/reagent_containers/food/drinks/mug))
		var/put_on_turf = TRUE
		if(user && iscarbon(user) && user.Adjacent(src))
			if(user.put_in_hands(vended))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
		return

	vended.reagents.trans_to(inserted_item, vended.reagents.total_volume)
	if(vended.reagents.total_volume)
		var/put_on_turf = TRUE
		if(user && iscarbon(user) && user.Adjacent(src))
			if(user.put_in_hands(vended))
				put_on_turf = FALSE
		if(put_on_turf)
			var/turf/T = get_turf(src)
			vended.forceMove(T)
	else
		qdel(vended)


/obj/machinery/economy/vending/hatdispenser
	name = "\improper Hatlord 9000"
	desc = "It doesn't seem the slightest bit unusual. This frustrates you immensely."
	icon_state = "hats"
	icon_lightmask = "hats"
	icon_panel = "syndi"
	icon_broken = "wide_vendor"
	ads_list = list("Warning, not all hats are dog/monkey compatible. Apply forcefully with care.","Apply directly to the forehead.","Who doesn't love spending cash on hats?!","From the people that brought you collectable hat crates, Hatlord!")
	products = list(/obj/item/clothing/head/that = 2,
					/obj/item/clothing/head/bowlerhat = 10,
					/obj/item/clothing/head/beaverhat = 10,
					/obj/item/clothing/head/boaterhat = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/cowboyhat = 10,
					/obj/item/clothing/head/cowboyhat/black = 10,
					/obj/item/clothing/head/fez = 10,
					/obj/item/clothing/head/soft/solgov = 10,
					/obj/item/clothing/head/beret = 10,
					/obj/item/clothing/head/beret/black = 10,
					/obj/item/clothing/head/hairflower = 10,
					/obj/item/clothing/head/mailman = 1,
					/obj/item/clothing/head/soft/rainbow = 1)
	contraband = list(/obj/item/clothing/head/bearpelt = 5)
	prices = list(/obj/item/clothing/head/that = 30,
				/obj/item/clothing/head/bowlerhat = 20,
				/obj/item/clothing/head/beaverhat = 20,
				/obj/item/clothing/head/boaterhat = 20,
				/obj/item/clothing/head/fedora = 20,
				/obj/item/clothing/head/cowboyhat = 20,
				/obj/item/clothing/head/cowboyhat/black = 20,
				/obj/item/clothing/head/fez = 20,
				/obj/item/clothing/head/soft/solgov = 20,
				/obj/item/clothing/head/beret = 20,
				/obj/item/clothing/head/beret/black = 20,
				/obj/item/clothing/head/hairflower = 20,
				/obj/item/clothing/head/mailman = 60,
				/obj/item/clothing/head/soft/rainbow = 40,
				/obj/item/clothing/head/bearpelt = 30)
	refill_canister = /obj/item/vending_refill/hatdispenser

/obj/machinery/economy/vending/suitdispenser
	name = "\improper Suitlord 9000"
	desc = "You wonder for a moment why all of your shirts and pants come conjoined. This hurts your head and you stop thinking about it."
	icon_state = "suits"
	icon_lightmask = "suits"
	icon_panel = "syndi"
	icon_broken = "wide_vendor"
	ads_list = list("Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*","Blood of your enemies washes right out!","Who are YOU wearing?","Look dapper! Look like an idiot!","Dont carry your size? How about you shave off some pounds you fat lazy- *BZZT*")
	products = list(/obj/item/clothing/under/color/black = 10,
					/obj/item/clothing/under/dress/blackskirt = 10,
					/obj/item/clothing/under/color/grey = 10,
					/obj/item/clothing/under/color/white = 10,
					/obj/item/clothing/under/color/darkred = 10,
					/obj/item/clothing/under/color/red = 10,
					/obj/item/clothing/under/color/lightred = 10,
					/obj/item/clothing/under/color/brown = 10,
					/obj/item/clothing/under/color/orange = 10,
					/obj/item/clothing/under/color/lightbrown = 10,
					/obj/item/clothing/under/color/yellow = 10,
					/obj/item/clothing/under/color/yellowgreen = 10,
					/obj/item/clothing/under/color/lightgreen = 10,
					/obj/item/clothing/under/color/green = 10,
					/obj/item/clothing/under/color/aqua = 10,
					/obj/item/clothing/under/color/darkblue = 10,
					/obj/item/clothing/under/color/blue = 10,
					/obj/item/clothing/under/color/lightblue = 10,
					/obj/item/clothing/under/color/purple = 10,
					/obj/item/clothing/under/color/lightpurple = 10,
					/obj/item/clothing/under/color/pink = 10,
					/obj/item/clothing/under/color/rainbow = 1)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 5,
					/obj/item/clothing/under/color/orange/prison = 5)
	prices = list(/obj/item/clothing/under/color/black = 30,
				/obj/item/clothing/under/dress/blackskirt = 30,
				/obj/item/clothing/under/color/grey = 30,
				/obj/item/clothing/under/color/white = 50,
				/obj/item/clothing/under/color/darkred = 50,
				/obj/item/clothing/under/color/red = 50,
				/obj/item/clothing/under/color/lightred = 50,
				/obj/item/clothing/under/color/brown = 30,
				/obj/item/clothing/under/color/orange = 50,
				/obj/item/clothing/under/color/lightbrown = 30,
				/obj/item/clothing/under/color/yellow = 50,
				/obj/item/clothing/under/color/yellowgreen = 50,
				/obj/item/clothing/under/color/lightgreen = 50,
				/obj/item/clothing/under/color/green = 50,
				/obj/item/clothing/under/color/aqua = 50,
				/obj/item/clothing/under/color/darkblue = 50,
				/obj/item/clothing/under/color/blue = 50,
				/obj/item/clothing/under/color/lightblue = 30,
				/obj/item/clothing/under/color/purple = 50,
				/obj/item/clothing/under/color/lightpurple = 50,
				/obj/item/clothing/under/color/pink = 50,
				/obj/item/clothing/under/color/rainbow = 100,
				/obj/item/clothing/under/syndicate/tacticool = 75,
				/obj/item/clothing/under/color/orange/prison = 75)
	refill_canister = /obj/item/vending_refill/suitdispenser

/obj/machinery/economy/vending/shoedispenser
	name = "\improper Shoelord 9000"
	desc = "Wow, hatlord looked fancy, suitlord looked streamlined, and this is just normal. The guy who designed these must be an idiot."
	icon_state = "shoes"
	icon_lightmask = "shoes"
	icon_panel = "syndi"
	icon_broken = "wide_vendor"
	ads_list = list("Put your foot down!","One size fits all!","IM WALKING ON SUNSHINE!","No hobbits allowed.","NO PLEASE WILLY, DONT HURT ME- *BZZT*")
	products = list(/obj/item/clothing/shoes/black = 10,
					/obj/item/clothing/shoes/brown = 10,
					/obj/item/clothing/shoes/blue = 10,
					/obj/item/clothing/shoes/green = 10,
					/obj/item/clothing/shoes/yellow = 10,
					/obj/item/clothing/shoes/purple = 10,
					/obj/item/clothing/shoes/red = 10,
					/obj/item/clothing/shoes/white = 10,
					/obj/item/clothing/shoes/laceup = 10,
					/obj/item/clothing/shoes/sandal = 10,
					/obj/item/clothing/shoes/jackboots = 10,
					/obj/item/clothing/shoes/winterboots = 10,
					/obj/item/clothing/shoes/cowboy = 10,
					/obj/item/clothing/shoes/cowboy/black = 10,
					/obj/item/clothing/shoes/rainbow = 1)
	contraband = list(/obj/item/clothing/shoes/orange = 5)
	prices= list(/obj/item/clothing/shoes/black = 20,
				/obj/item/clothing/shoes/brown = 20,
				/obj/item/clothing/shoes/blue = 20,
				/obj/item/clothing/shoes/green = 20,
				/obj/item/clothing/shoes/yellow = 20,
				/obj/item/clothing/shoes/purple = 20,
				/obj/item/clothing/shoes/red = 20,
				/obj/item/clothing/shoes/white = 20,
				/obj/item/clothing/shoes/laceup = 40,
				/obj/item/clothing/shoes/sandal = 20,
				/obj/item/clothing/shoes/jackboots = 20,
				/obj/item/clothing/shoes/winterboots = 20,
				/obj/item/clothing/shoes/cowboy = 20,
				/obj/item/clothing/shoes/cowboy/black = 20,
				/obj/item/clothing/shoes/orange = 40,
				/obj/item/clothing/shoes/rainbow = 40)
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
	products = list(/obj/item/clothing/suit/ianshirt = 2,
					/obj/item/clothing/under/misc/overalls = 2,
					/obj/item/clothing/under/misc/mailman = 1,
					/obj/item/clothing/under/suit/navy = 2,
					/obj/item/clothing/under/suit/really_black = 2,
					/obj/item/clothing/under/suit/checkered = 1,
					/obj/item/clothing/suit/storage/lawyer/blackjacket = 2,
					/obj/item/clothing/under/pants/jeans = 3,
					/obj/item/clothing/under/pants/classicjeans = 3,
					/obj/item/clothing/under/pants/mustangjeans = 1,
					/obj/item/clothing/under/pants/camo = 3,
					/obj/item/clothing/under/pants/blackjeans = 3,
					/obj/item/clothing/under/pants/khaki = 3,
					/obj/item/clothing/under/pants/white = 3,
					/obj/item/clothing/under/pants/red = 3,
					/obj/item/clothing/under/pants/black = 3,
					/obj/item/clothing/under/pants/tan = 3,
					/obj/item/clothing/under/pants/blue = 3,
					/obj/item/clothing/under/pants/track = 3,
					/obj/item/clothing/suit/jacket/miljacket = 3,
					/obj/item/clothing/suit/jacket/miljacket/white = 3,
					/obj/item/clothing/suit/jacket/miljacket/desert = 3,
					/obj/item/clothing/suit/jacket/miljacket/navy = 3,
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
					/obj/item/clothing/accessory/scarf/red = 3,
					/obj/item/clothing/accessory/scarf/green = 3,
					/obj/item/clothing/accessory/scarf/darkblue = 3,
					/obj/item/clothing/accessory/scarf/purple = 3,
					/obj/item/clothing/accessory/scarf/yellow = 3,
					/obj/item/clothing/accessory/scarf/orange = 3,
					/obj/item/clothing/accessory/scarf/lightblue = 3,
					/obj/item/clothing/accessory/scarf/white = 3,
					/obj/item/clothing/accessory/scarf/black = 3,
					/obj/item/clothing/accessory/scarf/zebra = 3,
					/obj/item/clothing/accessory/scarf/christmas = 3,
					/obj/item/clothing/accessory/stripedredscarf = 3,
					/obj/item/clothing/accessory/stripedbluescarf = 3,
					/obj/item/clothing/accessory/stripedgreenscarf = 3,
					/obj/item/clothing/accessory/blue = 3,
					/obj/item/clothing/accessory/red = 3,
					/obj/item/clothing/accessory/black = 3,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/under/dress/sundress = 2,
					/obj/item/clothing/under/dress/stripeddress = 2,
					/obj/item/clothing/under/dress/sailordress = 2,
					/obj/item/clothing/under/dress/redeveninggown = 2,
					/obj/item/clothing/under/dress/blacktango = 2,
					/obj/item/clothing/suit/hooded/wintercoat = 3,
					/obj/item/clothing/suit/jacket = 3,
					/obj/item/clothing/suit/hooded/hoodie = 3,
					/obj/item/clothing/suit/hooded/hoodie/blue = 3,
					/obj/item/clothing/suit/jacket/motojacket = 3,
					/obj/item/clothing/suit/jacket/leather = 1,
					/obj/item/clothing/suit/blacktrenchcoat = 3,
					/obj/item/clothing/suit/browntrenchcoat = 3,
					/obj/item/clothing/mask/bandana = 2,
					/obj/item/clothing/mask/bandana/black = 2,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/sunglasses_fake = 2,
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

	prices = list(/obj/item/clothing/under/suit/navy = 75,
				/obj/item/clothing/under/misc/overalls = 75,
				/obj/item/clothing/under/suit/checkered = 125,
				/obj/item/clothing/under/suit/really_black = 75,
				/obj/item/clothing/suit/storage/lawyer/blackjacket = 75,
				/obj/item/clothing/under/pants/jeans = 75,
				/obj/item/clothing/under/pants/classicjeans = 75,
				/obj/item/clothing/under/pants/mustangjeans = 100,
				/obj/item/clothing/under/pants/camo = 75,
				/obj/item/clothing/under/pants/blackjeans = 75,
				/obj/item/clothing/under/pants/khaki = 75,
				/obj/item/clothing/under/pants/white = 75,
				/obj/item/clothing/under/pants/red = 75,
				/obj/item/clothing/under/pants/black = 75,
				/obj/item/clothing/under/pants/tan = 75,
				/obj/item/clothing/under/pants/blue = 75,
				/obj/item/clothing/under/pants/track = 75,
				/obj/item/clothing/suit/jacket/miljacket = 75,
				/obj/item/clothing/suit/jacket/miljacket/white = 75,
				/obj/item/clothing/suit/jacket/miljacket/desert = 75,
				/obj/item/clothing/suit/jacket/miljacket/navy = 75,
				/obj/item/clothing/head/beanie = 30,
				/obj/item/clothing/head/beanie/black = 30,
				/obj/item/clothing/head/beanie/red = 30,
				/obj/item/clothing/head/beanie/green = 30,
				/obj/item/clothing/head/beanie/darkblue = 30,
				/obj/item/clothing/head/beanie/purple = 30,
				/obj/item/clothing/head/beanie/yellow = 30,
				/obj/item/clothing/head/beanie/orange = 30,
				/obj/item/clothing/head/beanie/cyan = 30,
				/obj/item/clothing/head/beanie/christmas = 40,
				/obj/item/clothing/head/beanie/striped = 40,
				/obj/item/clothing/head/beanie/stripedred = 40,
				/obj/item/clothing/head/beanie/stripedblue = 40,
				/obj/item/clothing/head/beanie/stripedgreen = 40,
				/obj/item/clothing/head/beanie/rasta = 40,
				/obj/item/clothing/accessory/scarf/red = 20,
				/obj/item/clothing/accessory/scarf/green = 20,
				/obj/item/clothing/accessory/scarf/darkblue = 20,
				/obj/item/clothing/accessory/scarf/purple = 20,
				/obj/item/clothing/accessory/scarf/yellow = 20,
				/obj/item/clothing/accessory/scarf/orange = 20,
				/obj/item/clothing/accessory/scarf/lightblue = 20,
				/obj/item/clothing/accessory/scarf/white = 20,
				/obj/item/clothing/accessory/scarf/black = 20,
				/obj/item/clothing/accessory/scarf/zebra = 20,
				/obj/item/clothing/accessory/scarf/christmas = 20,
				/obj/item/clothing/accessory/stripedredscarf = 20,
				/obj/item/clothing/accessory/stripedbluescarf = 20,
				/obj/item/clothing/accessory/stripedgreenscarf = 20,
				/obj/item/clothing/accessory/blue = 20,
				/obj/item/clothing/accessory/red = 20,
				/obj/item/clothing/accessory/black = 20,
				/obj/item/clothing/accessory/waistcoat = 20,
				/obj/item/clothing/under/dress/sundress = 75,
				/obj/item/clothing/under/dress/stripeddress = 75,
				/obj/item/clothing/under/dress/sailordress = 75,
				/obj/item/clothing/under/dress/redeveninggown = 100,
				/obj/item/clothing/under/dress/blacktango = 100,
				/obj/item/clothing/suit/hooded/wintercoat = 75,
				/obj/item/clothing/suit/jacket = 75,
				/obj/item/clothing/suit/hooded/hoodie = 75,
				/obj/item/clothing/suit/hooded/hoodie/blue = 75,
				/obj/item/clothing/suit/jacket/motojacket = 75,
				/obj/item/clothing/suit/jacket/leather = 100,
				/obj/item/clothing/suit/blacktrenchcoat = 75,
				/obj/item/clothing/suit/browntrenchcoat = 75,
				/obj/item/clothing/glasses/regular = 20,
				/obj/item/clothing/glasses/sunglasses_fake = 20,
				/obj/item/clothing/suit/ianshirt = 75,
				/obj/item/clothing/mask/bandana = 30,
				/obj/item/clothing/mask/bandana/black = 30,
				/obj/item/clothing/gloves/fingerless = 10,
				/obj/item/storage/belt/fannypack = 50,
				/obj/item/storage/belt/fannypack/blue = 50,
				/obj/item/storage/belt/fannypack/red = 50,
				/obj/item/clothing/suit/mantle = 20,
				/obj/item/clothing/suit/mantle/old = 20,
				/obj/item/clothing/suit/mantle/regal = 30,
				/obj/item/clothing/under/misc/mailman = 100)

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
					/obj/item/dnainjector/comic = 1,
					/obj/item/implanter/sad_trombone = 1,
					/obj/item/clothing/suit/wizrobe/mime = 1,
					/obj/item/clothing/head/wizard/mime = 1,
					/obj/item/clothing/mask/gas/mime/wizard = 1,
					/obj/item/clothing/shoes/sandal/marisa = 1,
					/obj/item/staff = 2)
	contraband = list(/obj/item/reagent_containers/glass/bottle/wizarditis = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	tiltable = FALSE  // don't let a poor wizard screw themselves

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
					/obj/item/clothing/under/dress/schoolgirl = 1,
					/obj/item/clothing/suit/toggle/owlwings = 1,
					/obj/item/clothing/under/costume/owl = 1,
					/obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 1,
					/obj/item/clothing/under/costume/griffin = 1,
					/obj/item/clothing/shoes/griffin = 1,
					/obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/under/suit/black = 1,
					/obj/item/clothing/head/that = 1,
					/obj/item/clothing/under/costume/kilt = 1,
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
					/obj/item/clothing/accessory/cowboyshirt = 1,
					/obj/item/clothing/accessory/cowboyshirt/navy = 1,
					/obj/item/clothing/under/costume/pirate = 1,
					/obj/item/clothing/suit/pirate_brown = 1,
					/obj/item/clothing/suit/pirate_black =1,
					/obj/item/clothing/under/costume/pirate_rags =1,
					/obj/item/clothing/head/pirate = 1,
					/obj/item/clothing/under/costume/soviet = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1,
					/obj/item/clothing/suit/holidaypriest = 1,
					/obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1,
					/obj/item/clothing/under/dress/sundress = 1,
					/obj/item/clothing/head/witchwig = 1,
					/obj/item/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1,
					/obj/item/clothing/head/wizard/fake = 1,
					/obj/item/staff = 3,
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
					/obj/item/clothing/accessory/horrible = 1,
					/obj/item/clothing/under/costume/maid = 1,
					/obj/item/clothing/under/costume/janimaid = 1,
					/obj/item/clothing/under/costume/jester = 1,
					/obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/pants/camo = 1,
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
					/obj/item/clothing/under/misc/orangehawaiianshirt = 1,
					/obj/item/clothing/suit/hgpirate = 1,
					/obj/item/clothing/head/hgpiratecap = 1,
					/obj/item/clothing/head/helmet/roman/fake = 1,
					/obj/item/clothing/head/helmet/roman/legionaire/fake = 1,
					/obj/item/clothing/under/costume/roman = 1,
					/obj/item/clothing/shoes/roman = 1,
					/obj/item/shield/riot/roman/fake = 1,
					/obj/item/clothing/under/costume/cuban_suit = 1,
					/obj/item/clothing/head/cuban_hat = 1)
	contraband = list(/obj/item/clothing/suit/judgerobe = 1,
					/obj/item/clothing/head/powdered_wig = 1,
					/obj/item/gun/magic/wand = 1,
					/obj/item/clothing/mask/balaclava=1,
					/obj/item/clothing/mask/horsehead = 2)

	prices = list(/obj/item/clothing/suit/chickensuit = 100,
					/obj/item/clothing/head/chicken = 50,
					/obj/item/clothing/under/costume/gladiator = 100,
					/obj/item/clothing/head/helmet/gladiator = 50,
					/obj/item/clothing/under/misc/gimmick/rank/captain/suit = 100,
					/obj/item/clothing/head/flatcap = 30,
					/obj/item/clothing/suit/storage/labcoat/mad = 75,
					/obj/item/clothing/glasses/gglasses = 20,
					/obj/item/clothing/under/dress/schoolgirl = 75,
					/obj/item/clothing/suit/toggle/owlwings = 120,
					/obj/item/clothing/under/costume/owl = 100,
					/obj/item/clothing/mask/gas/owl_mask = 50,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 120,
					/obj/item/clothing/under/costume/griffin = 100,
					/obj/item/clothing/shoes/griffin = 30,
					/obj/item/clothing/head/griffin = 50,
					/obj/item/clothing/under/suit/black = 75,
					/obj/item/clothing/head/that = 30,
					/obj/item/clothing/under/costume/kilt = 75,
					/obj/item/clothing/glasses/monocle = 30,
					/obj/item/clothing/head/bowlerhat = 20,
					/obj/item/cane = 50,
					/obj/item/clothing/under/misc/sl_suit = 75,
					/obj/item/clothing/mask/fakemoustache = 20,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 100,
					/obj/item/clothing/head/plaguedoctorhat = 40,
					/obj/item/clothing/mask/gas/plaguedoctor = 50,
					/obj/item/clothing/suit/apron = 75,
					/obj/item/clothing/under/misc/waiter = 75,
					/obj/item/clothing/accessory/cowboyshirt = 75,
					/obj/item/clothing/accessory/cowboyshirt/navy = 75,
					/obj/item/clothing/under/costume/pirate = 100,
					/obj/item/clothing/suit/pirate_brown = 100,
					/obj/item/clothing/suit/pirate_black = 100,
					/obj/item/clothing/under/costume/pirate_rags = 100,
					/obj/item/clothing/head/pirate = 50,
					/obj/item/clothing/under/costume/soviet = 100,
					/obj/item/clothing/head/ushanka = 50,
					/obj/item/clothing/suit/imperium_monk = 120,
					/obj/item/clothing/mask/gas/cyborg = 50,
					/obj/item/clothing/suit/holidaypriest = 100,
					/obj/item/clothing/head/wizard/marisa/fake = 50,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 100,
					/obj/item/clothing/under/dress/sundress = 75,
					/obj/item/clothing/head/witchwig = 50,
					/obj/item/staff/broom = 50,
					/obj/item/clothing/suit/wizrobe/fake = 75,
					/obj/item/clothing/head/wizard/fake = 75,
					/obj/item/staff = 50,
					/obj/item/clothing/mask/gas/clown_hat/sexy = 100,
					/obj/item/clothing/under/rank/civilian/clown/sexy = 100,
					/obj/item/clothing/mask/gas/sexymime = 100,
					/obj/item/clothing/under/rank/civilian/mime/sexy = 100,
					/obj/item/clothing/mask/face/bat = 100,
					/obj/item/clothing/mask/face/bee = 100,
					/obj/item/clothing/mask/face/bear = 100,
					/obj/item/clothing/mask/face/raven = 100,
					/obj/item/clothing/mask/face/jackal = 100,
					/obj/item/clothing/mask/face/fox = 100,
					/obj/item/clothing/mask/face/tribal = 100,
					/obj/item/clothing/mask/face/rat = 100,
					/obj/item/clothing/suit/apron/overalls = 75,
					/obj/item/clothing/head/rabbitears = 75,
					/obj/item/clothing/head/sombrero = 40,
					/obj/item/clothing/suit/poncho = 75,
					/obj/item/clothing/suit/poncho/green = 75,
					/obj/item/clothing/suit/poncho/red = 75,
					/obj/item/clothing/accessory/horrible = 30,
					/obj/item/clothing/under/costume/maid = 75,
					/obj/item/clothing/under/costume/janimaid = 75,
					/obj/item/clothing/under/costume/jester = 100,
					/obj/item/clothing/head/jester = 50,
					/obj/item/clothing/under/pants/camo = 75,
					/obj/item/clothing/shoes/singery = 20,
					/obj/item/clothing/under/costume/singery = 75,
					/obj/item/clothing/shoes/singerb = 20,
					/obj/item/clothing/under/costume/singerb = 75,
					/obj/item/clothing/suit/hooded/carp_costume = 120,
					/obj/item/clothing/suit/hooded/bee_costume = 120,
					/obj/item/clothing/suit/snowman = 120,
					/obj/item/clothing/head/snowman = 50,
					/obj/item/clothing/head/cueball = 50,
					/obj/item/clothing/under/misc/scratch = 75,
					/obj/item/clothing/under/dress/victdress = 100,
					/obj/item/clothing/under/dress/victdress/red = 100,
					/obj/item/clothing/suit/victcoat = 100,
					/obj/item/clothing/suit/victcoat/red = 100,
					/obj/item/clothing/under/suit/victsuit = 100,
					/obj/item/clothing/under/suit/victsuit/redblk = 100,
					/obj/item/clothing/under/suit/victsuit/red = 100,
					/obj/item/clothing/suit/tailcoat = 75,
					/obj/item/clothing/under/costume/tourist_suit = 75,
					/obj/item/clothing/suit/draculacoat = 100,
					/obj/item/clothing/head/zepelli = 50,
					/obj/item/clothing/under/misc/redhawaiianshirt = 75,
					/obj/item/clothing/under/misc/pinkhawaiianshirt = 75,
					/obj/item/clothing/under/misc/bluehawaiianshirt = 75,
					/obj/item/clothing/under/misc/orangehawaiianshirt = 75,
					/obj/item/clothing/suit/hgpirate = 125,
					/obj/item/clothing/head/hgpiratecap = 75,
					/obj/item/clothing/head/helmet/roman/fake = 75,
					/obj/item/clothing/head/helmet/roman/legionaire/fake = 75,
					/obj/item/clothing/under/costume/roman = 125,
					/obj/item/clothing/shoes/roman = 40,
					/obj/item/shield/riot/roman/fake = 75,
					/obj/item/clothing/under/costume/cuban_suit = 125,
					/obj/item/clothing/head/cuban_hat = 75)
	refill_canister = /obj/item/vending_refill/autodrobe


//Generic food vendors


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
	products = list(/obj/item/reagent_containers/food/drinks/cans/sodawater = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/cans/cola = 7)
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
	products = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 6, /obj/item/reagent_containers/food/drinks/dry_ramen = 6, /obj/item/reagent_containers/food/snacks/chips = 6,
					/obj/item/reagent_containers/food/snacks/sosjerky = 6,/obj/item/reagent_containers/food/snacks/no_raisin = 6, /obj/item/reagent_containers/food/snacks/pistachios = 6,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 6, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 6, /obj/item/reagent_containers/food/snacks/tastybread = 6, /obj/item/reagent_containers/food/snacks/stroopwafel = 2)
	contraband = list(/obj/item/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/reagent_containers/food/snacks/candy/candybar = 64, /obj/item/reagent_containers/food/drinks/dry_ramen = 32, /obj/item/reagent_containers/food/snacks/chips = 64,
					/obj/item/reagent_containers/food/snacks/sosjerky = 64, /obj/item/reagent_containers/food/snacks/no_raisin = 80, /obj/item/reagent_containers/food/snacks/pistachios = 80,
					/obj/item/reagent_containers/food/snacks/spacetwinkie = 64, /obj/item/reagent_containers/food/snacks/cheesiehonkers = 64,/obj/item/reagent_containers/food/snacks/tastybread = 80,
					/obj/item/reagent_containers/food/snacks/stroopwafel = 100, /obj/item/reagent_containers/food/snacks/syndicake = 175) //syndicakes are genuinely kind of powerful
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
	prices = list(/obj/item/reagent_containers/food/snacks/chinese/chowmein = 125, /obj/item/reagent_containers/food/snacks/chinese/tao = 125, /obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball = 125, /obj/item/reagent_containers/food/snacks/chinese/newdles = 100,
					/obj/item/reagent_containers/food/snacks/chinese/rice = 100, /obj/item/reagent_containers/food/snacks/fortunecookie = 50)
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
	products = list(/obj/item/reagent_containers/food/drinks/cans/cola = 10, /obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 10, /obj/item/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 10, /obj/item/reagent_containers/food/drinks/cans/grape_juice = 10, /obj/item/reagent_containers/glass/beaker/waterbottle = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/cans/thirteenloko = 5)
	prices = list(/obj/item/reagent_containers/food/drinks/cans/cola = 45, /obj/item/reagent_containers/food/drinks/cans/space_mountain_wind = 50,
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb = 50, /obj/item/reagent_containers/food/drinks/cans/starkist = 50,
					/obj/item/reagent_containers/food/drinks/cans/space_up = 50, /obj/item/reagent_containers/food/drinks/cans/grape_juice = 50, /obj/item/reagent_containers/glass/beaker/waterbottle = 20)
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
	products = list(/obj/item/stack/cable_coil/random = 10,
					/obj/item/toner = 4,
					/obj/item/camera = 4,
					/obj/item/camera_film = 6,
					/obj/item/storage/photo_album = 2,
					/obj/item/stack/wrapping_paper = 4,
					/obj/item/stack/packageWrap = 4,
					/obj/item/c_tube = 10,
					/obj/item/hand_labeler = 4,
					/obj/item/stack/tape_roll = 5,
					/obj/item/paper = 10,
					/obj/item/storage/fancy/crayons = 4,
					/obj/item/pen = 5,
					/obj/item/pen/blue = 5,
					/obj/item/pen/red = 5,
					/obj/item/pen/fancy = 2)
	contraband = list(/obj/item/toy/crayon/mime = 1,
					/obj/item/toy/crayon/rainbow = 1,
					/obj/item/poster/random_contraband = 5)
	prices = list(/obj/item/stack/cable_coil/random = 20,
				/obj/item/toner = 40,
				/obj/item/pen/fancy = 40)

/obj/machinery/economy/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool_deny"
	icon_lightmask = "tool"
	icon_panel = "generic"
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, rad = 0, fire = 100, acid = 70)
	resistance_flags = FIRE_PROOF
	products = list(/obj/item/crowbar = 5,
					/obj/item/screwdriver = 5,
					/obj/item/weldingtool = 3,
					/obj/item/wirecutters = 5,
					/obj/item/wrench = 5,
					/obj/item/analyzer = 5,
					/obj/item/t_scanner = 5,
					/obj/item/stack/cable_coil/random = 10,
					/obj/item/clothing/gloves/color/yellow = 1,
					/obj/item/crowbar/large = 1)
	contraband = list(/obj/item/clothing/gloves/color/fyellow = 2,
					/obj/item/weldingtool/hugetank = 2)
	prices = list(/obj/item/crowbar = 75,
				/obj/item/screwdriver = 50,
				/obj/item/weldingtool = 100,
				/obj/item/wirecutters = 50,
				/obj/item/wrench = 75,
				/obj/item/analyzer = 25,
				/obj/item/t_scanner = 25,
				/obj/item/stack/cable_coil/random = 20,
				/obj/item/clothing/gloves/color/yellow = 250,
				/obj/item/weldingtool/hugetank = 120,
				/obj/item/crowbar/large = 150)
	refill_canister = /obj/item/vending_refill/youtool

/// we want a free version for engineering to use
/obj/machinery/economy/vending/tool/free
	prices = list()
	desc = "Free Tools for tools."

/obj/machinery/economy/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	slogan_list = list("Stop by for all your animal's needs!","Cuddly pets deserve a stylish collar!","Pets in space, what could be more adorable?","Freshest fish eggs in the system!","Rocks are the perfect pet, buy one today!")
	ads_list = list("House-training costs extra!","Now with 1000% more cat hair!","Allergies are a sign of weakness!","Dogs are man's best friend. Remember that Vulpkanin!"," Heat lamps for Unathi!"," Vox-y want a cracker?")
	vend_delay = 15
	icon_state = "crittercare"
	icon_lightmask = "crittercare"
	icon_panel = "drobe"
	products = list(/obj/item/petcollar = 5, /obj/item/storage/firstaid/aquatic_kit/full =5, /obj/item/fish_eggs/goldfish = 5,
					/obj/item/fish_eggs/clownfish = 5, /obj/item/fish_eggs/shark = 5, /obj/item/fish_eggs/feederfish = 10,
					/obj/item/fish_eggs/salmon = 5, /obj/item/fish_eggs/catfish = 5, /obj/item/fish_eggs/glofish = 5,
					/obj/item/fish_eggs/electric_eel = 5, /obj/item/fish_eggs/shrimp = 10, /obj/item/toy/pet_rock = 5,
					/obj/item/toy/pet_rock/fred = 1, /obj/item/toy/pet_rock/roxie = 1,
					)
	prices = list(/obj/item/petcollar = 75, /obj/item/storage/firstaid/aquatic_kit/full = 50, /obj/item/fish_eggs/goldfish = 10,
					/obj/item/fish_eggs/clownfish = 30, /obj/item/fish_eggs/shark = 30, /obj/item/fish_eggs/feederfish = 20,
					/obj/item/fish_eggs/salmon = 30, /obj/item/fish_eggs/catfish = 30, /obj/item/fish_eggs/glofish = 10,
					/obj/item/fish_eggs/electric_eel = 30, /obj/item/fish_eggs/shrimp = 10, /obj/item/toy/pet_rock = 50,
					/obj/item/toy/pet_rock/fred = 75, /obj/item/toy/pet_rock/roxie = 75,
					)
	contraband = list(/obj/item/fish_eggs/babycarp = 5)
	refill_canister = /obj/item/vending_refill/crittercare

/obj/machinery/economy/vending/crittercare/free
	prices = list()

/obj/machinery/economy/vending/cigarette
	name = "\improper ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	slogan_list = list("Space cigs taste good like a cigarette should.","I'd rather toolbox than switch.","Smoke!","Don't believe the reports - smoke today!")
	ads_list = list("Probably not bad for you!","Don't believe the scientists!","It's good for you!","Don't quit, buy more!","Smoke!","Nicotine heaven.","Best cigarettes since 2150.","Award-winning cigs.")
	vend_delay = 34
	icon_state = "cigs"
	icon_lightmask = "cigs"
	products = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/clothing/mask/cigarette/cigar/havana = 2,
		/obj/item/reagent_containers/food/pill/patch/nicotine = 10,
		/obj/item/storage/box/matches = 10,
		/obj/item/lighter/random = 4,
		/obj/item/lighter/zippo = 2)
	contraband = list(/obj/item/storage/fancy/rollingpapers = 5)
	prices = list(/obj/item/storage/fancy/cigarettes/cigpack_robust = 25,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 25,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 35,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 60,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 80,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 120,
		/obj/item/reagent_containers/food/pill/patch/nicotine = 70,
		/obj/item/storage/box/matches = 20,
		/obj/item/lighter/random = 40,
		/obj/item/lighter/zippo = 80,
		/obj/item/storage/fancy/rollingpapers = 30,
		/obj/item/clothing/mask/cigarette/cigar/havana = 80)
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
					/obj/item/storage/fancy/rollingpapers = 5)
	contraband = list(/obj/item/lighter/zippo = 4)

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
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
					/obj/item/clothing/mask/cigarette/cigar/havana = 2,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/zippo = 4,
					/obj/item/storage/fancy/rollingpapers = 5)
	contraband = list()
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
	tiltable = FALSE
	products = list(/obj/item/stack/medical/bruise_pack = 2, /obj/item/stack/medical/ointment = 2, /obj/item/reagent_containers/hypospray/autoinjector = 4, /obj/item/healthanalyzer = 1)
	contraband = list(/obj/item/reagent_containers/syringe/charcoal = 4, /obj/item/reagent_containers/syringe/antiviral = 4, /obj/item/reagent_containers/food/pill/tox = 1)
	armor = list(melee = 50, bullet = 20, laser = 20, energy = 20, bomb = 0, rad = 0, fire = 100, acid = 70)
	//this shouldn't be priced
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
	products = list(/obj/item/pda =10,/obj/item/cartridge/mob_hunt_game = 25, /obj/item/cartridge/medical = 10, /obj/item/cartridge/chemistry = 10,
					/obj/item/cartridge/engineering = 10, /obj/item/cartridge/atmos = 10, /obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10, /obj/item/cartridge/signal = 10)
	contraband = list(/obj/item/cartridge/clown = 1,/obj/item/cartridge/mime = 1)
	prices = list(/obj/item/pda = 300, /obj/item/cartridge/mob_hunt_game = 50, /obj/item/cartridge/medical = 200,
					/obj/item/cartridge/chemistry = 150,/obj/item/cartridge/engineering = 100, /obj/item/cartridge/atmos = 75,
					/obj/item/cartridge/janitor = 100,/obj/item/cartridge/signal/toxins = 150, /obj/item/cartridge/signal = 75)
	refill_canister = /obj/item/vending_refill/cart

/obj/machinery/economy/vending/cart/free
	prices = list()
