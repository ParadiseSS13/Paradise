/obj/machinery/biogenerator
	name = "biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 40
	var/processing = 0
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/points = 0
	var/in_beaker = 1
	var/menustat = "menu"
	var/efficiency = 0
	var/productivity = 0
	var/max_items = 40

/obj/machinery/biogenerator/New()
	..()
	create_reagents(1000)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/biogenerator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/biogenerator/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/biogenerator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/biogenerator/RefreshParts()
	var/E = 0
	var/P = 0
	var/max_storage = 40
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		P += B.rating
		max_storage = 40 * B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
	productivity = P
	max_items = max_storage

/obj/machinery/biogenerator/on_reagent_change()			//When the reagents change, change the icon as well.
		update_icon()

/obj/machinery/biogenerator/update_icon()
	if(panel_open)
		icon_state = "biogen-empty-o"
	else if(!src.beaker)
		icon_state = "biogen-empty"
	else if(!src.processing)
		icon_state = "biogen-stand"
	else
		icon_state = "biogen-work"
	return

/obj/machinery/biogenerator/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/weapon/reagent_containers/glass) && !panel_open)
		if(beaker)
			to_chat(user, "<span class='warning'>A container is already loaded into the machine.</span>")
			return
		else
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>\The [O] is stuck to you!</span>")
				return
			O.forceMove(src)
			beaker = O
			to_chat(user, "<span class='notice'>You add the container to the machine.</span>")
			updateUsrDialog()
			update_icon()
			return

	if(!processing)
		if(default_deconstruction_screwdriver(user, "biogen-empty-o", "biogen-empty", O))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.forceMove(loc)
				beaker = null
			return

	if(exchange_parts(user, O))
		return

	else if(istype(O, /obj/item/weapon/crowbar))
	else if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
	else if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is currently processing.</span>")
	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is already full! Activate it.</span>")
		else
			for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
				if(i >= max_items)
					break
				G.forceMove(src)
				i++
			if(i < max_items)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator.</span>")
			else if(O.contents.len == 0)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator, filling it to its capacity.</span>")
			else
				to_chat(user, "<span class='info'>You fill the biogenerator to its capacity.</span>")

	else if(!istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown) && !istype(O, /obj/item/weapon/crowbar))
		to_chat(user, "<span class='warning'>You can not put this in [src.name]</span>")
	else
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is full! Activate it.</span>")
		else
			user.unEquip(O)
			O.forceMove(src)
			to_chat(user, "<span class='info'>You put [O.name] in [src.name]</span>")


	default_deconstruction_crowbar(O)

	update_icon()
	return

