
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/weapon/reagent_containers/food/condiment
	name = "condiment container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "emptycondiment"
	flags = OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50
	//Possible_states has the reagent id as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change() to change names, descs and sprites.
	var/list/possible_states = list(
	 "ketchup" = list("ketchup", "ketchup bottle", "You feel more American already."),
	 "capsaicin" = list("hotsauce", "hotsauce bottle", "You can almost TASTE the stomach ulcers now!"),
	 "enzyme" = list("enzyme", "universal enzyme bottle", "Used in cooking various dishes"),
	 "soysauce" = list("soysauce", "soy sauce bottle", "A salty soy-based flavoring"),
	 "frostoil" = list("coldsauce", "coldsauce bottle", "Leaves the tongue numb in it's passage"),
	 "sodiumchloride" = list("saltshakersmall", "salt shaker", "Salt. From space oceans, presumably"),
	 "blackpepper" = list("pepermillsmall", "pepper mill", "Often used to flavor food or make people sneeze"),
	 "cornoil" = list("oliveoil", "corn oil bottle", "A delicious oil used in cooking. Made from corn"),
	 "sugar" = list("emptycondiment", "sugar bottle", "Tasty spacey sugar!"),
	 "flour" =list("flour", "flour sack", "A big bag of flour. Good for baking!"),
	 "rice" =list("rice", "rice sack", "A big bag of rice. Good for cooking!"))


/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	return


/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		user << "\red None of [src] left, oh no!"
		return 0

	if(M == user)
		M << "\blue You swallow some of contents of the [src]."
		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn(0)
				reagents.trans_to(M, 10)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	else if( istype(M, /mob/living/carbon/human) )

		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] attempts to feed [M] [src].", 1)
		if(!do_mob(user, M)) return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] feeds [M] [src].", 1)

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [key_name(user)] Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [key_name(M)] Reagents: [reagentlist(src)]</font>")
		if(M.ckey)
			msg_admin_attack("[key_name_admin(user)] fed [key_name_admin(M)] with [src.name] (INTENT: [uppertext(user.a_intent)])")
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn(0)
				reagents.trans_to(M, 10)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/I as obj, mob/user as mob, params)
	return

/obj/item/weapon/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
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

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			user << "\red [src] is empty."
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "\red you can't add anymore to [target]."
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		user << "\blue You transfer [trans] units of the condiment to [target]."

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change()
	if(!possible_states.len)
		return
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			name = temp_list[2]
			desc = temp_list[3]

		else
			name = "condiment bottle"
			main_reagent = reagents.get_master_reagent_name()
			if (reagents.reagent_list.len==1)
				desc = "Looks like it is [lowertext(main_reagent)], but you are not sure."
			else
				desc = "A mixture of various condiments. [lowertext(main_reagent)] is one of them."
			icon_state = "mixedcondiments"
	else
		icon_state = "emptycondiment"
		name = "condiment bottle"
		desc = "An empty condiment bottle."
		return


/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	New()
		..()
		reagents.add_reagent("enzyme", 50)

/obj/item/weapon/reagent_containers/food/condiment/sugar
	name = "sugar bottle"
	desc = "Tasty spacey sugar!"

	New()
		..()
		reagents.add_reagent("sugar", 50)

/obj/item/weapon/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	possible_states = list()

	New()
		..()
		reagents.add_reagent("flour", 30)

/obj/item/weapon/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	item_state = "flour"
	possible_states = list()

	New()
		..()
		reagents.add_reagent("rice", 30)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	possible_states = list()

	New()
		..()
		reagents.add_reagent("sodiumchloride", 20)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	possible_states = list()

	New()
		..()
		reagents.add_reagent("blackpepper", 20)

/obj/item/weapon/reagent_containers/food/condiment/syndisauce
	name = "\improper Chef Excellence's Special Sauce"
	desc = "A potent sauce extracted from the potent amanita mushrooms. Death never tasted quite so delicious."
	amount_per_transfer_from_this = 5
	volume = 50
	New()
		..()
		reagents.add_reagent("amanitin", 50)

//Food packs. To easily apply deadly toxi... delicious sauces to your food!
/obj/item/weapon/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food"
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = 10
	possible_states = list("ketchup" = list("condi_ketchup", "Ketchup", "You feel more American already."), "capsaicin" = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"), "soysauce" = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"), "frostoil" = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage"), "sodiumchloride" = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"), "blackpepper" = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"), "cornoil" = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"), "sugar" = list("condi_sugar", "Sugar", "Tasty spacey sugar!"))
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.

/obj/item/weapon/reagent_containers/food/condiment/pack/New()
	..()
	pixel_x = rand(-7, 7)
	pixel_y = rand(-7, 7)

/obj/item/weapon/reagent_containers/food/condiment/pack/attack(mob/M as mob, mob/user as mob, def_zone) //Can't feed these to people directly.
	return

/obj/item/weapon/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			user << "<span class='warning'>You tear open [src], but there's nothing in it.</span>"
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			user << "<span class='warning'>You tear open [src], but [target] is stacked so high that it just drips off!</span>" //Not sure if food can ever be full, but better safe than sorry.
			qdel(src)
			return
		else
			user << "<span class='notice'>You tear open [src] above [target] and the condiments drip onto it.</span>"
			src.reagents.trans_to(target, amount_per_transfer_from_this)
			qdel(src)

/obj/item/weapon/reagent_containers/food/condiment/pack/on_reagent_change()
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			desc = temp_list[3]
		else
			icon_state = "condi_mixed"
			desc = "A small condiment pack. The label says it contains [originalname]"
	else
		icon_state = "condi_empty"
		desc = "A small condiment pack. It is empty."

//Ketchup
/obj/item/weapon/reagent_containers/food/condiment/pack/ketchup
	name = "Ketchup pack"
	originalname = "Ketchup"

/obj/item/weapon/reagent_containers/food/condiment/pack/ketchup/New()
		..()
		reagents.add_reagent("ketchup", 10)

//Hot sauce
/obj/item/weapon/reagent_containers/food/condiment/pack/hotsauce
	name = "Hotsauce pack"
	originalname = "Hotsauce"

/obj/item/weapon/reagent_containers/food/condiment/pack/hotsauce/New()
		..()
		reagents.add_reagent("capsaicin", 10)