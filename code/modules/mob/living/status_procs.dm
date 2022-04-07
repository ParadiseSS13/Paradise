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
	* Resting
		You are lying down of your own volition
	* Flying
		For some reason or another you can move while not touching the ground
*/


// STATUS EFFECTS
// All of these decrement over time - at a rate of 1 per life cycle unless otherwise noted
// Status effects sorted alphabetically:
/*
	* Confused				*
			Movement is scrambled
	* Dizzy					*
			The screen goes all warped
	* Drowsy
			You begin to yawn, and have a chance of incrementing "Paralysis"
	* Druggy				*
			A trippy overlay appears.
	* Drunk					*
			Essentially what your "BAC" is - the higher it is, the more alcohol you have in you
	* EyeBlind				*
			You cannot see. Prevents EyeBlurry from healing naturally.
	* EyeBlurry				*
			A hazy overlay appears on your screen.
	* Hallucination			*
			Your character will imagine various effects happening to them, vividly.
	* Jitter				*
			Your character will visibly twitch. Higher values amplify the effect.
	* LoseBreath			*
			Your character is unable to breathe.
	* Paralysis				*
			Your character is knocked out.
	* Silent				*
			Your character is unable to speak.
	* Sleeping				*
			Your character is asleep.
	* Slowed				*
			Your character moves slower.
	* Slurring				*
			Your character cannot enunciate clearly.
	* CultSlurring			*
			Your character cannot enunciate clearly while mumbling about elder codes.
	* Stunned				*
			Your character is unable to move, and drops stuff in their hands. They keep standing, though.
	* Stuttering			*
			Your character stutters parts of their messages.
	* Weakened				*
			Your character collapses, but is still conscious.
*/

#define RETURN_STATUS_EFFECT_STRENGTH(T) \
	var/datum/status_effect/transient/S = has_status_effect(T);\
	return S ? S.strength : 0

#define SET_STATUS_EFFECT_STRENGTH(T, A) \
	A = max(A, 0);\
	if(A) {;\
		var/datum/status_effect/transient/S = has_status_effect(T) || apply_status_effect(T);\
		S.strength = A;\
	} else {;\
		remove_status_effect(T);\
	}

#define IS_STUN_IMMUNE(source, ignore_canstun) ((source.status_flags & GODMODE) || (!ignore_canstun && !(source.status_flags & CANSTUN)))

/mob/living

	// Booleans
	var/resting = FALSE

	/*
	STATUS EFFECTS
	*/

/mob // On `/mob` for now, to support legacy code
	var/cultslurring = 0
	var/druggy = 0
	var/eye_blind = 0
	var/eye_blurry = 0
	var/hallucination = 0
	var/losebreath = 0
	var/paralysis = 0
	var/slurring = 0
	var/stuttering = 0

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


// SCALAR STATUS EFFECTS

/**
 * Returns current amount of [confusion][/datum/status_effect/decaying/confusion], 0 if none.
 */
/mob/living/proc/get_confusion()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CONFUSION)

/**
 * Sets [confusion][/datum/status_effect/decaying/confusion] if it's higher than zero.
 */
/mob/living/proc/SetConfused(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CONFUSION, amount)

/**
 * Sets [confusion][/datum/status_effect/decaying/confusion] if it's higher than current.
 */
/mob/living/proc/Confused(amount)
	SetConfused(max(get_confusion(), amount))

/**
 * Sets [confusion][/datum/status_effect/decaying/confusion] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustConfused(amount, bound_lower = 0, bound_upper = INFINITY)
	SetConfused(clamp(get_confusion() + amount, bound_lower, bound_upper))

// DIZZY

/**
 * Returns current amount of [dizziness][/datum/status_effect/decaying/dizziness], 0 if none.
 */
/mob/living/proc/get_dizziness()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DIZZINESS)

/**
 * Sets [dizziness][/datum/status_effect/decaying/dizziness] if it's higher than zero.
 */
/mob/living/proc/SetDizzy(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DIZZINESS, amount)

/**
 * Sets [dizziness][/datum/status_effect/decaying/dizziness] if it's higher than current.
 */
/mob/living/proc/Dizzy(amount)
	SetDizzy(max(get_dizziness(), amount))

/**
 * Sets [dizziness][/datum/status_effect/decaying/dizziness] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustDizzy(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDizzy(clamp(get_dizziness() + amount, bound_lower, bound_upper))

// DROWSY

/**
 * Returns current amount of [drowsiness][/datum/status_effect/decaying/drowsiness], 0 if none.
 */
/mob/living/proc/get_drowsiness()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DROWSINESS)

/**
 * Sets [drowsiness][/datum/status_effect/decaying/drowsiness] if it's higher than zero.
 */
/mob/living/proc/SetDrowsy(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DROWSINESS, amount)

