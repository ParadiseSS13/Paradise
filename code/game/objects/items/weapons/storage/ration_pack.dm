

/obj/item/storage/soviet_ration
	name = "The People's Field Ration"
	desc = "A compact USSP-produced field ration designed to feed a soldier in active combat for multiple days. Contains bars of ultra-condensed nutrition for maximum efficiency, \
	making it both the lightest and most calorie-dense ration in the entire Orion Arm. The USSP Bureau of Food stamp on the side certifies it as edible.\
	The USSP Bureau of Construction stamp on the other side certifies it as suitable to use as a building material."
	icon = 'icons/obj/storage.dmi'
	icon_state = "ration_soviet"
	storage_slots = 7
	can_hold = list(
		/obj/item/food/rations,
		/obj/item/reagent_containers/drinks/cans/sodawater,
		/obj/item/clothing/mask/cigarette,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/matches,
		/obj/item/match
	)

/obj/item/storage/soviet_ration/populate_contents()
	new /obj/item/food/rations/nutrient_prism(src)
	new /obj/item/food/rations/nutrient_prism(src)
	new /obj/item/food/rations/nutrient_prism(src)
	new /obj/item/food/rations/nutrient_prism(src)
	new /obj/item/reagent_containers/drinks/cans/sodawater(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_our_brand(src)
	new /obj/item/storage/fancy/matches(src)

#define MAIN_FOOD 1
#define SIDE_FOOD 2
#define SNACK_FOOD 3
#define DESSERT_FOOD 4

// Base type will randomly pick one of the menus.
/obj/item/storage/mre
	name = "Meal, Ready-to-Eat"
	desc = "A compact SolGov-produced field ration designed to feed a soldier in active combat. Contains self-heating food packets that require no prior preperation. \
	It meets all of the legal and technical requirements to be considered real food!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "ration_solgov"
	storage_slots = 8
	drop_sound = null
	pickup_sound = null
	can_hold = list(
		/obj/item/food/rations,
		/obj/item/reagent_containers/glass/beaker/waterbottle,
		/obj/item/clothing/mask/cigarette,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/fancy/matches,
		/obj/item/match,
		/obj/item/kitchen/utensil/pspoon/mre
	)
	/// Has anyone looked inside the MRE yet? Setting to TRUE changes the sprite and allows items to be added to the container.
	var/opened = FALSE
	///	Determines what set of food items will spawn in the MRE. Also alters the name and description of the MRE.
	var/menu_option
	/// Used when populating contents after doing get_menu_items().
	var/main_food
	/// Used when populating contents after doing get_menu_items().
	var/side_food
	/// Used when populating contents after doing get_menu_items().
	var/snack_food
	/// Used when populating contents after doing get_menu_items().
	var/dessert_food

/obj/item/storage/mre/Initialize(mapload)
	if(!menu_option)
		menu_option = pick("Chicken & Cavatelli", "BBQ Pork & Rice", "Pepperoni Pizza & Cheese-Filled Crackers", "Sushi & Rice Onigiri", "Spaghetti & Meatballs", "Creamy Spinach Fettuccini", "Cheese & Veggie Omlette")
	name =  "[name] ([menu_option])"
	get_menu_items(menu_option)
	. = ..()

/obj/item/storage/mre/show_to(mob/user as mob)
	if(!opened)
		opened = TRUE
		icon_state = "ration_solgov_open"
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -5)
		to_chat(user, "<span class='notice'>You tear open the packaging of [src].</span>")
	..()

/obj/item/storage/mre/can_be_inserted(obj/item/I as obj, stop_messages = FALSE)
	if(!opened)
		to_chat(usr, "<span class='warning'>You need to open [src] before you can put things inside it.</span>")
		return FALSE

	return ..()

/obj/item/storage/mre/examine()
	. = ..()
	. += "<span class = 'notice'>This one contains the [menu_option] menu.</span>"
	if(menu_option == "Cheese & Veggie Omlette")
		// The Cheese & Veggie Omlette is widely considered to be the most vile, disgusting MRE menu in history.
		. += "<span class = 'warning'>Looks like you'll be going hungry tonight...</span>"

