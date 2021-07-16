
//////////////////////
//		Mexican		//
//////////////////////

/obj/item/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2, "lettuce" = 1)

/obj/item/reagent_containers/food/snacks/burrito
	name = "burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("torilla" = 2, "meat" = 3)


/obj/item/reagent_containers/food/snacks/chimichanga
	name = "chimichanga"
	desc = "Time to eat a chimi-f***ing-changa."
	icon_state = "chimichanga"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list(/datum/reagent/medicine/omnizine = 4, /datum/reagent/consumable/cheese = 2) //Deadpool reference. Deal with it.

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva la Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/capsaicin = 6)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)

/obj/item/reagent_containers/food/snacks/cornchips
	name = "corn chips"
	desc = "Goes great with salsa! OLE!"
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)


//////////////////////
//		Chinese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	junkiness = 25
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/beans = 3, /datum/reagent/msg = 4, /datum/reagent/consumable/sugar = 2)
	tastes = list("noodle" = 1, "vegetables" = 1)

/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "sweet & sour chicken balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"
	item_state = "chinese3"
	junkiness = 25
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/msg = 4, /datum/reagent/consumable/sugar = 2)
	tastes = list("chicken" = 1, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	junkiness = 25
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/msg = 4, /datum/reagent/consumable/sugar = 4)
	tastes = list("chicken" = 1)

/obj/item/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	junkiness = 25
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/msg = 4, /datum/reagent/consumable/sugar = 3)
	tastes = list("noodles" = 1)

/obj/item/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"
	item_state = "chinese2"
	junkiness = 20
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/rice = 3, /datum/reagent/msg = 4, /datum/reagent/consumable/sugar = 2)
	tastes = list("rice" = 1)


//////////////////////
//	Japanese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("custard" = 1)

/obj/item/reagent_containers/food/snacks/yakiimo
	name = "yaki imo"
	desc = "Made with roasted sweet potatoes!"
	icon_state = "yakiimo"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#8B1105"
	tastes = list("sweet potato" = 1)


//////////////////////
//	Middle Eastern	//
//////////////////////

/obj/item/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "Human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)

/obj/item/reagent_containers/food/snacks/monkeykabob
	name = "meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)

/obj/item/reagent_containers/food/snacks/tofukabob
	name = "tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
