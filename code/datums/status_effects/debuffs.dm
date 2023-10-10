//OTHER DEBUFFS

/datum/status_effect/his_wrath //does minor damage over time unless holding His Grace
	id = "his_wrath"
	duration = -1
	tick_interval = 4
	alert_type = /obj/screen/alert/status_effect/his_wrath

/obj/screen/alert/status_effect/his_wrath
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

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes, can see ghosts and dies if too far from summoner
	id = "cult_ghost"
	duration = -1
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
		playsound(T, "desceration", 200, 1, -1)
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
	var/mob/living/simple_animal/hostile/asteroid/big_legion/latest_attacker

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
	addtimer(CALLBACK(latest_attacker, TYPE_PROC_REF(/mob/living/simple_animal/hostile/asteroid/big_legion, throw_mobs)), 1 SECONDS)

/datum/status_effect/stacking/ground_pound/on_remove()
	latest_attacker = null

/datum/status_effect/teleport_sickness
	id = "teleportation sickness"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /obj/screen/alert/status_effect/teleport_sickness
	var/teleports = 1

/obj/screen/alert/status_effect/teleport_sickness
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
	if(!ishuman(owner))
		return
	overlay = mutable_appearance('icons/effects/cult_effects.dmi', "cult-mark", ABOVE_MOB_LAYER)
	var/mob/living/carbon/human/H = owner
	H.add_overlay(overlay)

/datum/status_effect/cult_stun_mark/on_remove()
	owner.cut_overlay(overlay)

/datum/status_effect/cult_stun_mark/proc/trigger()
	owner.adjustStaminaLoss(60)
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
	var/is_ipc = ismachineperson(owner)

	if(HAS_TRAIT(owner, TRAIT_ALCOHOL_TOLERANCE))
		alcohol_resistance = 2

	actual_strength /= alcohol_resistance

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
				var/datum/martial_art/drunk_brawling/MA = new
				MA.teach(owner, TRUE)
		else if(istype(M.martial_art, DRUNK_BRAWLING))
			M.martial_art.remove(owner)
	// THRESHOLD_CONFUSION (80 SECONDS)
	if(actual_strength >= THRESHOLD_CONFUSION && prob(0.33))
		owner.AdjustConfused(6 SECONDS / alcohol_resistance, bound_lower = 2 SECONDS, bound_upper = 1 MINUTES)
	// THRESHOLD_SPARK (100 SECONDS)
	if(is_ipc && actual_strength >= THRESHOLD_SPARK && prob(0.25))
		do_sparks(3, 1, owner)
	// THRESHOLD_VOMIT (120 SECONDS)
	if(!is_ipc && actual_strength >= THRESHOLD_VOMIT && prob(0.08))
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
		if(!is_ipc)
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
	if(prob(10) && dreamer.health && dreamer.health_hud_override != HEALTH_HUD_OVERRIDE_CRIT)
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

/datum/status_effect/transient/silence/absolute // this one will mute all emote sounds including gasps
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
/// This is multiplied with [/mob/var/hallucination] to determine the final cooldown. A higher hallucination value means shorter cooldown.
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
	duration = -1 //Kill it, get out of sight, or be killed. Jump boots are *required*
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
	alert_type = /obj/screen/alert/status_effect/bubblegum_curse
	duration = -1 //Kill it. There is no other option.
	tick_interval = 1 SECONDS
	/// The damage the status effect does per tick.
	var/damage = 0.75
	var/source_UID
	/// Are we starting the process to check if the person has still gotten out of range of bubble / crossed zlvls.
	var/coward_checking = FALSE

/datum/status_effect/bubblegum_curse/on_creation(mob/living/new_owner, mob/living/source)
	. = ..()
	source_UID = source.UID()
	owner.overlay_fullscreen("Bubblegum", /obj/screen/fullscreen/fog, 1)

/datum/status_effect/bubblegum_curse/tick()
	var/mob/living/simple_animal/hostile/megafauna/bubblegum/attacker = locateUID(source_UID)
	if(!attacker)
		qdel(src)
	if(attacker.health <= attacker.maxHealth / 2)
		owner.clear_fullscreen("Bubblegum")
		owner.overlay_fullscreen("Bubblegum", /obj/screen/fullscreen/fog, 2)
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

/obj/screen/alert/status_effect/bubblegum_curse
	name = "I SEE YOU"
	desc = "YOUR SOUL WILL BE MINE FOR YOUR INSOLENCE"
	icon_state = "bubblegumjumpscare"

/obj/screen/alert/status_effect/bubblegum_curse/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/screen/alert/status_effect/bubblegum_curse/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/screen/alert/status_effect/bubblegum_curse/process()
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#ce3030", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)