/**
 * Sets [drowsiness][/datum/status_effect/decaying/drowsiness] if it's higher than current.
 */
/mob/living/proc/Drowsy(amount)
	SetDrowsy(max(get_drowsiness(), amount))

/**
 * Sets [drowsiness][/datum/status_effect/decaying/drowsiness] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustDrowsy(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDrowsy(clamp(get_drowsiness() + amount, bound_lower, bound_upper))

// DRUNK

/**
 * Returns current amount of [drunkenness][/datum/status_effect/decaying/drunkenness], 0 if none.
 */
/mob/living/proc/get_drunkenness()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUNKENNESS)

/**
 * Sets [drunkenness][/datum/status_effect/decaying/drunkenness] if it's higher than zero.
 */
/mob/living/proc/SetDrunk(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUNKENNESS, amount)

/**
 * Sets [drunkenness][/datum/status_effect/decaying/drunkenness] if it's higher than current.
 */
/mob/living/proc/Drunk(amount)
	SetDrunk(max(get_drunkenness(), amount))

/**
 * Sets [drunkenness][/datum/status_effect/decaying/drunkenness] to current amount + given, clamped between lower and higher bounds.
 *
 * Arguments:
 * * amount - Amount to add. Can be negative to reduce duration.
 * * bound_lower - Minimum bound to set at least to. Defaults to 0.
 * * bound_upper - Maximum bound to set up to. Defaults to infinity.
 */
/mob/living/proc/AdjustDrunk(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDrunk(clamp(get_drunkenness() + amount, bound_lower, bound_upper))

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
	//if they're both above max or equal that means we won't change the blur filter
	if(amount > MAX_EYE_BLURRY_FILTER_SIZE / EYE_BLUR_TO_FILTER_SIZE_MULTIPLIER && eye_blurry > MAX_EYE_BLURRY_FILTER_SIZE / EYE_BLUR_TO_FILTER_SIZE_MULTIPLIER || eye_blurry == amount)
		updating = FALSE
		. = STATUS_UPDATE_NONE

	eye_blurry = max(amount, 0)
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
/mob/living/proc/AmountJitter()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_JITTER)

/mob/living/proc/Jitter(amount, ignore_canstun = FALSE)
	SetJitter(max(AmountJitter(), amount), ignore_canstun)

/mob/living/proc/SetJitter(amount, ignore_canstun = FALSE)
	// Jitter is also associated with stun
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_JITTER, amount)

/mob/living/proc/AdjustJitter(amount, bound_lower = 0, bound_upper = INFINITY, force = 0)
	var/new_value = directional_bounded_sum(AmountJitter(), amount, bound_lower, bound_upper)
	SetJitter(new_value, force)

// LOSE_BREATH

/mob/living/LoseBreath(amount)
	SetLoseBreath(max(losebreath, amount))

/mob/living/SetLoseBreath(amount)
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
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
/mob/living/proc/AmountSilenced()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SILENCED)

/mob/living/Silence(amount)
	var/datum/status_effect/transient/silence/S = AmountSilenced()
	SetSilence(max(amount, S.strength))

/mob/living/SetSilence(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SILENCED, amount)

/mob/living/AdjustSilence(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSilence(clamp(AmountSilenced() + amount, bound_lower, bound_upper))

// SLEEPING
/mob/living/proc/IsSleeping()
	return has_status_effect(STATUS_EFFECT_SLEEPING)

/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Sleeping(amount, ignore_canstun = FALSE)
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
	return S

/mob/living/proc/SetSleeping(amount, ignore_canstun = FALSE)
	if(frozen && !ignore_canstun) // If the mob has been admin frozen, sleeping should not be changeable
		return
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, amount)
	return S

/mob/living/proc/PermaSleeping() /// used for admin freezing.
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = -1
	else
		S = apply_status_effect(/datum/status_effect/incapacitating/sleeping, -1)
	return S

/mob/living/proc/AdjustSleeping(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSleeping(clamp(amount, bound_lower, bound_upper))

// SLOWED
/mob/living/proc/IsSlowed()
	return has_status_effect(STATUS_EFFECT_SLOWED)

/mob/living/proc/Slowed(amount, _slowdown_value)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		S.duration = max(world.time + amount, S.duration)
		S.slowdown_value = _slowdown_value
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLOWED, amount, _slowdown_value)
	return S

/mob/living/proc/SetSlowed(amount, _slowdown_value)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(amount <= 0 || _slowdown_value <= 0)
		if(S)
			qdel(S)
	else
		if(S)
			S.duration = amount
			S.slowdown_value = _slowdown_value
		else
			S = apply_status_effect(STATUS_EFFECT_SLOWED, amount, _slowdown_value)
	return S


/mob/living/proc/AdjustSlowedDuration(amount)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		S.duration += amount

/mob/living/proc/AdjustSlowedIntensity(intensity)
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		S.slowdown_value += intensity

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
	SetCultSlur(max(cultslurring, amount))

