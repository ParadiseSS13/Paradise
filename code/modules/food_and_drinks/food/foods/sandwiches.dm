
//////////////////////
//		Burgers		//
//////////////////////

// Abstract object used for inheritance. Should never spawn. Needed to not break recipes that use plain burgers; recipes that use "burger" would accept any burger and transfer reagents otherwise.

/obj/item/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "If you got this, something broke! Contact a coder if this somehow spawns."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "burger"

/obj/item/reagent_containers/food/snacks/burger/plain
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#D63C3C"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "meat" = 1)

/obj/item/reagent_containers/food/snacks/burger/brain
	name = "brainburger"
	desc = "A strange looking burger. It appears almost sentient."
	icon_state = "brainburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "prions" = 10, "vitamin" = 1)
	tastes = list("bun" = 4, "brains" = 2)

/obj/item/reagent_containers/food/snacks/burger/ghost
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#FFF2FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "ectoplasm" = 2)

/obj/item/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "tender meat" = 2)

/obj/item/reagent_containers/food/snacks/burger/cheese
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "meat" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/burger/tofu
	name = "tofu burger"
	desc = "Making this should probably be a criminal offense."
	icon_state = "tofuburger"
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "tofu" = 4)

/obj/item/reagent_containers/food/snacks/burger/hamborger
	name = "hamborger"
	desc = "Looking at this makes your flesh feel like a weakness."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "nanomachines" = 10, "vitamin" = 1)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)

/obj/item/reagent_containers/food/snacks/burger/hamborger/Initialize(mapload)
	. = ..()
	message_admins("A [name] has been created at [ADMIN_COORDJMP(src)].")

/obj/item/reagent_containers/food/snacks/burger/xeno
	name = "xenoburger"
	desc = "Smells caustic and tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43DE18"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "acid" = 4)

/obj/item/reagent_containers/food/snacks/burger/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#FF00FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "banana" = 1, "magic" = 2)

/obj/item/reagent_containers/food/snacks/burger/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "silence" = 2)

/obj/item/reagent_containers/food/snacks/burger/baseball
	name = "home run baseball burger"
	desc = "It's still warm. Batter up!"
	icon_state = "baseball"
	filling_color = "#CD853F"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "a homerun" = 3)

/obj/item/reagent_containers/food/snacks/burger/spell
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#D505FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "magic" = 2)

/obj/item/reagent_containers/food/snacks/burger/bigbite
	name = "BigBite burger"
	desc = "Forget the Big Mac, THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#E3D681"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("bun" = 4, "meat" = 2, "cheese" = 2, "type two diabetes" = 10)

/obj/item/reagent_containers/food/snacks/burger/superbite
	name = "SuperBite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#CCA26A"
	bitesize = 7
	list_reagents = list("nutriment" = 40, "vitamin" = 5)
	tastes = list("bun" = 4, "meat" = 2, "cheese" = 2, "type two diabetes" = 10)

/obj/item/reagent_containers/food/snacks/burger/crazy
	name = "crazy hamburger"
	desc = "This looks like the sort of food that a demented clown in a trenchcoat would make."
	icon_state = "crazyburger"
	filling_color = "#E3D681"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2, "capsaicin" = 3, "condensedcapsaicin" = 2)
	tastes = list("bun" = 2, "meat" = 4, "cheese" = 2, "beef soaked in chili" = 3, "a smoking flare" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/white
	name = "white pretty patty"
	desc = "Delicious titanium!"
	icon_state = "ppatty-mime"
	filling_color = "#FFFFFF"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "white" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/red
	name = "red pretty patty"
	desc = "Perfect for hiding the fact that it's burnt to a crisp."
	icon_state = "ppatty-red"
	filling_color = "#D63C3C"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "red" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/orange
	name = "orange pretty patty"
	desc = "Contains 0% juice."
	icon_state = "ppatty-orange"
	filling_color = "#FFA500"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "orange" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/yellow
	name = "yellow pretty patty"
	desc = "Bright to the last bite."
	icon_state = "ppatty-yellow"
	filling_color = "#FFFF00"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "yellow" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/green
	name = "green pretty patty"
	desc = "It's not tainted meat, it's painted meat!"
	icon_state = "ppatty-green"
	filling_color = "#00FF00"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "green" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/blue
	name = "blue pretty patty"
	desc = "Is this blue rare?"
	icon_state = "ppatty-blue"
	filling_color = "#0000FF"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "blue" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/purple
	name = "purple pretty patty"
	desc = "Regal and low class at the same time."
	icon_state = "ppatty-purple"
	filling_color = "#800080"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "protein" = 1)
	tastes = list("bun" = 2, "meat" = 2, "purple" = 2)

