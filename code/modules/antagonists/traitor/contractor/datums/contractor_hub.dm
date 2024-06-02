/**
  * # Syndicate Hub
  *
  * Describes and manages the contracts and rewards for a single contractor.
  */
/datum/contractor_hub
	// Settings
	/// The number of contracts to generate initially.
	var/num_contracts = 6
	/// How much Contractor Rep to earn per contract completion.
	var/rep_per_completion = 2
	/// Completing every contract at a given difficulty will always result in a sum of TC greater or equal than the difficulty's threshold.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => number
	var/difficulty_tc_thresholds = list(
		EXTRACTION_DIFFICULTY_EASY = 100,
		EXTRACTION_DIFFICULTY_MEDIUM = 150,
		EXTRACTION_DIFFICULTY_HARD = 200,
	)
	/// Maximum variation a single contract's TC reward can have upon generation.
	/// In other words: final_reward = CEILING((tc_threshold / num_contracts) * (1 - (rand(0, 100) / 100) * tc_variation), 1)
	var/tc_variation = 0.25
	/// TC reward multiplier if the target was extracted DEAD. Should be a penalty so between 0 and 1.
	/// The final amount is rounded up.
	var/dead_penalty = 0.2
	/// List of purchases that can be done for Rep.
	var/list/datum/rep_purchase/purchases = list(
		/datum/rep_purchase/reroll,
		/datum/rep_purchase/item/pinpointer,
		/datum/rep_purchase/item/baton,
		/datum/rep_purchase/item/fulton,
		/datum/rep_purchase/item/flare,
		/datum/rep_purchase/blackout,
		/datum/rep_purchase/item/zippo,
		/datum/rep_purchase/item/balloon,
	)
	// Variables
	/// The contractor associated to this hub.
	var/datum/mind/owner = null
	/// The contractor uplink associated to this hub.
	var/obj/item/contractor_uplink/contractor_uplink = null
	/// The current contract in progress.
	var/datum/syndicate_contract/current_contract = null
	/// The contracts offered by the hub.
	var/list/datum/syndicate_contract/contracts = null
	/// List of targets from each contract in [/datum/contractor_hub/var/contracts].
	/// Used to make sure two contracts from the same hub don't have the same target.
	var/list/datum/mind/targets = null
	/// Amount of telecrystals available for redeeming.
	var/reward_tc_available = 0
	/// Total amount of paid out telecrystals since the start.
	var/reward_tc_paid_out = 0
	/// The number of completed contracts.
	var/completed_contracts = 0
	/// Amount of Contractor Rep available for spending.
	var/rep = 0
	/// Current UI page index.
	var/page = HUB_PAGE_CONTRACTS

/datum/contractor_hub/New(datum/mind/O, obj/item/contractor_uplink/U)
	owner = O
	contractor_uplink = U
	// Instantiate purchases
	for(var/i in 1 to length(purchases))
		if(ispath(purchases[i]))
			var/datum/rep_purchase/P = purchases[i]
			purchases[i] = new P
		else
			stack_trace("Expected Hub purchase [purchases[i]] to be a type but it wasn't!")

/datum/contractor_hub/ui_host(mob/user)
	return contractor_uplink

/**
  * Called when the loading animation completes for the first time.
  */
/datum/contractor_hub/proc/first_login(mob/user)
	if(!is_user_authorized(user))
		return
	user.playsound_local(user, 'sound/effects/contractstartup.ogg', 30, FALSE, use_reverb = FALSE)
	generate_contracts()
	SStgui.update_uis(src)

/**
  * Regenerates a list of contracts for the contractor to take up.
  */
