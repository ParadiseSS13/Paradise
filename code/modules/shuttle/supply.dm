#define MAX_CRATE_DELIVERY 40
#define CARGO_PREVENT_SHUTTLE 1
#define CARGO_SKIP_ATOM 2

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 2 MINUTES
	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7

	// The list of things that can't be sent to CC.
	var/list/blacklist = list(
		"living creatures" = list(
			/mob/living,
			/obj/structure/blob,
			/obj/structure/spider/spiderling,
			/obj/machinery/clonepod,
			/obj/item/paicard),
		"classified nuclear weaponry" = list(
			/obj/item/disk/nuclear,
			/obj/machinery/nuclearbomb),
		"homing beacons" = list(
			/obj/item/radio/beacon,
			/obj/machinery/quantumpad,
			/obj/machinery/teleport/station,
			/obj/machinery/teleport/hub,
			/obj/machinery/telepad,
			/obj/machinery/telepad_cargo,
			/obj/structure/extraction_point),
		"high-energy objects" = list(
			/obj/singularity,
			/obj/machinery/the_singularitygen,
			/obj/effect/hierophant,
			/obj/item/warp_cube),
		"undelivered mail" = list(/obj/item/envelope))

	// The current manifest of what's on the shuttle.
	var/datum/economy/cargo_shuttle_manifest/manifest = new

	// The auto-registered simple_seller instances.
	var/list/simple_sellers = list()

	// The item preventing this shuttle from going to CC.
	var/blocking_item = "ERR_UNKNOWN"

/obj/docking_port/mobile/supply/Initialize()
	..()
	for(var/T in subtypesof(/datum/economy/simple_seller))
		var/datum/economy/simple_seller/seller = new T
		simple_sellers += seller
		seller.register(src)

/obj/docking_port/mobile/supply/register()
	if(!..())
		return FALSE
	SSshuttle.supply = src
	return TRUE

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return scan_cargo()
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

	for(var/datum/supply_order/order as anything in SSeconomy.shopping_list)
		if(length(SSeconomy.delivery_list) >= MAX_CRATE_DELIVERY)
			break
		SSeconomy.delivery_list += order
		SSeconomy.shopping_list -= order

	if(!length(SSeconomy.delivery_list))
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

	for(var/datum/supply_order/SO in SSeconomy.delivery_list)
		if(!SO.object)
			throw EXCEPTION("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			SSeconomy.delivery_list.Cut(1, SSeconomy.delivery_list.Find(SO))
			return
		SO.createObject(T)

	SSeconomy.delivery_list.Cut()

/obj/docking_port/mobile/supply/proc/scan_cargo()
	manifest = new
	SEND_SIGNAL(src, COMSIG_CARGO_BEGIN_SCAN)
	for(var/atom/movable/AM in areaInstance)
		if(!deep_scan(AM, TRUE))
			return FALSE
	return TRUE

/obj/docking_port/mobile/supply/proc/deep_scan(atom/movable/AM, top_level = FALSE)
	var/handling = prefilter_atom(AM)
	if(handling == CARGO_PREVENT_SHUTTLE)
		return FALSE

	for(var/atom/movable/child in AM)
		if(!deep_scan(child))
			return FALSE

	if(handling != CARGO_SKIP_ATOM)
		var/sellable = SEND_SIGNAL(src, COMSIG_CARGO_CHECK_SELL, AM)
		manifest.items_to_sell[AM] = sellable
		if(top_level && !(sellable & COMSIG_CARGO_IS_SECURED))
			manifest.loose_cargo = TRUE

	return TRUE

/obj/docking_port/mobile/supply/proc/prefilter_atom(atom/movable/AM)
	for(var/reason in blacklist)
		if(is_type_in_list(AM, blacklist[reason]))
			blocking_item = "[reason] ([AM])"
			return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = AM
		if(C.manifest)
			blocking_item = "crates with their manifest still attached ([AM])"
			return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/structure/closet/crate/secure))
		var/obj/structure/closet/crate/secure/SC = AM
		if(SC.locked)
			blocking_item = "locked crates ([AM])"
			return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/effect))
		var/obj/effect/E = AM
		if(E.is_cleanable())
			return NONE

	if(AM.anchored)
		return CARGO_SKIP_ATOM

