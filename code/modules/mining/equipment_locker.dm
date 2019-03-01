/**********************Ore Redemption Unit**************************/
//Turns all the various mining machines into a single unit to speed up mining and establish a point system

/obj/machinery/mineral/ore_redemption
	name = "ore redemption machine"
	desc = "A machine that accepts ore and instantly transforms it into workable material sheets. Points for ore are generated based on type and can be redeemed at a mining equipment vendor."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	density = TRUE
	anchored = TRUE
	input_dir = NORTH
	output_dir = SOUTH
	req_access = list(access_mineral_storeroom)
	speed_process = TRUE
	layer = BELOW_OBJ_LAYER
	var/req_access_reclaim = access_mining_station
	var/obj/item/card/id/inserted_id
	var/points = 0
	var/ore_pickup_rate = 15
	var/sheet_per_ore = 1
	var/point_upgrade = 1
	var/list/ore_values = list("sand" = 1, "iron" = 1, "plasma" = 15, "silver" = 16, "gold" = 18, "titanium" = 30, "uranium" = 30, "diamond" = 50, "bluespace crystal" = 50, "bananium" = 60, "tranquillite" = 60)
	var/message_sent = FALSE
	var/list/ore_buffer = list()
	var/datum/research/files
	var/obj/item/disk/design_disk/inserted_disk
	var/list/supply_consoles = list("Science", "Robotics", "Research Director's Desk", "Mechanic", "Engineering" = list("metal", "glass", "plasma"), "Chief Engineer's Desk" = list("metal", "glass", "plasma"), "Atmospherics" = list("metal", "glass", "plasma"), "Bar" = list("uranium", "plasma"), "Virology" = list("plasma", "uranium", "gold"))

/obj/machinery/mineral/ore_redemption/New()
	..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), INFINITY, FALSE, /obj/item/stack)
	files = new /datum/research/smelter(src)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/golem
	req_access = list(access_free_golems)
	req_access_reclaim = access_free_golems

/obj/machinery/mineral/ore_redemption/golem/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/Destroy()
	QDEL_NULL(files)
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/mineral/ore_redemption/RefreshParts()
	var/ore_pickup_rate_temp = 15
	var/point_upgrade_temp = 1
	var/sheet_per_ore_temp = 1
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		sheet_per_ore_temp = 0.65 + (0.35 * B.rating)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		ore_pickup_rate_temp = 15 * M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		point_upgrade_temp = 0.65 + (0.35 * L.rating)
	ore_pickup_rate = ore_pickup_rate_temp
	point_upgrade = point_upgrade_temp
	sheet_per_ore = sheet_per_ore_temp

/obj/machinery/mineral/ore_redemption/proc/smelt_ore(obj/item/stack/ore/O)

	ore_buffer -= O

	if(O && O.refined_type)
		points += O.points * point_upgrade * O.amount

	GET_COMPONENT(materials, /datum/component/material_container)
	var/material_amount = materials.get_item_material_amount(O)

	if(!material_amount)
		qdel(O) //no materials, incinerate it

	else if(!materials.has_space(material_amount * sheet_per_ore * O.amount)) //if there is no space, eject it
		unload_mineral(O)

	else
		materials.insert_item(O, sheet_per_ore) //insert it
		qdel(O)

/obj/machinery/mineral/ore_redemption/proc/can_smelt_alloy(datum/design/D)
	if(D.make_reagents.len)
		return FALSE

	var/build_amount = 0

	GET_COMPONENT(materials, /datum/component/material_container)
	for(var/mat_id in D.materials)
		var/M = D.materials[mat_id]
		var/datum/material/redemption_mat = materials.materials[mat_id]

		if(!M || !redemption_mat)
			return FALSE

		var/smeltable_sheets = round(redemption_mat.amount / M)

		if(!smeltable_sheets)
			return FALSE

		if(!build_amount)
			build_amount = smeltable_sheets

		build_amount = min(build_amount, smeltable_sheets)

	return build_amount

/obj/machinery/mineral/ore_redemption/proc/process_ores(list/ores_to_process)
	var/current_amount = 0
	for(var/ore in ores_to_process)
		if(current_amount >= ore_pickup_rate)
			break
		smelt_ore(ore)

