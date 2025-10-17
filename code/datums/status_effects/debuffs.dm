//OTHER DEBUFFS

/// does minor damage over time unless holding His Grace
/datum/status_effect/his_wrath
	id = "his_wrath"
	tick_interval = 4
	alert_type = /atom/movable/screen/alert/status_effect/his_wrath

/atom/movable/screen/alert/status_effect/his_wrath
	name = "His Wrath"
	desc = "You fled from His Grace instead of feeding Him, and now you suffer."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/datum/status_effect/his_wrath/tick()
	var/list/held_items = list()
	held_items += owner.l_hand
	held_items += owner.r_hand
	for(var/obj/item/his_grace/HG in held_items)
		qdel(src)
		return
	owner.adjustBruteLoss(0.1)
	owner.adjustFireLoss(0.1)
	owner.adjustToxLoss(0.2)

/// is a cult ghost and can't use manifest runes, can see ghosts and dies if too far from summoner
/datum/status_effect/cultghost
	id = "cult_ghost"
	alert_type = null
	var/damage = 7.5
	var/source_UID

/datum/status_effect/cultghost/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent("holywater") //can't be deconverted
	var/mob/living/summoner = locateUID(source_UID)
	if(get_dist_euclidian(summoner, owner) < 21)
		return
	owner.adjustBruteLoss(damage)
	to_chat(owner, "<span class='userdanger'>You are too far away from the summoner!</span>")

/datum/status_effect/crusher_mark
	id = "crusher_mark"
	duration = 300 //if you leave for 30 seconds you lose the mark, deal with it
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/mutable_appearance/marked_underlay
	var/obj/item/kinetic_crusher/hammer_synced

/datum/status_effect/crusher_mark/on_creation(mob/living/new_owner, obj/item/kinetic_crusher/new_hammer_synced)
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

/datum/status_effect/saw_bleed
	id = "saw_bleed"
	tick_interval = 6
	alert_type = null
	var/mutable_appearance/bleed_overlay
	var/mutable_appearance/bleed_underlay
	var/bleed_amount = 3
	var/bleed_buildup = 3
	var/delay_before_decay = 5
	var/bleed_damage = 200
	var/needs_to_bleed = FALSE
	var/bleed_cap = 10

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
		if(bleed_amount >= bleed_cap)
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
		playsound(T, "desceration", 200, TRUE, -1)
		owner.adjustBruteLoss(bleed_damage)
	else
		new /obj/effect/temp_visual/bleed(get_turf(owner))

/datum/status_effect/saw_bleed/bloodletting
	id = "bloodletting"
	bleed_cap = 7
	bleed_damage = 25 //Seems weak (it is) but it also works on humans and bypasses armor SOOOO
	bleed_amount = 6

/datum/status_effect/stacking/ground_pound
	id = "ground_pound"
	tick_interval = 5 SECONDS
	stack_threshold = 3
	max_stacks = 3
	reset_ticks_on_stack = TRUE
	var/mob/living/basic/mining/big_legion/latest_attacker

/datum/status_effect/stacking/ground_pound/on_creation(mob/living/new_owner, stacks_to_apply, mob/living/attacker)
	. = ..()
	if(.)
		latest_attacker = attacker

/datum/status_effect/stacking/ground_pound/add_stacks(stacks_added, mob/living/attacker)
	. = ..()
	if(.)
		latest_attacker = attacker
	if(stacks != stack_threshold)
		return TRUE

/datum/status_effect/stacking/ground_pound/stacks_consumed_effect()
	flick("legion-smash", latest_attacker)
	addtimer(CALLBACK(latest_attacker, TYPE_PROC_REF(/mob/living/basic/mining/big_legion, throw_mobs)), 1 SECONDS)

/datum/status_effect/stacking/ground_pound/on_remove()
	latest_attacker = null

/datum/status_effect/teleport_sickness
	id = "teleportation sickness"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/teleport_sickness
	var/teleports = 1

/atom/movable/screen/alert/status_effect/teleport_sickness
	name = "Teleportation sickness"
	desc = "You feel like you are going to throw up with all this teleporting."
	icon_state = "bluespace"

/datum/status_effect/teleport_sickness/refresh()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/M = owner
		teleports++
		if(teleports < 3)
			return
		if(teleports < 6)
			to_chat(M, "<span class='warning'>You feel a bit sick!</span>")
			M.vomit(lost_nutrition = 15, blood = 0, should_confuse = FALSE, distance = 0, message = 1)
			M.Weaken(2 SECONDS)
		else
			to_chat(M, "<span class='danger'>You feel really sick!</span>")
			M.adjustBruteLoss(rand(0, teleports * 2))
			M.vomit(lost_nutrition = 30, blood = 0, should_confuse = FALSE, distance = 0, message = 1)
			M.Weaken(6 SECONDS)

/datum/status_effect/pacifism
	id = "pacifism_debuff"
	alert_type = null
	duration = 40 SECONDS

/datum/status_effect/pacifism/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	return ..()

/datum/status_effect/pacifism/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, id)

/datum/status_effect/pacifism/batterer
	id = "pacifism_debuff_batterer"
	alert_type = null
	duration = 10 SECONDS

// used to track if hitting someone with a cult dagger/sword should stamina crit.
/datum/status_effect/cult_stun_mark
	id = "cult_stun"
	duration = 10 SECONDS // when the knockdown ends, the mark disappears.
	alert_type = null
	var/mutable_appearance/overlay

/datum/status_effect/cult_stun_mark/on_apply()
	. = ..()
	if(!isliving(owner))
		return
	overlay = mutable_appearance('icons/effects/cult_effects.dmi', "cult-mark", ABOVE_MOB_LAYER)
	owner.add_overlay(overlay)

