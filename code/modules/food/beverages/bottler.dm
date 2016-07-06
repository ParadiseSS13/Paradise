
/obj/machinery/bottler
	name = "bottler unit"
	desc = "A machine that combines ingredients and bottles the resulting beverages."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "bottler_off"
	density = 1
	anchored = 1
	var/obj/item/obj_1 = null
	var/obj/item/obj_2 = null
	var/obj/item/obj_3 = null
	var/list/datum/bottler_recipe/available_recipes
	var/list/acceptable_items
	var/glass_bottles = 10
	var/plastic_bottles = 20
	var/cans = 25
	var/bottling = 0

/obj/machinery/bottler/New()
	if(!available_recipes)
		available_recipes = new
		acceptable_items = new
		//These are going to be acceptable even if they aren't in a recipe
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks
		acceptable_items |= /obj/item/weapon/reagent_containers/food/drinks/cans
		//the rest is based on what is used in recipes so we don't have people destroying the nuke disc
		for (var/type in subtypesof(/datum/bottler_recipe))
			var/datum/bottler_recipe/recipe = new type
			if(recipe.result) // Ignore recipe subtypes that lack a result
				available_recipes += recipe
				acceptable_items |= recipe.obj_1_item
				acceptable_items |= recipe.obj_2_item
				acceptable_items |= recipe.obj_3_item
			else
				qdel(recipe)

/obj/machinery/bottler/attackby(obj/item/O, mob/user, params)
	if(iswrench(O))		//This being before the canUnequip check allows borgs to (un)wrench bottlers in case they need move them to fix stuff
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class='alert'>[src] can now be moved.</span>")
		else
			anchored = 1
			to_chat(user, "<span class='alert'>[src] is now secured.</span>")
		return 1
	if(!user.canUnEquip(O, 0))
		to_chat(user, "<span class='warning'>[O] is stuck to your hand, you can't seem to put it down!</span>")
		return 0
	if(is_type_in_list(O,acceptable_items))
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
			var/obj/item/weapon/reagent_containers/food/snacks/S = O
			user.unEquip(S)
			if(S.reagents && !S.reagents.total_volume)		//This prevents us from using empty foods, should one occur due to some sort of error
				to_chat(user, "<span class='warning'>[S] is gone, oh no!</span>")
				qdel(S)			//Delete the food object because it is useless even as food due to the lack of reagents
			else
				insert_item(S, user)
			return 1
		else if(istype(O, /obj/item/weapon/reagent_containers/food/drinks/cans))
			var/obj/item/weapon/reagent_containers/food/drinks/cans/C = O
			if(C.reagents)
				if(C.canopened && C.reagents.total_volume)		//This prevents us from using opened cans that still have something in them
					to_chat(user, "<span class='warning'>Only unopened cans and bottles can be processed to ensure product integrity.</span>")
					return 0
				user.unEquip(C)
				if(!C.reagents.total_volume)		//Empty cans get recycled, even if they have somehow remained unopened due to some sort of error
					recycle_container(C)
				else								//Full cans that are unopened get inserted for processing as ingredients
					insert_item(C, user)
			return 1
		else
			user.unEquip(O)
			insert_item(O, user)
			return 1
	else if(istype(O, /obj/item/trash/can))			//Crushed cans (and bottles) are returnable still
		var/obj/item/trash/can/C = O
		user.unEquip(C)
		recycle_container(C)
		return 1
	else if(istype(O, /obj/item/stack/sheet))		//Sheets of materials can replenish the machine's supply of drink containers (when people inevitably don't return them)
		var/obj/item/stack/sheet/S = O
		user.unEquip(S)
		process_sheets(S)
		return 1
	else		//If it doesn't qualify in the above checks, we don't want it. Inform the person so they (ideally) stop trying to put the nuke disc in.
		to_chat(user, "<span class='warning'>You aren't sure this is able to be processed by the machine.</span>")
		return 0
	//..()

/obj/machinery/bottler/proc/insert_item(obj/item/O, mob/user)
	if(!O || !user)
		return
	if(obj_1 && obj_2 && obj_3)
		to_chat(user, "<span class='warning'>[src] is full, please remove or process the contents first.</span>")
		return
	var/slot_inserted = 0
	if(!obj_1)
		slot_inserted = 1
		obj_1 = O
	else if(!obj_2)
		slot_inserted = 2
		obj_2 = O
	else if(!obj_3)
		slot_inserted = 3
		obj_3 = O

	if(!slot_inserted)
		to_chat(user, "<span class='warning'>Something went wrong and the machine spits out [O].</span>")
		O.forceMove(loc)
	else
		to_chat(user, "<span class='notice'>You load [O] into the [slot_inserted]\th ingredient tray.</span>")
		O.forceMove(src)
	updateUsrDialog()

