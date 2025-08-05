#define DEFAULT_NAME "Unknown"
#define DEFAULT_RANK "Unknown"
#define EXTRACTION_PHASE_PREPARE 5 SECONDS
#define EXTRACTION_PHASE_PORTAL 5 SECONDS
#define COMPLETION_NOTIFY_DELAY 5 SECONDS
#define RETURN_SOUVENIR_CHANCE 10

/**
  * # Syndicate Contract
  *
  * Describes a contract that can be completed by a Contractor.
  */
/datum/syndicate_contract
	// Settings
	/// Cooldown before making another extraction request in deciseconds.
	var/extraction_cooldown = 10 MINUTES
	/// How long an extraction portal remains before going away. Should be less than [/datum/syndicate_contract/var/extraction_cooldown].
	var/portal_duration = 5 MINUTES
	/// How long a target remains in the Syndicate jail.
	var/prison_time = 4 MINUTES
	var/list/obj/item/souvenirs = list(
		/obj/item/bedsheet/syndie,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/poster/syndicate_recruitment,
		/obj/item/food/syndicake,
		/obj/item/food/tatortot,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/toy/figure/crew/syndie,
		/obj/item/toy/nuke,
		/obj/item/toy/plushie/nukeplushie,
		/obj/item/toy/sword,
		/obj/item/toy/syndicateballoon,
	)
	/// The base credits reward upon completion. Multiplied by the two lower bounds below.
	var/credits_base = 10
	// The lower bound of the credits reward multiplier.
	var/credits_lower_mult = 25
	// The upper bound of the credits reward multiplier.
	var/credits_upper_mult = 40
	// Variables
	/// The owning contractor hub.
	var/datum/contractor_hub/owning_hub = null
	/// The [/datum/objective/contract] associated to this contract.
	var/datum/objective/contract/contract = null
	/// Current contract status.
	var/status = CONTRACT_STATUS_INVALID
	/// Formatted station time at which the contract was completed, if applicable.
	var/completed_time
	/// Whether the contract was completed with the victim being dead on extraction.
	var/dead_extraction = FALSE
	/// Visual reason as to why the contract failed, if applicable.
	var/fail_reason
	/// The selected difficulty.
	var/chosen_difficulty = -1
	/// The flare indicating the extraction point.
	var/obj/effect/contractor_flare/extraction_flare = null
	/// The extraction portal.
	var/obj/effect/portal/advanced/contractor/extraction_portal = null
	/// The world.time at which the current extraction fulton will vanish and another extraction can be requested.
	var/extraction_deadline = -1
	/// Name of the target to display on the UI.
	var/target_name
	/// Fluff message explaining why the kidnapee is the target.
	var/fluff_message
	/// The target's photo to display on the UI.
	var/image/target_photo = null
	/// Amount of telecrystals the contract will receive upon completion, depending on the chosen difficulty.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => number
	var/list/reward_tc = null
	/// Amount of credits the contractor will receive upon completion.
	var/reward_credits = 0
	/// The kidnapee's belongings. Set upon extraction by the contractor.
	var/list/obj/item/victim_belongings = null
	/// Temporary objects that are available to the kidnapee during their time in jail. These are deleted when the victim is returned.
	var/list/obj/temp_objs = null
	/// Deadline reached timer handle. Deletes the portal and tells the agent to call extraction again.
	var/extraction_timer_handle = null
	/// Prisoner jail timer handle. On completion, returns the prisoner back to station.
	var/prisoner_timer_handle = null
	/// Whether the additional fluff story from any contractor completing all of their contracts was made already or not.
	var/static/nt_am_board_resigned = FALSE

/datum/syndicate_contract/New(datum/contractor_hub/hub, datum/mind/owner, list/datum/mind/target_blacklist, target_override)
	// Initialize
	owning_hub = hub
	contract = new /datum/objective/contract(src)
	contract.owner = owner
	contract.target_blacklist = target_blacklist
	generate(target_override)

/**
  * Fills the contract with valid data to be used.
  */
