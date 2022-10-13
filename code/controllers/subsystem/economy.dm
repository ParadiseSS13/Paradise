SUBSYSTEM_DEF(economy)
	name = "Economy"
	flags = SS_BACKGROUND | SS_NO_FIRE
	wait = 10
	runlevels = RUNLEVEL_GAME
	offline_implications = "Nothing, economy will still function"
	///List of all money account databases existing in the round
	var/list/money_account_databases = list()
	///Total amount of account created during the round, neccesary for generating unique account ids
	var/account_counter = 0

	///The absolute total amount of space cash (not to be confused with credits) in the round, does not count space credits in money accounts
	var/total_space_cash = 0
	///The absolute total amount of space credits in various economy systems, does not count space cash
	var/total_space_credits = 0
	///The amount of space credits that have been irreversibly deleted/removed from the round
	var/space_credits_destroyed = 0
	///The amount of space credits that have been created out of thin air, does not include credits created at round-start
	var/space_credits_created = 0


	//////CARGO VARIABLES/////
	///the department account tethered to this supply console, we keep a ref here for shuttle operations
	var/datum/money_account/cargo_account
	///Current Order number
	var/ordernum = 1

	var/credits_per_manifest = 2				//points gained per slip returned
	var/credits_per_crate = 5			//points gained per crate returned
	var/credits_per_intel = 250			//points gained per intel returned
	var/credits_per_plasma = 5			//points gained per plasma returned
	var/credits_per_design = 25			//points gained per research design returned

	var/centcom_message					//Remarks from Centcom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent CentComm, associated with their potencies
	var/list/techLevels = list()
	var/list/researchDesigns = list()

	///Requested crates, waiting for approval by department heads
	var/list/requestlist = list()
	///Approved Crates, waiting to be delivered on next shuttle shipment
	var/list/shoppinglist = list()
	///Full list of all available supply packs to purchase
	var/list/supply_packs = list()
	var/sold_atoms = ""

/datum/controller/subsystem/economy/Initialize()
	///create main station accounts
	if(!GLOB.current_date_string)
		GLOB.current_date_string = "[time2text(world.timeofday, "DD Month")], [GLOB.game_year]"
	if(GLOB.station_money_database)
		populate_station_database()
		cargo_account = GLOB.station_money_database.get_account_by_department("Cargo")
		if(!cargo_account)
			WARNING("SSeconomy could not locate the supply department account")
	if(GLOB.centcomm_money_database)
		populate_cc_database()

	ordernum = rand(1,9000)

	for(var/typepath in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		if(P.name == "HEADER")
			continue // To filter out group headers
		supply_packs["[P.type]"] = P

	centcom_message = "<center>---[station_time_timestamp()]---</center><br>Remember to stamp and send back the supply manifests.<hr>"

	return ..()


/*
  * # generate_account_number()
  *
  * SS proc that will generate a mostly random seven digit account number.
  * This will allow up to 1000 guaranteed unique account numbers
*/
/datum/controller/subsystem/economy/proc/generate_account_number()
	account_counter++
	return (rand(1000, 9999) * 1000) + account_counter

/datum/controller/subsystem/economy/proc/populate_station_database()
	var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
	money_account_databases += station_db
	for(var/department in GLOB.station_departments)
		station_db.create_department_account(department)
		requestlist[department] = list()
	station_db.create_vendor_account()

/datum/controller/subsystem/economy/proc/populate_cc_database()
	var/datum/money_account_database/central_command/cc_db = GLOB.centcomm_money_database
	money_account_databases += cc_db

////////////////////////////
/// Supply Stuff /////////
////////////////////////

/datum/controller/subsystem/economy/proc/generate_supply_order(packID, orderedby, occupation, amount, comment)
	if(!packID)
		return FALSE
	var/datum/supply_packs/pack = locateUID(packID)
	if(!pack)
		return FALSE

	var/datum/supply_order/order = new()
	order.ordernum = ordernum++
	order.object = pack
	order.orderedby = orderedby
	order.orderedbyRank = occupation
	order.comment = comment
	order.crates = amount

	return order

/datum/controller/subsystem/economy/proc/process_supply_order(datum/supply_order/order, datum/money_account/account, datum/money_account_database/account_database, paid_for, department)
	//if purchaser is ordered for a department but not a head of staff
	if(department && !paid_for)
		requestlist[department] += order //submit a request but do not finalize it
		return TRUE
	//if purchaser has already paid with their own personal account, finalize order
	if(paid_for)
		finalize_supply_order(order, department) //if payment was succesful, add order to shoppinglist
		return TRUE
	return FALSE

/datum/controller/subsystem/economy/proc/finalize_supply_order(datum/supply_order/order, department)
	if(!order)
		return FALSE
	shoppinglist += order
	if(department)
		requestlist[department] -= order
