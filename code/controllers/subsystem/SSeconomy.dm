SUBSYSTEM_DEF(economy)
	name = "Economy"
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_ECONOMY //needs to init AFTER SSjobs
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME
	offline_implications = "Crew wont get their paychecks. No immediate action is needed." // money go down
	cpu_display = SS_CPUDISPLAY_LOW
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
	///The amount of transfers (that are worth more than a few credits) that have been accepted during the round
	var/total_credit_transfers = 0
	///the amount of venor purchases during the round
	var/total_vendor_transactions = 0
	///amount of money spent in this 15 minute slot during the round
	var/current_10_minute_spending = 0

	///list of vars that will be tracked throughout the round (a new entry for each key list will be added every 15 minutes)
	var/list/economy_data = list(
		"totalcash" = list(),         //how much space cash is in circulation
		"totalcredits" = list(),      //How many space credits are in circulation
		"creditsdestroyed" = list(),  //How many space credits have been removed from the round
		"totaltransfers" = list(),    //How many transfers have been accped (above $4) this round
		"moneyvelocity" = list(),     //What is the money velocity of this 10 minute period  GDP/MS
		"totalvends" = list(),        //How many purchases have been made from vendors this round
		"stagnant_accounts" = list(), //How many accounts have not made any transactions this round
		"stagnant_cash" = list(),     //How many credits are sitting in stagnant accounts this round
		"non_stagnant_cash" = list()  //How many credits are in active accounts this round
	)
	///time to next stats check
	var/next_data_check = 0


	//////CARGO VARIABLES/////
	///the department account tethered to this supply console, we keep a ref here for shuttle operations
	var/datum/money_account/cargo_account
	///Current Order number
	var/ordernum = 1

	/// credits gained per slip returned
	var/credits_per_manifest = 5
	/// credits gained per intel sold
	var/credits_per_intel = 750
	/// credits gained per plasma sold
	var/credits_per_plasma = 10
	/// credits gained per research design sold
	var/credits_per_design = 20
	/// points gained per salvage sold
	var/credits_per_salvage = 100
	/// credits gained per working mech sold
	var/credits_per_mech = 100
	/// credits gained for each secondary goal completed
	/// These get split in 3, one part for Cargo, one for the department,
	/// and one part for the person who requested the goal.
	var/credits_per_easy_reagent_goal = 150
	var/credits_per_normal_reagent_goal = 300
	var/credits_per_hard_reagent_goal = 450
	var/credits_per_variety_reagent_goal = 300
	var/credits_per_easy_food_goal = 300
	var/credits_per_normal_food_goal = 450
	var/credits_per_hard_food_goal = 600
	var/credits_per_variety_food_goal = 450
	var/credits_per_ripley_goal = 600
	var/credits_per_kudzu_goal = 600
	var/credits_per_easy_smith_goal = 150
	var/credits_per_normal_smith_goal = 225
	var/credits_per_hard_smith_goal = 300
	/// credits lost for sending unsecured cargo
	var/fine_for_loose_cargo = -100
	/// credits lost for sending a messy shuttle
	var/fine_for_messy_shuttle = -100
	/// credits lost for sending unwanted items
	var/fine_for_selling_trash = -100
	/// points gained per virology goal
	var/credits_per_virology_goal = 200

	/// Remarks from Centcom on how well you checked the last order.
	var/centcom_message
	/// Typepaths for unusual plants we've already sent CentComm, associated with their potencies
	var/list/discovered_plants = list()
	var/list/tech_levels = list()
	var/list/research_designs = list()

	///Requested crates, waiting for approval by department heads
	var/list/request_list = list()
	///Approved Crates, waiting to be delivered
	var/list/shopping_list = list()
	///Crates that will be on next shuttle
	var/list/delivery_list = list()

	///Full list of all available supply packs to purchase
	var/list/supply_packs = list()
	var/sold_atoms = ""

	var/list/all_supply_groups = list(
		SUPPLY_EMERGENCY,
		SUPPLY_SECURITY,
		SUPPLY_ENGINEER,
		SUPPLY_MEDICAL,
		SUPPLY_SCIENCE,
		SUPPLY_ORGANIC,
		SUPPLY_MATERIALS,
		SUPPLY_MISC,
		SUPPLY_VEND,
		SUPPLY_SHUTTLE
	)
	///The modifier on crate prices to multiple the price by.
	var/pack_price_modifier = 1

	//////Paycheck Variables/////
	/// time to next payday
	var/next_paycheck_delay = 0
	/// total paydays this round
	var/payday_count = 0
	/// Time until the next mail shipment
	var/next_mail_delay = 0

	var/global_paycheck_bonus = 0
	var/global_paycheck_deduction = 0

