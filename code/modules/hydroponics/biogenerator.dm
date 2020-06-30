/obj/machinery/biogenerator
	name = "Biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/processing = 0
	var/obj/item/reagent_containers/glass/beaker = null
	var/points = 0
	var/menustat = "menu"
	var/efficiency = 0
	var/productivity = 0
	var/max_items = 40
	var/datum/research/files
	var/list/show_categories = list("Food", "Botany Chemicals", "Organic Materials", "Leather and Cloth")
	var/list/timesFiveCategories = list("Food", "Botany Chemicals", "Organic Materials")

/obj/machinery/biogenerator/New()
	..()
	files = new /datum/research/biogenerator(src)
	create_reagents(1000)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/biogenerator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/biogenerator/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(files)
	return ..()

/obj/machinery/biogenerator/ex_act(severity)
	if(beaker)
		beaker.ex_act(severity)
	..()

/obj/machinery/biogenerator/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_icon()
		updateUsrDialog()

/obj/machinery/biogenerator/RefreshParts()
	var/E = 0
	var/P = 0
	var/max_storage = 40
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		P += B.rating
		max_storage = 40 * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
	productivity = P
	max_items = max_storage

/obj/machinery/biogenerator/on_reagent_change()			//When the reagents change, change the icon as well.
	update_icon()

/obj/machinery/biogenerator/update_icon()
	if(panel_open)
		icon_state = "biogen-empty-o"
	else if(!beaker)
		icon_state = "biogen-empty"
	else if(!processing)
		icon_state = "biogen-stand"
	else
		icon_state = "biogen-work"
	return

