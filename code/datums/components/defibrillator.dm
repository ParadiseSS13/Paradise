/**
 * A component for an item that attempts to defibrillate a mob when activated.
 */
/datum/component/defib
	/// If this is being used by a borg or not, with necessary safeties applied if so.
	var/robotic
	/// If it should penetrate space suits
	var/combat
	/// If combat is true, this determines whether or not it should always cause a heart attack.
	var/heart_attack_chance
	/// Whether the safeties are enabled or not
	var/safety
	/// If the defib is actively performing a defib cycle
	var/busy = FALSE
	/// Cooldown length for this defib in deciseconds
	var/cooldown
	/// Whether or not we're currently on cooldown
	var/on_cooldown = FALSE
	/// How fast the defib should work.
	var/speed_multiplier
	/// If true, EMPs will have no effect.
	var/emp_proof
	/// If true, this cannot be emagged.
	var/emag_proof
	/// uid to an item that should be making noise and handling things that our direct parent shouldn't be concerned with.
	var/actual_unit_uid

/**
 * Create a new defibrillation component.
 *
 * Arguments:
 * * robotic - whether this should be treated like a borg module.
 * * cooldown - Minimum time possible between shocks.
 * * speed_multiplier - Speed multiplier for defib do-afters.
 * * combat - If true, the defib can zap through hardsuits.
 * * heart_attack_chance - If combat and safeties are off, the % chance for this to cause a heart attack on harm intent.
 * * safe_by_default - If true, safety will be enabled by default.
 * * emp_proof - If true, safety won't be switched by emp. Note that the device itself can still have behavior from it, it's just that the component will not.
 * * emag_proof - If true, safety won't be switched by emag. Note that the device itself can still have behavior from it, it's just that the component will not.
 * * actual_unit - Unit which the component's parent is based from, such as a large defib unit or a borg. The actual_unit will make the sounds and be the "origin" of visible messages, among other things.
 */
/datum/component/defib/Initialize(robotic, cooldown = 5 SECONDS, speed_multiplier = 1, combat = FALSE, heart_attack_chance = 100, safe_by_default = TRUE, emp_proof = FALSE, emag_proof = FALSE, obj/item/actual_unit = null)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.robotic = robotic
	src.speed_multiplier = speed_multiplier
	src.cooldown = cooldown
	src.combat = combat
	src.heart_attack_chance = heart_attack_chance
	safety = safe_by_default
	src.emp_proof = emp_proof
	src.emag_proof = emag_proof

	if(actual_unit)
		actual_unit_uid = actual_unit.UID()

	var/effect_target = isnull(actual_unit) ? parent : actual_unit

	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(trigger_defib))
	RegisterSignal(effect_target, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))
	RegisterSignal(effect_target, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/**
 * Get the "parent" that effects (emags, EMPs) should be applied onto.
 */
/datum/component/defib/proc/get_effect_target()
	var/actual_unit = locateUID(actual_unit_uid)
	if(!actual_unit)
		return parent
	return actual_unit

/datum/component/defib/proc/on_emp(obj/item/unit)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMP_ACT
	if(emp_proof)
		return

	if(safety)
		safety = FALSE
		unit.visible_message("<span class='notice'>[unit] beeps: Safety protocols disabled!</span>")
		playsound(get_turf(unit), 'sound/machines/defib_saftyoff.ogg', 50, 0)
	else
		safety = TRUE
		unit.visible_message("<span class='notice'>[unit] beeps: Safety protocols enabled!</span>")
		playsound(get_turf(unit), 'sound/machines/defib_saftyon.ogg', 50, 0)

/datum/component/defib/proc/on_emag(obj/item/unit, mob/user)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMAG_ACT
	if(emag_proof)
		return
	safety = !safety
	if(user && !robotic)
		to_chat(user, "<span class='warning'>You silently [safety ? "disable" : "enable"] [unit]'s safety protocols with the card.")

/datum/component/defib/proc/set_cooldown()
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_cooldown)), cooldown)

/datum/component/defib/proc/end_cooldown()
	on_cooldown = FALSE
	SEND_SIGNAL(parent, COMSIG_DEFIB_READY)

/**
 * Start the defibrillation process when triggered by a signal.
 */