/datum/status_effect/cult_stun_mark/on_remove()
	owner.cut_overlay(overlay)

/datum/status_effect/cult_stun_mark/proc/trigger()
	owner.apply_damage(60, STAMINA)
	owner.Silence(6 SECONDS) // refresh the silence
	qdel(src)

/datum/status_effect/bluespace_slowdown
	id = "bluespace_slowdown"
	alert_type = null
	duration = 15 SECONDS

/datum/status_effect/bluespace_slowdown/on_apply()
	owner.next_move_modifier *= 2
	return ..()

/datum/status_effect/bluespace_slowdown/on_remove()
	owner.next_move_modifier /= 2

/datum/status_effect/bluespace_slowdown/long
	duration = 1 MINUTES

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

/datum/status_effect/cling_tentacle
	id = "cling_tentacle"
	alert_type = null
	duration = 3 SECONDS

/datum/status_effect/cling_tentacle/on_apply()
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")
	return ..()

/datum/status_effect/cling_tentacle/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")

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
	var/amplitude = min(strength * 0.003, 32)
	px_diff = cos(world.time * 3) * amplitude * dir
	py_diff = sin(world.time * 3) * amplitude * dir
	owner.client?.pixel_x = px_diff
	owner.client?.pixel_y = py_diff

/datum/status_effect/transient/dizziness/calc_decay()
	return (-0.2 + (IS_HORIZONTAL(owner) ? -0.8 : 0)) SECONDS

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
	if(prob(0.5))
		owner.AdjustSleeping(2 SECONDS)
		owner.Paralyse(10 SECONDS)

/datum/status_effect/transient/drowsiness/calc_decay()
	return (-0.2 + (IS_HORIZONTAL(owner) ? -0.8 : 0)) SECONDS

/datum/status_effect/pepper_spray
	id = "pepperspray"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = -1
	alert_type = null

/datum/status_effect/pepper_spray/on_apply()
	. = ..()
	to_chat(owner, "<span class='danger'>Your throat burns!</span>")
	owner.AdjustConfused(12 SECONDS, bound_upper = 20 SECONDS)
	owner.Slowed(4 SECONDS)
	owner.apply_damage(40, STAMINA)

/datum/status_effect/pepper_spray/refresh()
	. = ..()
	owner.AdjustConfused(12 SECONDS, bound_upper = 20 SECONDS)
	owner.Slowed(4 SECONDS)
	owner.apply_damage(20, STAMINA)

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
	if(owner.mind && istype(owner.mind.martial_art, DRUNK_BRAWLING))
		owner.mind.martial_art.remove(owner)
	return ..()

/datum/status_effect/transient/drunkenness/tick()
	. = ..()
	if(!.)
		return

	// Adjust actual drunkenness based on trait and organ presence
	var/alcohol_resistance = 1
	var/actual_strength = strength
	var/datum/mind/M = owner.mind
	var/is_robot = ismachineperson(owner) || issilicon(owner)

	if(HAS_TRAIT(owner, TRAIT_ALCOHOL_TOLERANCE))
		alcohol_resistance = 2

	actual_strength /= alcohol_resistance

	var/obj/item/organ/internal/liver/L
	if(!is_robot)
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
			owner.throw_alert("drunk", /atom/movable/screen/alert/drunk)
			owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	// THRESHOLD_BRAWLING (60 SECONDS)
	if(M)
		if(actual_strength >= THRESHOLD_BRAWLING)
			if(!istype(M.martial_art, DRUNK_BRAWLING))
				var/datum/martial_art/drunk_brawling/MA = new
				MA.teach(owner, TRUE)
		else if(istype(M.martial_art, DRUNK_BRAWLING))
			M.martial_art.remove(owner)
	// THRESHOLD_CONFUSION (80 SECONDS)
	if(actual_strength >= THRESHOLD_CONFUSION && prob(0.33))
		owner.AdjustConfused(6 SECONDS / alcohol_resistance, bound_lower = 2 SECONDS, bound_upper = 1 MINUTES)
	// THRESHOLD_SPARK (100 SECONDS)
	if(is_robot && actual_strength >= THRESHOLD_SPARK && prob(0.25))
		do_sparks(3, 1, owner)
	// THRESHOLD_VOMIT (120 SECONDS)
	if(!is_robot && actual_strength >= THRESHOLD_VOMIT && prob(0.08))
		owner.fakevomit()
	// THRESHOLD_BLUR (150 SECONDS)
	if(actual_strength >= THRESHOLD_BLUR)
		owner.EyeBlurry(20 SECONDS / alcohol_resistance)
	// THRESHOLD_COLLAPSE (150 SECONDS)
	if(actual_strength >= THRESHOLD_COLLAPSE && prob(0.1))
		owner.emote("collapse")
		do_sparks(3, 1, src)
	// THRESHOLD_FAINT (180 SECONDS)
	if(actual_strength >= THRESHOLD_FAINT && prob(0.1))
		owner.Paralyse(10 SECONDS / alcohol_resistance)
		owner.Drowsy(60 SECONDS / alcohol_resistance)
		if(L)
			L.receive_damage(1, TRUE)
		if(!is_robot)
			owner.adjustToxLoss(1)
	// THRESHOLD_BRAIN_DAMAGE (240 SECONDS)
	if(actual_strength >= THRESHOLD_BRAIN_DAMAGE && prob(0.1))
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

/datum/status_effect/incapacitating
	id = "incapacitating"
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


/datum/status_effect/incapacitating/on_remove()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates
		owner.update_stat()
	return ..()

//FLOORED - forces the victim prone.
/datum/status_effect/incapacitating/floored
	id = "floored"

