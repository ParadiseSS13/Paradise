// New item list for the expedition vendomat

/obj/machinery/economy/vending/exploredrobe/Initialize(mapload)
	var/list/new_products = list(
			/obj/item/clothing/under/rank/cargo/expedition_prime = 5,
			/obj/item/clothing/under/rank/cargo/expedition_prime/green = 5,
			/obj/item/clothing/under/rank/cargo/expedition_prime/tan = 5,
			/obj/item/clothing/under/rank/cargo/expedition_prime/grey = 5,
			)
	var/list/new_prices = list(
			/obj/item/clothing/under/rank/cargo/expedition_prime = 50,
			/obj/item/clothing/under/rank/cargo/expedition_prime/green = 50,
			/obj/item/clothing/under/rank/cargo/expedition_prime/tan = 50,
			/obj/item/clothing/under/rank/cargo/expedition_prime/grey = 50,
			)
	new_products |= products
	products = new_products
	new_prices |= prices
	prices = new_prices
	. = ..()