/obj/docking_port/mobile/supply/proc/sell()
	if(z != level_name_to_num(CENTCOMM))		//we only sell when we are -at- centcomm
		return 1

	SEND_SIGNAL(src, COMSIG_CARGO_BEGIN_SELL)
	SSeconomy.sold_atoms = list()
	for(var/atom/movable/AM in manifest.items_to_sell)
		var/sellable = manifest.items_to_sell[AM]
		if(sellable & COMSIG_CARGO_SELL_PRIORITY)
			SEND_SIGNAL(src, COMSIG_CARGO_DO_PRIORITY_SELL, AM, manifest)
			SSeconomy.sold_atoms += "[AM.name](priority)"
			qdel(AM)
		else if(sellable & COMSIG_CARGO_SELL_NORMAL)
			SEND_SIGNAL(src, COMSIG_CARGO_DO_SELL, AM, manifest)
			SSeconomy.sold_atoms += "[AM.name](normal)"
			qdel(AM)
		else if(sellable & COMSIG_CARGO_SELL_WRONG)
			SEND_SIGNAL(src, COMSIG_CARGO_SEND_ERROR, AM, manifest)
			SSeconomy.sold_atoms += "[AM.name](error)"
			qdel(AM)
		else if(sellable & COMSIG_CARGO_MESS)
			manifest.messy_shuttle = TRUE
			SSeconomy.sold_atoms += "[AM.name](mess)"
			qdel(AM)
		else
			manifest.sent_trash = TRUE

	SEND_SIGNAL(src, COMSIG_CARGO_END_SELL, manifest)

	if(manifest.loose_cargo)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = SSeconomy.fine_for_loose_cargo
		item.reason = "Please remember to secure all items in crates."
		manifest.line_items += item
	if(manifest.messy_shuttle)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = SSeconomy.fine_for_messy_shuttle
		item.reason = "Shuttle cleaning fee."
		manifest.line_items += item
	if(manifest.sent_trash)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = SSeconomy.fine_for_selling_trash
		item.reason = "Don't send us random junk."
		manifest.line_items += item

	var/msg = "<center>---[station_time_timestamp()]---</center><br>"

	var/list/credit_changes = list()
	for(var/datum/economy/line_item/item in manifest.line_items)
		if(!credit_changes[item.account])
			credit_changes[item.account] = 0
		credit_changes[item.account] += item.credits

		if(item.credits > 0)
			msg += "<span class='good'>[item.account.account_name] +[item.credits]</span>: [item.reason]<br>"
		else if(item.credits == 0)
			msg += "<span class='[item.zero_is_good ? "good" : "bad"]'>[item.account.account_name] Notice</span>: [item.reason]<br>"
		else
			msg += "<span class='bad'>[item.account.account_name] [item.credits]</span>: [item.reason]<br>"

	for(var/account in credit_changes)
		if(credit_changes[account] > 0)
			GLOB.station_money_database.credit_account(account, credit_changes[account], "Supply Shuttle Exports Payment", "Central Command Supply Master", supress_log = FALSE)
		else
			GLOB.station_money_database.charge_account(account, -credit_changes[account], "Supply Shuttle Fine", "Central Command Supply Master", allow_overdraft = TRUE, supress_log = FALSE)

	SSeconomy.centcom_message += "[msg]<hr>"
	manifest = new


// Convenience object that registers itself with the supply shuttle and provides
// methods for you to override.
/datum/economy/simple_seller

/datum/economy/simple_seller/proc/register(obj/docking_port/mobile/supply/S)
	RegisterSignal(S, COMSIG_CARGO_BEGIN_SCAN,			PROC_REF(begin_scan))
	RegisterSignal(S, COMSIG_CARGO_CHECK_SELL,			PROC_REF(check_sell))
	RegisterSignal(S, COMSIG_CARGO_BEGIN_SELL,			PROC_REF(begin_sell))
	RegisterSignal(S, COMSIG_CARGO_DO_PRIORITY_SELL,	PROC_REF(sell_priority))
	RegisterSignal(S, COMSIG_CARGO_DO_SELL,				PROC_REF(sell_normal))
	RegisterSignal(S, COMSIG_CARGO_SEND_ERROR,			PROC_REF(sell_wrong))
	RegisterSignal(S, COMSIG_CARGO_END_SELL,			PROC_REF(end_sell))

