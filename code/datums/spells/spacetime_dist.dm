// This could probably be an aoe spell but it's a little cursed, so I'm not touching it
/obj/effect/proc_holder/spell/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate... \
		Upgrading the spell increases range, it does not lower cooldown."
	sound = 'sound/magic/strings.ogg'
	action_icon_state = "spacetime"

	school = "transmutation"
	base_cooldown = 30 SECONDS
	clothes_req = TRUE
	invocation = "none"
	centcom_cancast = FALSE //Prevent people from getting to centcom
	cooldown_min = 30 SECONDS //No reduction, just more range.
	level_max = 3

	/// Whether we're ready to cast again yet or not. In the event someone lowers their cooldown with charge.
	var/ready = TRUE
	/// The radius of the scramble around the caster. Increased by 3 * spell_level
	var/scramble_radius = 7
	/// The duration of the scramble
	var/duration = 15 SECONDS
	/// A lazylist of all scramble effects this spell has created.
	var/list/effects

/obj/effect/proc_holder/spell/spacetime_dist/Destroy()
	QDEL_LIST(effects)
	return ..()

/obj/effect/proc_holder/spell/spacetime_dist/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/spacetime_dist/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr)
	return ..() && ready

/obj/effect/proc_holder/spell/spacetime_dist/cast(list/targets, mob/user = usr)
	. = ..()
	var/list/turf/to_switcharoo = get_targets_to_scramble(usr)
	if(!length(to_switcharoo))
		to_chat(user, "<span class='warning'>For whatever reason, the strings nearby aren't keen on being tangled.</span>")
		return

	ready = FALSE

	for(var/turf/swap_a as anything in to_switcharoo)
		var/turf/swap_b = to_switcharoo[swap_a]
		var/obj/effect/cross_action/spacetime_dist/effect_a = new /obj/effect/cross_action/spacetime_dist(swap_a)
		var/obj/effect/cross_action/spacetime_dist/effect_b = new /obj/effect/cross_action/spacetime_dist(swap_b)
		effect_a.linked_dist = effect_b
		effect_a.add_overlay(swap_b.photograph())
		effect_b.linked_dist = effect_a
		effect_b.add_overlay(swap_a.photograph())
		effect_b.set_light(4, 30, "#c9fff5")
		LAZYADD(effects, effect_a)
		LAZYADD(effects, effect_b)

/turf/proc/photograph(limit = 20)
	var/image/I = new()
	I.add_overlay(src)
	for(var/V in contents)
		var/atom/A = V
		if(A.invisibility)
			continue
		I.add_overlay(A)
		if(limit)
			limit--
		else
			return I
	return I

/obj/effect/proc_holder/spell/spacetime_dist/after_cast(list/targets, mob/user)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(clean_turfs)), duration)

/// Callback which cleans up our effects list after the duration expires.
/obj/effect/proc_holder/spell/spacetime_dist/proc/clean_turfs()
	QDEL_LIST(effects)
	ready = TRUE

/**
 * Gets a list of turfs around the center atom to scramble.
 *
 * Returns an assoc list of [turf] to [turf]. These pairs are what turfs are
 * swapped between one another when the cast is done.
 */
/obj/effect/proc_holder/spell/spacetime_dist/proc/get_targets_to_scramble(atom/center)
	// Get turfs around the center
	var/list/turfs = spiral_range_turfs(scramble_radius + 3 * spell_level, center) // 7 10 13 16
	if(!length(turfs))
		return

	var/list/turf_steps = list()

	// Go through the turfs we got and pair them up
	// This is where we determine what to swap where
	var/num_to_scramble = round(length(turfs) * 0.5)
	for(var/i in 1 to num_to_scramble)
		turf_steps[pick_n_take(turfs)] = pick_n_take(turfs)

	// If there's any turfs unlinked with a friend,
	// just randomly swap it with any turf in the area
	if(length(turfs))
		var/turf/loner = pick(turfs)
		var/area/caster_area = get_area(center)
		turf_steps[loner] = get_turf(pick(caster_area.contents))

	return turf_steps


/obj/effect/cross_action
	name = "cross me"
	desc = "for crossing"
	anchored = TRUE

/obj/effect/cross_action/spacetime_dist
	name = "spacetime distortion"
	desc = "A distortion in spacetime. You can hear faint music..."
	icon_state = "nothing"
	/// A flags which save people from being thrown about
	var/obj/effect/cross_action/spacetime_dist/linked_dist
	var/busy = FALSE
	var/walks_left = 50 //prevents the game from hanging in extreme cases

/obj/effect/cross_action/singularity_act()
	return

/obj/effect/cross_action/singularity_pull()
	return

/obj/effect/cross_action/spacetime_dist/proc/walk_link(atom/movable/AM)
	if(linked_dist && walks_left > 0)
		flick("purplesparkles", src)
		linked_dist.get_walker(AM)
		walks_left--

/obj/effect/cross_action/spacetime_dist/proc/get_walker(atom/movable/AM)
	busy = TRUE
	flick("purplesparkles", src)
	AM.forceMove(get_turf(src))
	busy = FALSE

/obj/effect/cross_action/spacetime_dist/Crossed(atom/movable/AM, oldloc)
	if(!busy)
		walk_link(AM)

/obj/effect/cross_action/spacetime_dist/attackby(obj/item/W, mob/user, params)
	if(user.drop_item(W))
		walk_link(W)
	else
		walk_link(user)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/cross_action/spacetime_dist/attack_hand(mob/user, list/modifiers)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/Destroy()
	busy = TRUE
	linked_dist = null
	return ..()