/datum/syndicate_contract/proc/generate(target_override)
	. = FALSE
	// Select the target
	var/datum/mind/T
	if(target_override)
		contract.target = target_override
		T = target_override
	else
		contract.find_target()
		T = contract.target
	if(!T)
		return

	// In case the contract is invalidated
	contract.extraction_zone = null
	contract.target_blacklist |= T
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		contract.pick_candidate_zone(difficulty)

	// Fill data
	var/datum/data/record/R = find_record("name", T.name, GLOB.data_core.general)
	target_name = "[R?.fields["name"] || T.current?.real_name || DEFAULT_NAME], the [R?.fields["rank"] || T.assigned_role || DEFAULT_RANK]"
	reward_credits = credits_base * rand(credits_lower_mult, credits_upper_mult)

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
/datum/syndicate_contract/proc/initiate(mob/living/M, difficulty = EXTRACTION_DIFFICULTY_EASY)
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
	owning_hub.contractor_uplink?.message_holder("Request for this contract confirmed. Good luck, agent.", 'sound/machines/terminal_prompt.ogg')

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
	if(target_dead)
		final_tc_reward = CEILING(final_tc_reward * owning_hub.dead_penalty, 1)
	// Notify the Hub
	owning_hub.on_completion(final_tc_reward, reward_credits)
	// Finalize
	status = CONTRACT_STATUS_COMPLETED
	completed_time = station_time_timestamp()
	dead_extraction = target_dead
	addtimer(CALLBACK(src, PROC_REF(notify_completion), final_tc_reward, reward_credits, target_dead), COMPLETION_NOTIFY_DELAY)

/**
  * Marks the contract as invalid and effectively cancels it for later use.
  */
/datum/syndicate_contract/proc/invalidate()
	if(!owning_hub)
		return
	if(status in list(CONTRACT_STATUS_COMPLETED, CONTRACT_STATUS_FAILED))
		return

	clean_up()

	var/pre_text
	if(src == owning_hub.current_contract)
		owning_hub.current_contract = null
		pre_text = "Agent, it appears the target you were tasked to kidnap can no longer be reached."
	else
		pre_text = "Agent, a still inactive contract can no longer be done as the target has gone off our sensors."

	var/outcome_text
	if(generate())
		status = CONTRACT_STATUS_INACTIVE
		outcome_text = "Luckily, there is another target on station we can interrogate. A new contract can be found in your uplink."
	else
		// Too bad.
		status = CONTRACT_STATUS_INVALID
		outcome_text = "Unfortunately, we could not find another target to interrogate and thus we cannot give you another contract."

	if(owning_hub.contractor_uplink)
		owning_hub.contractor_uplink.message_holder("[pre_text] [outcome_text]", 'sound/machines/terminal_prompt_deny.ogg')
		SStgui.update_uis(owning_hub)

/**
  * Marks the contract as failed and stops it.
  *
  * Arguments:
  * * difficulty - The visual reason as to why the contract failed.
  */
/datum/syndicate_contract/proc/fail(reason)
	if(status != CONTRACT_STATUS_ACTIVE)
		return

	// Update info
	owning_hub.current_contract = null
	status = CONTRACT_STATUS_FAILED
	fail_reason = reason
	// Notify
	clean_up()
	owning_hub.contractor_uplink?.message_holder("You failed to kidnap the target, agent. Do not disappoint us again.", 'sound/machines/terminal_prompt_deny.ogg')

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
					"<span class='notice'>You start entering an extraction signal to your handlers on [U]...</span>")
	if(do_after(M, EXTRACTION_PHASE_PREPARE, target = M, hidden = TRUE))
		if(!U.Adjacent(M) || extraction_deadline > world.time)
			return
		var/obj/effect/contractor_flare/F = new(get_turf(M))
		extraction_flare = F
		extraction_deadline = world.time + extraction_cooldown
		M.visible_message("<span class='notice'>[M] enters a mysterious code on [U] and pulls a black and gold flare from [M.p_their()] belongings before lighting it.</span>",\
						"<span class='notice'>You finish entering the signal on [U] and light an extraction flare, initiating the extraction process.</span>")
		addtimer(CALLBACK(src, PROC_REF(open_extraction_portal), U, M, F), EXTRACTION_PHASE_PORTAL)
		extraction_timer_handle = addtimer(CALLBACK(src, PROC_REF(deadline_reached)), portal_duration, TIMER_STOPPABLE)

/**
  * Opens the extraction portal.
  *
  * Arguments:
  * * U - The uplink.
  * * M - The contractor.
  * * F - The flare.
  */
