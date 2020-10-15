#define CREDIT_REWARD_BASE 100
#define CREDIT_REWARD_MULT_MIN 25
#define CREDIT_REWARD_MULT_MAX 45
#define DEFAULT_NAME "Unknown"
#define DEFAULT_RANK "Unknown"
#define EXTRACTION_PHASE_PREPARE 5 SECONDS
#define EXTRACTION_PHASE_STEP_1 5 SECONDS
#define COMPLETION_NOTIFY_DELAY 5 SECONDS
#define RETURN_BRUISE_CHANCE 50
#define RETURN_BRUISE_DAMAGE 20
#define RETURN_SOUVENIR_CHANCE 10

/**
  * # Syndicate Contract
  *
  * Describes a contract that can be completed by a [/datum/antagonist/traitor/contractor].
  */
/datum/syndicate_contract
	// Settings
	/// Cooldown before making another extraction request in deciseconds.
	var/extraction_cooldown = 10 MINUTES
	/// How long an extraction portal remains before going away. Should be less than [/datum/syndicate_contract/var/extraction_cooldown].
	var/portal_duration = 5 MINUTES
	/// How long a target remains in the Syndicate jail.
	var/prison_time = 4 MINUTES
	/// List of items a target can get randomly after their return.
	var/list/obj/item/souvenirs = list(
		/obj/item/bedsheet/syndie,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/reagent_containers/food/snacks/syndicake,
		/obj/item/reagent_containers/food/snacks/tatortot,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/toy/figure/syndie,
		/obj/item/toy/nuke,
		/obj/item/toy/plushie/nukeplushie,
		/obj/item/toy/sword,
		/obj/item/toy/syndicateballoon,
		/obj/structure/sign/poster/contraband/syndicate_recruitment,
	)
	// Variables
	/// The owning contractor hub.
	var/datum/contractor_hub/owning_hub = null
	/// The [/datum/objective/contract] associated to this contract.
	var/datum/objective/contract/contract = null
	/// Current contract status.
	var/status = CONTRACT_STATUS_INVALID
	/// Formatted station time at which the contract was completed, if applicable.
	var/completed_time = ""
	/// Visual reason as to why the contract failed, if applicable.
	var/fail_reason = ""
	/// The selected difficulty.
	var/chosen_difficulty = -1
	/// The flare indicating the extraction point.
	var/obj/effect/contractor_flare/extraction_flare = null
	/// The extraction portal.
	var/obj/effect/portal/redspace/contractor/extraction_portal = null
	/// The world.time at which the current extraction fulton will vanish and another extraction can be requested.
	var/extraction_deadline = -1
	/// Name of the target to display on the UI.
	var/target_name = ""
	/// Fluff message explaining why the kidnapee is the target.
	var/fluff_message = ""
	/// The target's photo to display on the UI.
	var/image/target_photo = null
	/// Amount of telecrystals the contract will receive upon completion, depending on the chosen difficulty.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => number
	var/list/reward_tc = null
	/// Amount of credits the contractor will receive upon completion.
	var/reward_credits = 0
	/// The kidnapee's belongings. Set upon extraction by the contractor.
	var/list/obj/item/victim_belongings = null
	/// Deadline reached timer handle. Deletes the portal and tells the agent to call extraction again.
	var/extraction_timer_handle = null
	/// Whether the additional fluff story from any contractor completing all of their contracts was made already or not.
	var/static/nt_am_board_resigned = FALSE

/datum/syndicate_contract/New(datum/contractor_hub/hub, datum/mind/owner, list/datum/mind/target_blacklist)
	owning_hub = hub
	contract = new /datum/objective/contract(src)
	contract.owner = owner
	contract.target_blacklist = target_blacklist
	generate()

/**
  * Fills the contract with valid data to be used.
  */
