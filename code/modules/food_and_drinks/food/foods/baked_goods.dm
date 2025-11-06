#define DONUT_NORMAL	1
#define DONUT_FROSTED	2

//////////////////////
//		Cakes		//
//////////////////////

/obj/item/food/sliceable/carrotcake
	name = "carrot cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "carrotcake"
	slice_path = /obj/item/food/sliced/carrot_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#FFD675"
	list_reagents = list("nutriment" = 20, "oculine" = 10, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/carrot_cake
	name = "carrot cake slice"
	desc = "Carrotty slice of Carrot Cake. Carrots are good for your eyes! Also not a lie."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	list_reagents = list("nutriment" = 4, "oculine" = 2, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)
	goal_difficulty = FOOD_GOAL_EASY


/obj/item/food/sliceable/braincake
	name = "brain cake"
	desc = "A squishy cake-thing."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "braincake"
	slice_path = /obj/item/food/sliced/brain_cake
	slices_num = 5
	filling_color = "#E6AEDB"
	bitesize = 3
	list_reagents = list("protein" = 10, "nutriment" = 10, "mannitol" = 10, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/brain_cake
	name = "brain cake slice"
	desc = "Lemme tell you something about brains. THEY'RE DELICIOUS."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#E6AEDB"
	list_reagents = list("protein" = 2, "nutriment" = 2, "mannitol" = 2, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/cheesecake
	name = "cheese cake"
	desc = "DANGEROUSLY cheesy."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "cheesecake"
	slice_path = /obj/item/food/sliced/cheese_cake
	slices_num = 5
	filling_color = "#FAF7AF"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 4, "cream cheese" = 3)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/cheese_cake
	name = "cheese cake slice"
	desc = "Slice of pure cheestisfaction."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 4, "cream cheese" = 3)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/plaincake
	name = "plain cake"
	desc = "A plain cake, not a lie."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "plaincake"
	slice_path = /obj/item/food/sliced/plain_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#F7EDD5"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "vanilla" = 1, "sweetness" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/plain_cake
	name = "plain cake slice"
	desc = "Just a slice of cake. It's enough for everyone."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "vanilla" = 1, "sweetness" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/orangecake
	name = "orange cake"
	desc = "A cake with added orange."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "orangecake"
	slice_path = /obj/item/food/sliced/orange_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/orange_cake
	name = "orange cake slice"
	desc = "Just a slice of cake. It's enough for everyone."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/bananacake
	name = "banana cake"
	desc = "A cake with added bananas."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "bananacake"
	slice_path = /obj/item/food/sliced/banana_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "banana" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/banana_cake
	name = "banana cake slice"
	desc = "Just a slice of cake. It's enough for everyone."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "bananacake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "banana" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/limecake
	name = "lime cake"
	desc = "A cake with added lime."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "limecake"
	bitesize = 3
	slice_path = /obj/item/food/sliced/lime_cake
	slices_num = 5
	filling_color = "#CBFA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/lime_cake
	name = "lime cake slice"
	desc = "Just a slice of cake. It's enough for everyone."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#CBFA8E"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/lemoncake
	name = "lemon cake"
	desc = "A cake with added lemon."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "lemoncake"
	slice_path = /obj/item/food/sliced/lemon_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#FAFA8E"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/lemon_cake
	name = "lemon cake slice"
	desc = "Just a slice of cake. It's enough for everyone."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAFA8E"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/chocolatecake
	name = "chocolate cake"
	desc = "A cake with added chocolate."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "chocolatecake"
	slice_path = /obj/item/food/sliced/chocolate_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#805930"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/chocolate_cake
	name = "chocolate cake slice"
	desc = "Just a slice of cake. It's enough for everyone."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/birthdaycake
	name = "birthday cake"
	desc = "Happy Birthday..."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "birthdaycake"
	slice_path = /obj/item/food/sliced/birthday_cake
	slices_num = 5
	filling_color = "#FFD6D6"
	bitesize = 3
	list_reagents = list("nutriment" = 20, "sprinkles" = 10, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/birthday_cake
	name = "birthday cake slice"
	desc = "A slice of your birthday!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/applecake
	name = "apple cake"
	desc = "A cake centered with Apple."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "applecake"
	slice_path = /obj/item/food/sliced/apple_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#EBF5B8"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/apple_cake
	name = "apple cake slice"
	desc = "A slice of heavenly cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#EBF5B8"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/holy_cake
	name = "angel food cake"
	desc = "A cake made for angels and chaplains alike! Contains holy water."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "holy_cake"
	slice_path = /obj/item/food/sliced/holy_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 5, "vitamin" = 5, "holywater" = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/holy_cake
	name = "holy cake slice"
	desc = "A slice of heavenly cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "holy_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 1, "vitamin" = 1, "holywater" = 2)
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/liars_cake
	name = "strawberry chocolate cake"
	desc = "A chocolate cake with five strawberries on top. For some reason, this configuration of cake is particularly aesthetically pleasing to AIs in SELF."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "liars_cake"
	slice_path = /obj/item/food/sliced/liars
	slices_num = 5
	bitesize = 3
	filling_color = "#240606c7"
	list_reagents = list("nutriment" = 20, "vitamin" = 5, "cocoa" = 5)
	tastes = list("blackberry" = 2, "strawberries" = 2, "chocolate" = 2, "sweetness" = 2, "cake" = 3)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/liars
	name = "strawberry chocolate cake slice"
	desc = "Just a slice of cake with five strawberries on top. \
		For some reason, this configuration of cake is particularly aesthetically pleasing to AIs in SELF."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "liars_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "cocoa" = 1)
	tastes = list("strawberries" = 2, "chocolate" = 2, "sweetness" = 2, "cake" = 3)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/vanilla_berry_cake
	name = "blackberry and strawberry vanilla cake"
	desc = "A plain cake, filled with assortment of blackberries and strawberries!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "vanilla_berry_cake"
	slice_path = /obj/item/food/sliced/vanilla_berry_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#f0e3e3c7"
	list_reagents = list("nutriment" = 20, "vitamin" = 5, "vanilla" = 5)
	tastes = list("blackberry" = 2, "strawberries" = 2, "vanilla" = 2, "sweetness" = 2, "cake" = 3)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/vanilla_berry_cake
	name = "blackberry and strawberry vanilla cake slice"
	desc = "Just a slice of cake filled with assortment of blackberries and strawberries!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "vanilla_berry_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "vanilla" = 1)
	tastes = list("blackberry" = 2, "strawberries" = 2, "vanilla" = 2, "sweetness" = 2, "cake" = 3)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/hardware_cake
	name = "hardware cake"
	desc = "A \"cake\" that is made with electronic boards and leaks acid..."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "hardware_cake"
	slice_path = /obj/item/food/sliced/hardware_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#4ac25e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5, "sacid" = 15, "oil" = 15)
	tastes = list("acid" = 3, "metal" = 4, "glass" = 5)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/hardware_cake
	name = "hardware cake slice"
	desc = "A slice of electronic boards and some acid."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "hardware_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#4ac25e"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "sacid" = 3, "oil" = 3)
	tastes = list("acid" = 3, "metal" = 4, "glass" = 5)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/plum_cake
	name = "plum cake"
	desc = "A cake centred with Plums."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "plum_cake"
	slice_path = /obj/item/food/sliced/plum_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#a128c5"
	list_reagents = list("nutriment" = 20, "vitamin" = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "plum" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/plum_cake
	name = "plum cake slice"
	desc = "A slice of plum cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "plum_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#a128c5"
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("cake" = 5, "sweetness" = 1, "plum" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/pound_cake
	name = "pound cake"
	desc = "A condensed cake made for filling people up quickly."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pound_cake"
	slice_path = /obj/item/food/sliced/pound_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#c4cab7"
	list_reagents = list("nutriment" = 60, "vitamin" = 20)
	tastes = list("cake" = 5, "sweetness" = 5, "batter" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/pound_cake
	name = "pound cake slice"
	desc = "A slice of condensed cake made for filling people up quickly."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pound_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 12, "vitamin" = 4)
	tastes = list("cake" = 5, "sweetness" = 5, "batter" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/pumpkin_spice_cake
	name = "pumpkin spice cake"
	desc = "A hollow cake with real pumpkin."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pumpkin_spice_cake"
	slice_path = /obj/item/food/sliced/pumpkin_spice_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#ee710a"
	list_reagents = list("nutriment" = 20, "vitamin" = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "pumpkin" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/pumpkin_spice_cake
	name = "pumpkin spice cake slice"
	desc = "A spicy slice of pumpkin goodness."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pumpkin_spice_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ee710a"
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("cake" = 5, "sweetness" = 1, "pumpkin" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/slime_cake
	name = "slime cake"
	desc = "A cake made of slimes. Probably not electrified."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "slime_cake"
	slice_path = /obj/item/food/sliced/slime_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#0adfee"
	list_reagents = list("nutriment" = 20, "vitamin" = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/slime_cake
	name = "slime cake slice"
	desc = "A slice of slime cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "slime_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#0adfee"
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/spaceman_cake
	name = "spaceman's cake"
	desc = "A spaceman's trumpet frosted cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "trumpet_cake"
	slice_path = /obj/item/food/sliced/spaceman_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#610977"
	list_reagents = list("nutriment" = 20, "vitamin" = 10, "cream" = 5, "berryjuice" = 5)
	tastes = list("cake" = 4, "violets" = 2, "jam" = 2)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/spaceman_cake
	name = "spaceman's cake slice"
	desc = "A slice of spaceman's trumpet frosted cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "trumpet_cake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#610977"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "cream" = 1, "berryjuice" = 1)
	tastes = list("cake" = 4, "violets" = 2, "jam" = 2)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/vanilla_cake
	name = "vanilla cake"
	desc = "A vanilla frosted cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "vanilla_cake"
	slice_path = /obj/item/food/sliced/vanilla_cake
	slices_num = 5
	bitesize = 3
	filling_color = "#ece7ee"
	list_reagents = list("nutriment" = 20, "vitamin" = 5, "sugar" = 15, "vanilla" = 15)
	tastes = list("cake" = 1, "sugar" = 1, "vanilla" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/vanilla_cake
	name = "vanilla cake slice"
	desc = "A slice of vanilla frosted cake."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "vanilla_cake_slice"
	filling_color = "#ece7ee"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "sugar" = 3, "vanilla" = 3)
	tastes = list("cake" = 1, "sugar" = 1, "vanilla" = 10)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/mothmallow
	name = "mothmallow tray"
	desc = "A light and fluffy vegan marshmallow flavoured with vanilla and rum and topped with soft chocolate. These are known to the moths as höllflöfstarkken: cloud squares." //höllflöf = cloud (höll = wind, flöf = cotton), starkken = squares
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "mothmallow_tray"
	slice_path = /obj/item/food/sliced/mothmallow
	slices_num = 5
	bitesize = 3
	filling_color = "#eebe98"
	list_reagents = list("nutriment" = 20, "sugar" = 20)
	tastes = list("vanilla" = 1, "clouds" = 1, "chocolate" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/mothmallow
	name = "mothmallow"
	desc = "Fluffy little clouds of joy- in a strangely moth-like colour."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "mothmallow_slice"
	filling_color = "#ece7ee"
	filling_color = "#eebe98"
	list_reagents = list("nutriment" = 4, "sugar" = 4)
	tastes = list("vanilla" = 1, "clouds" = 1, "chocolate" = 1)
	goal_difficulty = FOOD_GOAL_EASY


//////////////////////
//		Cookies		//
//////////////////////

/obj/item/food/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "COOKIE!!!"
	bitesize = 1
	filling_color = "#DBC94F"
	list_reagents = list("nutriment" = 1, "sugar" = 3, "hot_coco" = 5 )
	tastes = list("cookie" = 1, "crunchy chocolate" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "fortune_cookie"
	filling_color = "#E8E79E"
	list_reagents = list("nutriment" = 3)
	trash = /obj/item/paper/fortune
	tastes = list("cookie" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "sugarcookie"
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	tastes = list("sweetness" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/oatmeal_cookie
	name = "oatmeal cookie"
	desc = "The best of both cookie and oat."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "oatmeal_cookie"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("cookie" = 2, "oat" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/raisin_cookie
	name = "raisin cookie"
	desc = "Why would you put raisins on a cookie?"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "raisin_cookie"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("cookie" = 1, "raisins" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/peanut_butter_cookie
	name = "peanut butter cookie"
	desc = "A tasty, chewy peanut butter cookie."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "peanut_butter_cookie"
	list_reagents = list("nutriment" = 6, "peanutbutter" = 5)
	tastes = list("cookie" = 1, "peanut butter" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

//////////////////////
//		Pies		//
//////////////////////

/obj/item/food/pie
	name = "banana cream pie"
	desc = "One of the five essential food groups of clowns."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#FBFFB8"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "banana" = 5, "vitamin" = 2)
	tastes = list("pie" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message("<span class='warning'>[src] splats.</span>","<span class='warning'>You hear a splat.</span>")
	qdel(src)

/obj/item/food/meatpie
	name = "meat-pie"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "meat" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/tofupie
	name = "tofu-pie"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "tofu" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "amanita_pie"
	filling_color = "#FFCCCC"
	bitesize = 4
	list_reagents = list("nutriment" = 6, "amanitin" = 3, "psilocybin" = 1, "vitamin" = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "mushroom" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/plump_pie/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!" // What
		reagents.add_reagent("omnizine", 5)

/obj/item/food/xemeatpie
	name = "xeno-pie"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43DE18"
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE


/obj/item/food/applepie
	name = "apple pie"
	desc = "A pie containing sweet, sweet love... or apple."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "applepie"
	filling_color = "#E0EDC5"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "apple" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/cherrypie
	name = "cherry pie"
	desc = "Taste so good, make a grown man cry."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "cherrypie"
	filling_color = "#FF525A"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("pie" = 1, "cherries" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/pumpkinpie
	name = "pumpkin pie"
	desc = "A delicious treat for the autumn months."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pumpkinpie"
	slice_path = /obj/item/food/sliced/pumpkinpie
	slices_num = 5
	bitesize = 3
	filling_color = "#F5B951"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("pie" = 1, "pumpkin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliced/pumpkinpie
	name = "pumpkin pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#F5B951"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("pie" = 1, "pumpkin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/beary_pie
	name = "beary pie"
	desc = "No brown bears, this is a good sign."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "beary_pie"
	filling_color = "#F5B951"
	list_reagents = list("nutriment" = 12, "vitamin" = 5, "protein" = 5)
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/blumpkin_pie
	name = "blumpkin pie"
	desc = "An odd blue pie made with toxic blumpkin."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "blumpkin_pie"
	slice_path = /obj/item/food/sliced/blumpkin_pie
	slices_num = 5
	bitesize = 3
	filling_color = "#102d8b"
	list_reagents = list("nutriment" = 20, "vitamin" = 5, "blumpkinjuice" = 5)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliced/blumpkin_pie
	name = "blumpkin pie slice"
	desc = "A slice of blumpkin pie, with whipped cream on top. Is this edible?"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "blumpkin_pie_slice"
	trash = /obj/item/trash/plate
	filling_color = "#102d8b"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "blumpkinjuice" = 1)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/french_silk_pie
	name = "french silk pie"
	desc = "A decadent pie made of a creamy chocolate mousse filling topped with a layer of whipped cream and chocolate shavings. Sliceable."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "french_silk_pie"
	slice_path = /obj/item/food/sliced/french_silk_pie
	slices_num = 5
	bitesize = 3
	filling_color = "#5e4337"
	list_reagents = list("nutriment" = 15, "vitamin" = 5)
	tastes = list("pie" = 1, "smooth chocolate" = 1, "whipped cream" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliced/french_silk_pie
	name = "french silk pie slice"
	desc = "A slice of french silk pie, filled with a chocolate mousse and topped with a layer of whipped cream and chocolate shavings. Delicious enough to make you cry."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "french_silk_pie_slice"
	trash = /obj/item/trash/plate
	filling_color = "#5e4337"
	list_reagents = list("nutriment" = 3, "vitamin" = 1)
	tastes = list("pie" = 1, "smooth chocolate" = 1, "whipped cream" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/frosty_pie
	name = "frosty pie"
	desc = "Tastes like blue and cold."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "frosty_pie"
	slice_path = /obj/item/food/sliced/frosty_pie
	slices_num = 5
	bitesize = 3
	filling_color = "#5e4337"
	list_reagents = list("nutriment" = 15, "vitamin" = 5)
	tastes = list("mint" = 1, "pie" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliced/frosty_pie
	name = "frosty pie slice"
	desc = "Tasty blue, like my favourite crayon!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "frosty_pie_slice"
	trash = /obj/item/trash/plate
	filling_color = "#338cb6"
	list_reagents = list("nutriment" = 3, "vitamin" = 1)
	tastes = list("mint" = 1, "pie" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

//////////////////////
//		Donuts		//
//////////////////////

/obj/item/food/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "donut1"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	var/extra_reagent = null
	filling_color = "#D2691E"
	var/randomized_sprinkles = TRUE
	var/donut_sprite_type = DONUT_NORMAL
	tastes = list("donut" = 1)

/obj/item/food/donut/Initialize(mapload)
	. = ..()
	if(randomized_sprinkles && prob(30))
		icon_state = "donut2"
		name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)
		donut_sprite_type = DONUT_FROSTED
		filling_color = "#FF69B4"

/obj/item/food/donut/sprinkles
	name = "frosted donut"
	icon_state = "donut2"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "sprinkles" = 2)
	filling_color = "#FF69B4"
	donut_sprite_type = DONUT_FROSTED
	randomized_sprinkles = FALSE

/obj/item/food/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."
	bitesize = 10
	tastes = list("donut" = 3, "chaos" = 1)
	goal_difficulty = FOOD_GOAL_HARD

/obj/item/food/donut/chaos/Initialize(mapload)
	. = ..()
	extra_reagent = pick("nutriment", "capsaicin", "frostoil", "krokodil", "plasma", "cocoa", "slimejelly", "banana", "berryjuice", "omnizine")
	reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		icon_state = "donut2"
		name = "frosted chaos donut"
		reagents.add_reagent("sprinkles", 2)
		filling_color = "#FF69B4"

/obj/item/food/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	extra_reagent = "berryjuice"
	tastes = list("jelly" = 1, "donut" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/donut/jelly/Initialize(mapload)
	. = ..()
	if(extra_reagent)
		reagents.add_reagent("[extra_reagent]", 3)
	if(prob(30))
		icon_state = "jdonut2"
		name = "frosted jelly Donut"
		donut_sprite_type = DONUT_FROSTED
		reagents.add_reagent("sprinkles", 2)
		filling_color = "#FF69B4"

/obj/item/food/donut/jelly/slimejelly
	name = "slime jelly donut"
	extra_reagent = "slimejelly"
	goal_difficulty = FOOD_GOAL_HARD

/obj/item/food/donut/jelly/cherryjelly
	name = "cherry jelly donut"
	extra_reagent = "cherryjelly"

/obj/item/food/donut/apple
	name = "apple donut"
	desc = "Goes great with a shot of cinnamon schnapps."
	icon_state = "donut_green"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "applejuice" = 2)
	filling_color = "#24d21e"
	tastes = list("donut" = 1, "apples" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/apple/jelly
	name = "jelly apple donut"
	icon_state = "jelly_green"
	extra_reagent = "berryjuice"

/obj/item/food/donut/apple/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/apple/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/pink
	name = "jelly pink donut"
	desc = "Goes great with a soy latte."
	icon_state = "donut_pink"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "berryjuice" = 3)
	tastes = list("donut" = 1, "berries" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/pink/jelly
	icon_state = "jelly_pink"
	extra_reagent = "berryjuice"

/obj/item/food/donut/pink/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/pink/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/blumpkin
	name = "blumpkin donut"
	desc = "Goes great with a mug of soothing drunken blumpkin."
	icon_state = "donut_blue"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "blumpkinjuice" = 2)
	tastes = list("donut" = 1, "blumpkin" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/blumpkin/jelly
	name = "jelly blumpkin donut"
	icon_state = "jelly_blue"
	extra_reagent = "berryjuice"

/obj/item/food/donut/blumpkin/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/blumpkin/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/caramel
	name = "caramel donut"
	desc = "Goes great with a mug of hot cocoa."
	icon_state = "donut_beige"
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	tastes = list("donut" = 1, "buttery sweetness" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/caramel/jelly
	name = "jelly caramel donut"
	icon_state = "jelly_beige"
	extra_reagent = "berryjuice"

/obj/item/food/donut/caramel/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/caramel/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/chocolate
	name = "chocolate donut"
	desc = "Goes great with a glass of warm milk."
	icon_state = "donut_choc"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "hot_coco" = 3)
	tastes = list("donut" = 1, "bitterness" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/chocolate/jelly
	name = "jelly chocolate donut"
	icon_state = "jelly_choc"
	extra_reagent = "berryjuice"

/obj/item/food/donut/chocolate/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/chocolate/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/matcha
	name = "matcha donut"
	desc = "Goes great with a cup of tea."
	icon_state = "donut_olive"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "teapowder" = 2)
	tastes = list("donut" = 1, "matcha" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/matcha/jelly
	name = "jelly matcha donut"
	icon_state = "jelly_olive"
	extra_reagent = "berryjuice"

/obj/item/food/donut/matcha/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/matcha/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/bungo
	name = "bungo donut"
	desc = "Goes great with a mason jar of hippie's delight."
	icon_state = "donut_yellow"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "bungojuice" = 3)
	tastes = list("donut" = 1, "tropical sweetness" = 1, "an acidic, poisonous tang" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/bungo/jelly
	name = "jelly bungo donut"
	icon_state = "jelly_yellow"
	extra_reagent = "berryjuice"

/obj/item/food/donut/bungo/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/bungo/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/spaceman
	name = "spaceman's donut"
	desc = "Goes great with a cold beaker of malk."
	icon_state = "donut_purple"
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	tastes = list("donut" = 1, "violets" = 1)
	randomized_sprinkles = FALSE

/obj/item/food/donut/spaceman/jelly
	name = "jelly spaceman's donut"
	icon_state = "jelly_purple"
	extra_reagent = "berryjuice"

/obj/item/food/donut/spaceman/jelly/cherry
	extra_reagent = "cherryjelly"

/obj/item/food/donut/spaceman/jelly/slime
	extra_reagent = "slimejelly"

/obj/item/food/donut/meat
	name = "Meat Donut"
	desc = "Tastes as gross as it looks."
	icon_state = "donut_meat"
	list_reagents = list("nutriment" = 3, "protein" = 3, "ketchup" = 3)
	tastes = list("meat" = 1, "ketchup" = 1)
	randomized_sprinkles = FALSE


//////////////////////
//		Pancakes	//
//////////////////////

/obj/item/food/pancake
	name = "pancake"
	desc = "A plain pancake."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "pancake"
	filling_color = "#E7D8AB"
	list_reagents = list("nutriment" = 3, "sugar" = 3)
	tastes = list("sweet cake" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/pancake/attack_tk(mob/user)
	if(src in user.tkgrabbed_objects)
		to_chat(user, "<span class='notice'>You start channeling psychic energy into [src].</span>")
		visible_message("<span class='danger'>The syrup on [src] starts to boil...</span>")
		if(do_after_once(user, 4 SECONDS, target = src))
			visible_message("<span class='danger'>[src] suddenly combust!</span>")
			to_chat(user, "<span class='warning'>You combust [src] with your mind!</span>")
			explosion(get_turf(src), light_impact_range = 2, flash_range = 2, cause = "[user.ckey]: blows up pancakes with mind")
			add_attack_logs(user, src, "blew up [src] with TK", ATKLOG_ALL)
			qdel(src)
			return
		to_chat(user, "<span class='notice'>You decide against the destruction of [src].</span>")
		return
	return ..()

/obj/item/food/pancake/berry_pancake
	name = "berry pancake"
	desc = "A pancake loaded with berries."
	icon_state = "berry_pancake"
	list_reagents = list("nutriment" = 3, "sugar" = 3, "berryjuice" = 3)
	tastes = list("sweet cake" = 2, "berries" = 2)

/obj/item/food/pancake/choc_chip_pancake
	name = "choc-chip pancake"
	desc = "A pancake loaded with chocolate chips."
	icon_state = "choc_chip_pancake"
	list_reagents = list("nutriment" = 3, "sugar" = 3, "cocoa" = 3)
	tastes = list("sweet cake" = 2, "chocolate" = 3)

//////////////////////
//		Misc		//
//////////////////////

/obj/item/food/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "muffin"
	filling_color = "#E0CF9B"
	list_reagents = list("nutriment" = 6)
	tastes = list("muffin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/berry_muffin
	name = "berry muffin"
	desc = "A delicious and spongy little cake, with berries."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "berry_muffin"
	filling_color = "#ad2bbe"
	list_reagents = list("nutriment" = 6, "berryjuice" = 2)
	tastes = list("muffin" = 3, "berry" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/booberry_muffin
	name = "booberry muffin"
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"
	icon = 'icons/obj/food/breakfast.dmi'
	alpha = 125
	icon_state = "berry_muffin"
	filling_color = "#d9b6f5"
	list_reagents = list("nutriment" = 6)
	tastes = list("muffin" = 3, "spookiness" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/moffin
	name = "moffin"
	desc = "A delicious and spongy little cake."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "moffin"
	filling_color = "#c7ab56"
	list_reagents = list("nutriment" = 6)
	tastes = list("muffin" = 3, "dust" = 1, "lint" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/berryclafoutis
	name = "berry clafoutis"
	desc = "No black birds, this is a good sign."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 10, "berryjuice" = 5, "vitamin" = 2)
	tastes = list("pie" = 1, "blackberries" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/poppypretzel
	name = "poppy pretzel"
	desc = "A large soft pretzel full of POP! It's all twisted up!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "poppypretzel"
	filling_color = "#916E36"
	list_reagents = list("nutriment" = 5)
	tastes = list("pretzel" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "phelmbiscuit"
	filling_color = "#CFB4C4"
	list_reagents = list("nutriment" = 5)
	tastes = list("mushroom" = 1, "biscuit" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/plumphelmetbiscuit/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!" // Is this a reference?
		reagents.add_reagent("omnizine", 5)

/obj/item/food/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#FFFF00"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "gold" = 5, "vitamin" = 4)
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/grape_tart
	name = "grape tart"
	desc = "A tasty dessert that reminds you of the wine you didn't make."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "grapetart"
	trash = /obj/item/trash/plate
	filling_color = "#8c00ff"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "vitamin" = 4)
	tastes = list("pie" = 1, "grape" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/mime_tart
	name = "mime tart"
	desc = "..."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "mime_tart"
	trash = /obj/item/trash/plate
	filling_color = "#8c00ff"
	bitesize = 3
	list_reagents = list("nutriment" = 5, "vitamin" = 5, "nothing" = 5)
	tastes = list("nothing" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cherry_cupcake
	name = "cherry cupcake"
	desc = "A sweet cupcake with cherry bits."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "cherry_cupcake"
	filling_color = "#8b1236"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("cake" = 3, "cherry" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cherry_cupcake/blue
	name = "blue cherry cupcake"
	desc = "Blue cherries inside a delicious cupcake."
	icon_state = "bluecherry_cupcake"
	filling_color = "#0d1694"
	tastes = list("cake" = 3, "bluecherry" = 1)

/obj/item/food/honey_bun
	name = "honey bun"
	desc = "A sticky pastry bun glazed with honey."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "honey_bun"
	filling_color = "#d88e06"
	list_reagents = list("nutriment" = 6, "honey" = 6)
	tastes = list("pastry" = 1, "sweetness" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cannoli
	name = "cannoli"
	desc = "A Sicilian treat that turns you into a wise guy."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "cannoli"
	filling_color = "#d88e06"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("pastry" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/chocolate_lava_tart
	name = "chocolate lava tart"
	desc = "A tasty dessert made of chocolate, with a liquid core."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "coco_lava_tart"
	filling_color = "#411b02"
	list_reagents = list("nutriment" = 4, "vitamin" = 4)
	tastes = list("pie" = 1, "dark chocolate" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/chocolate_cornet
	name = "chocolate cornet"
	desc = "Which side's the head, the fat end or the thin end?"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "choco_cornet"
	filling_color = "#411b02"
	list_reagents = list("nutriment" = 6, "vitamin" = 2)
	tastes = list("biscuit" = 3, "chocolate" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/dulce_de_batata
	name = "dulce de batata"
	desc = "A delicious jelly made with sweet potatoes."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "dulce_de_batata"
	slice_path = /obj/item/food/sliced/dulce_de_batata
	slices_num = 5
	bitesize = 3
	filling_color = "#411b02"
	list_reagents = list("nutriment" = 15, "vitamin" = 10)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliced/dulce_de_batata
	name = "dulce de batata slice"
	desc = "Tasty blue, like my favourite crayon!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "dulce_de_batata_slice"
	trash = /obj/item/trash/plate
	filling_color = "#411b02"
	list_reagents = list("nutriment" = 3, "vitamin" = 2)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cheese_balls
	name = "\improper ælorölen" //ælo = cheese, rölen = balls
	desc = "Ælorölen (cheese balls) are a traditional mothic dessert, made of soft cheese, powdered sugar and flour, rolled into balls, battered and then deep fried. They're often served with either chocolate sauce or honey, or sometimes both!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "moth_cheese_cakes"
	filling_color = "#411b02"
	list_reagents = list("protein" = 8, "sugar" = 12)
	tastes = list("cheesecake" = 1, "chocolate" = 1, "honey" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "cracker"
	bitesize = 1
	filling_color = "#F5DEB8"
	list_reagents = list("nutriment" = 1)
	tastes = list("cracker" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/croissant
	name = "croissant"
	desc = "Once a pastry reserved for the bourgeois, this flaky goodness is now on your table."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "croissant"
	bitesize = 4
	filling_color = "#ecb54f"
	list_reagents = list("nutriment" = 4, "sugar" = 2)
	tastes = list("croissant" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/croissant/throwing
	throwforce = 20
	throw_range = 9 //now with extra throwing action
	tastes = list("croissant" = 2, "butter" = 1, "metal" = 1)
	list_reagents = list("nutriment" = 4, "sugar" = 2, "iron" = 1)

/obj/item/food/croissant/throwing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boomerang, throw_range, TRUE)

#undef DONUT_NORMAL
#undef DONUT_FROSTED
