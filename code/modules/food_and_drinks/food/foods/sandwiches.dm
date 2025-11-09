
//////////////////////
//		Burgers		//
//////////////////////

// Abstract object used for inheritance. Should never spawn. Needed to not break recipes that use plain burgers; recipes that use "burger" would accept any burger and transfer reagents otherwise.

/obj/item/food/burger
	name = "burger"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "burger"

/obj/item/food/burger/plain
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#D63C3C"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "meat" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/brain
	name = "brainburger"
	desc = "A strange looking burger. It appears almost sentient."
	icon_state = "brainburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "prions" = 10, "vitamin" = 1)
	tastes = list("bun" = 4, "brains" = 2)

/obj/item/food/burger/ghost
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#FFF2FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "ectoplasm" = 2)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/food/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "tender meat" = 2)

/obj/item/food/burger/cheese
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "meat" = 1, "cheese" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/tofu
	name = "tofu burger"
	desc = "Making this should probably be a criminal offense."
	icon_state = "tofuburger"
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "tofu" = 4)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/hamborger
	name = "hamborger"
	desc = "Looking at this makes your flesh feel like a weakness."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "nanomachines" = 10, "vitamin" = 1)
	tastes = list("bun" = 4, "metal" = 2, "sludge" = 1)

/obj/item/food/burger/hamborger/Initialize(mapload)
	. = ..()
	message_admins("A [name] has been created at [ADMIN_COORDJMP(src)].")

/obj/item/food/burger/xeno
	name = "xenoburger"
	desc = "Smells caustic and tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43DE18"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "acid" = 4)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#FF00FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "banana" = 1, "magic" = 2)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "silence" = 2)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/baseball
	name = "home run baseball burger"
	desc = "It's still warm. Batter up!"
	icon_state = "baseball"
	filling_color = "#CD853F"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "a homerun" = 3)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/spell
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#D505FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "magic" = 2)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/bigbite
	name = "BigBite burger"
	desc = "Forget the Big Mac, THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#E3D681"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("bun" = 4, "meat" = 2, "cheese" = 2, "type two diabetes" = 10)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/superbite
	name = "SuperBite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#CCA26A"
	bitesize = 7
	list_reagents = list("nutriment" = 40, "vitamin" = 5)
	tastes = list("bun" = 4, "meat" = 2, "cheese" = 2, "type two diabetes" = 10)
	goal_difficulty = FOOD_GOAL_HARD

/obj/item/food/burger/crazy
	name = "crazy hamburger"
	desc = "This looks like the sort of food that a demented clown in a trenchcoat would make."
	icon_state = "crazyburger"
	filling_color = "#E3D681"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2, "capsaicin" = 3, "condensedcapsaicin" = 2)
	tastes = list("bun" = 2, "meat" = 4, "cheese" = 2, "beef soaked in chili" = 3, "a smoking flare" = 2)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/ppatty/white
	name = "white pretty patty"
	desc = "Delicious titanium!"
	icon_state = "ppatty-mime"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "white" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/red
	name = "red pretty patty"
	desc = "Perfect for hiding the fact that it's burnt to a crisp."
	icon_state = "ppatty-red"
	filling_color = "#D63C3C"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "red" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/orange
	name = "orange pretty patty"
	desc = "Contains 0% juice."
	icon_state = "ppatty-orange"
	filling_color = "#FFA500"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "orange" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/yellow
	name = "yellow pretty patty"
	desc = "Bright to the last bite."
	icon_state = "ppatty-yellow"
	filling_color = "#FFFF00"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "yellow" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/green
	name = "green pretty patty"
	desc = "It's not tainted meat, it's painted meat!"
	icon_state = "ppatty-green"
	filling_color = "#00FF00"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "green" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/blue
	name = "blue pretty patty"
	desc = "Is this blue rare?"
	icon_state = "ppatty-blue"
	filling_color = "#0000FF"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "blue" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/purple
	name = "purple pretty patty"
	desc = "Regal and low class at the same time."
	icon_state = "ppatty-purple"
	filling_color = "#800080"
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "purple" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/ppatty/rainbow
	name = "rainbow pretty patty"
	desc = "Taste the rainbow, eat the rainbow."
	icon_state = "ppatty-rainbow"
	filling_color = "#0000FF"
	bitesize = 4
	list_reagents = list("nutriment" = 14, "protein" = 5, "omnizine" = 10)
	tastes = list("bun" = 2, "meat" = 2, "rainbow" = 5)
	goal_difficulty = FOOD_GOAL_HARD

