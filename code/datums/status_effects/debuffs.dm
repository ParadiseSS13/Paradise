//OTHER DEBUFFS

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes
	id = "cult_ghost"
	duration = -1
	alert_type = null

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent("holywater") //can't be deconverted

/datum/status_effect/crusher_mark
	id = "crusher_mark"
	duration = 300 //if you leave for 30 seconds you lose the mark, deal with it
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/mutable_appearance/marked_underlay
	var/obj/item/twohanded/kinetic_crusher/hammer_synced

/datum/status_effect/crusher_mark/on_creation(mob/living/new_owner, obj/item/twohanded/kinetic_crusher/new_hammer_synced)
	. = ..()
	if(.)
		hammer_synced = new_hammer_synced

/datum/status_effect/crusher_mark/on_apply()
	if(owner.mob_size >= MOB_SIZE_LARGE)
		marked_underlay = mutable_appearance('icons/effects/effects.dmi', "shield2")
		marked_underlay.pixel_x = -owner.pixel_x
		marked_underlay.pixel_y = -owner.pixel_y
		owner.underlays += marked_underlay
		return TRUE
	return FALSE

/datum/status_effect/crusher_mark/Destroy()
	hammer_synced = null
	if(owner)
		owner.underlays -= marked_underlay
	QDEL_NULL(marked_underlay)
	return ..()

/datum/status_effect/crusher_mark/be_replaced()
	owner.underlays -= marked_underlay //if this is being called, we should have an owner at this point.
	..()


/datum/status_effect/pacifism
	id = "pacifism_debuff"
	alert_type = null
	duration = 40 SECONDS


/datum/status_effect/pacifism/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	return ..()


/datum/status_effect/pacifism/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, id)


/datum/status_effect/shadow_boxing
	id = "shadow barrage"
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 0.4 SECONDS
	var/damage = 8
	var/source_UID


/datum/status_effect/shadow_boxing/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()


/datum/status_effect/shadow_boxing/tick()
	var/mob/living/attacker = locateUID(source_UID)
	if(attacker in view(owner, 2))
		attacker.do_attack_animation(owner, ATTACK_EFFECT_PUNCH)
		owner.apply_damage(damage, BRUTE)
		shadow_to_animation(get_turf(attacker), get_turf(owner), attacker)


/datum/status_effect/saw_bleed
	id = "saw_bleed"
	duration = -1 //removed under specific conditions
	tick_interval = 6
	alert_type = null
	var/mutable_appearance/bleed_overlay
	var/mutable_appearance/bleed_underlay
	var/bleed_amount = 3
	var/bleed_buildup = 3
	var/delay_before_decay = 5
	var/bleed_damage = 200
	var/needs_to_bleed = FALSE

/datum/status_effect/saw_bleed/Destroy()
	if(owner)
		owner.cut_overlay(bleed_overlay)
		owner.underlays -= bleed_underlay
	QDEL_NULL(bleed_overlay)
	return ..()

/datum/status_effect/saw_bleed/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	bleed_overlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	bleed_underlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	var/icon_height = I.Height()
	bleed_overlay.pixel_x = -owner.pixel_x
	bleed_overlay.pixel_y = FLOOR(icon_height * 0.25, 1)
	bleed_overlay.transform = matrix() * (icon_height/world.icon_size) //scale the bleed overlay's size based on the target's icon size
	bleed_underlay.pixel_x = -owner.pixel_x
	bleed_underlay.transform = matrix() * (icon_height/world.icon_size) * 3
	bleed_underlay.alpha = 40
	owner.add_overlay(bleed_overlay)
	owner.underlays += bleed_underlay
	return ..()

/datum/status_effect/saw_bleed/tick()
	if(owner.stat == DEAD)
		qdel(src)
	else
		add_bleed(-1)

/datum/status_effect/saw_bleed/proc/add_bleed(amount)
	owner.cut_overlay(bleed_overlay)
	owner.underlays -= bleed_underlay
	bleed_amount += amount
	if(bleed_amount)
		if(bleed_amount >= 10)
			needs_to_bleed = TRUE
			qdel(src)
		else
			if(amount > 0)
				tick_interval += delay_before_decay
			bleed_overlay.icon_state = "bleed[bleed_amount]"
			bleed_underlay.icon_state = "bleed[bleed_amount]"
			owner.add_overlay(bleed_overlay)
			owner.underlays += bleed_underlay
	else
		qdel(src)

