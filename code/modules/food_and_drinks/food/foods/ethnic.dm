
//////////////////////
//		Mexican		//
//////////////////////

/obj/item/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2, "lettuce" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/burrito
	name = "burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("torilla" = 2, "meat" = 3)
	foodtype = MEAT | VEGETABLES


/obj/item/reagent_containers/food/snacks/chimichanga
	name = "chimichanga"
	desc = "Time to eat a chimi-f***ing-changa."
	icon_state = "chimichanga"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("omnizine" = 4, "cheese" = 2) //Deadpool reference. Deal with it.
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva la Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "capsaicin" = 6)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/cornchips
	name = "corn chips"
	desc = "Goes great with salsa! OLE!"
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 3)
	foodtype = FRIED | GRAIN


//////////////////////
//		Chinese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "beans" = 3, "msg" = 4, "sugar" = 2)
	tastes = list("noodle" = 1, "vegetables" = 1)
	foodtype = FRIED | VEGETABLES

/obj/item/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "sweet & sour chicken balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"
	item_state = "chinese3"
	junkiness = 25
	list_reagents = list("nutriment" = 2, "msg" = 4, "sugar" = 2)
	tastes = list("chicken" = 1, "sweetness" = 1)
	foodtype = FRIED | MEAT

/obj/item/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "protein" = 1, "msg" = 4, "sugar" = 4)
	tastes = list("chicken" = 1)
	foodtype = FRIED | MEAT

/obj/item/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "msg" = 4, "sugar" = 3)
	tastes = list("noodles" = 1)
	foodtype = FRIED | GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"
	item_state = "chinese2"
	junkiness = 20
	antable = FALSE
	list_reagents = list("nutriment" = 1, "rice" = 3, "msg" = 4, "sugar" = 2)
	tastes = list("rice" = 1)
	foodtype = FRIED | GRAIN | VEGETABLES


//////////////////////
//	Japanese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	list_reagents = list("nutriment" = 5)
	tastes = list("custard" = 1)
	foodtype = DAIRY

/obj/item/reagent_containers/food/snacks/yakiimo
	name = "yaki imo"
	desc = "Made with roasted sweet potatoes!"
	icon_state = "yakiimo"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 5, "vitamin" = 4)
	filling_color = "#8B1105"
	tastes = list("sweet potato" = 1)
	foodtype = VEGETABLES | SUGAR


//////////////////////
//	Middle Eastern	//
//////////////////////

/obj/item/reagent_containers/food/snacks/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "Human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/monkeykabob
	name = "meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	foodtype = MEAT | FRIED

/obj/item/reagent_containers/food/snacks/tofukabob
	name = "tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list("nutriment" = 8)
	foodtype = VEGETABLES | FRIED

//////////////////////////////////
//	North-Eastern Mediterranean	//
//////////////////////////////////

/obj/item/reagent_containers/food/snacks/shawarma
	name = "shawarma"
	desc = "Awesome mix of grilled meat and fresh vegetables. Don't ask about meat."
	icon_state = "shawarma"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("meat" = 3, "vegetables" = 2, "tomato" = 1, "pepper" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/doner_cheese
	name = "cheese doner"
	desc = "Chef's special - grilled meat and fresh vegetables with warm cheese sause. Yummy!"
	icon_state = "doner_cheese"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 6, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("meat" = 3, "cheese" = 2, "vegetables" = 2, "tomato" = 1, "pepper" = 1)
	foodtype = MEAT | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/doner_mushroom
	name = "mushroom doner"
	desc = "Grilled meat and fresh vegetables. You can see some mushrooms too."
	icon_state = "doner_mushroom"
	filling_color = "#c0720c"
	list_reagents = list("protein" = 4, "nutriment" = 4, "plantmatter" = 2, "vitamin" = 2, "tomatojuice" = 4)
	tastes = list("meat" = 3, "mushrooms" = 2, "vegetables" = 2, "tomato" = 1, "pepper" = 1)
	foodtype = MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/doner_vegan
	name = "vegan doner"
	desc = "Fresh vegetables wrapped in a long roll. No meat included!"
	icon_state = "doner_vegan"
	filling_color = "#c0720c"
	list_reagents = list("nutriment" = 4, "plantmatter" = 4, "vitamin" = 4, "tomatojuice" = 8)
	tastes = list("vegetables" = 2, "tomato" = 1, "pepper" = 1)
	foodtype = VEGETABLES