/obj/machinery/biogenerator/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is currently processing.</span>")
		return

	if(default_deconstruction_screwdriver(user, "biogen-empty-o", "biogen-empty", O))
		if(beaker)
			var/obj/item/reagent_containers/glass/B = beaker
			B.forceMove(loc)
			beaker = null
		update_icon()
		return

	if(exchange_parts(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(istype(O, /obj/item/reagent_containers/glass))
		. = 1 //no afterattack
		if(!panel_open)
			if(beaker)
				to_chat(user, "<span class='warning'>A container is already loaded into the machine.</span>")
			else
				if(!user.drop_item())
					return
				O.forceMove(src)
				beaker = O
				to_chat(user, "<span class='notice'>You add the container to the machine.</span>")
				update_icon()
				updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
		return

	else if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/PB = O
		var/i = 0
		for(var/obj/item/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is already full! Activate it.</span>")
		else
			for(var/obj/item/reagent_containers/food/snacks/grown/G in PB.contents)
				if(i >= max_items)
					break
				PB.remove_from_storage(G, src)
				i++
			if(i<max_items)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator.</span>")
			else if(PB.contents.len == 0)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator, filling it to its capacity.</span>")
			else
				to_chat(user, "<span class='info'>You fill the biogenerator to its capacity.</span>")
		return 1 //no afterattack

	else if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		var/i = 0
		for(var/obj/item/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is full! Activate it.</span>")
		else
			user.unEquip(O)
			O.forceMove(src)
			to_chat(user, "<span class='info'>You put [O.name] in [name]</span>")
		return 1 //no afterattack
	else if (istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load [O] in [src]...",
			"You begin to load a design from [O]...",
			"You hear the chatter of a floppy drive.")
		processing = 1
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 10, target = src))
			files.AddDesign2Known(D.blueprint)
		processing = 0
		return 1
	else
		to_chat(user, "<span class='warning'>You cannot put this in [name]!</span>")

/obj/machinery/biogenerator/interact(mob/user)
	if(stat & BROKEN || panel_open)
		return
	user.set_machine(src)
	add_fingerprint(user)
	var/dat
	if(processing)
		dat += "<div class='statusDisplay'>Biogenerator is processing! Please wait...</div><BR>"
	else
		switch(menustat)
			if("nopoints")
				dat += "<div class='statusDisplay'>You do not have enough biomass to create products.<BR>Please, put growns into reactor and activate it.</div>"
				menustat = "menu"
			if("complete")
				dat += "<div class='statusDisplay'>Operation complete.</div>"
				menustat = "menu"
			if("void")
				dat += "<div class='statusDisplay'>Error: No growns inside.<BR>Please, put growns into reactor.</div>"
				menustat = "menu"
			if("nobeakerspace")
				dat += "<div class='statusDisplay'>Not enough space left in container. Unable to create product.</div>"
				menustat = "menu"
		if(beaker)
			var/categories = show_categories.Copy()
			for(var/V in categories)
				categories[V] = list()
			for(var/V in files.known_designs)
				var/datum/design/D = files.known_designs[V]
				for(var/C in categories)
					if(C in D.category)
						categories[C] += D

			dat += "<div class='statusDisplay'>Biomass: [points] units.</div><BR>"
			dat += "<A href='?src=[src.UID()];activate=1'>Activate</A><A href='?src=[src.UID()];detach=1'>Detach Container</A>"
			for(var/cat in categories)
				dat += "<h3>[cat]:</h3>"
				dat += "<div class='statusDisplay'>"
				for(var/V in categories[cat])
					var/datum/design/D = V
					dat += "[D.name]: <A href='?src=[src.UID()];create=[D.UID()];amount=1'>Make</A>"
					if(cat in timesFiveCategories)
						dat += "<A href='?src=[src.UID()];create=[D.UID()];amount=5'>x5</A>"
					if(ispath(D.build_path, /obj/item/stack))
						dat += "<A href='?src=[src.UID()];create=[D.UID()];amount=10'>x10</A>"
					dat += "([D.materials[MAT_BIOMASS]/efficiency])<br>"
				dat += "</div>"
		else
			dat += "<div class='statusDisplay'>No container inside, please insert container.</div>"

	var/datum/browser/popup = new(user, "biogen", name, 350, 520)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/biogenerator/attack_hand(mob/user)
	interact(user)

/obj/machinery/biogenerator/attack_ghost(mob/user)
	interact(user)

/obj/machinery/biogenerator/proc/activate()
	if(usr.stat != 0)
		return
	if(stat != 0) //NOPOWER etc
		return
	if(processing)
		to_chat(usr, "<span class='warning'>The biogenerator is in the process of working.</span>")
		return
	var/S = 0
	for(var/obj/item/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		if(I.reagents.get_reagent_amount("nutriment")+I.reagents.get_reagent_amount("plantmatter") < 0.1)
			points += 1*productivity
		else
			points += (I.reagents.get_reagent_amount("nutriment")+I.reagents.get_reagent_amount("plantmatter"))*10*productivity
		qdel(I)
	if(S)
		processing = 1
		update_icon()
		updateUsrDialog()
		playsound(loc, 'sound/machines/blender.ogg', 50, 1)
		use_power(S*30)
		sleep(S+15/productivity)
		processing = 0
		update_icon()
	else
		menustat = "void"
	return

/obj/machinery/biogenerator/proc/check_cost(list/materials, multiplier = 1, remove_points = 1)
	if(materials.len != 1 || materials[1] != MAT_BIOMASS)
		return 0
	if (materials[MAT_BIOMASS]*multiplier/efficiency > points)
		menustat = "nopoints"
		return 0
	else
		if(remove_points)
			points -= materials[MAT_BIOMASS]*multiplier/efficiency
		update_icon()
		updateUsrDialog()
		return 1

/obj/machinery/biogenerator/proc/check_container_volume(list/reagents, multiplier = 1)
	var/sum_reagents = 0
	for(var/R in reagents)
		sum_reagents += reagents[R]
	sum_reagents *= multiplier

	if(beaker.reagents.total_volume + sum_reagents > beaker.reagents.maximum_volume)
		menustat = "nobeakerspace"
		return 0

	return 1

/obj/machinery/biogenerator/proc/create_product(datum/design/D, amount)
	if(!beaker || !loc)
		return 0

	if(ispath(D.build_path, /obj/item/stack))
		if(!check_container_volume(D.make_reagents, amount))
			return 0
		if(!check_cost(D.materials, amount))
			return 0

		var/obj/item/stack/product = new D.build_path(loc)
		product.amount = amount
		for(var/R in D.make_reagents)
			beaker.reagents.add_reagent(R, D.make_reagents[R]*amount)
	else
		var/i = amount
		while(i > 0)
			if(!check_container_volume(D.make_reagents))
				return .
			if(!check_cost(D.materials))
				return .
			if(D.build_path)
				new D.build_path(loc)
			for(var/R in D.make_reagents)
				beaker.reagents.add_reagent(R, D.make_reagents[R])
			. = 1
			--i

	menustat = "complete"
	update_icon()
	return .

/obj/machinery/biogenerator/proc/detach()
	if(beaker)
		beaker.forceMove(loc)
		beaker = null
		update_icon()

/obj/machinery/biogenerator/Topic(href, href_list)
	if(..() || panel_open)
		return 1

	usr.set_machine(src)

	if(href_list["activate"])
		activate()
		updateUsrDialog()

	else if(href_list["detach"])
		detach()
		updateUsrDialog()

	else if(href_list["create"])
		var/amount = (text2num(href_list["amount"]))
		//Can't be outside these (if you change this keep a sane limit)
		amount = clamp(amount, 1, 10)
		var/datum/design/D = locate(href_list["create"])
		create_product(D, amount)
		updateUsrDialog()

	else if(href_list["menu"])
		menustat = "menu"
		updateUsrDialog()
