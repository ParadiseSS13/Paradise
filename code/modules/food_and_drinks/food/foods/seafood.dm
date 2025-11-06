
/obj/item/food/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "carpfillet" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "carpotoxin" = 2, "vitamin" = 2)
	tastes = list("white fish" = 1)
	ingredient_name = "fillet of meat"
	ingredient_name_plural = "fillets of meat"

/obj/item/food/salmonmeat
	name = "raw salmon"
	desc = "A fillet of raw salmon."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "salmonfillet" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 2)
	tastes = list("raw salmon" = 1)

/obj/item/food/salmonsteak
	name = "salmon steak"
	desc = "A fillet of freshly-grilled salmon meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "salmonsteak" // Sprite based on one created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "vitamin" = 2)
	tastes = list("cooked salmon" = 1)

/obj/item/food/catfishmeat
	name = "raw catfish"
	desc = "A fillet of raw catfish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "catfishfillet" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 2)
	tastes = list("catfish" = 1)

/obj/item/food/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	bitesize = 1
	list_reagents = list("nutriment" = 4)
	tastes = list("fish" = 1, "bread" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/fishburger
	name = "Fillet-O-Carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishburger"
	filling_color = "#FFDEFE"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4, "fish" = 4)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/cubancarp
	name = "cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "capsaicin" = 1)
	tastes = list("fish" = 4, "batter" = 1, "hot peppers" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/fishandchips
	name = "fish and chips"
	desc = "I do say so myself old chap. Indubitably!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishandchips"
	filling_color = "#E3D796"
	bitesize = 3
	list_reagents = list("nutriment" = 6)
	tastes = list("fish" = 1, "chips" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalizing yourself."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sashimi"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "capsaicin" = 5)
	tastes = list("raw carp" = 1, "hot peppers" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/fried_shrimp
	name = "fried shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_fried"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("shrimp" = 1, "bread crumbs" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/boiled_shrimp
	name = "boiled shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_cooked"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("shrimp" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/shrimp_skewer
	name = "shrimp skewer"
	desc = "Four shrimp lightly grilled on a skewer. Yummy!"
	trash = /obj/item/stack/rods
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimpskewer"
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("shrimp" = 4)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/fish_skewer
	name = "fish skewer"
	desc = "A whole fish battered and grilled on a skewer. Hope you're hungry!"
	trash = /obj/item/stack/rods
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishskewer"
	bitesize = 3
	list_reagents = list("protein" = 6, "vitamin" = 4)
	tastes = list("shrimp" = 1, "batter" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/sliceable/ebi_maki
	name = "ebi maki roll"
	desc = "A large unsliced roll of Ebi Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Ebi_maki"
	slice_path = /obj/item/food/sliced/sushi_ebi
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("shrimp" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_ebi
	name = "ebi sushi"
	desc = "A simple sushi consisting of cooked shrimp and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ebi"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("shrimp" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/ikura_maki
	name = "ikura maki roll"
	desc = "A large unsliced roll of Ikura Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Ikura_maki"
	slice_path = /obj/item/food/sliced/sushi_ikura
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("salmon roe" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_ikura
	name = "ikura sushi"
	desc = "A simple sushi consisting of salmon roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ikura"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("salmon roe" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/sake_maki
	name = "sake maki roll"
	desc = "A large unsliced roll of Sake Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Sake_maki"
	slice_path = /obj/item/food/sliced/sushi_sake
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("raw salmon" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_sake
	name = "sake sushi"
	desc = "A simple sushi consisting of raw salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Sake"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("raw salmon" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/smoked_salmon_maki
	name = "smoked salmon maki roll"
	desc = "A large unsliced roll of Smoked Salmon Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "SmokedSalmon_maki"
	slice_path = /obj/item/food/sliced/sushi_smoked_salmon
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("smoked salmon" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_smoked_salmon
	name = "smoked salmon sushi"
	desc = "A simple sushi consisting of cooked salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("smoked salmon" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/tamago_maki
	name = "tamago maki roll"
	desc = "A large unsliced roll of Tamago Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tamago_maki"
	slice_path = /obj/item/food/sliced/sushi_tamago
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("egg" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_tamago
	name = "tamago sushi"
	desc = "A simple sushi consisting of egg and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tamago"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("egg" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/inari_maki
	name = "inari maki roll"
	desc = "A large unsliced roll of Inari Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Inari_maki"
	slice_path = /obj/item/food/sliced/sushi_inari
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("fried tofu" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_inari
	name = "inari sushi"
	desc = "A piece of fried tofu stuffed with rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Inari"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("fried tofu" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/masago_maki
	name = "masago maki roll"
	desc = "A large unsliced roll of Masago Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Masago_maki"
	slice_path = /obj/item/food/sliced/sushi_masago
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("goldfish roe" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_masago
	name = "masago sushi"
	desc = "A simple sushi consisting of goldfish roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("goldfish roe" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/tobiko_maki
	name = "tobiko maki roll"
	desc = "A large unsliced roll of Tobkio Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tobiko_maki"
	slice_path = /obj/item/food/sliced/sushi_tobiko
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("shark roe" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_tobiko
	name = "tobiko sushi"
	desc = "A simple sushi consisting of shark roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("shark roe" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/tobiko_egg_maki
	name = "tobiko and egg maki roll"
	desc = "A large unsliced roll of Tobkio and Egg Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "TobikoEgg_maki"
	slice_path = /obj/item/food/sliced/sushi_tobiko_egg
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)
	tastes = list("shark roe" = 1, "rice" = 1, "egg" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_tobiko_egg
	name = "tobiko and egg sushi"
	desc = "A sushi consisting of shark roe and an egg."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_TobikoEgg"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)
	tastes = list("shark roe" = 1, "rice" = 1, "egg" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sliceable/tai_maki
	name = "tai maki roll"
	desc = "A large unsliced roll of Tai Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tai_maki"
	slice_path = /obj/item/food/sliced/sushi_tai
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)
	tastes = list("catfish" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/sliced/sushi_tai
	name = "tai sushi"
	desc = "A simple sushi consisting of catfish and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tai"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("catfish" = 1, "rice" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_EASY

/obj/item/food/sushi_unagi
	name = "unagi sushi"
	desc = "A simple sushi consisting of eel and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Hokki"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
	tastes = list("grilled eel" = 1, "seaweed" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/caviar
	name = "\improper Three-Star caviar"
	desc = "A small, pretentious looking can of fish eggs."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "caviar"
	bitesize = 1
	trash = /obj/item/trash/caviar
	list_reagents = list("protein" = 5)
	tastes = list("fish" = 2, "high society" = 1)
