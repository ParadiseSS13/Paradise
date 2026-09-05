/obj/machinery/economy/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "A soft drink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	icon_lightmask = "Cola_Machine"
	icon_panel = "thin_vendor"
	slogan_list = list("Robust Softdrinks: More robust than a toolbox to the head!")
	ads_list = list("Refreshing!",
					"Hope you're thirsty!",
					"Over 1 million drinks sold!",
					"Thirsty? Why not cola?",
					"Please, have a drink!",
					"Drink up!",
					"The best drinks in space.")

	category = VENDOR_TYPE_DRINK
	products = list(/obj/item/reagent_containers/drinks/cans/cola = 10,
					/obj/item/reagent_containers/drinks/cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/drinks/cans/dr_gibb = 10,
					/obj/item/reagent_containers/drinks/cans/starkist = 10,
					/obj/item/reagent_containers/drinks/cans/space_up = 10,
					/obj/item/reagent_containers/drinks/cans/grape_juice = 10,
					/obj/item/reagent_containers/drinks/cans/ginger_ale = 10,
					/obj/item/reagent_containers/drinks/cans/electrolytes = 10,
					/obj/item/reagent_containers/drinks/cans/mrs_brown = 10,
					/obj/item/reagent_containers/drinks/bottle/chocolate_milk = 10,
					/obj/item/reagent_containers/glass/beaker/waterbottle = 10,)

	contraband = list(/obj/item/reagent_containers/drinks/cans/thirteenloko = 5,
					/obj/item/reagent_containers/drinks/cans/behemoth_energy = 5,
					/obj/item/reagent_containers/drinks/cans/behemoth_energy_lite = 5,)

	prices = list(/obj/item/reagent_containers/drinks/cans/cola = 45,
				/obj/item/reagent_containers/drinks/cans/space_mountain_wind = 50,
				/obj/item/reagent_containers/drinks/cans/dr_gibb = 50,
				/obj/item/reagent_containers/drinks/cans/starkist = 50,
				/obj/item/reagent_containers/drinks/cans/space_up = 50,
				/obj/item/reagent_containers/drinks/cans/grape_juice = 50,
				/obj/item/reagent_containers/drinks/cans/ginger_ale = 50,
				/obj/item/reagent_containers/drinks/cans/electrolytes = 40,
					/obj/item/reagent_containers/drinks/cans/mrs_brown = 50,
				/obj/item/reagent_containers/drinks/bottle/chocolate_milk = 64,
				/obj/item/reagent_containers/glass/beaker/waterbottle = 20,)

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