/obj/machinery/bottler/proc/eject_items(var/slot = 4)
	var/obj/item/O = null
	if(obj_1 && (slot == 1 || slot == 4))
		O = obj_1
		O.forceMove(loc)
		obj_1 = null
	if(obj_2 && (slot == 2 || slot == 4))
		O = obj_2
		O.forceMove(loc)
		obj_2 = null
	if(obj_3 && (slot == 3 || slot == 4))
		O = obj_3
		O.forceMove(loc)
		obj_3 = null
	if(slot == 4)
		visible_message("<span class='notice'>[src] beeps as it ejects the contents of all the ingredient trays.</span>")
	else
		visible_message("<span class='notice'>[src] beeps as it ejects [O.name] from the [slot]\th ingredient tray.</span>")
	updateUsrDialog()

/obj/machinery/bottler/proc/recycle_container(obj/item/O)
	if(!O)
		return
	var/recycled = 0
	if(istype(O, /obj/item/trash/can))
		var/obj/item/trash/can/C = O
		if(C.is_glass && glass_bottles < 10)
			glass_bottles++
			recycled = 1
		else if(C.is_plastic && plastic_bottles < 20)
			plastic_bottles++
			recycled = 1
		else if(cans < 25)
			cans++
			recycled = 1
	else if(istype(O, /obj/item/weapon/reagent_containers/food/drinks/cans))
		var/obj/item/weapon/reagent_containers/food/drinks/cans/C = O
		if(C.is_glass && glass_bottles < 10)
			glass_bottles++
			recycled = 1
		else if(C.is_plastic && plastic_bottles < 20)
			plastic_bottles++
			recycled = 1
		else if(cans < 25)
			cans++
			recycled = 1
	if(recycled)
		visible_message("<span class='notice'>[src] whirs briefly as it prepares the container for reuse.</span>")
		qdel(O)
		updateUsrDialog()
	else
		visible_message("<span class='warning'>[src] cannot store any more cans at this time. Please fill some before recycling more.</span>")
		O.forceMove(loc)