/obj/machinery/mineral/ore_redemption/proc/send_console_message()
	if(!is_station_level(z))
		return
	message_sent = TRUE
	var/area/A = get_area(src)
	var/msg = "Now available in [A]:<br>"

	var/has_minerals = FALSE
	var/mineral_name = null
	GET_COMPONENT(materials, /datum/component/material_container)
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		var/mineral_amount = M.amount / MINERAL_MATERIAL_AMOUNT
		mineral_name = capitalize(M.name)
		if(mineral_amount)
			has_minerals = TRUE
		msg += "[mineral_name]: [mineral_amount] sheets<br>"

	if(!has_minerals)
		return

	for(var/obj/machinery/requests_console/D in allConsoles)
		if(D.department in src.supply_consoles)
			if(supply_consoles[D.department] == null || (mineral_name in supply_consoles[D.department]))
				D.createMessage("Ore Redemption Machine", "New Minerals Available!", msg, 1)

/obj/machinery/mineral/ore_redemption/process()
	if(panel_open || !powered())
		return
	var/atom/input = get_step(src, input_dir)
	var/obj/structure/ore_box/OB = locate() in input
	if(OB)
		input = OB

	for(var/obj/item/stack/ore/O in input)
		if(QDELETED(O))
			continue
		ore_buffer |= O
		O.forceMove(src)
		CHECK_TICK

	if(LAZYLEN(ore_buffer))
		message_sent = FALSE
		process_ores(ore_buffer)
	else if(!message_sent)
		send_console_message()

/obj/machinery/mineral/ore_redemption/attackby(obj/item/W, mob/user, params)
	if(exchange_parts(user, W))
		return
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/I = user.get_active_hand()
		if(istype(I) && !istype(inserted_id))
			if(!user.drop_item())
				return
			I.forceMove(src)
			inserted_id = I
			interact(user)
		return

	if(ismultitool(W) && panel_open)
		input_dir = turn(input_dir, -90)
		output_dir = turn(output_dir, -90)
		to_chat(user, "<span class='notice'>You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)].</span>")
		return

	if(istype(W, /obj/item/disk/design_disk))
		if(user.drop_item())
			W.forceMove(src)
			inserted_disk = W
			interact(user)
			return TRUE

	return ..()

