

// ***********************************************************
// Candy! Delicious and sugary candy!
// Separated for organization and such
// ***********************************************************

//Candy / Candy Ingredients
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "generic candy"
	desc = "It's placeholder flavored. This shouldn't be seen."
	icon = 'icons/obj/food/candy.dmi'
	icon_state = "candy"

/obj/item/weapon/reagent_containers/food/snacks/candy/New()
		..()

// ***********************************************************
// Candy Ingredients / Flavorings / Byproduct
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("chocolate",4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel
	name = "Caramel"
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#DB944D"

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel/New()
	..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("sugar", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee
	name = "Toffee"
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat
	name = "Nougat"
	desc = "A soft, chewy candy commonly found in candybars."
	icon_state = "nougat"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)
	spawn(1)
		reagents.del_reagent("egg")
		reagents.update_total()
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy
	name = "Saltwater Taffy"
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy/New()
	..()
	icon_state = pick("candy1", "candy2", "candy3", "candy4", "candy5")
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge
	name = "Fudge"
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/New()
	..()
	reagents.add_reagent("cream", 3)
	reagents.add_reagent("chocolate",6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/peanut
	name = "Peanut Fudge"
	desc = "Chocolate fudge, with bits of peanuts mixed in. People with nut allergies shouldn't eat this."
	icon_state = "fudge_peanut"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry
	name = "Chocolate Cherry Fudge"
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "Cookies 'n' Cream Fudge"
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream/New()
	..()
	reagents.add_reagent("cream", 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle
	name = "Turtle Fudge"
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"
	filling_color = "#7D5F46"

// ***********************************************************
// Candy Products (Pre-existing)
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy

/obj/item/weapon/reagent_containers/food/snacks/candy/donor/New()
	..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("sugar", 3)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/candy/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candycorn"
	filling_color = "#FFFCB0"

/obj/item/weapon/reagent_containers/food/snacks/candy/candy_corn/New()
	..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sugar", 2)
	bitesize = 2

// ***********************************************************
// Candy Products (plain / unflavored)
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_plain"
	trash = /obj/item/weapon/c_tube
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/New()
	..()
	reagents.add_reagent("sugar", 15)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar
	name = "candy"
	desc = "A chocolate candybar, wrapped in a bit of foil."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("chocolate",5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#F2F2F2"

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane/New()
	..()
	reagents.add_reagent("minttoxin", 1)
	reagents.add_reagent("sugar", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear
	name = "gummy bear"
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/New()
	..()
	reagents.add_reagent("sugar", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/New()
	..()
	reagents.add_reagent("sugar", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas."
	icon_state = "jbean"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/New()
	..()
	reagents.add_reagent("sugar", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ED0758"

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker/New()
	..()
	reagents.add_reagent("sugar", 10)
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.

/obj/item/weapon/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"

/obj/item/weapon/reagent_containers/food/snacks/candy/cash/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("chocolate", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"

/obj/item/weapon/reagent_containers/food/snacks/candy/coin/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("chocolate",4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	desc = "Chewy!"
	icon_state = "bubblegum"
	trash = /obj/item/trash/gum
	filling_color = "#FF7495"

/obj/item/weapon/reagent_containers/food/snacks/candy/gum/New()
	..()
	reagents.add_reagent("sugar", 5)
	bitesize = 0.2

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	desc = "For being such a good sport!"
	icon_state = "sucker"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/New()
	..()
	reagents.add_reagent("sugar", 10)
	bitesize = 1

// ***********************************************************
// Gummy Bear Flavors
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red
	name = "gummy bear"
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801E28"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red/New()
	..()
	reagents.add_reagent("cherryjelly", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue/New()
	..()
	reagents.add_reagent("berryjuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/poison
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863353"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/poison/New()
	..()
	reagents.add_reagent("poisonberryjuice", 12)
	spawn(1)
		reagents.del_reagent("sugar")
		reagents.update_total()
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365E30"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green/New()
	..()
	reagents.add_reagent("limejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow/New()
	..()
	reagents.add_reagent("lemonjuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#E78108"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange/New()
	..()
	reagents.add_reagent("orangejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple/New()
	..()
	reagents.add_reagent("grapejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	desc = "A small bear. Wait... what?"
	icon_state = "gbear_wtf"
	filling_color = "#60A584"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf/New()
	..()
	reagents.add_reagent("space_drugs", 2)
	bitesize = 3

// ***********************************************************
// Gummy Worm Flavors
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801E28"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red/New()
	..()
	reagents.add_reagent("cherryjelly", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue/New()
	..()
	reagents.add_reagent("berryjuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/poison
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863353"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/poison/New()
	..()
	reagents.add_reagent("poisonberryjuice", 12)
	spawn(1)
		reagents.del_reagent("sugar")
		reagents.update_total()
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365E30"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green/New()
	..()
	reagents.add_reagent("limejuice", 10)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow/New()
	..()
	reagents.add_reagent("lemonjuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#E78108"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange/New()
	..()
	reagents.add_reagent("orangejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple/New()
	..()
	reagents.add_reagent("grapejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60A584"

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf/New()
	..()
	reagents.add_reagent("space_drugs", 2)
	bitesize = 3

// ***********************************************************
// Jelly Bean Flavors
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801E28"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red/New()
	..()
	reagents.add_reagent("cherryjelly", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue/New()
	..()
	reagents.add_reagent("berryjuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/poison
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863353"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/poison/New()
	..()
	reagents.add_reagent("poisonberryjuice", 12)
	spawn(1)
		reagents.del_reagent("sugar")
		reagents.update_total()
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365E30"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green/New()
	..()
	reagents.add_reagent("limejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow/New()
	..()
	reagents.add_reagent("lemonjuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#E78108"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange/New()
	..()
	reagents.add_reagent("orangejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple/New()
	..()
	reagents.add_reagent("grapejuice", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate/New()
	..()
	reagents.add_reagent("chocolate",2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn/New()
	..()
	reagents.add_reagent("nutriment", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola/New()
	..()
	reagents.add_reagent("cola", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb/New()
	..()
	reagents.add_reagent("dr_gibb", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee/New()
	..()
	reagents.add_reagent("coffee", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. You aren't sure what color it is."
	icon_state = "jbean_wtf"
	filling_color = "#60A584"

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf/New()
	..()
	reagents.add_reagent("space_drugs", 2)
	bitesize = 3

// ***********************************************************
// Cotton Candy Flavors
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_red"
	trash = /obj/item/weapon/c_tube
	filling_color = "#801E28"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red/New()
	..()
	reagents.add_reagent("cherryjelly", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	trash = /obj/item/weapon/c_tube
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue/New()
	..()
	reagents.add_reagent("berryjuice", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/poison
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	trash = /obj/item/weapon/c_tube
	filling_color = "#863353"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/poison/New()
	..()
	reagents.add_reagent("poisonberryjuice", 20)
	spawn(1)
		reagents.del_reagent("sugar")
		reagents.update_total()
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_green"
	trash = /obj/item/weapon/c_tube
	filling_color = "#365E30"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green/New()
	..()
	reagents.add_reagent("limejuice", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_yellow"
	trash = /obj/item/weapon/c_tube
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow/New()
	..()
	reagents.add_reagent("lemonjuice", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_orange"
	trash = /obj/item/weapon/c_tube
	filling_color = "#E78108"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange/New()
	..()
	reagents.add_reagent("orangejuice", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_purple"
	trash = /obj/item/weapon/c_tube
	filling_color = "#993399"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple/New()
	..()
	reagents.add_reagent("grapejuice", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_pink"
	trash = /obj/item/weapon/c_tube
	filling_color = "#863333"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink/New()
	..()
	reagents.add_reagent("watermelonjuice", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	trash = /obj/item/weapon/c_tube
	filling_color = "#C8A5DC"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow/New()
	..()
	reagents.add_reagent("omnizine", 20)
	spawn(1)
		reagents.del_reagent("sugar")
		reagents.update_total()
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/bad_rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	trash = /obj/item/weapon/c_tube
	filling_color = "#32127A"

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/bad_rainbow/New()
	..()
	reagents.add_reagent("sulfonal", 20)
	spawn(1)
		reagents.del_reagent("sugar")
		reagents.update_total()
	bitesize = 4

// ***********************************************************
// Candybar Flavors
// ***********************************************************

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar/rice
	name = "Asteroid Crunch Bar"
	desc = "Crunchy rice deposits in delicious chocolate! A favorite of miners galaxy-wide."
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar/toffee
	name = "Yum-baton Bar"
	desc = "Chocolate and toffee in the shape of a baton. Security sure knows how to pound these down!"
	icon_state = "yumbaton"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar/caramel
	name = "Malper Bar"
	desc = "A chocolate syringe filled with a caramel injection. Just what the doctor ordered!"
	icon_state = "malper"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar/caramel_nougat
	name = "Toxins Test Bar"
	desc = "An explosive combination of chocolate, caramel, and nougat. Research has never been so tasty!"
	icon_state = "toxinstest"
	filling_color = "#7D5F46"

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar/nougat
	name = "Tool-erone Bar"
	desc = "Chocolate-covered nougat, shaped like a wrench. Great for an engineer on the go!"
	icon_state = "toolerone"
	filling_color = "#7D5F46"
