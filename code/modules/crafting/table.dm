#define TABLECRAFT_MAX_ITEMS 30

/obj/structure/table
	var/list/table_contents = list()

/obj/structure/table/MouseDrop(atom/over)
	if(over != usr)
		return
	interact(usr)

/obj/structure/table/proc/check_contents(datum/table_recipe/R)
	check_table()
	main_loop:
		if(R.fruit)
			for(var/A in R.fruit)
				for(var/B in table_contents)
					if(B == A)
						if(table_contents[B] >= R.fruit[A])
							continue main_loop
					return 0
		for(var/A in R.reqs)
			for(var/B in table_contents)
				if(ispath(B, A))
					if(table_contents[B] >= R.reqs[A])
						continue main_loop
			return 0
	for(var/A in R.chem_catalists)
		if(table_contents[A] < R.chem_catalists[A])
			return 0
	return 1

/obj/structure/table/proc/check_table()
	table_contents = list()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			table_contents[I.type] += S.amount
		else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = I
			if(G.seed && G.seed.kitchen_tag)
				table_contents[G.seed.kitchen_tag] += 1
		else
			if(istype(I, /obj/item/weapon/reagent_containers))
				var/obj/item/weapon/reagent_containers/RC = I
				if(RC.flags & OPENCONTAINER)
					for(var/datum/reagent/A in RC.reagents.reagent_list)
						table_contents[A.type] += A.volume
			table_contents[I.type] += 1

/obj/structure/table/proc/check_tools(mob/user, datum/table_recipe/R)
	if(!R.tools.len)
		return 1
	var/list/possible_tools = list()
	for(var/obj/item/I in user.contents)
		if(istype(I, /obj/item/weapon/storage))
			for(var/obj/item/SI in I.contents)
				possible_tools += SI.type
		else
			possible_tools += I.type
	possible_tools += table_contents
	var/i = R.tools.len
	var/I
	for(var/A in R.tools)
		I = possible_tools.Find(A)
		if(I)
			possible_tools.Cut(I, I+1)
			i--
		else
			break
	return !i

/obj/structure/table/proc/construct_item(mob/user, datum/table_recipe/R)
	check_table()
	if(check_contents(R) && check_tools(user, R))
		if(do_after(user, R.time, target = src))
			if(!check_contents(R) || !check_tools(user, R))
				return 0
			var/atom/movable/I = new R.result (loc)
			var/list/parts = del_reqs(R, I)
			for(var/A in parts)
				if(istype(A, /obj/item))
					var/atom/movable/B = A
					B.loc = I
				else
					if(!I.reagents)
						I.reagents = new /datum/reagents()
					I.reagents.reagent_list.Add(A)
			I.CheckParts()
			R.AdjustChems(I)
			return 1
	return 0

/obj/structure/table/proc/del_reqs(datum/table_recipe/R, atom/movable/resultobject)
	var/list/Deletion = list()
	var/amt
	var/reagenttransfer = 0
	if(istype(resultobject,/obj/item/weapon/reagent_containers))
		reagenttransfer = 1
	if(R.fruit)
		for(var/A in R.fruit)
			amt = R.fruit[A]
			fruit_loop:	//ha
				for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in loc)
					if(G.seed && G.seed.kitchen_tag && (G.seed.kitchen_tag == A))
						amt--
						G.loc = null	//remove it from the table loc so that we don't locate the same fruit every time
						if(reagenttransfer)
							G.reagents.trans_to(resultobject, G.reagents.total_volume)
						qdel(G)
					if(amt <= 0)
						break fruit_loop
	for(var/A in R.reqs)
		amt = R.reqs[A]
		if(ispath(A, /obj/item/stack))
			var/obj/item/stack/S
			stack_loop:
				for(var/B in table_contents)
					if(ispath(B, A))
						while(amt > 0)
							S = locate(B) in loc
							if(S.amount >= amt)
								S.use(amt)
								break stack_loop
							else
								amt -= S.amount
								qdel(S)
		else if(ispath(A, /obj/item))
			var/obj/item/I
			item_loop:
				for(var/B in table_contents)
					if(ispath(B, A))
						while(amt > 0)
							I = locate(B) in loc
							Deletion.Add(I)
							I.loc = null //remove it from the table loc so that we don't locate the same item every time (will be relocated inside the crafted item in construct_item())
							amt--
							if(reagenttransfer && istype(I,/obj/item/weapon/reagent_containers))
								var/obj/item/weapon/reagent_containers/RC = I
								RC.reagents.trans_to(resultobject, RC.reagents.total_volume)
						break item_loop
		else
			var/datum/reagent/RG = new A
			reagent_loop:
				for(var/B in table_contents)
					if(ispath(B, /obj/item/weapon/reagent_containers))
						var/obj/item/RC = locate(B) in loc
						if(RC.reagents.has_reagent(RG.id, amt))
							if(reagenttransfer)
								RC.reagents.trans_id_to(resultobject,RG.id, amt)
							else
								RC.reagents.remove_reagent(RG.id, amt)
							RG.volume = amt
							Deletion.Add(RG)
							break reagent_loop
						else if(RC.reagents.has_reagent(RG.id))
							Deletion.Add(RG)
							RG.volume += RC.reagents.get_reagent_amount(RG.id)
							amt -= RC.reagents.get_reagent_amount(RG.id)
							if(reagenttransfer)
								RC.reagents.trans_id_to(resultobject,RG.id, RG.volume)
							else
								RC.reagents.del_reagent(RG.id)

	var/list/partlist = list(R.parts.len)
	for(var/M in R.parts)
		partlist[M] = R.parts[M]
	deletion_loop:
		for(var/B in Deletion)
			for(var/A in R.parts)
				if(istype(B, A))
					if(partlist[A] > 0) //do we still need a part like that?
						partlist[A] -= 1
						continue deletion_loop
			Deletion.Remove(B)
			qdel(B)

	return Deletion

/obj/structure/table/interact(mob/user)
	if(user.stat || user.lying || !Adjacent(user))
		return
	check_table()
	if(!table_contents.len)
		return
	user.face_atom(src)
	var/dat = "<h3>Crafting menu</h3>"
	dat += "<div class='statusDisplay'>"
	if(busy)
		dat += "Crafting in progress...</div>"
	else
		for(var/datum/table_recipe/R in table_recipes)
			if(check_contents(R))
				dat += "<A href='?src=\ref[src];make=\ref[R]'>[R.name]</A><BR>"
		dat += "</div>"

	var/datum/browser/popup = new(user, "table", "Table", 300, 300)
	popup.set_content(dat)
	popup.open()
	return

/obj/structure/table/Topic(href, href_list)
	if(usr.stat || !Adjacent(usr) || usr.lying)
		return
	if(href_list["make"])
		if(!check_table_space())
			usr << "<span class ='warning'>The table is too crowded.</span>"
			return
		var/datum/table_recipe/TR = locate(href_list["make"])
		busy = 1
		interact(usr)
		if(construct_item(usr, TR))
			usr << "<span class='notice'>[TR.name] constructed.</span>"
		else
			usr << "<span class ='warning'>Construction failed.</span>"
		busy = 0
		interact(usr)

/obj/structure/table/proc/check_table_space()
	var/Item_amount = 0
	for(var/obj/item/I in loc)
		Item_amount++
	if(Item_amount <= TABLECRAFT_MAX_ITEMS) //is the table crowded?
		return 1

 #undef TABLECRAFT_MAX_ITEMS