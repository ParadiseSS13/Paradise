/obj/machinery/economy/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	icon_lightmask = "Cola_Machine"
	icon_panel = "thin_vendor"
	slogan_list = list("Robust Softdrinks: More robust than a toolbox to the head!")
	ads_list = list(
		"Refreshing!",
		"Hope you're thirsty!",
		"Over 1 million drinks sold!",
		"Thirsty? Why not cola?",
		"Please, have a drink!",
		"Drink up!",
		"The best drinks in space.",
	)

	category = VENDOR_TYPE_DRINK
	products = list(
		/obj/item/reagent_containers/drinks/cans/cola = 10,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind = 10,
		/obj/item/reagent_containers/drinks/cans/dr_gibb = 10,
		/obj/item/reagent_containers/drinks/cans/starkist = 10,
		/obj/item/reagent_containers/drinks/cans/space_up = 10,
		/obj/item/reagent_containers/drinks/cans/grape_juice = 10,
		/obj/item/reagent_containers/drinks/cans/ginger_ale = 10,
		/obj/item/reagent_containers/drinks/cans/electrolytes = 10,
		/obj/item/reagent_containers/drinks/cans/mrs_brown = 10,
		/obj/item/reagent_containers/drinks/bottle/chocolate_milk = 10,
		/obj/item/reagent_containers/glass/beaker/waterbottle = 10,
	)

	contraband = list(
		/obj/item/reagent_containers/drinks/cans/thirteenloko = 5,
		/obj/item/reagent_containers/drinks/cans/behemoth_energy = 5,
		/obj/item/reagent_containers/drinks/cans/behemoth_energy_lite = 5,
	)

	prices = list(
		/obj/item/reagent_containers/drinks/cans/cola = 45,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind = 50,
		/obj/item/reagent_containers/drinks/cans/dr_gibb = 50,
		/obj/item/reagent_containers/drinks/cans/starkist = 50,
		/obj/item/reagent_containers/drinks/cans/space_up = 50,
		/obj/item/reagent_containers/drinks/cans/grape_juice = 50,
		/obj/item/reagent_containers/drinks/cans/ginger_ale = 50,
		/obj/item/reagent_containers/drinks/cans/electrolytes = 40,
		/obj/item/reagent_containers/drinks/cans/mrs_brown = 50,
		/obj/item/reagent_containers/drinks/bottle/chocolate_milk = 64,
		/obj/item/reagent_containers/glass/beaker/waterbottle = 20,
	)

	refill_canister = /obj/item/vending_refill/cola

/obj/machinery/economy/vending/cola/free
	prices = list()

/obj/machinery/economy/vending/cola/black
	icon_state = "cola_black"
	icon_lightmask = "Cola_Machine_lightmask"
	icon_off = "Cola_Machine_off" // slight blue tint still but whatever

/obj/machinery/economy/vending/cola/generic
	icon_state = "soda"

/obj/machinery/economy/vending/cola/starkist
	icon_state = "starkist"

/obj/machinery/economy/vending/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat" //////////////22 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat_deny"
	icon_lightmask = "smartfridge"
	icon_panel = "smartfridge"
	icon_broken = "smartfridge"
	category = VENDOR_TYPE_DRINK
	products = list(
		/obj/item/reagent_containers/drinks/bottle/gin = 5,
		/obj/item/reagent_containers/drinks/bottle/whiskey = 5,
		/obj/item/reagent_containers/drinks/bottle/tequila = 5,
		/obj/item/reagent_containers/drinks/bottle/vodka = 5,
		/obj/item/reagent_containers/drinks/bottle/vermouth = 5,
		/obj/item/reagent_containers/drinks/bottle/rum = 5,
		/obj/item/reagent_containers/drinks/bottle/wine = 5,
		/obj/item/reagent_containers/drinks/bottle/white_wine = 5,
		/obj/item/reagent_containers/drinks/bottle/mezcal = 5,
		/obj/item/reagent_containers/drinks/bag/goonbag = 3,
		/obj/item/reagent_containers/drinks/bottle/cognac = 5,
		/obj/item/reagent_containers/drinks/bottle/kahlua = 5,
		/obj/item/reagent_containers/drinks/bottle/beer = 6,
		/obj/item/reagent_containers/drinks/bottle/ale = 6,
		/obj/item/reagent_containers/drinks/cans/synthanol = 15,
		/obj/item/reagent_containers/drinks/bottle/orangejuice = 4,
		/obj/item/reagent_containers/drinks/bottle/tomatojuice = 4,
		/obj/item/reagent_containers/drinks/bottle/limejuice = 4,
		/obj/item/reagent_containers/drinks/bottle/cream = 4,
		/obj/item/reagent_containers/drinks/cans/tonic = 8,
		/obj/item/reagent_containers/drinks/cans/cola = 8,
		/obj/item/reagent_containers/drinks/cans/electrolytes = 4,
		/obj/item/reagent_containers/drinks/cans/sodawater = 15,
		/obj/item/reagent_containers/drinks/cans/ginger_ale = 8,
		/obj/item/reagent_containers/drinks/drinkingglass = 30,
		/obj/item/reagent_containers/drinks/drinkingglass/shotglass = 30,
		/obj/item/reagent_containers/drinks/ice = 9,
	)

	contraband = list(
		/obj/item/reagent_containers/drinks/tea = 10,
		/obj/item/reagent_containers/drinks/bottle/fernet = 5,
		/obj/item/reagent_containers/drinks/bottle/vampire_bestfriend = 5,
	)

	vend_delay = 15
	slogan_list = list(
		"I hope nobody asks me for a bloody cup o' tea...",
		"Alcohol is humanity's friend. Would you abandon a friend?",
		"Quite delighted to serve you!",
		"Is nobody thirsty on this station?",
	)

	ads_list = list(
		"Drink up!",
		"Booze is good for you!",
		"Alcohol is humanity's best friend.",
		"Quite delighted to serve you!",
		"Care for a nice, cold beer?",
		"Nothing cures you like booze!",
		"Have a sip!",
		"Have a drink!",
		"Have a beer!",
		"Beer is good for you!",
		"Only the finest alcohol!",
		"Best quality booze since 2053!",
		"Award-winning wine!",
		"Maximum alcohol!",
		"Man loves beer.",
		"A toast for progress!",
	)

	refill_canister = /obj/item/vending_refill/boozeomat