/obj/machinery/mineral/ore_redemption/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/ore_redemption/interact(mob/user)
	var/dat = "This machine only accepts ore. Gibtonite and Slag are not accepted.<br><br>"
	dat += "Current unclaimed points: [points]<br>"

	if(inserted_id)
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=[UID()];eject_id=1'>Eject ID.</A><br>"
		dat += "<A href='?src=[UID()];claim=1'>Claim points.</A><br><br>"
	else
		dat += "No ID inserted.  <A href='?src=[UID()];insert_id=1'>Insert ID.</A><br><br>"

	GET_COMPONENT(materials, /datum/component/material_container)
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		if(M.amount)
			var/sheet_amount = M.amount / MINERAL_MATERIAL_AMOUNT
			dat += "[capitalize(M.name)]: [sheet_amount] "
			if(sheet_amount >= 1)
				dat += "<A href='?src=[UID()];release=[mat_id]'>Release</A><br>"
			else
				dat += "<span  class='linkOff'>Release</span><br>"

	dat += "<br><b>Alloys: </b><br>"

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		if(can_smelt_alloy(D))
			dat += "[D.name]: <A href='?src=[UID()];alloy=[D.id]'>Smelt</A><br>"
		else
			dat += "[D.name]: <span class='linkOff'>Smelt</span><br>"

	dat += "<br><div class='statusDisplay'><b>Mineral Value List:</b><br>[get_ore_values()]</div>"

	if(inserted_disk)
		dat += "<A href='?src=[UID()];eject_disk=1'>Eject disk</A><br>"
		dat += "<div class='statusDisplay'><b>Uploadable designs: </b><br>"

		if(inserted_disk.blueprint)
			var/datum/design/D = inserted_disk.blueprint
			if(D.build_type & SMELTER)
				dat += "Name: [D.name] <A href='?src=[UID()];upload=[inserted_disk.blueprint]'>Upload to smelter</A>"

		dat += "</div><br>"
	else
		dat += "<A href='?src=[UID()];insert_disk=1'>Insert design disk</A><br><br>"

	var/datum/browser/popup = new(user, "ore_redemption_machine", "Ore Redemption Machine", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/mineral/ore_redemption/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value * point_upgrade]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/ore_redemption/Topic(href, href_list)
	if(..())
		return
	GET_COMPONENT(materials, /datum/component/material_container)
	if(href_list["eject_id"])
		usr.put_in_hands(inserted_id)
		inserted_id = null
	if(href_list["claim"])
		if(inserted_id)
			if(req_access_reclaim in inserted_id.access)
				inserted_id.mining_points += points
				points = 0
			else
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
	else if(href_list["insert_id"])
		var/obj/item/card/id/I = usr.get_active_hand()
		if(istype(I))
			if(!usr.drop_item())
				return
			I.forceMove(src)
			inserted_id = I
		else
			to_chat(usr, "<span class='warning'>Not a valid ID!</span>")
	if(href_list["eject_disk"])
		if(inserted_disk)
			inserted_disk.forceMove(loc)
			inserted_disk = null
	if(href_list["insert_disk"])
		var/obj/item/disk/design_disk/D = usr.get_active_hand()
		if(istype(D))
			if(!usr.drop_item())
				return
			D.forceMove(src)
			inserted_disk = D
	if(href_list["upload"])
		if(inserted_disk && inserted_disk.blueprint)
			files.AddDesign2Known(inserted_disk.blueprint)

	if(href_list["release"])
		if(check_access(inserted_id) || allowed(usr)) //Check the ID inside, otherwise check the user
			var/mat_id = href_list["release"]
			if(!materials.materials[mat_id])
				return

			var/datum/material/mat = materials.materials[mat_id]
			var/stored_amount = mat.amount / MINERAL_MATERIAL_AMOUNT

			if(!stored_amount)
				return

			var/desired = input("How many sheets?", "How many sheets to eject?", 1) as null|num
			var/sheets_to_remove = round(min(desired,50,stored_amount))

			var/out = get_step(src, output_dir)
			materials.retrieve_sheets(sheets_to_remove, mat_id, out)

		else
			to_chat(usr, "<span class='warning'>Required access not found.</span>")

	if(href_list["alloy"])
		var/alloy_id = href_list["alloy"]
		var/datum/design/alloy = files.FindDesignByID(alloy_id)
		if((check_access(inserted_id) || allowed(usr)) && alloy)
			var/desired = input("How many sheets?", "How many sheets would you like to smelt?", 1) as null|num
			if(desired < 1) // Stops an exploit that lets you build negative alloys and get free materials
				return
			var/smelt_amount = can_smelt_alloy(alloy)
			var/amount = round(min(desired,50,smelt_amount))
			materials.use_amount(alloy.materials, amount)

			var/output = new alloy.build_path(src)
			if(istype(output, /obj/item/stack/sheet))
				var/obj/item/stack/sheet/mineral/produced_alloy = output
				produced_alloy.amount = amount
				unload_mineral(produced_alloy)
			else
				unload_mineral(output)

		else
			to_chat(usr, "<span class='warning'>Required access not found.</span>")
	updateUsrDialog()

/obj/machinery/mineral/ore_redemption/ex_act(severity, target)
	do_sparks(5, 1, src)
	if(severity == 1)
		if(prob(50))
			qdel(src)
	else if(severity == 2)
		if(prob(25))
			qdel(src)

/obj/machinery/mineral/ore_redemption/power_change()
	..()
	update_icon()
	if(inserted_id && !powered())
		visible_message("<span class='notice'>The ID slot indicator light flickers on [src] as it spits out a card before powering down.</span>")
		inserted_id.forceMove(loc)

