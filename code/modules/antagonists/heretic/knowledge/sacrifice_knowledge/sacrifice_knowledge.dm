// The knowledge and process of heretic sacrificing.

/// How long we put the target so sleep for during sacrifice.
#define SACRIFICE_SLEEP_DURATION (12 SECONDS)
/// How long sacrifices must stay in the shadow realm to survive.
#define SACRIFICE_REALM_DURATION (2.5 MINUTES)

/**
 * Allows the heretic to sacrifice living heart targets.
 */
/datum/heretic_knowledge/hunt_and_sacrifice
	name = "Heartbeat of the Mansus"
	desc = "Allows you to sacrifice targets to the Mansus by bringing them to a rune in critical (or worse) condition. \
		If you have no targets, stand on a transmutation rune and invoke it to acquire some."
	required_atoms = list(/mob/living/carbon/human = 1)
	priority = MAX_KNOWLEDGE_PRIORITY // Should be at the top
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/effects/eldritch.dmi'
	research_tree_icon_state = "eye_close"
	/// How many targets do we generate?
	var/num_targets_to_generate = 5
	/// Whether we've generated a heretic sacrifice z-level yet, from any heretic.
	var/static/heretic_level_generated = FALSE
	/// A weakref to the mind of our heretic.
	var/datum/mind/heretic_mind
	/// Lazylist of minds that we won't pick as targets.
	var/list/datum/mind/target_blacklist
	/// An assoc list of [uif] to [timers] - a list of all the timers of people in the shadow realm currently
	var/list/return_timers
	/// Evil organs we can put in people
	var/static/list/grantable_organs = list(
		/obj/item/organ/internal/appendix/corrupt,
		/obj/item/organ/internal/eyes/corrupt,
		/obj/item/organ/internal/heart/corrupt,
		/obj/item/organ/internal/liver/corrupt,
		/obj/item/organ/internal/lungs/corrupt,
	)

/datum/heretic_knowledge/hunt_and_sacrifice/Destroy(force)
	heretic_mind = null
	LAZYCLEARLIST(target_blacklist)
	return ..()

/datum/heretic_knowledge/hunt_and_sacrifice/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(generate_targets), user, our_heretic), 10 SECONDS)

/datum/heretic_knowledge/hunt_and_sacrifice/proc/generate_targets(mob/user, datum/antagonist/heretic/our_heretic)
	obtain_targets(user, silent = TRUE, heretic_datum = our_heretic)
	heretic_mind = our_heretic.owner


#ifndef UNIT_TESTS // This is a decently hefty thing to generate while unit testing, so we should skip it.
	if(!heretic_level_generated)
		heretic_level_generated = TRUE
		log_game("Loading heretic lazytemplate for heretic sacrifices...")
		INVOKE_ASYNC(src, PROC_REF(generate_heretic_z_level))
#endif

/// Generate the sacrifice z-level.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/generate_heretic_z_level()
	var/datum/map_template/template = GLOB.map_templates["The Mansus"]
	var/datum/turf_reservation/reserve = SSmapping.lazy_load_template(template)
	if(!reserve)
		log_game("The heretic sacrifice template failed to load.")
		message_admins("The heretic sacrifice lazy template failed to load. Heretic sacrifices won't be teleported to the shadow realm. \
			If you want, you can spawn an /obj/effect/landmark/heretic somewhere to stop that from happening.")
		CRASH("Failed to lazy load heretic sacrifice template!")