/datum/status_effect/saw_bleed/on_remove()
	if(needs_to_bleed)
		var/turf/T = get_turf(owner)
		new /obj/effect/temp_visual/bleed/explode(T)
		for(var/d in GLOB.alldirs)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(T, d)
		playsound(T, "desceration", 200, 1, -1)
		owner.adjustBruteLoss(bleed_damage)
	else
		new /obj/effect/temp_visual/bleed(get_turf(owner))

/datum/status_effect/stamina_dot
	id = "stamina_dot"
	duration = 130
	alert_type = null

/datum/status_effect/stamina_dot/tick()
	owner.adjustStaminaLoss(10)

/datum/status_effect/bluespace_slowdown
	id = "bluespace_slowdown"
	duration = 150
	alert_type = null

/datum/status_effect/bluespace_slowdown/on_apply()
	owner.next_move_modifier *= 2
	return ..()

/datum/status_effect/bluespace_slowdown/on_remove()
	owner.next_move_modifier /= 2

// start of `living` level status procs.

/**
 * # Confusion
 *
 * Prevents moving straight, sometimes changing movement direction at random.
 * Decays at a rate of 1 per second.
 */
/datum/status_effect/transient/confusion
	id = "confusion"
	var/image/overlay

/datum/status_effect/transient/confusion/tick()
	. = ..()
	if(!.)
		return
	if(!owner.stat) //add or remove the overlay if they are alive or unconscious/dead
		add_overlay()
	else if(overlay)
		owner.cut_overlay(overlay)
		overlay = null

/datum/status_effect/transient/confusion/proc/add_overlay()
	if(overlay)
		return
	var/matrix/M = matrix()
	M.Scale(0.6)
	overlay = image('icons/effects/effects.dmi', "confusion", pixel_y = 20)
	overlay.transform = M
	owner.add_overlay(overlay)

/datum/status_effect/transient/confusion/on_remove()
	owner.cut_overlay(overlay)
	overlay = null
	return ..()

/**
 * # Dizziness
 *
 * Slightly offsets the client's screen randomly every tick.
 * Decays at a rate of 1 per second, or 5 when resting.
 */
/datum/status_effect/transient/dizziness
	id = "dizziness"
	var/px_diff = 0
	var/py_diff = 0

/datum/status_effect/transient/dizziness/on_remove()
	if(owner.client)
		// smoothly back to normal
		animate(owner.client, 0.2 SECONDS, pixel_x = -px_diff, pixel_y = -py_diff, flags = ANIMATION_PARALLEL)
	return ..()

/datum/status_effect/transient/dizziness/tick()
	. = ..()
	if(!.)
		return
	var/dir = sin(world.time)
	var/amplitude = min(strength * 0.02, 32)
	px_diff = cos(world.time * 3) * amplitude * dir
	py_diff = sin(world.time * 3) * amplitude * dir
	owner.client?.pixel_x = px_diff
	owner.client?.pixel_y = py_diff

/datum/status_effect/transient/dizziness/calc_decay()
	return (-0.2 + (owner.resting ? -0.8 : 0)) SECONDS

/**
 * # Drowsiness
 *
 * Slows down and causes eye blur, with a 5% chance of falling asleep for a short time.
 * Decays at a rate of 1 per second, or 5 when resting.
 */
/datum/status_effect/transient/drowsiness
	id = "drowsiness"

/datum/status_effect/transient/drowsiness/tick()
	. = ..()
	if(!.)
		return
	owner.EyeBlurry(4 SECONDS)
	if(prob(1))
		owner.AdjustSleeping(2 SECONDS)
		owner.Paralyse(10 SECONDS)

/datum/status_effect/transient/drowsiness/calc_decay()
	return (-0.2 + (owner.resting ? -0.8 : 0)) SECONDS

/**
 * # Drukenness
 *
 * Causes a myriad of status effects and other afflictions the stronger it is.
 * Decays at a rate of 1 per second if no alcohol remains inside.
 */
/datum/status_effect/transient/drunkenness
	id = "drunkenness"
	var/alert_thrown = FALSE

// the number of seconds of the status effect required for each effect to kick in.
#define THRESHOLD_SLUR 60 SECONDS
#define THRESHOLD_BRAWLING 60 SECONDS
#define THRESHOLD_CONFUSION 80 SECONDS
#define THRESHOLD_SPARK 100 SECONDS
#define THRESHOLD_VOMIT 120 SECONDS
#define THRESHOLD_BLUR 150 SECONDS
#define THRESHOLD_COLLAPSE 150 SECONDS
#define THRESHOLD_FAINT 180 SECONDS
#define THRESHOLD_BRAIN_DAMAGE 240 SECONDS
#define DRUNK_BRAWLING /datum/martial_art/drunk_brawling

