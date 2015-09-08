//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_STATION_AREATYPE "/area/supply/station" //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE "/area/supply/dock"	//Type of the supply shuttle area for dock
#define COMP_SCREEN_WIDTH 600 //width of supply computer interaction window
#define COMP_SCREEN_HEIGHT 555 //height of supply computer interaction window

var/datum/controller/supply/supply_controller = new()

var/list/mechtoys = list(
	/obj/item/toy/prize/ripley,
	/obj/item/toy/prize/fireripley,
	/obj/item/toy/prize/deathripley,
	/obj/item/toy/prize/gygax,
	/obj/item/toy/prize/durand,
	/obj/item/toy/prize/honk,
	/obj/item/toy/prize/marauder,
	/obj/item/toy/prize/seraph,
	/obj/item/toy/prize/mauler,
	/obj/item/toy/prize/odysseus,
	/obj/item/toy/prize/phazon
)

/area/supply/station
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/supply/dock
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

//SUPPLY PACKS MOVED TO /code/defines/obj/supplypacks.dm

/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	var/list/mobs_can_pass = list(
		/mob/living/carbon/slime,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone
		)

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/stool/bed/B = A
	if (istype(A, /obj/structure/stool/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/vehicle))	//no vehicles
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.is_small)
				return ..()
		return 0

	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

	New()
		air_update_turf(1)
		..()

	Destroy()
		air_update_turf(1)
		return ..()

	CanAtmosPass(turf/T)
		return 0

/obj/machinery/computer/supplycomp
	name = "Supply Shuttle Console"
	desc = "Used to order supplies."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "supply"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/supplycomp
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/hacked = 0
	var/can_order_contraband = 0
	var/last_viewed_group = "categories"
	var/datum/supply_packs/content_pack

/obj/machinery/computer/ordercomp
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "request"
	circuit = /obj/item/weapon/circuitboard/ordercomp
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/last_viewed_group = "categories"
	var/datum/supply_packs/content_pack

/*
/obj/effect/marker/supplymarker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = 101
	anchored = 1
	opacity = 0
*/

/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/comment = null

/datum/controller/supply
	processing = 1
	//processing_interval = 300
	//supply points
	var/points = 50
	var/points_per_process = 1
	var/points_per_slip = 2
	var/points_per_crate = 5
	var/points_per_plasma = 5
	var/points_per_intel = 250			//points gained per intel returned
	var/points_per_design = 25			//points gained per max reliability research design returned (only for initilally unreliable designs)

	var/list/techLevels = list()
	var/list/researchDesigns = list()
	//control
	var/ordernum
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
	//shuttle movement
	var/movetime = 1200
	var/datum/shuttle/ferry/supply/shuttle

/datum/controller/supply/New()
	ordernum = rand(1,9000)

