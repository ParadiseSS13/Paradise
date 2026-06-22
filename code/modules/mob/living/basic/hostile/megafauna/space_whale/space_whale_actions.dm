/datum/action/cooldown/mob_cooldown/space_whale/charge
	name = "Violent Charge"
	button_icon_state = "OH_YEAAAAH"
	desc = "Rear back and charge forward!"
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 20 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/space_whale/charge/Activate(atom/target)
	. = ..()
	var/dir_to_target = get_dir(get_turf(owner), get_turf(target))
	var/turf/T = get_step(get_turf(owner), dir_to_target)
	for(var/i in 1 to 9)
		new /obj/effect/temp_visual/dragon_swoop/space_whale(T)
		T = get_step(T, dir_to_target)
	owner.visible_message("<span class='danger'>[owner] prepares to charge!</span>")
	addtimer(CALLBACK(src, PROC_REF(charge_to), dir_to_target, 0), 4)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/space_whale/charge/proc/charge_to(move_dir, times_ran, list/hit_targets = list())
	var/mob/living/basic/whale = owner
	if(times_ran >= 9)
		return
	var/turf/T = get_step(get_turf(owner), move_dir)
	if(ismineralturf(T))
		var/turf/simulated/mineral/M = T
		M.gets_drilled()
	if(iswallturf(T))
		T.dismantle_wall(TRUE)
	for(var/obj/structure/window/W in T.contents)
		W.take_damage(whale.obj_damage, BRUTE)
	for(var/obj/machinery/door/D in T.contents)
		D.take_damage(whale.obj_damage, BRUTE)
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
		owner.visible_message("<span class='danger'>[owner] rams into [L]!</span>")
		to_chat(L, "<span class='userdanger'>[owner] rams into you and bashes you away!</span>")
		L.throw_at(throwtarget, 10, 1, owner)
		L.Weaken(1 SECONDS) // Pain Train has no breaks.
		if(L in hit_targets)
			L.adjustBruteLoss(15)
		else
			hit_targets += L
			L.adjustBruteLoss(25)
	addtimer(CALLBACK(src, PROC_REF(charge_to), move_dir, (times_ran + 1), hit_targets), 0.7)

// The visual effect which appears in front of the whale when it goes to charge.
/obj/effect/temp_visual/dragon_swoop/space_whale
	icon_state = "warning"

/obj/effect/temp_visual/dragon_swoop/space_whale/Initialize(mapload)
	. = ..()
	transform *= 0.33
