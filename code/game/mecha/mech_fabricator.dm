/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	var/time_coeff = 1
	var/component_coeff = 1
	var/datum/research/files
	var/fabricator_type = MECHFAB
	var/id
	var/sync = 0
	var/part_set
	var/datum/design/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = "main"
	var/temp
	var/list/part_sets = list(
								"Cyborg",
								"Cyborg Repair",
								"Ripley",
								"Firefighter",
								"Odysseus",
								"Gygax",
								"Durand",
								"H.O.N.K",
								"Reticence",
								"Phazon",
								"Exosuit Equipment",
								"Cyborg Upgrade Modules",
								"Misc"
								)

/obj/machinery/mecha_part_fabricator/New()
	var/datum/component/material_container/materials = AddComponent(/datum/component/material_container,
		list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), 0,
		FALSE, /obj/item/stack, CALLBACK(src, .proc/is_insertion_ready), CALLBACK(src, .proc/AfterMaterialInsert))
	materials.precise_insertion = TRUE
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()
	files = new /datum/research(src) //Setup the research data holder.

/obj/machinery/mecha_part_fabricator/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mecha_part_fabricator/Destroy()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/T = 0

	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.max_amount = (200000 + (T*50000))

	//resources adjustment coefficient (1 -> 0.85 -> 0.7 -> 0.55)
	T = 1.15
	for(var/obj/item/stock_parts/micro_laser/Ma in component_parts)
		T -= Ma.rating*0.15
	component_coeff = T

	//building time adjustment coefficient (1 -> 0.8 -> 0.6)
	T = -1
	for(var/obj/item/stock_parts/manipulator/Ml in component_parts)
		T += Ml.rating
	time_coeff = round(initial(time_coeff) - (initial(time_coeff)*(T))/5,0.01)


/obj/machinery/mecha_part_fabricator/proc/output_parts_list(set_name)
	var/output = ""
	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		if(D.build_type & fabricator_type)
			if(!(set_name in D.category))
				continue
			output += "<div class='part'>[output_part_info(D)]<br>\["
			if(check_resources(D))
				output += "<a href='?src=[UID()];part=[D.id]'>Build</a> | "
			output += "<a href='?src=[UID()];add_to_queue=[D.id]'>Add to queue</a>\]\[<a href='?src=[UID()];part_desc=[D.id]'>?</a>\]</div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_info(datum/design/D)
	var/output = "[initial(D.name)] (Cost: [output_part_cost(D)]) [get_construction_time_w_coeff(D)/10] seconds"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_cost(datum/design/D)
	var/i = 0
	var/output
	for(var/c in D.materials)
		output += "[i?" | ":null][get_resource_cost_w_coeff(D, c)] [material2name(c)]"
		i++
	return output

/obj/machinery/mecha_part_fabricator/proc/output_available_resources()
	var/output
	GET_COMPONENT(materials, /datum/component/material_container)
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		output += "<span class=\"res_name\">[M.name]: </span>[M.amount] cm&sup3;"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT)
			output += "<span style='font-size:80%;'>- Remove \[<a href='?src=[UID()];remove_mat=1;material=[mat_id]'>1</a>\]"
			if(M.amount >= (MINERAL_MATERIAL_AMOUNT * 10))
				output += " | \[<a href='?src=[UID()];remove_mat=10;material=[mat_id]'>10</a>\]"
			output += " | \[<a href='?src=[UID()];remove_mat=50;material=[mat_id]'>All</a>\]</span>"
		output += "<br/>"
	return output

/obj/machinery/mecha_part_fabricator/proc/get_resources_w_coeff(datum/design/D)
	var/list/resources = list()
	for(var/R in D.materials)
		resources[R] = get_resource_cost_w_coeff(D, R)
	return resources

/obj/machinery/mecha_part_fabricator/proc/check_resources(datum/design/D)
	if(D.reagents_list.len) // No reagents storage - no reagent designs.
		return FALSE
	GET_COMPONENT(materials, /datum/component/material_container)
	if(materials.has_materials(get_resources_w_coeff(D)))
		return TRUE
	return FALSE

