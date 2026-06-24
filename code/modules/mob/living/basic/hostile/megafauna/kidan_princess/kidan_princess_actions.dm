/datum/action/cooldown/mob_cooldown/kidan_princess/summon_mobs
	name = "Summon Throneguards"
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "telerune"
	desc = "Summon a pair of throneguards to protect you."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 90 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/kidan_princess/summon_mobs/Activate(atom/target)
	var/mob/living/basic/megafauna/kidan_princess/summoner = owner
	if(!istype(summoner))
		to_chat(owner, "<span class='warning'>I am unable to summon servants!</span>")
		return

	var/list/all_possible_dirs = GLOB.alldirs
	for(var/i in 1 to 2)
		var/mob/living/new_mob
		var/spawn_loc = get_step(summoner, pick_n_take(all_possible_dirs))
		new_mob = new /mob/living/basic/kidan_warrior/throneguard(spawn_loc)
		do_sparks(3, TRUE, new_mob)
	summoner.say("Guards! To me!")
	StartCooldown()

/datum/action/cooldown/mob_cooldown/kidan_princess/charge
	name = "Royal Charge"
	desc = "Charge forward into the fray!"
	button_icon_state = "OH_YEAAAAH"
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 20 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/kidan_princess/charge/Activate(atom/target)
	. = ..()
	var/dir_to_target = get_dir(get_turf(owner), get_turf(target))
	var/turf/T = get_step(get_turf(owner), dir_to_target)
	for(var/i in 1 to 9)
		new /obj/effect/temp_visual/dragon_swoop/space_whale(T)
		T = get_step(T, dir_to_target)
		if(ismineralturf(T))
			break
		if(iswallturf(T))
			break
		for(var/obj/structure/window/W in T.contents)
			break
		for(var/obj/machinery/door/D in T.contents)
			break
	owner.visible_message("<span class='danger'>[owner] prepares to charge!</span>")
	addtimer(CALLBACK(src, PROC_REF(charge_to), dir_to_target, 0), 0.3 SECONDS)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/kidan_princess/charge/proc/charge_to(move_dir, times_ran, list/hit_targets)
	if(times_ran >= 9)
		return
	var/turf/T = get_step(get_turf(owner), move_dir)
	if(ismineralturf(T))
		return
	if(iswallturf(T))
		return
	for(var/obj/structure/window/W in T.contents)
		return
	for(var/obj/machinery/door/D in T.contents)
		return
	if(T.x > world.maxx - 2 || T.x < 2) // Keep them from runtiming
		return
	if(T.y > world.maxy - 2 || T.y < 2)
		return
	owner.forceMove(T)
	playsound(owner, 'sound/effects/bang.ogg', 200, 1)
	var/throwtarget = get_edge_target_turf(owner, move_dir)
	for(var/mob/living/L in T.contents - owner)
		if(owner.faction_check_mob(L))
			continue
		owner.visible_message("<span class='danger'>[owner] slams into [L]!</span>")
		to_chat(L, "<span class='userdanger'>[owner] charges into you and smashes you away!</span>")
		L.throw_at(throwtarget, 10, 1, owner)
		L.Weaken(1 SECONDS) // Pain Train has no breaks.
		if(L in hit_targets)
			L.adjustBruteLoss(15)
		else
			hit_targets += L
			L.adjustBruteLoss(25)
	addtimer(CALLBACK(src, PROC_REF(charge_to), move_dir, (times_ran + 1), hit_targets), 0.7)

/datum/action/cooldown/mob_cooldown/kidan_princess/stomp
	name = "Shockwave"
	desc = "You slam your foot into the ground sending a powerful shockwave through the station's hull, sending people flying away."
	button_icon_state = "seismic_stomp"
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 40 SECONDS
	shared_cooldown = NONE
	var/max_range = 8

/datum/action/cooldown/mob_cooldown/kidan_princess/stomp/Activate(atom/target)
	var/mob/living/basic/megafauna/kidan_princess/princess = owner
	var/turf/T = get_turf(princess)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	playsound(T, 'sound/magic/invoke_general.ogg', 300, TRUE, 5)
	princess.say("Kneel!")
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, T, princess), 0.2 SECONDS)
	new /obj/effect/temp_visual/stomp(T)

/datum/action/cooldown/mob_cooldown/kidan_princess/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
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

/datum/action/cooldown/mob_cooldown/kidan_princess/martial_rush
	name = "Martial Rush"
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "sandy"
	desc = "Declare your intent to win, disgarding your halberd in favor of rapid punching attacks for ten seconds."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 75 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/kidan_princess/martial_rush/Activate(atom/target)
	var/mob/living/basic/megafauna/kidan_princess/princess = owner
	if(!istype(princess))
		return
	RegisterSignal(princess, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	princess.next_move_modifier -= 0.5
	princess.speed -= 1
	princess.attack_verb_continuous = "punches"
	princess.attack_verb_simple = "punch"
	if(princess.enraged)
		princess.melee_attack_cooldown_min = 0.2 SECONDS
		princess.melee_attack_cooldown_max = 0.3 SECONDS
		princess.melee_damage_lower = 10
		princess.melee_damage_upper = 15
	else
		princess.melee_attack_cooldown_min = 0.3 SECONDS
		princess.melee_attack_cooldown_max = 0.4 SECONDS
		princess.melee_damage_lower = 5
		princess.melee_damage_upper = 10
	princess.attack_sound ='sound/weapons/punch1.ogg'
	princess.martial_rushing = TRUE
	princess.update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(end_rush)), 10 SECONDS)
	playsound(get_turf(princess), 'sound/magic/invoke_general.ogg', 300, TRUE, 5)
	princess.say("FACE ME!")
	StartCooldown()

/// Leaves an afterimage behind the mob when they move
/datum/action/cooldown/mob_cooldown/kidan_princess/martial_rush/proc/on_movement(mob/living/L, atom/old_loc)
	SIGNAL_HANDLER
	if(HAS_TRAIT(L, TRAIT_IMMOBILIZED))
		return NONE
	new /obj/effect/temp_visual/decoy/mephedrone_afterimage(old_loc, L, 1.25 SECONDS)

/datum/action/cooldown/mob_cooldown/kidan_princess/martial_rush/proc/end_rush()
	var/mob/living/basic/megafauna/kidan_princess/princess = owner
	if(!istype(princess))
		return
	UnregisterSignal(princess, COMSIG_MOVABLE_MOVED)
	princess.next_move_modifier = initial(princess.move_speed)
	princess.speed = initial(princess.speed)
	princess.attack_verb_continuous = initial(princess.attack_verb_continuous)
	princess.attack_verb_simple = initial(princess.attack_verb_simple)
	princess.melee_attack_cooldown_min = initial(princess.melee_attack_cooldown_min)
	if(princess.enraged)
		princess.melee_attack_cooldown_max = 1.25 SECONDS
	else
		princess.melee_attack_cooldown_max = initial(princess.melee_attack_cooldown_max)
	princess.melee_damage_lower = initial(princess.melee_damage_lower)
	princess.melee_damage_upper = initial(princess.melee_damage_upper)
	princess.attack_sound = initial(princess.attack_sound)
	princess.martial_rushing = FALSE
	princess.update_icon(UPDATE_ICON_STATE)
