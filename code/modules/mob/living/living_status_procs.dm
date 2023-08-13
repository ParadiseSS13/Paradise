//Here are the procs used to modify status effects of a mob.

// The `updating` argument is only available on effects that cause a visual/physical effect on the mob itself
// when applied, such as Stun, Weaken, and Jitter - stuff like Blindness, which has a client-side effect,
// lacks this argument.

// BOOLEAN STATES

/*
	* Resting
		You are lying down of your own volition
	* Flying
		For some reason or another you can move while not touching the ground
*/


// STATUS EFFECTS
// All of these are handed by a status_effect in `debuffs.dm` their durations are measured in deciseconds, so the seconds define is used wherever possible, even with decimal seconds values.
// Status effects sorted alphabetically:
/*
	* Confused()				*
			Movement is scrambled
	* Dizzy()					*
			The screen shifts in random directions slightly.
	* Drowsy
			You begin to yawn, and have a chance of incrementing "Paralysis"
	* Druggy()				*
			A trippy overlay appears.
	* Drunk()					*
			Gives you a wide variety of negative effects related to being drunk, all scaling up with alcohol consumption.
	* EyeBlind()				*
			You cannot see. Prevents EyeBlurry from healing naturally.
	* EyeBlurry()				*
			A hazy overlay appears on your screen.
	* Hallucinate()			*
			Your character will imagine various effects happening to them, vividly.
	* Immobilize()
			Your character cannot walk, however they can act.
	* Jitter()				*
			Your character will visibly twitch. Higher values amplify the effect.
	* LoseBreath()			*
			Your character is unable to breathe.
	* Paralysis()				*
			Your character is knocked out.
	* Silence()				*
			Your character is unable to speak.
	* Sleeping()				*
			Your character is asleep.
	* Slowed()				*
			Your character moves slower. The amount of slowdown is variable, defaulting to 10, which is a massive amount.
	* Slurring()				*
			Your character cannot enunciate clearly.
	* CultSlurring()			*
			Your character cannot enunciate clearly while mumbling about elder codes.
	* Stun()				*
			Your character is unable to move, and drops stuff in their hands. They keep standing, though.
	* Stuttering()			*
			Your character stutters parts of their messages.
	* Weaken()				*
			Your character collapses, but is still conscious. does not need to be called in tandem with Stun().
*/

#define RETURN_STATUS_EFFECT_STRENGTH(T) \
	var/datum/status_effect/transient/S = has_status_effect(T);\
	return S ? S.strength : 0

#define SET_STATUS_EFFECT_STRENGTH(T, A) \
	A = max(A, 0);\
	if(A) {;\
		var/datum/status_effect/transient/S = has_status_effect(T);\
		if(!S) {;\
			apply_status_effect(T, A);\
		} else {;\
			S.strength = A;\
		};\
	} else {;\
		remove_status_effect(T);\
	}

#define IS_STUN_IMMUNE(source, ignore_canstun) ((source.status_flags & GODMODE) || (!ignore_canstun && !(source.status_flags & CANSTUN)))

/*
STATUS EFFECTS
*/

/mob/living/proc/lay_down()
	set_body_position(LYING_DOWN)

/mob/living/proc/stand_up(instant = TRUE, work_when_dead = FALSE)
	set waitfor = FALSE

	if(stat == DEAD && !work_when_dead)
		return
	if(!instant && !do_mob(src, src, 1 SECONDS, extra_checks = list(CALLBACK(src, TYPE_PROC_REF(/mob/living, cannot_stand))), only_use_extra_checks = TRUE))
		return
	if(resting || body_position == STANDING_UP || HAS_TRAIT(src, TRAIT_FLOORED))
		return
	set_body_position(STANDING_UP)

/mob/living/proc/set_body_position(new_value)
	if(body_position == new_value)
		return FALSE
	if(buckled) // if they are buckled they aint movin nowhere
		return FALSE
	. = TRUE
	body_position = new_value
	if(new_value == LYING_DOWN) // From standing to lying down.
		on_lying_down()
	else // From lying down to standing up.
		on_standing_up()

/mob/living/proc/on_lying_down(new_lying_angle)
	if(layer == initial(layer)) //to avoid things like hiding larvas.
		if(HAS_TRAIT(src, TRAIT_CONTORTED_BODY))
			layer = BLASTDOOR_LAYER
		else
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
	pixel_y = PIXEL_Y_OFFSET_LYING
	ADD_TRAIT(src, TRAIT_UI_BLOCKED, LYING_DOWN_TRAIT)
	ADD_TRAIT(src, TRAIT_CANNOT_PULL, LYING_DOWN_TRAIT)
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(orient_crawling))
	set_density(FALSE)
	set_lying_angle(pick(90, 270))