/obj/machinery/mecha_part_fabricator/proc/build_part(datum/design/D)
	being_built = D
	desc = "It's building \a [initial(D.name)]."
	var/list/res_coef = get_resources_w_coeff(D)

	GET_COMPONENT(materials, /datum/component/material_container)
	materials.use_amount(res_coef)
	overlays += "fab-active"
	use_power = ACTIVE_POWER_USE
	updateUsrDialog()
	sleep(get_construction_time_w_coeff(D))
	use_power = IDLE_POWER_USE
	overlays -= "fab-active"
	desc = initial(desc)

	var/obj/item/I = new D.build_path(loc)
	if(D.locked)
		var/obj/item/storage/lockbox/large/L = new /obj/item/storage/lockbox/large(get_step(src, SOUTH)) //(Don't use capitals in paths, or single letters.
		I.forceMove(L)
		L.name += " [initial(I.name)]"
		L.origin_tech = I.origin_tech
	else
		I.forceMove(get_step(src, SOUTH))
	if(istype(I))
		I.materials = res_coef
	atom_say("[I] is complete.")
	being_built = null

	updateUsrDialog()
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/update_queue_on_page()
	send_byjax(usr,"mecha_fabricator.browser","queue",list_queue())
	return

/obj/machinery/mecha_part_fabricator/proc/add_part_set_to_queue(set_name)
	if(set_name in part_sets)
		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(D.build_type & fabricator_type)
				if(set_name in D.category)
					add_to_queue(D)

/obj/machinery/mecha_part_fabricator/proc/add_to_queue(D)
	if(!istype(queue))
		queue = list()
	if(D)
		queue[++queue.len] = D
	return queue.len