/datum/heretic_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// First we have to check if the heretic has a Living Heart.
	// You may wonder why we don't straight up prevent them from invoking the ritual if they don't have one -
	// Hunt and sacrifice should always be invokable for clarity's sake, even if it'll fail immediately.
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		to_chat(user, SPAN_HIEROPHANT_WARNING("The ritual failed, you have no living heart!"))
		return FALSE

	// We've got no targets set, let's try to set some.
	// If we recently failed to acquire targets, we will be unable to acquire any.
	if(!LAZYLEN(heretic_datum.sac_targets))
		atoms += user
		return TRUE

	// If we have targets, we can check to see if we can do a sacrifice
	// Let's remove any humans in our atoms list that aren't a sac target
	for(var/mob/living/carbon/human/sacrifice in atoms)
		// If the mob's not in soft crit or worse, nor are they handcuffed, remove from list
		if(sacrifice.health > HEALTH_THRESHOLD_CRIT && sacrifice.stat != DEAD && (!HAS_TRAIT(sacrifice, TRAIT_RESTRAINED)))
			atoms -= sacrifice
		// Otherwise if it's neither a target nor a cultist, remove it
		else if(!(sacrifice in heretic_datum.sac_targets) && !IS_CULTIST(sacrifice))
			atoms -= sacrifice

	// Finally, return TRUE if we have a target in the list
	if(locate(/mob/living/carbon/human) in atoms)
		return TRUE

	// or FALSE if we don't
	to_chat(user, SPAN_HIEROPHANT("The ritual failed, no valid sacrifice was found!"))
	return FALSE

/datum/heretic_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// Force it to work if the sacrifice is a cultist, even if there's no targets.
	var/mob/living/carbon/human/sac = selected_atoms[1]
	if(!LAZYLEN(heretic_datum.sac_targets) && !IS_CULTIST(sac))
		if(obtain_targets(user, heretic_datum = heretic_datum))
			return TRUE
		else
			to_chat(user, SPAN_HIEROPHANT("The ritual failed, no valid sacrifice was found!"))
			return FALSE

	sacrifice_process(user, selected_atoms, our_turf)
	return TRUE


