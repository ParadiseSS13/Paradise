/obj/item/paper/manifest
	name = "supply manifest"
	var/erroneous = 0
	var/points = 0
	var/ordernumber = 0

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 1200

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

/obj/docking_port/mobile/supply/register()
	if(!..())
		return 0
	SSshuttle.supply = src
	return 1

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return forbidden_atoms_check(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	. = ..()
	if(.)	return .

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!is_station_level(z))		//we only buy when we are -at- the station
		return 1

	if(!SSshuttle.shoppinglist.len)
		return 2

	var/list/emptyTurfs = list()
	for(var/turf/simulated/T in areaInstance)
		if(T.density)
			continue

		var/contcount
		for(var/atom/A in T.contents)
			if(!A.simulated)
				continue
			if(istype(A, /obj/machinery/light))
				continue //hacky but whatever, shuttles need three spots each for this shit
			contcount++

		if(contcount)
			continue

		emptyTurfs += T

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!SO.object)
			throw EXCEPTION("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			SSshuttle.shoppinglist.Cut(1, SSshuttle.shoppinglist.Find(SO))
			return

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
			investigate_log("Supply order #[SO] generated a manifest with packages incorrectly counted.", INVESTIGATE_CARGO)
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
			investigate_log("Supply order #[SO] generated a manifest with destination station incorrect.", INVESTIGATE_CARGO)
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM
			investigate_log("Supply order #[SO] generated a manifest with package incomplete.", INVESTIGATE_CARGO)
		SO.createObject(T, errors)

	SSshuttle.shoppinglist.Cut()

/obj/docking_port/mobile/supply/proc/sell()
	if(z != level_name_to_num(CENTCOMM))		//we only sell when we are -at- centcomm
		return 1

	var/plasma_count = 0
	var/intel_count = 0
	var/crate_count = 0

	var/msg = "<center>---[station_time_timestamp()]---</center><br>"
	var/pointsEarned

	for(var/atom/movable/MA in areaInstance)
		if(MA.anchored)
			continue
		if(istype(MA, /mob/dead))
			continue
		SSshuttle.sold_atoms += " [MA.name]"

		// Must be in a crate (or a critter crate)!
		if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/critter))
			SSshuttle.sold_atoms += ":"
			if(!MA.contents.len)
				SSshuttle.sold_atoms += " (empty)"
			++crate_count

			var/find_slip = 1
			for(var/thing in MA)
				// Sell manifests
				SSshuttle.sold_atoms += " [thing:name]"
				if(find_slip && istype(thing,/obj/item/paper/manifest))
					var/obj/item/paper/manifest/slip = thing
					// TODO: Check for a signature, too.
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						// Did they mark it as erroneous?
						var/denied = 0
						for(var/i=1,i<=slip.stamped.len,i++)
							if(slip.stamped[i] == /obj/item/stamp/denied)
								denied = 1
						if(slip.erroneous && denied) // Caught a mistake by Centcom (IDEA: maybe Centcom rarely gets offended by this)
							pointsEarned = slip.points - SSshuttle.points_per_crate
							SSshuttle.points += pointsEarned // For now, give a full refund for paying attention (minus the crate cost)
							msg += "<span class='good'>+[pointsEarned]</span>: Station correctly denied package [slip.ordernumber]: "
							if(slip.erroneous & MANIFEST_ERROR_NAME)
								msg += "Destination station incorrect. "
							else if(slip.erroneous & MANIFEST_ERROR_COUNT)
								msg += "Packages incorrectly counted. "
							else if(slip.erroneous & MANIFEST_ERROR_ITEM)
								msg += "Package incomplete. "
							msg += "Points refunded.<br>"
						else if(!slip.erroneous && !denied) // Approving a proper order awards the relatively tiny points_per_slip
							SSshuttle.points += SSshuttle.points_per_slip
							msg += "<span class='good'>+[SSshuttle.points_per_slip]</span>: Package [slip.ordernumber] accorded.<br>"
						else // You done goofed.
							if(slip.erroneous)
								msg += "<span class='good'>+0</span>: Station approved package [slip.ordernumber] despite error: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect."
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted."
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "We found unshipped items on our dock."
								msg += "  Be more vigilant.<br>"
							else
								pointsEarned = round(SSshuttle.points_per_crate - slip.points)
								SSshuttle.points += pointsEarned
								msg += "<span class='bad'>[pointsEarned]</span>: Station denied package [slip.ordernumber]. Our records show no fault on our part.<br>"
						find_slip = 0
					continue

				// Sell plasma
				if(istype(thing, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = thing
					plasma_count += P.amount

				// Sell syndicate intel
				if(istype(thing, /obj/item/documents/syndicate))
					++intel_count

				// Sell tech levels
				if(istype(thing, /obj/item/disk/tech_disk))
					var/obj/item/disk/tech_disk/disk = thing
					if(!disk.stored) continue
					var/datum/tech/tech = disk.stored

					var/cost = tech.getCost(SSshuttle.techLevels[tech.id])
					if(cost)
						SSshuttle.techLevels[tech.id] = tech.level
						SSshuttle.points += cost
						for(var/mob/M in GLOB.player_list)
							if(M.mind)
								for(var/datum/job_objective/further_research/objective in M.mind.job_objectives)
									objective.unit_completed(cost)
						msg += "<span class='good'>+[cost]</span>: [tech.name] - new data.<br>"

				// Sell designs
				if(istype(thing, /obj/item/disk/design_disk))
					var/obj/item/disk/design_disk/disk = thing
					if(!disk.blueprint)
						continue
					var/datum/design/design = disk.blueprint
					if(design.id in SSshuttle.researchDesigns)
						continue
					SSshuttle.points += SSshuttle.points_per_design
					SSshuttle.researchDesigns += design.id
					msg += "<span class='good'>+[SSshuttle.points_per_design]</span>: [design.name] design.<br>"

				// Sell exotic plants
				if(istype(thing, /obj/item/seeds))
					var/obj/item/seeds/S = thing
					if(S.rarity == 0) // Mundane species
						msg += "<span class='bad'>+0</span>: We don't need samples of mundane species \"[capitalize(S.species)]\".<br>"
					else if(SSshuttle.discoveredPlants[S.type]) // This species has already been sent to CentComm
						var/potDiff = S.potency - SSshuttle.discoveredPlants[S.type] // Compare it to the previous best
						if(potDiff > 0) // This sample is better
							SSshuttle.discoveredPlants[S.type] = S.potency
							msg += "<span class='good'>+[potDiff]</span>: New sample of \"[capitalize(S.species)]\" is superior. Good work.<br>"
							SSshuttle.points += potDiff
						else // This sample is worthless
							msg += "<span class='bad'>+0</span>: New sample of \"[capitalize(S.species)]\" is not more potent than existing sample ([SSshuttle.discoveredPlants[S.type]] potency).<br>"
					else // This is a new discovery!
						SSshuttle.discoveredPlants[S.type] = S.potency
						msg += "<span class='good'>[S.rarity + S.potency]</span>: New species discovered: \"[capitalize(S.species)]\". Excellent work.<br>"
						SSshuttle.points += S.rarity + S.potency
		qdel(MA)
		SSshuttle.sold_atoms += "."

	if(plasma_count > 0)
		pointsEarned = round(plasma_count * SSshuttle.points_per_plasma)
		msg += "<span class='good'>+[pointsEarned]</span>: Received [plasma_count] unit(s) of exotic material.<br>"
		SSshuttle.points += pointsEarned

	if(intel_count > 0)
		pointsEarned = round(intel_count * SSshuttle.points_per_intel)
		msg += "<span class='good'>+[pointsEarned]</span>: Received [intel_count] article(s) of enemy intelligence.<br>"
		SSshuttle.points += pointsEarned

	if(crate_count > 0)
		pointsEarned = round(crate_count * SSshuttle.points_per_crate)
		msg += "<span class='good'>+[pointsEarned]</span>: Received [crate_count] crate(s).<br>"
		SSshuttle.points += pointsEarned

	SSshuttle.centcom_message += "[msg]<hr>"

/proc/forbidden_atoms_check(atom/A)
	var/list/blacklist = list(
		/mob/living,
		/obj/structure/blob,
		/obj/structure/spider/spiderling,
		/obj/item/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/radio/beacon,
		/obj/machinery/the_singularitygen,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/telepad_cargo,
		/obj/machinery/clonepod,
		/obj/effect/hierophant,
		/obj/item/warp_cube,
		/obj/machinery/quantumpad,
		/obj/structure/extraction_point
	)
	if(A)
		if(is_type_in_list(A, blacklist))
			return 1
		for(var/thing in A)
			if(.(thing))
				return 1

	return 0

/********************
    SUPPLY ORDER
 ********************/
/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/orderedbyRank
	var/comment = null
	var/crates

/datum/supply_order/proc/generateRequisition(atom/_loc)
	if(!object)
		return

	var/obj/item/paper/reqform = new /obj/item/paper(_loc)
	playsound(_loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	reqform.name = "Requisition Form - [crates] '[object.name]' for [orderedby]"
	reqform.info += "<h3>[station_name()] Supply Requisition Form</h3><hr>"
	reqform.info += "INDEX: #[SSshuttle.ordernum]<br>"
	reqform.info += "REQUESTED BY: [orderedby]<br>"
	reqform.info += "RANK: [orderedbyRank]<br>"
	reqform.info += "REASON: [comment]<br>"
	reqform.info += "SUPPLY CRATE TYPE: [object.name]<br>"
	reqform.info += "NUMBER OF CRATES: [crates]<br>"
	reqform.info += "ACCESS RESTRICTION: [object.access ? get_access_desc(object.access) : "None"]<br>"
	reqform.info += "CONTENTS:<br>"
	reqform.info += object.manifest
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.update_icon()	//Fix for appearing blank when printed.

	return reqform

/datum/supply_order/proc/createObject(atom/_loc, errors=0)
	if(!object)
		return

	//create the crate
	var/atom/Crate = new object.containertype(_loc)
	Crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	if(object.access)
		Crate:req_access = list(text2num(object.access))

	//create the manifest slip
	var/obj/item/paper/manifest/slip = new /obj/item/paper/manifest()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = (errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packagesAmt = SSshuttle.shoppinglist.len + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.name = "Shipping Manifest - '[object.name]' for [orderedby]"
	slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
	slip.info +="Order: #[ordernum]<br>"
	slip.info +="Destination: [stationName]<br>"
	slip.info +="Requested By: [orderedby]<br>"
	slip.info +="Rank: [orderedbyRank]<br>"
	slip.info +="Reason: [comment]<br>"
	slip.info +="Supply Crate Type: [object.name]<br>"
	slip.info +="Access Restriction: [object.access ? get_access_desc(object.access) : "None"]<br>"
	slip.info +="[packagesAmt] PACKAGES IN THIS SHIPMENT<br>"
	slip.info +="CONTENTS:<br><ul>"

	//we now create the actual contents
	var/list/contains
	if(istype(object, /datum/supply_packs/misc/randomised))
		var/datum/supply_packs/misc/randomised/SO = object
		contains = list()
		if(object.contains.len)
			for(var/j=1, j<=SO.num_contained, j++)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(Crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(Crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = Crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"

	if((errors & MANIFEST_ERROR_ITEM))
		//secure and large crates cannot lose items
		if(findtext("[object.containertype]", "/secure/") || findtext("[object.containertype]","/largecrate/"))
			errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lostAmt = max(round(Crate.contents.len/10), 1)
			//lose some of the items
			while(--lostAmt >= 0)
				qdel(pick(Crate.contents))

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.loc = Crate
	if(istype(Crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = Crate
		CR.manifest = slip
		CR.update_icon()
		CR.announce_beacons = object.announce_beacons.Copy()
	if(istype(Crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = Crate
		LC.manifest = slip
		LC.update_icon()

	return Crate

/***************************
    ORDER/REQUESTS CONSOLE
 **************************/
/obj/machinery/computer/supplycomp
	name = "Supply Shuttle Console"
	desc = "Used to order supplies."
	icon_screen = "supply"
	req_access = list(ACCESS_CARGO)
	circuit = /obj/item/circuitboard/supplycomp
	/// Is this a public console (Confirm + Shuttle controls are not visible)
	var/is_public = FALSE
	/// Time of last request
	var/reqtime = 0
	/// Can we order special supplies
	var/hacked = FALSE
	/// Can we order contraband
	var/can_order_contraband = FALSE

/obj/machinery/computer/supplycomp/public
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon = 'icons/obj/machines/computer.dmi'
	icon_screen = "request"
	circuit = /obj/item/circuitboard/ordercomp
	req_access = list()
	is_public = TRUE

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return 1

	post_signal("supply")
	ui_interact(user)
	return

/obj/machinery/computer/supplycomp/emag_act(user as mob)
	if(!hacked)
		add_attack_logs(user, src, "emagged")
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		hacked = TRUE
		return

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CargoConsole", name, 900, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/supplycomp/ui_data(mob/user)
	var/list/data = list()

	var/list/requests_list = list()
	for(var/set_name in SSshuttle.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No comment."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/list/orders_list = list()
	for(var/set_name in SSshuttle.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list

	data["is_public"] = is_public

	data["canapprove"] = (SSshuttle.supply.getDockedId() == "supply_away") && !(SSshuttle.supply.mode != SHUTTLE_IDLE) && !is_public
	data["points"] = round(SSshuttle.points)

	data["moving"] = SSshuttle.supply.mode != SHUTTLE_IDLE
	data["at_station"] = SSshuttle.supply.getDockedId() == "supply_home"
	data["timeleft"] = SSshuttle.supply.timeLeft(600)
	data["can_launch"] = !SSshuttle.supply.canMove()

	return data

/obj/machinery/computer/supplycomp/ui_static_data(mob/user)
	var/list/data = list()
	var/list/packs_list = list()

	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		if((pack.hidden && hacked) || (pack.contraband && can_order_contraband) || (pack.special && pack.special_enabled) || (!pack.contraband && !pack.hidden && !pack.special))
			packs_list.Add(list(list("name" = pack.name, "cost" = pack.cost, "ref" = "[pack.UID()]", "contents" = pack.ui_manifest, "cat" = pack.group)))

	data["supply_packs"] = packs_list

	var/list/categories = list() // meow
	for(var/category in GLOB.all_supply_groups)
		categories.Add(list(list("name" = get_supply_group_name(category), "category" = category)))
	data["categories"] = categories

	return data

/obj/machinery/computer/supplycomp/proc/is_authorized(mob/user)
	if(allowed(user))
		return TRUE

	if(user.can_admin_interact())
		return TRUE

	return FALSE

/obj/machinery/computer/supplycomp/ui_act(action, list/params)
	if(..())
		return

	// If its not a public console, and they aint authed, dont let them use this
	if(!is_public && !is_authorized(usr))
		return

	if(!SSshuttle)
		stack_trace("The SSshuttle controller datum is missing somehow.")
		return

	. = TRUE
	add_fingerprint(usr)

	switch(action)
		if("moveShuttle")
			// Public consoles cant move the shuttle. Dont allow exploiters.
			if(is_public)
				return
			if(SSshuttle.supply.canMove())
				to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
			else if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.toggleShuttle("supply", "supply_home", "supply_away", 1)
				investigate_log("[key_name_log(usr)] has sent the supply shuttle away. Remaining points: [SSshuttle.points]. Shuttle contents: [SSshuttle.sold_atoms]", INVESTIGATE_CARGO)
			else if(!SSshuttle.supply.request(SSshuttle.getDock("supply_home")))
				post_signal("supply")
				if(LAZYLEN(SSshuttle.shoppinglist) && prob(10))
					var/datum/supply_order/O = new /datum/supply_order()
					O.ordernum = SSshuttle.ordernum
					O.object = SSshuttle.supply_packs[pick(SSshuttle.supply_packs)]
					O.orderedby = random_name(pick(MALE,FEMALE), species = "Human")
					SSshuttle.shoppinglist += O
					investigate_log("Random [O.object] crate added to supply shuttle", INVESTIGATE_CARGO)

		if("order")
			if(world.time < reqtime)
				visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
				return

			var/amount = 1
			if(params["multiple"] == "1") // 1 is a string here. DO NOT MAKE THIS A BOOLEAN YOU DORK
				var/num_input = input(usr, "Amount", "How many crates? (20 Max)") as null|num
				if(!num_input || (!is_public && !is_authorized(usr)) || ..()) // Make sure they dont walk away
					return
				amount = clamp(round(num_input), 1, 20)


			var/datum/supply_packs/P = locateUID(params["crate"])
			if(!istype(P))
				return

			var/timeout = world.time + 600 // If you dont type the reason within a minute, theres bigger problems here
			var/reason = input(usr, "Reason", "Why do you require this item?","") as null|text
			if(world.time > timeout || !reason || (!is_public && !is_authorized(usr)) || ..())
				// Cancel if they take too long, they dont give a reason, they aint authed, or if they walked away
				return
			reason = sanitize(copytext_char(reason, 1, MAX_MESSAGE_LEN))

			var/idname = "*None Provided*"
			var/idrank = "*None Provided*"

			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				idname = H.get_authentification_name()
				idrank = H.get_assignment()
			else if(issilicon(usr))
				idname = usr.real_name

			investigate_log("[key_name_log(usr)] made an order for [P.name] with amount [amount]. Points: [SSshuttle.points].", INVESTIGATE_CARGO)
			//make our supply_order datums
			for(var/i = 1; i <= amount; i++)
				var/datum/supply_order/O = SSshuttle.generateSupplyOrder(params["crate"], idname, idrank, reason, amount)
				if(!O)
					return
				if(i == 1)
					O.generateRequisition(loc)

		if("approve")
			// Public consoles cant approve stuff
			if(is_public)
				return
			if(SSshuttle.supply.getDockedId() != "supply_away" || SSshuttle.supply.mode != SHUTTLE_IDLE)
				return

			var/ordernum = text2num(params["ordernum"])
			var/datum/supply_order/O
			var/datum/supply_packs/P
			for(var/i=1, i<=SSshuttle.requestlist.len, i++)
				var/datum/supply_order/SO = SSshuttle.requestlist[i]
				if(SO.ordernum == ordernum)
					O = SO
					P = O.object
					if(SSshuttle.points >= P.cost)
						SSshuttle.requestlist.Cut(i,i+1)
						SSshuttle.points -= P.cost
						SSshuttle.shoppinglist += O
						investigate_log("[key_name_log(usr)] has authorized an order for [P.name]. Remaining points: [SSshuttle.points].", INVESTIGATE_CARGO)
					else
						to_chat(usr, "<span class='warning'>There are insufficient supply points for this request.</span>")
					break

		if("deny")
			var/ordernum = text2num(params["ordernum"])
			for(var/i=1, i<=SSshuttle.requestlist.len, i++)
				var/datum/supply_order/SO = SSshuttle.requestlist[i]
				if(SO.ordernum == ordernum)
					// If we are on a public console, only allow cancelling of our own orders
					if(is_public)
						var/obj/item/card/id/I = usr.get_id_card()
						if(I && SO.orderedby == I.registered_name)
							SSshuttle.requestlist.Cut(i,i+1)
							break
					// If we arent public, were cargo access. CANCELLATIONS FOR EVERYONE
					else
						SSshuttle.requestlist.Cut(i,i+1)
						break

		// Popup to show CC message logs. Its easier this way to avoid box-spam in TGUI
		if("showMessages")
			// Public consoles cant view messages
			if(is_public)
				return
			var/datum/browser/ccmsg_browser = new(usr, "ccmsg", "Central Command Cargo Message Log", 800, 600)
			ccmsg_browser.set_content(SSshuttle.centcom_message)
			ccmsg_browser.open()

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(DISPLAY_FREQ)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)