/datum/status_effect/transient/drunkenness/on_remove()
	if(alert_thrown)
		alert_thrown = FALSE
		owner.clear_alert("drunk")
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE
	return ..()

/datum/status_effect/transient/drunkenness/tick()
	. = ..()
	if(!.)
		return

	// Adjust actual drunkenness based organ presence
	var/actual_strength = strength
	var/datum/mind/M = owner.mind
	var/is_ipc = ismachineperson(owner)

	var/obj/item/organ/internal/liver/L
	if(!is_ipc)
		L = owner.get_int_organ(/obj/item/organ/internal/liver)
		var/liver_multiplier = 5 // no liver? get shitfaced
		if(L)
			liver_multiplier = L.alcohol_intensity
		actual_strength *= liver_multiplier

	// THRESHOLD_SLUR (60 SECONDS)
	if(actual_strength >= THRESHOLD_SLUR)
		owner.Slur(actual_strength)
		if(!alert_thrown)
			alert_thrown = TRUE
			owner.throw_alert("drunk", /obj/screen/alert/drunk)
			owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	// THRESHOLD_BRAWLING (60 SECONDS)
	if(M)
		if(actual_strength >= THRESHOLD_BRAWLING)
			if(!istype(M.martial_art, DRUNK_BRAWLING))
				var/datum/martial_art/MA = new
				MA.teach(owner, TRUE)
		else if(istype(M.martial_art, DRUNK_BRAWLING))
			M.martial_art.remove(src)
	// THRESHOLD_CONFUSION (80 SECONDS)
	if(actual_strength >= THRESHOLD_CONFUSION && prob(0.66))
		owner.AdjustConfused(6 SECONDS, bound_lower = 2 SECONDS, bound_upper = 1 MINUTES)
	// THRESHOLD_SPARK (100 SECONDS)
	if(is_ipc && actual_strength >= THRESHOLD_SPARK && prob(0.5))
		do_sparks(3, 1, owner)
	// THRESHOLD_VOMIT (120 SECONDS)
	if(!is_ipc && actual_strength >= THRESHOLD_VOMIT && prob(0.2))
		owner.fakevomit()
	// THRESHOLD_BLUR (150 SECONDS)
	if(actual_strength >= THRESHOLD_BLUR)
		owner.EyeBlurry(20 SECONDS)
	// THRESHOLD_COLLAPSE (150 SECONDS)
	if(actual_strength >= THRESHOLD_COLLAPSE && prob(0.2))
		owner.emote("collapse")
		do_sparks(3, 1, src)
	// THRESHOLD_FAINT (180 SECONDS)
	if(actual_strength >= THRESHOLD_FAINT && prob(0.2))
		owner.Paralyse(10 SECONDS)
		owner.Drowsy(60 SECONDS)
		if(L)
			L.receive_damage(1, TRUE)
		if(!is_ipc)
			owner.adjustToxLoss(1)
	// THRESHOLD_BRAIN_DAMAGE (240 SECONDS)
	if(actual_strength >= THRESHOLD_BRAIN_DAMAGE && prob(1))
		owner.adjustBrainLoss(1)

#undef THRESHOLD_SLUR
#undef THRESHOLD_BRAWLING
#undef THRESHOLD_CONFUSION
#undef THRESHOLD_SPARK
#undef THRESHOLD_VOMIT
#undef THRESHOLD_BLUR
#undef THRESHOLD_COLLAPSE
#undef THRESHOLD_FAINT
#undef THRESHOLD_BRAIN_DAMAGE
#undef DRUNK_BRAWLING

/datum/status_effect/transient/drunkenness/calc_decay()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.has_booze())
			return 0
	return -0.2 SECONDS

/datum/status_effect/transient/cult_slurring
	id = "cult_slurring"

/datum/status_effect/transient/clock_cult_slurring
	id = "clock_cult_slurring"

/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		if(ishuman(new_owner))
			var/mob/living/carbon/human/H = new_owner
			set_duration = H.dna.species.spec_stun(H, set_duration)
		duration = set_duration
	if(!duration)
		return FALSE
	. = ..()
	if(. && (needs_update_stat || issilicon(owner)))
		owner.update_stat()
	owner.update_canmove()


/datum/status_effect/incapacitating/on_remove()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()
	owner.update_canmove()
	return ..()