/mob/living/proc/on_standing_up()
	if(layer == LYING_MOB_LAYER || HAS_TRAIT(src, TRAIT_CONTORTED_BODY))
		layer = initial(layer)
	set_density(initial(density))
	REMOVE_TRAITS_IN(src, LYING_DOWN_TRAIT)
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
	set_lying_angle(0)
	pixel_y = 0

/* makes sure the crawlers head is pointing in the direction they crawl
 * effectively splits dirs down the middle.

 *										# | #
 * moving this way points the head left # | # moving this way points the head right
 *										# | #

 * moving up or down retains their old lying angle

*/
/mob/living/proc/orient_crawling(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(new_dir in list(WEST, NORTHWEST, SOUTHWEST))
		set_lying_angle(270) // point right
	if(new_dir in list(EAST, NORTHEAST, SOUTHEAST))
		set_lying_angle(90) //point left


/**
 * Changes the inclination angle of a mob, used by humans and others to differentiate between standing up and prone positions.
 *
 * In BYOND-angles 0 is NORTH, 90 is EAST, 180 is SOUTH and 270 is WEST.
 * This usually means that 0 is standing up, 90 and 270 are horizontal positions to right and left respectively, and 180 is upside-down.
 * Mobs that do now follow these conventions due to unusual sprites should require a special handling or redefinition of this proc, due to the density and layer changes.
 * The return of this proc is the previous value of the modified lying_angle if a change was successful (might include zero), or null if no change was made.
 */
/mob/living/proc/set_lying_angle(new_lying)
	if(new_lying == lying_angle)
		return
	. = lying_angle
	lying_angle = new_lying
	if(lying_angle != lying_prev)
		update_transform()
		lying_prev = lying_angle


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
	SetConfused(directional_bounded_sum(get_confusion(), amount, bound_lower, bound_upper))

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
	SetDizzy(directional_bounded_sum(get_dizziness(), amount, bound_lower, bound_upper))

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
	SetDrowsy(directional_bounded_sum(get_drowsiness(), amount, bound_lower, bound_upper))

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
	SetDrunk(directional_bounded_sum(get_drunkenness(), amount, bound_lower, bound_upper))

// DRUGGY

/mob/living/proc/AmountDruggy()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUGGED)

/mob/living/proc/Druggy(amount)
	SetDruggy(max(AmountDruggy(), amount))

/mob/living/proc/SetDruggy(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DRUGGED, amount)

/mob/living/proc/AdjustDruggy(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDruggy(directional_bounded_sum(AmountDruggy(), amount, bound_lower, bound_upper))

// EYE_BLIND
/mob/living/proc/AmountBlinded()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLINDED)

/mob/living/proc/EyeBlind(amount)
	SetEyeBlind(max(AmountBlinded(), amount))

/mob/living/proc/SetEyeBlind(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLINDED, amount)

/mob/living/proc/AdjustEyeBlind(amount, bound_lower = 0, bound_upper = INFINITY, updating = TRUE)
	SetEyeBlind(directional_bounded_sum(AmountBlinded(), amount, bound_lower, bound_upper))

// EYE_BLURRY
/mob/living/proc/AmountEyeBlurry()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLURRY_EYES)

/mob/living/proc/EyeBlurry(amount)
	SetEyeBlurry(max(AmountEyeBlurry(), amount))

/mob/living/proc/SetEyeBlurry(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_BLURRY_EYES, amount)

/mob/living/proc/AdjustEyeBlurry(amount, bound_lower = 0, bound_upper = INFINITY)
	SetEyeBlurry(directional_bounded_sum(AmountEyeBlurry(), amount, bound_lower, bound_upper))

// HALLUCINATION
/mob/living/proc/AmountHallucinate()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_HALLUCINATION)

/mob/living/proc/Hallucinate(amount)
	SetHallucinate(max(AmountHallucinate(), amount))

/mob/living/proc/SetHallucinate(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_HALLUCINATION, amount)

/mob/living/proc/AdjustHallucinate(amount, bound_lower = 0, bound_upper = INFINITY)
	SetHallucinate(directional_bounded_sum(AmountHallucinate(), amount, bound_lower, bound_upper))

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
	SetJitter(directional_bounded_sum(AmountJitter(), amount, bound_lower, bound_upper), force)

// LOSE_BREATH

/mob/living/proc/AmountLoseBreath()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_LOSE_BREATH)