/obj/machinery/mineral/ore_redemption/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/**********************Mining Equipment Locker**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = 1
	anchored = 1.0
	var/obj/item/card/id/inserted_id
	var/list/prize_list = list(
		new /datum/data/mining_equipment("Stimpack",			/obj/item/reagent_containers/hypospray/autoinjector/stimpack, 50),
		new /datum/data/mining_equipment("Teporone MediPen",	/obj/item/reagent_containers/hypospray/autoinjector/teporone, 50),
		new /datum/data/mining_equipment("MediPen Bundle",		/obj/item/storage/box/autoinjector/utility,	 			   200),
		new /datum/data/mining_equipment("Whiskey",             /obj/item/reagent_containers/food/drinks/bottle/whiskey,    100),
		new /datum/data/mining_equipment("Cigar",               /obj/item/clothing/mask/cigarette/cigar/havana,                    150),
		new /datum/data/mining_equipment("Soap",                /obj/item/soap/nanotrasen, 						           200),
		new /datum/data/mining_equipment("Laser Pointer",       /obj/item/laser_pointer, 				                   300),
		new /datum/data/mining_equipment("Alien Toy",           /obj/item/clothing/mask/facehugger/toy, 		                   300),
		new /datum/data/mining_equipment("Advanced Scanner",	/obj/item/t_scanner/adv_mining_scanner,                     400),
		new /datum/data/mining_equipment("Hivelord Stabilizer",	/obj/item/hivelordstabilizer,                               400),
		new /datum/data/mining_equipment("Mining Drone",        /obj/item/mining_drone_cube,                                500),
		new /datum/data/mining_equipment("Drone Melee Upgrade", /obj/item/mine_bot_upgrade,      			   			   400),
		new /datum/data/mining_equipment("Drone Health Upgrade",/obj/item/mine_bot_upgrade/health,      			   	       400),
		new /datum/data/mining_equipment("Drone Ranged Upgrade",/obj/item/mine_bot_upgrade/cooldown,      			   	   600),
		new /datum/data/mining_equipment("Kinetic Crusher", 	/obj/item/twohanded/required/mining_hammer,				   750),
		new /datum/data/mining_equipment("Drone AI Upgrade",    /obj/item/slimepotion/sentience/mining,      			   	      1000),
		new /datum/data/mining_equipment("GAR mesons",			/obj/item/clothing/glasses/meson/gar,							   500),
		new /datum/data/mining_equipment("Brute First-Aid Kit",	/obj/item/storage/firstaid/brute,						   600),
		new /datum/data/mining_equipment("Jaunter",             /obj/item/wormhole_jaunter,                                 600),
		new /datum/data/mining_equipment("Kinetic Accelerator", /obj/item/gun/energy/kinetic_accelerator,               	   750),
		new /datum/data/mining_equipment("Resonator",           /obj/item/resonator,                                    	   800),
		new /datum/data/mining_equipment("Lazarus Injector",    /obj/item/lazarus_injector,                                1000),
		new /datum/data/mining_equipment("Silver Pickaxe",		/obj/item/pickaxe/silver,				                  1000),
		new /datum/data/mining_equipment("Lazarus Capsule", 	/obj/item/mobcapsule, 									   800),
		new /datum/data/mining_equipment("Lazarus Capsule belt",/obj/item/storage/belt/lazarus,							   200),
		new /datum/data/mining_equipment("Jetpack",             /obj/item/tank/jetpack/carbondioxide/mining,               2000),
		new /datum/data/mining_equipment("Space Cash",    		/obj/item/stack/spacecash/c1000,                    			  2000),
		new /datum/data/mining_equipment("Diamond Pickaxe",		/obj/item/pickaxe/diamond,				                  2000),
		new /datum/data/mining_equipment("Super Resonator",     /obj/item/resonator/upgraded,                              2500),
		new /datum/data/mining_equipment("KA White Tracer Rounds",	/obj/item/borg/upgrade/modkit/tracer,								100),
		new /datum/data/mining_equipment("KA Adjustable Tracer Rounds",	/obj/item/borg/upgrade/modkit/tracer/adjustable,				150),
		new /datum/data/mining_equipment("KA Super Chassis",	/obj/item/borg/upgrade/modkit/chassis_mod,								250),
		new /datum/data/mining_equipment("KA Hyper Chassis",	/obj/item/borg/upgrade/modkit/chassis_mod/orange,						300),
		new /datum/data/mining_equipment("KA Range Increase",	/obj/item/borg/upgrade/modkit/range,									1000),
		new /datum/data/mining_equipment("KA Damage Increase",	/obj/item/borg/upgrade/modkit/damage,									1000),
		new /datum/data/mining_equipment("KA Cooldown Decrease",/obj/item/borg/upgrade/modkit/cooldown,									1000),
		new /datum/data/mining_equipment("KA AoE Damage",		/obj/item/borg/upgrade/modkit/aoe/mobs,									2000),
		new /datum/data/mining_equipment("Point Transfer Card", /obj/item/card/mining_point_card,               			   500),
		)

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"

/obj/machinery/mineral/equipment_vendor/golem/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/golem/Initialize()
	. = ..()
	desc += "\nIt seems a few selections have been added."
	prize_list += list(
		new /datum/data/mining_equipment("Extra Id",       				/obj/item/card/id/golem, 				                   		250),
		new /datum/data/mining_equipment("Science Backpack",			/obj/item/storage/backpack/science,								250),
		new /datum/data/mining_equipment("Full Toolbelt",				/obj/item/storage/belt/utility/full/multitool,	    			250),
		new /datum/data/mining_equipment("Monkey Cube",					/obj/item/reagent_containers/food/snacks/monkeycube,        	250),
		new /datum/data/mining_equipment("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 								500),
		new /datum/data/mining_equipment("Grey Slime Extract",			/obj/item/slime_extract/grey,									1000),
		new /datum/data/mining_equipment("KA Trigger Modification Kit",	/obj/item/borg/upgrade/modkit/trigger_guard,					1000),
		new /datum/data/mining_equipment("The Liberator's Legacy",  	/obj/item/storage/box/rndboards,								2000)
		)

/datum/data/mining_equipment/
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/equipment_vendor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/power_change()
	..()
	update_icon()
	if(inserted_id && !powered())
		visible_message("<span class='notice'>The ID slot indicator light flickers on \the [src] as it spits out a card before powering down.</span>")
		inserted_id.forceMove(loc)

/obj/machinery/mineral/equipment_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/equipment_vendor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/mineral/equipment_vendor/attack_ghost(mob/user)
	interact(user)

/obj/machinery/mineral/equipment_vendor/interact(mob/user)
	user.set_machine(src)

	var/dat
	dat +="<div class='statusDisplay'>"
	if(istype(inserted_id))
		dat += "You have [inserted_id.mining_points] mining points collected. <A href='?src=[UID()];choice=eject'>Eject ID.</A><br>"
	else
		dat += "No ID inserted.  <A href='?src=[UID()];choice=insert'>Insert ID.</A><br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='200'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=[UID()];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "miningvendor", "Mining Equipment Vendor", 400, 350)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/equipment_vendor/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["choice"])
		if(istype(inserted_id))
			if(href_list["choice"] == "eject")
				inserted_id.loc = loc
				inserted_id.verb_pickup()
				inserted_id = null
		else if(href_list["choice"] == "insert")
			var/obj/item/card/id/I = usr.get_active_hand()
			if(istype(I))
				if(!usr.drop_item())
					return
				I.loc = src
				inserted_id = I
			else
				to_chat(usr, "<span class='danger'>No valid ID.</span>")

	if(href_list["purchase"])
		if(istype(inserted_id))
			var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
			if(!prize || !(prize in prize_list) || prize.cost > inserted_id.mining_points)
				return

			inserted_id.mining_points -= prize.cost
			new prize.equipment_path(src.loc)
	updateUsrDialog()

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		updateUsrDialog()
		return
	if(panel_open)
		if(istype(I, /obj/item/crowbar))
			if(inserted_id)
				inserted_id.forceMove(loc) //Prevents deconstructing the ORM from deleting whatever ID was inside it.
			default_deconstruction_crowbar(I)
		return 1
	if(istype(I, /obj/item/mining_voucher))
		if(!powered())
			return
		else
			RedeemVoucher(I, user)
			return
	if(istype(I,/obj/item/card/id))
		if(!powered())
			return
		else
			var/obj/item/card/id/C = usr.get_active_hand()
			if(istype(C) && !istype(inserted_id))
				if(!usr.drop_item())
					return
				C.forceMove(src)
				inserted_id = C
				interact(user)
			return
	..()

/obj/machinery/mineral/equipment_vendor/proc/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in list("Kinetic Accelerator", "Resonator", "Mining Drone", "Advanced Scanner", "Crusher")
	if(!selection || !Adjacent(redeemer) || voucher.loc != redeemer)
		return
	switch(selection)
		if("Kinetic Accelerator")
			new /obj/item/gun/energy/kinetic_accelerator(src.loc)
		if("Resonator")
			new /obj/item/resonator(src.loc)
		if("Mining Drone")
			new /obj/item/storage/box/drone_kit(src.loc)
		if("Advanced Scanner")
			new /obj/item/t_scanner/adv_mining_scanner(src.loc)
		if("Crusher")
			new /obj/item/twohanded/required/mining_hammer(loc)
	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, 1, src)
	if(prob(50 / severity) && severity < 3)
		qdel(src)

/**********************Mining Equipment Locker Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/items.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining point card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(points)
			var/obj/item/card/id/C = I
			C.mining_points += points
			to_chat(user, "<span class='info'>You transfer [points] points to [C].</span>")
			points = 0
		else
			to_chat(user, "<span class='info'>There's no points left on [src].</span>")
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	..(user)
	to_chat(user, "There's [points] points on the card.")

/**********************Jaunter**********************/