/datum/status_effect/incapacitating/floored/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_FLOORED, "[id]")

/datum/status_effect/incapacitating/floored/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FLOORED, "[id]")
	return ..()


//STUN - prevents movement and actions, victim stays standing
/datum/status_effect/incapacitating/stun
	id = "stun"

/datum/status_effect/incapacitating/stun/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, "[id]")

/datum/status_effect/incapacitating/stun/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, "[id]")
	return ..()

//IMMOBILIZED - prevents movement, victim can still stand and act
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

/datum/status_effect/incapacitating/immobilized/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")

/datum/status_effect/incapacitating/immobilized/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")
	return ..()

//WEAKENED - prevents movement and action, victim falls over
/datum/status_effect/incapacitating/weakened
	id = "weakened"

/datum/status_effect/incapacitating/weakened/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")
	ADD_TRAIT(owner, TRAIT_FLOORED, "[id]")
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, "[id]")

/datum/status_effect/incapacitating/weakened/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, "[id]")
	REMOVE_TRAIT(owner, TRAIT_FLOORED, "[id]")
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, "[id]")
	return ..()

//PARALYZED - prevents movement and action, victim falls over, victim cannot hear or see.
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"
	needs_update_stat = TRUE

/datum/status_effect/incapacitating/paralyzed/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, "[id]")

/datum/status_effect/incapacitating/paralyzed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, "[id]")
	return ..()

//SLEEPING - victim falls over, cannot act, cannot see or hear, heals under certain conditions.
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	tick_interval = 2 SECONDS
	needs_update_stat = TRUE
	/// Whether we decided to take a nap on our own.
	/// As opposed to being hard knocked out with N2O or similar.
	var/voluntary = FALSE

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, set_duration, voluntary = FALSE)
	..()
	src.voluntary = voluntary

/datum/status_effect/incapacitating/sleeping/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, "[id]")

/datum/status_effect/incapacitating/sleeping/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, "[id]")
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(!iscarbon(owner))
		return

	var/mob/living/carbon/dreamer = owner

	if(dreamer.mind?.has_antag_datum(/datum/antagonist/vampire))
		var/mob/living/carbon/human/V = owner
		if(istype(V.loc, /obj/structure/closet/coffin))
			V.adjustBruteLoss(-1)
			V.adjustFireLoss(-1)
			V.adjustToxLoss(-1)
			V.adjustOxyLoss(-1)
			V.adjustCloneLoss(-0.5)
			if(V.HasDisease(/datum/disease/critical/heart_failure) && prob(25))
				for(var/datum/disease/critical/heart_failure/HF in V.viruses)
					HF.cure()
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
	if(prob(10) && dreamer.health && dreamer.health_hud_override != HEALTH_HUD_OVERRIDE_CRIT)
		dreamer.emote("snore")
	SEND_SIGNAL(owner, COMSIG_MOB_SLEEP_TICK, comfort)


//SLOWED - slows down the victim for a duration and a given slowdown value.
/datum/status_effect/incapacitating/slowed
	id = "slowed"
	var/slowdown_value = 10 // defaults to this value if none is specified

/datum/status_effect/incapacitating/slowed/on_creation(mob/living/new_owner, set_duration, _slowdown_value)
	. = ..()
	if(isnum(_slowdown_value))
		slowdown_value = _slowdown_value

// Directional slow - Like slowed, but only if you're moving in a certain direction.
/datum/status_effect/incapacitating/directional_slow
	id = "directional_slow"
	var/direction
	var/slowdown_value = 10 // defaults to this value if none is specified

/datum/status_effect/incapacitating/directional_slow/on_creation(mob/living/new_owner, set_duration, _direction, _slowdown_value)
	. = ..()
	direction = _direction
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

/// this one will mute all emote sounds including gasps
/datum/status_effect/transient/silence/absolute
	id = "abssilenced"

/datum/status_effect/transient/deaf
	id = "deafened"

/datum/status_effect/transient/deaf/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/datum/status_effect/transient/deaf/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/datum/status_effect/transient/no_oxy_heal
	id = "no_oxy_heal"

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
	return (-0.2 + (IS_HORIZONTAL(owner) ? -0.8 : 0)) SECONDS

/datum/status_effect/transient/stammering
	id = "stammer"

/datum/status_effect/transient/slurring
	id = "slurring"

/datum/status_effect/transient/lose_breath
	id = "lose_breath"

#define HALLUCINATE_COOLDOWN_MIN 20 SECONDS
#define HALLUCINATE_COOLDOWN_MAX 50 SECONDS
/// This is multiplied with [/datum/status_effect/transient/var/strength] to determine the final cooldown. A higher hallucination value means shorter cooldown.
#define HALLUCINATE_COOLDOWN_FACTOR 0.003
/// Percentage defining the chance at which an hallucination may spawn past the cooldown.
#define HALLUCINATE_CHANCE 80
// Severity weights, should sum up to 100!
#define HALLUCINATE_MINOR_WEIGHT 60
#define HALLUCINATE_MODERATE_WEIGHT 30
#define HALLUCINATE_MAJOR_WEIGHT 10

/datum/status_effect/transient/hallucination
	id = "hallucination"
	var/next_hallucination = 0

