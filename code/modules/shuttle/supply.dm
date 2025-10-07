#define MAX_CRATE_DELIVERY 40

#define CARGO_OK 0
#define CARGO_PREVENT_SHUTTLE 1
#define CARGO_SKIP_ATOM 2
#define CARGO_REQUIRE_PRIORITY 3
#define CARGO_HAS_PRIORITY 4


/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 2 MINUTES
	dir = 8
	width = 12
	dwidth = 5
	height = 7
	port_direction = EAST

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
			/obj/item/beacon,
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
		"undelivered mail" = list(/obj/item/envelope),
		"live ordnance" = list(/obj/machinery/syndicatebomb)
		)

	// The current manifest of what's on the shuttle.
	var/datum/economy/cargo_shuttle_manifest/manifest = new

	// The auto-registered simple_seller instances.
	var/list/simple_sellers = list()

	// The item preventing this shuttle from going to CC.
	var/blocking_item = "ERR_UNKNOWN"

/obj/docking_port/mobile/supply/Initialize(mapload)
	. = ..()
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

/obj/docking_port/mobile/supply/dock(obj/docking_port/stationary/port)
	. = ..()
	if(.)
		return

	if(istype(port, /obj/docking_port/stationary/transit))
		// Ignore transit ports.
		return

	if(is_station_level(port.z))
		// Buy when arriving at the station.
		buy()

	if(port.z == level_name_to_num(CENTCOMM))
		// Sell when arriving at CentComm.
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	for(var/datum/supply_order/order as anything in SSeconomy.shopping_list)
		if(length(SSeconomy.delivery_list) >= MAX_CRATE_DELIVERY)
			break
		SSeconomy.delivery_list += order
		SSeconomy.shopping_list -= order

	var/list/emptyTurfs = list()
	for(var/turf/simulated/T in areaInstance)
		if(T.density)
			continue

		var/contcount
		for(var/atom/A in T.contents)
			if(!A.simulated)
				continue
			if(istype(A, /obj/machinery/light) || istype(A, /obj/machinery/conveyor))
				continue // Objects we're fine with spawning crates on.
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

	for(var/datum/station_goal/secondary/SG in SSticker.mode.secondary_goals)
		if(!SG.should_send_crate)
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			break

		var/obj/structure/closet/crate/secure/personal/PC = new(T)
		PC.name = "goal crate"
		PC.registered_name = SG.requester_name
		PC.AddComponent(/datum/component/label/goal, SG.requester_name, SG.department, TRUE)
		PC.locked = FALSE
		PC.update_icon()

		SG.should_send_crate = FALSE
	if(SSshuttle.shuttle_loan_UID)
		var/datum/event/shuttle_loan/shuttle_loan = locateUID(SSshuttle.shuttle_loan_UID)
		if(!shuttle_loan.dispatched)
			return
		// let the situation spawn its items
		var/list/spawn_list = list()
		shuttle_loan.situation.spawn_items(spawn_list, emptyTurfs)
		var/false_positive = 0
		while(spawn_list.len && emptyTurfs.len)
			var/turf/spawn_turf = pick_n_take(emptyTurfs)
			if(spawn_turf.contents.len && false_positive < 5)
				false_positive++
				continue
			var/spawn_type = pick_n_take(spawn_list)
			new spawn_type(spawn_turf)
		// Clear the event so it doesn't cause a problem again
		SSshuttle.shuttle_loan_UID = null

/obj/docking_port/mobile/supply/proc/scan_cargo()
	manifest = new
	SEND_SIGNAL(src, COMSIG_CARGO_BEGIN_SCAN)
	for(var/atom/movable/AM in areaInstance)
		if(deep_scan(AM, TRUE) == CARGO_PREVENT_SHUTTLE)
			return FALSE
	return TRUE

/obj/docking_port/mobile/supply/proc/deep_scan(atom/movable/AM, top_level = FALSE)
	var/handling = prefilter_atom(AM)
	if(handling == CARGO_PREVENT_SHUTTLE)
		return CARGO_PREVENT_SHUTTLE

	var/found_priority = FALSE
	for(var/atom/movable/child in AM)
		var/child_handling = deep_scan(child)
		if(child_handling == CARGO_PREVENT_SHUTTLE)
			return CARGO_PREVENT_SHUTTLE
		if(child_handling == CARGO_HAS_PRIORITY)
			found_priority = TRUE

	if(handling != CARGO_SKIP_ATOM)
		if(handling == CARGO_REQUIRE_PRIORITY && !found_priority)
			blocking_item = "locked containers that don't contain goal items ([AM])"
			return CARGO_PREVENT_SHUTTLE
		var/sellable = SEND_SIGNAL(src, COMSIG_CARGO_CHECK_SELL, AM)
		manifest.items_to_sell[AM] = sellable
		if(top_level)
			if(!AM.anchored && !(sellable & COMSIG_CARGO_IS_SECURED))
				manifest.loose_cargo = TRUE
			return CARGO_OK
		if(found_priority || sellable & COMSIG_CARGO_SELL_PRIORITY)
			return CARGO_HAS_PRIORITY

	return CARGO_OK