/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"

/obj/item/wormhole_jaunter/attack_self(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf || !is_teleport_allowed(device_turf.z))
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return
	else
		user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
		var/list/L = list()
		for(var/obj/item/radio/beacon/B in world)
			var/turf/T = get_turf(B)
			if(is_station_level(T.z))
				L += B
		if(!L.len)
			to_chat(user, "<span class='notice'>The [src.name] failed to create a wormhole.</span>")
			return
		var/chosen_beacon = pick(L)
		var/obj/effect/portal/wormhole/jaunt_tunnel/J = new /obj/effect/portal/wormhole/jaunt_tunnel(get_turf(src), chosen_beacon, lifespan=100)
		try_move_adjacent(J)
		playsound(src,'sound/effects/sparks4.ogg',50,1)
		qdel(src)

/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		if(do_teleport(M, target, 6))
			if(isliving(M))
				var/mob/living/L = M
				L.Weaken(3)
				if(ishuman(L))
					shake_camera(L, 20, 1)
					var/mob/living/carbon/human/H = L
					spawn(20)
						if(H && H.check_has_mouth())
							H.visible_message("<span class='danger'>[L.name] vomits from travelling through the [src.name]!</span>", "<span class='userdanger'>You throw up from travelling through the [src.name]!</span>")
							H.nutrition -= 20
							H.adjustToxLoss(-3)
							var/turf/T = get_turf(H)
							T.add_vomit_floor(H)
							playsound(H, 'sound/effects/splat.ogg', 50, 1)
		else
			visible_message("<span class='warning'>[src] flickers and fails, due to bluespace interference!</span>")
			qdel(src)

