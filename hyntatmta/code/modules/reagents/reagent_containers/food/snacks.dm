/obj/item/weapon/reagent_containers/food/snacks/pureshka
	name = "Puree"
	desc = "No cutlet?"
	icon = 'hyntatmta/icons/obj/food/food.dmi'
	icon_state = "pureshka"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"

/obj/item/weapon/reagent_containers/food/snacks/pureshka/New()
		..()
		reagents.add_reagent("nutriment", 5)		//Local meme.

/obj/item/weapon/reagent_containers/food/snacks/pureshka_cutlet
	name = "Cutlet puree"
	desc = "Da ti potoropis!"
	icon = 'hyntatmta/icons/obj/food/food.dmi'
	icon_state = "pureshka_cutlet"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"

/obj/item/weapon/reagent_containers/food/snacks/pureshka_cutlet/New()
		..()
		reagents.add_reagent("nutriment", 10)		//Local meme with kotletki.

/obj/item/weapon/reagent_containers/food/snacks/catbread
	name = "Cat Bread"
	desc = "Whoever made this, was not thinking about consequences."
	icon = 'hyntatmta/icons/obj/food/food.dmi'
	icon_state = "catbread"

	New()
		..()
		reagents.add_reagent("nutriment", 15)
		reagents.add_reagent("protein", 5)
		bitesize = 15

/obj/item/weapon/reagent_containers/food/snacks/olivier
	name = "Olivier Salad"
	desc = "Traditional salad served for New Year celebrations"
	icon = 'hyntatmta/icons/obj/food/food.dmi'
	icon_state = "olivier"
	trash = /obj/item/trash/plate
	filling_color = "#ffffe0"

/obj/item/weapon/reagent_containers/food/snacks/olivier/New()
		..()
		reagents.add_reagent("nutriment", 7)

/obj/item/weapon/reagent_containers/food/snacks/shubacarp
	name = "Dressed Space Carp" //P E R E V O D C H I K
	desc = "Traditional salad served for New Year celebrations. Another one"
	icon = 'hyntatmta/icons/obj/food/food.dmi'
	icon_state = "shubacarp"
	trash = /obj/item/trash/plate
	filling_color = "#ee82ee"

/obj/item/weapon/reagent_containers/food/snacks/shubacarp/New()
		..()
		reagents.add_reagent("nutriment", 10)

/obj/item/weapon/reagent_containers/food/snacks/sopademacaco
	name = "Sopa de macaco"
	desc = "Uma delicia! You can see monkey head swimming in this mess"
	icon = 'hyntatmta/icons/obj/food/food.dmi'
	icon_state = "sopa"
	trash = /obj/item/trash/plate
	filling_color = "cfbe02"

/obj/item/weapon/reagent_containers/food/snacks/sopademacaco/New()
		..()
		reagents.add_reagent("nutriment", 15)
		reagents.add_reagent("banana", 10)
		reagents.add_reagent("msg", 5)
		reagents.add_reagent("fartonium", 30)