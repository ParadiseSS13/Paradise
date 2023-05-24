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
	create_attack_logs = FALSE //no please god no do not log range^2 turfs being targeted

	/// Whether we're ready to cast again yet or not. In the event someone lowers their cooldown with charge.
	var/ready = TRUE
	/// The radius of the scramble around the caster. Increased by 3 * spell_level
	var/scramble_radius = 7
	/// The duration of the scramble
	var/duration = 15 SECONDS
	/// A lazylist of all scramble effects this spell has created.
	var/list/effects

/obj/effect/proc_holder/spell/spacetime_dist/Destroy()
	QDEL_LIST_CONTENTS(effects)
	return ..()

/obj/effect/proc_holder/spell/spacetime_dist/create_new_targeting()
	var/datum/spell_targeting/spiral/targeting = new()
	targeting.range = scramble_radius + 3 * spell_level
	return targeting

/obj/effect/proc_holder/spell/spacetime_dist/on_purchase_upgrade()
	. = ..()
	targeting = create_new_targeting()

/obj/effect/proc_holder/spell/spacetime_dist/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr)
	return ..() && ready

/obj/effect/proc_holder/spell/spacetime_dist/cast(list/targets, mob/user = usr)
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


/obj/effect/proc_holder/spell/spacetime_dist/after_cast(list/targets, mob/user)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(clean_turfs)), duration)

/// Callback which cleans up our effects list after the duration expires.
/obj/effect/proc_holder/spell/spacetime_dist/proc/clean_turfs()
	QDEL_LIST_CONTENTS(effects)
	ready = TRUE

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
	/// Used to prevent an infinite loop in the space tiime continuum
	var/cant_teleport = FALSE
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
	cant_teleport = TRUE
	flick("purplesparkles", src)
	AM.forceMove(get_turf(src))
	cant_teleport = FALSE

/obj/effect/cross_action/spacetime_dist/Crossed(atom/movable/AM, oldloc)
	if(!cant_teleport)
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
	cant_teleport = TRUE
	linked_dist = null
	return ..()
