
//////////////////////
//		Mexican		//
//////////////////////

/obj/item/food/tortilla
	name = "tortilla"
	desc = "A baked flatbread, perfect for tacos."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "tortilla"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)
	tastes = list("wheat")
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)
	tastes = list("taco" = 4, "meat" = 2, "cheese" = 2, "lettuce" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burrito
	name = "burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("torilla" = 2, "meat" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/chimichanga
	name = "chimichanga"
	desc = "Time to eat a chimi-f***ing-changa."
	icon_state = "chimichanga"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	list_reagents = list("omnizine" = 4, "cheese" = 2) //Deadpool reference. Deal with it.
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/enchiladas
	name = "enchiladas"
	desc = "Viva la Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "capsaicin" = 6)
	tastes = list("hot peppers" = 1, "meat" = 3, "cheese" = 1, "sour cream" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cornchips
	name = "corn chips"
	desc = "Goes great with salsa! OLE!"
	icon_state = "chips"
	bitesize = 1
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	list_reagents = list("nutriment" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL


//////////////////////
//		Chinese		//
//////////////////////

/obj/item/food/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "beans" = 3, "msg" = 4, "sugar" = 2)
	tastes = list("noodle" = 1, "vegetables" = 1)

/obj/item/food/chinese/sweetsourchickenball
	name = "sweet & sour chicken balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "chickenball"
	inhand_icon_state = "chinese3"
	junkiness = 25
	list_reagents = list("nutriment" = 2, "msg" = 4, "sugar" = 2, "protein" = 1)
	tastes = list("chicken" = 1, "sweetness" = 1)

/obj/item/food/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "protein" = 1, "msg" = 4, "sugar" = 4)
	tastes = list("chicken" = 1)

/obj/item/food/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "msg" = 4, "sugar" = 3)
	tastes = list("noodles" = 1)

/obj/item/food/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"
	inhand_icon_state = "chinese2"
	antable = FALSE
	junkiness = 20
	list_reagents = list("nutriment" = 1, "rice" = 3, "msg" = 4, "sugar" = 2)
	tastes = list("rice" = 1)


//////////////////////
//	Japanese		//
//////////////////////

/obj/item/food/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#F0F2E4"
	list_reagents = list("nutriment" = 5)
	tastes = list("custard" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/yakiimo
	name = "yaki imo"
	desc = "Made with roasted sweet potatoes!"
	icon_state = "yakiimo"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 5, "vitamin" = 4)
	filling_color = "#8B1105"
	tastes = list("sweet potato" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


//////////////////////
//	Middle Eastern	//
//////////////////////

/obj/item/food/meatkebab
	name = "meat-kebab"
	desc = "Delicious meat, on a stick."
	icon_state = "kebab"
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/meatkebab/bone
	icon_state = "kebab_bone"
	trash = /obj/item/stack/bone_rods

/obj/item/food/syntikebab
	name = "synthimeat-kebab"
	desc = "Delicious synthetic meat, on a stick."
	icon_state = "kebab"
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)

/obj/item/food/syntikebab/bone
	icon_state = "kebab_bone"
	trash = /obj/item/stack/bone_rods

/obj/item/food/human/kebab
	name = "-kebab"
	desc = "Human meat, on a stick."
	icon_state = "kebab"
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	list_reagents = list("nutriment" = 8)

/obj/item/food/human/kebab/bone
	icon_state = "kebab_bone"
	trash = /obj/item/stack/bone_rods

/obj/item/food/tofukebab
	name = "tofu-kebab"
	desc = "Vegan meat, on a stick."
	icon_state = "kebab"
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	list_reagents = list("nutriment" = 8)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/tofukebab/bone
	icon_state = "kebab_bone"
	trash = /obj/item/stack/bone_rods

/obj/item/food/picoss_kebab
	name = "picoss-kebab"
	desc = "A popular Moghes street food consisting of vinegar-marinated space carp on a skewer with onion and chillis."
	icon_state = "picoss_skewer"
	trash = /obj/item/stack/rods
	list_reagents = list("protein" = 8, "vitamin" = 4, "vinegar" = 1, "capsaicin" = 1)
	filling_color = "#A85340"
	tastes = list("fish" = 4, "acid" = 1, "onion" = 1, "heat" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/picoss_kebab/bone
	icon_state = "picoss_skewer_bone"
	trash = /obj/item/stack/bone_rods

////////////////////////
// 		Hispania!		//
////////////////////////

/obj/item/food/sliceable/cheeseannonacake
	name = "cheese annona cake"
	desc = "DANGEROUSLY sugary cheesy."
	icon_state = "cheeseannonacake"
	slice_path = /obj/item/food/sliced/cheeseannonacake
	slices_num = 5
	filling_color = "#FAF7AF"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 4, "sugary cream cheese" = 3)

