/datum/event/market_crash
	name = "Market Crash"
	nominal_severity = EVENT_LEVEL_MODERATE
	endWhen = 300
	/// Vendor price multiplier
	var/price_mult = 3

/datum/event/market_crash/announce(false_alarm)
	var/list/possible_reasons = list(
		"supply chain shortages",
		"[syndicate_name()] operatives attacking a shipment",
		"space wizard interference",
		"bluespace traffic",
		"gravitational anomalies",
		"extended trade routes",
		"market speculation",
		"vox",
		"a clown college graduation party",
		"a Trans-Solar Federation investigation",
		"too many credits being invested in WetSkrell.nt",
	)

	GLOB.minor_announcement.Announce("Due to [pick(possible_reasons)], prices for on-station vendors will be increased for a short period. We apologize for the inconvenience.", "Central Command Finance Division")

/datum/event/market_crash/start()
	for(var/obj/machinery/economy/vending/vendor in SSmachines.get_by_type(/obj/machinery/economy/vending))
		if(!is_station_level(vendor.z))
			continue
		vendor.build_inventory(vendor.products, vendor.product_records, FALSE, price_mult)
		vendor.build_inventory(vendor.contraband, vendor.hidden_records, FALSE, price_mult)
	addtimer(CALLBACK(src, PROC_REF(reset_prices)), rand(5 MINUTES, 10 MINUTES))

/datum/event/market_crash/proc/reset_prices()
	for(var/obj/machinery/economy/vending/vendor in SSmachines.get_by_type(/obj/machinery/economy/vending))
		if(!is_station_level(vendor.z))
			continue
		vendor.build_inventory(vendor.products, vendor.product_records, FALSE, 1)
		vendor.build_inventory(vendor.contraband, vendor.hidden_records, FALSE, 1)
