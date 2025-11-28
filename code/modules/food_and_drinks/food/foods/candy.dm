

// ***********************************************************
// Candy! Delicious and sugary candy!
// Separated for organization and such
// ***********************************************************

//Candy / Candy Ingredients
//Subclass so we can pass on values
/obj/item/food/candy
	name = "generic candy"
	desc = "It's placeholder flavored. This shouldn't be seen."
	icon = 'icons/obj/food/candy.dmi'
	icon_state = "candy"
	tastes = list("candy" = 1)

// ***********************************************************
// Candy Ingredients / Flavorings / Byproduct
// ***********************************************************

/obj/item/food/candy/caramel
	name = "caramel"
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#DB944D"
	list_reagents = list("cream" = 2, "sugar" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/candy/toffee
	name = "toffee"
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/nougat
	name = "nougat"
	desc = "A soft, chewy candy commonly found in candy bars."
	icon_state = "nougat"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/taffy
	name = "saltwater taffy"
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/taffy/Initialize(mapload)
	. = ..()
	icon_state = pick("candy1", "candy2", "candy3", "candy4", "candy5")

/obj/item/food/candy/fudge
	name = "fudge"
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7D5F46"
	bitesize = 3
	list_reagents = list("cream" = 3, "chocolate" = 6)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/fudge/peanut
	name = "peanut fudge"
	desc = "Chocolate fudge, with bits of peanuts mixed in. People with nut allergies shouldn't eat this."
	icon_state = "fudge_peanut"

/obj/item/food/candy/fudge/cherry
	name = "chocolate cherry fudge"
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"

/obj/item/food/candy/fudge/cookies_n_cream
	name = "cookies 'n' cream fudge"
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	list_reagents = list("cream" = 6, "chocolate" = 6)

/obj/item/food/candy/fudge/turtle
	name = "turtle fudge"
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"

/obj/item/food/candy/chocolate_orange
	name = "chocolate orange"
	desc = "A festive chocolate orange."
	icon_state = "choco_orange"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 1)
	tastes = list("chocolate" = 3, "oranges" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/candied_pineapple
	name = "candied pineapple"
	desc = "A chunk of pineapple coated in sugar and dried into a chewy treat."
	icon_state = "candied_pineapple"
	filling_color = "#ffbd35"
	list_reagents = list("nutriment" = 3, "vitamin" = 3)
	tastes = list("sugar" = 2, "chewy pineapple" = 4)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/chocolate_coin
	name = "chocolate coin"
	desc = "A completely edible but non-flippable festive coin."
	icon_state = "choco_coin"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 4, "sugar" = 1, "cocoa" = 1, "vitamin" = 1)
	tastes = list("chocolate" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/chocolate_bunny
	name = "chocolate bunny"
	desc = "Contains less than 10% real rabbit!"
	icon_state = "chocolate_bunny"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 4, "sugar" = 1, "cocoa" = 1)
	tastes = list("chocolate" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/fudge_dice
	name = "fudge dice"
	desc = "A little cube of chocolate that tends to have a less intense taste if you eat too many at once."
	icon_state = "choco_dice"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 1, "cocoa" = 1)
	tastes = list("fudge" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

// ***********************************************************
// Candy Products (Pre-existing)
// ***********************************************************

/obj/item/food/candy/donor
	name = "donor candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5
	list_reagents = list("nutriment" = 10, "sugar" = 3)

/obj/item/food/candy/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candycorn"
	filling_color = "#FFFCB0"
	list_reagents = list("nutriment" = 4, "sugar" = 2)
	tastes = list("candy corn" = 1)

// ***********************************************************
// Candy Products (plain / unflavored)
// ***********************************************************

/obj/item/food/candy/cotton
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_plain"
	trash = /obj/item/c_tube
	bitesize = 4
	list_reagents = list("sugar" = 15)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/candy/candybar
	name = "candy"
	desc = "A chocolate candy bar, wrapped in a bit of foil."
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"
	bitesize = 3
	junkiness = 25
	antable = FALSE
	list_reagents = list("nutriment" = 1, "chocolate" = 1)
	tastes = list("chocolate" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/candy/candycane
	name = "candy cane"
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#F2F2F2"
	list_reagents = list("minttoxin" = 1, "sugar" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear
	name = "gummy bear"
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	bitesize = 3
	list_reagents = list("sugar" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/candy/gummyworm
	name = "gummy worm"
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	bitesize = 3
	list_reagents = list("sugar" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/candy/jellybean
	name = "jelly bean"
	desc = "A candy bean, guaranteed to not give you gas."
	icon_state = "jbean"
	bitesize = 3
	list_reagents = list("sugar" = 10)
	goal_difficulty = FOOD_GOAL_DUPLICATE

/obj/item/food/candy/jawbreaker
	name = "jawbreaker"
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ED0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.
	list_reagents = list("sugar" = 10)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cash
	name = "candy cash"
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("chocolate" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/candy/coin
	name = "chocolate coin"
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("chocolate" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL


/obj/item/food/candy/gum
	name = "bubblegum"
	desc = "Chewy!"
	icon_state = "bubblegum"
	trash = /obj/item/trash/gum
	filling_color = "#FF7495"
	bitesize = 0.2
	list_reagents = list("sugar" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/sucker
	name = "sucker"
	desc = "For being such a good sport!"
	icon_state = "sucker"
	list_reagents = list("sugar" = 10)
	goal_difficulty = FOOD_GOAL_NORMAL

// ***********************************************************
// Gummy Bear Flavors
// ***********************************************************

/obj/item/food/candy/gummybear/red
	name = "red gummy bear"
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 10, "cherryjelly" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear/blue
	name = "blue gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "berryjuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear/poison
	name = "blue gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/food/candy/gummybear/green
	name = "green gummy bear"
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 10, "limejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear/yellow
	name = "yellow gummy bear"
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "lemonjuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear/orange
	name = "orange gummy bear"
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 10, "orangejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear/purple
	name = "purple gummy bear"
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 10, "grapejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummybear/wtf
	name = "rainbow gummy bear"
	desc = "A small bear. Wait... what?"
	icon_state = "gbear_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 10, "space_drugs" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

// ***********************************************************
// Gummy Worm Flavors
// ***********************************************************

/obj/item/food/candy/gummyworm/red
	name = "red gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 10, "cherryjelly" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummyworm/blue
	name = "blue gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "berryjuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummyworm/poison
	name = "blue gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/food/candy/gummyworm/green
	name = "green gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 10, "limejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummyworm/yellow
	name = "yellow gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "lemonjuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummyworm/orange
	name = "orange gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 10, "orangejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummyworm/purple
	name = "purple gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 10, "grapejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/gummyworm/wtf
	name = "rainbow gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 10, "space_drugs" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

// ***********************************************************
// Jelly Bean Flavors
// ***********************************************************

/obj/item/food/candy/jellybean/red
	name = "red jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 10, "cherryjelly" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/blue
	name = "blue jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "berryjuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/poison
	name = "blue jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/food/candy/jellybean/green
	name = "green jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 10, "limejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/yellow
	name = "yellow jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "lemonjuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/orange
	name = "orange jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 10, "orangejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/purple
	name = "purple jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 10, "grapejuice" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/chocolate
	name = "chocolate jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	list_reagents = list("sugar" = 10, "chocolate" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/popcorn
	name = "popcorn jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	list_reagents = list("sugar" = 10, "nutriment" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/cola
	name = "cola jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	list_reagents = list("sugar" = 10, "cola" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/drgibb
	name = "\improper Dr. Gibb jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	list_reagents = list("sugar" = 10, "dr_gibb" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/coffee
	name = "coffee jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. It's coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	list_reagents = list("sugar" = 10, "coffee" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/jellybean/wtf
	name = "rainbow jelly bean"
	desc = "A candy bean, guaranteed to not give you gas. You aren't sure what color it is."
	icon_state = "jbean_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 10, "space_drugs" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

// ***********************************************************
// Cotton Candy Flavors
// ***********************************************************

/obj/item/food/candy/cotton/red
	name = "red cotton candy"
	icon_state = "cottoncandy_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 15, "cherryjelly" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/blue
	name = "blue cotton candy"
	icon_state = "cottoncandy_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "berryjuice" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/poison
	name = "blue cotton candy"
	icon_state = "cottoncandy_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 20)

/obj/item/food/candy/cotton/green
	name = "green cotton candy"
	icon_state = "cottoncandy_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 15, "limejuice" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/yellow
	name = "yellow cotton candy"
	icon_state = "cottoncandy_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "lemonjuice" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/orange
	name = "orange cotton candy"
	icon_state = "cottoncandy_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 15, "orangejuice" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/purple
	name = "purple cotton candy"
	icon_state = "cottoncandy_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 15, "grapejuice" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/pink
	name = "pink cotton candy"
	icon_state = "cottoncandy_pink"
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "watermelonjuice" = 5)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/cotton/rainbow
	name = "rainbow cotton candy"
	icon_state = "cottoncandy_rainbow"
	filling_color = "#eb0dc6"
	list_reagents = list("omnizine" = 20)
	goal_difficulty = FOOD_GOAL_HARD

/obj/item/food/candy/cotton/bad_rainbow
	name = "rainbow cotton candy"
	icon_state = "cottoncandy_rainbow"
	filling_color = "#32127A"
	list_reagents = list("sulfonal" = 20)

// ***********************************************************
// Candybar Flavors
// ***********************************************************

/obj/item/food/candy/confectionery
	list_reagents = list("nutriment" = 1, "chocolate" = 1)

/obj/item/food/candy/confectionery/rice
	name = "Asteroid Crunch Bar"
	desc = "Crunchy rice deposits in delicious chocolate! A favorite of miners galaxy-wide."
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/confectionery/toffee
	name = "Yum-Baton Bar"
	desc = "Chocolate and toffee in the shape of a baton. Security sure knows how to pound these down!"
	icon_state = "yumbaton"
	filling_color = "#7D5F46"
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/confectionery/caramel
	name = "Malper Bar"
	desc = "A chocolate syringe filled with a caramel injection. Just what the doctor ordered!"
	icon_state = "malper"
	filling_color = "#7D5F46"
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/confectionery/caramel_nougat
	name = "Toxins Test Bar"
	desc = "An explosive combination of chocolate, caramel, and nougat. Research has never been so tasty!"
	icon_state = "toxinstest"
	filling_color = "#7D5F46"
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candy/confectionery/nougat
	name = "Tool-erone Bar"
	desc = "Chocolate-covered nougat, shaped like a wrench. Great for an engineer on the go!"
	icon_state = "toolerone"
	filling_color = "#7D5F46"
	goal_difficulty = FOOD_GOAL_NORMAL