/datum/controller/subsystem/economy/vv_edit_var(var_name, var_value)
	switch(var_name)
		//These are all things that admins should not be touching during production, these are either used for logging
		//or economy critical things that should not be touched
		if("payday_count")
			return FALSE //fuck off, used for logging
		if("sold_atoms")
			return FALSE //fuck off, used for logging
		if("cargo_account")
			if(!istype(var_value, /datum/money_account))
				return FALSE //really fuck off, you're vv editing something to a value that will break the economy
	return ..()

/proc/init_current_date_string()
	if(!GLOB.current_date_string)
		GLOB.current_date_string = "[time2text(world.timeofday, "DD Month")], [GLOB.game_year]"

/datum/controller/subsystem/economy/Initialize()
	init_current_date_string()
	///create main station accounts
	if(GLOB.station_money_database)
		populate_station_database()
		cargo_account = GLOB.station_money_database.get_account_by_department(DEPARTMENT_SUPPLY)
	if(!cargo_account)
		WARNING("SSeconomy could not locate the supply department account")
	//need to set this back to 0 due to how this is tracked (and so we have a clean slate for roundstart)
	current_10_minute_spending = 0
	ordernum = rand(1, 9000)

	// these represent intermediate types, we really shouldn't bother with them
	var/list/ignored_supply_pack_types = list(
		/datum/supply_packs/abstract,
		/datum/supply_packs/abstract/shuttle
	)

	for(var/typepath in subtypesof(/datum/supply_packs) - ignored_supply_pack_types)
		var/datum/supply_packs/P = typepath
		if(initial(P.name) == "HEADER" || isnull(initial(P.name)))
			continue // To filter out group headers
		P = new typepath()
		supply_packs["[P.type]"] = P

	centcom_message = "<center>---[station_time_timestamp()]---</center><br>Remember to stamp and send back the supply manifests.<hr>"

	next_paycheck_delay = 30 MINUTES + world.time
	next_mail_delay = 15 MINUTES + world.time

	check_total_virology_goals_completion()

/datum/controller/subsystem/economy/fire()
	if(next_paycheck_delay <= world.time)
		next_paycheck_delay = 30 MINUTES + world.time
		payday()
	if(next_data_check <= world.time)
		next_data_check = 10 MINUTES + world.time
		record_economy_data()
	process_job_tasks()
	if(next_mail_delay <= world.time)
		if(!is_admin_level(SSshuttle.supply.z) || SSshuttle.supply.areaInstance.moving)
			return
		next_mail_delay = 15 MINUTES + world.time
		SSshuttle.mail_delivery()

/datum/controller/subsystem/economy/proc/record_economy_data()
	economy_data["totalcash"] += total_space_cash
	economy_data["totalcredits"] += total_space_credits
	economy_data["creditsdestroyed"] += space_credits_destroyed - listgetindex(economy_data["creditsdestroyed"], length(economy_data["creditsdestroyed"]))
	economy_data["totaltransfers"] += total_credit_transfers - listgetindex(economy_data["totaltransfers"], length(economy_data["totaltransfers"]))
	economy_data["totalvends"] += total_vendor_transactions - listgetindex(economy_data["totalvends"], length(economy_data["totalvends"]))
	economy_data["moneyvelocity"] += round((current_10_minute_spending / total_space_cash), 0.001)
	var/stagnant_count = 0
	var/stagnant_cash = 0
	for(var/datum/money_account/account as anything in GLOB.station_money_database.user_accounts)
		if(length(account.account_log) <= payday_count)
			stagnant_count++
			stagnant_cash += account.credit_balance
	economy_data["stagnant_accounts"] += stagnant_count
	economy_data["stagnant_cash"] = stagnant_cash
	economy_data["non_stagnant_cash"] = total_space_credits - stagnant_cash
	current_10_minute_spending = 0
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
		department.department_account = station_db.get_account_by_department(department.department_name)
	//some crates ordered outside of cargo members still need QM explicit approval
	station_db.create_vendor_account()