/datum/syndicate_contract/proc/generate()
	. = FALSE
	// Select the target
	contract.find_target()
	var/datum/mind/T = contract.target
	if(!T)
		return

	// In case the contract is invalidated
	contract.extraction_zone = null
	contract.target_blacklist += T
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		contract.pick_candidate_zone(difficulty)

	// Fill data
	var/datum/data/record/R = find_record("name", T.name, GLOB.data_core.general)
	target_name = "[R?.fields["name"] || DEFAULT_NAME], the [R?.fields["rank"] || DEFAULT_RANK]"
	reward_credits = CREDIT_REWARD_BASE * rand(CREDIT_REWARD_MULT_MIN, CREDIT_REWARD_MULT_MAX)

	// Fluff message
	var/base = pick(strings(CONTRACT_STRINGS_WANTED, "basemessage"))
	var/verb_string = pick(strings(CONTRACT_STRINGS_WANTED, "verb"))
	var/noun = pickweight(strings(CONTRACT_STRINGS_WANTED, "noun"))
	var/location = pickweight(strings(CONTRACT_STRINGS_WANTED, "location"))
	fluff_message = "[base] [verb_string] [noun] [location]."

	// Photo
	if(R?.fields["photo"])
		var/icon/temp = new('icons/turf/floors.dmi', pick("floor", "wood", "darkfull", "stairs"))
		temp.Blend(R.fields["photo"], ICON_OVERLAY)
		target_photo = temp
	else
		target_photo = null

	// OK
	status = CONTRACT_STATUS_INACTIVE
	fail_reason = ""

	return TRUE

/**
  * Begins the contract if possible.
  *
  * Arguments:
  * * M - The contractor.
  * * difficulty - The chosen difficulty level.
  */
/datum/syndicate_contract/proc/initiate(mob/M, difficulty = EXTRACTION_DIFFICULTY_EASY)
	. = FALSE
	if(status != CONTRACT_STATUS_INACTIVE || !ISINDEXSAFE(reward_tc, difficulty))
		return
	else if(owning_hub.current_contract)
		to_chat(M, "<span class='warning'>You already have an ongoing contract!</span>")
		return

	if(!contract.choose_difficulty(difficulty, src))
		return FALSE

	status = CONTRACT_STATUS_ACTIVE
	chosen_difficulty = difficulty
	owning_hub.current_contract = src
	owning_hub.uplink?.message_holder("Request for this contract confirmed. Good luck, agent.", 'sound/machines/terminal_prompt.ogg')

	return TRUE

/**
  * Marks the contract as completed and gives the rewards to the contractor.
  *
  * Arguments:
  * * target_dead - Whether the target was extracted dead.
  */
/datum/syndicate_contract/proc/complete(target_dead = FALSE)
	if(status != CONTRACT_STATUS_ACTIVE)
		return
	var/final_tc_reward = reward_tc[chosen_difficulty]
	if(target_dead == DEAD)
		final_tc_reward = CEILING(final_tc_reward * owning_hub.dead_penalty, 1)

	owning_hub.completed_contracts++
	owning_hub.reward_tc_available += final_tc_reward
	owning_hub.rep += owning_hub.rep_per_completion
	owning_hub.owner?.initial_account?.credit(reward_credits, pick(list(
		"CONGRATULATIONS. You are the 10,000th visitor of SquishySlimes.squish. Please find attached your [reward_credits] credits.",
		"Congratulations on winning your bet in the latest Clown vs. Mime match! Your account was credited with [reward_credits] credits.",
		"Deer fund beneficiary, We have please to imform you that overdue fund payments has finally is approved and yuor account credited with [reward_credits] creadits.",
		"Hey bro. How's it going? You bought me a beer a long time ago and I want to pay you back with [reward_credits] creds. Enjoy!",
		"Thank you for your initial investment of 500 credits! We have credited your account with [reward_credits] as a token of appreciation.",
		"Your refund request for 100 Dr. Maxman pills with the reason \"I need way more than 100 pills!\" has been received. We have credited your account with [reward_credits] credits.",
		"Your refund request for your WetSkrell.nt subscription has been received. We have credited your account with [reward_credits] credits.",
	)))
	owning_hub.current_contract = null

	status = CONTRACT_STATUS_COMPLETED
	completed_time = station_time_timestamp()
	addtimer(CALLBACK(src, .proc/notify_completion, final_tc_reward, reward_credits, target_dead), COMPLETION_NOTIFY_DELAY)

/**
  * Marks the contract as invalid and effectively cancels it for later use.
  */
/datum/syndicate_contract/proc/invalidate()
	if(status in list(CONTRACT_STATUS_COMPLETED, CONTRACT_STATUS_FAILED))
		return

	clean_up()

	var/pre_text = ""
	if(src == owning_hub.current_contract)
		owning_hub.current_contract = null
		pre_text = "Agent, it appears the target you were tasked to kidnap can no longer be reached."
	else
		pre_text = "Agent, a still inactive contract can no longer be done as the target has gone off our sensors."

	var/outcome_text = ""
	if(generate())
		status = CONTRACT_STATUS_INACTIVE
		outcome_text = "Luckily, there is another target on station we can interrogate. A new contract can be found in your uplink."
	else
		// Too bad.
		status = CONTRACT_STATUS_INVALID
		outcome_text = "Unfortunately, we could not find another target to interrogate and thus we cannot give you another contract."

	if(owning_hub.uplink)
		owning_hub.uplink.message_holder("[pre_text] [outcome_text]", 'sound/machines/terminal_prompt_deny.ogg')
		SStgui.update_uis(owning_hub.uplink)

