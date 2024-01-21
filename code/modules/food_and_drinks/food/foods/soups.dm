
//////////////////////
//		Soups		//
//////////////////////

// Base object for soups, should never appear ingame.
/obj/item/reagent_containers/food/snacks/soup
	name = "impossible soup"
	desc = "This soup is so good, it shouldn't even exist!"
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "beans" // If you don't have a sprite, you get beans.
	consume_sound = 'sound/items/drink.ogg'
	trash = /obj/item/trash/snack_bowl
	bitesize = 5

/obj/item/reagent_containers/food/snacks/soup/meatballsoup
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	filling_color = "#785210"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("meatball" = 1)

/obj/item/reagent_containers/food/snacks/soup/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#C4DBA0"
	list_reagents = list("nutriment" = 5, "slimejelly" = 5, "water" = 5, "vitamin" = 4)
	tastes = list("slime" = 1)

/obj/item/reagent_containers/food/snacks/soup/bloodsoup
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	list_reagents = list("nutriment" = 2, "blood" = 10, "water" = 5, "vitamin" = 4)
	tastes = list("iron" = 1)

/obj/item/reagent_containers/food/snacks/soup/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 5, "vitamin" = 8)
	tastes = list("a bad joke" = 1)

/obj/item/reagent_containers/food/snacks/soup/vegetablesoup
	name = "vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	filling_color = "#AFC4B5"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("vegetables" = 1)

