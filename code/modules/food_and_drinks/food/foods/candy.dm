

// ***********************************************************
// Candy! Delicious and sugary candy!
// Separated for organization and such
// ***********************************************************

//Candy / Candy Ingredients
//Subclass so we can pass on values
/obj/item/reagent_containers/food/snacks/candy
	name = "generic candy"
	desc = "It's placeholder flavored. This shouldn't be seen."
	icon = 'icons/obj/food/candy.dmi'
	icon_state = "candy"
	tastes = list("candy" = 1)

// ***********************************************************
// Candy Ingredients / Flavorings / Byproduct
// ***********************************************************

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("chocolate" = 1)

/obj/item/reagent_containers/food/snacks/candy/caramel
	name = "caramel"
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#DB944D"
	list_reagents = list("cream" = 2, "sugar" = 2)


/obj/item/reagent_containers/food/snacks/candy/toffee
	name = "toffee"
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/nougat
	name = "nougat"
	desc = "A soft, chewy candy commonly found in candybars."
	icon_state = "nougat"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/taffy
	name = "saltwater taffy"
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/taffy/New()
	..()
	icon_state = pick("candy1", "candy2", "candy3", "candy4", "candy5")

/obj/item/reagent_containers/food/snacks/candy/fudge
	name = "fudge"
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7D5F46"
	bitesize = 3
	list_reagents = list("cream" = 3, "chocolate" = 6)

/obj/item/reagent_containers/food/snacks/candy/fudge/peanut
	name = "peanut fudge"
	desc = "Chocolate fudge, with bits of peanuts mixed in. People with nut allergies shouldn't eat this."
	icon_state = "fudge_peanut"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/fudge/cherry
	name = "chocolate cherry fudge"
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "cookies 'n' cream fudge"
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7D5F46"
	list_reagents = list("cream" = 6, "chocolate" = 6)

/obj/item/reagent_containers/food/snacks/candy/fudge/turtle
	name = "turtle fudge"
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"
	filling_color = "#7D5F46"

// ***********************************************************
// Candy Products (Pre-existing)
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/donor
	name = "donor candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5
	list_reagents = list("nutriment" = 10, "sugar" = 3)

/obj/item/reagent_containers/food/snacks/candy/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candycorn"
	filling_color = "#FFFCB0"
	list_reagents = list("nutriment" = 4, "sugar" = 2)
	tastes = list("candy corn" = 1)

// ***********************************************************
// Candy Products (plain / unflavored)
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/cotton
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_plain"
	trash = /obj/item/c_tube
	filling_color = "#FFFFFF"
	bitesize = 4
	list_reagents = list("sugar" = 15)

/obj/item/reagent_containers/food/snacks/candy/candybar
	name = "candy"
	desc = "A chocolate candybar, wrapped in a bit of foil."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"
	bitesize = 3
	junkiness = 25
	list_reagents = list("nutriment" = 1, "chocolate" = 1)
	tastes = list("chocolate" = 1)


/obj/item/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#F2F2F2"
	list_reagents = list("minttoxin" = 1, "sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/gummybear
	name = "gummy bear"
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas."
	icon_state = "jbean"
	filling_color = "#FFFFFF"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ED0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.
	list_reagents = list("sugar" = 10)

/obj/item/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("chocolate" = 1)


/obj/item/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "chocolate" = 4)
	tastes = list("chocolate" = 1)


/obj/item/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	desc = "Chewy!"
	icon_state = "bubblegum"
	trash = /obj/item/trash/gum
	filling_color = "#FF7495"
	bitesize = 0.2
	list_reagents = list("sugar" = 5)

/obj/item/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	desc = "For being such a good sport!"
	icon_state = "sucker"
	filling_color = "#FFFFFF"
	list_reagents = list("sugar" = 10)

// ***********************************************************
// Gummy Bear Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/gummybear/red
	name = "gummy bear"
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 10, "cherryjelly" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "berryjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/poison
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 10, "limejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "lemonjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 10, "orangejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 10, "grapejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	desc = "A small bear. Wait... what?"
	icon_state = "gbear_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 10, "space_drugs" = 2)