/datum/syndicate_contract/proc/open_extraction_portal(obj/item/contractor_uplink/U, mob/living/carbon/human/M, obj/effect/contractor_flare/F)
	if(!U || !M || status != CONTRACT_STATUS_ACTIVE)
		invalidate()
		return
	else if(!F)
		U.message_holder("Extraction flare could not be located, agent. Ensure the extraction zone is clear before signaling us.", 'sound/machines/terminal_prompt_deny.ogg')
		return
	else if(!ismob(contract.target.current))
		invalidate()
		return
	U.message_holder("Extraction signal received, agent. [SSmapping.map_datum.fluff_name]'s bluespace transport jamming systems have been sabotaged. "\
				+ "We have opened a temporary portal at your flare location - proceed to the target's extraction by inserting them into the portal.", 'sound/effects/confirmdropoff.ogg')
	// Open a portal
	var/obj/effect/portal/advanced/contractor/P = new(get_turf(F), pick(GLOB.syndieprisonwarp), F, 0, M)
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
/datum/syndicate_contract/proc/target_received(mob/living/M, obj/effect/portal/advanced/contractor/P)
	INVOKE_ASYNC(src, PROC_REF(clean_up))
	add_attack_logs(owning_hub.owner.current, M, "extracted to Syndicate Jail")
	complete(M.stat == DEAD)
	handle_target_experience(M, P)

/**
  * Notifies the uplink's holder that a contract has been completed.
  *
  * Arguments:
  * * tc - How many telecrystals they have received.
  * * creds - How many credits they have received.
  * * target_dead - Whether the target was extracted dead.
  */
/datum/syndicate_contract/proc/notify_completion(tc, creds, target_dead)
	var/penalty_text = ""
	if(target_dead)
		penalty_text = " (penalty applied as the target was extracted dead)"
	owning_hub.contractor_uplink?.message_holder("Well done, agent. The package has been received and will be processed shortly before being returned. "\
									+ "As agreed, you have been credited with [tc] telecrystals[penalty_text] and [creds] credits.", 'sound/machines/terminal_prompt_confirm.ogg')

/**
  * Handles the target's experience from extraction.
  *
  * Arguments:
  * * M - The target mob.
  * * P - The extraction portal.
  */
/datum/syndicate_contract/proc/handle_target_experience(mob/living/M, obj/effect/portal/advanced/contractor/P)
	var/turf/T = get_turf(P)
	var/mob/living/carbon/human/H = M

	// Prepare their return
	prisoner_timer_handle = addtimer(CALLBACK(src, PROC_REF(handle_target_return), M, T), prison_time, TIMER_STOPPABLE)

	LAZYSET(GLOB.prisoner_belongings.prisoners, M, src)

	// Shove all of the victim's items in the secure locker.
	victim_belongings = list()
	var/list/obj/item/stuff_to_transfer = list()

	// Cybernetic implants get removed first (to deal with NODROP stuff)
	for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
		// Greys get to keep their implant
		if(isgrey(H) && istype(I, /obj/item/organ/internal/cyberimp/brain/speech_translator))
			continue
		// IPCs keep this implant, free of charge!
		if(ismachineperson(H) && istype(I, /obj/item/organ/internal/cyberimp/arm/power_cord))
			continue
		// Try removing it
		I = I.remove(H)
		if(I)
			stuff_to_transfer += I

	// Skrell headpocket. They already have a check in place to limit what's placed in them.
	var/obj/item/organ/internal/headpocket/C = H.get_int_organ(/obj/item/organ/internal/headpocket)
	if(C?.held_item)
		GLOB.prisoner_belongings.give_item(C.held_item)
		victim_belongings += C.held_item
		C.held_item = null

	if(M.back) //Lets not bork modsuits in funny ways.
		var/obj/modsuit_safety = M.back
		M.drop_item_to_ground(modsuit_safety)
		stuff_to_transfer += modsuit_safety
	// Regular items get removed in second
	for(var/obj/item/I in M)
		// Any items we don't want to take from them?
		if(istype(H))
			// Keep their uniform and shoes
			if(I == H.w_uniform || I == H.shoes)
				continue
			// Plasmamen are no use if they're crispy
			if(isplasmaman(H) && I == H.head)
				continue

		// Any kind of implant gets potentially removed (mindshield, freedoms, etc)
		if(istype(I, /obj/item/bio_chip))
			if(istype(I, /obj/item/bio_chip/storage)) // Storage items are removed and placed in the confiscation locker before the implant is taken.
				var/obj/item/bio_chip/storage/storage_chip = I
				for(var/it in storage_chip.storage)
					storage_chip.storage.remove_from_storage(it)
					stuff_to_transfer += it
			qdel(I)
			continue

		if(M.drop_item_to_ground(I))
			stuff_to_transfer += I

	// Remove accessories from the suit if present
	if(length(H.w_uniform?.accessories))
		for(var/obj/item/clothing/accessory/A in H.w_uniform.accessories)
			H.w_uniform.detach_accessory(A, null)
			H.drop_item_to_ground(A)
			stuff_to_transfer += A

	// Transfer it all (or drop it if not possible)
	for(var/i in stuff_to_transfer)
		var/obj/item/I = i
		if(GLOB.prisoner_belongings.give_item(I))
			victim_belongings += I
		else if(!((ABSTRACT|NODROP) in I.flags)) // Anything that can't be put on hold, just drop it on the ground
			I.forceMove(T)

	// Give some species the necessary to survive. Courtesy of the Syndicate.
	if(istype(H))
		var/obj/item/tank/internals/emergency_oxygen/tank
		var/obj/item/clothing/mask/breath/mask
		if(isvox(H))
			tank = new /obj/item/tank/internals/emergency_oxygen/nitrogen(H)
			mask = new /obj/item/clothing/mask/breath/vox(H)
		else if(isplasmaman(H))
			tank = new /obj/item/tank/internals/emergency_oxygen/plasma(H)
			mask = new /obj/item/clothing/mask/breath(H)

		if(tank)
			H.equip_to_appropriate_slot(tank)
			H.equip_to_appropriate_slot(mask)
			tank.toggle_internals(H, TRUE)

	M.reagents.add_reagent("mutadone", 1) // 1u of mutadone for the Hulk:tm: experience
	M.update_icons()

	// Supply them with some chow. How generous is the Syndicate?
	var/obj/item/food/sliced/bread/food = new(get_turf(M))
	food.name = "stale bread"
	food.desc = "Looks like your captors care for their prisoners as much as their bread."
	food.trash = null
	if(prob(10))
		// Mold adds a bit of spice to it
		food.name = "moldy bread"
		food.reagents.add_reagent("fungus", 1)

	var/obj/item/reagent_containers/drinks/drinkingglass/drink = new(get_turf(M))
	drink.reagents.add_reagent("tea", 25) // British coders beware, tea in glasses

	var/obj/item/coin/antagtoken/passingtime = new(get_turf(M))

	temp_objs = list(food, drink, passingtime)

	// Narrate their kidnapping and torturing experience.
	if(M.stat != DEAD)
		// Heal them up - gets them out of crit/soft crit.
		M.reagents.add_reagent("omnizine", 10)

		to_chat(M, "<span class='warning'>You feel strange...</span>")
		M.Paralyse(30 SECONDS)
		M.EyeBlind(35 SECONDS)
		M.EyeBlurry(35 SECONDS)
		M.AdjustConfused(35 SECONDS)

		for(var/mob/living/simple_animal/hostile/guardian/G in GLOB.alive_mob_list)
			if(G.summoner == M)
				M.remove_guardian_actions()
				to_chat(G, "<span class='danger'>You feel your body ripped to shreds as you're forcibly removed from your summoner!</span>")
				to_chat(M, "<span class='warning'>You feel some part of you missing, you're not who you used to be...</span>")
				G.ghostize()
				qdel(G)

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

		to_chat(M, "<span class='danger'><font size=3>You have been kidnapped and interrogated for valuable information! You will be sent back to the station in a few minutes...</font></span>")

