////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	flags = OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,25)
	volume = 50

	on_reagent_change()
		if (gulp_size < 5) gulp_size = 5
		else gulp_size = max(round(reagents.total_volume / 5), 5)

	attack_self(mob/user as mob)
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		var/datum/reagents/R = src.reagents
		var/fillevel = gulp_size

		if(!R.total_volume || !R)
			user << "\red None of [src] left, oh no!"
			return 0

		if(M == user)

			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(!H.check_has_mouth())
					user << "Where do you intend to put \the [src]? You don't have a mouth!"
					return

			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(0)
					reagents.trans_to(M, gulp_size)

			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )

			var/mob/living/carbon/human/H = M
			if(!H.check_has_mouth())
				user << "Where do you intend to put \the [src]? \The [H] doesn't have a mouth!"
				return

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [key_name(user)] Reagents: [reagentlist(src)]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [key_name(M)] Reagents: [reagentlist(src)]</font>")
			log_attack("[key_name_admin(user)] fed [key_name_admin(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(0)
					reagents.trans_to(M, gulp_size)

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/borg = user
				borg.cell.use(30)
				var/refill = R.get_master_reagent_id()
				if(refill in drinks) // Only synthesize drinks
					spawn(600)
						R.add_reagent(refill, fillevel)

			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
			return 1

		return 0


	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return

		// Moved from the can code; not necessary since closed cans aren't open containers now, but, eh.
		if (istype(target, /obj/item/weapon/reagent_containers/food/drinks/cans))
			var/obj/item/weapon/reagent_containers/food/drinks/cans/cantarget = target
			if(cantarget.canopened == 0)
				user << "<span class='notice'>You need to open the drink you want to pour into!</span>"
				return

		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return



			var/datum/reagent/refill
			var/datum/reagent/refillName
			if(isrobot(user))
				refill = reagents.get_master_reagent_id()
				refillName = reagents.get_master_reagent_name()

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution to [target]."

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				if(refill in drinks) // Only synthesize drinks
					var/mob/living/silicon/robot/bro = user
					var/chargeAmount = max(30,4*trans)
					bro.cell.use(chargeAmount)
					user << "Now synthesizing [trans] units of [refillName]..."


					spawn(300)
						reagents.add_reagent(refill, trans)
						user << "Cyborg [src] refilled."

		return

	attackby(var/obj/item/I, mob/user as mob, params)
		if(istype(I, /obj/item/clothing/mask/cigarette)) //ciggies are weird
			return
		if(is_hot(I))
			if(src.reagents)
				src.reagents.chem_temp += 15
				user << "<span class='notice'>You heat [src] with [I].</span>"
				src.reagents.handle_reactions()

	examine(mob/user)
		if(!..(user, 1))
			return
		if(!reagents || reagents.total_volume==0)
			user << "\blue \The [src] is empty!"
		else if (reagents.total_volume<=src.volume/4)
			user << "\blue \The [src] is almost empty!"
		else if (reagents.total_volume<=src.volume*0.66)
			user << "\blue \The [src] is half empty!" // Pessimism is the real order of the day.
		else if (reagents.total_volume<=src.volume*0.90)
			user << "\blue \The [src] is almost full!"
		else
			user << "\blue \The [src] is full!"


////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup"
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "golden_cup" //yup :)
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	possible_transfer_amounts = null
	volume = 150
	flags = CONDUCT | OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 june and name of the winner will be graved on it."


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "\improper Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	New()
		..()
		reagents.add_reagent("milk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/* Flour is no longer a reagent
/obj/item/weapon/reagent_containers/food/drinks/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "flour"
	item_state = "flour"
	New()
		..()
		reagents.add_reagent("flour", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)
*/

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "\improper SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	New()
		..()
		reagents.add_reagent("soymilk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "\improper Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("coffee", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "\improper Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("tea", 30)
		if(prob(20))
			reagents.add_reagent("mugwort", 3)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/mugwort
	name = "\improper Mugwort Tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("mugwort", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "\improper Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("ice", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "\improper Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("hot_coco", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/chocolate
	name = "\improper Hot Chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("chocolate", 45)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/weightloss
	name = "\improper Weight-Loss Shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "coffee"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("lipolicide", 30)
		reagents.add_reagent("chocolate", 5)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)


/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "\improper Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	New()
		..()
		reagents.add_reagent("dry_ramen", 30)
		if(prob(20))
			reagents.add_reagent("enzyme", 3)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/chicken_soup
	name = "\improper Cup Chicken Soup"
	desc = "A delicious and soothing cup of chicken noodle soup; just like spessmom used to make it."
	icon_state = "ramen"
	New()
		..()
		reagents.add_reagent("chicken_soup", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10
	New()
		..()
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)
	on_reagent_change()
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
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "Captain's Flask"
	desc = "A metal flask belonging to the captain"
	icon_state = "flask"
	materials = list(MAT_SILVER=500)
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "Detective's Flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
	materials = list(MAT_METAL=250)
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/flask/hand_made
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"

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