/datum/status_effect/transient/hallucination/tick()
	. = ..()
	if(!.)
		return

	if(next_hallucination > world.time)
		return

	next_hallucination = world.time + rand(HALLUCINATE_COOLDOWN_MIN, HALLUCINATE_COOLDOWN_MAX) / (strength * HALLUCINATE_COOLDOWN_FACTOR)
	if(!prob(HALLUCINATE_CHANCE))
		return

	// Pick a severity
	var/severity = HALLUCINATE_MINOR
	switch(rand(100))
		if(0 to HALLUCINATE_MINOR_WEIGHT)
			severity = HALLUCINATE_MINOR
		if((HALLUCINATE_MINOR_WEIGHT + 1) to (HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT))
			severity = HALLUCINATE_MODERATE
		if((HALLUCINATE_MINOR_WEIGHT + HALLUCINATE_MODERATE_WEIGHT + 1) to 100)
			severity = HALLUCINATE_MAJOR

	hallucinate(pickweight(GLOB.hallucinations[severity]))


/**
  * Spawns an hallucination for the mob.
  *
  * Arguments:
  * * H - The type path of the hallucination to spawn.
  */
/datum/status_effect/transient/hallucination/proc/hallucinate(hallucination_type)
	ASSERT(ispath(hallucination_type))
	if(owner.ckey)
		add_attack_logs(null, owner, "Received hallucination [hallucination_type]", ATKLOG_ALL)
	return new hallucination_type(get_turf(owner), owner)

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
		if(HAS_TRAIT(owner, TRAIT_BLIND))
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

#define FAKE_COLD 1
#define FAKE_FOOD_POISONING 2
#define FAKE_RETRO_VIRUS 3
#define FAKE_TURBERCULOSIS 4
#define FAKE_BRAINROT 5

/datum/status_effect/fake_virus
	id = "fake_virus"
	duration = 3 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 2
	alert_type = null
	/// So you dont get the most intense messages immediately
	var/msg_stage = 0
	/// Which disease we are going to fake?
	var/current_fake_disease
	/// Fake virus messages by with three stages
	var/list/fake_msg
	/// Fake virus emotes with three stages
	var/list/fake_emote

