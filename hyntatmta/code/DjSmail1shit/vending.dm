/obj/item/weapon/storage/toolbox/fluff/lunchboxp //shitcode of DjSmail1
	name = "lunchpail"
	desc = "A simple black lunchpail."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lunch_box"
	item_state = "lunch_box"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 9
	storage_slots = 3

/obj/item/weapon/storage/toolbox/fluff/lunchboxp/New()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/pureshka_cutlet(src)
	new /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/cola(src)

/obj/machinery/vending/pizza
	name = "Pizzamatt"
	desc = "A vending machine with pizza and lunchbox"
	icon = 'hyntatmta/icons/obj/vending.dmi'
	product_slogans = "Ah, can you feel that divine smell?;Si, my amico! Freshly baked!;Hawaiian is good to, admit it!;Feeling hungry? Nothing's better than a hot pizza!"
	product_ads = "HOT PIZZA!;Just baked! Trust me!"
	vend_delay = 80
	icon_state = "pizza"
	vend_reply = "Hey, you! Go get your yummy."
	products = list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita = 5,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza = 5,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza = 5,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza = 5,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza = 5,
					/obj/item/weapon/storage/toolbox/fluff/lunchboxp = 10 )
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita = 200,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza = 200,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza = 200,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza = 200,
					/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza=200,
					/obj/item/weapon/storage/toolbox/fluff/lunchboxp = 150 )
	premium = list(/obj/item/weapon/reagent_containers/food/snacks/warmdonkpocket = 1)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndidonkpocket = 3)


/obj/machinery/vending/gunshop/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench) || istype(I, /obj/item/weapon/screwdriver))
		return
	..()


/obj/machinery/vending/gunshop
	name = "Gunshop"
	desc = "A vending machine. With guns. God bless."
	product_ads = "Guuun?Maybe you want it?;Buy some Zincum;Wanna feel safe? Well, you can!"
	icon_state = "liberationstation"
	vend_reply = "Don't forget the license!"
	products = list(/obj/item/weapon/gun/projectile/automatic/pistol/enforcer = 5,/obj/item/ammo_box/magazine/m45/enforcer45 = 10)
	prices = list(/obj/item/weapon/gun/projectile/automatic/pistol/enforcer = 2000,/obj/item/ammo_box/magazine/m45/enforcer45 = 500)
	premium = list(/obj/item/ammo_casing/rubber45)
	anchored = 1


/obj/machinery/vending/gunshop/vend(datum/data/vending_product/R, mob/user)
	..()
	var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(src)
	a.config(list("Security" = 0))
	a.autosay("[user.name] purchased [R.product_name]", "[name]", "Security")