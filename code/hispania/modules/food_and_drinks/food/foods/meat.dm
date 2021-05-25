//Drake meat//

/obj/item/reagent_containers/food/snacks/drakemeat
	name = "drake meat"
	desc = "A steak of an ash drake. It's melting only with the heat of your fingers."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "drake_meat"

	list_reagents = list("protein" = 5)
	tastes = list("tender meat, like butter" = 1)

/obj/item/reagent_containers/food/snacks/drakeribs
	name = "drake ribs"
	desc = "Some drake ribs looking pretty strong... and delicious!"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "drake_ribs"

	list_reagents = list("protein" = 10)
	tastes = list("strong meat" = 1)

 /////////////
//Cooked Meat//
 /////////////

///Drake steak///
/obj/item/reagent_containers/food/snacks/drakesteak
	name = "drake steak"
	desc = "It look very disgusting, but smells so sweet and delicious."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "drake_steak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "miracledrops" = 2)
	tastes = list("HEAVEN" = 1)

// COSTILLAS D-DE DE BRON-//
/obj/item/reagent_containers/food/snacks/brontosaurio
	name = "cooked drake ribs"
	desc = "No way... These ribs are looking gorgeous and god that smell!"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "cookeddrake_ribs"
	filling_color = "#EC3924"
	bitesize = 2
	list_reagents = list("nutriment" = 20)
	tastes = list("BRONTOSAURIO" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/plazmiteleg
	name = "plazmite leg"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "A plazmite leg. It's not very edible now, but it cooks great in lava, rumors says its great for digestion."
	icon_state = "plazmite_leg_raw"
	list_reagents = list("protein" = 3, "plazmitevenom" = 5)
	tastes = list("tough meat" = 1)

/obj/item/reagent_containers/food/snacks/monstermeat/plazmiteleg/burn()
	visible_message("[src] finishes cooking!")
	new /obj/item/reagent_containers/food/snacks/plazmite_fingers(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/plazmite_fingers
	name = "Plazmite Fingers"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "A delicious, lava cooked leg."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "plazmite_leg"
	trash = null
	list_reagents = list("protein" = 2, "charcoal" = 10)
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/peach_meat
	name = "Peach Meat"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "A good steak dipped in peach sauce, with an avocado base"
	icon_state = "peach_meat"
	trash = /obj/item/trash/plate
	bitesize = 4
	tastes = list("sweet" = 1, "beefy" = 1)

/obj/item/reagent_containers/food/snacks/baconrolled
	name = "Bacon Rolls"
	icon = 'icons/hispania/obj/food/food.dmi'
	desc = "Rolls of bacon filled up with avocado!"
	icon_state = "bacon_roll"
	list_reagents = list("protein" = 1, "nutriment" = 2)
	tastes = list("meat with vegetables" = 1)

/obj/item/reagent_containers/food/snacks/meatsteak_cactus
	name = "meat steak"
	desc = "A piece of hot spicy meat. With some prickly pear cactus on top."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "meatstake_cactus"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	tastes = list("meat" = 1, "cactus" = 1)

/obj/item/reagent_containers/food/snacks/syntisteak_cactus
	name = "synthetic meat"
	desc = "A synthetic slab of flesh. With some prickly pear cactus on top."
	icon_state = "meatstake_cactus"
	icon = 'icons/hispania/obj/food/food.dmi'
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 5, "vitamin" = 1)
	tastes = list("meat" = 1, "cactus" = 1)

/obj/item/reagent_containers/food/snacks/smokedsalmon
	name = "salmon smoked steak"
	desc = "A fillet of freshly-grilled and smoked salmon meat."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "smokedsalmon"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 4
	list_reagents = list("nutriment" = 5, "vitamin" = 1, "sodiumchloride" = 1)
	tastes = list("smoked salmon" = 1)

/obj/item/reagent_containers/food/snacks/avocadosalmon
	name = "avocado salmon"
	desc = "A fillet of freshly-grilled of salmon meat with some avocado."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "salmonavocado"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 4
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "sodiumchloride" = 1, "protein" = 1)
	tastes = list("meat with vegetables" = 1)

/obj/item/reagent_containers/food/snacks/citrussalmon
	name = "grilled citrus salmon"
	desc = "A fillet of freshly-grilled of salmon meat with some citrus fruits."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "citrussalmon"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 4
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "orangejuice" = 2, "lemonjuice" = 2)
	tastes = list("salmon" = 1, "citrus" = 1)