/obj/machinery/biogenerator/interact(mob/user as mob)
	if(stat & BROKEN || panel_open)
		return
	user.set_machine(src)
	var/dat
	if(processing)
		dat += "<div class='statusDisplay'>Biogenerator is processing! Please wait...</div><BR>"
	else
		switch(menustat)
			if("nopoints")
				dat += "<div class='statusDisplay'>You do not have sufficient biomass to create products.<BR>Please put growns into the reactor and activate it.</div>"
				menustat = "menu"
			if("complete")
				dat += "<div class='statusDisplay'>Operation complete.</div>"
				menustat = "menu"
			if("void")
				dat += "<div class='statusDisplay'>Error: No growns inside.<BR>Please put growns into reactor.</div>"
				menustat = "menu"
			if("nobeakerspace")
				dat += "<div class='statusDisplay'>Not enough space left in container. Unable to create product.</div>"
				menustat = "menu"
		if(beaker)
			dat += "<div class='statusDisplay'>Biomass: [points] units.</div><BR>"
			dat += "<A href='?src=[UID()];activate=1'>Activate</A><A href='?src=[UID()];detach=1'>Detach Container</A><BR>"
			dat += "Put fertilizer in: <A href='?src=[UID()];inbeaker=1'>[in_beaker ? "Beaker" : "Bottle"]</A>"
			dat += "<h3>Food:</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "10 milk: <A href='?src=[UID()];create=milk;amount=1'>Make</A> ([20/efficiency])<BR>"
			dat += "10 cream: <A href='?src=[UID()];create=cream;amount=1'>Make</A> ([30/efficiency])<BR>"
			dat += "Monkey cube: <A href='?src=[UID()];create=meat;amount=1'>Make</A> ([250/efficiency])"
			dat += "</div>"
			dat += "<h3>Nutrients:</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "E-Z-Nutrient: <A href='?src=[UID()];create=ez;amount=1'>Make</A><A href='?src=[UID()];create=ez;amount=5'>x5</A> ([10/efficiency])<BR>"
			dat += "Left 4 Zed: <A href='?src=[UID()];create=l4z;amount=1'>Make</A><A href='?src=[UID()];create=l4z;amount=5'>x5</A> ([20/efficiency])<BR>"
			dat += "Robust Harvest: <A href='?src=[UID()];create=rh;amount=1'>Make</A><A href='?src=[UID()];create=rh;amount=5'>x5</A> ([25/efficiency])<BR>"
			dat += "</div>"
			dat += "<h3>Leather:</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "Wallet: <A href='?src=[UID()];create=wallet;amount=1'>Make</A> ([100/efficiency])<BR>"
			dat += "Book bag: <A href='?src=[UID()];create=bkbag;amount=1'>Make</A> ([200/efficiency])<BR>"
			dat += "Plant bag: <A href='?src=[UID()];create=ptbag;amount=1'>Make</A> ([200/efficiency])<BR>"
			dat += "Rag: <A href='?src=[UID()];create=rag;amount=1'>Make</A> ([200/efficiency])<BR>"
			dat += "Mining satchel: <A href='?src=[UID()];create=mnbag;amount=1'>Make</A> ([200/efficiency])<BR>"
			dat += "Chemistry bag: <A href='?src=[UID()];create=chbag;amount=1'>Make</A> ([200/efficiency])<BR>"
			dat += "Botanical gloves: <A href='?src=[UID()];create=gloves;amount=1'>Make</A> ([250/efficiency])<BR>"
			dat += "Leather Satchel: <A href='?src=[UID()];create=satchel;amount=1'>Make</A> ([400/efficiency])<BR>"
			dat += "Cash Bag: <A href='?src=[UID()];create=cashbag;amount=1'>Make</A> ([400/efficiency])<BR>"
			dat += "Leather Jacket: <A href='?src=[UID()];create=jacket;amount=1'>Make</A> ([500/efficiency])<BR>"
			dat += "</div>"
			dat += "<h3>Belts</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "Utility belt: <A href='?src=[UID()];create=tbelt;amount=1'>Make</A> ([300/efficiency])<BR>"
			dat += "Botanist belt: <A href='?src=[UID()];create=bbelt;amount=1'>Make</A> ([300/efficiency])<BR>"
			dat += "Security belt: <A href='?src=[UID()];create=sbelt;amount=1'>Make</A> ([300/efficiency])<BR>"
			dat += "Medical belt: <A href='?src=[UID()];create=mbelt;amount=1'>Make</A> ([300/efficiency])<BR>"
			dat += "Janitor belt: <A href='?src=[UID()];create=jbelt;amount=1'>Make</A> ([300/efficiency])<BR>"
			dat += "Bandolier: <A href='?src=[UID()];create=band;amount=1'>Make</A> ([300/efficiency])<BR>"
			dat += "</div>"
			//dat += "<h3>Other:</h3>"
			//dat += "Monkey: <A href='?src=[UID()];create=monkey;amount=1'>Make</A> ([400/efficiency])<BR>"
		else
			dat += "<div class='statusDisplay'>No container inside. Please insert a container.</div>"

	var/datum/browser/popup = new(user, "biogen", name, 350, 520)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/biogenerator/attack_hand(mob/user as mob)
	interact(user)

/obj/machinery/biogenerator/proc/activate()
	if(usr.stat != 0)
		return
	if(src.stat != 0) //NOPOWER etc
		return
	if(src.processing)
		to_chat(usr, "<span class='warning'>The biogenerator is in the process of working.</span>")
		return
	var/S = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		var/reagent_amount = I.reagents.get_reagent_amount("nutriment") + I.reagents.get_reagent_amount("plantmatter")
		if(reagent_amount < 0.1)
			points += 1*productivity
		else points += reagent_amount*10*productivity
		qdel(I)
	if(S)
		processing = 1
		update_icon()
		updateUsrDialog()
		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
		use_power(S*30)
		sleep(S+15/productivity)
		processing = 0
		update_icon()
	else
		menustat = "void"
	return

