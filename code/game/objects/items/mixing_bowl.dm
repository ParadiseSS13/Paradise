
/obj/item/mixing_bowl
	name = "mixing bowl"
	desc = "Mixing it up in the kitchen."
	flags = OPENCONTAINER
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mixing_bowl"
	var/max_n_of_items = 25
	var/dirty = FALSE
	var/clean_icon = "mixing_bowl"
	var/dirty_icon = "mixing_bowl_dirty"

/obj/item/mixing_bowl/New()
	..()
	create_reagents(100)

/obj/item/mixing_bowl/attackby(obj/item/I, mob/user, params)
	if(dirty)
		if(istype(I, /obj/item/soap))
			user.visible_message("<span class='notice'>[user] starts to scrub [src].</span>", "<span class='notice'>You start to scrub [src].</span>")
			if(do_after(user, 20 * I.toolspeed, target = src))
				clean()
				user.visible_message("<span class='notice'>[user] has scrubbed [src] clean.</span>", "<span class='notice'>You have scrubbed [src] clean.</span>")
			return 1
		else
			to_chat(user, "<span class='warning'>You should clean [src] before you use it for food prep.</span>")
		return 0
	if(is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_MICROWAVE]) || is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_GRILL]) || is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_OVEN]) || is_type_in_list(I, GLOB.cooking_ingredients[RECIPE_CANDY]))
		if(contents.len>=max_n_of_items)
			to_chat(user, "<span class='alert'>This [src] is full of ingredients, you cannot put more.</span>")
			return 1
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			if(S.amount > 1)
				var/obj/item/stack/to_add = S.split(user, 1)
				to_add.forceMove(src)
				user.visible_message("<span class='notice'>[user] adds one of [S] to [src].</span>", "<span class='notice'>You add one of [S] to [src].</span>")
			else
				return add_item(S, user)
		else
			return add_item(I, user)
	else if(is_type_in_list(I, list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/drinks, /obj/item/reagent_containers/food/condiment)))
		if(!I.reagents)
			return 1
		for(var/datum/reagent/R in I.reagents.reagent_list)
			if(!(R.id in GLOB.cooking_reagents[RECIPE_MICROWAVE]) && !(R.id in GLOB.cooking_reagents[RECIPE_GRILL]) && !(R.id in GLOB.cooking_reagents[RECIPE_OVEN]) && !(R.id in GLOB.cooking_reagents[RECIPE_CANDY]))
				to_chat(user, "<span class='alert'>Your [I] contains components unsuitable for cookery.</span>")
				return 1
	else
		to_chat(user, "<span class='alert'>You have no idea what you can cook with [I].</span>")
		return 1

/obj/item/mixing_bowl/proc/add_item(obj/item/I, mob/user)
	if(!user.drop_item())
		to_chat(user, "<span class='notice'>\The [I] is stuck to your hand, you cannot put it in [src]</span>")
		//return 0
	else
		I.forceMove(src)
		user.visible_message("<span class='notice'>[user] adds [I] to [src].</span>", "<span class='notice'>You add [I] to [src].</span>")

/obj/item/mixing_bowl/attack_self(mob/user)
	var/dat = ""
	if(dirty)
		dat = {"<code>This [src] is dirty!<BR>Please clean it before use!</code>"}
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for(var/obj/O in contents)
			var/display_name = O.name
			if(istype(O,/obj/item/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if(istype(O,/obj/item/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if(istype(O,/obj/item/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if(istype(O,/obj/item/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if(istype(O,/obj/item/reagent_containers/food/snacks/carpmeat))
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
		dat += {"<HR><BR> <A href='?src=[UID()];action=dispose'>Eject ingredients!</A><BR>"}

	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "[name]")
	return

/obj/item/mixing_bowl/Topic(href, href_list)
	if(..())
		return
	if("dispose")
		dispose()
	return

/obj/item/mixing_bowl/proc/dispose()
	for(var/obj/O in contents)
		O.forceMove(loc)
	if(reagents.total_volume)
		make_dirty(5)
	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of [src]'s contents.</span>")
	updateUsrDialog()

/obj/item/mixing_bowl/proc/make_dirty(chance)
	if(!chance)
		return
	if(prob(chance))
		dirty = TRUE
		flags = null
		icon_state = dirty_icon

/obj/item/mixing_bowl/proc/clean()
	dirty = FALSE
	flags = OPENCONTAINER
	icon_state = clean_icon

/obj/item/mixing_bowl/wash(mob/user, atom/source)
	if(..())
		clean()

/obj/item/mixing_bowl/proc/fail(obj/source)
	if(!source)
		source = src
	var/amount = 0
	for(var/obj/O in contents)
		amount++
		if(O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if(id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	if(reagents && reagents.total_volume)
		var/id = reagents.get_master_reagent_id()
		if(id)
			amount += reagents.get_reagent_amount(id)
	reagents.clear_reagents()
	var/obj/item/reagent_containers/food/snacks/badrecipe/ffuu = new(get_turf(source))
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("????", amount/10)
	make_dirty(75)