/obj/item/storage/mre/examine_more(mob/user)
	. = ..()
	. += "The MRE is a lightweight, multi-component field ration used by the armed forces of the Trans-Solar Federation. The food is fortified with additional vitamins and nutrients, \
and designed with a minimum shelf life of 10 years. It's not exactly the most appetising thing out there, how appealing the food is can vary a lot, but it'll refill your energy after a strenuous day's work."
	. += ""
	. += "In addition to being used in all branches of the TSF's armed forces, it is also distributed as food aid in disaster zones, and can be bought from surplus sales. \
Frequently bought by preppers, explorers, and colonists heading out to the frontier."

/obj/item/storage/mre/populate_contents()
	new main_food(src)
	new side_food(src)
	new snack_food(src)
	new dessert_food(src)
	new /obj/item/kitchen/utensil/pspoon/mre(src)
	new /obj/item/reagent_containers/glass/beaker/waterbottle(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_solar_rays(src)
	new /obj/item/storage/fancy/matches(src)

/**
  * Selects one of several MRE menus based on the menu_option of the MRE. 
  *
  * Arguments:
  * * menu_item_list - Static list containing the food items associated with each MRE menu option.
  * * main_food - Takes first food item from the list for use in populate_contents().
  * * side_food - Takes second food item from the list for use in populate_contents().
  * * snack_food - Takes third food item from the list for use in populate_contents().
  * * dessert_food - Takes fourth food item from the list for use in populate_contents().
  */
/obj/item/storage/mre/proc/get_menu_items()
	var/static/list/menu_item_list = list(
		"Chicken & Cavatelli" = list(
			/obj/item/food/rations/mre/chicken,
			/obj/item/food/rations/mre/cavatelli,
			/obj/item/food/rations/mre/trail_mix,
			/obj/item/food/rations/mre/brownie
		),
		"BBQ Pork & Rice" = list(
			/obj/item/food/rations/mre/pork,
			/obj/item/food/rations/mre/rice,
			/obj/item/food/rations/mre/fighting_fuel,
			/obj/item/food/rations/mre/pancake
		),
		"Pepperoni Pizza & Cheese-Filled Crackers" = list(
			/obj/item/food/rations/mre/pizza,
			/obj/item/food/rations/mre/cheese_crackers,
			/obj/item/food/rations/mre/trail_mix,
			/obj/item/food/rations/mre/smores
		),
		"Sushi & Rice Onigiri" = list(
			/obj/item/food/rations/mre/sushi,
			/obj/item/food/rations/mre/onigiri,
			/obj/item/food/rations/mre/bun,
			/obj/item/food/rations/mre/spiced_apple
		),
		"Spaghetti & Meatballs" = list(
			/obj/item/food/rations/mre/spaghetti,
			/obj/item/food/rations/mre/meatballs,
			/obj/item/food/rations/mre/peanut_crackers,
			/obj/item/food/rations/mre/flan
		),
		"Creamy Spinach Fettuccini" = list(
			/obj/item/food/rations/mre/fettuccini,
			/obj/item/food/rations/mre/pretzel_nugget,
			/obj/item/food/rations/mre/fighting_fuel,
			/obj/item/food/rations/mre/pbj
		),
		// The Vomlette. The worst MRE in history.
		"Cheese & Veggie Omlette" = list(
			/obj/item/food/rations/mre/vomlette,
			/obj/item/food/rations/mre/cheese_crackers,
			/obj/item/food/rations/mre/bun,
			/obj/item/food/rations/mre/granola
		)
	)
	main_food = menu_item_list[menu_option][MAIN_FOOD]
	side_food = menu_item_list[menu_option][SIDE_FOOD]
	snack_food = menu_item_list[menu_option][SNACK_FOOD]
	dessert_food = menu_item_list[menu_option][DESSERT_FOOD]

/obj/item/storage/mre/chicken
	menu_option = "Chicken & Cavatelli"

/obj/item/storage/mre/pork
	menu_option = "BBQ Pork & Rice"

/obj/item/storage/mre/pizza
	menu_option = "Pepperoni Pizza & Cheese-Filled Crackers"

/obj/item/storage/mre/sushi
	menu_option = "Sushi & Rice Onigiri"

/obj/item/storage/mre/spaghetti
	menu_option = "Spaghetti & Meatballs"

/obj/item/storage/mre/fettuccini
	menu_option = "Creamy Spinach Fettuccini"

/obj/item/storage/mre/vomlette
	menu_option = "Cheese & Veggie Omlette"

#undef MAIN_FOOD
#undef SIDE_FOOD
#undef SNACK_FOOD
#undef DESSERT_FOOD
