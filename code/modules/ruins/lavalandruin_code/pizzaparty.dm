/obj/effect/spawner/random/pizzaparty
	name = "pizza bomb spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "pizzabox"
	loot = list(
		/obj/item/pizzabox/margherita = 2,
		/obj/item/pizzabox/meat = 2,
		/obj/item/pizzabox/pepperoni = 2,
		/obj/item/pizzabox/mushroom = 1,
		/obj/item/pizzabox/garlic = 1,
		/obj/item/pizzabox/firecracker = 1,
		/obj/item/pizzabox/pizza_bomb = 1
	)
	spawn_loot_double = TRUE

/obj/structure/reagent_dispensers/water_cooler/pizzaparty
	name = "punch cooler"
	reagent_id = "bacchus_blessing"