/obj/item/food/sliced/cheeseannonacake
	name = "cheese annona cake slice"
	desc = "Slice of pure cheestisfaction."
	icon_state = "cheeseannonacake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	tastes = list("cake" = 4, "sugary cream cheese" = 3)

///empanadas by Soulster
/obj/item/food/empanada
	name = "empanada"
	desc = "A meaty goodness"
	icon_state = "empanada"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "vitamin" = 2)

///VIVA VENEZUELA CARAJO -EvoS
/obj/item/food/arepa
	name = "arepa"
	desc = "Venezuelan flavor."
	icon_state = "arepa"
	bitesize = 4
	list_reagents = list("nutriment" = 5, "vitamin" = 2)

/obj/item/food/arepa/cheese
	name = "cheese arepa"
	desc = "Venezuelan flavor just with cheese."
	icon_state = "arepa_cheese"
	list_reagents = list("nutriment" = 5, "vitamin" = 5)

/obj/item/food/arepa/ham
	name = "ham arepa"
	desc = "Venezuelan flavor just with ham."
	icon_state = "ham_arepa"
	list_reagents = list("nutriment" = 6, "vitamin" = 5)

/obj/item/food/arepa/ham_cheese
	name = "cheese and ham arepa"
	desc = "Venezuelan flavor but with ham and cheese."
	icon_state = "arepa_ham_cheese"
	bitesize = 6
	list_reagents = list("nutriment" = 8, "vitamin" = 6)

/obj/item/food/arepa/plasma
	name = "plasma arepa"
	desc = "Venezuelan flavor taken to another level."
	icon_state = "arepa_plasma"
	bitesize = 6
	list_reagents = list("nutriment" = 10, "vitamin" = 9)

/obj/item/food/arepa/ghost
	name = "ghost arepa"
	desc = "deliciously spooky BOOOOOOOOO"
	icon_state = "arepa_ghost"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "vitamin" = 7, "ectoplasm" = 5)

/obj/item/food/arepa/xeno
	name = "xeno arepa"
	desc = "Viscous, lumpy and smells horrible, but has everything a healthy body needs, even if you feel like throwing up."
	icon_state = "xeno_arepa"
	bitesize = 5
	list_reagents = list("nutriment" = 5, "vitamin" = 4)

/obj/item/food/arepa/spider
	name = "spider arepa"
	desc = "I think it's still moving ... Ok, I swear it moved."
	icon_state = "spider_arepa"
	bitesize = 7
	list_reagents = list("nutriment" = 7, "vitamin" = 6, "toxin" = 2, "charcoal" = 2)

/obj/item/food/arepa/life
	name = "holy arepa"
	desc = "created by a mage in his moms house."
	icon_state = "arepa_life"
	bitesize = 3
	list_reagents = list("nutriment" = 0, "vitamin" = 0, "strange_reagent" = 5)

/obj/item/food/arepa/slime
	name = "slime arepa"
	desc = "A smooth arepa."
	icon_state = "arepa_slime"
	list_reagents = list("nutriment" = 5, "vitamin" = 5, "slimejelly" = 5)

/obj/item/food/arepa/sweet
	name = "sweet arepa"
	desc = "A sweet and delicious arepa."
	icon_state = "sweet_arepa"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "vitamin" = 5, "slimejelly" = 10, "sugar" = 10)

/obj/item/food/arepa/cheesier
	name = "cheese arepa"
	desc = "A lot of cheese with delicious arepa."
	icon_state = "cheese_arepa"
	bitesize = 10
	list_reagents = list("nutriment" = 10, "vitamin" = 4)

/obj/item/food/arepa/fruit
	name = "fruit arepa"
	desc = "A tropical arepa."
	icon_state = "fruit_arepa"
	bitesize = 5
	list_reagents = list("nutriment" = 5, "vitamin" = 8, "banana" = 10)

/obj/item/food/arepa/salmon
	name = "arepa with salmon"
	desc = "It's supposed to be tuna."
	icon_state = "arepa_salmon"
	bitesize = 5
	list_reagents = list("nutriment" = 5, "vitamin" = 8)

/obj/item/food/arepa/industrial
	name = "arepa industrial"
	desc = "Beep Boop VENEZUELA RISE UP Beep."
	icon_state = "arepa_industrial"
	bitesize = 7
	list_reagents = list("nutriment" = 2, "vitamin" = 2, "oil" = 10, "iron" = 10, "synthanol" = 5)

/obj/item/food/arepa/infernal
	name = "arepa inferno"
	desc = "You feel your nose burn with the smell of it."
	icon_state = "arepa_infernal"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "capsaicin" = 10, "condensedcapsaicin" = 7)

