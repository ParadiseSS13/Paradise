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
				if(H.species.flags & IS_SYNTHETIC)
					H << "\red You have a monitor for a head, where do you think you're going to put that?"
					return

			M << "\blue You swallow a gulp of [src]."
			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to_ingest(M, gulp_size)

			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
			return 1
		else if( istype(M, /mob/living/carbon/human) )

			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				H << "\red They have a monitor for a head, where do you think you're going to put that?"
				return

			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] attempts to feed [M] [src].", 1)
			if(!do_mob(user, M)) return
			for(var/mob/O in viewers(world.view, user))
				O.show_message("\red [user] feeds [M] [src].", 1)

			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
			log_attack("[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

			if(reagents.total_volume)
				reagents.reaction(M, INGEST)
				spawn(5)
					reagents.trans_to_ingest(M, gulp_size)

			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/bro = user
				bro.cell.use(30)
				var/refill = R.get_master_reagent_id()
				spawn(600)
					R.add_reagent(refill, fillevel)

			playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
			return 1

		return 0


	afterattack(obj/target, mob/user, proximity)
		if(!proximity) return

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

	examine()
		set src in view()
		..()
		if (!(usr in range(0)) && usr!=src.loc) return
		if(!reagents || reagents.total_volume==0)
			usr << "\blue \The [src] is empty!"
		else if (reagents.total_volume<=src.volume/4)
			usr << "\blue \The [src] is almost empty!"
		else if (reagents.total_volume<=src.volume*0.66)
			usr << "\blue \The [src] is half full!"
		else if (reagents.total_volume<=src.volume*0.90)
			usr << "\blue \The [src] is almost full!"
		else
			usr << "\blue \The [src] is full!"


////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup"
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
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
	name = "Space Milk"
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
	icon = 'icons/obj/food.dmi'
	icon_state = "flour"
	item_state = "flour"
	New()
		..()
		reagents.add_reagent("flour", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)
*/

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	New()
		..()
		reagents.add_reagent("soymilk", 50)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("coffee", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("tea", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/mugwort
	name = "Mugwort Tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("mugwort", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	New()
		..()
		reagents.add_reagent("ice", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("hot_coco", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/chocolate
	name = "Hot Chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	item_state = "coffee"
	New()
		..()
		reagents.add_reagent("chocolate", 45)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/weightloss
	name = "Weight-Loss Shake"
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
	name = "Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	New()
		..()
		reagents.add_reagent("dry_ramen", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/chicken_soup
	name = "Cup Chicken Soup"
	desc = "A delicious and soothing cup of chicken noodle soup; just like spessmom used to make it."
	icon_state = "ramen"
	New()
		..()
		reagents.add_reagent("chicken_soup", 30)
		src.pixel_x = rand(-10.0, 10)
		src.pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "Paper Cup"
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
	name = "Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "Captain's Flask"
	desc = "A metal flask belonging to the captain"
	icon_state = "flask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "Detective's Flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
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

////Stinkeye///   Holy buns don't ever drink this -Fox

/obj/item/weapon/reagent_containers/food/drinks/stinkeye
	name = "Stinkeye's Special Reserve"
	desc = "An old bottle labelled 'The Good Stuff'. This probably has enough kick to knock an elephant on its ass."
	icon_state = "whiskeybottle"
	volume = 250
	New()
		..()
		reagents.add_reagent("beer", 30)
		reagents.add_reagent("wine", 30)
		reagents.add_reagent("cider", 30)
		reagents.add_reagent("vodka", 30)
		reagents.add_reagent("ethanol", 30)
		reagents.add_reagent("eyenewt", 30)

////Discount Dan's Soup//////       May God have mercy on your souls---and stomachs.    -Fox


/obj/item/weapon/reagent_containers/food/drinks/dansoup
	name = "Discount Dan's Quik-Noodles"
	desc = "A self-heating cup of noodles. There's enough sodium in these to put the Dead Sea to shame."
	icon_state = "dansoup"
	volume = 65
	var/selfheat = 0

/obj/item/weapon/reagent_containers/food/drinks/dansoup/attack_self(mob/user as mob) //self-heating action!
	if(selfheat)
		return
	else
		selfheat = 1
		user << "<span class='notice'>You twist the bottom of the cup. The cup emits a soft clack as the heater triggers.</span>"
		reagents.add_reagent("pyrosium", 2)
		reagents.add_reagent("oxygen", 2)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/random
	New()
		..()
		var/list/list = typesof(/obj/item/weapon/reagent_containers/food/drinks/dansoup) - list(/obj/item/weapon/reagent_containers/food/drinks/dansoup,/obj/item/weapon/reagent_containers/food/drinks/dansoup/random)
		var/T = pick(list)
		new T(loc)
		spawn(0)
			del src

/obj/item/weapon/reagent_containers/food/drinks/dansoup/bbq
	name = "Devil Dan's Quik-Noodles - Brimstone BBQ Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("sulfur", 5)
		reagents.add_reagent("beff", 5)
//		reagents.add_reagent("ghostchili", 5)      uncomment once ghost chili juice is added

/obj/item/weapon/reagent_containers/food/drinks/dansoup/macaroni
	name = "Discount Dan's Quik-Noodles - Macaroni and Imitation Processed Cheese Product Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 9)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("fake_cheese", 2)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/beef
	name = "Comrade Dan's Quik-Noodles - Beef Perestroikanoff Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("milk", 3)
		reagents.add_reagent("enzyme", 3)
		reagents.add_reagent("beff", 4)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/teriyaki
	name = "Discount Deng's Quik-Noodles - Teriyaki TVP Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("hydrogenated_soybeanoil", 1)
		reagents.add_reagent("msg", 14)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("synthflesh", 5)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/gamer
	name = "Dan's Quik-Noodles - Gamer Grubs Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("????", 10)
		reagents.add_reagent("potassium", 5)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/mushroom
	name = "Frycook Dan's Quik-Noodles - Mushroom-Swiss Burger-Bake Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("beff", 2)
		reagents.add_reagent("weird_cheese", 2)
		reagents.add_reagent("psilocybin", 6)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/ketchup
	name = "Frycook Dan's Quik-Noodles - Curly Fry Ketchup Hoedown Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("hydrogenated_soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("tomatojuice", 4)
		reagents.add_reagent("mugwort", 3)
		reagents.add_reagent("capsaicin", 3)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/sundae
	name = "Dessert Dan's Quik-Noodles - Sweet Sundae Noodle Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("vhfcs", 10)
		reagents.add_reagent("chocolate", 2)
		reagents.add_reagent("cream", 2)
		reagents.add_reagent("chocolate_milk", 6)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/tuna
	name = "Descuento Danito's Quik-Noodles - Tuna Melt Taco Fiesta Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("fake_cheese", 3)
		reagents.add_reagent("mercury", 3)
		reagents.add_reagent("capsaicin", 4)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/lomein
	name = "Discount Deng's Quik-Noodles - Sweet and Sour Lo Mein Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("sacid", 3)
		reagents.add_reagent("vhfcs", 7)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/crab
	name = "Pirate Dan's Quik-Noodles - Spicy Imitation Crab Meat Paste Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("synthflesh", 3)
		reagents.add_reagent("saltpetre", 3)
		reagents.add_reagent("capsaicin", 14)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/sausage
	name = "Morning Dan's Quik-Noodles - Mechanically Reclaimed Sausage Biscuit Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("hydrogenated_soybeanoil", 4)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("ammonia", 3)
		reagents.add_reagent("gravy", 4)
		reagents.add_reagent("coffee", 3)

/obj/item/weapon/reagent_containers/food/drinks/dansoup/italian
	name = "Sconto Danilo's Quik-Noodles - Italian Strozzapreti Lunare Flavor"
	New()
		..()
		reagents.add_reagent("chicken_soup", 10)
		reagents.add_reagent("soybeanoil", 1)
		reagents.add_reagent("msg", 9)
		reagents.add_reagent("sodiumchloride", 10)
		reagents.add_reagent("nicotine", 8)
		reagents.add_reagent("tomatojuice", 4)
		reagents.add_reagent("wine", 2)
		reagents.add_reagent("water", 2)