//Supply shuttle ticker - handles supply point regeneration and shuttle travelling between centcomm and the station
/datum/controller/supply/proc/process()
	for(var/typepath in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		if(P.name == "HEADER")
			qdel(P)
			continue
		supply_packs[P.name] = P

	spawn(0)
		if(processing)
			iteration++
			points += points_per_process

			//sleep(processing_interval)

//To stop things being sent to centcomm which should not be sent to centcomm. Recursively checks for these types.
/datum/controller/supply/proc/forbidden_atoms_check(atom/A)
	if(istype(A,/mob/living))
		return 1
	if(istype(A,/obj/item/weapon/disk/nuclear))
		return 1
	if(istype(A,/obj/item/flag/nation))
		return 1
	if(istype(A,/obj/machinery/nuclearbomb))
		return 1
	if(istype(A,/obj/item/device/radio/beacon))
		return 1

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
			return 1

	//Sellin
/datum/controller/supply/proc/sell()
	var/area/area_shuttle = shuttle.get_location_area()
	if(!area_shuttle)	return

	var/plasma_count = 0
	var/intel_count = 0

	for(var/atom/movable/MA in area_shuttle)
		if(MA.anchored)	continue

		// Must be in a crate!
		if(istype(MA,/obj/structure/closet/crate))
			callHook("sell_crate", list(MA, area_shuttle))  // check this

			points += points_per_crate
			var/find_slip = 1

			for(var/atom in MA)
				// Sell manifests
				var/atom/A = atom
				if(find_slip && istype(A,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/slip = A
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						points += points_per_slip
						find_slip = 0

				// Sell plasma
				if(istype(A, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = A
					plasma_count += P.amount

				// Sell syndicate intel
				if(istype(A, /obj/item/documents/syndicate))
					++intel_count

				// Sell tech levels
				if(istype(A, /obj/item/weapon/disk/tech_disk))
					var/obj/item/weapon/disk/tech_disk/disk = A
					if(!disk.stored) continue
					var/datum/tech/tech = disk.stored

					var/cost = tech.getCost(techLevels[tech.id])
					if(cost)
						techLevels[tech.id] = tech.level
						points += cost

				// Sell max reliablity designs
				if(istype(A, /obj/item/weapon/disk/design_disk))
					var/obj/item/weapon/disk/design_disk/disk = A
					if(!disk.blueprint) continue
					var/datum/design/design = disk.blueprint
					if(design.id in researchDesigns) continue

					if(initial(design.reliability) < 100 && design.reliability >= 100)
						// Maxed out reliability designs only.
						points += points_per_design
						researchDesigns += design.id

				// If you send something in a crate, centcom's keeping it! - fixes secure crates being sent to centom to open them
				qdel(A)
		qdel(MA)

	if(plasma_count)
		points += plasma_count * points_per_plasma

	if(intel_count)
		points += intel_count * points_per_intel

//Buyin
/datum/controller/supply/proc/buy()
	if(!shoppinglist.len) return

	var/area/area_shuttle = shuttle.get_location_area()
	if(!area_shuttle)	return

	var/list/clear_turfs = list()

	for(var/turf/T in area_shuttle)
		if(T.density)	continue
		var/contcount
		for(var/atom/A in T.contents)
			if(istype(A,/atom/movable/lighting_overlay))
				continue
			if(!A.simulated)
				continue
			contcount++
		if(contcount)	continue
		clear_turfs += T

	for(var/S in shoppinglist)
		if(!clear_turfs.len)	break
		var/i = rand(1,clear_turfs.len)
		var/turf/pickedloc = clear_turfs[i]
		clear_turfs.Cut(i,i+1)

		var/datum/supply_order/SO = S
		var/datum/supply_packs/SP = SO.object

		var/atom/A = new SP.containertype(pickedloc)
		A.name = "[SP.containername]"// [SO.comment ? "([SO.comment])":"" ]"

		//supply manifest generation begin

		var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest(A)
		slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
		slip.info +="Order #[SO.ordernum]<br>"
		slip.info +="Destination: [station_name]<br>"
		slip.info +="[shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>"
		slip.info +="CONTENTS:<br><ul>"

		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access)
			A:req_access = list()
			A:req_access += text2num(SP.access)

		var/list/contains
		if(istype(SP,/datum/supply_packs/misc/randomised))
			var/datum/supply_packs/misc/randomised/SPR = SP
			contains = list()
			if(SPR.contains.len)
				for(var/j=1,j<=SPR.num_contained,j++)
					contains += pick(SPR.contains)
		else
			contains = SP.contains

		for(var/typepath in contains)
			if(!typepath)	continue
			var/atom/B2 = new typepath(A)
			if(SP.amount && B2:amount) B2:amount = SP.amount
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation
		slip.info += "</ul><br>"
		slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"
		if(!SP.contraband)
			if(istype(A, /obj/structure/closet/crate))
				var/obj/structure/closet/crate/CR = A
				CR.manifest = slip
				CR.update_icon()
			if(istype(A, /obj/structure/largecrate))
				var/obj/structure/largecrate/LC = A
				LC.manifest = slip
				LC.update_icon()
		else slip.loc = null	//we are out of blanks for Form #44-D Ordering Illicit Drugs.
	shoppinglist.Cut()
	return

/obj/item/weapon/paper/manifest
	name = "Supply Manifest"

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	ui_interact(usr)
	return

/obj/machinery/computer/ordercomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	// data to send to ui
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_groups)
		category_list.Add(list(list("name" = get_supply_group_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in supply_controller.supply_packs)
		var/datum/supply_packs/pack = supply_controller.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden && pack.group == cat)
			// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
			packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_access"] = get_access_desc(content_pack.access)

	var/requests_list[0]
	for(var/set_name in supply_controller.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			// Check if the usr owns the request, so they can cancel requests
			var/obj/item/weapon/card/id/I = usr.get_id_card()
			var/owned = 0
			if(I && SO.orderedby == I.registered_name)
				owned = 1
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "owned" = owned, "command1" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in supply_controller.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby)))
	data["orders"] = orders_list

	data["points"] = supply_controller.points
	data["send"] = list("send" = 1)

	var/datum/shuttle/ferry/supply/shuttle = supply_controller.shuttle
	data["moving"] = shuttle.has_arrive_time()
	data["at_station"] = shuttle.at_station()
	data["timeleft"] = shuttle.eta_minutes()
	if(shuttle.docking_controller)
		data["docked"] = capitalize(shuttle.docking_controller.get_docking_status())

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, COMP_SCREEN_WIDTH, COMP_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return 1

	if (href_list["doorder"])
		if(world.time < reqtime)
			visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			nanomanager.update_uis(src)
			return

		var/index = copytext(href_list["doorder"], 1, lentext(href_list["doorder"])) //text2num(copytext(href_list["doorder"], 1))
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return
		var/datum/supply_packs/P = supply_controller.supply_packs[index]
		if(!istype(P))
			return
		var/crates = 1
		if(multi)
			var/num_input = input(usr, "Amount:", "How many crates?", "") as num
			crates = Clamp(round(text2num(num_input)), 1, 20)
			if(..())
				return

		var/timeout = world.time + 600
		var/reason = sanitize(copytext(input(usr,"Reason:","Why do you require this item?","") as null|text,1,MAX_MESSAGE_LEN))
		if(world.time > timeout || !reason || ..())
			return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		supply_controller.ordernum++
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "Requisition Form - [crates] '[P.name]' for [idname]"
		reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
		reqform.info += "INDEX: #[supply_controller.ordernum]<br>"
		reqform.info += "REQUESTED BY: [idname]<br>"
		reqform.info += "RANK: [idrank]<br>"
		reqform.info += "REASON: [reason]<br>"
		reqform.info += "SUPPLY CRATE TYPE: [P.name]<br>"
		reqform.info += "NUMBER OF CRATES: [crates]<br>"
		reqform.info += "ACCESS RESTRICTION: [replacetext(get_access_desc(P.access))]<br>"
		reqform.info += "CONTENTS:<br>"
		reqform.info += P.manifest
		reqform.info += "<hr>"
		reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datums
		for(var/i = 1; i <= crates; i++)
			supply_controller.ordernum++
			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = supply_controller.ordernum
			O.object = P
			O.orderedby = idname
			O.comment = reason
			supply_controller.requestlist += O

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		var/obj/item/weapon/card/id/I = usr.get_id_card()
		for(var/i=1, i<=supply_controller.requestlist.len, i++)
			var/datum/supply_order/SO = supply_controller.requestlist[i]
			if(SO.ordernum == ordernum && (I && SO.orderedby == I.registered_name))
				supply_controller.requestlist.Cut(i,i+1)
				break

	else if (href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if (href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_packs/P = supply_controller.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)
	return

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user) && !isobserver(user))
		user << "<span class='warning'>Access denied.</span>"
		return

	post_signal("supply")
	ui_interact(user)
	return

/obj/machinery/computer/supplycomp/emag_act(user as mob)
	if(!hacked)
		user << "<span class='notice'>Special supplies unlocked.</span>"
		hacked = 1
		return

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	// data to send to ui
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_groups)
		category_list.Add(list(list("name" = get_supply_group_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in supply_controller.supply_packs)
		var/datum/supply_packs/pack = supply_controller.supply_packs[set_name]
		if((pack.hidden && src.hacked) || (pack.contraband && src.can_order_contraband) || (!pack.contraband && !pack.hidden))
			if(pack.group == cat)
				// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_access"] = get_access_desc(content_pack.access)

	var/requests_list[0]
	for(var/set_name in supply_controller.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No comment."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in supply_controller.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list

	data["points"] = supply_controller.points
	data["send"] = list("send" = 1)

	var/datum/shuttle/ferry/supply/shuttle = supply_controller.shuttle
	data["moving"] = shuttle.has_arrive_time()
	data["at_station"] = shuttle.at_station()
	data["timeleft"] = shuttle.eta_minutes()
	data["can_launch"] = shuttle.can_launch()
	data["can_force"] = shuttle.can_force()
	data["can_cancel"] = shuttle.can_cancel()
	if(shuttle.docking_controller)
		data["docked"] = capitalize(shuttle.docking_controller.get_docking_status())

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "supply_console.tmpl", name, COMP_SCREEN_WIDTH, COMP_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/supplycomp/proc/is_authorized(user)
	if(allowed(user))
		return 1

	if(isobserver(user) && check_rights(R_ADMIN, 0))
		return 1

	return 0

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return 1

	if(!is_authorized(usr))
		return 1

	if(!supply_controller)
		log_to_dd("## ERROR: The supply_controller controller datum is missing somehow.")
		return 1

	var/datum/shuttle/ferry/supply/shuttle = supply_controller.shuttle
	if(!shuttle)
		log_to_dd("## ERROR: The supply or shuttle datum is missing somehow.")
		return 1

	if(href_list["send"])
		if(shuttle.at_station())
			if (shuttle.forbidden_atoms_check())
				usr = "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>"
			else
				shuttle.launch(src)
		else
			shuttle.launch(src)
			post_signal("supply")

	if (href_list["force_send"])
		shuttle.force_launch(src)

	if (href_list["cancel_send"])
		shuttle.cancel_launch(src)

	else if (href_list["doorder"])
		if(world.time < reqtime)
			visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			nanomanager.update_uis(src)
			return

		var/index = copytext(href_list["doorder"], 1, lentext(href_list["doorder"])) //text2num(copytext(href_list["doorder"], 1))
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return
		var/datum/supply_packs/P = supply_controller.supply_packs[index]
		if(!istype(P))
			return
		var/crates = 1
		if(multi)
			var/num_input = input(usr, "Amount:", "How many crates?", "") as num
			crates = Clamp(round(text2num(num_input)), 1, 20)
			if(..())
				return

		var/timeout = world.time + 600
		var/reason = sanitize(copytext(input(usr,"Reason:","Why do you require this item?","") as null|text,1,MAX_MESSAGE_LEN))
		if(world.time > timeout || !reason || ..())
			return

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		supply_controller.ordernum++
		var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(loc)
		reqform.name = "Requisition Form - [crates] '[P.name]' for [idname]"
		reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
		reqform.info += "INDEX: #[supply_controller.ordernum]<br>"
		reqform.info += "REQUESTED BY: [idname]<br>"
		reqform.info += "RANK: [idrank]<br>"
		reqform.info += "REASON: [reason]<br>"
		reqform.info += "SUPPLY CRATE TYPE: [P.name]<br>"
		reqform.info += "NUMBER OF CRATES: [crates]<br>"
		reqform.info += "ACCESS RESTRICTION: [replacetext(get_access_desc(P.access))]<br>"
		reqform.info += "CONTENTS:<br>"
		reqform.info += P.manifest
		reqform.info += "<hr>"
		reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

		reqform.update_icon()	//Fix for appearing blank when printed.
		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		for(var/i = 1; i <= crates; i++)
			supply_controller.ordernum++
			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = supply_controller.ordernum
			O.object = P
			O.orderedby = idname
			O.comment = reason
			supply_controller.requestlist += O

	else if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		for(var/i=1, i<=supply_controller.requestlist.len, i++)
			var/datum/supply_order/SO = supply_controller.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
				if(supply_controller.points >= P.cost)
					supply_controller.requestlist.Cut(i,i+1)
					supply_controller.points -= P.cost
					supply_controller.shoppinglist += O
				else
					usr << "<span class='warning'>There are insufficient supply points for this request.</span>"
				break

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=supply_controller.requestlist.len, i++)
			var/datum/supply_order/SO = supply_controller.requestlist[i]
			if(SO.ordernum == ordernum)
				supply_controller.requestlist.Cut(i,i+1)
				break

	else if (href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if (href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_packs/P = supply_controller.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)