/mob/living/SetCultSlur(amount)
	cultslurring = max(amount, 0)

/mob/living/AdjustCultSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(cultslurring, amount, bound_lower, bound_upper)
	SetCultSlur(new_value)


/* STUN */
/mob/living/proc/IsStunned() //If we're stunned
	return has_status_effect(STATUS_EFFECT_STUN)

/mob/living/proc/AmountStun() //How many deciseconds remain in our stun
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Stun(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S

/mob/living/proc/SetStunned(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(amount <= 0)
		if(S)
			qdel(S)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(S)
			S.duration = world.time + amount
		else
			S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S

/mob/living/proc/AdjustStunned(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/stun/S = IsStunned()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_STUN, amount)
	return S

/mob/living/proc/IsImmobilized()
	return has_status_effect(STATUS_EFFECT_IMMOBILIZED)

/mob/living/proc/Immobilize(amount, ignore_canstun = FALSE)
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		I.duration = max(world.time + amount, I.duration)
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I

/mob/living/proc/SetImmobilized(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(amount <= 0)
		if(I)
			qdel(I)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(I)
			I.duration = world.time + amount
		else
			I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I

/mob/living/proc/AdjustImmobilized(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/immobilized/I = IsImmobilized()
	if(I)
		I.duration += amount
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_IMMOBILIZED, amount)
	return I

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

/mob/living/proc/IsWeakened()
	return has_status_effect(STATUS_EFFECT_PARALYZED)

/mob/living/proc/AmountWeakened() //How many deciseconds remain in our Weakened status effect
	var/datum/status_effect/incapacitating/paralyzed/P = IsWeakened()
	if(P)
		return P.duration - world.time
	return 0

/mob/living/proc/Weaken(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsWeakened()
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P

/mob/living/proc/SetWeakened(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsWeakened()
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P

/mob/living/proc/AdjustWeakened(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsWeakened()
	if(P)
		P.duration += amount
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P

//
//		DISABILITIES
//

// Blind

/mob/living/proc/become_blind(source, updating = TRUE)
	var/val_change = !HAS_TRAIT(src, TRAIT_BLIND)
	. = val_change ? STATUS_UPDATE_BLIND : STATUS_UPDATE_NONE
	ADD_TRAIT(src, TRAIT_BLIND, source)
	if(val_change && updating)
		update_blind_effects()

/mob/living/proc/cure_blind(source, updating = TRUE)
	var/val_change = !!HAS_TRAIT(src, TRAIT_BLIND)
	. = val_change ? STATUS_UPDATE_BLIND : STATUS_UPDATE_NONE
	REMOVE_TRAIT(src, TRAIT_BLIND, source)
	if(val_change && updating)
		update_blind_effects()

// Coughing
/mob/living/proc/CureCoughing()
	CureIfHasDisability(GLOB.coughblock)

// Deaf
/mob/living/proc/CureDeaf()
	CureIfHasDisability(GLOB.deafblock)

// Epilepsy
/mob/living/proc/CureEpilepsy()
	CureIfHasDisability(GLOB.epilepsyblock)

// Mute
/mob/living/proc/CureMute()
	CureIfHasDisability(GLOB.muteblock)

// Nearsighted
/mob/living/proc/become_nearsighted(source, updating = TRUE)
	var/val_change = !HAS_TRAIT(src, TRAIT_NEARSIGHT)
	. = val_change ? STATUS_UPDATE_NEARSIGHTED : STATUS_UPDATE_NONE
	ADD_TRAIT(src, TRAIT_NEARSIGHT, source)
	if(val_change && updating)
		update_nearsighted_effects()

/mob/living/proc/cure_nearsighted(source, updating = TRUE)
	var/val_change = !!HAS_TRAIT(src, TRAIT_NEARSIGHT)
	. = val_change ? STATUS_UPDATE_NEARSIGHTED : STATUS_UPDATE_NONE
	REMOVE_TRAIT(src, TRAIT_NEARSIGHT, source)
	if(val_change && updating)
		update_nearsighted_effects()

// Nervous
/mob/living/proc/CureNervous()
	CureIfHasDisability(GLOB.nervousblock)

// Tourettes
/mob/living/proc/CureTourettes()
	CureIfHasDisability(GLOB.twitchblock)

/mob/living/proc/CureIfHasDisability(block)
	if(dna && dna.GetSEState(block))
		dna.SetSEState(block, 0, 1) //Fix the gene
		singlemutcheck(src, block, MUTCHK_FORCED)
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

/mob/living/proc/set_shocked()
	flags_2 |= SHOCKED_2

/mob/living/proc/reset_shocked()
	flags_2 &= ~ SHOCKED_2

#undef RETURN_STATUS_EFFECT_STRENGTH
#undef SET_STATUS_EFFECT_STRENGTH
