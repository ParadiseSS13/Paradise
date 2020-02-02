///Hispania Civilians Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//code by Danaleja2005

/obj/machinery/vending/walldrobe
	name = "\improper WallDrobe"
	desc = "Wall-mounted Clothes dispenser. Made by D&N Corp."
	product_ads = "Dress up in fashion and wear our amazing uniforms, hats, suits made of the best material, only with us N&D Corp!."
	icon = 'icons/hispania/obj/vending.dmi'
	icon_state = "walldrobe"
	icon_deny = "walldrobe-deny"
	icon_vend = "walldrobe-vend"
	density = FALSE //It is wall-mounted, and thus, not dense. --SuperxpdudeS
	vend_delay = 12

/obj/machinery/vending/walldrobe/cap
	name = "\improper Captain's WallDrobe"
	req_access = list(access_captain)
	products = list(/obj/item/clothing/under/rank/command/captain/formal/light = 1,
					/obj/item/clothing/under/rank/command/captain/formal/dark = 1,
					/obj/item/clothing/head/caphat/dark = 1,
					/obj/item/clothing/head/caphat/light = 1,
					/obj/item/clothing/suit/armor/vest/captrenchcoat = 1,
					/obj/item/clothing/suit/captunic = 1,
					/obj/item/clothing/suit/captunic/capjacket = 1,
					/obj/item/clothing/under/captainparade = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/head/caphat/parade = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/under/dress/dress_cap = 1,
					/obj/item/clothing/under/dress/dress_cap = 1,
					/obj/item/clothing/suit/armor/vest/capcarapace/alt = 1,
					/obj/item/clothing/shoes/brown = 1,
					/obj/item/clothing/shoes/laceup = 1,
					/obj/item/clothing/suit/mantle/armor/captain = 1,
					/obj/item/clothing/gloves/color/captain = 1)

/obj/machinery/vending/walldrobe/rd
	name = "\improper Research Director's WallDrobe"
	req_access = list(access_rd)
	products = list(/obj/item/clothing/suit/storage/labcoat/rdlargedark = 1,
					/obj/item/clothing/suit/storage/labcoat/rdlargeroundcutdark = 1,
					/obj/item/clothing/suit/bio_suit/scientist = 1,
					/obj/item/clothing/head/bio_hood/scientist = 1,
					/obj/item/clothing/under/rank/research_director = 1,
					/obj/item/clothing/suit/storage/labcoat = 1,
					/obj/item/clothing/suit/mantle/labcoat = 1,
					/obj/item/clothing/mask/gas = 1,
					/obj/item/clothing/shoes/white = 1,
					/obj/item/clothing/gloves/color/latex = 1)

/obj/machinery/vending/accesories
	name = "\improper Xtra"
	desc = "Accessories dispenser. Made by NT Corp."
	product_ads = "Get fashion and useful, funny accessories for make your work better an happy, only with us NT Corp!, Remember Work is the most important."
	icon = 'icons/hispania/obj/vending.dmi'
	icon_state = "Xtra"
	icon_vend = "Xtra-vend"
	density = TRUE
	vend_delay = 12

	products = list(		/obj/item/storage/wallet/random = 15,
					/obj/item/clothing/glasses/monocle = 5,
					/obj/item/clothing/glasses/regular = 5,
					/obj/item/deck/cards = 5,
					/obj/item/deck/tarot = 5,
					/obj/item/clothing/ears/headphones = 5,
					/obj/item/reagent_containers/food/drinks/mug = 5,
					/obj/item/clothing/accessory/necklace = 5,
					/obj/item/clothing/accessory/necklace = 5,
					/obj/item/clothing/accessory/necklace/dope = 5,
					/obj/item/clothing/accessory/necklace/locket = 5,
					/obj/item/clothing/accessory/armband = 5,
					/obj/item/lipstick = 5,
					/obj/item/lipstick/blue = 5,
					/obj/item/lipstick/lime= 5,
					/obj/item/lipstick/purple = 5,
					/obj/item/lipstick/jade = 5,
   					/obj/item/lipstick/black = 5,
   					/obj/item/lipstick/white = 5,
    					/obj/item/lipstick/green = 5,
   					/obj/item/clothing/head/kitty = 10,
   					/obj/item/clothing/head/kitty/mouse= 10,
   					/obj/item/clothing/head/collectable/rabbitears = 10,
    					/obj/item/bikehorn/rubberducky = 5,
					/obj/item/clothing/head/hairflower = 5,
    					/obj/item/storage/bag/UNO = 15,
    					/obj/item/stack/sheet/animalhide/monkey = 5,
    					/obj/item/stack/sheet/animalhide/lizard = 5)
	contraband = list(		/obj/item/stack/sheet/animalhide/human = 5)
	prices = list(			/obj/item/storage/wallet/random = 700,
					/obj/item/clothing/glasses/monocle = 800,
					/obj/item/clothing/glasses/regular = 1500,
					/obj/item/deck/cards = 400,
					/obj/item/deck/tarot = 500,
					/obj/item/clothing/ears/headphones = 1000,
					/obj/item/reagent_containers/food/drinks/mug = 400,
					/obj/item/clothing/accessory/necklace = 600,
					/obj/item/clothing/accessory/necklace/dope = 700,
					/obj/item/clothing/accessory/necklace/locket = 1200,
					/obj/item/clothing/accessory/armband = 450,
					/obj/item/lipstick = 200,
					/obj/item/lipstick/green = 200,
					/obj/item/lipstick/blue = 200,
					/obj/item/lipstick/lime= 220,
					/obj/item/lipstick/purple = 200,
					/obj/item/lipstick/jade = 220,
    					/obj/item/lipstick/black = 200,
    					/obj/item/lipstick/white = 200,
    					/obj/item/clothing/head/kitty = 550,
    					/obj/item/clothing/head/kitty/mouse = 550,
   					/obj/item/clothing/head/collectable/rabbitears = 550,
   				 	/obj/item/bikehorn/rubberducky = 679,
    					/obj/item/clothing/head/hairflower = 400,
    					/obj/item/storage/bag/UNO = 200,
    					/obj/item/stack/sheet/animalhide/monkey = 1500,
    					/obj/item/stack/sheet/animalhide/lizard = 2000)