/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return FALSE
	queue.Cut(index,++index)
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/process_queue()
	var/datum/design/D = queue[1]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	temp = null
	while(D)
		if(stat&(NOPOWER|BROKEN))
			return FALSE
		if(!check_resources(D))
			atom_say("Not enough resources. Queue processing stopped.")
			temp = {"<span class='alert'>Not enough resources to build next part.</span><br>
						<a href='?src=[UID()];process_queue=1'>Try again</a> | <a href='?src=[UID()];clear_temp=1'>Return</a><a>"}
			return FALSE
		remove_from_queue(1)
		build_part(D)
		D = listgetindex(queue, 1)
	atom_say("Queue processing finished successfully.")

/obj/machinery/mecha_part_fabricator/proc/list_queue()
	var/output = "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		output += "<br>Nothing"
	else
		output += "<ol>"
		var/i = 0
		for(var/datum/design/D in queue)
			i++
			var/obj/part = D.build_path
			output += "<li[!check_resources(D)?" style='color: #f00;'":null]>"
			output += initial(part.name) + " - "
			output += "[i>1?"<a href='?src=[UID()];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] "
			output += "[i<queue.len?"<a href='?src=[UID()];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] "
			output += "<a href='?src=[UID()];remove_from_queue=[i]'>Remove</a></li>"

		output += "</ol>"
		output += "\[<a href='?src=[UID()];process_queue=1'>Process queue</a> | <a href='?src=[UID()];clear_queue=1'>Clear queue</a>\]"
	return output

/obj/machinery/mecha_part_fabricator/proc/sync()
	temp = "Updating local R&D database..."
	updateUsrDialog()
	sleep(30) //only sleep if called by user
	var/area/localarea = get_area(src)

	for(var/obj/machinery/computer/rdconsole/RDC in localarea.contents)
		if(!RDC.sync)
			continue
		RDC.files.push_data(files)
		temp = "Processed equipment designs.<br>"
		//check if the tech coefficients have changed
		temp += "<a href='?src=[UID()];clear_temp=1'>Return</a>"

		updateUsrDialog()
		atom_say("Successfully synchronized with R&D server.")
		return

	temp = "Unable to connect to local R&D Database.<br>Please check your connections and try again.<br><a href='?src=[UID()];clear_temp=1'>Return</a>"
	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(datum/design/D, resource, roundto = 1)
	return round(D.materials[resource]*component_coeff, roundto)

/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(datum/design/D, roundto = 1) //aran
	return round(initial(D.construction_time)*time_coeff, roundto)

/obj/machinery/mecha_part_fabricator/attack_ghost(mob/user)
	interact(user)

/obj/machinery/mecha_part_fabricator/attack_hand(mob/user)
	if(..())
		return 1
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1
	return interact(user)

/obj/machinery/mecha_part_fabricator/interact(mob/user)
	var/dat, left_part
	if(..())
		return
	user.set_machine(src)
	var/turf/exit = get_step(src,(dir))
	if(exit.density)
		atom_say("Error! Part outlet is obstructed.")
		return
	if(temp)
		left_part = temp
	else if(being_built)
		var/obj/I = being_built.build_path
		left_part = {"<TT>Building [initial(I.name)].<BR>
							Please wait until completion...</TT>"}
	else
		switch(screen)
			if("main")
				left_part = output_available_resources()+"<hr>"
				left_part += "<a href='?src=[UID()];sync=1'>Sync with R&D servers</a><hr>"
				for(var/part_set in part_sets)
					left_part += "<a href='?src=[UID()];part_set=[part_set]'>[part_set]</a> - \[<a href='?src=[UID()];partset_to_queue=[part_set]'>Add all parts to queue</a>\]<br>"
			if("parts")
				left_part += output_parts_list(part_set)
				left_part += "<hr><a href='?src=[UID()];screen=main'>Return</a>"
	dat = {"

			  <title>[name]</title>
				<style>
				.res_name {font-weight: bold; text-transform: capitalize;}
				.red {color: #f00;}
				.part {margin-bottom: 10px;}
				.arrow {text-decoration: none; font-size: 10px;}
				body, table {height: 100%;}
				td {vertical-align: top; padding: 5px;}
				html, body {padding: 0px; margin: 0px;}
				h1 {font-size: 18px; margin: 5px 0px;}
				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>

				<table style='width: 100%;'>
				<tr>
				<td style='width: 65%; padding-right: 10px;'>
				[left_part]
				</td>
				<td style='width: 35%; background: #000;' id='queue'>
				[list_queue()]
				</td>
				<tr>
				</table>"}
	var/datum/browser/popup = new(user, "mecha_fabricator", name, 1000, 600)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "mecha_fabricator")
	return

/obj/machinery/mecha_part_fabricator/Topic(href, href_list)
	if(..())
		return 1
	var/datum/topic_input/afilter = new /datum/topic_input(href,href_list)
	if(href_list["part_set"])
		var/tpart_set = afilter.getStr("part_set")
		if(tpart_set)
			if(tpart_set=="clear")
				part_set = null
			else
				part_set = tpart_set
				screen = "parts"
	if(href_list["part"])
		var/T = afilter.getStr("part")
		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(D.build_type & fabricator_type)
				if(D.id == T)
					if(!processing_queue)
						build_part(D)
					else
						add_to_queue(D)
					break
	if(href_list["add_to_queue"])
		var/T = afilter.getStr("add_to_queue")
		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(D.build_type & fabricator_type)
				if(D.id == T)
					add_to_queue(D)
					break
		return update_queue_on_page()
	if(href_list["remove_from_queue"])
		remove_from_queue(afilter.getNum("remove_from_queue"))
		return update_queue_on_page()
	if(href_list["partset_to_queue"])
		add_part_set_to_queue(afilter.get("partset_to_queue"))
		return update_queue_on_page()
	if(href_list["process_queue"])
		spawn(0)
			if(processing_queue || being_built)
				return FALSE
			processing_queue = 1
			process_queue()
			processing_queue = 0
	if(href_list["clear_temp"])
		temp = null
	if(href_list["screen"])
		screen = href_list["screen"]
	if(href_list["queue_move"] && href_list["index"])
		var/index = afilter.getNum("index")
		var/new_index = index + afilter.getNum("queue_move")
		if(isnum(index) && isnum(new_index))
			if(IsInRange(new_index,1,queue.len))
				queue.Swap(index,new_index)
		return update_queue_on_page()
	if(href_list["clear_queue"])
		queue = list()
		return update_queue_on_page()
	if(href_list["sync"])
		sync()
	if(href_list["part_desc"])
		var/T = afilter.getStr("part_desc")
		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(D.build_type & fabricator_type)
				if(D.id == T)
					var/obj/part = D.build_path
					temp = {"<h1>[initial(part.name)] description:</h1>
								[initial(part.desc)]<br>
								<a href='?src=[UID()];clear_temp=1'>Return</a>
								"}
					break

	if(href_list["remove_mat"] && href_list["material"])
		GET_COMPONENT(materials, /datum/component/material_container)
		materials.retrieve_sheets(text2num(href_list["remove_mat"]), href_list["material"])

	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name = material2name(id_inserted)
	overlays += "fab-load-[stack_name]"
	sleep(10)
	overlays -= "fab-load-[stack_name]"
	updateUsrDialog()

/obj/machinery/mecha_part_fabricator/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return TRUE

	else
		return ..()

/obj/machinery/mecha_part_fabricator/proc/material2name(ID)
	return copytext(ID,2)

/obj/machinery/mecha_part_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE

	return TRUE

/obj/machinery/mecha_part_fabricator/spacepod
	name = "spacepod fabricator"
	fabricator_type = PODFAB
	part_sets = list(			"Pod_Weaponry",
								"Pod_Armor",
								"Pod_Cargo",
								"Pod_Parts",
								"Pod_Frame",
								"Misc")
	req_access = list(access_mechanic)

/obj/machinery/mecha_part_fabricator/spacepod/New()
	..()
	QDEL_LIST(component_parts)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/podfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/mecha_part_fabricator/robot
	name = "Robotic Fabricator"
	part_sets = list("Cyborg")
