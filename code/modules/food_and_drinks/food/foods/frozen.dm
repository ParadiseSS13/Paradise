
//////////////////////////////
//		Frozen Treats		//
//////////////////////////////

//Abstract item for inheritence.

/obj/item/food/frozen
	name = "frozen treat"
	desc = "If you got this, something broke! Contact a coder if this somehow spawns."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "flavorless_sc"

/obj/item/food/sliceable/clowncake
	name = "clown cake"
	desc = "A funny cake with a clown face on it."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "clowncake"
	slice_path = /obj/item/food/sliced/clowncake
	slices_num = 5
	bitesize = 3
	list_reagents = list("nutriment" = 20, "sugar" = 5, "vitamin" = 5, "banana" = 15)
	tastes = list("cake" = 5, "sweetness" = 2, "banana" = 1, "sad clowns" = 1, "ice-cream" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/sliced/clowncake
	name = "clown cake slice"
	desc = "A slice of bad jokes, and silly props."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "clowncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	list_reagents = list("nutriment" = 4, "sugar" = 1, "vitamin" = 1, "banana" = 3)
	tastes = list("cake" = 5, "sweetness" = 2, "sad clowns" = 1, "ice-cream" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

///////////////////
//	Ice Cream	//
//////////////////

/obj/item/food/frozen/icecream
	name = "ice cream"
	desc = "Delicious ice cream."
	icon_state = "icecream_cone"
	bitesize = 3
	list_reagents = list("nutriment" = 1, "sugar" = 1)
	tastes = list("ice cream" = 1)

/obj/item/food/frozen/icecream/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/food/frozen/icecream/update_overlays()
	. = ..()
	var/mutable_appearance/filling = mutable_appearance('icons/obj/food/frozen_treats.dmi', "icecream_color")
	var/list/reagent_colors = rgb2num(mix_color_from_reagents(reagents.reagent_list), COLORSPACE_HSV)  //switching to HSV colorspace lets us easily manipulate the saturation and brightness independently
	//Clamping the brightness keeps us from having greyish ice cream while still alowing for a range of colours
	filling.color = rgb(reagent_colors[1], ((1.5 * reagent_colors[2]) - 10), (clamp(reagent_colors[3], 85, 100) - 10), space = COLORSPACE_HSV)
	. += filling

/obj/item/food/frozen/icecream/icecreamcone
	name = "ice cream cone"
	list_reagents = list("nutriment" = 3, "sugar" = 7, "ice" = 2)

/obj/item/food/frozen/icecream/wafflecone
	name = "ice cream in a waffle cone"
	icon_state = "icecream_cone_waffle"
	list_reagents = list("nutriment" = 3, "sugar" = 7, "ice" = 2)

/obj/item/food/frozen/icecream/icecreamcup
	name = "chocolate ice cream cone"
	icon_state = "icecream_cone_chocolate"
	list_reagents = list("nutriment" = 5, "chocolate" = 8, "ice" = 2)

/obj/item/food/wafflecone
	name = "waffle cone"
	desc = "Delicious waffle cone, but no ice cream."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "icecream_cone_waffle"
	list_reagents = list("nutriment" = 5)
	tastes = list("cream" = 2, "waffle" = 1)

/obj/item/food/frozen/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable ice cream in its own packaging."
	icon_state = "icecreamsandwich"
	list_reagents = list("nutriment" = 2, "ice" = 2)
	tastes = list("ice cream" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/berryicecreamsandwich
	name = "strawberry icecream sandwich"
	desc = "Portable ice cream in its own packaging."
	icon_state = "strawberryicecreamsandwich"
	list_reagents = list("nutriment" = 2, "ice" = 2)
	tastes = list("ice cream" = 1, "strawberry" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/sundae
	name = "sundae"
	desc = "A classic dessert."
	icon_state = "sundae"
	list_reagents = list("nutriment" = 6, "banana" = 5, "vitamin" = 2)
	tastes = list("ice cream" = 1, "banana" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/honkdae
	name = "honkdae"
	desc = "The clown's favorite dessert."
	icon_state = "honkdae"
	list_reagents = list("nutriment" = 6, "banana" = 10, "vitamin" = 4)
	tastes = list("ice cream" = 1, "banana" = 1, "a bad joke" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/cornuto
	name = "cornuto"
	desc = "A neapolitan vanilla and chocolate ice cream cone. It menaces with a sprinkling of caramelized nuts."
	icon_state = "cornuto"
	list_reagents = list("nutriment" = 6, "hot_coco" = 4, "cream" = 2, "vanilla" = 4, "sugar" = 2)
	tastes = list("chopped hazelnuts" = 3, "waffle" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/peanutbuttermochi
	name = "peanut butter ice cream mochi"
	desc = "A classic dessert at the Arabia Street Night Market in Prospect, peanut butter ice cream mochi is made with a peanut-butter flavoured ice cream as the main filling, and coated in crushed peanuts in the Taiwanese tradition."
	icon_state = "pb_ice_cream_mochi"
	list_reagents = list("nutriment" = 4, "sugar" = 6, "peanutbutter" = 4, "milk" = 2)
	tastes = list("peanut butter" = 1, "mochi" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/spacefreezy
	name = "spacefreezy"
	desc = "The best ice cream in space."
	icon_state = "spacefreezy"
	list_reagents = list("nutriment" = 8, "vitamin" = 5, "bluecherryjelly" = 5)
	tastes = list("blue cherries" = 2, "ice cream" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

///////////////////
//	Snow Cones	//
//////////////////

/obj/item/food/frozen/snowcone
	name = "flavorless snowcone"
	desc = "It's just shaved ice. Still fun to chew on."
	trash = /obj/item/reagent_containers/drinks/sillycup
	list_reagents = list("water" = 10, "ice" = 5)
	tastes = list("cold water" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/frozen/snowcone/apple
	name = "apple snowcone"
	desc = "Apple syrup drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "applejuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "apples" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/berry
	name = "berry snowcone"
	desc = "Berry syrup drizzled over a snowball in a paper cup."
	icon_state = "berry_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "berryjuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "berries" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/bluecherry
	name = "bluecherry snowcone"
	desc = "Bluecherry syrup drizzled over a snowball in a paper cup, how rare!"
	icon_state = "blue_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "bluecherryjelly" = 5)
	tastes = list("ice" = 1, "water" = 1, "bluecherries" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/cherry
	name = "cherry snowcone"
	desc = "Cherry syrup drizzled over a snowball in a paper cup."
	icon_state = "red_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "cherryjelly" = 5)
	tastes = list("ice" = 1, "water" = 1, "cherries" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/fruitsalad
	name = "fruit salad snowcone"
	desc = "A delightful mix of citrus syrups drizzled over a snowball in a paper cup."
	icon_state = "fruitsalad_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "limejuice" = 5, "lemonjuice" = 5, "orangejuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "oranges" = 5, "lemons" = 5, "limes" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/grape
	name = "grape snowcone"
	desc = "Grape syrup drizzled over a snowball in a paper cup."
	icon_state = "grape_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "grapejuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "grapes" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/honey
	name = "honey snowcone"
	desc = "Honey drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "honey" = 5)
	tastes = list("ice" = 1, "water" = 1, "honey" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/lemon
	name = "lemon snowcone"
	desc = "Lemon syrup drizzled over a snowball in a paper cup."
	icon_state = "lemon_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "lemonjuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "lemons" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/lime
	name = "lime snowcone"
	desc = "Lime syrup drizzled over a snowball in a paper cup."
	icon_state = "lime_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "limejuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "limes" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/mime
	name = "mime snowcone"
	desc = "..."
	icon_state = "mime_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "nothing" = 5)
	tastes = list("ice" = 1, "water" = 1, "silence" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/orange
	name = "orange snowcone"
	desc = "Orange syrup drizzled over a snowball in a paper cup."
	icon_state = "orange_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "orangejuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "oranges" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/pineapple
	name = "pineapple snowcone"
	desc = "Pineapple syrup drizzled over a snowball in a paper cup."
	icon_state = "pineapple_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "pineapplejuice" = 5)
	tastes = list("ice" = 1, "water" = 1, "pineapple" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/rainbow
	name = "rainbow snowcone"
	desc = "A very colorful snowball in a paper cup."
	icon_state = "rainbow_sc"
	list_reagents = list("water" = 10, "ice" = 5, "colorful_reagent" = 5)
	tastes = list("ice" = 1, "water" = 1, "rainbows" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/cola
	name = "space cola snowcone"
	desc = "Space Cola drizzled over a snowball in a paper cup."
	icon_state = "soda_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "cola" = 5)
	tastes = list("ice" = 1, "water" = 1, "soda" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/snowcone/spacemountain
	name = "space mountain wind snowcone"
	desc = "Space Mountain Wind drizzled over a snowball in a paper cup."
	icon_state = "mountainwind_sc"
	list_reagents = list("water" = 10, "ice" = 5, "nutriment" = 1, "spacemountainwind" = 5)
	tastes = list("ice" = 1, "water" = 1, "mountain wind" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

///////////////////
//	Popsicles	//
/////////////////

/obj/item/food/frozen/popsicle
	name = "jumbo icecream"
	desc = "A luxurious ice cream covered in rich chocolate. It seems smaller than you remember it being."
	icon_state = "jumbo"
	trash = /obj/item/trash/popsicle_stick
	list_reagents = list("nutriment" = 4, "sugar" = 4, "chocolate" = 3)
	tastes = list("ice cream" = 1, "chocolate" = 1, "vanilla" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/frozen/popsicle/bananatop
	name = "banana topsicle"
	desc = "A frozen treat made from tofu and banana juice blended smooth, then frozen. Popular in rural Japan in the summer."
	icon_state = "topsicle_banana"
	list_reagents = list("vitamin" = 4, "sugar" = 6, "banana" = 4)
	tastes = list("bananas" = 1, "tofu" = 1)

/obj/item/food/frozen/popsicle/berrytop
	name = "berry topsicle"
	desc = "A frozen treat made from tofu and berry juice blended smooth, then frozen. Supposedly a favourite of bears, but that makes no sense..."
	icon_state = "topsicle_berry"
	list_reagents = list("vitamin" = 4, "sugar" = 6, "berryjuice" = 4)
	tastes = list("berries" = 1, "tofu" = 1)

/obj/item/food/frozen/popsicle/pineappletop
	name = "pineapple topsicle"
	desc = "A frozen treat made from tofu and pineapple juice blended smooth, then frozen. As seen on TV."
	icon_state = "topsicle_pineapple"
	list_reagents = list("vitamin" = 4, "sugar" = 6, "pineapplejuice" = 4)
	tastes = list("pineapples" = 1, "tofu" = 1)

/obj/item/food/frozen/popsicle/licoricecream
	name = "licorice creamsicle"
	desc = "A salty licorice ice cream. A salty frozen treat."
	icon_state = "licorice_creamsicle"
	list_reagents = list("nutriment" = 4, "cream" = 2, "vanilla" = 1, "sugar" = 4, "salt" = 1)
	tastes = list("salty licorice" = 1)

/obj/item/food/frozen/popsicle/orangecream
	name = "orange creamsicle"
	desc = "A classic orange creamsicle. A sunny frozen treat."
	icon_state = "creamsicle_o"
	list_reagents = list("orangejuice" = 4, "cream" = 2, "vanilla" = 2, "sugar" = 4)
	tastes = list("ice cream" = 1, "oranges" = 1, "vanilla" = 1)

/obj/item/food/frozen/popsicle/berrycream
	name = "berry creamsicle"
	desc = "A vibrant berry creamsicle. A berry good frozen treat."
	icon_state = "creamsicle_m"
	list_reagents = list("berryjuice" = 4, "cream" = 2, "vanilla" = 2, "sugar" = 4)
	tastes = list("ice cream" = 1, "berries" = 1, "vanilla" = 1)

/obj/item/food/frozen/popsicle/frozenpineapple
	name = "frozen pineapple pop"
	desc = "Few cultures love pineapple as much as the Martians, and this dessert proves that- frozen pineapple, on a stick, with just a little dunk of dark chocolate."
	icon_state = "pineapple_pop"
	list_reagents = list("pineapplejuice" = 4, "sugar" = 4, "nutriment" = 2, "vitamin" = 2)
	tastes = list("cold pineapple" = 1, "chocolate" = 1)

/obj/item/food/frozen/popsicle/sea_salt
	name = "sea salt ice-cream bar"
	desc = "This sky-blue ice-cream bar is flavoured with only the finest imported sea salt. Salty... no, sweet!"
	icon_state = "sea_salt_pop"
	list_reagents = list("salt" = 1, "nutriment" = 2, "cream" = 2, "vanilla" = 2, "sugar"= 4,)
	tastes = list("salt" = 1, "sweet" = 1)

/obj/item/food/frozen/popsicle/ant
	name = "ant popsicle"
	desc = "A colony of ants suspended in hardened sugar. Those things are dead, right?"
	icon_state = "ant_pop"
	list_reagents = list("nutriment" = 1, "vitamin" = 1, "sugar" = 5, "ants" = 3)
	tastes = list("candy" = 1, "ants" = 2)