/datum/component/defib/proc/trigger_defib(obj/item/paddles, mob/living/carbon/human/target, mob/living/user)
	SIGNAL_HANDLER  // COMSIG_ITEM_ATTACK
	// This includes some do-afters, so we have to pass it off asynchronously
	INVOKE_ASYNC(src, PROC_REF(defibrillate), user, target)
	return TRUE

/**
 * Perform a defibrillation.
 */
/datum/component/defib/proc/defibrillate(mob/living/user, mob/living/carbon/human/target)
	var/tobehealed
	var/threshold = -HEALTH_THRESHOLD_DEAD
	var/parent_unit = locateUID(actual_unit_uid)
	var/should_cause_harm = user.a_intent == INTENT_HARM && !safety

	// find what the defib should be referring to itself as
	var/atom/defib_ref
	if(parent_unit)
		defib_ref = parent_unit
	if(!defib_ref && robotic)
		defib_ref = user
	if(!defib_ref)
		defib_ref = parent  // contingency

	// before we do all the hard work, make sure we aren't already defibbing someone
	if(busy)
		return

	// check what the unit itself has to say about how the defib went
	var/application_result = SEND_SIGNAL(parent, COMSIG_DEFIB_PADDLES_APPLIED, user, target, should_cause_harm)

	if(!should_cause_harm && (application_result & COMPONENT_DEFIB_BECOME_THE_DANGER))
		should_cause_harm = TRUE
	if(should_cause_harm && (application_result & COMPONENT_DEFIB_BECOME_SAFE))
		should_cause_harm = FALSE

	if(application_result & COMPONENT_BLOCK_DEFIB_DEAD)
		user.visible_message("<span class='notice'>[defib_ref] beeps: Unit is unpowered.</span>")
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
		return

	if(on_cooldown)
		to_chat(user, "<span class='notice'>[defib_ref] is recharging.</span>")
		return

	if(application_result & COMPONENT_BLOCK_DEFIB_MISC)
		return  // the unit should handle this

	if(!istype(target))
		if(robotic)
			to_chat(user, "<span class='notice'>This unit is only designed to work on humanoid lifeforms.</span>")
		else
			to_chat(user, "<span class='notice'>The instructions on [defib_ref] don't mention how to defibrillate that...</span>")
		return

	if(should_cause_harm)
		fibrillate(user, target)
		return

	user.visible_message(
		"<span class='warning'>[user] begins to place [parent] on [target]'s chest.</span>",
		"<span class='warning'>You begin to place [parent] on [target.name]'s chest.</span>"
	)

	busy = TRUE
	var/mob/dead/observer/ghost = target.get_ghost(TRUE)
	if(ghost?.can_reenter_corpse)
		to_chat(ghost, "<span class='ghostalert'>Your heart is being defibrillated. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
		window_flash(ghost.client)
		notify_ghosts()
		ghost << sound('sound/effects/genetics.ogg')

	if(!do_after(user, 3 SECONDS * speed_multiplier, target = target)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
		busy = FALSE
		SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
		return

	user.visible_message("<span class='notice'>[user] places [parent] on [target]'s chest.</span>", "<span class='warning'>You place [parent] on [target]'s chest.</span>")
	playsound(get_turf(defib_ref), 'sound/machines/defib_charge.ogg', 50, 0)

	if(ghost && !ghost.client && !QDELETED(ghost))
		log_debug("Ghost of name [ghost.name] is bound to [target.real_name], but lacks a client. Deleting ghost.")
		QDEL_NULL(ghost)

	var/tplus = world.time - target.timeofdeath
	var/tlimit = DEFIB_TIME_LIMIT
	var/tloss = DEFIB_TIME_LOSS
	var/total_burn	= 0
	var/total_brute	= 0

	var/signal_result = SEND_SIGNAL(target, COMSIG_LIVING_PRE_DEFIB, user, parent, ghost)

	if(!do_after(user, 2 SECONDS * speed_multiplier, target = target)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
		busy = FALSE
		SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
		return

	signal_result |= SEND_SIGNAL(target, COMSIG_LIVING_DEFIBBED, user, parent, ghost)
	if(istype(target.wear_suit, /obj/item/clothing/suit/space) && !combat)
		user.visible_message("<span class='notice'>[defib_ref] buzzes: Patient's chest is obscured. Operation aborted.</span>")
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
		busy = FALSE
		SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
		return

	if(signal_result & COMPONENT_DEFIB_OVERRIDE)
		// let our signal handle it
		busy = FALSE
		SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
		return

	if(target.undergoing_cardiac_arrest())
		if(!target.get_int_organ(/obj/item/organ/internal/heart) && !target.get_int_organ(/obj/item/organ/internal/brain/slime)) //prevents defibing someone still alive suffering from a heart attack attack if they lack a heart
			user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Failed to pick up any heart electrical activity.</span>")
			playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
			SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
			busy = FALSE
			return

		var/obj/item/organ/internal/heart/heart = target.get_int_organ(/obj/item/organ/internal/heart)
		if(heart.status & ORGAN_DEAD)
			user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Heart necrosis detected.</span>")
			playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
			SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
			busy = FALSE
			return

		target.set_heartattack(FALSE)
		SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
		SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, TRUE)
		set_cooldown()
		user.visible_message("<span class='boldnotice'>[defib_ref] pings: Cardiac arrhythmia corrected.</span>")
		target.visible_message("<span class='warning'>[target]'s body convulses a bit.</span>", "<span class='userdanger'>You feel a jolt, and your heartbeat seems to steady.</span>")
		playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, 1, -1)
		playsound(get_turf(defib_ref), "bodyfall", 50, 1)
		playsound(get_turf(defib_ref), 'sound/machines/defib_success.ogg', 50, 0)
		busy = FALSE
		return

	if(target.stat != DEAD && !HAS_TRAIT(target, TRAIT_FAKEDEATH))
		user.visible_message("<span class='notice'>[defib_ref] buzzes: Patient is not in a valid state. Operation aborted.</span>")
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
		SEND_SIGNAL(parent, COMSIG_DEFIB_ABORTED, user, target, should_cause_harm)
		busy = FALSE
		return

	var/health = target.health
	target.visible_message("<span class='warning'>[target]'s body convulses a bit.</span>")
	playsound(get_turf(defib_ref), "bodyfall", 50, 1)
	playsound(get_turf(defib_ref), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	for(var/obj/item/organ/external/O in target.bodyparts)
		total_brute	+= O.brute_dam
		total_burn	+= O.burn_dam
	ghost = target.get_ghost(TRUE) // We have to double check whether the dead guy has entered their body during the above

	var/defib_success = TRUE

	// run through some quick failure states after shocking.

	var/obj/item/organ/internal/brain/brain_org = target.get_organ_slot("brain")

	if(tplus > tlimit || (!target.get_int_organ(/obj/item/organ/internal/heart || !target.get_int_organ(/obj/item/organ/internal/brain/slime))))
		user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation.</span>")
		defib_success = FALSE
	else if(total_burn >= 180 || total_brute >= 180)
		user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Severe tissue damage detected.</span>")
		defib_success = FALSE
	else if(HAS_TRAIT(target, TRAIT_HUSK))
		user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Subject is husked.</span>")
		defib_success = FALSE
	else if (target.blood_volume < BLOOD_VOLUME_SURVIVE)
		user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Patient blood volume critically low.</span>")
		defib_success = FALSE
	else if(!istype(brain_org))  // so things like headless clings don't get outed
		user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - No brain detected within patient.</span>")
		defib_success = FALSE
	else if(ghost)
		if(!ghost.can_reenter_corpse) // DNR or AntagHUD
			user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - No electrical brain activity detected.</span>")
		else
			user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed - Patient's brain is unresponsive. Further attempts may succeed.</span>")
		defib_success = FALSE
	else if((signal_result & COMPONENT_BLOCK_DEFIB) || HAS_TRAIT(target, TRAIT_FAKEDEATH) || HAS_TRAIT(target, TRAIT_BADDNA))  // these are a bit more arbitrary
		user.visible_message("<span class='boldnotice'>[defib_ref] buzzes: Resuscitation failed.</span>")
		defib_success = FALSE

	if(!defib_success)
		playsound(get_turf(defib_ref), 'sound/machines/defib_failed.ogg', 50, 0)
	else
		tobehealed = min(health + threshold, 0) // It's HILARIOUS without this min statqement, let me tell you
		tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
		target.adjustOxyLoss(tobehealed)
		target.adjustToxLoss(tobehealed)
		target.adjustFireLoss(tobehealed)
		target.adjustBruteLoss(tobehealed)
		if(target.get_int_organ(/obj/item/organ/internal/brain) && target.getBrainLoss() >= 100)
			// If you want to treat this with mannitol, it'll have to metabolize while the patient is alive, so it's alright to bring them back up for a minute
			playsound(get_turf(defib_ref), 'sound/machines/defib_saftyoff.ogg', 50, 0)
			user.visible_message("<span class='boldnotice'>[defib_ref] chimes: Minimal brain activity detected, brain treatment recommended for full resuscitation.</span>")
		else
			playsound(get_turf(defib_ref), 'sound/machines/defib_success.ogg', 50, 0)
		user.visible_message("<span class='boldnotice'>[defib_ref] pings: Resuscitation successful.</span>")
		target.update_revive()
		target.KnockOut()
		target.Paralyse(10 SECONDS)
		target.emote("gasp")
		if(tplus > tloss)
			target.setBrainLoss(max(0, min(99, ((tlimit - tplus) / tlimit * 100))))

		SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
		if(ishuman(target.pulledby)) // for some reason, pulledby isnt a list despite it being possible to be pulled by multiple people
			excess_shock(user, target, target.pulledby, defib_ref)
		for(var/obj/item/grab/G in target.grabbed_by)
			if(ishuman(G.assailant))
				excess_shock(user, target, G.assailant, defib_ref)

		target.med_hud_set_health()
		target.med_hud_set_status()
		SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, TRUE)
		add_attack_logs(user, target, "Revived with [defib_ref]")
		SSblackbox.record_feedback("tally", "players_revived", 1, "defibrillator")
	SEND_SIGNAL(parent, COMSIG_DEFIB_SHOCK_APPLIED, user, target, should_cause_harm, defib_success)
	set_cooldown()
	busy = FALSE

/**
 * Inflict stamina loss (and possibly inflict cardiac arrest) on someone.
 *
 * Arguments:
 * * user - wielder of the defib
 * * target - person getting shocked
 */
/datum/component/defib/proc/fibrillate(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return
	busy = TRUE
	target.visible_message("<span class='danger'>[user] has touched [target] with [parent]!</span>", \
			"<span class='userdanger'>[user] touches you with [parent], and you feel a strong jolt!</span>")
	target.adjustStaminaLoss(60)
	target.KnockDown(10 SECONDS)
	playsound(get_turf(parent), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	target.emote("gasp")
	if(combat && prob(heart_attack_chance)) // If the victim is not having a heart attack, and a 10% chance passes, or the defib has heart attack variable to TRUE while being a combat defib, or if another 10% chance passes with combat being TRUE
		target.set_heartattack(TRUE)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK, 100)
	add_attack_logs(user, target, "Stunned with [parent]")
	set_cooldown()
	busy = FALSE
	return

/*
 * Pass excess shock from a defibrillation into someone else.
 *
 * Arguments:
 * * user - The person using the defib
 * * origin - The person the shock was originally applied to, the person being defibrillated
 * * affecting - The person the shock is spreading to and negatively affecting.
 * * cell_location - item holding the power source.
*/
/datum/component/defib/proc/excess_shock(mob/user, mob/living/origin, mob/living/carbon/human/affecting, obj/item/cell_location)
	if(user == affecting)
		return
	var/power_source
	if(robotic)
		power_source = user
	else
		if(cell_location)
			power_source = locate(/obj/item/stock_parts/cell) in cell_location

	if(!power_source)
		return

	if(electrocute_mob(affecting, power_source, origin)) // shock anyone touching them >:)
		var/obj/item/organ/internal/heart/HE = affecting.get_organ_slot("heart")
		if(HE.parent_organ == "chest" && affecting.has_both_hands()) // making sure the shock will go through their heart (drask hearts are in their head), and that they have both arms so the shock can cross their heart inside their chest
			affecting.visible_message("<span class='danger'>[affecting]'s entire body shakes as a shock travels up [affecting.p_their()] arm!</span>", \
							"<span class='userdanger'>You feel a powerful shock travel up your [affecting.hand ? affecting.get_organ("l_arm") : affecting.get_organ("r_arm")] and back down your [affecting.hand ? affecting.get_organ("r_arm") : affecting.get_organ("l_arm")]!</span>")
			affecting.set_heartattack(TRUE)