/**
  * Marks the contract as failed and stops it.
  *
  * Arguments:
  * * difficulty - The visual reason as to why the contract failed.
  */
/datum/syndicate_contract/proc/fail(reason = "")
	if(status != CONTRACT_STATUS_ACTIVE)
		return

	// Update info
	owning_hub.current_contract = null
	status = CONTRACT_STATUS_FAILED
	fail_reason = reason
	// Notify
	clean_up()
	owning_hub.uplink?.message_holder("You failed to kidnap the target, agent. Do not disappoint us again.", 'sound/machines/terminal_prompt_deny.ogg')

/**
  * Initiates the extraction process if conditions are met.
  *
  * Arguments:
  * * M - The contractor.
  */
/datum/syndicate_contract/proc/start_extraction_process(obj/item/contractor_uplink/U, mob/living/carbon/human/M)
	if(!U?.Adjacent(M))
		return "Where in space is your uplink?!"
	else if(status != CONTRACT_STATUS_ACTIVE)
		return "This contract is not active."
	else if(extraction_deadline > world.time)
		return "Another extraction attempt cannot be made yet."

	var/mob/target = contract.target.current
	if(!target)
		invalidate()
		return "The target is no longer on our sensors. Your contract will be invalidated and replaced with another one."
	else if(!contract.can_start_extraction_process(M, target))
		return "You and the target must be standing in the extraction area to start the extraction process."

	M.visible_message("<span class='notice'>[M] starts entering a cryptic series of characters on [U].</span>",\
					  "<span class='notice'>You start entering an extraction signal to your handlers on [U]..</span>")
	if(do_after(M, EXTRACTION_PHASE_PREPARE, target = M))
		if(!U?.Adjacent(M) || extraction_deadline > world.time)
			return
		var/obj/effect/contractor_flare/F = new(get_turf(M))
		extraction_flare = F
		extraction_deadline = world.time + extraction_cooldown
		M.visible_message("<span class='notice'>[M] enters a mysterious code on [U] and pulls a black and gold flare from [M.p_their()] belongings before lighting it.</span>",\
						  "<span class='notice'>You finish entering the signal on [U] and light an extraction flare, initiating the extraction process.</span>")
		addtimer(CALLBACK(src, .proc/extraction_step_1, U, M, F), EXTRACTION_PHASE_STEP_1)
		extraction_timer_handle = addtimer(CALLBACK(src, .proc/deadline_reached), portal_duration, TIMER_STOPPABLE)

/**
  * First step of the extraction process.
  *
  * Arguments:
  * * U - The uplink.
  * * M - The contractor.
  * * F - The flare.
  */
/datum/syndicate_contract/proc/extraction_step_1(obj/item/contractor_uplink/U, mob/living/carbon/human/M, obj/effect/contractor_flare/F)
	if(!U || !M || status != CONTRACT_STATUS_ACTIVE)
		invalidate()
		return
	else if(!F)
		U.message_holder("Extraction flare could not be located, agent. Ensure the extraction zone is clear before signaling us.", 'sound/machines/terminal_prompt_deny.ogg')
		return
	else if(!ismob(contract.target?.current))
		invalidate()
		return
	U.message_holder("Extraction signal received, agent. [GLOB.using_map.full_name]'s redspace transport jamming systems have been sabotaged. "\
			 	   + "We have opened a temporary portal at your flare location - proceed to the target's extraction by inserting them into the portal.", 'sound/effects/confirmdropoff.ogg')
	// Open a portal
	var/obj/effect/portal/redspace/contractor/P = new(get_turf(F), pick(GLOB.syndieprisonwarp), null, 0)
	P.contract = src
	P.contractor_mind = M.mind
	P.target_mind = contract.target
	extraction_portal = P
	do_sparks(4, FALSE, P.loc)

/**
  * Called when a contract target has been extracted through the portal.
  *
  * Arguments:
  * * M - The target mob.
  * * P - The extraction portal.
  */
/datum/syndicate_contract/proc/target_received(mob/M, obj/effect/portal/redspace/contractor/P)
	complete(M.stat == DEAD)
	handle_target_experience(M, P)
	clean_up()

