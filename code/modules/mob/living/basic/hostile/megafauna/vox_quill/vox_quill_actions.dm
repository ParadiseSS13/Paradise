/datum/action/cooldown/mob_cooldown/vox_quill/stomp
	name = "Repulse"
	desc = "You slam your foot into the ground sending a powerful shockwave through the station's hull, sending people flying away."
	button_icon_state = "seismic_stomp"
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 40 SECONDS
	shared_cooldown = NONE
	var/max_range = 8

/datum/action/cooldown/mob_cooldown/vox_quill/stomp/Activate(atom/target)
	var/mob/living/basic/megafauna/vox_quill/bird = owner
	var/turf/T = get_turf(bird)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	playsound(T, 'sound/magic/invoke_general.ogg', 300, TRUE, 5)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, T, bird), 0.2 SECONDS)
	new /obj/effect/temp_visual/stomp(T)

/datum/action/cooldown/mob_cooldown/vox_quill/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
	// gets the two outermost turfs in a ring, we get two so people cannot "walk over" the shockwave
	var/list/targets = view(range, start_turf) - view(range - 2, start_turf)
	for(var/turf/simulated/floor/flooring in targets)
		if(prob(100 - (range * 20)))
			flooring.ex_act(EXPLODE_LIGHT)

	for(var/mob/living/L in targets)
		if(istype(L, /mob/living/basic/kidan_warrior))
			continue
		if(L in safe_targets)
			continue
		if(L.throwing) // no double hits
			continue
		if(L.move_resist > MOVE_FORCE_VERY_STRONG)
			continue
		var/throw_target = get_edge_target_turf(L, get_dir(start_turf, L))
		INVOKE_ASYNC(L, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 3, 4)
		L.KnockDown(2 SECONDS)
		L.adjustBruteLoss(20)
		safe_targets += L
	var/new_range = range + 1
	if(new_range <= max_range)
		addtimer(CALLBACK(src, PROC_REF(hit_check), new_range, start_turf, user, safe_targets), 0.2 SECONDS)

