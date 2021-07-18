// TODO: Refactor all of this
/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = 0
	var/obj/item/reagent_containers/beaker = new /obj/item/reagent_containers/glass/beaker/large
	var/limit = null
	var/efficiency = null

	//IMPORTANT NOTE! A negative number is a multiplier, a positive number is a flat amount to add. 0 means equal to the amount of the original reagent
	var/list/blend_items = list (

			//Sheets
			/obj/item/stack/sheet/mineral/plasma = list(/datum/reagent/plasma_dust = 20),
			/obj/item/stack/sheet/metal = list(/datum/reagent/iron = 20),
			/obj/item/stack/rods = list(/datum/reagent/iron = 10),
			/obj/item/stack/sheet/plasteel = list(/datum/reagent/iron = 20, /datum/reagent/plasma_dust = 20),
			/obj/item/stack/sheet/wood = list(/datum/reagent/carbon = 20),
			/obj/item/stack/sheet/glass = list(/datum/reagent/silicon = 20),
			/obj/item/stack/sheet/rglass = list(/datum/reagent/silicon = 20, /datum/reagent/iron = 20),
			/obj/item/stack/sheet/mineral/uranium = list(/datum/reagent/uranium = 20),
			/obj/item/stack/sheet/mineral/bananium = list(/datum/reagent/consumable/drink/banana = 20),
			/obj/item/stack/sheet/mineral/tranquillite = list(/datum/reagent/consumable/drink/nothing = 20),
			/obj/item/stack/sheet/mineral/silver = list(/datum/reagent/silver = 20),
			/obj/item/stack/sheet/mineral/gold = list(/datum/reagent/gold = 20),
			/obj/item/grown/nettle/basic = list(/datum/reagent/consumable/wasabi = 0),
			/obj/item/grown/nettle/death = list(/datum/reagent/acid/facid = 0, /datum/reagent/acid = 0),
			/obj/item/grown/novaflower = list(/datum/reagent/consumable/capsaicin = 0, /datum/reagent/consumable/condensedcapsaicin = 0),

			//Blender Stuff
			/obj/item/reagent_containers/food/snacks/grown/tomato = list(/datum/reagent/consumable/ketchup = 0),
			/obj/item/reagent_containers/food/snacks/grown/wheat = list(/datum/reagent/consumable/flour = -5),
			/obj/item/reagent_containers/food/snacks/grown/oat = list(/datum/reagent/consumable/flour = -5),
			/obj/item/reagent_containers/food/snacks/grown/cherries = list(/datum/reagent/consumable/cherryjelly = 0),
			/obj/item/reagent_containers/food/snacks/grown/bluecherries = list(/datum/reagent/consumable/bluecherryjelly = 0),
			/obj/item/reagent_containers/food/snacks/egg = list(/datum/reagent/consumable/egg = -5),
			/obj/item/reagent_containers/food/snacks/grown/rice = list(/datum/reagent/consumable/rice = -5),

			//Grinder stuff, but only if dry
			/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list(/datum/reagent/toxin/coffeepowder = 0, /datum/reagent/medicine/morphine = 0),
			/obj/item/reagent_containers/food/snacks/grown/coffee = list(/datum/reagent/toxin/coffeepowder = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea/astra = list(/datum/reagent/toxin/teapowder = 0, /datum/reagent/medicine/salglu_solution = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea = list(/datum/reagent/toxin/teapowder = 0),


			//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
			/obj/item/slime_extract = list(),
			/obj/item/reagent_containers/food = list(),
			/obj/item/reagent_containers/honeycomb = list()
	)

	var/list/juice_items = list (

			//Juicer Stuff
			/obj/item/reagent_containers/food/snacks/grown/soybeans = list(/datum/reagent/consumable/drink/milk/soymilk = 0),
			/obj/item/reagent_containers/food/snacks/grown/corn = list(/datum/reagent/consumable/corn_starch = 0),
			/obj/item/reagent_containers/food/snacks/grown/tomato = list(/datum/reagent/consumable/drink/tomatojuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/carrot = list(/datum/reagent/consumable/drink/carrotjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/berries = list(/datum/reagent/consumable/drink/berryjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/banana = list(/datum/reagent/consumable/drink/banana = 0),
			/obj/item/reagent_containers/food/snacks/grown/potato = list(/datum/reagent/consumable/drink/potato_juice = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = list(/datum/reagent/consumable/drink/lemonjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/orange = list(/datum/reagent/consumable/drink/orangejuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/citrus/lime = list(/datum/reagent/consumable/drink/limejuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/watermelon = list(/datum/reagent/consumable/drink/watermelonjuice = 0),
			/obj/item/reagent_containers/food/snacks/watermelonslice = list(/datum/reagent/consumable/drink/watermelonjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/berries/poison = list(/datum/reagent/consumable/drink/poisonberryjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/pumpkin = list(/datum/reagent/consumable/drink/pumpkinjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/blumpkin = list(/datum/reagent/consumable/drink/blumpkinjuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/apple = list(/datum/reagent/consumable/applejuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/grapes = list(/datum/reagent/consumable/drink/grapejuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/grapes/green = list(/datum/reagent/consumable/drink/grapejuice = 0),
			/obj/item/reagent_containers/food/snacks/grown/pineapple = list(/datum/reagent/consumable/drink/pineapplejuice = 0)
	)

	var/list/dried_items = list(
			//Grinder stuff, but only if dry,
			/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = list(/datum/reagent/toxin/coffeepowder = 0, /datum/reagent/medicine/morphine = 0),
			/obj/item/reagent_containers/food/snacks/grown/coffee = list(/datum/reagent/toxin/coffeepowder = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea/astra = list(/datum/reagent/toxin/teapowder = 0, /datum/reagent/medicine/salglu_solution = 0),
			/obj/item/reagent_containers/food/snacks/grown/tea = list(/datum/reagent/toxin/teapowder = 0)
	)

	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/empty
	icon_state = "juicer0"
	beaker = null

/obj/machinery/reagentgrinder/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/reagentgrinder(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/reagentgrinder/RefreshParts()
	var/H
	var/T
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	limit = 10*H
	efficiency = 0.8+T*0.1

/obj/machinery/reagentgrinder/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/reagentgrinder/ex_act(severity)
	if(beaker)
		beaker.ex_act(severity)
	..()

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	if(A == beaker)
		beaker = null
		update_icon()

/obj/machinery/reagentgrinder/update_icon()
	if(beaker)
		icon_state = "juicer1"
	else
		icon_state = "juicer0"

/obj/machinery/reagentgrinder/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored || beaker)
		return
	if(!panel_open)
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(I)

/obj/machinery/reagentgrinder/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!anchored || beaker)
		return
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "juicer_open", "juicer0", I)

/obj/machinery/reagentgrinder/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I)

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)

	if(exchange_parts(user, I))
		return

	if(istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER) )
		if(beaker)
			to_chat(user, "<span class='warning'>There's already a container inside.</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
		else
			if(!user.drop_item())
				return FALSE
			beaker =  I
			beaker.loc = src
			update_icon()
			updateUsrDialog()
		return TRUE //no afterattack

	if(is_type_in_list(I, dried_items))
		if(istype(I, /obj/item/reagent_containers/food/snacks/grown))
			var/obj/item/reagent_containers/food/snacks/grown/G = I
			if(!G.dry)
				to_chat(user, "<span class='warning'>You must dry that first!</span>")
				return FALSE

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return FALSE

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/obj/item/storage/bag/B = I
		if(!B.contents.len)
			to_chat(user, "<span class='warning'>[B] is empty.</span>")
			return FALSE

		var/original_contents_len = B.contents.len

		for(var/obj/item/G in B.contents)
			if(is_type_in_list(G, blend_items) || is_type_in_list(G, juice_items))
				B.remove_from_storage(G, src)
				holdingitems += G
				if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
					to_chat(user, "<span class='notice'>You fill the All-In-One grinder to the brim.</span>")
					break

		if(B.contents.len == original_contents_len)
			to_chat(user, "<span class='warning'>Nothing in [B] can be put into the All-In-One grinder.</span>")
			return FALSE
		else if(!B.contents.len)
			to_chat(user, "<span class='notice'>You empty all of [B]'s contents into the All-In-One grinder.</span>")
		else
			to_chat(user, "<span class='notice'>You empty some of [B]'s contents into the All-In-One grinder.</span>")

		updateUsrDialog()
		return TRUE

	if(!is_type_in_list(I, blend_items) && !is_type_in_list(I, juice_items))
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>Cannot refine into a reagent!</span>")
			return TRUE

	if(user.drop_item())
		I.loc = src
		holdingitems += I
		src.updateUsrDialog()
		return FALSE



/obj/machinery/reagentgrinder/attack_ai(mob/user)
		return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user)
		user.set_machine(src)
		interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu
		var/is_chamber_empty = 0
		var/is_beaker_ready = 0
		var/processing_chamber = ""
		var/beaker_contents = ""
		var/dat = ""

		if(!operating)
				for (var/obj/item/O in holdingitems)
						processing_chamber += "\A [html_encode(O.name)]<BR>"

				if (!processing_chamber)
						is_chamber_empty = 1
						processing_chamber = "Nothing."
				if (!beaker)
						beaker_contents = "<B>No beaker attached.</B><br>"
				else
						is_beaker_ready = 1
						beaker_contents = "<B>The beaker contains:</B><br>"
						var/anything = 0
						for(var/datum/reagent/R in beaker.reagents.reagent_list)
								anything = 1
								beaker_contents += "[R.volume] - [R.name]<br>"
						if(!anything)
								beaker_contents += "Nothing<br>"


				dat = {"
		<b>Processing chamber contains:</b><br>
		[processing_chamber]<br>
		[beaker_contents]<hr>
		"}
				if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
						dat += "<A href='?src=[src.UID()];action=grind'>Grind the reagents</a><BR>"
						dat += "<A href='?src=[src.UID()];action=juice'>Juice the reagents</a><BR><BR>"
				if(holdingitems && holdingitems.len > 0)
						dat += "<A href='?src=[src.UID()];action=eject'>Eject the reagents</a><BR>"
				if (beaker)
						dat += "<A href='?src=[src.UID()];action=detach'>Detach the beaker</a><BR>"
		else
				dat += "Please wait..."

		var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder")
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open(1)
		return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()

/obj/machinery/reagentgrinder/proc/detach()

		if (usr.stat != 0)
				return
		if (!beaker)
				return
		beaker.loc = src.loc
		beaker = null
		update_icon()
		updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject()

		if (usr.stat != 0)
				return
		if (holdingitems && holdingitems.len == 0)
				return

		for(var/obj/item/O in holdingitems)
				O.loc = src.loc
				holdingitems -= O
		holdingitems = list()
		updateUsrDialog()

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/reagent_containers/O)
		for (var/i in blend_items)
				if(istype(O, i))
						return TRUE
		return FALSE

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/O)
		for (var/i in blend_items)
				if (istype(O, i))
						return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/reagent_containers/food/snacks/O)
		for(var/i in blend_items)
				if(istype(O, i))
						return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/reagent_containers/food/snacks/O)
		for(var/i in juice_items)
				if(istype(O, i))
						return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/grown/O)
		if (!istype(O) || !O.seed)
				return 5
		else if (O.seed.potency == -1)
				return 5
		else
				return round(O.seed.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/reagent_containers/food/snacks/grown/O)
		if (!istype(O) || !O.seed)
				return 5
		else if (O.seed.potency == -1)
				return 5
		else
				return round(5*sqrt(O.seed.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
		holdingitems -= O
		qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER | BROKEN))
		return
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src, 'sound/machines/juicer.ogg', 20, TRUE)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = TRUE
	updateUsrDialog()
	addtimer(CALLBACK(src, .proc/stop_shaking), 5 SECONDS)

	//Snacks
	for(var/obj/item/reagent_containers/food/snacks/O in holdingitems)
		if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(!allowed)
			break

		for(var/reagent in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)
			if(space <= 0)
				break

			beaker.reagents.add_reagent(reagent, min(amount * efficiency, space))

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()
	power_change()
	if(stat & (NOPOWER | BROKEN))
		return
	if(!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(loc, 'sound/machines/blender.ogg', 50, TRUE)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = TRUE
	updateUsrDialog()
	addtimer(CALLBACK(src, .proc/stop_shaking), 6 SECONDS) //return to its spot after shaking


	for(var/item in holdingitems)
		//Snacks and Plants
		if(istype(item, /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/O = item
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

			var/allowed = get_allowed_snack_by_id(O)
			if(!allowed)
				break

			for(var/reagent in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[reagent]
				if(space <= 0)
					break
				if(!O.reagents)
					continue

				var/nutriment = O.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
				var/plantmatter = O.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment/plantmatter)
				if(amount <= 0)
					if(amount == 0) // Doesn't have a specific set amount
						if(nutriment) // Replace all nutriment and plantmatter with `reagent` for the beaker.
							beaker.reagents.add_reagent(reagent, min(nutriment * efficiency, space))
							O.reagents.remove_reagent(/datum/reagent/consumable/nutriment, min(nutriment, space))
						if(plantmatter)
							beaker.reagents.add_reagent(reagent, min(plantmatter * efficiency, space))
							O.reagents.remove_reagent(/datum/reagent/consumable/nutriment/plantmatter, min(plantmatter, space))
					else
						if(nutriment)
							beaker.reagents.add_reagent(reagent, min(round(nutriment * abs(amount) * efficiency), space))
							O.reagents.remove_reagent(/datum/reagent/consumable/nutriment, min(nutriment, space))
						if(plantmatter)
							beaker.reagents.add_reagent(reagent, min(round(plantmatter * abs(amount) * efficiency), space))
							O.reagents.remove_reagent(/datum/reagent/consumable/nutriment/plantmatter, min(plantmatter, space))
				else // amount > 0
					O.reagents.trans_reagent_to(beaker, reagent, min(amount, space))

			if(!O.reagents || !length(O.reagents.reagent_list))
				remove_object(O)

		//Sheets
		else if(istype(item, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/O = item
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

			var/allowed = get_allowed_by_id(O)
			var/stack_amount = round(O.amount, 1)
			for(var/I in 1 to stack_amount)
				for(var/reagent in allowed)
					var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
					var/amount = allowed[reagent]
					if(space <= 0)
						break

					beaker.reagents.add_reagent(reagent, min(amount * efficiency, space))
					if(space < amount)
						break
				if(I == stack_amount)
					remove_object(O)
					break

		//Plants
		else if(istype(item, /obj/item/grown))
			var/obj/item/grown/O = item
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

			var/allowed = get_allowed_by_id(O)
			for(var/reagent in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[reagent]
				if(space <= 0)
					break
				if(!O.reagents)
					continue

				if(amount == 0)
					var/has_reagent = O.reagents.get_reagent_amount(reagent)
					if(has_reagent)
						beaker.reagents.add_reagent(reagent, min(has_reagent * efficiency, space))
				else
					beaker.reagents.add_reagent(reagent, min(amount * efficiency, space))
			remove_object(O)

		//Slime Extracts
		else if(istype(item, /obj/item/slime_extract))
			var/obj/item/slime_extract/O = item
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			if(O.reagents && length(O.reagents.reagent_list))
				O.reagents.trans_to(beaker, min(O.reagents.total_volume, space))
			if(O.Uses > 0)
				beaker.reagents.add_reagent(/datum/reagent/slimejelly, min(20 * efficiency, space))
			remove_object(O)

		//Everything else - Transfers reagents from it into beaker
		else if(istype(item, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/O = item
			if(beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			O.reagents.trans_to(beaker, min(O.reagents.total_volume, space))
			if(!O.reagents.total_volume)
				remove_object(O)

/obj/machinery/reagentgrinder/proc/stop_shaking()
	pixel_x = initial(pixel_x)
	operating = FALSE
	updateUsrDialog()