/obj/docking_port/mobile/supply/proc/prefilter_atom(atom/movable/AM)
	for(var/reason in blacklist)
		if(is_type_in_list(AM, blacklist[reason]))
			blocking_item = "[reason] ([AM])"
			return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/structure/largecrate))
		blocking_item = "unopened large crates ([AM])"
		return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = AM
		if(C.manifest)
			blocking_item = "crates with their manifest still attached ([AM])"
			return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/structure/closet/crate/secure))
		var/obj/structure/closet/crate/secure/SC = AM
		if(SC.locked)
			return CARGO_REQUIRE_PRIORITY
		else if(istype(SC, /obj/structure/closet/crate/secure/personal))
			blocking_item = "unlocked personal crates ([AM])"
			return CARGO_PREVENT_SHUTTLE

	if(istype(AM, /obj/item/storage/lockbox))
		var/obj/item/storage/lockbox/LB = AM
		if(LB.locked)
			return CARGO_REQUIRE_PRIORITY

	if(istype(AM, /obj/effect))
		var/obj/effect/E = AM
		if(E.is_cleanable())
			return CARGO_OK
		return CARGO_SKIP_ATOM

	if(istype(AM, /mob/dead))
		return CARGO_SKIP_ATOM

	return CARGO_OK


/obj/docking_port/mobile/supply/proc/sell()
	SEND_SIGNAL(src, COMSIG_CARGO_BEGIN_SELL)
	SSeconomy.sold_atoms = list()
	var/list/qdel_atoms = list()
	var/list/rescue_atoms = list()
	for(var/atom/movable/AM in manifest.items_to_sell)
		var/sellable = manifest.items_to_sell[AM]
		if(sellable & COMSIG_CARGO_SELL_PRIORITY)
			SEND_SIGNAL(src, COMSIG_CARGO_DO_PRIORITY_SELL, AM, manifest)
			SSeconomy.sold_atoms += "[AM.name](priority)"
			qdel_atoms += AM
			continue
		else if(sellable & COMSIG_CARGO_SELL_NORMAL)
			SEND_SIGNAL(src, COMSIG_CARGO_DO_SELL, AM, manifest)
			SSeconomy.sold_atoms += "[AM.name](normal)"
			qdel_atoms += AM
			continue
		else if(sellable & COMSIG_CARGO_SELL_WRONG)
			SEND_SIGNAL(src, COMSIG_CARGO_SEND_ERROR, AM, manifest)
			SSeconomy.sold_atoms += "[AM.name](error)"
			qdel_atoms += AM
			continue
		else if(sellable & COMSIG_CARGO_MESS)
			manifest.messy_shuttle = TRUE
			SSeconomy.sold_atoms += "[AM.name](mess)"
			qdel_atoms += AM
			continue
		else if(!AM.anchored && !(sellable & COMSIG_CARGO_SELL_SKIP))
			manifest.sent_trash = TRUE

		rescue_atoms += AM

	for(var/atom/movable/AM in rescue_atoms)
		if(AM.loc in qdel_atoms)
			AM.forceMove(get_turf(AM))

	for(var/AM in qdel_atoms)
		qdel(AM)

	SEND_SIGNAL(src, COMSIG_CARGO_END_SELL, manifest)

	SSblackbox.record_feedback("amount", "cargo shipments", 1)

	if(manifest.loose_cargo)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = SSeconomy.fine_for_loose_cargo
		item.reason = "Please remember to secure all items in crates."
		manifest.line_items += item
		SSblackbox.record_feedback("nested tally", "cargo fines", 1, list("loose cargo", "amount"))
		SSblackbox.record_feedback("nested tally", "cargo fines", SSeconomy.fine_for_loose_cargo, list("loose cargo", "credits"))
	if(manifest.messy_shuttle)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = SSeconomy.fine_for_messy_shuttle
		item.reason = "Shuttle cleaning fee."
		manifest.line_items += item
		SSblackbox.record_feedback("nested tally", "cargo fines", 1, list("messy shuttle", "amount"))
		SSblackbox.record_feedback("nested tally", "cargo fines", SSeconomy.fine_for_messy_shuttle, list("messy shuttle", "credits"))
	if(manifest.sent_trash)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = SSeconomy.fine_for_selling_trash
		item.reason = "Don't send us random junk."
		manifest.line_items += item
		SSblackbox.record_feedback("nested tally", "cargo fines", 1, list("sent trash", "amount"))
		SSblackbox.record_feedback("nested tally", "cargo fines", SSeconomy.fine_for_selling_trash, list("sent trash", "credits"))

	var/msg = "<center>---[station_time_timestamp()]---</center><br>"

	var/list/credit_changes = list()
	var/list/department_messages = list()
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

		if(item.requests_console_department)
			if(!department_messages[item.requests_console_department])
				department_messages[item.requests_console_department] = list()
			if(!department_messages[item.requests_console_department][item.reason])
				department_messages[item.requests_console_department][item.reason] = 0
			department_messages[item.requests_console_department][item.reason]++

	for(var/datum/money_account/account in credit_changes)
		if(account.account_type == ACCOUNT_TYPE_DEPARTMENT)
			SSblackbox.record_feedback("tally", "cargo profits", credit_changes[account], "[account.account_name]")
		else
			SSblackbox.record_feedback("tally", "cargo profits", credit_changes[account], "All personal accounts")

		if(credit_changes[account] > 0)
			GLOB.station_money_database.credit_account(account, credit_changes[account], "Supply Shuttle Exports Payment", "Central Command Supply Master", supress_log = FALSE)
		else
			GLOB.station_money_database.charge_account(account, -credit_changes[account], "Supply Shuttle Fine", "Central Command Supply Master", allow_overdraft = TRUE, supress_log = FALSE)

	for(var/department in department_messages)
		var/list/rc_message = list()
		for(var/message_piece in department_messages[department])
			var/count = ""
			if(department_messages[department][message_piece] > 1)
				count = " (x[department_messages[department][message_piece]])"
			rc_message += "[message_piece][count]"
		send_requests_console_message(rc_message, "Procurement Office", department, "Stamped with the Central Command rubber stamp.", "Verified by the Central Command receiving department.", RQ_NORMALPRIORITY)

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
	SSblackbox.record_feedback("tally", "cargo crates sold", crates, "amount")
	SSblackbox.record_feedback("tally", "cargo crates sold", item.credits, "credits")


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
	SSblackbox.record_feedback("tally", "cargo plasma sold", plasma, "amount")
	SSblackbox.record_feedback("tally", "cargo plasma sold", item.credits, "credits")


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
	SSblackbox.record_feedback("tally", "cargo intel sold", intel, "amount")
	SSblackbox.record_feedback("tally", "cargo intel sold", item.credits, "credits")


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
	SSblackbox.record_feedback("tally", "cargo alien organs sold", 1, "amount")
	SSblackbox.record_feedback("tally", "cargo alien organs sold", item.credits, "credits")