/**
  * Notifies the uplink's holder that a contract has been completed.
  *
  * Arguments:
  * * tc - How many telecrystals they have received.
  * * creds - How many credits they have received.
  * * target_dead - Whether the target was extracted dead.
  */
/datum/syndicate_contract/proc/notify_completion(tc = 0, creds = 0, target_dead = FALSE)
	var/penalty_text = ""
	if(target_dead)
		penalty_text = " (penalty applied as the target was not extracted alive)"
	owning_hub.uplink?.message_holder("Well done, agent. The package has been received and will be processed shortly before being returned. "\
									 + "As agreed, you have been credited with [tc] telecrystals[penalty_text] and [creds] credits.", 'sound/machines/terminal_prompt_confirm.ogg')

/**
  * Handles the target's experience from extraction.
  *
  * Arguments:
  * * M - The target mob.
  * * P - The extraction portal.
  */
/datum/syndicate_contract/proc/handle_target_experience(mob/M, obj/effect/portal/redspace/contractor/P)
	var/turf/T = get_turf(P)
	var/mob/living/carbon/human/H = M

	// Prepare their return
	addtimer(CALLBACK(src, .proc/handle_target_return, M, T), prison_time)

	// Shove all of the victim's items in the secure locker.
	victim_belongings = list()
	var/list/obj/item/stuff_to_transfer = list()
	for(var/obj/item/I in M)
		// Any items we don't want to take from them?
		if(istype(H))
			// Keep their uniform and shoes
			if(I == H.w_uniform || I == H.shoes)
				continue
			// Plasmamen are no use if they're crispy
			if(isplasmaman(H) && I == H.head)
				continue

		// Any kind of implant gets removed (mindshield, etc)
		if(istype(I, /obj/item/implant))
			qdel(I)
			continue

		if(M.unEquip(I))
			stuff_to_transfer += I

	// Cybernetic implants as well
	for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
		// Greys get to keep their implant
		if(isgrey(H) && istype(I, /obj/item/organ/internal/cyberimp/brain/speech_translator))
			continue
		// Try removing it
		I = I.remove(H)
		if(I)
			stuff_to_transfer += I

	// Transfer it all (or drop it if not possible)
	for(var/i in stuff_to_transfer)
		var/obj/item/I = i
		if(GLOB.prisoner_belongings.give_item(I))
			victim_belongings += I
		else if(!((ABSTRACT|NODROP) in I.flags)) // Anything that can't be put on hold, just drop it on the ground
			I.forceMove(T)

	// Give some species the necessary to survive. Courtesy of the Syndicate.
	if(istype(H))
		var/obj/item/tank/emergency_oxygen/tank
		var/obj/item/clothing/mask/breath/mask
		if(isvox(H))
			tank = new /obj/item/tank/emergency_oxygen/nitrogen(H)
			mask = new /obj/item/clothing/mask/breath/vox(H)
		else if(isplasmaman(H))
			tank = new /obj/item/tank/emergency_oxygen/plasma(H)
			mask = new /obj/item/clothing/mask/breath(H)

		if(tank)
			H.equip_to_appropriate_slot(tank)
			H.equip_to_appropriate_slot(mask)
			tank.toggle_internals(H, TRUE)

	M.update_icons()

	// Narrate their kidnapping and torturing experience.
	if (M.stat != DEAD)
		// Heal them up - gets them out of crit/soft crit.
		M.reagents.add_reagent("omnizine", 20)

		to_chat(M, "<span class='warning'>You feel strange...</span>")
		M.Paralyse(30 SECONDS_TO_LIFE_CYCLES)
		M.EyeBlind(35 SECONDS_TO_LIFE_CYCLES)
		M.EyeBlurry(35 SECONDS_TO_LIFE_CYCLES)
		M.AdjustConfused(35 SECONDS_TO_LIFE_CYCLES)

		sleep(6 SECONDS)
		to_chat(M, "<span class='warning'>That portal did something to you...</span>")

		sleep(6.5 SECONDS)
		to_chat(M, "<span class='warning'>Your head pounds... It feels like it's going to burst out your skull!</span>")

		sleep(3 SECONDS)
		to_chat(M, "<span class='warning'>Your head pounds...</span>")

		sleep(10 SECONDS)
		to_chat(M, "<span class='specialnotice'>A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
					we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
					so it's only a matter of time before we send you back...\"</i></span>")

/**
  * Handles the target's return to station.
  *
  * Arguments:
  * * M - The target mob.
  * * T - The turf the target was extracted from.
  */
/datum/syndicate_contract/proc/handle_target_return(mob/living/M, turf/extraction_turf)
	var/list/turf/possible_turfs = list()
	for(var/turf/T in (list(extraction_turf) + contract.extraction_zone.contents))
		if(!isspaceturf(T) && !isunsimulatedturf(T) && !is_blocked_turf(T))
			possible_turfs += T

	var/turf/destination = length(possible_turfs) ? pick(possible_turfs) : pick(GLOB.latejoin)

	// Return their items
	for(var/i in victim_belongings)
		var/obj/item/I = GLOB.prisoner_belongings.remove_item(i)
		if(!I)
			continue
		I.forceMove(destination)

	victim_belongings = list()

	// Chance for souvenir or bruises
	if(prob(RETURN_SOUVENIR_CHANCE))
		to_chat(M, "<span class='notice'>Your captors left you a souvenir for your troubles!</span>")
		var/obj/item/souvenir = pick(souvenirs)
		new souvenir(destination)
	else if(prob(RETURN_BRUISE_CHANCE) && M.health >= 50)
		to_chat(M, "<span class='warning'>You were roughed up a little by your captors before being sent back!</span>")
		M.adjustBruteLoss(RETURN_BRUISE_DAMAGE)

	// Return them a bit confused.
	M.visible_message("<span class='notice'>[M] vanishes...</span>")
	M.forceMove(destination)
	M.Paralyse(3 SECONDS_TO_LIFE_CYCLES)
	M.EyeBlurry(5 SECONDS_TO_LIFE_CYCLES)
	M.AdjustConfused(5 SECONDS_TO_LIFE_CYCLES)
	M.Dizzy(35)
	do_sparks(4, FALSE, destination)

	// Newscaster story
	var/datum/data/record/R = find_record("name", contract.target?.name, GLOB.data_core.general)
	var/initials = ""
	for(var/s in splittext(R?.fields["name"] || DEFAULT_NAME, " "))
		initials = initials + "[s[1]]."

	var/datum/feed_message/FM = new
	FM.author = "Nyx Daily"
	FM.admin_locked = TRUE
	FM.body = "Suspected Syndicate activity was reported in the system. Rumours have surfaced about a [R?.fields["rank"] || DEFAULT_RANK] aboard the [GLOB.using_map.full_name] being the victim of a kidnapping.\n\n" +\
				"A reliable source said the following: There was a note with the victim's initials which were \"[initials]\" and a scribble saying \"[fluff_message]\""
	GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(FM)

	// Bonus story if the contractor has done all their contracts (appears only once per round)
	if(!nt_am_board_resigned && (owning_hub.completed_contracts >= owning_hub.num_contracts))
		nt_am_board_resigned = TRUE

		var/datum/feed_message/FM2 = new
		FM2.author = "Nyx Daily"
		FM2.admin_locked = TRUE
		FM2.body = "Nanotrasen's Asset Management board has resigned today after a series of kidnappings aboard the [GLOB.using_map.full_name]." +\
					"One former member of the board was heard saying: \"I can't do this anymore. How does a single shift on this cursed station manage to cost us over ten million Credits in ransom payments? Is there no security aboard?!\""
		GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(FM2)

	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news("Nyx Daily")

/**
  * Called when the extraction window closes.
  */
/datum/syndicate_contract/proc/deadline_reached()
	clean_up()
	owning_hub.uplink?.message_holder("The window for extraction has closed and so did the portal, agent. You will need to call for another extraction so we can open a new portal.")
	SStgui.update_uis(owning_hub.uplink)

/**
  * Cleans up the contract.
  */
/datum/syndicate_contract/proc/clean_up()
	QDEL_NULL(extraction_flare)
	QDEL_NULL(extraction_portal)
	deltimer(extraction_timer_handle)
	extraction_deadline = -1
	extraction_timer_handle = null

#undef CREDIT_REWARD_BASE
#undef CREDIT_REWARD_MULT_MIN
#undef CREDIT_REWARD_MULT_MAX
#undef DEFAULT_NAME
#undef DEFAULT_RANK
#undef EXTRACTION_PHASE_PREPARE
#undef EXTRACTION_PHASE_STEP_1
#undef COMPLETION_NOTIFY_DELAY
#undef RETURN_BRUISE_CHANCE
#undef RETURN_BRUISE_DAMAGE
#undef RETURN_SOUVENIR_CHANCE
