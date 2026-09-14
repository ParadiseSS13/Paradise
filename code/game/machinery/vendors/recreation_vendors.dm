/obj/machinery/economy/vending/cigarette
	name = "\improper ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	slogan_list = list(
		"Space cigs taste good like a cigarette should.",
		"I'd rather toolbox than switch.",
		"Smoke!",
		"Don't believe the reports - smoke today!",
	)

	ads_list = list(
		"Probably not bad for you!",
		"Don't believe the scientists!",
		"It's good for you!",
		"Don't quit, buy more!",
		"Smoke!",
		"Nicotine heaven.",
		"Best cigarettes since 2150.",
		"Award-winning cigs.",
	)

	vend_delay = 34
	icon_state = "cigs"
	icon_lightmask = "cigs"
	category = VENDOR_TYPE_RECREATION
	products = list(
		/obj/item/clothing/mask/cigarette/cigar = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 6,
		/obj/item/storage/fancy/cigarettes/dromedaryco = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_our_brand = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_solar_rays = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
		/obj/item/reagent_containers/patch/nicotine = 10,
		/obj/item/storage/fancy/matches = 10,
		/obj/item/lighter/random = 4,
		/obj/item/lighter/zippo = 2,
		/obj/item/storage/fancy/rollingpapers = 5,
		/obj/item/food/grown/tobacco/pre_dried = 5,
	)

	contraband = list(
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_carcinoma = 6,
	)

	prices = list(
		/obj/item/clothing/mask/cigarette/cigar = 100,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 25,
		/obj/item/storage/fancy/cigarettes/dromedaryco = 25,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 80,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 60,
		/obj/item/storage/fancy/cigarettes/cigpack_our_brand = 15,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 25,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 120,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 25,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims = 50,
		/obj/item/storage/fancy/cigarettes/cigpack_solar_rays = 25,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 35,
		/obj/item/storage/fancy/cigarettes/cigpack_carcinoma = 70,
		/obj/item/reagent_containers/patch/nicotine = 70,
		/obj/item/storage/fancy/matches = 20,
		/obj/item/lighter/random = 40,
		/obj/item/lighter/zippo = 80,
		/obj/item/storage/fancy/rollingpapers = 30,
		/obj/item/food/grown/tobacco/pre_dried = 50,
	)

	refill_canister = /obj/item/vending_refill/cigarette

/obj/machinery/economy/vending/cigarette/free
	prices = list()

// The Syndicate version doesn't sell Robust because that is a Nanotrasen-owned brand. It *does* have its special own-brand replacement.
/obj/machinery/economy/vending/cigarette/syndicate
	products = list(
		/obj/item/clothing/mask/cigarette/cigar = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 6,
		/obj/item/storage/fancy/cigarettes/dromedaryco = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_our_brand = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_carcinoma = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_solar_rays = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 6,
		/obj/item/reagent_containers/patch/nicotine = 10,
		/obj/item/storage/fancy/matches = 10,
		/obj/item/lighter/zippo = 6,
		/obj/item/storage/fancy/rollingpapers = 5,
		/obj/item/food/grown/tobacco/pre_dried = 5,
	)

	// You'd better believe that NT branded cigs are contraband in the Syndicate's territory.
	contraband = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 6,
	)

/obj/machinery/economy/vending/cigarette/syndicate/free
	prices = list()

/// Used in the lavaland_biodome_beach.dmm ruin. As the ultimate in smokable vending, it sells the widest range in the grestest quantity.
/obj/machinery/economy/vending/cigarette/beach
	name = "\improper ShadyCigs Ultra"
	desc = "Now with extra premium products!"
	slogan_list = list(
		"Turn on, tune in, drop out!",
		"Better living through chemistry!",
		"Toke!",
		"Don't forget to keep a smile on your lips and a song in your heart!",
	)

	ads_list = list(
		"Probably not bad for you!",
		"Dope will get you through times of no money better than money will get you through times of no dope!",
		"It's good for you!",
	)

	products = list(
		/obj/item/clothing/mask/cigarette/cigar = 6,
		/obj/item/clothing/mask/cigarette/cigar/cohiba = 6,
		/obj/item/clothing/mask/cigarette/cigar/havana = 6,
		/obj/item/storage/fancy/cigarettes/cigpack_carp = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_random = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_midori = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_our_brand = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_candy = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_carcinoma = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_solar_rays = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift = 10,
		/obj/item/reagent_containers/patch/nicotine = 20,
		/obj/item/storage/fancy/matches = 10,
		/obj/item/lighter/zippo = 10,
		/obj/item/storage/fancy/rollingpapers = 10,
		/obj/item/food/grown/tobacco/pre_dried = 10,
	)

	contraband = list()
	prices = list()

// The finest cigs, available at centcomm for the crew to enjoy after a long, hard day of being brutalized.
/obj/machinery/economy/vending/cigarette/beach/centcomm
	slogan_list = list(
		"Space cigs taste good like a cigarette should.",
		"I'd rather toolbox than switch.",
		"Smoke!",
		"Don't believe the reports - smoke today!",
	)

	ads_list = list(
		"Probably not bad for you!",
		"Don't believe the scientists!",
		"It's good for you!",
		"Don't quit, buy more!",
		"Smoke!",
		"Nicotine heaven.",
		"Best cigarettes since 2150.",
		"Award-winning cigs.",
	)
