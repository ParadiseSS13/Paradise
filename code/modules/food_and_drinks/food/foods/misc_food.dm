
//////////////////////
//		Meals		//
//////////////////////

/obj/item/food/eggplantparm
	name = "eggplant parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4D2F5E"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("eggplant" = 2, "cheese" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/soylentgreen
	name = "soylent green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#B8E6B5"
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	tastes = list("waffles" = 7, "people" = 1)

/obj/item/food/soylentviridians
	name = "soylent virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#E6FA61"
	list_reagents = list("nutriment" = 10, "vitamin" = 1)
	tastes = list("waffles" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/monkeysdelight
	name = "monkey's delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5C3C11"
	bitesize = 6
	list_reagents = list("nutriment" = 10, "banana" = 5, "vitamin" = 5)
	tastes = list("banana" = 1, "the jungle" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/dionaroast
	name = "roast diona"
	desc = "It's like an enormous leathery carrot... With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754B"
	list_reagents = list("plantmatter" = 4, "nutriment" = 2, "radium" = 2, "vitamin" = 4)
	tastes = list("chewy vegetables" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/tofurkey
	name = "tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 12)
	tastes = list("tofu" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


//////////////////////
//		Salads		//
//////////////////////

/obj/item/food/salad
	name = "salad"
	desc = "This salad is blander than the jokes of the clown, but is also low in carbohydrates!"
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "salad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#468C00"
	bitesize = 3
	list_reagents = list("nutriment" = 6,"vitamin" = 4)
	tastes = list("lettuce" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/salad/aesir
	name = "aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	list_reagents = list("nutriment" = 8, "omnizine" = 8, "vitamin" = 6)
	tastes = list("divinity" = 1, "lettuce" = 1)

/obj/item/food/salad/antipasto
	name = "antipasto salad"
	desc = "A traditional Italian salad made of salami, mozzarella cheese, olives, and tomatoes. Often served as a first course meal."
	icon_state = "antipasto_salad"
	list_reagents = list("nutriment" = 12, "protein" = 6, "vitamin" = 6)
	tastes = list("lettuce" = 2, "salami" = 2, "mozzarella cheese" = 2, "tomatoes" = 2, "dressing" = 1)

/obj/item/food/salad/caesar
	name = "Caesar salad"
	desc = "A simple yet flavorful salad of onions, lettuce, croutons, and shreds of cheese dressed in oil. Comes with a slice of pita bread!"
	icon_state = "caesar_salad"
	list_reagents = list("nutriment" = 12, "vitamin" = 6)
	tastes = list("healthy greens" = 2, "olive dressing" = 2, "feta cheese" = 2, "pita bread" = 1)

/obj/item/food/salad/fruit
	name = "fruit salad"
	desc = "Your standard fruit salad."
	icon_state = "fruitsalad"
	list_reagents = list("nutriment" = 9, "vitamin" = 4)
	tastes = list("fruit" = 1)

/obj/item/food/salad/greek
	name = "Greek salad"
	desc = "A popular salad made of tomatoes, onions, feta cheese, and olives all drizzled in olive oil. Though it feels like it's missing something..."
	icon_state = "greek_salad"
	list_reagents = list("nutriment" = 13, "vitamin" = 14)
	tastes = list("healthy greens" = 2, "olive dressing" = 1, "feta cheese" = 1)

/obj/item/food/salad/citrusdelight
	name = "citrus delight"
	desc = "Citrus overload!"
	icon_state = "citrusdelight"
	list_reagents = list("nutriment" = 11, "vitamin" = 7)
	tastes = list("sourness" = 1, "leaves" = 1)

/obj/item/food/salad/jungle
	name = "jungle salad"
	desc = "Exotic fruits in a bowl."
	icon_state = "junglesalad"
	list_reagents = list("banana" = 5, "nutriment" = 11, "vitamin" = 7)
	tastes = list("fruit" = 1, "the jungle" = 1)

/obj/item/food/salad/kale
	name = "kale salad"
	desc = "A healthy kale salad drizzled in oil, perfect for warm summer months."
	icon_state = "kale_salad"
	list_reagents = list("nutriment" = 12, "vitamin" = 12)
	tastes = list("healthy greens" = 2, "olive dressing" = 1)

/obj/item/food/salad/potato
	name = "potato salad"
	desc = "A dish of boiled potatoes mixed with boiled eggs, onions, and mayonnaise. A staple of every self-respecting barbeque."
	icon_state = "potato_salad"
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("potato" = 2, "egg" = 2, "mayonnaise" = 2)

/obj/item/food/salad/melonfruitbowl
	name = "melon fruit bowl"
	desc = "For people who wants edible fruit bowls."
	icon_state = "melonfruitbowl"
	trash = null
	list_reagents = list("nutriment" = 6, "vitamin" = 4)
	tastes = list("melon" = 1)

/obj/item/food/salad/herb
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	filling_color = "#76B87F"
	list_reagents = list("nutriment" = 8, "vitamin" = 2)
	tastes = list("lettuce" = 1, "apple" = 1)

/obj/item/food/salad/valid
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	filling_color = "#76B87F"
	list_reagents = list("nutriment" = 8, "salglu_solution" = 5, "vitamin" = 2)
	tastes = list("fried potato" = 1, "lettuce" = 1, "meat" = 1, "valids" = 1)


//////////////////////
//	Donk Pockets	//
//////////////////////

/obj/item/food/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list("nutriment" = 4)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	ingredient_name = "turnover"

/obj/item/food/warmdonkpocket
	name = "warm Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list("nutriment" = 4)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	/// Is the donk pocket warm or has it cooled - this affects what chemicals it yields when consumed
	var/warm = TRUE
	/// This stores the timer for how long the donk pocket takes to cool, seven minutes, that is paused inside of a donk pocket box
	var/cool_timer
	/// This is used to check the world time when the donk pocket was heated or last removed from a donk pocket box, for restarting the timer
	var/heated_at
	/// This tracks how much time the donk pocket has already been cooling for when its timer is paused
	var/subtracted_time = 0

/obj/item/food/warmdonkpocket/Initialize(mapload)
	. = ..()
	donk_heat()

/obj/item/food/warmdonkpocket/proc/donk_heat()
	heated_at = world.time
	cool_timer = addtimer(CALLBACK(src, PROC_REF(donk_cool)), 7 MINUTES - subtracted_time, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/item/food/warmdonkpocket/proc/donk_cool()
	name = "cold Donk-pocket"
	desc = "The food of choice for the seasoned traitor. This one is cold."
	warm = FALSE

/obj/item/food/warmdonkpocket/on_enter_storage(obj/item/storage/S)
	. = ..()
	if(!cool_timer)
		return
	if(istype(S, /obj/item/storage/box/donkpockets))
		deltimer(cool_timer)
		subtracted_time += (world.time - heated_at)
		cool_timer = null

/obj/item/food/warmdonkpocket/on_exit_storage(obj/item/storage/S)
	. = ..()
	if(warm)
		donk_heat()

/obj/item/food/warmdonkpocket/Post_Consume(mob/living/M)
	if(warm)
		M.reagents.add_reagent("omnizine", 15)
		return
	M.reagents.add_reagent("weak_omnizine", 5)

/obj/item/food/warmdonkpocket_weak
	name = "lukewarm Donk-pocket"
	desc = "The food of choice for the seasoned traitor. This one is lukewarm."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	list_reagents = list("nutriment" = 4, "weak_omnizine" = 3)

/obj/item/food/syndidonkpocket
	name = "Donk-pocket"
	desc = "This donk-pocket is emitting a small amount of heat."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	bitesize = 100 //nom the whole thing at once.
	list_reagents = list("nutriment" = 1)

/obj/item/food/syndidonkpocket/Post_Consume(mob/living/M)
	M.reagents.add_reagent("omnizine", 15)
	M.reagents.add_reagent("teporone", 15)
	M.reagents.add_reagent("synaptizine", 15)
	M.reagents.add_reagent("salglu_solution", 15)
	M.reagents.add_reagent("salbutamol", 15)
	M.reagents.add_reagent("methamphetamine", 15)
	M.reagents.add_reagent("mannitol", 15)


//////////////////////
//		Misc		//
//////////////////////

/obj/item/food/boiledslimecore
	name = "boiled slime core"
	desc = "A boiled red thing."
	icon_state = "boiledrorocore"
	bitesize = 3
	list_reagents = list("slimejelly" = 5)
	tastes = list("jelly" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/popcorn
	name = "popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	gender = PLURAL
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#FFFAD4"
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	list_reagents = list("nutriment" = 2)
	tastes = list("popcorn" = 3, "butter" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/popcorn/Initialize(mapload)
	. = ..()
	unpopped = rand(1,10)

/obj/item/food/popcorn/On_Consume(mob/M, mob/user)
	if(prob(unpopped))	//lol ...what's the point?
		to_chat(user, "<span class='userdanger'>You bite down on an un-popped kernel!</span>")
		unpopped = max(0, unpopped-1)
	..()

/obj/item/food/liquidfood
	name = "\improper LiquidFood ration"
	desc = "A prepackaged grey slurry of all the essential nutrients for a spacefarer on the go. Should this be crunchy?"
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#A8A8A8"
	bitesize = 4
	list_reagents = list("nutriment" = 20, "iron" = 3, "vitamin" = 2)