/datum/economy/simple_seller/proc/begin_scan(obj/docking_port/mobile/supply/S)
	SIGNAL_HANDLER  // COMSIG_CARGO_BEGIN_SCAN
	return

/datum/economy/simple_seller/proc/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	SIGNAL_HANDLER  // COMSIG_CARGO_CHECK_SELL
	return NONE

/datum/economy/simple_seller/proc/begin_sell(obj/docking_port/mobile/supply/S)
	SIGNAL_HANDLER  // COMSIG_CARGO_BEGIN_SELL
	return

/datum/economy/simple_seller/proc/sell_priority(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	SIGNAL_HANDLER  // COMSIG_CARGO_DO_PRIORITY_SELL
	return check_sell(S, AM) & COMSIG_CARGO_SELL_PRIORITY

/datum/economy/simple_seller/proc/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	SIGNAL_HANDLER  // COMSIG_CARGO_DO_SELL
	return check_sell(S, AM) & COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/proc/sell_wrong(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	SIGNAL_HANDLER  // COMSIG_CARGO_SEND_ERROR
	return check_sell(S, AM) & COMSIG_CARGO_SELL_WRONG

/datum/economy/simple_seller/proc/end_sell(obj/docking_port/mobile/supply/S, datum/economy/cargo_shuttle_manifest/manifest)
	SIGNAL_HANDLER  // COMSIG_CARGO_END_SELL
	return


/datum/economy/simple_seller/crates
	var/crates = 0
	var/credits = 0

/datum/economy/simple_seller/crates/begin_sell(obj/docking_port/mobile/supply/S)
	crates = 0
	credits = 0

/datum/economy/simple_seller/crates/check_sell(obj/docking_port/mobile/supply/S, AM)
	if(istype(AM, /obj/structure/closet/crate) || istype(AM, /obj/structure/closet/critter) || istype(AM, /obj/structure/closet/crate/mail))
		return COMSIG_CARGO_SELL_NORMAL | COMSIG_CARGO_IS_SECURED

/datum/economy/simple_seller/crates/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	crates += 1
	if(istype(AM, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/exported_crate = AM
		credits += exported_crate.crate_value
	else
		credits += DEFAULT_CRATE_VALUE

/datum/economy/simple_seller/crates/end_sell(obj/docking_port/mobile/supply/S, datum/economy/cargo_shuttle_manifest/manifest)
	if(!credits)
		return
	var/datum/economy/line_item/item = new
	item.account = SSeconomy.cargo_account
	item.credits = credits
	item.reason = "Returned [crates] crate(s)."
	manifest.line_items += item


/datum/economy/simple_seller/plasma
	var/plasma = 0

/datum/economy/simple_seller/plasma/begin_sell(obj/docking_port/mobile/supply/S)
	plasma = 0

/datum/economy/simple_seller/plasma/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/stack/sheet/mineral/plasma))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/plasma/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/stack/sheet/mineral/plasma/P = AM
	plasma += P.amount

/datum/economy/simple_seller/plasma/end_sell(obj/docking_port/mobile/supply/S, datum/economy/cargo_shuttle_manifest/manifest)
	if(!plasma)
		return
	var/datum/economy/line_item/item = new
	item.account = SSeconomy.cargo_account
	item.credits = plasma * SSeconomy.credits_per_plasma
	item.reason = "Received [plasma] unit(s) of exotic material."
	manifest.line_items += item


/datum/economy/simple_seller/intel
	var/intel = 0

/datum/economy/simple_seller/intel/begin_sell(obj/docking_port/mobile/supply/S)
	intel = 0

/datum/economy/simple_seller/intel/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/documents/syndicate))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/intel/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	intel++

/datum/economy/simple_seller/intel/end_sell(obj/docking_port/mobile/supply/S, datum/economy/cargo_shuttle_manifest/manifest)
	if(!intel)
		return
	var/datum/economy/line_item/item = new
	item.account = SSeconomy.cargo_account
	item.credits = intel * SSeconomy.credits_per_intel
	item.reason = "Received [intel] article(s) of enemy intelligence."
	manifest.line_items += item