/datum/status_effect/fake_virus/on_creation()
	current_fake_disease = pick(FAKE_COLD, FAKE_FOOD_POISONING, FAKE_RETRO_VIRUS, FAKE_TURBERCULOSIS, FAKE_BRAINROT)
	switch(current_fake_disease)
		if(FAKE_COLD)
			fake_msg = list(
						list("<span class='danger'>Your throat feels sore.</span>", "<span class='danger'>Mucous runs down the back of your throat.</span>"),
						list("<span class='danger'>Your muscles ache.</span>", "<span class='danger'>Your stomach hurts.</span>"),
						list("<span class='danger'>Your muscles ache.</span>", "<span class='danger'>Your stomach hurts.</span>")
			)
			fake_emote = list(
						list("sneeze", "cough"),
						list("sneeze", "cough"),
						list("sneeze", "cough")
			)
		if(FAKE_FOOD_POISONING)
			fake_msg = list(
						list("<span class='danger'>Your stomach feels weird.</span>", "<span class='danger'>You feel queasy.</span>"),
						list("<span class='danger'>Your stomach aches.</span>", "<span class='danger'>You feel nauseous.</span>"),
						list("<span class='danger'>Your stomach hurts.</span>", "<span class='danger'>You feel sick.</span>")
			)
			fake_emote = list(
						list(),
						list("groan"),
						list("groan", "moan")
			)
		if(FAKE_RETRO_VIRUS)
			fake_msg = list(
						list("<span class='danger'>Your head hurts.</span>", "You feel a tingling sensation in your chest.", "<span class='danger'>You feel angry.</span>"),
						list("<span class='danger'>Your skin feels loose.</span>", "You feel very strange.", "<span class='danger'>You feel a stabbing pain in your head!</span>", "<span class='danger'>Your stomach churns.</span>"),
						list("<span class='danger'>Your entire body vibrates.</span>")
			)
			fake_emote = list(
						list(),
						list(),
						list()
			)
		if(FAKE_TURBERCULOSIS)
			fake_msg = list(
						list("<span class='danger'>Your chest hurts.</span>", "<span class='danger'>Your stomach violently rumbles!</span>", "<span class='danger'>You feel a cold sweat form.</span>"),
						list("<span class='danger'>You feel a sharp pain from your lower chest!</span>", "<span class='danger'>You feel air escape from your lungs painfully.</span>"),
						list("<span class='danger'>You feel uncomfortably hot...</span>", "<span class='danger'>You feel like unzipping your jumpsuit</span>", "<span class='danger'>You feel like taking off some clothes...</span>")
			)
			fake_emote = list(
						list("cough"),
						list("gasp"),
						list()
			)
		else // FAKE_BRAINROT
			fake_msg = list(
						list("<span class='danger'>You don't feel like yourself.</span>"),
						list("<span class='danger'>Your try to remember something important...but can't.</span>"),
						list("<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
			)
			fake_emote = list(
						list("blink", "yawn"),
						list("stare", "drool"),
						list("stare", "drool")
			)
	. = ..()

/datum/status_effect/fake_virus/tick()
	var/selected_fake_msg
	var/selected_fake_emote
	switch(msg_stage)
		if(0 to 300)
			if(prob(1)) // First stage starts slow, stage 2 and 3 trigger fake msgs/emotes twice as often
				if(prob(50) || !length(fake_emote[1])) // 50% chance to trigger either a msg or emote, 100% if it doesnt have an emote
					selected_fake_msg = safepick(fake_msg[1])
				else
					selected_fake_emote = safepick(fake_emote[1])
		if(301 to 600)
			if(prob(2))
				if(prob(50) || !length(fake_emote[2]))
					selected_fake_msg = safepick(fake_msg[2])
				else
					selected_fake_emote = safepick(fake_emote[2])
		else
			if(prob(2))
				if(prob(50) || !length(fake_emote[3]))
					selected_fake_msg = safepick(fake_msg[3])
				else
					selected_fake_emote = safepick(fake_emote[3])

	if(selected_fake_msg)
		to_chat(owner, selected_fake_msg)
	else if(selected_fake_emote)
		owner.emote(selected_fake_emote)
	msg_stage++

#undef FAKE_COLD
#undef FAKE_FOOD_POISONING
#undef FAKE_RETRO_VIRUS
#undef FAKE_TURBERCULOSIS
#undef FAKE_BRAINROT

/datum/status_effect/cryo_beam
	id = "cryo beam"
	alert_type = null
	tick_interval = 0.5 SECONDS
	var/damage = 0.75
	var/source_UID

/datum/status_effect/cryo_beam/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()

/datum/status_effect/cryo_beam/tick()
	var/mob/living/simple_animal/hostile/megafauna/ancient_robot/attacker = locateUID(source_UID)
	if(!(owner in view(attacker, 8)))
		qdel(src)
		return

	owner.apply_damage(damage, BURN)
	owner.bodytemperature = max(0, owner.bodytemperature - 20)
	owner.Beam(attacker.beam, icon_state = "medbeam", time = 0.5 SECONDS)
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		owner.reagents.remove_reagent(R.id, 0.75)
	if(prob(10))
		to_chat(owner, "<span class='userdanger'>Your blood freezes in your veins, get away!</span>")

/datum/status_effect/bubblegum_curse
	id = "bubblegum curse"
	alert_type = /atom/movable/screen/alert/status_effect/bubblegum_curse
	/// The damage the status effect does per tick.
	var/damage = 0.75
	var/source_UID
	/// Are we starting the process to check if the person has still gotten out of range of bubble / crossed zlvls.
	var/coward_checking = FALSE

/datum/status_effect/bubblegum_curse/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()
	owner.overlay_fullscreen("Bubblegum", /atom/movable/screen/fullscreen/stretch/fog, 1)

/datum/status_effect/bubblegum_curse/tick()
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(!attacker || attacker.loc == null || attacker.stat == DEAD)
		qdel(src)
		return
	if(attacker.health <= attacker.maxHealth / 2)
		owner.clear_fullscreen("Bubblegum")
		owner.overlay_fullscreen("Bubblegum", /atom/movable/screen/fullscreen/stretch/fog, 2)
	if(!coward_checking)
		if(owner.z != attacker.z)
			addtimer(CALLBACK(src, PROC_REF(onstation_coward_callback)), 12 SECONDS)
			coward_checking = TRUE
		else if(get_dist(attacker, owner) >= 25)
			addtimer(CALLBACK(src, PROC_REF(runaway_coward_callback)), 12 SECONDS)
			coward_checking = TRUE

	owner.apply_damage(damage, BRUTE)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.bleed(0.33)
	if(prob(5))
		to_chat(owner, "<span class='userdanger'>[pick("You feel your sins crawling on your back.", "You felt your sins weighing on your neck.", "You feel your blood pulsing inside you.", "<b>YOU'LL NEVER ESCAPE ME</b>", "<b>YOU'LL DIE FOR INSULTING ME LIKE THIS</b>")]</span>")

/datum/status_effect/bubblegum_curse/on_remove()
	owner.clear_fullscreen("Bubblegum")

/datum/status_effect/bubblegum_curse/proc/onstation_coward_callback()
	coward_checking = FALSE
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(owner.z != attacker.z)
		to_chat(owner, "<span class='colossus'><b>YOU CHALLENGE ME LIKE THIS... AND YOU RUN WITH YOUR FALSE MAGICS?</b></span>")
	else
		return
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>REALLY?</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>SUCH INSOLENCE!</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>SO PATHETIC...</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>...SO FOOLISH!</b></span>")
	get_over_here()

/datum/status_effect/bubblegum_curse/proc/runaway_coward_callback()
	coward_checking = FALSE
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(get_dist(attacker, owner) >= 25)
		to_chat(owner, "<span class='colossus'><b>My my, you can run FAST.</b></span>")
	else
		return
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>I thought you wanted a true fight?</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>Perhaps I was mistaken.</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>You are a coward who does not want a fight...</b></span>")
	SLEEP_CHECK_QDEL(2 SECONDS)
	to_chat(owner, "<span class='colossus'><b>...BUT I WANT YOU DEAD!</b></span>")
	get_over_here()

/datum/status_effect/bubblegum_curse/proc/get_over_here()
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(!attacker)
		return //Let's not nullspace
	if(attacker.loc == null)
		return //Extra emergency safety.
	var/turf/TA = get_turf(owner)
	owner.Immobilize(3 SECONDS)
	new /obj/effect/decal/cleanable/blood/bubblegum(TA)
	new /obj/effect/temp_visual/bubblegum_hands/rightsmack(TA)
	sleep(6)
	var/turf/TB = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>[attacker] rends you!</span>")
	playsound(TB, attacker.attack_sound, 100, TRUE, -1)
	owner.adjustBruteLoss(10)
	new /obj/effect/decal/cleanable/blood/bubblegum(TB)
	new /obj/effect/temp_visual/bubblegum_hands/leftsmack(TB)
	sleep(6)
	var/turf/TC = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>[attacker] rends you!</span>")
	playsound(TC, attacker.attack_sound, 100, TRUE, -1)
	owner.adjustBruteLoss(10)
	new /obj/effect/decal/cleanable/blood/bubblegum(TC)
	new /obj/effect/temp_visual/bubblegum_hands/rightsmack(TC)
	sleep(6)
	var/turf/TD = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>[attacker] rends you!</span>")
	playsound(TD, attacker.attack_sound, 100, TRUE, -1)
	owner.adjustBruteLoss(10)
	new /obj/effect/temp_visual/bubblegum_hands/leftpaw(TD)
	new /obj/effect/temp_visual/bubblegum_hands/leftthumb(TD)
	sleep(8)
	to_chat(owner, "<span class='userdanger'>[attacker] drags you through the blood!</span>")
	playsound(TD, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
	var/turf/targetturf = get_step(attacker, attacker.dir)
	owner.forceMove(targetturf)
	playsound(targetturf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	addtimer(CALLBACK(attacker, TYPE_PROC_REF(/mob/living/simple_animal/hostile/megafauna/bubblegum, FindTarget), list(owner), 1), 2)

/atom/movable/screen/alert/status_effect/bubblegum_curse
	name = "I SEE YOU"
	desc = "YOUR SOUL WILL BE MINE FOR YOUR INSOLENCE."
	icon_state = "bubblegumjumpscare"

/atom/movable/screen/alert/status_effect/bubblegum_curse/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/atom/movable/screen/alert/status_effect/bubblegum_curse/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/atom/movable/screen/alert/status_effect/bubblegum_curse/process()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ce3030", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)


/datum/status_effect/abductor_cooldown
	id = "abductor_cooldown"
	alert_type = /atom/movable/screen/alert/status_effect/abductor_cooldown
	duration = 10 SECONDS

/atom/movable/screen/alert/status_effect/abductor_cooldown
	name = "Teleportation cooldown"
	desc = "Per article A-113, all experimentors must wait 10000 milliseconds between teleports in order to ensure no long term genetic or mental damage happens to experimentor or test subjects."
	icon_state = "bluespace"

#define DEFAULT_MAX_CURSE_COUNT 5

/// Status effect that gives the target miscellanous debuffs while throwing a status alert and causing them to smoke from the damage they're incurring.
/// Purposebuilt for cursed slot machines.
/datum/status_effect/cursed
	id = "cursed"
	alert_type = /atom/movable/screen/alert/status_effect/cursed
	/// The max number of curses a target can incur with this status effect.
	var/max_curse_count = DEFAULT_MAX_CURSE_COUNT
	/// The amount of times we have been "applied" to the target.
	var/curse_count = 0
	/// Raw probability we have to deal damage this tick.
	var/damage_chance = 10
	/// Are we currently in the process of sending a monologue?
	var/monologuing = FALSE
	/// The hand we are branded to.
	var/obj/item/organ/external/branded_hand = null

/datum/status_effect/cursed/on_apply()
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(owner, COMSIG_CURSED_SLOT_MACHINE_USE, PROC_REF(check_curses))
	RegisterSignal(owner, COMSIG_CURSED_SLOT_MACHINE_LOST, PROC_REF(update_curse_count))
	RegisterSignal(SSdcs, COMSIG_GLOB_CURSED_SLOT_MACHINE_WON, PROC_REF(clear_curses))
	return ..()

/datum/status_effect/cursed/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CURSED_SLOT_MACHINE_WON)
	branded_hand = null
	return ..()

/// Checks the number of curses we have and returns information back to the slot machine. `max_curse_amount` is set by the slot machine itself.
/datum/status_effect/cursed/proc/check_curses(mob/user, max_curse_amount)
	SIGNAL_HANDLER
	if(curse_count >= max_curse_amount)
		return SLOT_MACHINE_USE_CANCEL

	if(monologuing)
		to_chat(owner, "<span class='warning'>Your arm is resisting your attempts to pull the lever!</span>") // listening to kitschy monologues to postpone your powergaming is the true curse here.
		return SLOT_MACHINE_USE_POSTPONE

/// Handles the debuffs of this status effect and incrementing the number of curses we have.
/datum/status_effect/cursed/proc/update_curse_count()
	SIGNAL_HANDLER
	curse_count++

	linked_alert?.update_appearance() // we may have not initialized it yet

	addtimer(CALLBACK(src, PROC_REF(handle_after_effects), 1 SECONDS)) // give it a second to let the failure sink in before we exact our toll

/// Makes a nice lorey message about the curse level we're at. I think it's nice
/datum/status_effect/cursed/proc/handle_after_effects()
	if(QDELETED(src))
		return

	monologuing = TRUE
	var/list/messages = list()
	switch(curse_count)
		if(1) // basically your first is a "freebie" that will still require urgent medical attention and will leave you smoking forever but could be worse tbh
			if(ishuman(owner))
				var/mob/living/carbon/human/human_owner = owner
				playsound(human_owner, 'sound/weapons/sear.ogg', 50, TRUE)
				var/obj/item/organ/external/affecting = human_owner.get_active_hand()
				branded_hand = affecting

			messages += "<span class='boldwarning'>Your hand burns, and you quickly let go of the lever! You feel a little sick as the nerves deaden in your hand...</span>"
			messages += "<span class='boldwarning'>Some smoke appears to be coming out of your hand now, but it's not too bad...</span>"
			messages += "<span class='boldwarning'>Fucking stupid machine.</span>"

		if(2)
			messages += "<span class='boldwarning'>The machine didn't burn you this time, it must be some arcane work of the brand recognizing a source...</span>"
			messages += "<span class='boldwarning'>Blisters and boils start to appear over your skin. Each one hissing searing hot steam out of its own pocket...</span>"
			messages += "<span class='boldwarning'>You understand that the machine tortures you with its simplistic allure. It can kill you at any moment, but it derives a sick satisfaction at forcing you to keep going.</span>"
			messages += "<span class='boldwarning'>If you could get away from here, you might be able to live with some medical supplies. Is it too late to stop now?</span>"
			messages += "<span class='boldwarning'>As you shut your eyes to dwell on this conundrum, the brand surges in pain. You shudder to think what might happen if you go unconscious.</span>"

		if(3)
			owner.emote("cough")
			messages += "<span class='boldwarning'>Your throat becomes to feel like it's slowly caking up with sand and dust. You eject the contents of the back of your throat onto your sleeve.</span>"
			messages += "<span class='boldwarning'>It is sand. Crimson red. You've never felt so thirsty in your life, yet you don't trust your own hand to carry the glass to your lips.</span>"
			messages += "<span class='boldwarning'>You get the sneaking feeling that if someone else were to win, that it might clear your curse too. Saving your life is a noble cause.</span>"
			messages += "<span class='boldwarning'>Of course, you might have to not speak on the nature of this machine, in case they scamper off to leave you to die.</span>"
			messages += "<span class='boldwarning'>Is it truly worth it to condemn someone to this fate to cure the manifestation of your own hedonistic urges? You'll have to decide quickly.</span>"

		if(4)
			messages += "<span class='boldwarning'>A migraine swells over your head as your thoughts become hazy. Your hand desperately inches closer towards the slot machine for one final pull...</span>"
			messages += "<span class='boldwarning'>The ultimate test of mind over matter. You can jerk your own muscle back in order to prevent a terrible fate, but your life already is worth so little now.</span>"
			messages += "<span class='boldwarning'>This is what they want, is it not? To witness your failure against itself? The compulsion carries you forward as a sinking feeling of dread fills your stomach.</span>"
			messages += "<span class='boldwarning'>Paradoxically, where there is hopelessness, there is elation. Elation at the fact that there's still enough power in you for one more pull.</span>"
			messages += "<span class='boldwarning'>Your legs desperately wish to jolt away on the thought of running away from this wretched machination, but your own arm remains complacent in the thought of seeing spinning wheels.</span>"
			messages += "<span class='userdanger'>The toll has already been exacted. There is no longer death on 'your' terms. Is your dignity worth more than your life?</span>"

		if(5 to INFINITY)
			if(max_curse_count != DEFAULT_MAX_CURSE_COUNT) // this probably will only happen through admin schenanigans letting people stack up infinite curses or something
				to_chat(owner, "<span class='userdanger'>Do you <i>still</i> think you're in control?</span>")
				return

			to_chat(owner, "Why couldn't I get one more try?!")
			owner.gib()
			qdel(src)
			return
	for(var/message in messages)
		to_chat(owner, message)
		sleep(3 SECONDS) // yes yes a bit fast but it can be a lot of text and i want the whole thing to send before the cooldown on the slot machine might expire
	monologuing = FALSE

/// Cleans ourselves up and removes our curses. Meant to be done in a "positive" way, when the curse is broken. Directly use qdel otherwise.
/datum/status_effect/cursed/proc/clear_curses()
	SIGNAL_HANDLER

	owner.visible_message(
		"<span class='warning'>The smoke slowly clears from [owner.name]...</span>",
		"<span class='notice'>Your skin finally settles down and your throat no longer feels as dry... The brand disappearing confirms that the curse has been lifted.</span>",)
	qdel(src)

/// If our owner's stat changes, rapidly surge the damage chance.
/datum/status_effect/cursed/proc/on_stat_changed()
	SIGNAL_HANDLER
	if(owner.stat == CONSCIOUS || owner.stat == DEAD) // reset on these two states
		damage_chance = initial(damage_chance)
		return

	to_chat(owner, "<span class='userdanger'>As your body crumbles, you feel the curse of the slot machine surge through your body!</span>")
	damage_chance += 75 //ruh roh raggy

/// If our owner dies without getting gibbed, we gib them, because fuck you baltamore
/datum/status_effect/cursed/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(!ishuman(owner))
		return
	if(gibbed)
		return
	var/mob/living/carbon/human/H = owner
	INVOKE_ASYNC(H, TYPE_PROC_REF(/mob, gib))

/datum/status_effect/cursed/tick()
	if(curse_count <= 1)
		return // you get one "freebie" (single damage) to nudge you into thinking this is a bad idea before the house begins to win.

	// the house won.
	var/ticked_coefficient = rand(15, 40) * 2 / 100
	var/effective_percentile_chance = ((curse_count == 2 ? 1 : curse_count) * damage_chance * ticked_coefficient)

	if(prob(effective_percentile_chance))
		owner.apply_damages(
			brute = (curse_count * ticked_coefficient),
			burn = (curse_count * ticked_coefficient),
			oxy = (curse_count * ticked_coefficient),
		)

/atom/movable/screen/alert/status_effect/cursed
	name = "Cursed!"
	desc = "The brand on your hand reminds you of your greed, yet you seem to be okay otherwise."
	icon_state = "cursed_by_slots"

/atom/movable/screen/alert/status_effect/cursed/update_desc()
	. = ..()
	var/datum/status_effect/cursed/linked_effect = attached_effect
	var/curses = linked_effect.curse_count
	switch(curses)
		if(2)
			desc = "Your greed is catching up to you..."
		if(3)
			desc = "You really don't feel good right now... But why stop now?"
		if(4 to INFINITY)
			desc = "Real winners quit before they reach the ultimate prize."

#undef DEFAULT_MAX_CURSE_COUNT

/datum/status_effect/reversed_high_priestess
	id = "reversed_high_priestess"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bubblegum_curse

/datum/status_effect/reversed_high_priestess/tick()
	. = ..()
	new /obj/effect/bubblegum_warning(get_turf(owner))

/obj/effect/bubblegum_warning
	name = "bloody rift"
	desc = "You feel like even being *near* this is a bad idea."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	color = "red"

/obj/effect/bubblegum_warning/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(slap_someone)), 2.5 SECONDS) //A chance to run away

