
/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
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
	var/efficiency = 0
	var/list/cook_verbs = list("Cooking")
	//Recipe & Item vars
	var/recipe_type		//Make sure to set this on the machine definition, or else you're gonna runtime on New()
	var/list/datum/recipe/available_recipes // List of the recipes you can use
	var/list/acceptable_items // List of the items you can put in
	var/list/acceptable_reagents // List of the reagents you can put in
	var/max_n_of_items = 0
	//Icon states
	var/off_icon
	var/on_icon
	var/broken_icon
	var/dirty_icon
	var/open_icon

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/New()
	reagents = new/datum/reagents(100)
	reagents.my_atom = src
	if(!available_recipes)
		available_recipes = new
		acceptable_items = new
		acceptable_reagents = new
		for(var/type in subtypesof(recipe_type))
			var/datum/recipe/recipe = new type
			if(recipe.result) // Ignore recipe subtypes that lack a result
				available_recipes += recipe
				for(var/item in recipe.items)
					acceptable_items |= item
				for(var/reagent in recipe.reagents)
					acceptable_reagents |= reagent
				if(recipe.items || recipe.fruit)
					max_n_of_items = max(max_n_of_items,recipe.count_n_items())
			else
				qdel(recipe)
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

/*******************
*   Item Adding
********************/

/obj/machinery/kitchen_machine/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(operating)
		return
	if(!broken && dirty < 100)
		if(default_deconstruction_screwdriver(user, open_icon, off_icon, O))
			return
		if(exchange_parts(user, O))
			return
	if(!broken && istype(O, /obj/item/weapon/wrench))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class='alert'>\The [src] can now be moved.</span>")
			return
		else if(!anchored)
			anchored = 1
			to_chat(user, "<span class='alert'>\The [src] is now secured.</span>")
			return

	default_deconstruction_crowbar(O)

	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of \the [src].</span>", \
				"<span class='notice'>You start to fix part of \the [src].</span>" \
			)
			if(do_after(user,20, target = src))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of \the [src].</span>", \
					"<span class='notice'>You have fixed part of \the [src].</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of \the [src].</span>", \
				"<span class='notice'>You start to fix part of \the [src].</span>" \
			)
			if(do_after(user,20, target = src))
				user.visible_message( \
					"<span class='notice'>[user] fixes \the [src].</span>", \
					"<span class='notice'>You have fixed \the [src].</span>" \
				)
				src.icon_state = off_icon
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags = OPENCONTAINER
		else
			to_chat(user, "<span class='alert'>It's broken!</span>")
			return 1
	else if(src.dirty==100) // The machine is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/reagent_containers/spray/cleaner) || istype(O, /obj/item/weapon/soap)) // If they're trying to clean it then let them
			user.visible_message( \
				"<span class='notice'>[user] starts to clean \the [src].</span>", \
				"<span class='notice'>You start to clean \the [src].</span>" \
			)
			if(do_after(user,20, target = src))
				user.visible_message( \
					"<span class='notice'>[user]  has cleaned \the [src].</span>", \
					"<span class='notice'>You have cleaned \the [src].</span>" \
				)
				src.dirty = 0 // It's clean!
				src.broken = 0 // just to be sure
				src.icon_state = off_icon
				src.flags = OPENCONTAINER
		else //Otherwise bad luck!!
			to_chat(user, "<span class='alert'>It's dirty!</span>")
			return 1
	else if(is_type_in_list(O,acceptable_items))
		if(contents.len>=max_n_of_items)
			to_chat(user, "<span class='alert'>This [src] is full of ingredients, you cannot put more.</span>")
			return 1
		if(istype(O,/obj/item/stack) && O:amount>1)
			new O.type (src)
			O:use(1)
			user.visible_message( \
				"<span class='notice'>[user] has added one of [O] to \the [src].</span>", \
				"<span class='notice'>You add one of [O] to \the [src].</span>")
		else
			if(!user.drop_item())
				to_chat(user, "<span class='notice'>\The [O] is stuck to your hand, you cannot put it in \the [src]</span>")
				return 0

			O.forceMove(src)
			user.visible_message( \
				"<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")
	else if(istype(O,/obj/item/weapon/reagent_containers/glass) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/drinks) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/condiment) \
		)
		if(!O.reagents)
			return 1
		for(var/datum/reagent/R in O.reagents.reagent_list)
			if(!(R.id in acceptable_reagents))
				to_chat(user, "<span class='alert'>Your [O] contains components unsuitable for cookery.</span>")
				return 1
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		to_chat(user, "<span class='alert'>This is ridiculous. You can not fit \the [G.affecting] in this [src].</span>")
		return 1
	else
		to_chat(user, "<span class='alert'>You have no idea what you can cook with this [O].</span>")
		return 1
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/attack_ai(mob/user as mob)
	return 0

