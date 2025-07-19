/obj/machinery/economy/vending/autodrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/head/ratge = 1,
		)
	contraband += list(
		/obj/item/clothing/mask/rooster = 1,
		)
	prices += list(
		/obj/item/clothing/head/ratge = 75,
		/obj/item/clothing/mask/rooster = 100,
		)
	. = ..()

/obj/machinery/economy/vending/chefdrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/under/rank/civilian/chef/red = 2,
		/obj/item/clothing/suit/chef/red = 2,
		/obj/item/clothing/head/chefhat/red = 2,
		/obj/item/storage/belt/chef/apron = 1,
		/obj/item/storage/belt/chef/apron/red = 1,
		)
	prices += list(
		/obj/item/clothing/under/rank/civilian/chef/red = 50,
		/obj/item/clothing/suit/chef/red = 50,
		/obj/item/clothing/head/chefhat/red = 50,
		/obj/item/storage/belt/chef/apron = 75,
		/obj/item/storage/belt/chef/apron/red = 75,
		)
	. = ..()
