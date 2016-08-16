////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	flags = OPENCONTAINER
	consume_sound = 'sound/items/drink.ogg'
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	burn_state = FIRE_PROOF

/obj/item/weapon/reagent_containers/food/drinks/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	bitesize = amount_per_transfer_from_this
	if(bitesize < 5)
		bitesize = 5

/obj/item/weapon/reagent_containers/food/drinks/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/M, mob/user, def_zone)
	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'> None of [src] left, oh no!</span>")
		return 0

	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.eat(src, user))
			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/borg = user
				borg.cell.use(30)
				var/refill = reagents.get_master_reagent_id()
				if(refill in drinks) // Only synthesize drinks
					spawn(600)
						reagents.add_reagent(refill, bitesize)
			return 1
	return 0

/obj/item/weapon/reagent_containers/food/drinks/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return

	// Moved from the can code; not necessary since closed cans aren't open containers now, but, eh.
	if(istype(target, /obj/item/weapon/reagent_containers/food/drinks/cans))
		var/obj/item/weapon/reagent_containers/food/drinks/cans/cantarget = target
		if(cantarget.canopened == 0)
			to_chat(user, "<span class='notice'>You need to open the drink you want to pour into!</span>")
			return

	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'> [target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'> [src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'> [src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'> [target] is full.</span>")
			return



		var/datum/reagent/refill
		var/datum/reagent/refillName
		if(isrobot(user))
			refill = reagents.get_master_reagent_id()
			refillName = reagents.get_master_reagent_name()

		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You transfer [trans] units of the solution to [target].</span>")

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			if(refill in drinks) // Only synthesize drinks
				var/mob/living/silicon/robot/bro = user
				var/chargeAmount = max(30,4*trans)
				bro.cell.use(chargeAmount)
				to_chat(user, "Now synthesizing [trans] units of [refillName]...")


				spawn(300)
					reagents.add_reagent(refill, trans)
					to_chat(user, "Cyborg [src] refilled.")

	return

/obj/item/weapon/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/mask/cigarette)) //ciggies are weird
		return
	if(is_hot(I))
		if(src.reagents)
			src.reagents.chem_temp += 15
			to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")
			src.reagents.handle_reactions()

/obj/item/weapon/reagent_containers/food/drinks/examine(mob/user)
	if(!..(user, 1))
		return
	if(!reagents || reagents.total_volume==0)
		to_chat(user, "<span class='notice'> \The [src] is empty!</span>")
	else if(reagents.total_volume<=src.volume/4)
		to_chat(user, "<span class='notice'> \The [src] is almost empty!</span>")
	else if(reagents.total_volume<=src.volume*0.66)
		to_chat(user, "<span class='notice'> \The [src] is half full!</span>")// We're all optimistic, right?!

	else if(reagents.total_volume<=src.volume*0.90)
		to_chat(user, "<span class='notice'> \The [src] is almost full!</span>")
	else
		to_chat(user, "<span class='notice'> \The [src] is full!</span>")

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	w_class = 1
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	materials = list(MAT_METAL=100)
	possible_transfer_amounts = list()
	volume = 5
	flags = CONDUCT | OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	volume = 150

/obj/item/weapon/reagent_containers/food/drinks/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = 3
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(MAT_SILVER=800)
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = 2
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	materials = list(MAT_METAL=400)
	volume = 25


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.


/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list("coffee" = 30)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	list_reagents = list("ice" = 30)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	list_reagents = list("tea" = 30)

/obj/item/weapon/reagent_containers/food/drinks/tea/New()
	..()
	if(prob(20))
		reagents.add_reagent("mugwort", 3)

/obj/item/weapon/reagent_containers/food/drinks/mugwort
	name = "Mugwort Tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	item_state = "coffee"
	list_reagents = list("mugwort" = 30)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 30, "sugar" = 5)

/obj/item/weapon/reagent_containers/food/drinks/chocolate
	name = "Hot Chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("chocolate" = 30)

/obj/item/weapon/reagent_containers/food/drinks/weightloss
	name = "Weight-Loss Shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "coffee"
	list_reagents = list("lipolicide" = 30, "chocolate" = 5)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml of water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	item_state = "coffee"
	list_reagents = list("dry_ramen" = 30)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/New()
	..()
	if(prob(20))
		reagents.add_reagent("enzyme", 3)

/obj/item/weapon/reagent_containers/food/drinks/chicken_soup
	name = "Cup Chicken Soup"
	desc = "A delicious and soothing cup of chicken noodle soup; just like spessmom used to make it."
	icon_state = "ramen"
	item_state = "coffee"
	list_reagents = list("chicken_soup" = 30)

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	item_state = "coffee"
	possible_transfer_amounts = list()
	volume = 10

/obj/item/weapon/reagent_containers/food/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	materials = list(MAT_METAL=1500)
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	materials = list(MAT_METAL=250)
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"

/obj/item/weapon/reagent_containers/food/drinks/flask/gold
	name = "captain's flask"
	desc = "A gold flask belonging to the captain."
	icon_state = "flask_gold"
	materials = list(MAT_GOLD=500)

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list("whiskey" = 30)

/obj/item/weapon/reagent_containers/food/drinks/flask/hand_made
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"
	materials = list()

/obj/item/weapon/reagent_containers/food/drinks/flask/thermos
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon_state = "thermos"
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/flask/lithium
	name = "Lithium Flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lithiumflask"
	volume = 50


/obj/item/weapon/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30