/datum/economy/simple_seller/alien_organs

/datum/economy/simple_seller/alien_organs/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/organ/internal/alien))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/alien_organs/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/organ/internal/alien/organ = AM
	var/datum/economy/line_item/item = new
	item.account = SSeconomy.cargo_account
	item.credits = organ.cargo_profit
	item.reason = "Received a sample of exotic biological tissue."
	manifest.line_items += item


/datum/economy/simple_seller/shipping_manifests

/datum/economy/simple_seller/shipping_manifests/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM,/obj/item/paper/manifest))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/shipping_manifests/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/paper/manifest/slip = AM

	var/datum/economy/line_item/item = new
	item.account = SSeconomy.cargo_account
	item.credits = SSeconomy.credits_per_manifest
	item.reason = "Package [slip.ordernumber] accorded."
	manifest.line_items += item


/datum/economy/simple_seller/tech_levels
	var/list/temp_tech_levels

/datum/economy/simple_seller/tech_levels/begin_scan(obj/docking_port/mobile/supply/S)
	temp_tech_levels = SSeconomy.tech_levels.Copy()

/datum/economy/simple_seller/tech_levels/begin_sell(obj/docking_port/mobile/supply/S)
	temp_tech_levels = SSeconomy.tech_levels.Copy()

/datum/economy/simple_seller/tech_levels/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/disk = AM
		if(!disk.stored)
			return COMSIG_CARGO_SELL_WRONG
		var/datum/tech/tech = disk.stored

		var/cost = tech.getCost(temp_tech_levels[tech.id])
		if(cost)
			temp_tech_levels[tech.id] = tech.level
			return COMSIG_CARGO_SELL_NORMAL
		return COMSIG_CARGO_SELL_WRONG

/datum/economy/simple_seller/tech_levels/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/disk/tech_disk/disk = AM
	if(!disk.stored)
		return
	var/datum/tech/tech = disk.stored

	var/cost = tech.getCost(SSeconomy.tech_levels[tech.id])
	if(!cost)
		return

	SSeconomy.tech_levels[tech.id] = tech.level

	var/datum/economy/line_item/cargo_item = new
	cargo_item.account = SSeconomy.cargo_account
	cargo_item.credits = cost / 2
	cargo_item.reason = "[tech.name] - new data."
	manifest.line_items += cargo_item

	var/datum/economy/line_item/science_item = new
	science_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	science_item.credits = cost / 2
	science_item.reason = "[tech.name] - new data."
	manifest.line_items += science_item

/datum/economy/simple_seller/tech_levels/sell_wrong(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	item.credits = 0

	var/obj/item/disk/tech_disk/disk = AM
	if(!disk.stored)
		item.reason = "Blank tech disk."
		manifest.line_items += item
		return

	var/datum/tech/tech = disk.stored
	var/cost = tech.getCost(SSeconomy.tech_levels[tech.id])
	if(!cost)
		item.reason = "[tech.name] - no new data."
		manifest.line_items += item


/datum/economy/simple_seller/designs
	var/list/temp_designs

/datum/economy/simple_seller/designs/begin_scan(obj/docking_port/mobile/supply/S)
	temp_designs = SSeconomy.research_designs.Copy()

/datum/economy/simple_seller/designs/begin_sell(obj/docking_port/mobile/supply/S)
	temp_designs = SSeconomy.research_designs.Copy()

/datum/economy/simple_seller/designs/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/disk/design_disk))
		var/obj/item/disk/design_disk/disk = AM
		if(!disk.blueprint)
			return COMSIG_CARGO_SELL_WRONG
		var/datum/design/design = disk.blueprint
		if(design.id in temp_designs)
			return COMSIG_CARGO_SELL_WRONG
		temp_designs += design.id
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/designs/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/disk/design_disk/disk = AM
	if(!disk.blueprint)
		return
	var/datum/design/design = disk.blueprint
	if(design.id in SSeconomy.research_designs)
		return
	SSeconomy.research_designs += design.id

	var/datum/economy/line_item/cargo_item = new
	cargo_item.account = SSeconomy.cargo_account
	cargo_item.credits = SSeconomy.credits_per_design / 2
	cargo_item.reason = "[design.name] design."
	manifest.line_items += cargo_item

	var/datum/economy/line_item/science_item = new
	science_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	science_item.credits = SSeconomy.credits_per_design / 2
	science_item.reason = "[design.name] design."
	manifest.line_items += science_item