/obj/item/reagent_containers/food/snacks/soup/nettlesoup
	name = "nettle soup"
	desc = "To think, the botanist would've beaten you to death with one of these."
	icon_state = "nettlesoup"
	filling_color = "#AFC4B5"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("nettles" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	var/extra_reagent = null
	list_reagents = list("nutriment" = 6)
	tastes = list("chaos" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup/Initialize(mapload)
	. = ..()
	extra_reagent = pick("capsaicin", "frostoil", "omnizine", "banana", "blood", "slimejelly", "toxin", "banana", "carbon", "oculine")
	reagents.add_reagent("[extra_reagent]", 5)

/obj/item/reagent_containers/food/snacks/soup/wishsoup
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	filling_color = "#D1F4FF"
	list_reagents = list("water" = 10)
	tastes = list("wishes" = 1)

/obj/item/reagent_containers/food/snacks/soup/wishsoup/Initialize(mapload)
	. = ..()
	if(prob(25))
		desc = "A wish come true!" // hue
		reagents.add_reagent("nutriment", 9)
		reagents.add_reagent("vitamin", 1)

/obj/item/reagent_containers/food/snacks/soup/tomatosoup
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	filling_color = "#D92929"
	list_reagents = list("nutriment" = 5, "tomatojuice" = 10, "vitamin" = 3)
	tastes = list("tomato" = 1)

/obj/item/reagent_containers/food/snacks/soup/misosoup
	name = "miso soup"
	desc = "The universe's best soup! Yum!!!"
	icon_state = "misosoup"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("miso" = 1)

/obj/item/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	filling_color = "#E386BF"
	list_reagents = list("nutriment" = 8, "vitamin" = 4)
	tastes = list("mushroom" = 1)

/obj/item/reagent_containers/food/snacks/soup/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	filling_color = "#FAC9FF"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("beet" = 1)

/obj/item/reagent_containers/food/snacks/soup/beetsoup/Initialize(mapload)
	. = ..()
	name = pick("borsch", "bortsch", "borstch", "borsh", "borshch", "borscht")

/obj/item/reagent_containers/food/snacks/soup/eyesoup
	name = "eyeball soup"
	desc = "It looks back at you..."
	icon_state = "eyeballsoup"
	filling_color = "#E386BF"
	list_reagents = list("nutriment" = 7, "protein" = 2)
	tastes = list("squirming" = 2, "tomato" = 2)

/obj/item/reagent_containers/food/snacks/soup/sweetpotatosoup
	name = "sweet potato soup"
	desc = "Delicious sweet potato in soup form."
	icon_state = "sweetpotatosoup"
	list_reagents = list("nutriment" = 5)
	tastes = list("sweet potato" = 1)

/obj/item/reagent_containers/food/snacks/soup/redbeetsoup
	name = "red beet soup"
	desc = "Quite a delicacy."
	icon_state = "redbeetsoup"
	list_reagents = list("nutriment" = 5)
	tastes = list("red beet" = 1)

/obj/item/reagent_containers/food/snacks/soup/frenchonionsoup
	name = "french onion soup"
	desc = "Good enough to make a grown mime cry."
	icon_state = "onionsoup"
	list_reagents = list("nutriment" = 8)
	tastes = list("caramelized onions" = 3, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/soup/zurek
	name = "zurek"
	desc = "A traditional Polish soup composed of vegetables, meat, and an egg. Goes great with bread."
	icon_state = "zurek"
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("creamy vegetables" = 3, "sausage" = 2)

/obj/item/reagent_containers/food/snacks/soup/cullenskink
	name = "cullen skink"
	desc = "A thick Scottish soup made of smoked fish, potatoes and onions."
	icon_state = "cullen_skink"
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("creamy broth" = 2, "fish" = 2, "vegetables" = 2)

/obj/item/reagent_containers/food/snacks/soup/chicken_noodle_soup
	name = "chicken noodle soup"
	desc = "A hearty bowl of chicken noodle soup, perfect for when you're stuck at home and sick."
	icon_state = "chicken_noodle_soup"
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("broth" = 1, "chicken" = 1, "carrots" = 1, "noodles" = 1)

/obj/item/reagent_containers/food/snacks/soup/cornchowder
	name = "corn chowder"
	desc = "A creamy bowl of corn chowder, with bacon bits and mixed vegetables. One bowl is never enough."
	icon_state = "corn_chowder"
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("creamy broth" = 1, "bacon" = 1, "mixed vegetables" = 1)

/obj/item/reagent_containers/food/snacks/soup/meatball_noodles
	name = "meatball noodle soup"
	desc = "A hearty noodle soup made from meatballs and pasta in a rich broth. Commonly topped with a handful of chopped nuts."
	icon_state = "meatball_noodles"
	list_reagents = list("nutriment" = 10, "protein" = 4)
	tastes = list("bone broth" = 1, "meat" = 1, "gnocchi" = 1, "peanuts" = 1)

/obj/item/reagent_containers/food/snacks/soup/seedsoup
	name = "Misklmæsch" //miskl = seed, mæsch = soup
	desc = "A seed based soup, made by germinating seeds and then boiling them. \
		Produces a particularly bitter broth which is usually balanced by the addition of vinegar."
	icon_state = "moth_seed_soup"
	list_reagents = list("nutriment" = 6)
	tastes = list("bitterness" = 1, "sourness" = 1, "nature" = 1)

//////////////////////
//		Stews		//
//////////////////////

/obj/item/reagent_containers/food/snacks/soup/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9E673A"
	bitesize = 7
	list_reagents = list("nutriment" = 10, "oculine" = 5, "tomatojuice" = 5, "vitamin" = 5)
	tastes = list("tomato" = 1, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 8)
	tastes = list("soy" = 1, "vegetables" = 1)

/obj/item/reagent_containers/food/snacks/soup/beanstew
	name = "Prickeldröndolhaskl" //prickeld = spicy, röndol = bean, haskl = stew
	desc = "A spicy bean stew with lots of veggies, commonly served aboard the fleet as a filling and satisfying meal with rice or bread."
	icon_state = "moth_bean_stew"
	list_reagents = list("nutriment" = 10)
	tastes = list("beans" = 1, "cabbage" = 1, "spicy sauce" = 1)

/obj/item/reagent_containers/food/snacks/soup/oatstew
	name = "Häfmisklhaskl" //häfmiskl = oat (häf from German hafer meaning oat, miskl meaning seed), haskl = stew
	desc = "A spicy bean stew with lots of veggies, commonly served aboard the fleet as a filling and satisfying meal with rice or bread."
	icon_state = "moth_oat_stew"
	list_reagents = list("nutriment" = 10)
	tastes = list("oats" = 1, "sweet potato" = 1, "carrot" = 1, "pumpkin" = 1, "parsnip" = 1)

/obj/item/reagent_containers/food/snacks/soup/hong_kong_borscht
	name = "hong kong borscht"
	desc = "Also known as luo song tang or Russian soup, this dish bears little to no resemblance to Eastern European borscht- indeed, it's a tomato-based soup with no beets in sight."
	icon_state = "hong_kong_borscht"
	list_reagents = list("nutriment" = 10, "protein" = 2)
	tastes = list("tomato" = 1, "cabbage" = 1, "meat" = 1)

/obj/item/reagent_containers/food/snacks/soup/hong_kong_macaroni
	name = "hong kong macaroni"
	desc = "A favourite from Hong Kong's Cha Chaan Tengs, this macaroni soup came to Mars with Cantonese settlers under Cybersun Industries, and has become as much of a breakfast staple there as it is in its homeland."
	icon_state = "hong_kong_macaroni"
	list_reagents = list("nutriment" = 8, "protein" = 2)
	tastes = list("cream" = 1, "chicken" = 1, "pasta" = 1, "ham" =1)

//////////////////////
//		Chili		//
//////////////////////

/obj/item/reagent_containers/food/snacks/soup/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	filling_color = "#FF3C00"
	list_reagents = list("nutriment" = 5, "capsaicin" = 1, "tomatojuice" = 2, "vitamin" = 2)
	tastes = list("hot peppers" = 1, "tomato" = 1)

/obj/item/reagent_containers/food/snacks/soup/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	list_reagents = list("nutriment" = 5, "frostoil" = 1, "tomatojuice" = 2, "vitamin" = 2)
	tastes = list("tomato" = 1, "mint" = 1)

/obj/item/reagent_containers/food/snacks/soup/clownchili
	name = "chili con carnival"
	desc = "A delicious stew of meat, chiles, and salty, salty clown tears."
	icon_state = "clownchili"
	filling_color = "#FF3C00"
	list_reagents = list("nutriment" = 5, "tomatojuice" = 2, "protein" = 2)
	tastes = list("tomato" = 1, "chili" = 1, "meat" = 1, "sad clowns" = 4)