/obj/item/reagent_containers/food/snacks/burger/ppatty/rainbow
	name = "rainbow pretty patty"
	desc = "Taste the rainbow, eat the rainbow."
	icon_state = "ppatty-rainbow"
	filling_color = "#0000FF"
	bitesize = 4
	list_reagents = list("nutriment" = 14, "protein" = 5, "omnizine" = 10)
	tastes = list("bun" = 2, "meat" = 2, "rainbow" = 5)

/obj/item/reagent_containers/food/snacks/burger/elec
	name = "empowered burger"
	desc = "It's shockingly good, if you live off of electricity that is."
	icon_state = "empoweredburger"
	filling_color = "#FFFF00"
	bitesize = 2
	list_reagents = list("nutriment" = 5, "protein" = 1, "plasma" = 2)
	tastes = list("bun" = 2, "pure electricity" = 5)

/obj/item/reagent_containers/food/snacks/burger/rat
	name = "mouse burger"
	desc = "Pretty much what you'd expect..."
	icon_state = "ratburger"
	filling_color = "#808080"
	bitesize = 2
	list_reagents = list("nutriment" = 5, "protein" = 1)
	tastes = list("bun" = 2, "dead rat" = 5)

/obj/item/reagent_containers/food/snacks/burger/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	icon_state = "appendixburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 6, "vitamin" = 6)
	tastes = list("bun" = 1, "grass" = 1)

/obj/item/reagent_containers/food/snacks/burger/bacon
	name = "bacon burger"
	desc = "The perfect combination of all things American."
	icon_state = "baconburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "vitamin" = 2, "protein" = 6)
	tastes = list("bun" = 1, "bacon" = 1)


/obj/item/reagent_containers/food/snacks/burger/bearger
	name = "bearger"
	desc = "Best served rawr."
	icon_state = "bearger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "protein" = 6, "vitamin" = 2)
	tastes = list("bun" = 1, "meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/burger/fivealarm
	name = "five alarm burger"
	desc = "HOT! HOT!"
	icon_state = "fivealarmburger"
	bitesize = 3
	filling_color = "#F2B6EA"
	list_reagents = list("nutriment" = 4, "protein" = 6, "condensedcapsaicin" = 5, "capsaicin" = 5)
	tastes = list("bun" = 1, "extreme heat" = 1)

/obj/item/reagent_containers/food/snacks/burger/mcguffin
	name = "mcGuffin"
	desc = "A cheap and greasy imitation of an eggs benedict."
	icon_state = "mcguffin"
	bitesize = 3
	filling_color = "#F2B6EA"
	list_reagents = list("nutriment" = 2, "protein" = 7, "vitamin" = 1)
	tastes = list("muffin" = 1, "bacon" = 1)

/obj/item/reagent_containers/food/snacks/burger/mcrib
	name = "mcRib"
	desc = "An elusive rib shaped burger with limited availablity across the galaxy. Not as good as you remember it."
	icon_state = "mcrib"
	bitesize = 3
	filling_color = "#F2B6EA"
	list_reagents = list("nutriment" = 2, "protein" = 7, "vitamin" = 4, "bbqsauce" = 1)
	tastes = list("bun" = 1, "pork" = 1, "patty" = 1)

/obj/item/reagent_containers/food/snacks/burger/jelly
	name = "jelly burger"
	desc = "Culinary delight...?"
	icon_state = "jellyburger"
	filling_color = "#B572AB"
	bitesize = 3
	tastes = list("bun" = 4, "jelly" = 2)

/obj/item/reagent_containers/food/snacks/burger/jelly/slime
	list_reagents = list("nutriment" = 6, "slimejelly" = 5, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/burger/jelly/cherry
	list_reagents = list("nutriment" = 6, "cherryjelly" = 5, "vitamin" = 1)


//////////////////////
//	Sandwiches		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "sandwich"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("meat" = 2, "cheese" = 1, "bread" = 2, "lettuce" = 1)

/obj/item/reagent_containers/food/snacks/toastedsandwich
	name = "toasted sandwich"
	desc = "Now if you only had a pepper bar."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "toastedsandwich"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 6, "carbon" = 2)
	tastes = list("toast" = 1)

/obj/item/reagent_containers/food/snacks/grilledcheese
	name = "grilled cheese sandwich"
	desc = "Goes great with tomato soup!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "grilledcheese"
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 7, "vitamin" = 1) //why make a regualr sandwhich when you can make grilled cheese, with this nutriment value?
	tastes = list("toast" = 1, "grilled cheese" = 1)