////////////////////////////
/// Supply Stuff /////////
////////////////////////

/datum/controller/subsystem/economy/proc/generate_supply_order(packID, orderedby, occupation, comment)
	if(!packID)
		return FALSE
	var/datum/supply_packs/pack = locateUID(packID)
	if(!pack)
		return FALSE
	if(!pack.can_order())
		// if this cannot be ordered at this point, just refuse it
		return FALSE

	var/datum/supply_order/order = pack.create_order(orderedby, occupation, comment, ordernum++)
	return order

/datum/controller/subsystem/economy/proc/process_supply_order(datum/supply_order/order, paid_for)
	if(!order)
		CRASH("process_supply_order() called with a null datum/supply_order")

	// remove any other items we share a group with, so only one of these can be ordered at once.
	for(var/datum/supply_order/other_order in SSeconomy.request_list)
		if(other_order.object.singleton_group_id && other_order.object.singleton_group_id == order.object.singleton_group_id)
			SSeconomy.request_list -= other_order

	if(!paid_for && !(order in request_list))
		request_list += order //submit a request but do not finalize it
		return TRUE

	if(order.requires_head_approval || order.requires_cargo_approval)
		return TRUE

	//if purchaser has already paid it means it's fully approved, finalize order
	if(paid_for)
		finalize_supply_order(order) //if payment was succesful, add order to shoppinglist
		return TRUE
	log_debug("process_supply_order() called on Crate [order.ordernum] ordered by [order.orderedby] but isn't paid for and doesn't need approval, deleting")
	qdel(order) //only the strong will survive
	return FALSE

/datum/controller/subsystem/economy/proc/finalize_supply_order(datum/supply_order/order)
	if(!order)
		CRASH("finalize_supply_order() called with a null datum/supply_order")
	if(order in request_list)
		request_list -= order

	order.object.on_order_confirm(order)

	// Abstract orders won't get added to the shuttle delivery list -- if they're finalized, they're getting processed here and now.
	if(istype(order.object, /datum/supply_packs/abstract))
		return

	if(SSshuttle.supply.getDockedId() == "supply_away" && SSshuttle.supply.mode == SHUTTLE_IDLE)
		delivery_list += order
	else
		shopping_list += order

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
		var/amount_to_pay = account.payday_amount + global_paycheck_bonus - global_paycheck_deduction
		if(LAZYLEN(account.pay_check_bonuses))
			for(var/bonus in account.pay_check_bonuses)
				amount_to_pay += bonus
			account.pay_check_bonuses = null
		for(var/deduction in account.pay_check_deductions)
			amount_to_pay -= deduction
		amount_to_pay = max(amount_to_pay, 0)
		account.pay_check_deductions = null
		if(!amount_to_pay)
			continue
		station_db.credit_account(account, amount_to_pay, "Payday", "NAS Trurl Payroll", FALSE)
		if(account.account_type == ACCOUNT_TYPE_PERSONAL)
			if(LAZYLEN(account.associated_nanobank_programs))
				for(var/datum/data/pda/app/nanobank/program as anything in account.associated_nanobank_programs)
					program.announce_payday(amount_to_pay)
		total_accounts++
		total_payout += amount_to_pay

	//reset global paycheck modifiers to 0
	global_paycheck_bonus = 0
	global_paycheck_deduction = 0
	//update space credit statistics
	space_credits_created += total_payout
	total_space_credits += total_payout
	//alert admins and c*ders alike
	log_debug("Payday Count: [payday_count] - [total_payout] credits paid out to [total_accounts] accounts")


//Called by the gameticker
/datum/controller/subsystem/economy/proc/process_job_tasks()
	for(var/mob/M in GLOB.player_list) //why not just make a global list of players with job objectives???? someone else fix this ~sirryan
		if(!M.mind)
			continue
		for(var/datum/job_objective/objective as anything in M.mind.job_objectives)
			if(objective.completed && objective.payout_given)
				continue //objective is completed and we've already given out award
			if(!objective.is_completed())
				continue //object is not completed, do not proceed
			if(objective.completion_payment == 0)
				objective.payout_given = TRUE
				continue //objective doesn't giveout payout

			if(objective.owner_account)
				objective.owner_account.modify_payroll(objective.completion_payment, TRUE, "Job Objective \"[objective.objective_name]\" completed, award will be included in next paycheck")
				objective.payout_given = TRUE
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