/datum/economy/simple_seller/shipping_manifests

/datum/economy/simple_seller/shipping_manifests/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM,/obj/item/paper/manifest))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/shipping_manifests/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/paper/manifest/slip = AM

	var/error = FALSE
	if(/obj/item/stamp/denied in slip.stamped)
		error = "Package [slip.ordernumber] rejected. A Nanotrasen supply department official will reach out to you in 2-3 business days."
		SSblackbox.record_feedback("tally", "cargo manifests rejected", 1, "amount")
	else if(!(/obj/item/stamp/granted in slip.stamped))
		error = "Received unstamped manifest for package [slip.ordernumber]. Remember to stamp all manifests before returning them."
		SSblackbox.record_feedback("tally", "cargo manifests not stamped", 1, "amount")

	if(error)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		item.credits = 0
		item.reason = error
		manifest.line_items += item
		return

	var/datum/economy/line_item/item = new
	item.account = SSeconomy.cargo_account
	item.credits = SSeconomy.credits_per_manifest
	item.reason = "Package [slip.ordernumber] accorded."
	manifest.line_items += item
	SSblackbox.record_feedback("tally", "cargo manifests sold", 1, "amount")
	SSblackbox.record_feedback("tally", "cargo manifests sold", item.credits, "credits")


/datum/economy/simple_seller/tech_levels
	var/list/temp_tech_levels