/obj/item/reagent_containers/food/snacks/jellysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellysandwich"
	filling_color = "#9E3A78"
	bitesize = 3
	tastes = list("toast" = 1, "jelly" = 1)

/obj/item/reagent_containers/food/snacks/jellysandwich/slime
	list_reagents = list("nutriment" = 2, "slimejelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/jellysandwich/cherry
	list_reagents = list("nutriment" = 2, "cherryjelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "notasandwich"
	list_reagents = list("nutriment" = 6, "vitamin" = 6)
	tastes = list("nothing suspicious" = 1)

/obj/item/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "wrap"
	list_reagents = list("nutriment" = 5)
	tastes = list("egg" = 1)

/obj/item/reagent_containers/food/snacks/blt
	name = "\improper BLT"
	desc = "A classic bacon, lettuce, and tomato sandwich."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "blt"
	filling_color = "#D63C3C"
	bitesize = 4
	list_reagents = list("nutriment" = 5, "protein" = 2)
	tastes = list("bacon" = 3, "lettuce" = 2, "tomato" = 2, "bread" = 2)

/obj/item/reagent_containers/food/snacks/peanut_butter_jelly
	name = "peanut butter and jelly sandwich"
	desc = "A classic PB&J sandwich, just like your mom used to make."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "peanut_butter_jelly_sandwich"
	filling_color = "#9E3A78"
	bitesize = 2
	tastes = list("peanut butter" = 3, "jelly" = 3, "bread" = 2)

/obj/item/reagent_containers/food/snacks/peanut_butter_jelly/slime
	list_reagents = list("peanutbutter" = 2, "slimejelly" = 5, "nutriment" = 5, "protein" = 2)

/obj/item/reagent_containers/food/snacks/peanut_butter_jelly/cherry
	list_reagents = list("peanutbutter" = 2, "cherryjelly" = 5, "nutriment" = 5, "protein" = 2)

/obj/item/reagent_containers/food/snacks/philly_cheesesteak
	name = "Philly cheesesteak"
	desc = "A popular sandwich made of sliced meat, onions, melted cheese in a long hoagie roll. Mouthwatering doesn't even begin to describe it."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "philly_cheesesteak"
	filling_color = "#D9BE29"
	bitesize = 4
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("steak" = 3, "melted cheese" = 3, "onions" = 2, "bread" = 2)

/obj/item/reagent_containers/food/snacks/peanut_butter_banana
	name = "peanut butter and banana sandwich"
	desc = "A peanut butter sandwich with banana slices mixed in, a good high protein treat."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "peanut_butter_banana_sandwich"
	filling_color = "#D9BE29"
	bitesize = 2
	list_reagents = list("nutriment" = 5, "protein" = 2)
	tastes = list("peanutbutter" = 3, "banana" = 3, "bread" = 2)