/obj/machinery/bottler/proc/process_sheets(obj/item/stack/sheet/S)
	if(!S)
		return
	S.forceMove(loc)
	//Glass sheets for glass bottles (1 bottle per sheet)
	if(istype(S, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = S
		if(glass_bottles < 10)
			var/sheets_to_use = min((10 - glass_bottles), G.amount)
			visible_message("<span class='notice'>[src] shudders as it converts [sheets_to_use] [G.singular_name]\s into new bottles.</span>")
			glass_bottles += sheets_to_use
			glass_bottles = min(glass_bottles, 10)
			G.use(sheets_to_use)
		else
			visible_message("<span class='warning'>[src] rejects the [G] because it already is fully stocked with glass bottles.</span>")
			return
	//Plastic sheets for plastic bottles (2 bottles per sheet)
	else if(istype(S, /obj/item/stack/sheet/mineral/plastic))
		var/obj/item/stack/sheet/mineral/plastic/P = S
		if(plastic_bottles < 20)
			var/bottles_missing = 20 - plastic_bottles
			var/sheets_needed = round(bottles_missing / 2, 1)
			if(bottles_missing % 2)		//A bit wasteful, but we'll always try to completely refill the supply even if it means throwing away excess material
				sheets_needed += 1
			var/sheets_to_use = min(sheets_needed, P.amount)
			visible_message("<span class='notice'>[src] shudders as it converts [sheets_to_use] [P.singular_name]\s into new bottles.</span>")
			plastic_bottles += sheets_to_use * 2
			plastic_bottles = min(plastic_bottles, 20)
			P.use(sheets_to_use)
		else
			visible_message("<span class='warning'>[src] rejects the [P] because it already is fully stocked with plastic bottles.</span>")
			return
	//Metal sheets for cans (5 cans per sheet)
	else if(istype(S, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = S
		if(cans < 25)
			var/cans_missing = 25 - cans
			var/sheets_needed = round(cans_missing / 5, 1)
			if(cans_missing % 5)		//A bit wasteful, but we'll always try to completely refill the supply even if it means throwing away excess material
				sheets_needed += 1
			var/sheets_to_use = min(sheets_needed, M.amount)
			visible_message("<span class='notice'>[src] shudders as it converts [sheets_to_use] [M.singular_name]\s into new cans.</span>")
			cans += sheets_to_use * 5
			cans = min(cans, 25)
			M.use(sheets_to_use)
		else
			visible_message("<span class='warning'>[src] rejects the [M] because it already is fully stocked with metal cans.</span>")
			return
	else
		visible_message("<span class='warning'>[src] rejects the unusable materials.</span>")
		return
	updateUsrDialog()

/obj/machinery/bottler/proc/select_recipe()
	for(var/datum/bottler_recipe/recipe in available_recipes)
		var/number_matches = 0
		if(istype(obj_1, recipe.obj_1_item))
			if(istype(obj_1, /obj/item/weapon/reagent_containers/food/snacks/grown))
				var/obj/item/weapon/reagent_containers/food/snacks/grown/G = obj_1
				if(G.seed && G.seed.kitchen_tag == recipe.obj_1_kitchen_tag)
					number_matches++
			else
				number_matches++
		if(istype(obj_2, recipe.obj_2_item))
			if(istype(obj_2, /obj/item/weapon/reagent_containers/food/snacks/grown))
				var/obj/item/weapon/reagent_containers/food/snacks/grown/G = obj_2
				if(G.seed && G.seed.kitchen_tag == recipe.obj_2_kitchen_tag)
					number_matches++
			else
				number_matches++
		if(istype(obj_3, recipe.obj_3_item))
			if(istype(obj_3, /obj/item/weapon/reagent_containers/food/snacks/grown))
				var/obj/item/weapon/reagent_containers/food/snacks/grown/G = obj_3
				if(G.seed && G.seed.kitchen_tag == recipe.obj_3_kitchen_tag)
					number_matches++
			else
				number_matches++
		if(number_matches == 3)
			return recipe
	return null

/obj/machinery/bottler/proc/dispense_empty_container(container = 0)
	switch(container)
		if(1)	//glass bottle
			if(glass_bottles > 0)
				new /obj/item/weapon/reagent_containers/food/drinks/cans/bottler/glass_bottle(loc)
				glass_bottles--
		if(2)	//plastic bottle
			if(plastic_bottles > 0)
				new /obj/item/weapon/reagent_containers/food/drinks/cans/bottler/plastic_bottle(loc)
				plastic_bottles--
		if(3)	//can
			if(cans > 0)
				new /obj/item/weapon/reagent_containers/food/drinks/cans/bottler/metal_can(loc)
				cans--

/obj/machinery/bottler/proc/process_ingredients(container = 0)
	//stop if we have ZERO ingredients (what would you process?)
	if(!obj_1 && !obj_2 && !obj_3)
		visible_message("<span class='warning'>There are no ingredients to process! Please insert some first.</span>")
		return
	//prep a container
	var/obj/item/weapon/reagent_containers/food/drinks/cans/drink_container
	var/container_type = ""
	switch(container)
		if(1)	//glass bottle
			container_type = "Glass Bottle"
			if(glass_bottles > 0)
				drink_container = new /obj/item/weapon/reagent_containers/food/drinks/cans/bottler/glass_bottle()
				glass_bottles--
		if(2)	//plastic bottle
			container_type = "Plastic Bottle"
			if(plastic_bottles > 0)
				drink_container = new /obj/item/weapon/reagent_containers/food/drinks/cans/bottler/plastic_bottle()
				plastic_bottles--
		if(3)	//can
			container_type = "Can"
			if(cans > 0)
				drink_container = new /obj/item/weapon/reagent_containers/food/drinks/cans/bottler/metal_can()
				cans--
	if(!drink_container)
		if(container_type)
			visible_message("<span class='warning'>Error 503: Out of [container_type]s.</span>")
		else
			visible_message("<span class='warning'>Error 404: Drink Container Not Found.</span>")
		return
	//select and process a recipe based on inserted ingredients
	visible_message("<span class='notice'>[src] hums as it processes the ingredients...</span>")
	bottling = 1
	var/datum/bottler_recipe/recipe_to_use = select_recipe()
	if(!recipe_to_use)
		//bad recipe, ruins the drink
		var/contents = pick("thick goop", "pungent sludge", "unspeakable slurry", "gross-looking concoction", "eldritch abomination of liquids")
		visible_message("<span class='warning'>The [container_type] fills with \an [contents]...</span>")
		drink_container.reagents.add_reagent(pick("????", "toxic_slurry", "meatslurry", "glowing_slury", "fishwater"), pick(30, 50))
		drink_container.name = "Liquid Mistakes"
		drink_container.desc = "WARNING: CONTENTS MAY BE AWFUL, DRINK AT OWN RISK."
	else
		//good recipe, make it
		visible_message("<span class='notice'>The [container_type] fills with a delicious-looking beverage!</span>")
		drink_container.reagents.add_reagent(recipe_to_use.result, 50)
		drink_container.name = "[recipe_to_use.name]"
		drink_container.desc = "[recipe_to_use.description]"
	flick("bottler_on", src)
	spawn(45)
		qdel(obj_1)
		qdel(obj_2)
		qdel(obj_3)
		//just in case
		obj_1 = null
		obj_2 = null
		obj_3 = null
		bottling = 0
		drink_container.forceMove(loc)
		updateUsrDialog()

/obj/machinery/bottler/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/bottler/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/bottler/attack_hand(mob/user)
	if(stat & BROKEN)
		return
	interact(user)

/obj/machinery/bottler/interact(mob/user)
	user.set_machine(src)
	//html ahoy
	var/dat = ""
	if(bottling)
		dat = "<h2>Bottling in process, please wait...</h2>"
	else
		dat += "<table border='1' style='width:75%'>"
		dat += "<tr>"
		dat += "<th colspan='3'>Containers:</th>"
		dat += "</tr>"
		dat += "<tr>"
		dat += "<td>Glass Bottles: [glass_bottles]</td>"
		dat += "<td>Plastic Bottles: [plastic_bottles]</td>"
		dat += "<td>Metal Cans: [cans]</td>"
		dat += "</tr>"
		dat += "<tr>"
		if(glass_bottles > 0)
			dat += "<td><A href='?src=\ref[src];dispense=1'>Dispense</a></td>"
		else
			dat += "<td>Out of stock</td>"
		if(plastic_bottles > 0)
			dat += "<td><A href='?src=\ref[src];dispense=2'>Dispense</a></td>"
		else
			dat += "<td>Out of stock</td>"
		if(cans > 0)
			dat += "<td><A href='?src=\ref[src];dispense=3'>Dispense</a></td>"
		else
			dat += "<td>Out of stock</td>"
		dat += "</tr>"
		dat += "</table>"
		dat += "<hr>"
		dat += "<table border='1' style='width:75%'>"
		dat += "<tr>"
		dat += "<th colspan='4'>Ingredient Tray Contents:</th>"
		dat += "</tr>"
		dat += "<tr>"
		if(obj_1)
			dat += "<td>[bicon(obj_1)]<br>[obj_1.name]</td>"
		else
			dat += "<td>Tray Empty</td>"
		if(obj_2)
			dat += "<td>[bicon(obj_2)]<br>[obj_2.name]</td>"
		else
			dat += "<td>Tray Empty</td>"
		if(obj_3)
			dat += "<td>[bicon(obj_3)]<br>[obj_3.name]</td>"
		else
			dat += "<td>Tray Empty</td>"
		if(obj_1 && obj_2 && obj_3)
			dat += "<td><A href='?src=\ref[src];process=1'>Process Ingredients</a></td>"
		else
			dat += "<td>Insufficient Ingredients</td>"
		dat += "</tr>"
		dat += "<tr>"
		if(obj_1)
			dat += "<td><A href='?src=\ref[src];eject=1'>Eject</a></td>"
		else
			dat += "<td>N/A</td>"
		if(obj_2)
			dat += "<td><A href='?src=\ref[src];eject=2'>Eject</a></td>"
		else
			dat += "<td>N/A</td>"
		if(obj_3)
			dat += "<td><A href='?src=\ref[src];eject=3'>Eject</a></td>"
		else
			dat += "<td>N/A</td>"
		dat += "<td><A href='?src=\ref[src];eject=4'>Eject All</a></td>"
		dat += "</tr>"
		dat += "</table>"
		dat += "<hr>"
		dat += "<p>Insert three ingredients and press process to create a beverage. You will be able to select a container for the beverage before processing begins.</p>"
		dat += "<p>Inserting empty bottles and cans, as well as sheets of glass, plastic, or metal will restock the appropriate container supply.</p>"
	var/datum/browser/popup = new(user, "bottler", "Bottler Menu", 575, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/bottler/Topic(href, href_list)
	if(..())
		return 1

	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["process"])
		var/list/choices = list("Glass Bottle" = 1, "Plastic Bottle" = 2, "Metal Can" = 3, "Cancel" = 4)
		var/selection = input("Select a container for your beverage.", "Container") in choices
		selection = choices[selection]
		if(selection == 4)
				//they chose cancel
			return
		else
			process_ingredients(selection)

	if(href_list["eject"])
		var/slot = text2num(href_list["eject"])
		eject_items(slot)

	if(href_list["dispense"])
		var/container = text2num(href_list["dispense"])
		dispense_empty_container(container)

	updateUsrDialog()
	return

/obj/machinery/bottler/update_icon()
	if(stat & BROKEN)
		icon_state = "bottler_broken"
	else if(bottling)
		icon_state = "bottler_on"
	else
		icon_state = "bottler_off"