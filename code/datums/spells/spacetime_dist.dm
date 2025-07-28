// This could probably be an aoe spell but it's a little cursed, so I'm not touching it
/datum/spell/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate... \
		Upgrading the spell increases range, it does not lower cooldown."
	sound = 'sound/magic/strings.ogg'
	action_icon_state = "spacetime"

	base_cooldown = 30 SECONDS
	invocation = "none"
	centcom_cancast = FALSE //Prevent people from getting to centcom
	cooldown_min = 30 SECONDS //No reduction, just more range.
	level_max = 3
	create_attack_logs = FALSE //no please god no do not log range^2 turfs being targeted

	/// Whether we're ready to cast again yet or not. In the event someone lowers their cooldown with charge.
	var/ready = TRUE
	/// The radius of the scramble around the caster. Increased by 3 * spell_level
	var/scramble_radius = 7
	/// The duration of the scramble
	var/duration = 15 SECONDS
	/// A lazylist of all scramble effects this spell has created.
	var/list/effects

/datum/spell/spacetime_dist/Destroy()
	QDEL_LIST_CONTENTS(effects)
	return ..()

/datum/spell/spacetime_dist/create_new_targeting()
	var/datum/spell_targeting/spiral/targeting = new()
	targeting.range = scramble_radius + 3 * spell_level
	return targeting

/datum/spell/spacetime_dist/on_purchase_upgrade()
	. = ..()
	targeting = create_new_targeting()

/datum/spell/spacetime_dist/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr)
	return ..() && ready

/datum/spell/spacetime_dist/cast(list/targets, mob/user = usr)
	. = ..()
	var/list/turf/to_switcharoo = targets
	if(!length(to_switcharoo))
		to_chat(user, "<span class='warning'>For whatever reason, the strings nearby aren't keen on being tangled.</span>")
		return

	ready = FALSE
	effects = list()

	for(var/turf/swap_a as anything in to_switcharoo)
		var/turf/swap_b = to_switcharoo[swap_a]
		var/obj/effect/cross_action/spacetime_dist/effect_a = new /obj/effect/cross_action/spacetime_dist(swap_a)
		var/obj/effect/cross_action/spacetime_dist/effect_b = new /obj/effect/cross_action/spacetime_dist(swap_b)
		effect_a.linked_dist = effect_b
		effect_a.add_overlay(swap_b.photograph())
		effect_b.linked_dist = effect_a
		effect_b.add_overlay(swap_a.photograph())
		effect_b.set_light(4, 30, "#c9fff5")
		effects += effect_a
		effects += effect_b


/datum/spell/spacetime_dist/after_cast(list/targets, mob/user)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(clean_turfs)), duration)

/// Callback which cleans up our effects list after the duration expires.
/datum/spell/spacetime_dist/proc/clean_turfs()
	QDEL_LIST_CONTENTS(effects)
	ready = TRUE

/obj/effect/cross_action
	name = "cross me"
	desc = "for crossing."

/obj/effect/cross_action/spacetime_dist
	name = "spacetime distortion"
	desc = "A distortion in spacetime. You can hear faint music..."
	icon_state = "nothing"
	/// A flags which save people from being thrown about
	var/antimagic_flags = MAGIC_RESISTANCE
	/// A flags which save people from being thrown about
	var/obj/effect/cross_action/spacetime_dist/linked_dist
	/// Used to prevent an infinite loop in the space tiime continuum
	var/cant_teleport = FALSE
	var/walks_left = 50 //prevents the game from hanging in extreme cases

/obj/effect/cross_action/singularity_act()
	return

/obj/effect/cross_action/singularity_pull()
	return

/obj/effect/cross_action/spacetime_dist/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/cross_action/spacetime_dist/proc/walk_link(atom/movable/AM)
	if(ismob(AM))
		var/mob/M = AM
		if(M.can_block_magic(antimagic_flags, charge_cost = 0))
			return
	if(linked_dist && walks_left > 0)
		flick("purplesparkles", src)
		linked_dist.get_walker(AM)
		walks_left--

/obj/effect/cross_action/spacetime_dist/proc/get_walker(atom/movable/AM)
	cant_teleport = TRUE
	flick("purplesparkles", src)
	AM.forceMove(get_turf(src))
	cant_teleport = FALSE

/obj/effect/cross_action/spacetime_dist/proc/on_atom_entered(atom/source, atom/movable/entered, turf/old_loc)
	if(!cant_teleport)
		walk_link(entered)

/obj/effect/cross_action/spacetime_dist/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.drop_item(used))
		walk_link(used)
	else
		walk_link(user)
	return ITEM_INTERACT_COMPLETE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/cross_action/spacetime_dist/attack_hand(mob/user, list/modifiers)
	walk_link(user)

/obj/effect/cross_action/spacetime_dist/Destroy()
	cant_teleport = TRUE
	linked_dist = null
	RemoveElement(/datum/element/connect_loc)
	return ..()