/datum/economy/simple_seller/tech_levels/begin_scan(obj/docking_port/mobile/supply/S)
	temp_tech_levels = SSeconomy.tech_levels.Copy()

/datum/economy/simple_seller/tech_levels/begin_sell(obj/docking_port/mobile/supply/S)
	temp_tech_levels = SSeconomy.tech_levels.Copy()

/datum/economy/simple_seller/tech_levels/proc/get_price(tech_rarity, tech_level, sold_level = null)
	// Calculates tech disk's supply points sell cost
	if(!sold_level)
		sold_level = 1

	if(sold_level >= tech_level)
		return 0

	var/cost = 0
	for(var/i in (sold_level + 1) to tech_level)
		cost += i * 5 * tech_rarity

	return cost

/datum/economy/simple_seller/tech_levels/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/disk/tech_disk))
		var/obj/item/disk/tech_disk/disk = AM
		if(!disk.tech_id)
			return COMSIG_CARGO_SELL_WRONG

		var/cost = get_price(disk.tech_rarity, disk.tech_level, temp_tech_levels[disk.tech_id])
		if(cost)
			temp_tech_levels[disk.tech_id] = disk.tech_level
			return COMSIG_CARGO_SELL_NORMAL
		return COMSIG_CARGO_SELL_WRONG

/datum/economy/simple_seller/tech_levels/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/obj/item/disk/tech_disk/disk = AM
	if(!disk.tech_id)
		return

	var/cost = get_price(disk.tech_rarity, disk.tech_level, SSeconomy.tech_levels[disk.tech_id])
	if(!cost)
		return

	SSeconomy.tech_levels[disk.tech_id] = disk.tech_level
	SSblackbox.record_feedback("tally", "cargo tech disks sold", 1, "amount")
	SSblackbox.record_feedback("tally", "cargo tech disks sold", cost, "credits")

	var/datum/economy/line_item/cargo_item = new
	cargo_item.account = SSeconomy.cargo_account
	cargo_item.credits = cost / 2
	cargo_item.reason = "[disk.tech_name] - new data."
	manifest.line_items += cargo_item

	var/datum/economy/line_item/science_item = new
	science_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	science_item.credits = cost / 2
	science_item.reason = "[disk.tech_name] - new data."
	manifest.line_items += science_item

/datum/economy/simple_seller/tech_levels/sell_wrong(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	var/datum/economy/line_item/item = new
	item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	item.credits = 0

	var/obj/item/disk/tech_disk/disk = AM
	if(!disk.tech_id)
		item.reason = "Blank tech disk."
		manifest.line_items += item
		SSblackbox.record_feedback("tally", "cargo tech disks sold", 1, "blank")
		return

	var/cost = get_price(disk.tech_rarity, disk.tech_level, SSeconomy.tech_levels[disk.tech_id])
	if(!cost)
		item.reason = "[disk.tech_name] - no new data."
		manifest.line_items += item
		SSblackbox.record_feedback("tally", "cargo tech disks sold", 1, "repeat")


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
	SSblackbox.record_feedback("tally", "cargo design disks sold", 1, "amount")
	SSblackbox.record_feedback("tally", "cargo design disks sold", SSeconomy.credits_per_design, "credits")

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
		SSblackbox.record_feedback("tally", "cargo design disks sold", 1, "blank")
		return
	var/datum/design/design = disk.blueprint
	if(design.id in SSeconomy.research_designs)
		item.reason = "Duplicate design for [design.name]."
		manifest.line_items += item
		SSblackbox.record_feedback("tally", "cargo design disks sold", 1, "repeat")
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
			SSblackbox.record_feedback("tally", "cargo seeds sold", 1, "improved")
	else
		// This is a new discovery!
		SSeconomy.discovered_plants[seed.type] = seed.potency
		credits = seed.rarity + seed.potency
		msg = "New species discovered: \"[capitalize(seed.species)]\". Excellent work."
		SSblackbox.record_feedback("tally", "cargo seeds sold", 1, "new")

	if(credits == 0)
		return

	SSblackbox.record_feedback("tally", "cargo seeds sold", 1, "amount")
	SSblackbox.record_feedback("tally", "cargo seeds sold", credits, "credits")

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
		SSblackbox.record_feedback("tally", "cargo seeds sold", 1, "boring")
	else if(SSeconomy.discovered_plants[seed.type] && SSeconomy.discovered_plants[seed.type] < seed.potency)
		item.reason = "New sample of \"[capitalize(seed.species)]\" is not more potent than existing sample ([SSeconomy.discovered_plants[seed.type]] potency)."
		manifest.line_items += item
		SSblackbox.record_feedback("tally", "cargo seeds sold", 1, "repeat")
	// If neither succeeds, this seed was declared wrong by a different
	// seller, so we should be quiet.


/datum/economy/simple_seller/messes

/datum/economy/simple_seller/messes/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/effect))
		var/obj/effect/E = AM
		if(E.is_cleanable())
			return COMSIG_CARGO_MESS | COMSIG_CARGO_IS_SECURED


