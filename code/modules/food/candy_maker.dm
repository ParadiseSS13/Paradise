
/obj/machinery/candy_maker
	name = "candy machine"
	desc = "The stuff of nightmares for a dentist."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "candymaker_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = OPENCONTAINER | NOREACT
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/global/list/datum/recipe/available_recipes // List of the recipes you can use
	var/global/list/acceptable_items // List of the items you can put in
	var/global/list/acceptable_reagents // List of the reagents you can put in
	var/global/max_n_of_items = 0
	var/efficiency

// see code/modules/food/recipes_candy.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/candy_maker/New()
	//..() //do not need this
	reagents = new/datum/reagents(100)
	reagents.my_atom = src
	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe/candy)-/datum/recipe/candy))
			var/datum/recipe/recipe = new type
			if(recipe.result) // Ignore recipe subtypes that lack a result
				available_recipes += recipe
			else
				del(recipe)
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/candy/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.items.len)
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/candy_maker(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()


/obj/machinery/candy_maker/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/candy_maker(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/candy_maker/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E

/*******************
*   Item Adding
********************/

/obj/machinery/candy_maker/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(operating)
		return
	if(!broken && dirty < 100)
		if(default_deconstruction_screwdriver(user, "candymaker_open", "candymaker_off", O))
			return
		if(exchange_parts(user, O))
			return
	if(!broken && istype(O, /obj/item/weapon/wrench))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			user << "<span class='caution'>The [src] can now be moved.</span>"
			return
		else if(!anchored)
			anchored = 1
			user << "<span class='caution'>The [src] is now secured.</span>"
			return

	default_deconstruction_crowbar(O)

	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"\blue [user] starts to fix part of the candy maker.", \
				"\blue You start to fix part of the candy maker." \
			)
			if (do_after(user,20))
				user.visible_message( \
					"\blue [user] fixes part of the candy maker.", \
					"\blue You have fixed part of the candy maker." \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"\blue [user] starts to fix part of the candy maker.", \
				"\blue You start to fix part of the candy maker." \
			)
			if (do_after(user,20))
				user.visible_message( \
					"\blue [user] fixes the candy maker.", \
					"\blue You have fixed the candy maker." \
				)
				src.icon_state = "candymaker_off"
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags = OPENCONTAINER
		else
			user << "\red It's broken!"
			return 1
	else if(src.dirty==100) // The candy_maker is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/reagent_containers/spray/cleaner) || istype(O, /obj/item/weapon/soap)) // If they're trying to clean it then let them
			user.visible_message( \
				"\blue [user] starts to clean the candy maker.", \
				"\blue You start to clean the candy maker." \
			)
			if (do_after(user,20))
				user.visible_message( \
					"\blue [user]  has cleaned  the candy maker.", \
					"\blue You have cleaned the candy maker." \
				)
				src.dirty = 0 // It's clean!
				src.broken = 0 // just to be sure
				src.icon_state = "candymaker_off"
				src.flags = OPENCONTAINER
		else //Otherwise bad luck!!
			user << "\red It's dirty!"
			return 1
	else if(is_type_in_list(O,acceptable_items))
		if (contents.len>=max_n_of_items)
			user << "\red This [src] is full of ingredients, you cannot put more."
			return 1
		if (istype(O,/obj/item/stack) && O:amount>1)
			new O.type (src)
			O:use(1)
			user.visible_message( \
				"\blue [user] has added one of [O] to \the [src].", \
				"\blue You add one of [O] to \the [src].")
		else
		//	user.unEquip(O)	//This just causes problems so far as I can tell. -Pete
			if(!user.drop_item())
				user << "<span class='notice'>\the [O] is stuck to your hand, you cannot put it in \the [src]</span>"
				return 0
			O.loc = src
			user.visible_message( \
				"\blue [user] has added \the [O] to \the [src].", \
				"\blue You add \the [O] to \the [src].")
	else if(istype(O,/obj/item/weapon/reagent_containers/glass) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/drinks) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/condiment) \
		)
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				user << "\red Your [O] contains components unsuitable for cookery."
				return 1
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		user << "\red This is ridiculous. You can not fit \the [G.affecting] in this [src]."
		return 1
	else
		user << "\red You have no idea what you can cook with this [O]."
		return 1
	src.updateUsrDialog()