/**
 * Obtain a list of targets for the user to hunt down and sacrifice.
 * Tries to get four targets (minds) with living human currents.
 *
 * Returns FALSE if no targets are found, TRUE if the targets list was populated.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user, silent = FALSE, datum/antagonist/heretic/heretic_datum)

	// First construct a list of minds that are valid objective targets.
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target as anything in SSticker.minds)
		if(possible_target == user.mind)
			continue
		if(!possible_target.assigned_role)
			continue
		if(is_invalid_target(possible_target))
			continue
		if(possible_target in target_blacklist)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue

		valid_targets += possible_target

	if(!length(valid_targets))
		if(!silent)
			to_chat(user, SPAN_HIEROPHANT_WARNING("No sacrifice targets could be found!"))
		return FALSE

	// Now, let's try to get five targets.
	// - Two are completely random
	// - One from your department
	// - One from security
	// - One from heads of staff ("high value")
	var/list/datum/mind/final_targets = list()

	// First target, any command.
	for(var/datum/mind/head_mind as anything in shuffle(valid_targets))
		if(head_mind.assigned_role in GLOB.command_head_positions)
			final_targets += head_mind
			valid_targets -= head_mind
			break

	// Second target, any security
	for(var/datum/mind/sec_mind as anything in shuffle(valid_targets))
		if(sec_mind.assigned_role in GLOB.active_security_positions)
			final_targets += sec_mind
			valid_targets -= sec_mind
			break

	// Third target, someone in their department.
	for(var/datum/mind/department_mind as anything in shuffle(valid_targets))
		if(!user.mind.job_datum)
			break
		if(department_mind.job_datum.job_department_flags & user.mind.job_datum.job_department_flags)
			final_targets += department_mind
			valid_targets -= department_mind
			break

	// Now grab completely random targets until we'll full
	var/target_sanity = 0
	while(length(final_targets) < num_targets_to_generate && length(valid_targets) > num_targets_to_generate && target_sanity < 25)
		final_targets += pick_n_take(valid_targets)
		target_sanity++

	if(!silent)
		to_chat(user, SPAN_DANGER("Your targets have been determined. Your Living Heart will allow you to track their position. Go and sacrifice them!"))

	for(var/datum/mind/chosen_mind as anything in final_targets)
		heretic_datum.add_sacrifice_target(chosen_mind.current)
		if(!silent)
			to_chat(user, SPAN_DANGER("[chosen_mind.current.real_name], the [chosen_mind.assigned_role]."))

	return TRUE

/**
 * Begin the process of sacrificing the target.
 *
 * Arguments
 * * user - the mob doing the sacrifice (a heretic)
 * * selected_atoms - a list of all atoms chosen. Should be (at least) one human.
 * * our_turf - the turf the sacrifice is occurring on
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/user, list/selected_atoms, turf/our_turf)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(sacrifice in heretic_datum.sac_targets) && !IS_CULTIST(sacrifice))
		CRASH("[type] sacrifice_process managed to get a non-target, non-cult human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, sacrifice.mind)
		sacrifice.get_ghost(FALSE)
	heretic_datum.remove_sacrifice_target(sacrifice)


	var/feedback = "Your patrons accept your offer"
	var/sac_job = sacrifice.mind?.assigned_role
	var/datum/antagonist/cultist/cultist_datum = IS_CULTIST(sacrifice)
	// Heads give 3 points, cultists give 1 point (and a special reward), normal sacrifices give 2 points.
	heretic_datum.total_sacrifices++
	if(sac_job in GLOB.command_head_positions)
		heretic_datum.knowledge_points += 3
		heretic_datum.high_value_sacrifices++
		feedback += " <i>graciously</i>"
	if(cultist_datum)
		heretic_datum.knowledge_points += 3
		grant_reward(user, sacrifice, our_turf)
		// easier to read
		var/rewards_given = heretic_datum.rewards_given
		// Chance for it to send a warning to cultists, higher with each reward. Stops after 5 because they probably got the hint by then.
		if(prob(min(15 * rewards_given)) && (rewards_given <= 5))
			for(var/datum/mind/mind as anything in cultist_datum.get_team())
				if(mind.current)
					SEND_SOUND(mind.current, 'sound/magic/narsie_attack.ogg')
					var/message = "<span class='narsie'>A vile heretic has </span>" + \
					"<span class='hierophant_warning'>sacrificed</span>" + \
					"<span class='narsie'> one of our own. Destroy and sacrifice the infidel before it claims more!</span>"
					to_chat(mind.current, message)
			// he(retic) gets a warn too
			to_chat(user, "<span class='narsiesmall'>How DARE you!? I will see you destroyed for this.</span>")
			var/non_flavor_warning = SPAN_CULTLARGE("You feel that your action has attracted ") + SPAN_HIEROPHANT_WARNING("attention")
			to_chat(user, non_flavor_warning)
	else
		heretic_datum.knowledge_points += 2

	ADD_TRAIT(sacrifice, TRAIT_WAS_SACRIFICED, CULT_TRAIT)
	to_chat(user, SPAN_HIEROPHANT_WARNING("[feedback]."))
	if(!begin_sacrifice(sacrifice))
		disembowel_target(sacrifice)
		return

	sacrifice.apply_status_effect(/datum/status_effect/heretic_curse, user)

/datum/heretic_knowledge/hunt_and_sacrifice/proc/grant_reward(mob/living/user, mob/living/sacrifice, turf/our_turf)

	// Visible and audible encouragement!
	to_chat(user, SPAN_HIEROPHANT_WARNING("A servant of the Sanguine Apostate!"))
	to_chat(user, SPAN_HIEROPHANT("Your patrons are rapturous!"))
	playsound(sacrifice, 'sound/magic/disintegrate.ogg', 75, TRUE)

	to_chat(sacrifice, SPAN_HIEROPHANT("No! Your feel your connection with your god has been severed!"))
	sacrifice.mind.remove_antag_datum(/datum/antagonist/cultist)

	// Increase reward counter
	var/datum/antagonist/heretic/antag = IS_HERETIC(user)
	antag.rewards_given++

	// Cool effect for the rune as well as the item
	var/obj/effect/heretic_rune/rune = locate() in range(2, user)
	if(rune)
		rune.gender_reveal(
			outline_color = COLOR_RED_LIGHT,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	addtimer(CALLBACK(src, PROC_REF(deposit_reward), user, our_turf, null, rune), 5 SECONDS)


/datum/heretic_knowledge/hunt_and_sacrifice/proc/deposit_reward(mob/user, turf/our_turf, loop = 0, obj/rune)
	if(loop > 5) // Max limit for retrying a reward
		return
	// Remove the outline, we don't need it anymore.
	rune?.remove_filter("reward_outline")
	playsound(our_turf, 'sound/magic/repulse.ogg', 75, TRUE)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	ASSERT(heretic_datum)
	// This list will be almost identical to unlocked_heretic_items, with the same keys, the difference being the values will be 1 to 5.
	var/list/rewards = heretic_datum.unlocked_heretic_items.Copy()
	// We will make it increasingly less likely to get a reward if you've already got it
	for(var/possible_reward in heretic_datum.unlocked_heretic_items)
		var/amount_already_awarded = heretic_datum.unlocked_heretic_items[possible_reward]
		rewards[possible_reward] = min(5 - (amount_already_awarded * 2), 1)

	var/atom/reward = pickweight(rewards)
	reward = new reward(our_turf)

	if(isliving(reward))
		if(summon_ritual_mob(user, our_turf, reward) == FALSE)
			qdel(reward)
			deposit_reward(user, our_turf, loop++, rune) // If no ghosts, try again until limit is hit
		return

	else if(isitem(reward))
		var/obj/item/item_reward = reward
		item_reward.gender_reveal(outline_color = null, ray_color = COLOR_RED_LIGHT)

	ASSERT(reward)

	return reward

/**
 * This proc is called from [proc/sacrifice_process] after the heretic successfully sacrifices [sac_target].)
 *
 * Sets off a chain that sends the person sacrificed to the shadow realm to dodge hands to fight for survival.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/begin_sacrifice(mob/living/carbon/human/sac_target)
	. = FALSE

	var/datum/antagonist/heretic/our_heretic = heretic_mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!our_heretic)
		CRASH("[type] - begin_sacrifice was called, and no heretic [heretic_mind ? "antag datum":"mind"] could be found!")

	if(!LAZYLEN(GLOB.heretic_sacrifice_landmarks))
		CRASH("[type] - begin_sacrifice was called, but no heretic sacrifice landmarks were found!")

	var/obj/effect/landmark/heretic/destination_landmark = GLOB.heretic_sacrifice_landmarks[our_heretic.heretic_path] || GLOB.heretic_sacrifice_landmarks[PATH_START]
	if(!destination_landmark)
		CRASH("[type] - begin_sacrifice could not find a destination landmark OR default landmark to send the sacrifice! (Heretic's path: [our_heretic.heretic_path])")

	var/turf/destination = get_turf(destination_landmark)

	sac_target.visible_message(SPAN_DANGER("[sac_target] begins to shudder violenty as dark tendrils begin to drag them into thin air!"))
	sac_target.handcuffed = new /obj/item/restraints/handcuffs/cult(sac_target)
	sac_target.update_handcuffed()
	if(sac_target.legcuffed)
		sac_target.clear_legcuffs(TRUE)

	sac_target.setBrainLoss(40)
	sac_target.do_jitter_animation()
	for(var/datum/disease/critical/heart_failure/HF in sac_target.viruses)
		HF.cure()

	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (1/3))
	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (2/3))

	// If our target is dead, try to revive them
	// and if we fail to revive them, don't proceede the chain
	if(sac_target.stat & DEAD)
		sac_target.adjustOxyLoss(-100, FALSE)
		if(!sac_target.heal_and_revive(50, SPAN_DANGER("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
			return

	if(sac_target.AdjustSleeping(SACRIFICE_SLEEP_DURATION))
		to_chat(sac_target, SPAN_HIEROPHANT_WARNING("Your mind feels torn apart as you fall into a shallow slumber..."))
	else
		to_chat(sac_target, SPAN_HIEROPHANT_WARNING("Your mind begins to tear apart as you watch dark tendrils envelop you."))

	sac_target.AdjustWeakened(SACRIFICE_SLEEP_DURATION * 1.2)
	sac_target.AdjustImmobilized(SACRIFICE_SLEEP_DURATION * 1.2)
	if(HAS_TRAIT(sac_target, TRAIT_RESTRAINED) && sac_target.health > 60) // We gotta harm the restrained ones JUST a lil. For fun!
		sac_target.adjustBruteLoss(20)
		sac_target.adjustFireLoss(20)

	addtimer(CALLBACK(src, PROC_REF(after_target_sleeps), sac_target, destination), SACRIFICE_SLEEP_DURATION * 0.5) // Teleport to the minigame

	return TRUE

/**
 * This proc is called from [proc/begin_sacrifice] after the [sac_target] falls asleep), shortly after the sacrifice occurs.
 *
 * Teleports the [sac_target] to the heretic room, asleep.
 * If it fails to teleport, they will be disemboweled and stop the chain.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 * * destination - the spot they're being teleported to.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_sleeps(mob/living/carbon/human/sac_target, turf/destination)
	if(QDELETED(sac_target))
		return

	curse_organs(sac_target)

	// The target disconnected or something, we shouldn't bother sending them along.
	if(!sac_target.client || !sac_target.mind)
		return

	// Send 'em to the destination. If the teleport fails, just disembowel them and stop the chain
	if(!destination || SEND_SIGNAL(sac_target, COMSIG_MOVABLE_TELEPORTING, destination) & COMPONENT_BLOCK_TELEPORT)
		disembowel_target(sac_target)
		return
	sac_target.forceMove(destination)
	// If our target died during the (short) wait timer,
	// and we fail to revive them (using a lower number than before),
	// just disembowel them and stop the chain
	sac_target.adjustOxyLoss(-100, FALSE)
	if(!sac_target.heal_and_revive(50, SPAN_DANGER("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		return
	else // lets give them a little help
		for(var/organ_name in list("l_leg", "r_leg", "l_foot", "r_foot"))
			var/obj/item/organ/external/E = sac_target.get_organ(organ_name)
			if(!E)
				sac_target.regrow_external_limb_if_missing(organ_name)
			else if(E.status |= ORGAN_BROKEN)
				E.status &= ~ORGAN_BROKEN
		sac_target.update_body() // Update the limb sprites

	to_chat(sac_target, SPAN_HIEROPHANT_WARNING("Unnatural forces begin to claw at your every being from beyond the veil."))

	playsound(sac_target, 'sound/ambience/antag/heretic/heretic_sacrifice.ogg', 50, FALSE) // play theme

	sac_target.apply_status_effect(/datum/status_effect/unholy_determination, SACRIFICE_REALM_DURATION)
	addtimer(CALLBACK(src, PROC_REF(after_target_wakes), sac_target), SACRIFICE_SLEEP_DURATION * 0.5) // Begin the minigame

	RegisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_escape)) // Cheese condition
	RegisterSignal(sac_target, COMSIG_MOB_DEATH, PROC_REF(on_target_death)) // Loss condition

/// Apply a sinister curse to some of the target's organs as an incentive to leave us alone
/datum/heretic_knowledge/hunt_and_sacrifice/proc/curse_organs(mob/living/carbon/human/sac_target)
	var/usable_organs = grantable_organs.Copy()
	if(isplasmaman(sac_target) || isvox(sac_target))
		usable_organs -= /obj/item/organ/internal/lungs/corrupt // Their lungs are already more cursed than anything I could give them

	var/total_implant = rand(2, 4)

	for(var/i in 1 to total_implant)
		if(!length(usable_organs))
			return
		var/organ_path = pick_n_take(usable_organs)
		var/obj/item/organ/internal/to_give = new organ_path
		var/obj/item/organ/internal/to_eject = sac_target.get_int_organ(to_give.parent_type)
		if(to_eject)
			to_eject.remove(sac_target)
			to_eject.forceMove(get_turf(sac_target))
		to_give.insert(sac_target)

	new /obj/effect/gibspawner/generic(get_turf(sac_target))
	sac_target.visible_message(SPAN_BOLDWARNING("Several organs force themselves out of [sac_target]!"))
	sac_target.set_heartattack(FALSE) //Otherwise you die if you try to do an organic heart, very funny, very bad

/**
 * This proc is called from [proc/after_target_sleeps] when the [sac_target] should be waking up.)
 *
 * Begins the survival minigame, featuring the sacrifice targets.
 * Gives them Helgrasp, throwing cursed hands towards them that they must dodge to survive.
 * Also gives them a status effect, Unholy Determination, to help them in this endeavor.
 *
 * Then applies some miscellaneous effects.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_wakes(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	// About how long should the helgrasp last? (1 metab a tick = helgrasp_time / 2 ticks (so, 1 minute = 60 seconds = 30 ticks))
	var/helgrasp_time = 1 MINUTES

	sac_target.reagents?.add_reagent("mansusgrasp", helgrasp_time / 40)
	sac_target.apply_status_effect(/datum/status_effect/necropolis_curse)

	sac_target.EyeBlurry(30 SECONDS)
	sac_target.AdjustJitter(20 SECONDS)
	sac_target.AdjustDizzy(20 SECONDS)
	sac_target.emote("scream")

	to_chat(sac_target, SPAN_HIEROPHANT_WARNING("The grasp of the Mansus reveal themselves to you!"))
	to_chat(sac_target, SPAN_HIEROPHANT_WARNING("You feel invigorated! Fight to survive!"))
	// When it runs out, let them know they're almost home free
	addtimer(CALLBACK(src, PROC_REF(after_helgrasp_ends), sac_target), helgrasp_time)
	// Win condition
	var/win_timer = addtimer(CALLBACK(src, PROC_REF(return_target), sac_target), SACRIFICE_REALM_DURATION, TIMER_STOPPABLE)
	LAZYSET(return_timers, sac_target.UID(), win_timer)

/**
 * This proc is called from [proc/after_target_wakes] after the helgrasp runs out in the [sac_target].)
 *
 * It gives them a message letting them know it's getting easier and they're almost free.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_helgrasp_ends(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target) || sac_target.stat == DEAD)
		return

	to_chat(sac_target, SPAN_HIEROPHANT_WARNING("The worst is behind you... Not much longer! Hold fast, or expire!"))

/**
 * This proc is called from [proc/begin_sacrifice] if the target survived the shadow realm), or [COMSIG_MOB_DEATH] if they don't.
 *
 * Teleports [sac_target] back to a random safe turf on the station (or observer spawn if it fails to find a safe turf).
 * Also clears their status effects, unregisters any signals associated with the shadow realm, and sends a message
 * to the heretic who did the sacrificed about whether they survived, and where they ended up.
 *
 * Arguments
 * * sac_target - the mob being sacrificed
 * * heretic - the heretic who originally did the sacrifice.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/return_target(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	var/current_timer = LAZYACCESS(return_timers, sac_target.UID())
	if(current_timer)
		deltimer(current_timer)
	LAZYREMOVE(return_timers, sac_target.UID())

	UnregisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED)
	UnregisterSignal(sac_target, COMSIG_MOB_DEATH)
	sac_target.remove_status_effect(/datum/status_effect/necropolis_curse)
	sac_target.remove_status_effect(/datum/status_effect/unholy_determination)
	sac_target.reagents?.del_reagent("mansusgrasp")
	sac_target.clear_restraints()
	if(IS_HERETIC(sac_target))
		var/datum/antagonist/heretic/victim_heretic = sac_target.mind?.has_antag_datum(/datum/antagonist/heretic)
		victim_heretic.knowledge_points -= 3

	// Wherever we end up, we sure as hell won't be able to explain
	sac_target.HereticSlur(40 SECONDS)
	sac_target.AdjustStuttering(40 SECONDS)

	// They're already back on the station for some reason, don't bother teleporting
	var/turf/below_target = get_turf(sac_target)
	// is_station_level runtimes when passed z = 0, so I'm being very explicit here about checking for nullspace until fixed
	// otherwise, we really don't want this to runtime error, as it'll get people stuck in hell forever - not ideal!
	if(below_target && below_target.z != 0 && is_station_level(below_target.z))
		return

	// Teleport them to a random safe coordinate on the station z level.
	var/turf/simulated/floor/safe_turf = get_safe_random_station_turf_equal_weight()
	if(!safe_turf)
		safe_turf = sac_target.forceMove(pick(GLOB.latejoin))
		stack_trace("[type] - return_target was unable to find a safe turf for [sac_target] to return to. Defaulting to arrivals.")
	sac_target.forceMove(safe_turf)

	if(sac_target.stat == DEAD)
		after_return_dead_target(sac_target)
	else
		after_return_live_target(sac_target)

	if(heretic_mind?.current)
		var/composed_return_message = ""
		composed_return_message += SPAN_NOTICE("Your victim, [sac_target], was returned to the station - ")
		if(sac_target.stat == DEAD)
			composed_return_message += "<span class='red'>dead. </span>"
		else
			composed_return_message += "<span class='green'>alive, but with a shattered mind. </span>"

		composed_return_message += SPAN_NOTICE("You hear a whisper... ")
		composed_return_message += SPAN_HIEROPHANT_WARNING("[get_area_name(safe_turf, TRUE)]")
		to_chat(heretic_mind.current, composed_return_message)

/**
 * If they die in the shadow realm, they lost. Send them back.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_death(mob/living/carbon/human/sac_target, gibbed)
	SIGNAL_HANDLER

	if(gibbed) // Nothing to return
		return

	return_target(sac_target)

/**
 * If they somehow cheese the shadow realm by teleporting out, they are disemboweled and killed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_escape(mob/living/carbon/human/sac_target, old_z, new_z)
	SIGNAL_HANDLER

	to_chat(sac_target, SPAN_BOLDWARNING("Your attempt to escape the Mansus is not taken kindly!"))
	// Ends up calling return_target() via death signal to clean up.
	disembowel_target(sac_target)

/**
 * This proc is called from [proc/return_target] if the [sac_target] survives the shadow realm.)
 *
 * Gives the sacrifice target some after effects upon ariving back to reality.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_live_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, SPAN_USERDANGER("The fight is over, but at great cost. You have been returned to the station in one piece."))
	if(IS_HERETIC(sac_target))
		to_chat(sac_target, SPAN_USERDANGER("You don't remember anything leading up to the experience, but you feel your connection with the Mansus weakened - Knowledge once known, forgotten..."))
	else
		to_chat(sac_target, SPAN_USERDANGER("You don't remember anything leading up to the experience - All you can think about are those horrific hands..."))

	// Oh god where are we?
	sac_target.AdjustConfused(60 SECONDS)
	sac_target.AdjustJitter(120 SECONDS)
	sac_target.EyeBlurry(100 SECONDS)
	sac_target.AdjustDizzy(1 MINUTES)
	sac_target.AdjustKnockDown(8 SECONDS)
	sac_target.adjustStaminaLoss(120)


	// Could use a little pick-me-up...
	sac_target.reagents?.add_reagent("atropine", 8)
	sac_target.reagents?.add_reagent("epinephrine", 8)

/**
 * This proc is called from [proc/return_target] if the target dies in the shadow realm.)
 *
 * After teleporting the target back to the station (dead),
 * it spawns a special red broken illusion on their spot, for style.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_dead_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, SPAN_HIEROPHANT_WARNING("You failed to resist the horrors of the Mansus! Your ruined body has been returned to the station."))
	to_chat(sac_target, SPAN_HIEROPHANT_WARNING("The experience leaves your mind torn and memories tattered. You will not remember anything leading up to the experience if revived."))

	var/obj/effect/visible_heretic_influence/illusion = new(get_turf(sac_target))
	illusion.name = "\improper weakened rift in reality"
	illusion.desc = "A rift wide enough for something... or someone... to come through."
	illusion.color = COLOR_RED

/**
 * "Fuck you" proc that gets called if the chain is interrupted at some points.
 * Disembowels the [sac_target] and brutilizes their body. Throws some gibs around for good measure.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/disembowel_target(mob/living/carbon/human/sac_target)
	if(heretic_mind)
		add_attack_logs(src, sac_target, "disemboweled via sacrifice")
	var/obj/item/organ/external/chest = sac_target.get_organ(BODY_ZONE_CHEST)
	chest.fracture()
	chest.droplimb()
	sac_target.apply_damage(250, BRUTE)
	if(sac_target.stat != DEAD)
		sac_target.death()
	sac_target.visible_message(
		SPAN_DANGER("[sac_target]'s organs are pulled out of [sac_target.p_their()] chest by shadowy hands!"),
		SPAN_USERDANGER("our organs are violently pulled out of your chest by shadowy hands!")
	)

	new /obj/effect/gibspawner/human(get_turf(sac_target))

#undef SACRIFICE_SLEEP_DURATION
#undef SACRIFICE_REALM_DURATION
