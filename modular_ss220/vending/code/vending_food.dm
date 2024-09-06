/obj/item/circuitboard/vendor
	var/static/list/ss220_vendors = list("MacVulpix Deluxe Food" = /obj/machinery/economy/vending/vulpix)

/obj/machinery/economy/vending/vulpix
	name = "\improper MacVulpix Deluxe Food"
	desc = "Торговый автомат сети ресторанов быстрого питания МакВульпикс с забавным лисом на логотипе."
	icon = 'modular_ss220/vending/icons/vending.dmi'
	icon_state = "McVulpix"
	icon_lightmask = "McVulpix"
	category = VENDOR_TYPE_FOOD
	refill_canister = /obj/item/vending_refill/vulpix
	vend_reply = "Спасибо, что выбрали МакВульпикс!"
	slogan_list = list(
		"Не любите вульп? Вы просто не умеете их готовить!",
		"Если вам понравились вульпиксы - ингредиенты погибли не зря!",
		"МакВульпикс! То что я люблю!",
		"МакВульпикс - выбор настоящего гурмана, одобрено девятью из десяти диетологами!",
		"Если чревоугодие — это грех, то добро пожаловать в ад!"
	)
	products = list(
		/obj/item/food/fancy/macvulpix_original = 5,
		/obj/item/food/fancy/macvulpix_cheese = 5,
		/obj/item/food/fancy/macvulpburger = 5,
		/obj/item/pizzabox/vulpix = 3,
		/obj/item/food/vulpix_chips = 5,
		/obj/item/reagent_containers/drinks/bottle/vulpix_milk/berry = 5,
		/obj/item/reagent_containers/drinks/bottle/vulpix_milk/banana = 5,
		/obj/item/reagent_containers/drinks/bottle/vulpix_milk/choco = 5,
		/obj/item/reagent_containers/drinks/cans/vulpbeer = 5,
	)
	prices = list(
		/obj/item/food/fancy/macvulpix_original = 100,
		/obj/item/food/fancy/macvulpix_cheese = 100,
		/obj/item/food/fancy/macvulpburger = 125,
		/obj/item/pizzabox/vulpix = 150,
		/obj/item/food/vulpix_chips = 60,
		/obj/item/reagent_containers/drinks/bottle/vulpix_milk/berry = 50,
		/obj/item/reagent_containers/drinks/bottle/vulpix_milk/banana = 50,
		/obj/item/reagent_containers/drinks/bottle/vulpix_milk/choco = 50,
		/obj/item/reagent_containers/drinks/cans/vulpbeer = 30,
	)
	contraband = list(
		/obj/item/toy/plushie/macvulpix = 3,
		/obj/item/poster/mac_vulpix = 3,
	)