/obj/item/food/burger/elec
	name = "empowered burger"
	desc = "It's shockingly good, if you live off of electricity that is."
	icon_state = "empoweredburger"
	filling_color = "#FFFF00"
	list_reagents = list("nutriment" = 5, "protein" = 1, "plasma" = 2)
	tastes = list("bun" = 2, "pure electricity" = 5)
	goal_difficulty = FOOD_GOAL_HARD

/obj/item/food/burger/rat
	name = "mouse burger"
	desc = "Pretty much what you'd expect..."
	icon_state = "ratburger"
	filling_color = "#808080"
	list_reagents = list("nutriment" = 5, "protein" = 1)
	tastes = list("bun" = 2, "dead rat" = 5)

/obj/item/food/burger/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	icon_state = "appendixburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 6, "vitamin" = 6)
	tastes = list("bun" = 1, "grass" = 1)

/obj/item/food/burger/bacon
	name = "bacon burger"
	desc = "The perfect combination of all things American."
	icon_state = "baconburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "protein" = 6)
	tastes = list("bun" = 1, "bacon" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/burger/bearger
	name = "bearger"
	desc = "Best served rawr."
	icon_state = "bearger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "protein" = 6, "vitamin" = 2)
	tastes = list("bun" = 1, "meat" = 1, "salmon" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/burger/fivealarm
	name = "five alarm burger"
	desc = "HOT! HOT!"
	icon_state = "fivealarmburger"
	bitesize = 3
	filling_color = "#F2B6EA"
	list_reagents = list("nutriment" = 4, "protein" = 6, "condensedcapsaicin" = 5, "capsaicin" = 5)
	tastes = list("bun" = 1, "extreme heat" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/mcguffin
	name = "mcGuffin"
	desc = "A cheap and greasy imitation of an eggs benedict."
	icon_state = "mcguffin"
	bitesize = 3
	filling_color = "#F2B6EA"
	list_reagents = list("nutriment" = 2, "protein" = 7, "vitamin" = 1)
	tastes = list("muffin" = 1, "bacon" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/mcrib
	name = "mcRib"
	desc = "An elusive rib-shaped burger with limited availability across the galaxy. Not as good as you remember it."
	icon_state = "mcrib"
	bitesize = 3
	filling_color = "#F2B6EA"
	list_reagents = list("nutriment" = 2, "protein" = 7, "vitamin" = 4, "bbqsauce" = 1)
	tastes = list("bun" = 1, "pork" = 1, "patty" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/chicken
	name = "chicken burger"
	desc = "May I mayo?"
	icon_state = "chickenburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "chicken" = 2)

/obj/item/food/burger/jelly
	name = "jelly burger"
	desc = "Culinary delight...?"
	icon_state = "jellyburger"
	filling_color = "#B572AB"
	bitesize = 3
	tastes = list("bun" = 4, "jelly" = 2)

/obj/item/food/burger/jelly/slime
	name = "slime burger"
	list_reagents = list("nutriment" = 6, "slimejelly" = 5, "vitamin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/burger/jelly/cherry
	list_reagents = list("nutriment" = 6, "cherryjelly" = 5, "vitamin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


//////////////////////
//	Sandwiches		//
//////////////////////

/obj/item/food/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "sandwich"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("meat" = 2, "cheese" = 1, "bread" = 2, "lettuce" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/toastedsandwich
	name = "toasted sandwich"
	desc = "Now if you only had a pepper bar."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "toastedsandwich"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 6, "carbon" = 2)
	tastes = list("toast" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/grilledcheese
	name = "grilled cheese sandwich"
	desc = "Goes great with tomato soup!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "grilledcheese"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 7, "vitamin" = 1) //why make a regualr sandwhich when you can make grilled cheese, with this nutriment value?
	tastes = list("toast" = 1, "grilled cheese" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/jellysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellysandwich"
	filling_color = "#9E3A78"
	bitesize = 3
	tastes = list("toast" = 1, "jelly" = 1)

/obj/item/food/jellysandwich/slime
	name = "slime sandwich"
	list_reagents = list("nutriment" = 2, "slimejelly" = 5, "vitamin" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/jellysandwich/cherry
	name = "cherry sandwich"
	list_reagents = list("nutriment" = 2, "cherryjelly" = 5, "vitamin" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, but you can't quite figure out what. Maybe it's his moustache."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "notasandwich"
	list_reagents = list("nutriment" = 6, "vitamin" = 6)
	tastes = list("nothing suspicious" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	list_reagents = list("nutriment" = 5)
	tastes = list("egg" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/blt
	name = "\improper BLT"
	desc = "A classic bacon, lettuce, and tomato sandwich."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "blt"
	filling_color = "#D63C3C"
	bitesize = 4
	list_reagents = list("nutriment" = 5, "protein" = 2)
	tastes = list("bacon" = 3, "lettuce" = 2, "tomato" = 2, "bread" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/peanut_butter_jelly
	name = "peanut butter and jelly sandwich"
	desc = "A classic PB&J sandwich, just like your mom used to make."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "peanut_butter_jelly_sandwich"
	filling_color = "#9E3A78"
	tastes = list("peanut butter" = 3, "jelly" = 3, "bread" = 2)

/obj/item/food/peanut_butter_jelly/slime
	name = "peanut butter and slime sandwich"
	desc = "A classic PB&J sandwich, just like your mom used to make?"
	list_reagents = list("peanutbutter" = 2, "slimejelly" = 5, "nutriment" = 5, "protein" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/peanut_butter_jelly/cherry
	list_reagents = list("peanutbutter" = 2, "cherryjelly" = 5, "nutriment" = 5, "protein" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/philly_cheesesteak
	name = "Philly cheesesteak"
	desc = "A popular sandwich made of sliced meat, onions, melted cheese in a long hoagie roll. Mouthwatering doesn't even begin to describe it."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "philly_cheesesteak"
	filling_color = "#D9BE29"
	bitesize = 4
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("steak" = 3, "melted cheese" = 3, "onions" = 2, "bread" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/peanut_butter_banana
	name = "peanut butter and banana sandwich"
	desc = "A peanut butter sandwich with banana slices mixed in, a good high protein treat."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "peanut_butter_banana_sandwich"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 5, "protein" = 2)
	tastes = list("peanutbutter" = 3, "banana" = 3, "bread" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/glass_sandwich
	name = "glass sandwich"
	desc = "Crushed glass shards sandwiched between two slices of plain bread. Crunchy!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "glass_sandwich"
	tastes = list("dozens of glass shards skewering your mouth" = 3, "pain" = 3, "bread" = 2)
	list_reagents = list("nutriment" = 2, "glass_shards" = 5)
	var/bite_damage = 2

/obj/item/food/glass_sandwich/On_Consume(mob/living/M)
	..()
	M.adjustBruteLoss(bite_damage)

/obj/item/food/glass_sandwich/plasma
	name = "plasma glass sandwich"
	desc = "Razor-sharp plasma glass shards, crushed up and sandwiched between two slices of plain bread. Extra crunchy!"
	icon_state = "plasma_glass_sandwich"
	list_reagents = list("nutriment" = 2, "glass_shards" = 5, "plasma" = 5)
	bite_damage = 4

/obj/item/food/glass_sandwich/plasma/plastitanium
	name = "plastitanium glass sandwich"
	desc = "Evil-looking plastitanium glass shards, crushed up and sandwiched between two slices of plain bread. Evilly crunchy!"
	icon_state = "plastitanium_glass_sandwich"

/obj/item/food/supermatter_sandwich
	name = "supermatter sandwich"
	desc = "A supermatter sliver, somehow safely contained between two slices of bread. You have been told many times to not lick the forbidden nacho... But surely one taste can't be that bad?"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "supermatter_sandwich"
	tastes = list("indescribable power" = 3, "bread" = 2)
	list_reagents = list("vitamin" = 50) // Supermatter is full of energy!

/obj/item/food/supermatter_sandwich/On_Consume(mob/living/M)
	..()
	if(!HAS_TRAIT(M, TRAIT_SUPERMATTER_IMMUNE))
		M.visible_message(
			"<span class='danger'>[M] lifts [src] up to [M.p_their()] mouth and bites down, inducing a resonance... [M.p_their(TRUE)] body starts to glow and burst into flames before flashing into dust!</span>",
			"<span class='userdanger'>You bite down on [src].<br><br> Everything starts burning and all you can hear is ringing. Your final thought is: \"OH FU-\"</span>",
			"<span class='danger'>A deafening resonance fills the air, followed by silence...</span>"
		)
		radiation_pulse(src, 2000, GAMMA_RAD)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		M.drop_item() // How many bridge hobos will take a bite, I wonder?
		M.dust()
		message_admins("[src] has consumed [key_name_admin(M)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(M)].", INVESTIGATE_SUPERMATTER)

/obj/item/food/supermatter_sandwich/process()
	. = ..()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ffd04f", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)
