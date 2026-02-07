// Shoots out in a wave-like, what rust heretics themselves get
/datum/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, \
		briefly blinds them (increasing with range) and poisons them (decreasing with range). \
		Also spreads rust in the path of the plume."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "entropic_plume"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/magic/forcewall.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "'NTR'P'C PL'M'"
	invocation_type = INVOCATION_WHISPER
	cone_levels = 5

/datum/spell/cone/staggered/entropic_plume/create_new_targeting()
	var/datum/spell_targeting/cone/entropic/E = new()
	E.cone_levels = cone_levels
	E.respect_density = respect_density
	return E

/datum/spell_targeting/cone/entropic

/datum/spell_targeting/cone/entropic/calculate_cone_shape(current_level)
	// At the first level (that isn't level 1) we will be small
	if(current_level == 2)
		return 3
	// At the max level, we turn small again
	if(current_level == cone_levels)
		return 3
	// Otherwise, all levels in between will be wider
	return 5

/datum/spell/cone/staggered/entropic_plume/cast(list/targets, mob/user)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(user, user.dir), user.dir)

/datum/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, mob/living/caster, level)
	if(ismob(caster))
		caster.do_rust_heretic_act(target_turf)
	else
		target_turf.rust_heretic_act()

/datum/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	if(victim.can_block_magic(antimagic_flags) || IS_HERETIC_OR_MONSTER(victim) || victim == caster)
		return
	victim.apply_status_effect(/datum/status_effect/amok)
	victim.apply_status_effect(/datum/status_effect/cloudstruck, level * 1 SECONDS)
	victim.adjust_disgust(20 SECONDS)
	victim.AdjustConfused(10 SECONDS)


/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

// Shoots a straight line of rusty stuff ahead of the caster, what rust monsters get
/datum/spell/fireball/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your hands to release a wave of rust."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "rust_wave"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 35 SECONDS

	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER

	fireball_type = /obj/projectile/magic/rust_wave

/obj/projectile/magic/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	range = 15

/obj/projectile/magic/rust_wave/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(movement_dir,90))
	turflist += T1
	turflist += get_step(T1,turn(movement_dir,90))
	T1 = get_step(src,turn(movement_dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(movement_dir,-90))
	for(var/turf/T as anything in turflist)
		if(!T || prob(25))
			continue
		T.rust_heretic_act()

/datum/spell/fireball/rust_wave/short
	name = "Lesser Patron's Reach"
	fireball_type = /obj/projectile/magic/rust_wave/short

/obj/projectile/magic/rust_wave/short
	range = 7
	speed = 0.5
