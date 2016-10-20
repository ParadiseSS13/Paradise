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