/obj/machinery/kitchen_machine/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/********************
*   Machine Menu	*
********************/

/obj/machinery/kitchen_machine/interact(mob/user as mob) // The microwave Menu
	if(panel_open || !anchored)
		return
	var/dat = ""
	if(src.broken > 0)
		dat = {"<TT>Bzzzzttttt</TT>"}
	else if(src.operating)
		dat = {"<TT>[pick(src.cook_verbs)] in progress!<BR>Please wait...!</TT>"}
	else if(src.dirty==100)
		dat = {"<TT>This [src] is dirty!<BR>Please clean it before use!</TT>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for(var/obj/O in contents)
			var/display_name = O.name
			if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for(var/O in items_counts)
			var/N = items_counts[O]
			if(!(O in items_measures))
				dat += {"<B>[capitalize(O)]:</B> [N] [lowertext(O)]\s<BR>"}
			else
				if(N==1)
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures[O]]<BR>"}
				else
					dat += {"<B>[capitalize(O)]:</B> [N] [items_measures_p[O]]<BR>"}

		for(var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if(R.id == "capsaicin")
				display_name = "Hotsauce"
			if(R.id == "frostoil")
				display_name = "Coldsauce"
			dat += {"<B>[display_name]:</B> [R.volume] unit\s<BR>"}

		if(items_counts.len==0 && reagents.reagent_list.len==0)
			dat = {"<B>The [src] is empty</B><BR>"}
		else
			dat = {"<b>Ingredients:</b><br>[dat]"}
		dat += {"<HR><BR>\
<A href='?src=[UID()];action=cook'>Turn on!</A><BR>\
<A href='?src=[UID()];action=dispose'>Eject ingredients!</A><BR>\
"}

	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "[src.name]")
	return



/************************************
*   Machine Menu Handling/Cooking	*
************************************/

/obj/machinery/kitchen_machine/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if(!wzhzhzh(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	var/obj/byproduct
	if(!recipe)
		dirty += 1
		if(prob(max(10,dirty*5)))
			if(!wzhzhzh(4))
				abort()
				return
			muck_start()
			wzhzhzh(4)
			muck_finish()
			fail()
			return
		else if(has_extra_item())
			if(!wzhzhzh(4))
				abort()
				return
			broke()
			fail()
			return
		else
			if(!wzhzhzh(10))
				abort()
				return
			stop()
			fail()
			return
	else
		var/halftime = round(recipe.time/10/2)
		if(!wzhzhzh(halftime))
			abort()
			return
		if(!wzhzhzh(halftime))
			abort()
			fail()
			return
		cooked = recipe.make_food(src)
		byproduct = recipe.get_byproduct()
		stop()
		if(cooked)
			cooked.forceMove(src.loc)
		for(var/i=1,i<efficiency,i++)
			cooked = new cooked.type(loc)
		if(byproduct)
			new byproduct(loc)
		return

/obj/machinery/kitchen_machine/proc/wzhzhzh(var/seconds as num)
	for(var/i=1 to seconds)
		if(stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for(var/obj/O in contents)
		if( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/kitchen_machine/proc/start()
	src.visible_message("<span class='notice'>\The [src] turns on.</span>", "<span class='notice'>You hear \a [src].</span>")
	src.operating = 1
	src.icon_state = on_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = off_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = off_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/dispose()
	for(var/obj/O in contents)
		O.forceMove(src.loc)
	if(src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of \the [src]'s contents.</span>")
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = dirty_icon // Make it look dirty!!

/obj/machinery/kitchen_machine/proc/muck_finish()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message("<span class='alert'>\The [src] gets covered in muck!</span>")
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.flags = null //So you can't add condiments
	src.icon_state = dirty_icon // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/broke()
	var/datum/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	src.icon_state = broken_icon // Make it look all busted up and shit
	src.visible_message("<span class='alert'>The [src] breaks!</span>") //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.flags = null //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for(var/obj/O in contents-ffuu)
		amount++
		if(O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("????", amount/10)
	ffuu.forceMove(get_turf(src))

/obj/machinery/kitchen_machine/Topic(href, href_list)
	if(..() || panel_open)
		return

	usr.set_machine(src)
	if(src.operating)
		src.updateUsrDialog()
		return

	switch(href_list["action"])
		if("cook")
			cook()

		if("dispose")
			dispose()
	return
