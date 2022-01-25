//HISPANIA VENDING
/obj/machinery/vending
	var/list/hispa_products = list()
	var/list/hispa_contraband = list()
	var/list/hispa_premium = list()
	var/list/hispa_prices = list()
///Hispania Civilians Clothes

/obj/machinery/vending/proc/make_products()
	products |= hispa_products	// For each, use the following pattern:
	contraband |= hispa_contraband	// list(/type/path = amount,/type/path2 = amount2)
	premium |= hispa_premium
	prices |= hispa_prices

/*Note:  all sprites that belong to hispania code and have their respective sprites
in the icon folders of hispania (icons/hispania) need an extra line of code for them
to work, "hispania_icon = TRUE"*/

/obj/machinery/vending/accesories
	name = "\improper Xtra"
	desc = "An accessories dispenser. Made by NT Corp."
	ads_list = list("Why die on the inside when you can be beautiful on the outside?","Buy yourself a sense of style!","Try our new *ITEM NOT FOUND, PLEASE REACH OUT TO YOUR NEAREST ENGINEER*!","Respect the drip. (and the law!)")
	icon = 'icons/hispania/obj/vending.dmi'
	icon_state = "Xtra"
	icon_vend = "Xtra-vend"
	density = TRUE
	vend_delay = 12

	products = list(/obj/item/storage/wallet = 15,
					/obj/item/clothing/glasses/monocle = 5,
					/obj/item/clothing/glasses/regular = 5,
					/obj/item/clothing/ears/headphones = 5,
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
   					/obj/item/clothing/head/collectable/rabbitears = 2,
					/obj/item/clothing/head/hairflower = 5,
    				/obj/item/stack/sheet/animalhide/monkey = 5,
    				/obj/item/stack/sheet/animalhide/lizard = 5,)
	contraband = list(/obj/item/lipstick = 200,
					/obj/item/lipstick/green = 200,
					/obj/item/lipstick/blue = 200,
					/obj/item/lipstick/lime= 220,
					/obj/item/lipstick/purple = 200,
					/obj/item/lipstick/jade = 220,
    				/obj/item/lipstick/black = 200,
    				/obj/item/lipstick/white = 200,
    				/obj/item/clothing/head/kitty = 350,
    				/obj/item/clothing/head/kitty/mouse = 350,
   					/obj/item/clothing/head/collectable/rabbitears = 2000,
    				/obj/item/clothing/head/hairflower = 200,
    				/obj/item/clothing/head/collectable/petehat = 2000,
					/obj/item/clothing/head/collectable/xenom = 2000,
					/obj/item/clothing/head/collectable/paper = 2000,
					/obj/item/clothing/head/collectable/slime = 2000,
					/obj/item/clothing/head/collectable/pirate = 2000,
					/obj/item/clothing/head/collectable/thunderdome = 2000,
    				/obj/item/stack/sheet/animalhide/monkey = 500,
    				/obj/item/stack/sheet/animalhide/lizard = 500,)

/obj/machinery/vending/artvend/free
	prices = list()
	hispa_prices = list()

/obj/machinery/vending/discdan
	name = "\improper Discount Dan's"
	desc = "A vending machine containing discount snacks. It is owned by the infamous 'Discount Dan' franchise."
	ads_list = list("Discount Dan, he's the man!","There ain't nothing better in this world than a bite of mystery.","Don't listen to those other machines, buy my product!","Quantity over Quality!","Don't listen to those eggheads from MedBay, buy now!","Discount Dan's: We're good for you! Nope, couldn't say it with a straight face.","Discount Dan's: Only the best quality produ-*BZZT*")
	icon = 'icons/hispania/obj/vending.dmi'
	slogan_list = list("Discount Dan(tm) is not responsible for any damages caused by misuse of his product.")
	vend_reply = "No refunds."
	icon_state = "discount"
	icon_vend = "discount-vend"
	density = TRUE
	vend_delay = 12
	products = list(/obj/item/reagent_containers/food/snacks/discountburger = 6,
					/obj/item/reagent_containers/food/snacks/danitos = 6,
					/obj/item/reagent_containers/food/snacks/discountburrito = 10,
					/obj/item/reagent_containers/food/snacks/donitos = 3,
					/obj/item/reagent_containers/food/snacks/discountbar = 10,
					/obj/item/reagent_containers/food/snacks/discountpie = 8,
					/obj/item/reagent_containers/food/condiment/pack/discount_sauce = 5
					)
	premium = list(		/obj/item/reagent_containers/food/snacks/discountpie/self_heating = 5)
	prices = list(			/obj/item/reagent_containers/food/snacks/discountburger = 30,
					/obj/item/reagent_containers/food/snacks/danitos = 25,
					/obj/item/reagent_containers/food/snacks/discountburrito = 40,
					/obj/item/reagent_containers/food/snacks/donitos = 60,
					/obj/item/reagent_containers/food/snacks/discountbar = 15,
					/obj/item/reagent_containers/food/snacks/discountpie = 50,
					/obj/item/reagent_containers/food/condiment/pack/discount_sauce = 10
					)

/obj/machinery/vending/fitness
	name = "\improper SweatMAX"
	desc = "An exercise aid and nutrition supplement vendor that preys on your inadequacy."
	ads_list = list("Pain is just weakness leaving the body!","Run! Your fat is catching up to you", "Never forget leg day!","Push out!","This is the only break you get today.","Don't cry, sweat!","Healthy is an outfit that looks good on everybody.","It's about grind, it's about power!")
	icon = 'icons/hispania/obj/vending.dmi'
	slogan_list = list("SweatMAX, get robust!")
	vend_reply = "Get robust!"
	icon_state = "fitness"
	icon_vend = "fitness-vend"
	density = TRUE
	vend_delay = 12
	products = list(/obj/item/reagent_containers/food/drinks/hispania/minimilk = 6,
					/obj/item/reagent_containers/food/drinks/hispania/minimilk/minimilk_chocolate = 6,
					/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker = 1, ///Cause its edgy everyone wants it
					/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker/red = 2,
					/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker/blue = 2,
					/obj/item/reagent_containers/food/snacks/proteinbar = 3,
					/obj/item/reagent_containers/glass/beaker/waterbottle = 10
					)
	prices = list(	/obj/item/reagent_containers/food/drinks/hispania/minimilk = 50,
					/obj/item/reagent_containers/food/drinks/hispania/minimilk/minimilk_chocolate = 55,
					/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker = 550, //Protein its expensive even in space
					/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker/red = 500,
					/obj/item/reagent_containers/glass/beaker/waterbottle/fitnessshaker/blue = 500,
					/obj/item/reagent_containers/food/snacks/proteinbar = 100,
					/obj/item/reagent_containers/glass/beaker/waterbottle = 30
					)
