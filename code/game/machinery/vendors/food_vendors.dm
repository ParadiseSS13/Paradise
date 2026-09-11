/obj/machinery/economy/vending/sustenance
	name = "\improper Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	slogan_list = list(
		"Enjoy your meal.",
		"Enough calories to support strenuous labor.",
	)

	ads_list = list(
		"The healthiest!",
		"Award-winning chocolate bars!",
		"Mmm! So good!",
		"Oh my god it's so juicy!",
		"Have a snack.",
		"Snacks are good for you!",
		"Have some more Getmore!",
		"Best quality snacks straight from mars.",
		"We love chocolate!",
		"Try our new jerky!",
	)

	icon_state = "sustenance"
	icon_lightmask = "nutri"
	icon_off = "nutri"
	icon_panel = "thin_vendor"
	category = VENDOR_TYPE_FOOD
	products = list(
		/obj/item/food/tofu = 24,
		/obj/item/reagent_containers/drinks/ice = 12,
		/obj/item/food/candy/candy_corn = 6,
	)

	contraband = list(
		/obj/item/kitchen/knife = 6,
		/obj/item/reagent_containers/drinks/coffee = 12,
		/obj/item/tank/internals/emergency_oxygen = 6,
		/obj/item/clothing/mask/breath = 6,
	)

	refill_canister = /obj/item/vending_refill/sustenance

/obj/machinery/economy/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	slogan_list = list(
		"Try our new nougat bar!",
		"Twice the calories for half the price!",
	)

	ads_list = list(
		"The healthiest!",
		"Award-winning chocolate bars!",
		"Mmm! So good!",
		"Oh my god it's so juicy!",
		"Have a snack.",
		"Snacks are good for you!",
		"Have some more Getmore!",
		"Best quality snacks straight from mars.",
		"We love chocolate!",
		"Try our new jerky!",
	)

	icon_state = "snack"
	icon_lightmask = "nutri"
	icon_off = "nutri"
	icon_panel = "thin_vendor"
	category = VENDOR_TYPE_FOOD
	products = list(
		/obj/item/food/candy/candybar = 6,
		/obj/item/reagent_containers/drinks/dry_ramen = 6,
		/obj/item/food/chips = 6,
		/obj/item/food/twimsts = 6,
		/obj/item/food/sosjerky = 6,
		/obj/item/food/no_raisin = 6,
		/obj/item/food/pistachios = 6,
		/obj/item/food/spacetwinkie = 6,
		/obj/item/food/cheesiehonkers = 6,
		/obj/item/food/tastybread = 6,
		/obj/item/food/deluxe_chocolate_bar = 6,
		/obj/item/food/stroopwafel = 2,
	)

	contraband = list(/obj/item/food/syndicake = 6)

	prices = list(
		/obj/item/food/candy/candybar = 64,
		/obj/item/reagent_containers/drinks/dry_ramen = 32,
		/obj/item/food/chips = 64,
		/obj/item/food/twimsts = 64,
		/obj/item/food/sosjerky = 64,
		/obj/item/food/no_raisin = 80,
		/obj/item/food/pistachios = 80,
		/obj/item/food/spacetwinkie = 64,
		/obj/item/food/cheesiehonkers = 64,
		/obj/item/food/tastybread = 80,
		/obj/item/food/deluxe_chocolate_bar = 100,
		/obj/item/food/stroopwafel = 100,
		/obj/item/food/syndicake = 175, // syndicakes are genuinely kind of powerful
	)

	refill_canister = /obj/item/vending_refill/snack

/obj/machinery/economy/vending/snack/free
	prices = list()

/obj/machinery/economy/vending/chinese
	name = "\improper Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	slogan_list = list(
		"Taste 5000 years of culture!",
		"Mr. Chang, approved for safe consumption in over 10 sectors!",
		"Chinese food is great for a date night, or a lonely night!",
		"You can't go wrong with Mr. Chang's authentic Chinese food!",
	)

	icon_state = "chang"
	icon_lightmask = "chang"
	category = VENDOR_TYPE_FOOD
	products = list(
		/obj/item/food/chinese/chowmein = 6,
		/obj/item/food/chinese/tao = 6,
		/obj/item/food/chinese/sweetsourchickenball = 6,
		/obj/item/food/chinese/newdles = 6,
		/obj/item/food/chinese/rice = 6,
		/obj/item/food/fortunecookie = 6,
	)

	prices = list(
		/obj/item/food/chinese/chowmein = 125,
		/obj/item/food/chinese/tao = 125,
		/obj/item/food/chinese/sweetsourchickenball = 125,
		/obj/item/food/chinese/newdles = 100,
		/obj/item/food/chinese/rice = 100,
		/obj/item/food/fortunecookie = 50,
	)

	refill_canister = /obj/item/vending_refill/chinese

/obj/machinery/economy/vending/chinese/free
	prices = list()
