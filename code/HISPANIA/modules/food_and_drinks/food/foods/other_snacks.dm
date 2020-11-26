/obj/item/reagent_containers/food/snacks/tinychocolate
	name = "chocolate"
	desc = "A tiny and sweet chocolate."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "tiny_chocolate"
	list_reagents = list("nutriment" = 1, "candy" = 1, "cocoa" = 1)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 1)

/obj/item/reagent_containers/food/snacks/proteinbar
	name = "protein bar"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "proteinbar"
	bitesize = 5
	desc = "A nutrition bar that contain a high proportion of protein to carbohydrates and fats made by a NT Medical Branch"
	trash = /obj/item/trash/proteinbar
	filling_color = "#631212"
	list_reagents = list("protein" = 5, "sugar" = 2, "nutriment" = 5)
	tastes = list("protein" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/cake/slimecake
	name = "Slime cake"
	desc = "A cake made of slimes. Probably not electrified."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "slimecake"
	slice_path = /obj/item/reagent_containers/food/snacks/cakeslice/slimecake
	slices_num = 5
	bitesize = 3
	list_reagents = list("nutriment" = 20, "vitamin" = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)

/obj/item/reagent_containers/food/snacks/cakeslice/slimecake
	name = "slime cake slice"
	desc = "A slice of slime cake."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "slimecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#00FFFF"
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)

/obj/item/reagent_containers/food/snacks/caribean_paradise
	name = "Caribean Paradise"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "caribean_paradise"
	bitesize = 3
	desc = "Half coconut stuffed with mango"
	trash = /obj/item/reagent_containers/food/snacks/grown/coconutsliced
	filling_color = "#E37F0E"
	list_reagents = list("nutriment" = 3, "sugar" = 2, "vitamin" = 4)
	tastes = list("mango" = 1)