/obj/effect/bubblegum_warning/proc/slap_someone()
	new /obj/effect/abstract/bubblegum_rend_helper(get_turf(src), null, 10)
	qdel(src)

/// The mob has been pushed by airflow recently, and won't automatically grab nearby objects to stop drifting.
/datum/status_effect/unbalanced
	id = "unbalanced"
	duration = 1 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/unbalanced

/atom/movable/screen/alert/status_effect/unbalanced
	name = "Unbalanced"
	desc = "You're being shoved around by airflow! You can resist this by moving, but moving against the wind will be slow."
	icon_state = "unbalanced"

/datum/status_effect/c_foamed
	id = "c_foamed up"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 10 SECONDS
	var/foam_level = 1
	var/mutable_appearance/foam_overlay

/datum/status_effect/c_foamed/on_apply()
	. = ..()
	foam_overlay = mutable_appearance('icons/obj/foam_blobs.dmi', "foamed_1")
	owner.add_overlay(foam_overlay)
	owner.next_move_modifier *= 1.5
	owner.Slowed(10 SECONDS, 1.5)

/datum/status_effect/c_foamed/Destroy()
	if(owner)
		owner.cut_overlay(foam_overlay)
		owner.next_move_modifier /= 1.5

	QDEL_NULL(foam_overlay)
	return ..()