/mob/living/proc/LoseBreath(amount)
	SetLoseBreath(max(AmountLoseBreath(), amount))

/mob/living/proc/SetLoseBreath(amount)
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_LOSE_BREATH, amount)

/mob/living/proc/AdjustLoseBreath(amount, bound_lower = 0, bound_upper = INFINITY)
	SetLoseBreath(directional_bounded_sum(AmountLoseBreath(), amount, bound_lower, bound_upper))

// PARALYSE
/mob/living/proc/IsParalyzed()
	return has_status_effect(STATUS_EFFECT_PARALYZED)

/mob/living/proc/AmountParalyzed()
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		return P.duration - world.time
	return 0

/mob/living/proc/Paralyse(amount, ignore_canstun = FALSE)
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P

/mob/living/proc/SetParalysis(amount, ignore_canstun = FALSE)
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed()
	if(P)
		P.duration = world.time + amount
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_PARALYZED, amount)
	return P

/mob/living/proc/AdjustParalysis(amount, bound_lower = 0, bound_upper = INFINITY, ignore_canstun = FALSE)
	return SetParalysis(directional_bounded_sum(AmountParalyzed(), amount, bound_lower, bound_upper), ignore_canstun)

// SILENT
/mob/living/proc/AmountSilenced()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SILENCED)

/mob/living/proc/Silence(amount)
	SetSilence(max(amount, AmountSilenced()))

/mob/living/proc/SetSilence(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SILENCED, amount)

/mob/living/proc/AmountAbsoluteSilenced()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_ABSSILENCED)

/mob/living/proc/AbsoluteSilence(amount)
	SetAbsoluteSilence(max(amount, AmountAbsoluteSilenced()))

/mob/living/proc/SetAbsoluteSilence(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_ABSSILENCED, amount)

/mob/living/proc/PreventedOxyHeal()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_NO_OXY_HEAL)

/mob/living/proc/PreventOxyHeal(amount)
	SetPreventOxyHeal(max(PreventedOxyHeal(), amount))

/mob/living/proc/SetPreventOxyHeal(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_NO_OXY_HEAL, amount)

/mob/living/proc/AdjustSilence(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSilence(directional_bounded_sum(AmountSilenced(), amount, bound_lower, bound_upper))

//DEAFNESS
/mob/living/proc/AmountDeaf()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DEAF)

/mob/living/proc/Deaf(amount)
	SetDeaf(max(amount, AmountDeaf()))

/mob/living/proc/SetDeaf(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_DEAF, amount)

/mob/living/proc/AdjustDeaf(amount, bound_lower = 0, bound_upper = INFINITY)
	SetDeaf(directional_bounded_sum(AmountDeaf(), amount, bound_lower, bound_upper))

// SLEEPING
/mob/living/proc/IsSleeping()
	return has_status_effect(STATUS_EFFECT_SLEEPING)

/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return S.duration - world.time
	return 0

/mob/living/proc/Sleeping(amount, ignore_canstun = FALSE)
	if(frozen) // If the mob has been admin frozen, sleeping should not be changeable
		return
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = max(world.time + amount, S.duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount)
	return S

/mob/living/proc/SetSleeping(amount, ignore_canstun = FALSE, voluntary = FALSE)
	if(frozen) // If the mob has been admin frozen, sleeping should not be changeable
		return
	if(status_flags & GODMODE)
		return
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(amount <= 0 && S)
		qdel(S)
	if(S)
		S.duration = amount + world.time
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, amount, voluntary)
	if(!voluntary && S)
		// Only set it one way (true => false)
		// Otherwise if we are hard knocked out, and then try to nap, we'd be
		// treated as "just lightly napping" and woken up by trivial stuff.
		S.voluntary = FALSE
	return S

/mob/living/proc/PermaSleeping() /// used for admin freezing.
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration = -1
		S.voluntary = FALSE
	else
		S = apply_status_effect(STATUS_EFFECT_SLEEPING, -1)
	return S

/mob/living/proc/AdjustSleeping(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSleeping(directional_bounded_sum(AmountSleeping(), amount, bound_lower, bound_upper))

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
/mob/living/proc/AmountSluring()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SLURRING)

/mob/living/proc/Slur(amount)
	SetSlur(max(AmountSluring(), amount))

/mob/living/proc/SetSlur(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_SLURRING, amount)

/mob/living/proc/AdjustSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	SetSlur(directional_bounded_sum(AmountSluring(), amount, bound_lower, bound_upper))