/obj/machinery/candy_maker/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/candy_maker/attack_ai(mob/user as mob)
	return 0

/obj/machinery/candy_maker/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/*******************
*   candy_maker Menu
********************/

/obj/machinery/candy_maker/interact(mob/user as mob) // The Candy Maker Menu
	if(panel_open || !anchored)
		return
	var/dat = ""
	if(src.broken > 0)
		dat = {"<TT>Bzzzzttttt</TT>"}
	else if(src.operating)
		var/whimsy_word = pick("Wonderizing", "Scrumpdiddlyumptiousification", "Miracle-coating", "Flavorifaction")
		dat = {"<TT>[whimsy_word] in progress!<BR>Please wait...!</TT>"}
	else if(src.dirty==100)
		dat = {"<TT>This candy maker is dirty!<BR>Please clean it before use!</TT>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if (!(O in items_measures))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if (N==1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == "capsaicin")
				display_name = "Hotsauce"
			if (R.id == "frostoil")
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if (items_counts.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The candy maker is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]"}
		dat += {"<HR><BR>\
<A href='?src=\ref[src];action=cook'>Turn on!<BR>\
<A href='?src=\ref[src];action=dispose'>Eject ingredients!<BR>\
"}

	user << browse("<HEAD><TITLE>Candy Maker Controls</TITLE></HEAD><TT>[dat]</TT>", "window=candy_maker")
	onclose(user, "candy_maker")
	return



/***********************************
*   candy_maker Menu Handling/Cooking
************************************/

/obj/machinery/candy_maker/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if (!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	var/obj/byproduct
	if (!recipe)
		dirty += 1
		if (prob(max(10,dirty*5)))
			if (!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			cooked = fail()
			cooked.loc = src.loc
			return
		else if (has_extra_item())
			if (!wzhzhzh(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.loc = src.loc
			return
		else
			if (!wzhzhzh(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.loc = src.loc
			return
	else
		var/halftime = round(recipe.time/10/2)
		if (!wzhzhzh(halftime))
			abort()
			return
		if (!wzhzhzh(halftime))
			abort()
			cooked = fail()
			cooked.loc = src.loc
			return
		cooked = recipe.make_food(src)
		byproduct = recipe.get_byproduct()
		stop()
		if(cooked)
			cooked.loc = src.loc
		for(var/i=1,i<efficiency,i++)
			cooked = new cooked.type(loc)
		if(byproduct)
			new byproduct(loc)
		return

/obj/machinery/candy_maker/proc/wzhzhzh(var/seconds as num)
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/candy_maker/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/candy_maker/proc/start()
	src.visible_message("\blue The candy maker turns on.", "\blue You hear a candy maker.")
	src.operating = 1
	src.icon_state = "candymaker_on"
	src.updateUsrDialog()

/obj/machinery/candy_maker/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "candymaker_off"
	src.updateUsrDialog()

/obj/machinery/candy_maker/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = "candymaker_off"
	src.updateUsrDialog()

/obj/machinery/candy_maker/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	if (src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	usr << "\blue You dispose of the candy maker contents."
	src.updateUsrDialog()

/obj/machinery/candy_maker/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = "candymaker_dirty" // Make it look dirty!!

/obj/machinery/candy_maker/proc/muck_finish()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message("\red The candy maker gets covered in muck!")
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.flags = null //So you can't add condiments
	src.icon_state = "candymaker_dirty" // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/candy_maker/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	src.icon_state = "candymaker_broke" // Make it look all busted up and shit
	src.visible_message("\red The candy maker breaks!") //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.flags = null //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/candy_maker/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		del(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("????", amount/10)
	return ffuu

/obj/machinery/candy_maker/Topic(href, href_list)
	if(..() || panel_open)
		return

	usr.set_machine(src)
	if(src.operating)
		src.updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			dispose()
	return
