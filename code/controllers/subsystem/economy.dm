SUBSYSTEM_DEF(economy)
	name = "Economy"
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_ECONOMY //needs to init AFTER SSjobs
	wait = 30 SECONDS
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

	//////Paycheck Variables/////
	///time to next payday
	var/next_paycheck_delay = 0
	///total paydays this round
	var/payday_count = 0

	var/global_paycheck_bonus = 0
	var/global_paycheck_deducation = 0

/datum/controller/subsystem/economy/Initialize()
	///create main station accounts
	if(!GLOB.current_date_string)
		GLOB.current_date_string = "[time2text(world.timeofday, "DD Month")], [GLOB.game_year]"
	if(GLOB.station_money_database)
		populate_station_database()
		cargo_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY)
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

	next_paycheck_delay = 30 MINUTES + world.time
	return ..()

/datum/controller/subsystem/economy/fire()
	if(next_paycheck_delay <= world.time)
		next_paycheck_delay = 30 MINUTES + world.time
		payday()
	process_job_tasks()


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
	for(var/datum/station_department/department as anything in SSjobs.station_departments)
		station_db.create_department_account(department.department_name, department.account_base_pay, department.account_starting_balance)
		department.department_account = GLOB.station_money_database.get_account_by_department(department.department_name)
		requestlist[department.department_name] = list()
	//some crates ordered outside of cargo members still need QM explicit approval
	requestlist[QM_REQUEST_LIST_NAME] = list()
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

/datum/controller/subsystem/economy/proc/process_supply_order(datum/supply_order/order, paid_for, department)
	if(!order)
		CRASH("process_supply_order() called with a null datum/supply_order")
	//if purchase is ordered for a department
	if(department && !paid_for && !(order in requestlist[department]))
		requestlist[department] += order //submit a request but do not finalize it
		return TRUE
	//if purchase is authenticated and requires QM approve still
	if(order.requires_qm_approval)
		requestlist[QM_REQUEST_LIST_NAME] += order //put up a request up to QM approval
		if(order in requestlist[department])
			requestlist[department] -= order
		return TRUE
	//if purchaser has already paid with their own personal account, finalize order
	if(paid_for)
		finalize_supply_order(order, department) //if payment was succesful, add order to shoppinglist
		return TRUE
	//we shouldn't be here, this means that the crate isn't paid for and doesn't need approval
	qdel(order) //only the strong will survive
	return FALSE

/datum/controller/subsystem/economy/proc/finalize_supply_order(datum/supply_order/order, department)
	if(!order)
		CRASH("finalize_supply_order() called with a null datum/supply_order")
	shoppinglist += order
	if(department)
		requestlist[department] -= order

////////////////////////////
/// Paycheck Stuff /////////
////////////////////////

/datum/controller/subsystem/economy/proc/payday()
	payday_count++
	var/total_payout = 0
	var/total_accounts = 0
	var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
	var/list/all_station_accounts = station_db.user_accounts + station_db.get_all_department_accounts()
	for(var/datum/money_account/account in all_station_accounts)
		var/amount_to_pay = account.payday_amount + global_paycheck_bonus - global_paycheck_deducation
		if(length(account.pay_check_bonuses))
			for(var/bonus in account.pay_check_bonuses)
				amount_to_pay += bonus
				LAZYREMOVE(account.pay_check_bonuses, bonus)
		for(var/deduction in account.pay_check_deductions)
			amount_to_pay = max(amount_to_pay - deduction, 0)
			LAZYREMOVE(account.pay_check_deductions, deduction)
		station_db.credit_account(account, amount_to_pay, "Payday", "NAS Trurl Payroll", FALSE)
		if(account.account_type == ACCOUNT_TYPE_PERSONAL)
			for(var/datum/data/pda/app/nanobank/program as anything in account.associated_nanobank_programs)
				program.announce_payday(amount_to_pay)
		total_accounts++
		total_payout += amount_to_pay

	//reset global paycheck modifiers to 0
	global_paycheck_bonus = 0
	global_paycheck_deducation = 0
	//update space credit statistics
	space_credits_created += total_payout
	total_space_credits += total_payout
	//alert admins and c*ders alike
	log_debug("Payday Count: [payday_count] - [total_payout] credits paid out to [total_accounts] accounts")
	message_admins("Here comes the money! Payday: [total_payout] credits paid out to [total_accounts] accounts")


//Called by the gameticker
/datum/controller/subsystem/economy/proc/process_job_tasks()
	for(var/mob/M in GLOB.player_list) //why not just make a global list of players with job objectives???? someone else fix this ~sirryan
		if(M.mind)
			for(var/datum/job_objective/objective in M.mind.job_objectives)
				if(objective.completed && objective.payout_given)
					continue //objective is completed and we've already given out award
				if(!objective.is_completed())
					continue //object is not completed, do not proceed
				if(objective.completion_payment == 0)
					objective.payout_given = TRUE
					continue //objective doesn't giveout payout

				if(objective.owner_account)
					GLOB.station_money_database.credit_account(objective.owner_account, objective.completion_payment, "Job Objective Completion Bonus")
					objective.owner_account.modify_payroll(objective.completion_payment, TRUE, "Job Objective \"[objective.objective_name]\" completed, award will be included in next paycheck")
				else
					log_debug("Job objective ([objective.objective_name]) does not have an associated money account")
				break

//
//   The NanoCoin Economy is booming
//	  My Parabuck Stocks are Rising
//     God Bless John Nanotrasen
//
//           __-----__
//      ..;;;--'~~~`--;;;..
//     /; -~IN NANOTRASEN ;.
//	  //     WE TRUST~-    \\
//   //      ,-------,      \\
// .//      | ;;;   ~ \      \\.
// ||       |;;;(   /.|       ||
// ||       |;;       _\      ||
// ||       '.      '===      ||
// || PROFIT | ''\  ;;;/      ||
//  \\     ,| '\  '|><| 2223 //
//   \\   |     |      \  AD//
//    `;.,|.    |      '\.-'/
//      ~~;;;,._|___.,-;;;~'
//         ''=--'
//