/datum/contractor_hub/proc/generate_contracts()
	contracts = list()
	targets = list()

	var/num_to_generate = min(num_contracts, length(GLOB.data_core.locked))
	if(num_to_generate <= 0) // ?
		return

	// Contract generation
	var/total_earnable_tc = list(0, 0, 0)
	for(var/i in 1 to num_to_generate)
		var/datum/syndicate_contract/C = new(src, owner, targets)
		// Calculate TC reward for each difficulty
		C.reward_tc = list(null, null, null)
		for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
			var/amount_tc = calculate_tc_reward(num_to_generate, difficulty)
			C.reward_tc[difficulty] = amount_tc
			total_earnable_tc[difficulty] += amount_tc
		// Add to lists
		contracts += C
		targets += C.contract.target

	// Fill the gap if a difficulty doesn't meet the TC threshold
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		var/total = total_earnable_tc[difficulty]
		var/missing = difficulty_tc_thresholds[difficulty] - total
		// Increment the TC payout of a random contract till we're even
		while(missing-- > 0)
			var/datum/syndicate_contract/C = pick(contracts)
			C.reward_tc[difficulty]++

/**
  * Generates an amount of TC to be used as a contract reward for the given difficulty.
  *
  * Arguments:
  * * total_contracts - The number of contracts being generated.
  * * difficulty - The difficulty to base the threshold from.
  */
/datum/contractor_hub/proc/calculate_tc_reward(total_contracts, difficulty = EXTRACTION_DIFFICULTY_EASY)
	ASSERT(total_contracts > 0)
	return FLOOR((difficulty_tc_thresholds[difficulty] / total_contracts) * (1 - (rand(0, 100) / 100) * tc_variation), 1)

/**
  * Called when a [/datum/syndicate_contract] has been completed.
  *
  * Arguments:
  * * tc - The final amount of TC to award.
  * * creds - The final amount of credits to award.
  */
/datum/contractor_hub/proc/on_completion(tc, creds)
	completed_contracts++
	reward_tc_available += tc
	rep += rep_per_completion
	var/notify_text = pick("CONGRATULATIONS. You are the 10,000th visitor of SquishySlimes.squish. Please find attached your [creds] credits.",
						"Congratulations on winning your bet in the latest Clown vs. Mime match! Your account was credited with [creds] credits.",
						"Deer fund beneficiary, We have please to imform you that overdue fund payments has finally is approved and yuor account credited with [creds] creadits.",
						"Hey bro. How's it going? You bought me a beer a long time ago and I want to pay you back with [creds] creds. Enjoy!",
						"Thank you for your initial investment of 500 credits! We have credited your account with [creds] as a token of appreciation.",
						"Your refund request for 100 Dr. Maxman pills with the reason \"I need way more than 100 pills!\" has been received. We have credited your account with [creds] credits.",
						"Your refund request for your WetSkrell.nt subscription has been received. We have credited your account with [creds] credits.",
					)
	var/transaction_person
	if(prob(50))
		transaction_person = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	else
		transaction_person = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	//we want to make this transfer look real as possible, only if someone is really really closely looking at it will they notic the transaction person isn't real
	if(GLOB.station_money_database.credit_account(owner?.initial_account, creds, "Transfer From [transaction_person]", "NanoBank Transfer Services", FALSE))
		if(LAZYLEN(owner.initial_account.associated_nanobank_programs))
			for(var/datum/data/pda/app/nanobank/program as anything in owner.initial_account.associated_nanobank_programs)
				program.notify(notify_text, TRUE)
	current_contract = null

/**
  * Gives any unclaimed TC to the given mob.
  *
  * Arguments:
  * * M - The mob to give the TC to.
  */
/datum/contractor_hub/proc/claim_tc(mob/living/M)
	if(reward_tc_available <= 0)
		return

	// Spawn the crystals
	var/obj/item/stack/telecrystal/TC = new(get_turf(M), reward_tc_available)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.put_in_hands(TC))
			to_chat(H, "<span class='notice'>Your payment materializes into your hands!</span>")
		else
			to_chat(M, "<span class='notice'>Your payment materializes on the floor.</span>")
	// Update info
	reward_tc_paid_out += reward_tc_available
	reward_tc_available = 0

/**
  * Returns whether the given mob is allowed to connect to the uplink.
  *
  * Arguments:
  * * M - The mob.
  */
/datum/contractor_hub/proc/is_user_authorized(mob/living/carbon/M)
	return LAZYACCESS(GLOB.contractors, M.mind) && M.mind == owner