/obj/machinery/biogenerator/proc/check_cost(var/cost, var/checkonly)
	if(cost > points)
		menustat = "nopoints"
		return 1
	else if(checkonly)
		return 0
	else
		points -= cost
		processing = 1
		update_icon()
		updateUsrDialog()
		return 0

/obj/machinery/biogenerator/proc/check_container_volume(var/reagent_amount)
	if(beaker.reagents.total_volume + reagent_amount > beaker.reagents.maximum_volume)
		menustat = "nobeakerspace"
		return 1

/obj/machinery/biogenerator/proc/create_product(var/create)
	switch(create)
		//Food
		if("milk")
			if(check_container_volume(10)) return 0
			else if(check_cost(20/efficiency)) return 0
			else beaker.reagents.add_reagent("milk",10)
		if("cream")
			if(check_container_volume(10)) return 0
			else if(check_cost(30/efficiency)) return 0
			else beaker.reagents.add_reagent("cream",10)
		if("meat")
			if(check_cost(250/efficiency)) return 0
			else new/obj/item/weapon/reagent_containers/food/snacks/monkeycube(src.loc)
		//Nutrients
		if("ez")
			if(check_cost(10/efficiency, 1)) return 0
			if(in_beaker)
				if(check_container_volume(10)) return 0
				else beaker.reagents.add_reagent("eznutrient",10)
			else
				new/obj/item/weapon/reagent_containers/glass/fertilizer/ez(src.loc)
			if(check_cost(10/efficiency)) return 0
		if("l4z")
			if(check_cost(20/efficiency, 1)) return 0
			if(in_beaker)
				if(check_container_volume(10)) return 0
				else beaker.reagents.add_reagent("left4zed",10)
			else
				new/obj/item/weapon/reagent_containers/glass/fertilizer/l4z(src.loc)
			if(check_cost(20/efficiency)) return 0
		if("rh")
			if(check_cost(25/efficiency, 1)) return 0
			if(in_beaker)
				if(check_container_volume(10)) return 0
				else beaker.reagents.add_reagent("robustharvest",10)
			else
				new/obj/item/weapon/reagent_containers/glass/fertilizer/rh(src.loc)
			if(check_cost(25/efficiency)) return 0
		//Leather
		if("wallet")
			if(check_cost(100/efficiency)) return 0
			else new/obj/item/weapon/storage/wallet(src.loc)
		if("bkbag")
			if(check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/books(src.loc)
		if("ptbag")
			if(check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/plants(src.loc)
		if("mnbag")
			if(check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/ore(src.loc)
		if("chbag")
			if(check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/chemistry(src.loc)
		if("rag")
			if(check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/reagent_containers/glass/rag(src.loc)
		if("gloves")
			if(check_cost(250/efficiency)) return 0
			else new/obj/item/clothing/gloves/botanic_leather(src.loc)
		if("satchel")
			if(check_cost(400/efficiency)) return 0
			else new/obj/item/weapon/storage/backpack/satchel(src.loc)
		if("cashbag")
			if(check_cost(400/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/cash(src.loc)
		if("jacket")
			if(check_cost(500/efficiency)) return 0
			else new/obj/item/clothing/suit/jacket/leather(src.loc)
		//Belts
		if("tbelt")
			if(check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/utility(src.loc)
		if("bbelt")
			if(check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/botany(src.loc)
		if("sbelt")
			if(check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/security(src.loc)
		if("mbelt")
			if(check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/medical(src.loc)
		if("jbelt")
			if(check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/janitor(src.loc)
		if("band")
			if(check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/bandolier(src.loc)
	processing = 0
	menustat = "complete"
	update_icon()
	return 1

/obj/machinery/biogenerator/proc/detach()
	if(beaker)
		beaker.forceMove(src.loc)
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
		var/i = amount
		var/C = href_list["create"]
		if(i <= 0)
			return
		while(i >= 1)
			create_product(C)
			i--
		processing = 0
		updateUsrDialog()

	else if(href_list["menu"])
		menustat = "menu"
		updateUsrDialog()

	else if(href_list["inbeaker"])
		in_beaker = !in_beaker
		updateUsrDialog()