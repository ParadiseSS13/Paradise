
//////////////////////
//		Burgers		//
//////////////////////

/obj/item/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It appears almost sentient."
	icon_state = "brainburger"
	filling_color = "#F2B6EA"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "prions" = 10, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/ghostburger
	name = "ghost burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#FFF2FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#D63C3C"

/obj/item/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#D63C3C"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/tofuburger
	name = "tofu burger"
	desc = "Making this should probably be a criminal offense."
	icon_state = "tofuburger"
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "nanomachines" = 10, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#CCCCCC"
	volume = 120
	bitesize = 3
	list_reagents = list("nutriment" = 6, "nanomachines" = 70, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic and tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43DE18"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/clownburger
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	filling_color = "#FF00FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/mimeburger
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/baseballburger
	name = "home run baseball burger"
	desc = "It's still warm. Batter up!"
	icon_state = "baseball"
	filling_color = "#CD853F"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/spellburger
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#D505FF"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/bigbiteburger
	name = "BigBite burger"
	desc = "Forget the Big Mac, THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#E3D681"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/superbiteburger
	name = "SuperBite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#CCA26A"
	bitesize = 7
	list_reagents = list("nutriment" = 40, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/jellyburger
	name = "jelly burger"
	desc = "Culinary delight...?"
	icon_state = "jellyburger"
	filling_color = "#B572AB"
	bitesize = 3

/obj/item/reagent_containers/food/snacks/jellyburger/slime
	list_reagents = list("nutriment" = 6, "slimejelly" = 5, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/jellyburger/cherry
	list_reagents = list("nutriment" = 6, "cherryjelly" = 5, "vitamin" = 1)


//////////////////////
//	Sandwiches		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sandwich
	name = "sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/toastedsandwich
	name = "toasted sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 6, "carbon" = 2)

/obj/item/reagent_containers/food/snacks/grilledcheese
	name = "grilled cheese sandwich"
	desc = "Goes great with tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list("nutriment" = 7, "vitamin" = 1) //why make a regualr sandwhich when you can make grilled cheese, with this nutriment value?

/obj/item/reagent_containers/food/snacks/jellysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9E3A78"
	bitesize = 3

/obj/item/reagent_containers/food/snacks/jellysandwich/slime
	list_reagents = list("nutriment" = 2, "slimejelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/jellysandwich/cherry
	list_reagents = list("nutriment" = 2, "cherryjelly" = 5, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	list_reagents = list("nutriment" = 6, "vitamin" = 6)

/obj/item/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	list_reagents = list("nutriment" = 5)