//STUN - prevents movement and actions, victim stays standing
/datum/status_effect/incapacitating/stun
	id = "stun"

//IMMOBILIZED - prevents movement, victim can still stand and act
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

//WEAKENED - prevents movement and action, victim falls over
/datum/status_effect/incapacitating/weakened
	id = "weakened"

//PARALYZED - prevents movement and action, victim falls over, victim cannot hear or see.
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"
	needs_update_stat = TRUE

//SLEEPING - victim falls over, cannot act, cannot see or hear, heals under certain conditions.
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	tick_interval = 2 SECONDS
	needs_update_stat = TRUE

/datum/status_effect/incapacitating/sleeping/tick()
	if(!iscarbon(owner))
		return

	var/mob/living/carbon/dreamer = owner

	if(isvampire(dreamer))
		if(istype(dreamer.loc, /obj/structure/closet/coffin))
			dreamer.adjustBruteLoss(-1, FALSE)
			dreamer.adjustFireLoss(-1, FALSE)
			dreamer.adjustToxLoss(-1)
	dreamer.handle_dreams()
	dreamer.adjustStaminaLoss(-10)
	var/comfort = 1
	if(istype(dreamer.buckled, /obj/structure/bed))
		var/obj/structure/bed/bed = dreamer.buckled
		comfort += bed.comfort
	for(var/obj/item/bedsheet/bedsheet in range(dreamer.loc,0))
		if(bedsheet.loc != dreamer.loc) //bedsheets in your backpack/neck don't give you comfort
			continue
		comfort += bedsheet.comfort
		break //Only count the first bedsheet
	if(dreamer.get_drunkenness() > 0)
		comfort += 1 //Aren't naps SO much better when drunk?
		dreamer.AdjustDrunk(-0.4 SECONDS * comfort) //reduce drunkenness while sleeping.
	if(comfort > 1 && prob(3))//You don't heal if you're just sleeping on the floor without a blanket.
		dreamer.adjustBruteLoss(-1 * comfort, FALSE)
		dreamer.adjustFireLoss(-1 * comfort)
	if(prob(10) && dreamer.health)
		dreamer.emote("snore")


//SLOWED - slows down the victim for a duration and a given slowdown value.
/datum/status_effect/incapacitating/slowed
	id = "slowed"
	var/slowdown_value = 10 // defaults to this value if none is specified

/datum/status_effect/incapacitating/slowed/on_creation(mob/living/new_owner, set_duration, _slowdown_value)
	. = ..()
	if(isnum(_slowdown_value))
		slowdown_value = _slowdown_value

/datum/status_effect/transient/silence
	id = "silenced"

/datum/status_effect/transient/silence/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_MUTE, id)

/datum/status_effect/transient/silence/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_MUTE, id)

/datum/status_effect/transient/jittery
	id = "jittering"

/datum/status_effect/transient/jittery/on_apply()
	. = ..()
	owner.do_jitter_animation(strength / 20, 1)

/datum/status_effect/transient/jittery/tick()
	. = ..()
	if(!.)
		return
	owner.do_jitter_animation(strength / 20, 1)

/datum/status_effect/transient/jittery/calc_decay()
	return (-0.2 + (owner.resting ? -0.8 : 0)) SECONDS

/datum/status_effect/transient/stammering
	id = "stammer"

/datum/status_effect/transient/slurring
	id = "slurring"

/datum/status_effect/transient/lose_breath
	id = "lose_breath"

#define HALLUCINATE_COOLDOWN_MIN 20 SECONDS
#define HALLUCINATE_COOLDOWN_MAX 50 SECONDS
/// This is multiplied with [/mob/var/hallucination] to determine the final cooldown. A higher hallucination value means shorter cooldown.
#define HALLUCINATE_COOLDOWN_FACTOR 0.003
/// Percentage defining the chance at which an hallucination may spawn past the cooldown.
#define HALLUCINATE_CHANCE 20
// Severity weights, should sum up to 100!
#define HALLUCINATE_MINOR_WEIGHT 60
#define HALLUCINATE_MODERATE_WEIGHT 25
#define HALLUCINATE_MAJOR_WEIGHT 15

/datum/status_effect/transient/hallucination
	id = "hallucination"
	var/next_hallucination = 0

