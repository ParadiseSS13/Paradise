//Here are the procs used to modify status effects of a mob.

// We use these to automatically apply their effects when they are changed, as
// opposed to setting them manually and having to either wait for the next `Life`
// or update by hand

// The `updating` argument is only available on effects that cause a visual/physical effect on the mob itself
// when applied, such as Stun, Weaken, and Jitter - stuff like Blindness, which has a client-side effect,
// lacks this argument.

// Ideally, code should only read the vars in this file, and not ever directly
// modify them

// If you want a mob type to ignore a given status effect, just override the corresponding
// `SetSTATE` proc - since all of the other procs are wrappers around that,
// calling them will have no effect

// BOOLEAN STATES

/*
	* EyesBlocked
		Your eyes are covered somehow
	* EarsBlocked
		Your ears are covered somehow
	* Resting
		You are lying down of your own volition
	* Flying
		For some reason or another you can move while not touching the ground
*/


// STATUS EFFECTS
// All of these decrement over time - at a rate of 1 per life cycle unless otherwise noted
// Status effects sorted alphabetically:
/*
	*	Confused				*
			Movement is scrambled
	*	Dizzy						*
			The screen goes all warped
	*	Drowsy
			You begin to yawn, and have a chance of incrementing "Paralysis"
	*	Druggy					*
			A trippy overlay appears.
	*	Drunk						*
			Essentially what your "BAC" is - the higher it is, the more alcohol you have in you
	*	EyeBlind				*
			You cannot see. Prevents EyeBlurry from healing naturally.
	*	EyeBlurry				*
			A hazy overlay appears on your screen.
	*	Hallucination		*
			Your character will imagine various effects happening to them, vividly.
	*	Jitter					*
			Your character will visibly twitch. Higher values amplify the effect.
	* LoseBreath			*
			Your character is unable to breathe.
	*	Paralysis				*
			Your character is knocked out.
	* Silent					*
			Your character is unable to speak.
	*	Sleeping				*
			Your character is asleep.
	*	Slowed					*
			Your character moves slower.
	*	Slurring				*
			Your character cannot enunciate clearly.
	*	CultSlurring			*
			Your character cannot enunciate clearly while mumbling about elder codes.
	*	Stunned					*
			Your character is unable to move, and drops stuff in their hands. They keep standing, though.
	* Stuttering			*
			Your character stutters parts of their messages.
	*	Weakened				*
			Your character collapses, but is still conscious.
*/

// DISABILITIES
// These are more permanent than the above.
// Disabilities sorted alphabetically
/*
	*	Blind	(32)
			Can't see. EyeBlind does not heal when this is active.
	*	Coughing	(4)
			Cough occasionally, causing you to drop your items
	*	Deaf	(128)
			Can't hear. EarDeaf does not heal when this is active
	*	Epilepsy	(2)
			Occasionally go "Epileptic", causing you to become very twitchy, drop all items, and fall to the floor
	*	Mute	(64)
			Cannot talk.
	*	Nearsighted	(1)
			My glasses! I can't see without my glasses! (Nearsighted overlay when not wearing prescription eyewear)
	*	Nervous	(16)
			Occasionally begin to stutter.
	*	Tourettes	(8)
			SHIT (say bad words, and drop stuff occasionally)
*/

/mob/living

	// Booleans
	var/resting = FALSE

	/*
	STATUS EFFECTS
	*/

/mob // On `/mob` for now, to support legacy code
	var/confused = 0
	var/cultslurring = 0
	var/dizziness = 0
	var/drowsyness = 0
	var/druggy = 0
	var/drunk = 0
	var/eye_blind = 0
	var/eye_blurry = 0
	var/hallucination = 0
	var/jitteriness = 0
	var/losebreath = 0
	var/paralysis = 0
	var/silent = 0
	var/sleeping = 0
	var/slowed = 0
	var/slurring = 0
	var/stunned = 0
	var/stuttering = 0
	var/weakened = 0

