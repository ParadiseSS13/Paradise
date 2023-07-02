/mob/living/simple_animal/hostile/carp
	a_intent = INTENT_HARM
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	health = 60
	maxHealth = 60
	/// Ability which lets carp teleport around
	var/datum/action/innate/lesser_carp_rift/teleport

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	teleport = new
	teleport.Grant(src)

/mob/living/simple_animal/hostile/carp/AttackingTarget()
	if(isliving(target))
		var/mob/living/living_target = target
		if("carp" in living_target.faction)
			to_chat(src, span_warning("Вы почти укусили своего сородича, но вовремя остановились."))
			return
	. = ..()

/datum/action/innate/lesser_carp_rift
	name = "Lesser Carp Rift"
	desc = "Открывает малый разлом карпов, который позволяет перемещаться на малое расстояние."
	button_icon_state = "rift"
	background_icon_state = "bg_alien"
	var/cooldown_time = 15 SECONDS
	var/melee_cooldown_time = 0 SECONDS // Handled by rift
	/// How far away can you place a rift?
	var/range = 3
	COOLDOWN_DECLARE(rift_cooldown)

/datum/action/innate/lesser_carp_rift/Activate()
	if(!COOLDOWN_FINISHED(src, rift_cooldown))
		to_chat(owner, span_warning("Способность на перезарядке! Осталось секунд: [round(COOLDOWN_TIMELEFT(src, rift_cooldown)) / 10]!"))
		return FALSE
	var/turf/current_location = get_turf(owner)
	var/turf/destination = get_teleport_loc(current_location, owner, range)
	if (!make_rift(destination))
		return FALSE
	COOLDOWN_START(src, rift_cooldown, cooldown_time)
	return TRUE

/datum/action/innate/lesser_carp_rift/proc/make_rift(atom/target_atom)
	var/turf/owner_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target_atom)
	if (!target_turf)
		return FALSE

	var/list/open_exit_turfs = list()
	for (var/turf/potential_exit as anything in (RANGE_TURFS(1, target_turf) - target_turf))
		if(is_blocked_turf(potential_exit, exclude_mobs = TRUE))
			continue
		open_exit_turfs += potential_exit

	if(!length(open_exit_turfs))
		to_chat(owner, span_warning("Нет выхода!"))
		return FALSE
	if(!is_blocked_turf(target_turf, exclude_mobs = TRUE))
		open_exit_turfs += target_turf

	new /obj/effect/temp_visual/lesser_carp_rift/exit(target_turf)
	var/obj/effect/temp_visual/lesser_carp_rift/entrance/enter = new(owner_turf)
	enter.exit_locs = open_exit_turfs
	enter.on_entered(enter, owner)
	return TRUE

/// If you touch the entrance you are teleported to the exit, exit doesn't do anything
/obj/effect/temp_visual/lesser_carp_rift
	name = "lesser carp rift"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	duration = 5 SECONDS
	/// Holds a reference to a timer until this gets deleted
	var/destroy_timer

/obj/effect/temp_visual/lesser_carp_rift/Initialize(mapload)
	destroy_timer = addtimer(CALLBACK(src, PROC_REF(animate_out)), duration - 1, TIMER_STOPPABLE)
	return ..()

/obj/effect/temp_visual/lesser_carp_rift/proc/animate_out()
	var/obj/effect/temp_visual/lesser_carp_rift_dissipating/animate_out = new(loc)
	animate_out.setup_animation(alpha)

/obj/effect/temp_visual/lesser_carp_rift/Destroy()
	. = ..()
	deltimer(destroy_timer)

/// If you touch this you are taken to the exit
/obj/effect/temp_visual/lesser_carp_rift/entrance
	/// Where you get teleported to
	var/list/exit_locs
	/// Click CD to apply after teleporting
	var/disorient_time = CLICK_CD_MELEE

/obj/effect/temp_visual/lesser_carp_rift/entrance/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/lesser_carp_rift/entrance/proc/on_entered(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER

	if (!length(exit_locs))
		return
	if (!ismob(entered_atom) && !isobj(entered_atom))
		return
	if (entered_atom.anchored)
		return
	if(!entered_atom.loc)
		return
	if (isobserver(entered_atom))
		return

	if (isliving(entered_atom))
		var/mob/living/teleported_mob = entered_atom
		teleported_mob.changeNext_move(disorient_time)

	var/turf/destination = pick(exit_locs)
	do_teleport(entered_atom, destination)
	playsound(src, 'sound/magic/wand_teleport.ogg', 50)
	playsound(destination, 'sound/magic/wand_teleport.ogg', 50)

/// Doesn't actually do anything, just a visual marker
/obj/effect/temp_visual/lesser_carp_rift/exit
	alpha = 125

/// Just an animation
/obj/effect/temp_visual/lesser_carp_rift_dissipating
	name = "lesser carp rift"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	duration = 1 SECONDS

/obj/effect/temp_visual/lesser_carp_rift_dissipating/proc/setup_animation(new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0, time = duration - 1)