/**********************Resonator**********************/

/obj/item/resonator
	name = "resonator"
	icon = 'icons/obj/items.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	origin_tech = "magnets=3;engineering=3"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vaccuum."
	w_class = WEIGHT_CLASS_NORMAL
	force = 8
	throwforce = 10
	var/cooldown = 0
	var/fieldsactive = 0
	var/burst_time = 50
	var/fieldlimit = 3

/obj/item/resonator/upgraded
	name = "upgraded resonator"
	desc = "An upgraded version of the resonator that can produce more fields at once."
	icon_state = "resonator_u"
	origin_tech = "materials=4;powerstorage=3;engineering=3;magnets=3"
	fieldlimit = 5

/obj/item/resonator/proc/CreateResonance(var/target, var/creator)
	var/turf/T = get_turf(target)
	if(locate(/obj/effect/resonance) in T)
		return
	if(fieldsactive < fieldlimit)
		playsound(src,'sound/weapons/resonator_fire.ogg',50,1)
		new /obj/effect/resonance(T, creator, burst_time)
		fieldsactive++
		spawn(burst_time)
			fieldsactive--

/obj/item/resonator/attack_self(mob/user)
	if(burst_time == 50)
		burst_time = 30
		to_chat(user, "<span class='info'>You set the resonator's fields to detonate after 3 seconds.</span>")
	else
		burst_time = 50
		to_chat(user, "<span class='info'>You set the resonator's fields to detonate after 5 seconds.</span>")

/obj/item/resonator/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(!check_allowed_items(target, 1)) return
		CreateResonance(target, user)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/resonance_damage = 20