// ***********************************************************
// Gummy Worm Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 10, "cherryjelly" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "berryjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/poison
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 10, "limejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "lemonjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 10, "orangejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 10, "grapejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 10, "space_drugs" = 2)

// ***********************************************************
// Jelly Bean Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801E28"
	list_reagents = list("sugar" = 10, "cherryjelly" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "berryjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/poison
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 12)

/obj/item/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365E30"
	list_reagents = list("sugar" = 10, "limejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	list_reagents = list("sugar" = 10, "lemonjuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#E78108"
	list_reagents = list("sugar" = 10, "orangejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	list_reagents = list("sugar" = 10, "grapejuice" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	list_reagents = list("sugar" = 10, "chocolate" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	list_reagents = list("sugar" = 10, "nutriment" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	list_reagents = list("sugar" = 10, "cola" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	list_reagents = list("sugar" = 10, "dr_gibb" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	list_reagents = list("sugar" = 10, "coffee" = 2)

/obj/item/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. You aren't sure what color it is."
	icon_state = "jbean_rainbow"
	filling_color = "#60A584"
	list_reagents = list("sugar" = 10, "space_drugs" = 2)

// ***********************************************************
// Cotton Candy Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_red"
	trash = /obj/item/c_tube
	filling_color = "#801E28"
	list_reagents = list("sugar" = 15, "cherryjelly" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	trash = /obj/item/c_tube
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "berryjuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/poison
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	trash = /obj/item/c_tube
	filling_color = "#863353"
	list_reagents = list("poisonberryjuice" = 20)

/obj/item/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_green"
	trash = /obj/item/c_tube
	filling_color = "#365E30"
	list_reagents = list("sugar" = 15, "limejuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_yellow"
	trash = /obj/item/c_tube
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "lemonjuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_orange"
	trash = /obj/item/c_tube
	filling_color = "#E78108"
	list_reagents = list("sugar" = 15, "orangejuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_purple"
	trash = /obj/item/c_tube
	filling_color = "#993399"
	list_reagents = list("sugar" = 15, "grapejuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_pink"
	trash = /obj/item/c_tube
	filling_color = "#863333"
	list_reagents = list("sugar" = 15, "watermelonjuice" = 5)

/obj/item/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	trash = /obj/item/c_tube
	filling_color = "#C8A5DC"
	list_reagents = list("omnizine" = 20)

/obj/item/reagent_containers/food/snacks/candy/cotton/bad_rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	trash = /obj/item/c_tube
	filling_color = "#32127A"
	list_reagents = list("sulfonal" = 20)

// ***********************************************************
// Candybar Flavors
// ***********************************************************

/obj/item/reagent_containers/food/snacks/candy/confectionery
	list_reagents = list("nutriment" = 1, "chocolate" = 1)

/obj/item/reagent_containers/food/snacks/candy/confectionery/rice
	name = "Asteroid Crunch Bar"
	desc = "Crunchy rice deposits in delicious chocolate! A favorite of miners galaxy-wide."
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/toffee
	name = "Yum-Baton Bar"
	desc = "Chocolate and toffee in the shape of a baton. Security sure knows how to pound these down!"
	icon_state = "yumbaton"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/caramel
	name = "Malper Bar"
	desc = "A chocolate syringe filled with a caramel injection. Just what the doctor ordered!"
	icon_state = "malper"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/caramel_nougat
	name = "Toxins Test Bar"
	desc = "An explosive combination of chocolate, caramel, and nougat. Research has never been so tasty!"
	icon_state = "toxinstest"
	filling_color = "#7D5F46"

/obj/item/reagent_containers/food/snacks/candy/confectionery/nougat
	name = "Tool-erone Bar"
	desc = "Chocolate-covered nougat, shaped like a wrench. Great for an engineer on the go!"
	icon_state = "toolerone"
	filling_color = "#7D5F46"