/datum/economy/simple_seller/containers

/datum/economy/simple_seller/containers/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/storage))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/containers/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return
	SSblackbox.record_feedback("amount", "cargo containers sold", 1)


/datum/economy/simple_seller/mechs

/datum/economy/simple_seller/mechs/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return
	SSblackbox.record_feedback("tally", "cargo basic mechs sold", 1, "amount")
	SSblackbox.record_feedback("tally", "cargo basic mechs sold", SSeconomy.credits_per_mech, "credits")

	var/datum/economy/line_item/cargo_item = new
	cargo_item.account = SSeconomy.cargo_account
	cargo_item.credits = SSeconomy.credits_per_mech / 2
	cargo_item.reason = "Received a working [AM.name], great job!"
	manifest.line_items += cargo_item

	var/datum/economy/line_item/science_item = new
	science_item.account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SCIENCE)
	science_item.credits = SSeconomy.credits_per_mech / 2
	science_item.reason = "Received a working [AM.name], great job!"
	manifest.line_items += science_item


/datum/economy/simple_seller/mechs/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/mecha/working))
		return COMSIG_CARGO_SELL_NORMAL


// Skip mech parts to avoid complaining about them.
/datum/economy/simple_seller/mech_parts

/datum/economy/simple_seller/mech_parts/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM.loc, /obj/mecha/working))
		return COMSIG_CARGO_SELL_SKIP

/datum/economy/simple_seller/explorer_salvage
	var/list/salvage_counts = list()

/datum/economy/simple_seller/explorer_salvage/begin_sell(obj/docking_port/mobile/supply/S)
	LAZYCLEARLIST(salvage_counts)

/datum/economy/simple_seller/explorer_salvage/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(istype(AM, /obj/item/salvage))
		return COMSIG_CARGO_SELL_NORMAL

/datum/economy/simple_seller/explorer_salvage/sell_normal(obj/docking_port/mobile/supply/S, atom/movable/AM, datum/economy/cargo_shuttle_manifest/manifest)
	if(!..())
		return

	salvage_counts[AM.name]++

/datum/economy/simple_seller/explorer_salvage/end_sell(obj/docking_port/mobile/supply/S, datum/economy/cargo_shuttle_manifest/manifest)
	if(!salvage_counts)
		return
	for(var/salvage_name in salvage_counts)
		var/datum/economy/line_item/item = new
		item.account = SSeconomy.cargo_account
		var/count = salvage_counts[salvage_name]
		item.credits = count * SSeconomy.credits_per_salvage
		item.reason = "Received [count] haul(s) of [salvage_name]."
		manifest.line_items += item
		SSblackbox.record_feedback("nested tally", "cargo salvage sold", count, list(salvage_name, "count"))
		SSblackbox.record_feedback("nested tally", "cargo salvage sold", item.credits, list(salvage_name, "credits"))

/datum/economy/simple_seller/shelved_items

/datum/economy/simple_seller/shelved_items/check_sell(obj/docking_port/mobile/supply/S, atom/movable/AM)
	if(AM.GetComponent(/datum/component/shelved))
		return COMSIG_CARGO_IS_SECURED

/datum/economy/cargo_shuttle_manifest
	var/list/items_to_sell = list()
	var/list/line_items = list()
	var/loose_cargo = FALSE
	var/messy_shuttle = FALSE
	var/sent_trash = FALSE


/datum/economy/line_item
	var/datum/money_account/account
	var/requests_console_department
	var/credits
	var/reason
	var/zero_is_good = FALSE

#undef MAX_CRATE_DELIVERY

#undef CARGO_OK
#undef CARGO_PREVENT_SHUTTLE
#undef CARGO_SKIP_ATOM
#undef CARGO_REQUIRE_PRIORITY
#undef CARGO_HAS_PRIORITY
