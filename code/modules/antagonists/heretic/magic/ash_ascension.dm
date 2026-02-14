/// Creates a constant Ring of Fire around the caster for a set duration of time, which follows them.
/datum/spell/fire_sworn
	name = "Oath of Flame"
	desc = "For a minute, you will passively create a ring of fire around you."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "fire_ring"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 70 SECONDS

	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER

	/// The radius of the fire ring
	var/fire_radius = 1
	/// How long it the ring lasts
	var/duration = 1 MINUTES


/datum/spell/fire_sworn/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/fire_sworn/cast(list/targets, mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(/datum/status_effect/fire_ring, duration, fire_radius)

/// Simple status effect for adding a ring of fire around a mob.
/datum/status_effect/fire_ring
	id = "fire_ring"
	tick_interval = 0.2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The radius of the ring around us.
	var/ring_radius = 1

/datum/status_effect/fire_ring/on_creation(mob/living/new_owner, duration = 1 MINUTES, radius = 1)
	src.duration = duration
	src.ring_radius = radius
	return ..()

/datum/status_effect/fire_ring/tick()
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return

	if(!isturf(owner.loc))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, owner))
		fireflash(nearby_turf, 0, 750)
		for(var/mob/living/fried_living in nearby_turf.contents - owner)
			fried_living.apply_damage(1.5, BURN)
	for(var/obj/effect/hotspot/flame_tile in range(2, owner)) //Extra range for if they are moving about since there is async shit going on
		flame_tile.alpha = 125

/// Creates one, large, expanding ring of fire around the caster, which does not follow them.
/datum/spell/fire_cascade
	name = "Lesser Fire Cascade"
	desc = "Heats the air around you."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "fire_ring"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/items/welder.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER

	/// The radius the flames will go around the caster.
	var/flame_radius = 4

/datum/spell/fire_cascade/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/fire_cascade/cast(list/targets, mob/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fire_cascade), get_turf(user), user, flame_radius)

/// Spreads a huge wave of fire in a radius around us, staggered between levels
/datum/spell/fire_cascade/proc/fire_cascade(atom/centre, mob/user, flame_radius = 1)
	for(var/i in 0 to flame_radius)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			fireflash(nearby_turf, 0, 750)
			for(var/mob/living/fried_living in nearby_turf.contents - user)
				fried_living.apply_damage(5, BURN)

		stoplag(0.3 SECONDS)
		for(var/obj/effect/hotspot/flame_tile in range(i + 2, user)) //Extra range for if they are moving about since there is async shit going on
			flame_tile.alpha = 125

/datum/spell/fire_cascade/big
	name = "Greater Fire Cascade"
	flame_radius = 6

// Currently used only by the funny haunted longsword
/datum/spell/pointed/ash_beams
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases five streams of eldritch fire towards the target."


	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 300

	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER

	/// The length of the flame line spit out.
	var/flame_line_length = 15

/datum/spell/pointed/ash_beams/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.use_turf_of_user = TRUE
	C.allowed_type = /atom
	return C


/datum/spell/pointed/ash_beams/cast(list/targets, mob/user)
	. = ..()
	var/target = targets[1]
	var/static/list/offsets = list(-25, -10, 0, 10, 25)
	for(var/offset in offsets)
		INVOKE_ASYNC(src, PROC_REF(fire_line), user, line_target(offset, flame_line_length, target, user))

/datum/spell/pointed/ash_beams/proc/line_target(offset, range, atom/at, atom/user)
	var/turf/user_loc = get_turf(user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user_loc.x, at.y - user_loc.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user_loc.x + cos(angle) * i, user_loc.y + sin(angle) * i, user_loc.z)
		if(!check)
			break
		T = check
	return (get_line(user_loc, T) - user_loc)

/datum/spell/pointed/ash_beams/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(iswallturf(T))
			break

		for(var/mob/living/L in T.contents)
			if(L.can_block_magic())
				L.visible_message(SPAN_DANGER("The spell bounces off of [L]!"), SPAN_USERDANGER("The spell bounces off of you!"))
				continue
			if((L in hit_list) || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, SPAN_USERDANGER("You're hit by [source]'s eldritch flames!"))

		fireflash(T, 0, 750)
		// deals damage to mechs
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(0.15 SECONDS)