/**
  * Default damage if no injury is possible.
  *
  * Arguments:
  * * M - The target mob.
  */
/datum/syndicate_contract/proc/default_damage(mob/living/M)
	M.adjustBruteLoss(40)
	M.adjustBrainLoss(25)
/**
  * Handles the target's injury/interrogation at the Syndicate Jail.
  *
  * Arguments:
  * * M - The target mob.
  */
/datum/syndicate_contract/proc/injure_target(mob/living/M)
	var/obj/item/organ/external/injury_target
	if(prob(20)) //See if they're !!!lucky!!! enough to just chop a hand or foot off first, or even !!LUCKIER!! that it chose an already amputated limb
		injury_target = M.get_organ(pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
		if(!injury_target)
			return
		default_damage(M)
		injury_target.droplimb()
		to_chat(M, "<span class='warning'>You were interrogated by your captors before being sent back! Oh god, something's missing!</span>")
		return
		//Species specific punishments first
	if(ismachineperson(M))
		M.emp_act(EMP_HEAVY)
		M.adjustBrainLoss(30)
		to_chat(M, "<span class='warning'>You were interrogated by your captors before being sent back! You feel like some of your components are loose!</span>")
		return
	default_damage(M) //Now that we won't accidentally kill an IPC we can make everyone take damage
	if(isslimeperson(M))
		injury_target = M.get_organ(pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
		if(!injury_target)
			return
		injury_target.cause_internal_bleeding()
		injury_target = M.get_organ(BODY_ZONE_CHEST)
		injury_target.cause_internal_bleeding()
		to_chat(M, "<span class='warning'>You were interrogated by your captors before being sent back! You feel like your inner membrane has been punctured!</span>")
		return
	if(prob(25)) //You either get broken ribs, or a broken limb and IB if you made it this far
		injury_target = M.get_organ(BODY_ZONE_CHEST)
		injury_target.fracture()
	else
		injury_target = M.get_organ(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_R_LEG))
		if(!injury_target)
			return
		injury_target.fracture()
		injury_target.cause_internal_bleeding()

/**
  * Handles the target's return to station.
  *
  * Arguments:
  * * M - The target mob.
  */
/datum/syndicate_contract/proc/handle_target_return(mob/living/M)
	var/list/turf/possible_turfs = list()
	for(var/turf/T in contract.extraction_zone.contents)
		if(!isspaceturf(T) && !T.is_blocked_turf())
			possible_turfs += T

	var/turf/destination = length(possible_turfs) ? pick(possible_turfs) : pick(GLOB.latejoin)

	// Make a closet to return the target and their items neatly
	var/obj/structure/closet/closet = new
	closet.forceMove(destination)

	// Return their items
	for(var/i in victim_belongings)
		var/obj/item/I = GLOB.prisoner_belongings.remove_item(i)
		if(!I)
			continue
		I.forceMove(closet)

	victim_belongings = list()

	// Clean up
	var/obj/item/bio_chip/uplink/uplink_implant = locate() in M
	uplink_implant?.hidden_uplink?.is_jammed = FALSE

	QDEL_LIST_CONTENTS(temp_objs)

	// Injuries due to questioning and souvenirs
	injure_target(M)
	if(prob(RETURN_SOUVENIR_CHANCE))
		to_chat(M, "<span class='notice'>Your captors left you a souvenir for your troubles!</span>")
		var/obj/item/souvenir = pick(souvenirs)
		new souvenir(closet)

	// Return them a bit confused.
	M.visible_message("<span class='notice'>[M] vanishes...</span>")
	M.forceMove(closet)
	M.Paralyse(3 SECONDS)
	M.EyeBlurry(5 SECONDS)
	M.AdjustConfused(5 SECONDS)
	M.Dizzy(70 SECONDS)
	do_sparks(4, FALSE, destination)

	// Newscaster story
	var/datum/data/record/R = find_record("name", contract.target.name, GLOB.data_core.general)
	var/initials = ""
	for(var/s in splittext(R?.fields["name"] || M.real_name || DEFAULT_NAME, " "))
		initials = initials + "[s[1]]."

	var/datum/feed_message/FM = new
	FM.author = "Nyx Daily"
	FM.admin_locked = TRUE
	FM.body = "Suspected Syndicate activity was reported in the system. Rumours have surfaced about a [R?.fields["rank"] || M?.mind.assigned_role || DEFAULT_RANK] aboard the [SSmapping.map_datum.fluff_name] being the victim of a kidnapping.\n\n" +\
				"A reliable source said the following: There was a note with the victim's initials which were \"[initials]\" and a scribble saying \"[fluff_message]\""
	GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(FM)

	// Bonus story if the contractor has done all their contracts (appears only once per round)
	if(!nt_am_board_resigned && (owning_hub.completed_contracts >= owning_hub.num_contracts))
		nt_am_board_resigned = TRUE

		var/datum/feed_message/FM2 = new
		FM2.author = "Nyx Daily"
		FM2.admin_locked = TRUE
		FM2.body = "Nanotrasen's Asset Management board has resigned today after a series of kidnappings aboard the [SSmapping.map_datum.fluff_name]." +\
					"One former member of the board was heard saying: \"I can't do this anymore. How does a single shift on this cursed station manage to cost us over ten million Credits in ransom payments? Is there no security aboard?!\""
		GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(FM2)

	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news("Nyx Daily")

	prisoner_timer_handle = null
	GLOB.prisoner_belongings.prisoners[M] = null

/**
  * Called when the extraction window closes.
  */
/datum/syndicate_contract/proc/deadline_reached()
	clean_up()
	owning_hub.contractor_uplink?.message_holder("The window for extraction has closed and so did the portal, agent. You will need to call for another extraction so we can open a new portal.")
	SStgui.update_uis(owning_hub)

/**
  * Cleans up the contract.
  */
/datum/syndicate_contract/proc/clean_up()
	QDEL_NULL(extraction_flare)
	QDEL_NULL(extraction_portal)
	deltimer(extraction_timer_handle)
	extraction_deadline = -1
	extraction_timer_handle = null

#undef DEFAULT_NAME
#undef DEFAULT_RANK
#undef EXTRACTION_PHASE_PREPARE
#undef EXTRACTION_PHASE_PORTAL
#undef COMPLETION_NOTIFY_DELAY
#undef RETURN_SOUVENIR_CHANCE