/datum/economy/simple_seller/designs/sell_wrong(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	item.credits = 0

	var/obj/item/disk/design_disk/disk = AM
	if(!disk.blueprint)
		item.reason = "Blank design disk."
		manifest.line_items += item
		return
	var/datum/design/design = disk.blueprint
	if(design.id in SSeconomy.research_designs)
		item.reason = "Duplicate design for [design.name]."
		manifest.line_items += item
		return


/datum/economy/simple_seller/seeds
	var/list/temp_discovered

/datum/economy/simple_seller/seeds/begin_scan(obj/docking_port/mobile/supply/S)
	temp_discovered = SSeconomy.discovered_plants.Copy()

/datum/economy/simple_seller/seeds/begin_sell(obj/docking_port/mobile/supply/S)
	temp_discovered = SSeconomy.discovered_plants.Copy()

/datum/economy/simple_seller/seeds/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/seeds))
		var/obj/item/seeds/seed = AM
		if(seed.rarity == 0) // Mundane species
			return COMSIG_CARGO_SELL_WRONG
		if(!temp_discovered[seed.type] || temp_discovered[seed.type] < seed.potency)
			temp_discovered[seed.type] = seed.potency
			return COMSIG_CARGO_SELL_NORMAL
		return COMSIG_CARGO_SELL_WRONG

/datum/economy/simple_seller/seeds/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/msg = ""
	var/credits = 0
	var/obj/item/seeds/seed = AM
	if(seed.rarity == 0) // Mundane species
		return
	else if(SSeconomy.discovered_plants[seed.type])
		// This species has already been sent to CentComm
		// Compare it to the previous best
		var/potDiff = seed.potency - SSeconomy.discovered_plants[seed.type]
		if(potDiff > 0)
			SSeconomy.discovered_plants[seed.type] = seed.potency
			credits = potDiff
			msg = "New sample of \"[capitalize(seed.species)]\" is superior. Good work."
	else
		// This is a new discovery!
		SSeconomy.discovered_plants[seed.type] = seed.potency
		credits = seed.rarity + seed.potency
		msg = "New species discovered: \"[capitalize(seed.species)]\". Excellent work."

	if(credits == 0)
		return

	var/datum/economy/line_item/cargo_item = new
	cargo_item.account = SSeconomy.cargo_account
	cargo_item.credits = credits / 2
	cargo_item.reason = msg
	manifest.line_items += cargo_item

	var/datum/economy/line_item/service_item = new
	service_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	service_item.credits = credits / 2
	service_item.reason = msg
	manifest.line_items += service_item

/datum/economy/simple_seller/seeds/sell_wrong(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SERVICE)
	item.credits = 0

	var/obj/item/seeds/seed = AM
	if(seed.rarity == 0)
		item.reason = "We don't need samples of mundane species \"[capitalize(seed.species)]\"."
		manifest.line_items += item
		return
	else
		item.reason = "New sample of \"[capitalize(seed.species)]\" is not more potent than existing sample ([SSeconomy.discovered_plants[seed.type]] potency)."
		manifest.line_items += item


/datum/economy/simple_seller/messes
	var/list/temp_discovered

/datum/economy/simple_seller/messes/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/effect))
		var/obj/effect/E = AM
		if(E.is_cleanable())
			return COMSIG_CARGO_MESS | COMSIG_CARGO_IS_SECURED


/datum/economy/cargo_shuttle_manifest
	var/list/items_to_sell = list()
	var/list/line_items = list()
	var/loose_cargo = FALSE
	var/messy_shuttle = FALSE
	var/sent_trash = FALSE


/datum/economy/line_item
	var/datum/money_account/account
	var/credits
	var/reason
	var/zero_is_good = FALSE

#undef MAX_CRATE_DELIVERY
#undef CARGO_PREVENT_SHUTTLE
#undef CARGO_SKIP_ATOM