/obj/effect/resonance/New(loc, var/creator = null, var/timetoburst)
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf))
		return
	if(istype(proj_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = proj_turf
		spawn(timetoburst)
			playsound(src,'sound/weapons/resonator_blast.ogg',50,1)
			M.gets_drilled(creator)
			qdel(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance field"
			resonance_damage = 50
		spawn(timetoburst)
			playsound(src,'sound/weapons/resonator_blast.ogg',50,1)
			if(creator)
				for(var/mob/living/L in src.loc)
					add_attack_logs(creator, L, "Resonance field'ed")
					to_chat(L, "<span class='danger'>The [src.name] ruptured with you in it!</span>")
					L.adjustBruteLoss(resonance_damage)
			else
				for(var/mob/living/L in src.loc)
					to_chat(L, "<span class='danger'>The [src.name] ruptured with you in it!</span>")
					L.adjustBruteLoss(resonance_damage)
			qdel(src)

/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger/toy
	item_state = "facehugger_inactive"
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	real = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/Die()
	return


/**********************Mining drone cube**********************/

/obj/item/mining_drone_cube
	name = "mining drone cube"
	desc = "Compressed mining drone, ready for deployment. Just press the button to activate!"
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/aibots.dmi'
	icon_state = "minedronecube"
	item_state = "electronic"

/obj/item/mining_drone_cube/attack_self(mob/user)
	user.visible_message("<span class='warning'>\The [src] suddenly expands into a fully functional mining drone!</span>", \
	"<span class='warning'>You press center button on \the [src]. The device suddenly expands into a fully functional mining drone!</span>")
	new /mob/living/simple_animal/hostile/mining_drone(get_turf(src))
	qdel(src)

/**********************Mining drone kit**********************/

/obj/item/storage/box/drone_kit
	name = "Drone Kit"
	desc = "A boxed kit that includes one mining drone cube and a welding tool with an increased capacity."
	icon_state = "implant"
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 2
	can_hold = list(/obj/item/mining_drone_cube, /obj/item/weldingtool/hugetank)

/obj/item/storage/box/drone_kit/New()
	..()
	new /obj/item/mining_drone_cube(src)
	new /obj/item/weldingtool/hugetank(src)

/**********************Lazarus Injector**********************/

/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	origin_tech = "biotech=4;magnets=6"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0

/obj/item/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive()
				M.can_collar = 1
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "\ref[user]")
						H.robust_searching = 1
						H.friends += user
						H.attack_same = 1
						log_game("[user] has revived hostile mob [target] with a malfunctioning lazarus injector")
					else
						H.attack_same = 0
				loaded = 0
				user.visible_message("<span class='notice'>[user] injects [M] with [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, "<span class='info'>[src] is only effective on the dead.</span>")
				return
		else
			to_chat(user, "<span class='info'>[src] is only effective on lesser beings.</span>")
			return

/obj/item/lazarus_injector/emag_act(mob/user)
	if(!malfunctioning)
		malfunctioning = 1
		to_chat(user, "<span class='notice'>You override [src]'s safety protocols.</span>")

/obj/item/lazarus_injector/emp_act()
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/lazarus_injector/examine(mob/user)
	..(user)
	if(!loaded)
		to_chat(user, "<span class='info'>[src] is empty.</span>")
	if(malfunctioning)
		to_chat(user, "<span class='info'>The display on [src] seems to be flickering.</span>")

/**********************Mining Scanner**********************/

/obj/item/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	name = "manual mining scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "mining1"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 0
	origin_tech = "engineering=1;magnets=1"

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(!cooldown)
		cooldown = 1
		spawn(40)
			cooldown = 0
		var/list/mobs = list()
		mobs |= user
		mineral_scan_pulse(mobs, get_turf(user))


//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/simulated/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results. This one has an extended range."
	name = "advanced automatic mining scanner"
	icon_state = "mining0"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 35
	var/on_cooldown = 0
	var/range = 7
	var/meson = TRUE
	origin_tech = "engineering=3;magnets=3"

/obj/item/t_scanner/adv_mining_scanner/cyborg
	flags = CONDUCT | NODROP

/obj/item/t_scanner/adv_mining_scanner/material
	meson = FALSE
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results. This one has an extended range."

/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear meson scanners for optimal results."
	range = 4
	cooldown = 50

/obj/item/t_scanner/adv_mining_scanner/lesser/material
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. Wear material scanners for optimal results."
	meson = FALSE

/obj/item/t_scanner/adv_mining_scanner/scan()
	if(!on_cooldown)
		on_cooldown = 1
		spawn(cooldown)
			on_cooldown = 0
		var/turf/t = get_turf(src)
		var/list/mobs = recursive_mob_check(t, client_check = 1, sight_check = 0, include_radio = 0)
		if(!mobs.len)
			return
		if(meson)
			mineral_scan_pulse(mobs, t, range)
		else
			mineral_scan_pulse_material(mobs, t, range)

//For use with mesons
/proc/mineral_scan_pulse(list/mobs, turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(minerals.len)
		for(var/mob/user in mobs)
			if(user.client)
				var/client/C = user.client
				for(var/turf/simulated/mineral/M in minerals)
					var/turf/F = get_turf(M)
					var/image/I = image('icons/turf/mining.dmi', loc = F, icon_state = M.scan_state, layer = 18)
					C.images += I
					spawn(30)
						if(C)
							C.images -= I

//For use with material scanners
/proc/mineral_scan_pulse_material(list/mobs, turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(minerals.len)
		for(var/turf/simulated/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/C = new/obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.scan_state

/obj/effect/temp_visual/mining_overlay
	layer = 18
	icon = 'icons/turf/mining.dmi'
	anchored = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 30
	pixel_x = -4
	pixel_y = -4

/**********************Xeno Warning Sign**********************/
/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would be travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"

/**********************Mining Jetpack**********************/
/obj/item/tank/jetpack/carbondioxide/mining
	name = "mining jetpack"
	icon_state = "jetpack-mining"
	item_state = "jetpack-mining"
	origin_tech = "materials=4;magnets=4;engineering=5"
	desc = "A tank of compressed carbon dioxide for miners to use as propulsion in local space. The compact size allows for easy storage at the cost of capacity."
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL //same as syndie harness

/*********************Hivelord stabilizer****************/

/obj/item/hivelordstabilizer
	name = "hivelord stabilizer"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject a hivelord core with this stabilizer to preserve its healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=3"

/obj/item/hivelordstabilizer/afterattack(obj/item/organ/internal/M, mob/user)
	var/obj/item/organ/internal/hivelord_core/C = M
	if(!istype(C, /obj/item/organ/internal/hivelord_core))
		to_chat(user, "<span class='warning'>The stabilizer only works on hivelord cores.</span>")
		return ..()
	C.preserved = 1
	to_chat(user, "<span class='notice'>You inject the hivelord core with the stabilizer. It will no longer go inert.</span>")
	qdel(src)

/*********************Mining Hammer****************/
/obj/item/twohanded/required/mining_hammer
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_hammer1"
	item_state = "mining_hammer1"
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than an combination of various mining tools cobbled together, forming a high-tech club.\
	  While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna. \
	 \n<span class='info'>Mark a mob with the destabilizing force, then hit them in melee to activate it for extra damage. Extra damage if backstabbed in this fashion. \
	 This weapon is only particularly effective against large creatures.</span>"
	force = 20 //As much as a bone spear, but this is significantly more annoying to carry around due to requiring the use of both hands at all times
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 20 //It's never not wielded so these are the same
	force_wielded = 20
	throwforce = 5
	throw_speed = 4
	light_range = 4
	armour_penetration = 10
	materials = list(MAT_METAL=1150, MAT_GLASS=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("smashes", "crushes", "cleaves", "chops", "pulps")
	sharp = 1
	var/charged = 1
	var/charge_time = 16
	var/atom/mark = null
	var/marked_image = null

/obj/item/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	flag = "bomb"
	range = 6
	var/obj/item/twohanded/required/mining_hammer/hammer_synced =  null

/obj/item/projectile/destabilizer/on_hit(atom/target, blocked = 0, hit_zone)
	if(hammer_synced)
		if(hammer_synced.mark == target)
			return ..()
		if(isliving(target))
			if(hammer_synced.mark && hammer_synced.marked_image)
				hammer_synced.mark.underlays -= hammer_synced.marked_image
				hammer_synced.marked_image = null
			var/mob/living/L = target
			if(L.mob_size >= MOB_SIZE_LARGE)
				hammer_synced.mark = L
				var/image/I = image('icons/effects/effects.dmi', loc = L, icon_state = "shield2",pixel_y = (-L.pixel_y),pixel_x = (-L.pixel_x))
				L.underlays += I
				hammer_synced.marked_image = I
		var/target_turf = get_turf(target)
		if(istype(target_turf, /turf/simulated/mineral))
			var/turf/simulated/mineral/M = target_turf
			new /obj/effect/temp_visual/kinetic_blast(M)
			M.gets_drilled(firer)
	..()

/obj/item/twohanded/required/mining_hammer/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = get_turf(src)
		if(!istype(proj_turf, /turf))
			return
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure > 50)
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
			return
		var/obj/item/projectile/destabilizer/D = new /obj/item/projectile/destabilizer(user.loc)
		D.preparePixelProjectile(target,get_turf(target), user)
		D.hammer_synced = src
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, 1)
		D.fire()
		charged = 0
		icon_state = "mining_hammer1_uncharged"
		spawn(charge_time)
			Recharge()
		return
	if(proximity_flag && target == mark && isliving(target))
		var/mob/living/L = target
		new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
		mark = 0
		if(L.mob_size >= MOB_SIZE_LARGE)
			L.underlays -= marked_image
			QDEL_NULL(marked_image)
			var/backstab = check_target_facings(user, L)
			var/def_check = L.getarmor(type = "bomb")
			if(backstab == FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR || backstab == FACING_SAME_DIR)
				L.apply_damage(80, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong
			else
				L.apply_damage(50, BRUTE, blocked = def_check)

/obj/item/twohanded/required/mining_hammer/proc/Recharge()
	if(!charged)
		charged = 1
		icon_state = "mining_hammer1"
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