/obj/item/reagent_containers/food/snacks/mushrooms_curry
	name = "Mushrooms Curry"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "mushrooms_curry"
	bitesize = 5
	desc = "A slight twist to the traditional recipe, rare but delicious"
	list_reagents = list("nutriment" = 5,  "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/garlic_snack
	name = "Garlic Dip Dish "
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "garlic_snack"
	bitesize = 5
	desc = "A fresh garlic-avocado mix"
	filling_color = "#E6EBD1"
	list_reagents = list("nutriment" = 4,  "vitamin" = 4)

////DISCOUNT SNACKS STARTS HERE

/obj/item/reagent_containers/food/snacks/discountburger
	name = "Discount Dan's On The Go Burger"
	desc = "Its still warm... looks horrible but food its food, right?"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "danburguer"
	bitesize = 3
	filling_color = "#126319"
	list_reagents = list("nutriment" = 1, "sodiumchloride" = 2, "fake_cheese" = 1)
	tastes = list("horsemeat" = 1, "corgimeat" = 2, "plastic" = 2)

/obj/item/reagent_containers/food/snacks/discountburger/New()
	..()
	if(prob(20))
		reagents.add_reagent("mutagen", 4)

/obj/item/reagent_containers/food/snacks/danitos
	name = "Danitos"
	desc = "For only the most MLG hardcore robust spessmen."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "danitos"
	trash = /obj/item/trash/danitos
	bitesize = 3
	filling_color = "#6312125d"
	list_reagents = list("fake_cheese" = 3, "sodiumchloride" = 4, "sugar" = 1)
	tastes = list("crisps" = 3, "chesse" = 2, "vg" = 1) //Yup tastes like VG

/obj/item/reagent_containers/food/snacks/discountburrito
	name = "Discount Dan's Burritos"
	desc = "The perfect blend of cheap processing and cheap materials."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "danburrito"
	var/list/ddname = list("Spooky Dan's BOO-ritos - Texas Toast Chainsaw Massacre Flavor","Sconto Danilo's Burritos - 50% Real Mozzarella Pepperoni Pizza Party Flavor","Descuento Danito's Burritos - Pancake Sausage Brunch Flavor","Descuento Danito's Burritos - Homestyle Comfort Flavor","Spooky Dan's BOO-ritos - Nightmare on Elm Meat Flavor","Descuento Danito's Burritos - Strawberrito Churro Flavor","Descuento Danito's Burritos - Beff and Bean Flavor")
	bitesize = 3
	filling_color = "#631216"
	list_reagents = list("fake_cheese" = 2, "porktonium" = 2, "soysauce" = 2 , "blackpepper" = 1, "protein" = 1)
	tastes = list("weird chemicals" = 3, "pug meat" = 2, "bland" = 1)

/obj/item/reagent_containers/food/snacks/discountburrito/New()
	..()
	name = pick(ddname) //The joke its that all of them are the same
	if(prob(30))
		reagents.add_reagent("polonium", 1)  //Tasty Radioactive Burrito

/obj/item/reagent_containers/food/snacks/donitos //Perfect for security
	name = "Danitos"
	desc = "Ranch or cool ranch?"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "donitos"
	trash = /obj/item/trash/donitos
	bitesize = 2
	filling_color = "#FF69B4"
	list_reagents = list("sprinkles" = 5, "nutriment" = 2, "sugar" = 5)
	tastes = list("order" = 3, "law" = 2, "shitcurity" = 1)

/obj/item/reagent_containers/food/snacks/discountbar
	name = "Discount Dan's Chocolate Bar"
	desc = "Something tells you that the glowing green filling inside, isn't healthy."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "danbar"
	bitesize = 3
	filling_color = "#631216"
	trash = /obj/item/trash/danbar
	list_reagents = list("chocolate" = 2, "cream" = 1, "sugar" = 1)
	tastes = list("chocolate" = 3, "sugar" = 2)

/obj/item/reagent_containers/food/snacks/discountbar/New()
	..()
	if(prob(30))
		reagents.add_reagent("polonium", 1)  //Tasty Radioactive Chocolate

/obj/item/reagent_containers/food/snacks/discountpie
	name = "Discount Pie"
	desc = "Regulatory laws prevent us from lying to you in the technical sense, so you know this has to contain at least some meat!"
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "danpie"
	bitesize = 2
	filling_color = "#631216"
	list_reagents = list("vitamin" = 1, "radium" = 1, "plantmatter" = 1)
	tastes = list("human meat" = 2, "iron" = 2)

/obj/item/reagent_containers/food/snacks/discountpie/self_heating
	name = "Self-Heating Donk-pocket"
	desc = "Individually wrapped, frozen, unfrozen, desiccated, resiccated, twice recalled, and still edible. Infamously so."
	icon = 'icons/hispania/obj/food/food.dmi'
	icon_state = "donkpocket_wrapped"
	wrapped = TRUE
	var/unwrapping = FALSE
	list_reagents = list("sodiumchloride" = 2, "nutriment" = 4)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)

/obj/item/reagent_containers/food/snacks/discountpie/self_heating/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)
	else
		..()

/obj/item/reagent_containers/food/snacks/discountpie/self_heating/proc/Unwrap(mob/user)
	if(unwrapping)
		return
	playsound(src, 'sound/hispania/misc/donkselfheat.ogg', 25, 1, -1)
	to_chat(user, "<span class='notice'>Following the instructions, you shake the packaging firmly and rip it open with an unsatisfying wet crunch.</span>")
	unwrapping = TRUE
	spawn(2 SECONDS)
		name = "Donk-pocket"
		desc = "Freshly warmed and probably not toxic."
		icon_state = "donkpocket"
		wrapped = FALSE
		unwrapping = FALSE

/obj/item/reagent_containers/food/snacks/discountpie/self_heating/Post_Consume(mob/living/M)
	if (wrapped == FALSE)
		M.reagents.add_reagent("omnizine", 20)
	else
		..()
////DISCOUNT SNACKS ENDS HERE
