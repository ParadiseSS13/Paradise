/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 2 MINUTES
	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7

/obj/docking_port/mobile/supply/register()
	if(!..())
		return FALSE
	SSshuttle.supply = src
	return TRUE

/obj/docking_port/mobile/supply/proc/forbidden_atoms_check(atom/A)
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
			return TRUE
		for(var/thing in A)
			if(.(thing))
				return TRUE

	return FALSE

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
	if(.)
		return

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!is_station_level(z))		//we only buy when we are -at- the station
		return 1

	if(!length(SSeconomy.shoppinglist))
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

	for(var/datum/supply_order/SO in SSeconomy.shoppinglist)
		if(!SO.object)
			throw EXCEPTION("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			SSeconomy.shoppinglist.Cut(1, SSeconomy.shoppinglist.Find(SO))
			return
		SO.createObject(T)

	SSeconomy.shoppinglist.Cut()

/obj/docking_port/mobile/supply/proc/sell()
	if(z != level_name_to_num(CENTCOMM))		//we only sell when we are -at- centcomm
		return 1

	var/plasma_count = 0
	var/intel_count = 0
	var/crate_count = 0

	var/msg = "<center>---[station_time_timestamp()]---</center><br>"
	var/credits_to_deposit = 0

	for(var/atom/movable/MA in areaInstance)
		if(MA.anchored)
			continue
		if(istype(MA, /mob/dead))
			continue
		SSeconomy.sold_atoms += " [MA.name]"

		// Must be in a crate (or a critter crate)!
		if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/critter))
			SSeconomy.sold_atoms += ":"
			if(!length(MA.contents))
				SSeconomy.sold_atoms += " (empty)"
			crate_count++

			var/find_slip = TRUE
			for(var/thing in MA)
				// Sell manifests
				SSeconomy.sold_atoms += " [thing:name]"
				if(find_slip && istype(thing,/obj/item/paper/manifest))
					var/obj/item/paper/manifest/slip = thing
					if(length(slip.stamped))
						if(/obj/item/stamp/denied in slip.stamped) //need to test this lol
							continue
					credits_to_deposit += SSeconomy.credits_per_manifest
					msg += "<span class='good'>+[SSeconomy.credits_per_manifest]</span>: Package [slip.ordernumber] accorded.<br>"

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
					if(!disk.stored)
						continue
					var/datum/tech/tech = disk.stored

					var/cost = tech.getCost(SSeconomy.techLevels[tech.id])
					if(cost)
						SSeconomy.techLevels[tech.id] = tech.level
						credits_to_deposit += cost
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
					if(design.id in SSeconomy.researchDesigns)
						continue
					credits_to_deposit += SSeconomy.credits_per_design
					SSeconomy.researchDesigns += design.id
					msg += "<span class='good'>+[SSeconomy.credits_per_design]</span>: [design.name] design.<br>"

				// Sell exotic plants
				if(istype(thing, /obj/item/seeds))
					var/obj/item/seeds/S = thing
					if(S.rarity == 0) // Mundane species
						msg += "<span class='bad'>+0</span>: We don't need samples of mundane species \"[capitalize(S.species)]\".<br>"
					else if(SSeconomy.discoveredPlants[S.type]) // This species has already been sent to CentComm
						var/potDiff = S.potency - SSeconomy.discoveredPlants[S.type] // Compare it to the previous best
						if(potDiff > 0) // This sample is better
							SSeconomy.discoveredPlants[S.type] = S.potency
							msg += "<span class='good'>+[potDiff]</span>: New sample of \"[capitalize(S.species)]\" is superior. Good work.<br>"
							credits_to_deposit += potDiff
						else // This sample is worthless
							msg += "<span class='bad'>+0</span>: New sample of \"[capitalize(S.species)]\" is not more potent than existing sample ([SSeconomy.discoveredPlants[S.type]] potency).<br>"
					else // This is a new discovery!
						SSeconomy.discoveredPlants[S.type] = S.potency
						msg += "<span class='good'>[S.rarity]</span>: New species discovered: \"[capitalize(S.species)]\". Excellent work.<br>"
						credits_to_deposit += S.rarity // That's right, no bonus for potency.  Send a crappy sample first to "show improvement" later
		qdel(MA)
		SSeconomy.sold_atoms += "."

	if(plasma_count > 0)
		var/credits_from_plasma = plasma_count * SSeconomy.credits_per_plasma
		msg += "<span class='good'>+[credits_from_plasma]</span>: Received [plasma_count] unit(s) of exotic material.<br>"
		credits_to_deposit += credits_from_plasma

	if(intel_count > 0)
		var/credits_from_intel = intel_count * SSeconomy.credits_per_intel
		msg += "<span class='good'>+[credits_from_intel]</span>: Received [intel_count] article(s) of enemy intelligence.<br>"
		credits_to_deposit += credits_from_intel

	if(crate_count > 0)
		var/credits_from_crates = crate_count * SSeconomy.credits_per_crate
		msg += "<span class='good'>+[credits_from_crates]</span>: Received [crate_count] crate(s).<br>"
		credits_to_deposit += credits_from_crates

	SSeconomy.centcom_message += "[msg]<hr>"
	GLOB.station_money_database.credit_account(SSeconomy.cargo_account, credits_to_deposit, "Supply Shuttle Exports Payment", "Central Command Supply Master", supress_log = FALSE)

