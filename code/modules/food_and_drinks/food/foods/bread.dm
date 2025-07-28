
//////////////////////
//		Breads		//
//////////////////////

/obj/item/food/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "meatbread"
	slice_path = /obj/item/food/sliced/meat_bread
	slices_num = 5
	filling_color = "#FF7575"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("bread" = 10, "meat" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/meat_bread
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "meatbreadslice"
	filling_color = "#FF7575"
	list_reagents = list("protein" = 4, "nutriment" = 2, "vitamin" = 1)
	tastes = list("bread" = 10, "meat" = 10)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "xenomeatbread"
	slice_path = /obj/item/food/sliced/xeno_meat_bread
	slices_num = 5
	filling_color = "#8AFF75"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)
	tastes = list("bread" = 10, "acid" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/xeno_meat_bread
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "xenobreadslice"
	filling_color = "#8AFF75"
	list_reagents = list("protein" = 4, "nutriment" = 2, "vitamin" = 1)
	tastes = list("bread" = 10, "acid" = 10)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/sliceable/spidermeatbread
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "spidermeatbread"
	slice_path = /obj/item/food/sliced/spider_meat_bread
	slices_num = 5
	list_reagents = list("protein" = 20, "nutriment" = 10, "toxin" = 15, "vitamin" = 5)
	tastes = list("bread" = 10, "cobwebs" = 5)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/spider_meat_bread
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "spidermeatslice"
	list_reagents = list("protein" = 4, "nutriment" = 2, "toxin" = 3, "vitamin" = 1)
	tastes = list("bread" = 10, "cobwebs" = 5)
	list_reagents = list("toxin" = 2)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/sliceable/bananabread
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bananabread"
	slice_path = /obj/item/food/sliced/banana_bread
	slices_num = 5
	filling_color = "#EDE5AD"
	list_reagents = list("banana" = 20, "nutriment" = 20)
	tastes = list("bread" = 10, "banana" = 5)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/banana_bread
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bananabreadslice"
	filling_color = "#EDE5AD"
	list_reagents = list("banana" = 4, "nutriment" = 4)
	tastes = list("bread" = 10, "banana" = 5)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/tofubread
	name = "tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "tofubread"
	slice_path = /obj/item/food/sliced/tofu_bread
	slices_num = 5
	filling_color = "#F7FFE0"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("bread" = 10, "tofu" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/tofu_bread
	name = "tofubread slice"
	desc = "A slice of delicious tofubread."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "tofubreadslice"
	filling_color = "#F7FFE0"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("bread" = 10, "tofu" = 10)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/bread
	name = "bread"
	desc = "Some plain old Earthen bread."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "bread"
	slice_path = /obj/item/food/sliced/bread
	slices_num = 6
	filling_color = "#FFE396"
	list_reagents = list("nutriment" = 10)
	tastes = list("bread" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/bread
	name = "bread slice"
	desc = "A slice of home."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "breadslice"
	filling_color = "#D27332"
	list_reagents = list("nutriment" = 2, "bread" = 5) // TODO Why bread?
	tastes = list("bread" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/creamcheesebread
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "creamcheesebread"
	slice_path = /obj/item/food/sliced/cream_cheese_bread
	slices_num = 5
	filling_color = "#FFF896"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("bread" = 10, "cheese" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/cream_cheese_bread
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "creamcheesebreadslice"
	filling_color = "#FFF896"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("bread" = 10, "cheese" = 10)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/banarnarbread
	name = "banarnarbread loaf"
	desc = "A loaf of delicious mah'weyh pleggh at e'ntrath!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "banarnarbread"
	slice_path = /obj/item/food/sliced/banarnarbread
	slices_num = 5
	filling_color = "#6F0000"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("heresy" = 10, "banana" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/banarnarbread
	name = "banarnarbread slice"
	desc = "A slice of delicious mah'weyh pleggh at e'ntrath!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "banarnarbreadslice"
	filling_color = "#6F0000"
	list_reagents = list("nutriment" = 4, "vitamin" = 1)
	tastes = list("heresy" = 10, "banana" = 10)
	goal_difficulty = FOOD_GOAL_EASY


//////////////////////
//		Misc		//
//////////////////////

/obj/item/food/bun
	name = "bun"
	desc = "The base for any self-respecting burger."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "bun"
	list_reagents = list("nutriment" = 1)
	tastes = list("bun" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flatbread"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bread" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "baguette"
	filling_color = "#E3D796"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bread" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/baguette/combat
	sharp = TRUE
	force = 20

/obj/item/food/baguette/combat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/food/twobread
	name = "two bread"
	desc = "It is very bitter and winy."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "twobread"
	filling_color = "#DBCC9A"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)
	tastes = list("bread" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/toast
	name = "toast"
	desc = "Yeah! Toast!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "toast"
	filling_color = "#B2580E"
	bitesize = 3
	list_reagents = list("nutriment" = 3)
	tastes = list("toast" = 1)
	goal_difficulty = FOOD_GOAL_EXCESSIVE

/obj/item/food/jelliedtoast
	name = "jellied toast"
	desc = "A slice of bread covered with delicious jam."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellytoast"
	filling_color = "#B572AB"
	bitesize = 3
	tastes = list("toast" = 1, "jelly" = 1)

/obj/item/food/jelliedtoast/cherry
	list_reagents = list("nutriment" = 1, "cherryjelly" = 5, "vitamin" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/jelliedtoast/slime
	list_reagents = list("nutriment" = 1, "slimejelly" = 5, "vitamin" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#FF00F7"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "psilocybin" = 2, "vitamin" = 2)
	tastes = list("waffle" = 1, "mushrooms" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon = 'icons/obj/food/breakfast.dmi'
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#E6DEB5"
	list_reagents = list("nutriment" = 8, "vitamin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL
