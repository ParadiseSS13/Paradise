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
	* EarDamage				*
			Doesn't do much, but if it's 25+, you go deaf. Heals much slower than other statuses - 0.05 normally
	*	EarDeaf					*
			You cannot hear. Prevents EarDamage from healing naturally.
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
	var/ear_damage = 0
	var/ear_deaf = 0
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

/mob/living/Druggy(amount)
	SetDruggy(max(druggy, amount))

/mob/living/SetDruggy(amount)
	var/old_val = druggy
	druggy = max(amount, 0)
	// We transitioned to/from 0, so update the druggy overlays
	if((old_val == 0 || druggy == 0) && (old_val != druggy))
		update_druggy_effects()

/mob/living/AdjustDruggy(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(druggy, amount, bound_lower, bound_upper)
	SetDruggy(new_value)

// EAR_DAMAGE

/mob/living/EarDamage(amount)
	SetEarDamage(max(ear_damage, amount))

/mob/living/SetEarDamage(amount)
	ear_damage = max(amount, 0)

/mob/living/AdjustEarDamage(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(ear_damage, amount, bound_lower, bound_upper)
	SetEarDamage(new_value)

// EAR_DEAF

/mob/living/EarDeaf(amount)
	SetEarDeaf(max(ear_deaf, amount))

/mob/living/SetEarDeaf(amount)
	ear_deaf = max(amount, 0)

/mob/living/AdjustEarDeaf(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(ear_deaf, amount, bound_lower, bound_upper)
	SetEarDeaf(new_value)

// EYE_BLIND

/mob/living/EyeBlind(amount)
	SetEyeBlind(max(eye_blind, amount))

/mob/living/SetEyeBlind(amount)
	var/old_val = eye_blind
	eye_blind = max(amount, 0)
	// We transitioned to/from 0, so update the eye blind overlays
	if((old_val == 0 || eye_blind == 0) && (old_val != eye_blind))
		update_blind_effects()

/mob/living/AdjustEyeBlind(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(eye_blind, amount, bound_lower, bound_upper)
	SetEyeBlind(new_value)

// EYE_BLURRY

/mob/living/EyeBlurry(amount)
	SetEyeBlurry(max(eye_blurry, amount))

/mob/living/SetEyeBlurry(amount)
	var/old_val = eye_blurry
	eye_blurry = max(amount, 0)
	// We transitioned to/from 0, so update the eye blur overlays
	if((old_val == 0 || eye_blurry == 0) && (old_val != eye_blurry))
		update_blurry_effects()

/mob/living/AdjustEyeBlurry(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(eye_blurry, amount, bound_lower, bound_upper)
	SetEyeBlurry(new_value)

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
	losebreath = max(amount, 0)

/mob/living/AdjustLoseBreath(amount, bound_lower = 0, bound_upper = INFINITY)
	var/new_value = directional_bounded_sum(losebreath, amount, bound_lower, bound_upper)
	SetLoseBreath(new_value)

// PARALYSE

/mob/living/Paralyse(amount, updating = 1, force = 0)
	SetParalysis(max(paralysis, amount), updating, force)

/mob/living/SetParalysis(amount, updating = 1, force = 0)
	if(status_flags & CANPARALYSE || force)
		paralysis = max(amount, 0)
		if(updating)
			update_canmove()
			update_stat()

/mob/living/AdjustParalysis(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(paralysis, amount, bound_lower, bound_upper)
	SetParalysis(new_value, updating, force)

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
	SetSleeping(max(sleeping, amount), updating, no_alert)

/mob/living/SetSleeping(amount, updating = 1, no_alert = FALSE)
	sleeping = max(amount, 0)
	update_sleeping_effects(no_alert)
	if(updating)
		update_stat()
		update_canmove()

/mob/living/AdjustSleeping(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, no_alert = FALSE)
	var/new_value = directional_bounded_sum(sleeping, amount, bound_lower, bound_upper)
	SetSleeping(new_value, updating, no_alert)

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
	SetStunned(max(stunned, amount), updating, force)

/mob/living/SetStunned(amount, updating = 1, force = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN || force)
		stunned = max(amount, 0)
		if(updating)
			update_canmove()

/mob/living/AdjustStunned(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(stunned, amount, bound_lower, bound_upper)
	SetStunned(new_value, updating, force)

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
	SetWeakened(max(weakened, amount), updating, force)

/mob/living/SetWeakened(amount, updating = 1, force = 0)
	if(status_flags & CANWEAKEN || force)
		weakened = max(amount, 0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons

/mob/living/AdjustWeakened(amount, bound_lower = 0, bound_upper = INFINITY, updating = 1, force = 0)
	var/new_value = directional_bounded_sum(weakened, amount, bound_lower, bound_upper)
	SetWeakened(new_value, updating, force)

//
//		DISABILITIES
//

// Blind

/mob/living/proc/BecomeBlind()
	var/val_change = !(disabilities & BLIND)
	disabilities |= BLIND
	if(val_change)
		update_blind_effects()

/mob/living/proc/CureBlind()
	var/val_change = !!(disabilities & BLIND)
	disabilities &= ~BLIND
	if(val_change)
		update_blind_effects()

// Coughing

/mob/living/proc/BecomeCoughing()
	disabilities |= COUGHING

/mob/living/proc/CureCoughing()
	disabilities &= ~COUGHING

// Deaf

/mob/living/proc/BecomeDeaf()
	disabilities |= DEAF

/mob/living/proc/CureDeaf()
	disabilities &= ~DEAF

// Epilepsy

/mob/living/proc/BecomeEpilepsy()
	disabilities |= EPILEPSY

/mob/living/proc/CureEpilepsy()
	disabilities &= ~EPILEPSY

// Mute

/mob/living/proc/BecomeMute()
	disabilities |= MUTE

/mob/living/proc/CureMute()
	disabilities &= ~MUTE

// Nearsighted

/mob/living/proc/BecomeNearsighted()
	var/val_change = !(disabilities & NEARSIGHTED)
	disabilities |= NEARSIGHTED
	if(val_change)
		update_nearsighted_effects()

/mob/living/proc/CureNearsighted()
	var/val_change = !!(disabilities & NEARSIGHTED)
	disabilities &= ~NEARSIGHTED
	if(val_change)
		update_nearsighted_effects()

// Nervous

/mob/living/proc/BecomeNervous()
	disabilities |= NERVOUS

/mob/living/proc/CureNervous()
	disabilities &= ~NERVOUS

// Tourettes

/mob/living/proc/BecomeTourettes()
	disabilities |= TOURETTES

/mob/living/proc/CureTourettes()
	disabilities &= ~TOURETTES
