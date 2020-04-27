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
	req_access = list(ACCESS_MINERAL_STOREROOM)
	speed_process = TRUE
	layer = BELOW_OBJ_LAYER
	var/req_access_reclaim = ACCESS_MINING_STATION
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
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/ore_redemption/golem
	req_access = list(ACCESS_FREE_GOLEMS)
	req_access_reclaim = ACCESS_FREE_GOLEMS

/obj/machinery/mineral/ore_redemption/golem/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/ore_redemption/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/assembly/igniter(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
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

	for(var/obj/machinery/requests_console/D in GLOB.allRequestConsoles)
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

	if(istype(W, /obj/item/disk/design_disk))
		if(user.drop_item())
			W.forceMove(src)
			inserted_disk = W
			interact(user)
			return TRUE

	return ..()


/obj/machinery/mineral/ore_redemption/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/mineral/ore_redemption/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!powered())
		return
	if(!I.tool_start_check(user, 0))
		return
	input_dir = turn(input_dir, -90)
	output_dir = turn(output_dir, -90)
	to_chat(user, "<span class='notice'>You change [src]'s I/O settings, setting the input to [dir2text(input_dir)] and the output to [dir2text(output_dir)].</span>")

/obj/machinery/mineral/ore_redemption/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "ore_redemption-open", "ore_redemption", I))
		updateUsrDialog()
		return TRUE

/obj/machinery/mineral/ore_redemption/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I))
		return TRUE

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

/obj/machinery/mineral/ore_redemption/ex_act(severity)
	do_sparks(5, TRUE, src)
	..()

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
