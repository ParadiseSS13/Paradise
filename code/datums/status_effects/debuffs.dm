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


/**
 * # Confusion
 * 
 * Prevents moving straight, sometimes changing movement direction at random.
 * Decays at a rate of 1 per second.
 */
/datum/status_effect/transient/confusion
	id = "confusion"
	var/static/image/overlay

/datum/status_effect/transient/confusion/on_apply()
	if(!overlay)
		var/matrix/M = matrix()
		M.Scale(0.6)
		overlay = image('icons/effects/effects.dmi', "confusion", pixel_y = 20)
		overlay.transform = M
	owner.add_overlay(overlay)
	return ..()

/datum/status_effect/transient/confusion/on_remove()
	owner.cut_overlay(overlay)
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
	..()
	if(QDELETED(src))
		return
	var/dir = sin(world.time * 2)
	px_diff = cos(world.time * 3) * min(strength * 2, 32) * dir
	py_diff = sin(world.time * 3) * min(strength * 2, 32) * dir
	owner.client?.pixel_x = px_diff
	owner.client?.pixel_y = py_diff

/datum/status_effect/transient/dizziness/calc_decay()
	return -0.2 + (owner.resting ? -0.8 : 0)
	
/**
 * # Drowsiness
 * 
 * Slows down and causes eye blur, with a 5% chance of falling asleep for a short time.
 * Decays at a rate of 1 per second, or 5 when resting.
 */
/datum/status_effect/transient/drowsiness
	id = "drowsiness"
	
/datum/status_effect/transient/drowsiness/tick()
	..()
	if(QDELETED(src))
		return
	owner.EyeBlurry(2)
	if(prob(5))
		owner.AdjustSleeping(1)
		owner.Paralyse(5)

/datum/status_effect/transient/drowsiness/calc_decay()
	return -0.2 + (owner.resting ? -0.8 : 0)

/**
 * # Drukenness
 * 
 * Causes a myriad of status effects and other afflictions the stronger it is.
 * Decays at a rate of 1 per second if no alcohol remains inside.
 */
/datum/status_effect/transient/drunkenness
	id = "drunkenness"
	var/alert_thrown = FALSE

#define THRESHOLD_SLUR 30
#define THRESHOLD_BRAWLING 30
#define THRESHOLD_CONFUSION 40
#define THRESHOLD_SPARK 50
#define THRESHOLD_VOMIT 60
#define THRESHOLD_BLUR 75
#define THRESHOLD_COLLAPSE 75
#define THRESHOLD_FAINT 90
#define THRESHOLD_BRAIN_DAMAGE 120
#define DRUNK_BRAWLING /datum/martial_art/drunk_brawling

/datum/status_effect/transient/drunkenness/on_remove()
	if(alert_thrown)
		alert_thrown = FALSE
		owner.clear_alert("drunk")
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE
	return ..()

/datum/status_effect/transient/drunkenness/tick()
	. = ..()
	if(QDELETED(src))
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

	// THRESHOLD_SLUR (30)
	if(actual_strength >= THRESHOLD_SLUR)
		owner.Slur(actual_strength)
		if(!alert_thrown)
			alert_thrown = TRUE
			owner.throw_alert("drunk", /obj/screen/alert/drunk)
			owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	// THRESHOLD_BRAWLING (30)
	if(M)
		if(actual_strength >= THRESHOLD_BRAWLING)
			if(!istype(M.martial_art, DRUNK_BRAWLING))
				var/datum/martial_art/MA = new
				MA.teach(owner, TRUE)
		else if(istype(M.martial_art, DRUNK_BRAWLING))
			M.martial_art.remove(src)
	// THRESHOLD_CONFUSION (40)
	if(actual_strength >= THRESHOLD_CONFUSION && prob(33))
		owner.AdjustConfused(3 / alcohol_resistance, bound_lower = 1)
		owner.AdjustDizzy(3 / alcohol_resistance, bound_lower = 1)
	// THRESHOLD_SPARK (50)
	if(is_ipc && actual_strength >= THRESHOLD_SPARK && prob(25))
		do_sparks(3, 1, owner)
	// THRESHOLD_VOMIT (60)
	if(!is_ipc && actual_strength >= THRESHOLD_VOMIT && prob(8))
		owner.fakevomit()
	// THRESHOLD_BLUR (75)
	if(actual_strength >= THRESHOLD_BLUR)
		owner.EyeBlurry(10 / alcohol_resistance)
	// THRESHOLD_COLLAPSE (75)
	if(actual_strength >= THRESHOLD_COLLAPSE && prob(10))
		owner.emote("collapse")
		do_sparks(3, 1, src)
	// THRESHOLD_FAINT (90)
	if(actual_strength >= THRESHOLD_FAINT && prob(10))
		owner.Paralyse(5 / alcohol_resistance)
		owner.Drowsy(30 / alcohol_resistance)
		if(L)
			L.receive_damage(1, TRUE)
		if(!is_ipc)
			owner.adjustToxLoss(1)
	// THRESHOLD_BRAIN_DAMAGE (120)
	if(actual_strength >= THRESHOLD_BRAIN_DAMAGE && prob(10))
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
	return -0.2