// CULTSLURRING
/mob/living/proc/AmountCultSlurring()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CULT_SLUR)

/mob/living/proc/CultSlur(amount)
	SetCultSlur(max(AmountCultSlurring(), amount))

/mob/living/proc/SetCultSlur(amount)
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_CULT_SLUR, amount)

/mob/living/proc/AdjustCultSlur(amount, bound_lower = 0, bound_upper = INFINITY)
	SetCultSlur(directional_bounded_sum(AmountCultSlurring(), amount, bound_lower, bound_upper))

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

/mob/living/proc/AmountStuttering()
	RETURN_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_STAMMER)

/mob/living/proc/Stuttering(amount, ignore_canstun = FALSE)
	SetStuttering(max(AmountStuttering(), amount), ignore_canstun)

/mob/living/proc/SetStuttering(amount, ignore_canstun = FALSE)
	if(IS_STUN_IMMUNE(src, ignore_canstun)) //Often applied with a stun
		return
	SET_STATUS_EFFECT_STRENGTH(STATUS_EFFECT_STAMMER, amount)

/mob/living/proc/AdjustStuttering(amount, bound_lower = 0, bound_upper = INFINITY, ignore_canstun = FALSE)
	SetStuttering(directional_bounded_sum(AmountStuttering(), amount, bound_lower, bound_upper), ignore_canstun)

// WEAKEN

/mob/living/proc/IsWeakened()
	return has_status_effect(STATUS_EFFECT_WEAKENED)

/mob/living/proc/AmountWeakened() //How many deciseconds remain in our Weakened status effect
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened(FALSE)
	if(P)
		return P.duration - world.time
	return 0

/mob/living/proc/Weaken(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened(FALSE)
	if(P)
		P.duration = max(world.time + amount, P.duration)
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_WEAKENED, amount)
	return P

/mob/living/proc/SetWeakened(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened(FALSE)
	if(amount <= 0)
		if(P)
			qdel(P)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(P)
			P.duration = world.time + amount
		else
			P = apply_status_effect(STATUS_EFFECT_WEAKENED, amount)
	return P

/mob/living/proc/AdjustWeakened(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/weakened/P = IsWeakened(FALSE)
	if(P)
		P.duration += amount
	else if(amount > 0)
		P = apply_status_effect(STATUS_EFFECT_WEAKENED, amount)
	return P

/mob/living/proc/IsKnockedDown()
	return has_status_effect(STATUS_EFFECT_FLOORED)

/mob/living/proc/AmountKnockDown()
	var/datum/status_effect/incapacitating/floored/F = IsKnockedDown()
	if(F)
		return F.duration - world.time
	return 0

/mob/living/proc/KnockDown(amount, ignore_canstun = FALSE) //Can't go below remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/floored/F = IsKnockedDown()
	if(F)
		F.duration = max(world.time + amount, F.duration)
	else if(amount > 0)
		F = apply_status_effect(STATUS_EFFECT_FLOORED, amount)
	return F

/mob/living/proc/SetKnockDown(amount, ignore_canstun = FALSE) //Sets remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/floored/F = IsKnockedDown()
	if(amount <= 0)
		if(F)
			qdel(F)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(F)
			F.duration = world.time + amount
		else
			F = apply_status_effect(STATUS_EFFECT_FLOORED, amount)
	return F

/mob/living/proc/AdjustKnockDown(amount, ignore_canstun = FALSE) //Adds to remaining duration
	if(IS_STUN_IMMUNE(src, ignore_canstun))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/floored/F = IsKnockedDown()
	if(F)
		F.duration += amount
	else if(amount > 0)
		F = apply_status_effect(STATUS_EFFECT_FLOORED, amount)
	return F


//
//		DISABILITIES
//

// Blind

/mob/living/proc/become_blind(source, updating = TRUE)
	var/val_change = !HAS_TRAIT(src, TRAIT_BLIND)
	. = val_change ? STATUS_UPDATE_BLIND : STATUS_UPDATE_NONE
	ADD_TRAIT(src, TRAIT_BLIND, source)
	EyeBlind(2 SECONDS)
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

/mob/living/proc/remove_stun_absorption(id_flag)
	stun_absorption -= id_flag
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.getStaminaLoss() <= 100)
			return
		H.enter_stamcrit()


/mob/living/proc/set_shocked()
	flags_2 |= SHOCKED_2

/mob/living/proc/reset_shocked()
	flags_2 &= ~ SHOCKED_2

#undef RETURN_STATUS_EFFECT_STRENGTH
#undef SET_STATUS_EFFECT_STRENGTH