/datum/status_effect/c_foamed/tick()
	. = ..()
	if(--foam_level <= 0)
		qdel(src)
	refresh_overlay()

/datum/status_effect/c_foamed/refresh()
	. = ..()
	// Our max slow is 50 seconds
	foam_level = min(foam_level + 1, 5)

	refresh_overlay()

	if(foam_level == 5)
		owner.Immobilize(5 SECONDS)

/datum/status_effect/c_foamed/proc/refresh_overlay()
	// Refresh overlay
	owner.cut_overlay(foam_overlay)
	QDEL_NULL(foam_overlay)
	foam_overlay = mutable_appearance('icons/obj/foam_blobs.dmi', "foamed_[foam_level]")
	owner.add_overlay(foam_overlay)

/datum/status_effect/judo_armbar
	id = "armbar"
	duration = 5 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/rust_corruption
	alert_type = null
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS

/datum/status_effect/rust_corruption/tick()
	. = ..()
	SEND_SOUND(owner, sound('sound/weapons/sear.ogg'))
	if(issilicon(owner))
		to_chat(owner, "<span class='userdanger'>The unnatural rust magically corrodes your body!</span>")
		owner.adjustBruteLoss(10)
		return
	//We don't have disgust, so...
	to_chat(owner, "<span class='userdanger'>The unnatural rust makes you feel sick!</span>")
	if(ishuman(owner))
		owner.adjustBrainLoss(2.5)
		owner.reagents?.remove_all(0.75)
	else
		owner.adjustBruteLoss(3) //Weaker than borgs but still constant.

