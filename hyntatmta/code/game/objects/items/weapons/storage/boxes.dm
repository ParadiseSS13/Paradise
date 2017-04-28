/obj/item/weapon/storage/box/survival/prisoner
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/condiment/soymilk( src )
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar( src )
		new /obj/item/clothing/mask/cigarette( src )
		new /obj/item/weapon/match( src )
		return