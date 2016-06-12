
/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"

	New()
		..()
		reagents.add_reagent("protein", 3)
		reagents.add_reagent("carpotoxin", 3)
		src.bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/salmonmeat
	name = "raw salmon"
	desc = "A fillet of raw salmon"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"

	New()
		..()
		reagents.add_reagent("protein", 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak
	name = "Salmon steak"
	desc = "A piece of freshly-grilled salmon meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "salmonsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("sodiumchloride", 1)
		reagents.add_reagent("blackpepper", 1)
		bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/catfishmeat
	name = "raw catfish"
	desc = "A fillet of raw catfish"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"

	New()
		..()
		reagents.add_reagent("protein", 3)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"

	New()
		..()
		reagents.add_reagent("nutriment", 4)
		reagents.add_reagent("carpotoxin", 3)
		spawn(1)
			reagents.del_reagent("egg")
			reagents.update_total()
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishburger"
	filling_color = "#FFDEFE"

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		reagents.add_reagent("capsaicin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishandchips"
	filling_color = "#E3D796"

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("carpotoxin", 3)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sashimi"

	New()
		..()
		reagents.add_reagent("nutriment", 6)
		reagents.add_reagent("toxin", 5)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fried_shrimp
	name = "fried shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_fried"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp
	name = "boiled shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_cooked"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Ebi
	name = "Ebi Sushi"
	desc = "A simple sushi consisting of cooked shrimp and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ebi"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Ikura
	name = "Ikura Sushi"
	desc = "A simple sushi consisting of salmon roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ikura"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("protein", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Sake
	name = "Sake Sushi"
	desc = "A simple sushi consisting of raw salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Sake"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	desc = "A simple sushi consisting of cooked salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Tamago
	name = "Tamago Sushi"
	desc = "A simple sushi consisting of egg and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tamago"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Inari
	name = "Inari Sushi"
	desc = "A piece of fried tofu stuffed with rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Inari"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Masago
	name = "Masago Sushi"
	desc = "A simple sushi consisting of goldfish roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("protein", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko
	name = "Tobiko Sushi"
	desc = "A simple sushi consisting of shark roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("protein", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	desc = "A sushi consisting of shark roe and an egg."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_TobikoEgg"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		reagents.add_reagent("protein", 1)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Tai
	name = "Tai Sushi"
	desc = "A simple sushi consisting of catfish and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tai"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sushi_Unagi
	name = "Unagi Sushi"
	desc = "A simple sushi consisting of eel and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Hokki"

	New()
		..()
		reagents.add_reagent("nutriment", 2)
		bitesize = 3