
/obj/item/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "carpotoxin" = 2, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/salmonmeat
	name = "raw salmon"
	desc = "A fillet of raw salmon."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/salmonsteak
	name = "salmon steak"
	desc = "A fillet of freshly-grilled salmon meat."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "salmonsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/catfishmeat
	name = "raw catfish"
	desc = "A fillet of raw catfish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	bitesize = 1
	list_reagents = list("nutriment" = 4)

/obj/item/reagent_containers/food/snacks/fishburger
	name = "Fillet-O-Carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishburger"
	filling_color = "#FFDEFE"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/cubancarp
	name = "Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "capsaicin" = 1)

/obj/item/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself old chap. Indubitably!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "fishandchips"
	filling_color = "#E3D796"
	bitesize = 3
	list_reagents = list("nutriment" = 6)

/obj/item/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sashimi"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "capsaicin" = 5)

/obj/item/reagent_containers/food/snacks/fried_shrimp
	name = "fried shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_fried"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/boiled_shrimp
	name = "boiled shrimp"
	desc = "Just one of the many things you can do with shrimp!"
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "shrimp_cooked"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/Ebi_maki
	name = "ebi makiroll"
	desc = "A large unsliced roll of Ebi Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Ebi_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Ebi
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/sushi_Ebi
	name = "ebi sushi"
	desc = "A simple sushi consisting of cooked shrimp and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ebi"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/Ikura_maki
	name = "ikura makiroll"
	desc = "A large unsliced roll of Ikura Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Ikura_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Ikura
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)

/obj/item/reagent_containers/food/snacks/sushi_Ikura
	name = "ikura sushi"
	desc = "A simple sushi consisting of salmon roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Ikura"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/Sake_maki
	name = "sake makiroll"
	desc = "A large unsliced roll of Ebi Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Sake_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Sake
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/sushi_Sake
	name = "sake sushi"
	desc = "A simple sushi consisting of raw salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Sake"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/SmokedSalmon_maki
	name = "smoked salmon makiroll"
	desc = "A large unsliced roll of Smoked Salmon Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "SmokedSalmon_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon
	name = "smoked salmon sushi"
	desc = "A simple sushi consisting of cooked salmon and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/Tamago_maki
	name = "tamago makiroll"
	desc = "A large unsliced roll of Tamago Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tamago_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Tamago
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/sushi_Tamago
	name = "tamago sushi"
	desc = "A simple sushi consisting of egg and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tamago"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/Inari_maki
	name = "inari makiroll"
	desc = "A large unsliced roll of Inari Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Inari_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Inari
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/sushi_Inari
	name = "inari sushi"
	desc = "A piece of fried tofu stuffed with rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Inari"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/Masago_maki
	name = "masago makiroll"
	desc = "A large unsliced roll of Masago Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Masago_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Masago
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)

/obj/item/reagent_containers/food/snacks/sushi_Masago
	name = "masago sushi"
	desc = "A simple sushi consisting of goldfish roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/Tobiko_maki
	name = "tobiko makiroll"
	desc = "A large unsliced roll of Tobkio Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tobiko_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Tobiko
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)

/obj/item/reagent_containers/food/snacks/sushi_Tobiko
	name = "tobiko sushi"
	desc = "A simple sushi consisting of shark roe."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Masago"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/TobikoEgg_maki
	name = "tobiko and egg makiroll"
	desc = "A large unsliced roll of Tobkio and Egg Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "TobikoEgg_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_TobikoEgg
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8, "protein" = 4)

/obj/item/reagent_containers/food/snacks/sushi_TobikoEgg
	name = "tobiko and egg sushi"
	desc = "A sushi consisting of shark roe and an egg."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_TobikoEgg"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "protein" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/Tai_maki
	name = "tai makiroll"
	desc = "A large unsliced roll of Tai Sushi."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "Tai_maki"
	slice_path = /obj/item/reagent_containers/food/snacks/sushi_Tai
	slices_num = 4
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/reagent_containers/food/snacks/sushi_Tai
	name = "tai sushi"
	desc = "A simple sushi consisting of catfish and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Tai"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/reagent_containers/food/snacks/sushi_Unagi
	name = "unagi sushi"
	desc = "A simple sushi consisting of eel and rice."
	icon = 'icons/obj/food/seafood.dmi'
	icon_state = "sushi_Hokki"
	bitesize = 3
	list_reagents = list("nutriment" = 2)