/obj/item/food/arepa/ice
	name = "iced arepa"
	desc = "A solid ice cube, with an arepa in it."
	icon_state = "arepa_ice"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "frostoil" = 25)

/obj/item/food/arepa/plumphelmet
	name = "dwarf arepa"
	desc = "Armok itself created this arepa."
	icon_state = "arepa_plumphelmet"
	bitesize = 5
	list_reagents = list("nutriment" = 9, "vitamin" = 5)

/obj/item/food/arepa/magma
	name = "magma arepa"
	desc = "Arepa taken from lavaland itself."
	icon_state = "arepa_magma"
	bitesize = 6
	list_reagents = list("nutriment" = 6, "vitamin" = 6, "capsaicin" = 20, "condensedcapsaicin" = 20)  //666,el diablo

// Cuy//
/obj/item/food/cuy
	name = "Cuy"
	desc = "Wood grilled guinea pig served with potatoes and avocado slices"
	icon_state = "cuy"
	bitesize = 5
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("salty" = 1, "mousey" = 1)

/obj/item/food/ensaladacactus
	name = "Salad of Pickly Pear"
	desc = "An salad everyday keeps you away from a doctor."
	icon_state = "salad"
	filling_color = "#89F834"
	bitesize = 1
	trash = /obj/item/trash/empty_plasticcup
	list_reagents = list("nutriment" = 3, "vitamin" = 8)
	tastes = list("prickly pear" = 4, "cabbage and tomato" = 3)

/obj/item/food/gigapuddi
	name = "Giga Puddi"
	desc = "A large crème caramel."
	icon_state = "gigapuddi"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 2, "vitamin" = 2)
	tastes = list("japanese" = 4, "milk" = 3)
	bitesize = 50

/obj/item/food/gigapuddi/happy
	desc = "A large crème caramel, made with extra love."
	icon_state = "happypuddi"
	list_reagents = list("nutriment" = 2, "vitamin" = 1, "milk" = 1, "love" = 1)
	tastes = list("japanese" = 4, "milk" = 3, "love" = 2)

/obj/item/food/gigapuddi/anger
	desc = "A large crème caramel, made with extra hate."
	icon_state = "angerpuddi"
	list_reagents = list("nutriment" = 2, "vitamin" = 1, "milk" = 1, "hate" = 1)
	tastes = list("japanese" = 4, "milk" = 3, "hate" = 2)

/obj/item/food/caribean_paradise
	name = "Caribean Paradise"
	icon_state = "caribean_paradise"
	bitesize = 3
	desc = "Half coconut stuffed with mango"
	trash = /obj/item/food/sliced/coconut
	filling_color = "#E37F0E"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "vitamin" = 4)
	tastes = list("mango" = 1)

/obj/item/food/mushrooms_curry
	name = "Mushrooms Curry"
	icon_state = "mushrooms_curry"
	bitesize = 5
	desc = "A slight twist to the traditional recipe, rare but delicious"
	list_reagents = list("nutriment" = 5,  "vitamin" = 4)

/obj/item/food/garlic_snack
	name = "Garlic Dip Dish"
	icon_state = "garlic_snack"
	bitesize = 5
	desc = "A fresh garlic-avocado mix"
	filling_color = "#E6EBD1"
	list_reagents = list("nutriment" = 4,  "vitamin" = 4)

/obj/item/food/avocadosandwich
	name = "Sandwich of Avocado"
	desc = "Made of avocado and lots of mayonnaise."
	icon_state = "avocado_sandwich"
	filling_color = "#fff98f"
	list_reagents = list("nutriment" = 6, "vitamin" = 6, "mayonnaise" = 5)
	tastes = list("bread" = 1, "avocado" = 2)

/obj/item/food/salmoncreamtoast
	name = "Salmon Cream cheese toast"
	desc = "Bite size toast with salmon and thick cream cheese"
	icon_state = "scc_toast"
	filling_color = "#ff8c69"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 6, "cream_cheese" = 5)
	tastes = list("bread" = 1, "avocado" = 2)

/obj/item/food/soup/macacosoup
	name = "Macaco Soup"
	desc = "Uma delicia"
	icon_state = "macacosoup"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)

/obj/item/food/soup/furamingosoup
	name = "Furamingo Soup"
	desc = "Black, white, pink or blue"
	icon_state = "furamingosoup"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)

/obj/item/food/salmoncurry
	name = "Salmon Curry"
	desc = "it uses a combination of spices and herbs to create a tasty meal"
	icon_state = "carpcurry"
	trash = /obj/item/trash/snack_bowl
	bitesize = 4
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "blackpepper" = 1, "capsaicin" = 1)
	tastes = list("spicy" = 1, "salmon" = 1, "milk" = 1)

// ---------- END of imports from Hispania!