/datum/status_effect/transient/hallucination/tick()
	. = ..()
	if(!.)
		return

	if(!iscarbon(owner))
		return

	if(next_hallucination > world.time)
		return

	next_hallucination = world.time + rand(HALLUCINATE_COOLDOWN_MIN, HALLUCINATE_COOLDOWN_MAX) / (strength * HALLUCINATE_COOLDOWN_FACTOR)
	if(!prob(HALLUCINATE_CHANCE))
		return

	// Pick a severity
	var/list/severity = list()
	switch(rand(100))
		if(0 to HALLUCINATE_MINOR_WEIGHT)
			severity = GLOB.minor_hallutinations.Copy()
		if((HALLUCINATE_MINOR_WEIGHT + 1) to (HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT))
			severity = GLOB.medium_hallutinations.Copy()
		if((HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT + 1) to 100)
			severity = GLOB.major_hallutinations.Copy()

	owner.hallucinate_living(pickweight(severity))

#undef HALLUCINATE_COOLDOWN_MIN
#undef HALLUCINATE_COOLDOWN_MAX
#undef HALLUCINATE_COOLDOWN_FACTOR
#undef HALLUCINATE_CHANCE
#undef HALLUCINATE_MINOR_WEIGHT
#undef HALLUCINATE_MODERATE_WEIGHT
#undef HALLUCINATE_MAJOR_WEIGHT

/datum/status_effect/transient/eye_blurry
	id = "eye_blurry"

/datum/status_effect/transient/eye_blurry/on_apply()
	owner.update_blurry_effects()
	. = ..()

/datum/status_effect/transient/eye_blurry/on_remove()
	owner.update_blurry_effects()

/datum/status_effect/transient/eye_blurry/calc_decay()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner

		if(isnull(H.dna.species.vision_organ)) //species has no eyes
			return ..()

		var/obj/item/organ/vision = H.get_int_organ(H.dna.species.vision_organ)

		if(!vision || vision.is_bruised() || vision.is_broken()) // doesn't decay if you have damaged eyesight.
			return 0

		if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/blindfold)) // decays faster if you rest your eyes with a blindfold.
			return -1 SECONDS
	return ..() //default decay rate


/datum/status_effect/transient/blindness
	id = "blindness"

/datum/status_effect/transient/blindness/on_apply()
	. = ..()
	owner.update_blind_effects()

/datum/status_effect/transient/blindness/on_remove()
	owner.update_blind_effects()

/datum/status_effect/transient/blindness/calc_decay()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if((BLINDNESS in H.mutations))
			return 0

		if(isnull(H.dna.species.vision_organ)) // species that have no eyes
			return ..()

		var/obj/item/organ/vision = H.get_int_organ(H.dna.species.vision_organ)

		if(!vision || vision.is_broken() || vision.is_bruised()) //got no eyes or broken eyes
			return 0

	return ..() //default decay rate

/datum/status_effect/transient/drugged
	id = "drugged"

/datum/status_effect/transient/drugged/on_apply()
	. = ..()
	owner.update_druggy_effects()

/datum/status_effect/transient/drugged/on_remove()
	owner.update_druggy_effects()

/datum/status_effect/transient/disgust
	id = "disgust"
	tick_interval = 2 SECONDS

/datum/status_effect/transient/disgust/tick()
	. = ..()

	if(!.)
		return

	if(!iscarbon(owner))
		return

	var/mob/living/carbon/carbon = owner
	if(strength >= DISGUST_LEVEL_GROSS)
		if(prob(10))
			carbon.AdjustStuttering(4 SECONDS)
			carbon.AdjustConfused(6 SECONDS)
		if(prob(10) && !carbon.stat)
			to_chat(carbon, "<span class='warning'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>")
		carbon.Jitter(9 SECONDS)
	if(strength >= DISGUST_LEVEL_VERYGROSS)
		var/pukeprob = 5 + 0.005 * strength
		if(prob(pukeprob))
			carbon.AdjustConfused(9 SECONDS)
			carbon.AdjustStuttering(3 SECONDS)
			carbon.vomit(15, FALSE, TRUE, 0, FALSE)
		carbon.Dizzy(15 SECONDS)
	if(strength >= DISGUST_LEVEL_DISGUSTED)
		if(prob(25))
			carbon.AdjustEyeBlurry(9 SECONDS)
	carbon.update_disgust_alert()

/datum/status_effect/transient/disgust/on_apply()
	. = ..()
	owner.update_disgust_alert()

/datum/status_effect/transient/disgust/on_remove()
	owner.update_disgust_alert()

/datum/status_effect/transient/disgust/calc_decay()
	return -1 * initial(tick_interval)

/datum/status_effect/transient/deaf
	id = "deafened"

/datum/status_effect/transient/deaf/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/datum/status_effect/transient/deaf/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