/mob/living
	// Bitfields
	var/disabilities = 0

// RESTING

/mob/living/proc/StartResting(updating = 1)
	var/val_change = !resting
	resting = TRUE

	if(updating && val_change)
		update_canmove()

/mob/living/proc/StopResting(updating = 1)
	var/val_change = !!resting
	resting = FALSE

	if(updating && val_change)
		update_canmove()

/mob/living/proc/StartFlying()
	var/val_change = !flying
	flying = TRUE
	if(val_change)
		update_animations()

/mob/living/proc/StopFlying()
	var/val_change = !!flying
	flying = FALSE
	if(val_change)
		update_animations()


// SCALAR STATUS EFFECTS

// CONFUSED

/mob/living/Confused(amount)
	SetConfused(max(confused, amount))

/mob/living/SetConfused(amount)
	confused = max(amount, 0)

/mob/living/AdjustConfused(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(confused, amount, bound_lower, bound_upper)
	SetConfused(new_value)

// DIZZY

/mob/living/Dizzy(amount)
	SetDizzy(max(dizziness, amount))

/mob/living/SetDizzy(amount)
	dizziness = max(amount, 0)

/mob/living/AdjustDizzy(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(dizziness, amount, bound_lower, bound_upper)
	SetDizzy(new_value)

// DROWSY

/mob/living/Drowsy(amount)
	SetDrowsy(max(drowsyness, amount))

/mob/living/SetDrowsy(amount)
	drowsyness = max(amount, 0)

/mob/living/AdjustDrowsy(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(drowsyness, amount, bound_lower, bound_upper)
	SetDrowsy(new_value)

// DRUNK

/mob/living/Drunk(amount)
	SetDrunk(max(drunk, amount))

/mob/living/SetDrunk(amount)
	drunk = max(amount, 0)

/mob/living/AdjustDrunk(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(drunk, amount, bound_lower, bound_upper)
	SetDrunk(new_value)

// DRUGGY

/mob/living/Druggy(amount, updating = TRUE)
	return SetDruggy(max(druggy, amount), updating)

/mob/living/SetDruggy(amount, updating = TRUE)
	. = STATUS_UPDATE_DRUGGY
	if((!!amount) == (!!druggy)) // We're not changing from + to 0 or vice versa
		. = STATUS_UPDATE_NONE
		updating = FALSE
	druggy = max(amount, 0)
	// We transitioned to/from 0, so update the druggy overlays
	if(updating)
		update_druggy_effects()

/mob/living/AdjustDruggy(amount, bound_lower = 0, bound_upper = INFINITY, updating = TRUE)
	var/new_value = directional_bounded_sum(druggy, amount, bound_lower, bound_upper)
	return SetDruggy(new_value, updating)

// EYE_BLIND

/mob/living/EyeBlind(amount, updating = TRUE)
	return SetEyeBlind(max(eye_blind, amount), updating)

/mob/living/SetEyeBlind(amount, updating = TRUE)
	. = STATUS_UPDATE_BLIND
	if((!!amount) == (!!eye_blind)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE
	eye_blind = max(amount, 0)
	// We transitioned to/from 0, so update the eye blind overlays
	if(updating)
		update_blind_effects()

/mob/living/AdjustEyeBlind(amount, bound_lower = 0, bound_upper = INFINITY, updating = TRUE)
	var/new_value = directional_bounded_sum(eye_blind, amount, bound_lower, bound_upper)
	return SetEyeBlind(new_value, updating)

// EYE_BLURRY

/mob/living/EyeBlurry(amount, updating = TRUE)
	return SetEyeBlurry(max(eye_blurry, amount), updating)

/mob/living/SetEyeBlurry(amount, updating = TRUE)
	. = STATUS_UPDATE_BLURRY
	if((!!amount) == (!!eye_blurry)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE
	eye_blurry = max(amount, 0)
	// We transitioned to/from 0, so update the eye blur overlays
	if(updating)
		update_blurry_effects()

/mob/living/AdjustEyeBlurry(amount, bound_lower = 0, bound_upper = INFINITY, updating = TRUE)
	var/new_value = directional_bounded_sum(eye_blurry, amount, bound_lower, bound_upper)
	return SetEyeBlurry(new_value, updating)

// HALLUCINATION

/mob/living/Hallucinate(amount)
	SetHallucinate(max(hallucination, amount))

/mob/living/SetHallucinate(amount)
	hallucination = max(amount, 0)

/mob/living/AdjustHallucinate(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(hallucination, amount, bound_lower, bound_upper)
	SetHallucinate(new_value)

// JITTER

/mob/living/Jitter(amount, force = 0)
	SetJitter(max(jitteriness, amount), force)

/mob/living/SetJitter(amount, force = 0)
	// Jitter is also associated with stun
	if(status_flags & CANSTUN || force)
		jitteriness = max(amount, 0)

/mob/living/AdjustJitter(amount, bound_lower = 0, bound_upper = INFINITY, force = 0)
	var/new_value = directional_bounded_sum(jitteriness, amount, bound_lower, bound_upper)
	SetJitter(new_value, force)

// LOSE_BREATH

/mob/living/LoseBreath(amount)
	SetLoseBreath(max(losebreath, amount))

/mob/living/SetLoseBreath(amount)
	if(BREATHLESS in mutations)
		losebreath = 0
		return FALSE
	losebreath = max(amount, 0)

/mob/living/AdjustLoseBreath(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(losebreath, amount, bound_lower, bound_upper)
	SetLoseBreath(new_value)

// PARALYSE

/mob/living/Paralyse(amount, updating = 1, force = 0)
	return SetParalysis(max(paralysis, amount), updating, force)

/mob/living/SetParalysis(amount, updating = 1, force = 0)
	. = STATUS_UPDATE_STAT
	if((!!amount) == (!!paralysis)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE
	if(status_flags & CANPARALYSE || force)
		paralysis = max(amount, 0)
		if(updating)
			update_canmove()
			update_stat("paralysis")

/mob/living/AdjustParalysis(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(paralysis, amount, bound_lower, bound_upper)
	return SetParalysis(new_value, updating, force)

// SILENT

/mob/living/Silence(amount)
	SetSilence(max(silent, amount))

/mob/living/SetSilence(amount)
	silent = max(amount, 0)

/mob/living/AdjustSilence(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(silent, amount, bound_lower, bound_upper)
	SetSilence(new_value)

// SLEEPING

/mob/living/Sleeping(amount, updating = 1, no_alert = FALSE)
	return SetSleeping(max(sleeping, amount), updating, no_alert)

/mob/living/SetSleeping(amount, updating = 1, no_alert = FALSE)
	if(frozen) // If the mob has been admin frozen, sleeping should not be changeable
		return
	. = STATUS_UPDATE_STAT
	if((!!amount) == (!!sleeping)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE
	sleeping = max(amount, 0)
	if(updating)
		update_sleeping_effects(no_alert)
		update_stat("sleeping")
		update_canmove()

/mob/living/AdjustSleeping(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, no_alert = FALSE)
	var/new_value = directional_bounded_sum(sleeping, amount, bound_lower, bound_upper)
	return SetSleeping(new_value, updating, no_alert)

// SLOWED

/mob/living/Slowed(amount, updating = 1)
	SetSlowed(max(slowed, amount), updating)

/mob/living/SetSlowed(amount, updating = 1)
	slowed = max(amount, 0)

/mob/living/AdjustSlowed(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1)
	var/new_value = directional_bounded_sum(slowed, amount, bound_lower, bound_upper)
	SetSlowed(new_value, updating)

// SLURRING

/mob/living/Slur(amount)
	SetSlur(max(slurring, amount))

/mob/living/SetSlur(amount)
	slurring = max(amount, 0)

/mob/living/AdjustSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(slurring, amount, bound_lower, bound_upper)
	SetSlur(new_value)

// CULTSLURRING

/mob/living/CultSlur(amount)
	SetSlur(max(slurring, amount))

/mob/living/SetCultSlur(amount)
	slurring = max(amount, 0)

/mob/living/AdjustCultSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(cultslurring, amount, bound_lower, bound_upper)
	SetCultSlur(new_value)

// STUN

/mob/living/Stun(amount, updating = 1, force = 0)
	if(status_flags & CANSTUN || force)
		if(absorb_stun(amount, force))
			return FALSE
	return SetStunned(max(stunned, amount), updating, force)

/mob/living/SetStunned(amount, updating = 1, force = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	. = STATUS_UPDATE_CANMOVE
	if((!!amount) == (!!stunned)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE

	if(status_flags & CANSTUN || force)
		stunned = max(amount, 0)
		if(updating)
			update_canmove()
	else
		return STATUS_UPDATE_NONE

/mob/living/AdjustStunned(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(stunned, amount, bound_lower, bound_upper)
	return SetStunned(new_value, updating, force)

// STUTTERING


/mob/living/Stuttering(amount, force = 0)
	SetStuttering(max(stuttering, amount), force)

/mob/living/SetStuttering(amount, force = 0)
	//From mob/living/apply_effect: "Stuttering is often associated with Stun"
	if(status_flags & CANSTUN || force)
		stuttering = max(amount, 0)

/mob/living/AdjustStuttering(amount, bound_lower = 0, bound_upper = INFINITY, force = 0)
	var/new_value = directional_bounded_sum(stuttering, amount, bound_lower, bound_upper)
	SetStuttering(new_value, force)

// WEAKEN

/mob/living/Weaken(amount, updating = 1, force = 0)
	if(status_flags & CANWEAKEN || force)
		if(absorb_stun(amount, force))
			return FALSE
	return SetWeakened(max(weakened, amount), updating, force)

/mob/living/SetWeakened(amount, updating = 1, force = 0)
	. = STATUS_UPDATE_CANMOVE
	if((!!amount) == (!!weakened)) // We're not changing from + to 0 or vice versa
		updating = FALSE
		. = STATUS_UPDATE_NONE
	if(status_flags & CANWEAKEN || force)
		weakened = max(amount, 0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
	else
		return STATUS_UPDATE_NONE

/mob/living/AdjustWeakened(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(weakened, amount, bound_lower, bound_upper)
	return SetWeakened(new_value, updating, force)

//
//		DISABILITIES
//

// Blind

/mob/living/proc/BecomeBlind(updating = TRUE)
	var/val_change = !(disabilities & BLIND)
	. = val_change ? STATUS_UPDATE_BLIND : STATUS_UPDATE_NONE
	disabilities |= BLIND
	if(val_change && updating)
		update_blind_effects()

/mob/living/proc/CureBlind(updating = TRUE)
	var/val_change = !!(disabilities & BLIND)
	. = val_change ? STATUS_UPDATE_BLIND : STATUS_UPDATE_NONE
	disabilities &= ~BLIND
	if(val_change && updating)
		CureIfHasDisability(BLINDBLOCK)
		update_blind_effects()

// Coughing

/mob/living/proc/BecomeCoughing()
	disabilities |= COUGHING

/mob/living/proc/CureCoughing()
	disabilities &= ~COUGHING
	CureIfHasDisability(COUGHBLOCK)

// Deaf

/mob/living/proc/BecomeDeaf()
	disabilities |= DEAF

/mob/living/proc/CureDeaf()
	disabilities &= ~DEAF
	CureIfHasDisability(DEAFBLOCK)

// Epilepsy

/mob/living/proc/BecomeEpilepsy()
	disabilities |= EPILEPSY

/mob/living/proc/CureEpilepsy()
	disabilities &= ~EPILEPSY
	CureIfHasDisability(EPILEPSYBLOCK)

// Mute

/mob/living/proc/BecomeMute()
	disabilities |= MUTE

/mob/living/proc/CureMute()
	disabilities &= ~MUTE
	CureIfHasDisability(MUTEBLOCK)

// Nearsighted

/mob/living/proc/BecomeNearsighted(updating = TRUE)
	var/val_change = !(disabilities & NEARSIGHTED)
	. = val_change ? STATUS_UPDATE_NEARSIGHTED : STATUS_UPDATE_NONE
	disabilities |= NEARSIGHTED
	if(val_change && updating)
		update_nearsighted_effects()

/mob/living/proc/CureNearsighted(updating = TRUE)
	var/val_change = !!(disabilities & NEARSIGHTED)
	. = val_change ? STATUS_UPDATE_NEARSIGHTED : STATUS_UPDATE_NONE
	disabilities &= ~NEARSIGHTED
	if(val_change && updating)
		CureIfHasDisability(GLASSESBLOCK)
		update_nearsighted_effects()

// Nervous

/mob/living/proc/BecomeNervous()
	disabilities |= NERVOUS

/mob/living/proc/CureNervous()
	disabilities &= ~NERVOUS
	CureIfHasDisability(NERVOUSBLOCK)

// Tourettes

/mob/living/proc/BecomeTourettes()
	disabilities |= TOURETTES

/mob/living/proc/CureTourettes()
	disabilities &= ~TOURETTES
	CureIfHasDisability(TWITCHBLOCK)

/mob/living/proc/CureIfHasDisability(block)
	if(dna && dna.GetSEState(block))
		dna.SetSEState(block, 0, 1) //Fix the gene
		genemutcheck(src, block,null, MUTCHK_FORCED)
		dna.UpdateSE()

///////////////////////////////// FROZEN /////////////////////////////////////

/mob/living/proc/IsFrozen()
	return has_status_effect(/datum/status_effect/freon)

///////////////////////////////////// STUN ABSORPTION /////////////////////////////////////

/mob/living/proc/add_stun_absorption(key, duration, priority, message, self_message, examine_message)
//adds a stun absorption with a key, a duration in deciseconds, its priority, and the messages it makes when you're stun/examined, if any
	if(!islist(stun_absorption))
		stun_absorption = list()
	if(stun_absorption[key])
		stun_absorption[key]["end_time"] = world.time + duration
		stun_absorption[key]["priority"] = priority
		stun_absorption[key]["stuns_absorbed"] = 0
	else
		stun_absorption[key] = list("end_time" = world.time + duration, "priority" = priority, "stuns_absorbed" = 0, \
		"visible_message" = message, "self_message" = self_message, "examine_message" = examine_message)

/mob/living/proc/absorb_stun(amount, ignoring_flag_presence)
	if(amount < 0 || stat || ignoring_flag_presence || !islist(stun_absorption))
		return FALSE
	if(!amount)
		amount = 0
	var/priority_absorb_key
	var/highest_priority
	for(var/i in stun_absorption)
		if(stun_absorption[i]["end_time"] > world.time && (!priority_absorb_key || stun_absorption[i]["priority"] > highest_priority))
			priority_absorb_key = stun_absorption[i]
			highest_priority = priority_absorb_key["priority"]
	if(priority_absorb_key)
		if(amount) //don't spam up the chat for continuous stuns
			if(priority_absorb_key["visible_message"] || priority_absorb_key["self_message"])
				if(priority_absorb_key["visible_message"] && priority_absorb_key["self_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>", "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
				else if(priority_absorb_key["visible_message"])
					visible_message("<span class='warning'>[src][priority_absorb_key["visible_message"]]</span>")
				else if(priority_absorb_key["self_message"])
					to_chat(src, "<span class='boldwarning'>[priority_absorb_key["self_message"]]</span>")
			priority_absorb_key["stuns_absorbed"] += amount
		return TRUE