/// This is the threshold where the attack will stun on the last hit. Why? Because it is cool, that's why.
#define FINISHER_THRESHOLD 7

/datum/status_effect/temporal_slash
	id = "temporal_slash"
	duration = 3 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// How many times the user has been cut. Each cut adds a damage value below
	var/cuts = 1
	/// How much damage the blade will do each slice
	var/damage_per_cut = 20

/datum/status_effect/temporal_slash/on_creation(mob/living/new_owner, cut_damage = 20)
	. = ..()
	damage_per_cut = cut_damage

/datum/status_effect/temporal_slash/refresh()
	cuts++
	return ..()

/datum/status_effect/temporal_slash/on_remove()
	owner.apply_status_effect(STATUS_EFFECT_TEMPORAL_SLASH_FINISHER, cuts, damage_per_cut) //We apply this to a new status effect, to avoid refreshing while on_remove happens.

/datum/status_effect/temporal_slash_finisher
	id = "temporal_slash_finisher"
	alert_type = null
	tick_interval = 0.25 SECONDS
	/// How many times the user has been cut. Each cut adds a damage value below
	var/cuts = 1
	/// How much damage the blade will do each slice
	var/damage_per_cut = 20
	/// Have we done enough damage to trigger the finisher?
	var/finishing_cuts = FALSE

/datum/status_effect/temporal_slash_finisher/on_creation(mob/living/new_owner, final_cuts = 1, cut_damage = 20)
	. = ..()
	cuts = final_cuts
	damage_per_cut = cut_damage
	if(ismegafauna(owner))
		damage_per_cut *= 4 //This will deal 40 damage bonus per cut on megafauna as a miner, and 80 as a wizard. To kill a megafauna, you need to hit it 48 times. You don't get the buffs of a crusher though. Also you already killed bubblegum, so, you know.
	if(cuts >= FINISHER_THRESHOLD)
		finishing_cuts = TRUE
	new /obj/effect/temp_visual/temporal_slash(get_turf(owner), owner)

/datum/status_effect/temporal_slash_finisher/tick()
	. = ..()
	owner.visible_message("<span class='danger'>[owner] gets slashed by a cut through spacetime!</span>", "<span class='userdanger'>You get slashed by a cut through spacetime!</span>")
	playsound(owner, 'sound/weapons/rapierhit.ogg', 50, TRUE)
	owner.apply_damage(damage_per_cut, BRUTE, pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG), 0, TRUE, null, FALSE)
	cuts--
	if(cuts <= 0)
		if(finishing_cuts)
			owner.Weaken(7 SECONDS)
		qdel(src)
	else
		new /obj/effect/temp_visual/temporal_slash(get_turf(owner), owner)

#undef FINISHER_THRESHOLD