/obj/machinery/economy/vending/boozeomat/syndicate_access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/economy/vending/coffee
	name = "\improper Solar's Best Hot Drinks"
	desc = "A vending machine which dispenses coffee, coffee, hot chocolate, and more coffee!"
	ads_list = list(
		"Have a drink!",
		"Drink up!",
		"It's good for you!",
		"Would you like a hot joe?",
		"I'd kill for some coffee!",
		"The best beans in the galaxy.",
		"Only the finest brew for you.",
		"Mmmm. Nothing like a coffee.",
		"I like coffee, don't you?",
		"Coffee helps you work!",
		"Try some tea.",
		"We hope you like the best!",
		"Try our new chocolate!",
		"Admin conspiracies",
	)

	icon_state = "coffee"
	icon_lightmask = "coffee"
	icon_vend = "coffee_vend"
	icon_panel = "screen_vendor"
	item_slot = TRUE
	vend_delay = 34
	category = VENDOR_TYPE_DRINK
	products = list(
		/obj/item/reagent_containers/drinks/coffee = 25,
		/obj/item/reagent_containers/drinks/tea = 25,
		/obj/item/reagent_containers/drinks/h_chocolate = 25,
		/obj/item/reagent_containers/drinks/chocolate = 10,
		/obj/item/reagent_containers/drinks/bottle/chocolate_milk = 10,
		/obj/item/reagent_containers/drinks/chicken_soup = 10,
		/obj/item/reagent_containers/drinks/weightloss = 10,
		/obj/item/reagent_containers/drinks/mug = 15,
		/obj/item/reagent_containers/drinks/mug/novelty = 5,
	)

	contraband = list(/obj/item/reagent_containers/drinks/ice = 10)

	prices = list(
		/obj/item/reagent_containers/drinks/coffee = 80,
		/obj/item/reagent_containers/drinks/tea = 80,
		/obj/item/reagent_containers/drinks/h_chocolate = 64,
		/obj/item/reagent_containers/drinks/chocolate = 120,
		/obj/item/reagent_containers/drinks/bottle/chocolate_milk = 64,
		/obj/item/reagent_containers/drinks/chicken_soup = 100,
		/obj/item/reagent_containers/drinks/weightloss = 50,
		/obj/item/reagent_containers/drinks/mug = 75,
		/obj/item/reagent_containers/drinks/mug/novelty = 100,
	)

	refill_canister = /obj/item/vending_refill/coffee

/obj/machinery/economy/vending/coffee/free
	prices = list()

/obj/machinery/economy/vending/coffee/item_slot_check(mob/user, obj/item/I)
	if(!(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/drinks)))
		return FALSE
	if(!..())
		return FALSE
	if(!I.is_open_container())
		to_chat(user, SPAN_WARNING("You need to open [I] before inserting it."))
		return FALSE
	return TRUE

/obj/machinery/economy/vending/coffee/do_vend(datum/data/vending_product/R, mob/user)
	var/obj/item/reagent_containers/drinks/vended = ..()
	if(!istype(vended))
		return

	if(istype(vended, /obj/item/reagent_containers/drinks/mug))
		return

	vended.reagents.trans_to(inserted_item, vended.reagents.total_volume)
	if(!vended.reagents.total_volume)
		qdel(vended)

/obj/machinery/economy/vending/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine."
	icon_state = "sovietsoda"
	icon_lightmask = "sovietsoda"
	category = VENDOR_TYPE_DRINK
	ads_list = list(
		"For Tsar and Country.",
		"Have you fulfilled your nutrition quota today?",
		"Very nice!",
		"We are simple people, for this is all we eat.",
		"If there is a person, there is a problem. If there is no person, then there is no problem.",
	)

	products = list(/obj/item/reagent_containers/drinks/cans/sodawater = 10)

	contraband = list(/obj/item/reagent_containers/drinks/cans/cola = 7)

	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/sovietsoda
