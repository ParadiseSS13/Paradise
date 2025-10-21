/*

The Hierophant

The Hierophant spawns in its arena, which makes fighting it challenging but not impossible.

The text this boss speaks is ROT4, use ROT22 to decode

The Hierophant's attacks are as follows;
- These attacks happen at a random, increasing chance:
	If target is at least 2 tiles away; Blinks to the target after a very brief delay, damaging everything near the start and end points.
		As above, but does so multiple times if below half health.
	Rapidly creates cardinal and diagonal Cross Blasts under a target.
	If chasers are off cooldown, creates 4 chasers.

- IF TARGET IS OUTSIDE THE ARENA: Creates an arena around the target for 10 seconds, blinking to the target if not in the created arena.
	The arena has a 20 second cooldown, giving people a small window to get the fuck out.

- If no chasers exist, creates a chaser that will seek its target, leaving a trail of blasts.
	Is more likely to create a second, slower, chaser if hurt.
- If the target is at least 2 tiles away, may Blink to the target after a very brief delay, damaging everything near the start and end points.
- Creates a cardinal or diagonal blast(Cross Blast) under its target, exploding after a short time.
	If below half health, the created Cross Blast may fire in all directions.
- Creates an expanding AoE burst.

- IF ATTACKING IN MELEE: Creates an expanding AoE burst.

Cross Blasts and the AoE burst gain additional range as Hierophant loses health, while Chasers gain additional speed.

When Hierophant dies, it stops trying to murder you and shrinks into a small form, which, while much weaker, is still quite effective.
- The smaller club can place a teleport beacon, allowing the user to teleport themself and their allies to the beacon.

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/hierophant
	name = "hierophant"
	desc = "A massive metal club that hangs in the air as though waiting. It'll make you dance to its beat."
	health = 2500
	maxHealth = 2500
	attacktext = "slams into"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "hierophant"
	icon_living = "hierophant"
	icon_dead = "hierophant_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/hierophant_new.dmi'
	faction = list("boss") //asteroid mobs? get that shit out of my beautiful square house
	speak_emote = list("preaches")
	armor_penetration_percentage = 100 // It does 15 damage / only attacks when enraged
	melee_damage_lower = 15
	melee_damage_upper = 15
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	ranged_cooldown_time = 40
	aggro_vision_range = 21 //so it can see to one side of the arena to the other
	loot = list(/obj/item/hierophant_club)
	difficulty_ore_modifier = 2
	crusher_loot = list(/obj/item/crusher_trophy/vortex_talisman)
	wander = FALSE
	internal_gps = /obj/item/gps/internal/hierophant
	medal_type = BOSS_MEDAL_HIEROPHANT
	score_type = HIEROPHANT_SCORE
	death_sound = 'sound/magic/repulse.ogg'
	enraged_loot = /obj/item/disk/fauna_research/hierophant
	contains_xeno_organ = TRUE
	ignore_generic_organs = TRUE
	surgery_container = /datum/xenobiology_surgery_container/hierophant

	var/burst_range = 3 //range on burst aoe
	var/beam_range = 5 //range on cross blast beams
	var/chaser_speed = 3 //how fast chasers are currently
	var/chaser_cooldown = 101 //base cooldown/cooldown var between spawning chasers
	var/major_attack_cooldown = 60 //base cooldown for major attacks
	var/arena_cooldown = 200 //base cooldown/cooldown var for creating an arena
	var/blinking = FALSE //if we're doing something that requires us to stand still and not attack
	var/obj/effect/hierophant/spawned_beacon //the beacon we teleport back to
	var/timeout_time = 15 //after this many Life() ticks with no target, we return to our beacon
	var/did_reset = TRUE //if we timed out, returned to our beacon, and healed some
	var/list/kill_phrases = list("Wsyvgi sj irivkc xettih. Vitemvmrk...", "Irivkc wsyvgi jsyrh. Vitemvmrk...", "Jyip jsyrh. Egxmzexmrk vitemv gcgpiw...", "Kix fiex. Liepmrk...")
	var/list/target_phrases = list("Xevkix psgexih.", "Iriqc jsyrh.", "Eguymvih xevkix.")
	var/list/stored_nearby = list() // stores people nearby the hierophant when it enters the death animation
	///If the hiero has changed colour, stop the rays animation.
	var/colour_shifting = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/Initialize(mapload)
	. = ..()
	spawned_beacon = new(loc)
	AddComponent(/datum/component/boss_music, 'sound/lavaland/hiero_boss.ogg', 145 SECONDS)

/datum/action/innate/megafauna_attack/blink
	name = "Blink To Target"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now blinking to your target.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/chaser_swarm
	name = "Chaser Swarm"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "hierophant_squares_indefinite"
	chosen_message = "<span class='colossus'>You are firing a chaser swarm at your target.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/cross_blasts
	name = "Cross Blasts"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "hierophant_blast_indefinite"
	chosen_message = "<span class='colossus'>You are now firing cross blasts at your target.</span>"
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/blink_spam
	name = "Blink Chase"
	button_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "hierophant_club_ready_beacon"
	chosen_message = "<span class='colossus'>You are now repeatedly blinking at your target.</span>"
	chosen_attack_num = 4

/mob/living/simple_animal/hostile/megafauna/hierophant/enrage()
	. = ..()
	move_to_delay = 5

/mob/living/simple_animal/hostile/megafauna/hierophant/unrage()
	. = ..()
	move_to_delay = initial(move_to_delay)

/mob/living/simple_animal/hostile/megafauna/hierophant/OpenFire()
	if(blinking)
		return

	calculate_rage()
	var/blink_counter = 1 + round(anger_modifier * 0.08)
	var/cross_counter = 1 + round(anger_modifier * 0.12)

	arena_trap(target)
	ranged_cooldown = world.time + max(5, ranged_cooldown_time - anger_modifier * 0.75) //scale cooldown lower with high anger.

	var/target_slowness = 0
	var/mob/living/L
	if(isliving(target))
		L = target
		target_slowness += L.movement_delay()
	if(client)
		target_slowness += 1

	target_slowness = max(target_slowness, 1)
	chaser_speed = max(1, (3 - anger_modifier * 0.04) + ((target_slowness - 1) * 0.5))

	if(client)
		switch(chosen_attack)
			if(1)
				blink(target)
			if(2)
				chaser_swarm(blink_counter, target_slowness, cross_counter)
			if(3)
				cross_blast_spam(blink_counter, target_slowness, cross_counter)
			if(4)
				blink_spam(blink_counter, target_slowness, cross_counter)
		return

	if(L?.stat == DEAD && !blinking && get_dist(src, L) > 2)
		blink(L)
		return

	if(prob(anger_modifier * 0.75)) //major ranged attack
		var/list/possibilities = list()
		if(cross_counter > 1)
			possibilities += "cross_blast_spam"
		if(get_dist(src, target) > 2)
			possibilities += "blink_spam"
		if(chaser_cooldown < world.time)
			if(prob(anger_modifier * 2))
				possibilities = list("chaser_swarm")
			else
				possibilities += "chaser_swarm"
		if(length(possibilities))
			switch(pick(possibilities))
				if("blink_spam") //blink either once or multiple times.
					blink_spam(blink_counter, target_slowness, cross_counter)
				if("cross_blast_spam") //fire a lot of cross blasts at a target.
					cross_blast_spam(blink_counter, target_slowness, cross_counter)
				if("chaser_swarm") //fire four fucking chasers at a target and their friends.
					chaser_swarm(blink_counter, target_slowness, cross_counter)
			return

	if(chaser_cooldown < world.time) //if chasers are off cooldown, fire some!
		var/obj/effect/temp_visual/hierophant/chaser/C = new /obj/effect/temp_visual/hierophant/chaser(loc, src, target, chaser_speed, FALSE)
		chaser_cooldown = world.time + initial(chaser_cooldown)
		if((prob(anger_modifier) || target.Adjacent(src)) && target != src)
			var/obj/effect/temp_visual/hierophant/chaser/OC = new(loc, src, target, chaser_speed * 1.5, FALSE)
			OC.moving = 4
			OC.moving_dir = pick(GLOB.cardinal - C.moving_dir)

	else if(prob(10 + (anger_modifier * 0.5)) && get_dist(src, target) > 2)
		blink(target)

	else if(prob(70 - anger_modifier)) //a cross blast of some type
		if(prob(anger_modifier * (2 / target_slowness)) && health < maxHealth * 0.5) //we're super angry do it at all dirs
			INVOKE_ASYNC(src, PROC_REF(blasts), target, GLOB.alldirs)
		else if(prob(60))
			INVOKE_ASYNC(src, PROC_REF(blasts), target, GLOB.cardinal)
		else
			INVOKE_ASYNC(src, PROC_REF(blasts), target, GLOB.diagonals)
	else //just release a burst of power
		INVOKE_ASYNC(src, PROC_REF(burst), get_turf(src))

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/easy_anti_cheese(mob/living/simple_animal/S)
	if(enraged || get_dist(S, src) > 20)
		return
	for(var/mob/living/L in urange(20, src))
		if(L.client)
			enrage()
			arena_trap(L, TRUE)
			FindTarget(list(L), 1)
			for(var/mob/living/simple_animal/hostile/megafauna/colossus/C in GLOB.mob_list)
				UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE)
			break

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blink_spam(blink_counter, target_slowness, cross_counter)
	ranged_cooldown = world.time + max(5, major_attack_cooldown - anger_modifier * 0.75)
	if(((health < maxHealth * 0.5) || enraged) && blink_counter > 1)
		visible_message("<span class='hierophant'>\"Mx ampp rsx iwgeti.\"</span>")
		var/oldcolor = color
		animate(src, color = "#660099", time = 6)
		colour_shifting = TRUE
		remove_filter("rays")
		SLEEP_CHECK_DEATH(6)
		while(!QDELETED(target) && blink_counter)
			if(loc == target.loc || loc == target) //we're on the same tile as them after about a second we can stop now
				break
			blink_counter--
			blinking = FALSE
			blink(target)
			blinking = TRUE
			SLEEP_CHECK_DEATH(4 + target_slowness)
		animate(src, color = oldcolor, time = 8)
		colour_shifting = FALSE
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)
		SLEEP_CHECK_DEATH(8)
		blinking = FALSE
	else
		blink(target)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/cross_blast_spam(blink_counter, target_slowness, cross_counter)
	ranged_cooldown = world.time + max(5, major_attack_cooldown - anger_modifier * 0.75)
	visible_message("<span class='hierophant'>\"Piezi mx rsalivi xs vyr.\"</span>")
	blinking = TRUE
	var/oldcolor = color
	animate(src, color = "#660099", time = 6)
	colour_shifting = TRUE
	remove_filter("rays")
	SLEEP_CHECK_DEATH(6)
	while(!QDELETED(target) && cross_counter)
		cross_counter--
		if(prob(60))
			INVOKE_ASYNC(src, PROC_REF(blasts), target, GLOB.cardinal)
		else
			INVOKE_ASYNC(src, PROC_REF(blasts), target, GLOB.diagonals)
		SLEEP_CHECK_DEATH(6 + target_slowness)
	animate(src, color = oldcolor, time = 8)
	colour_shifting = FALSE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)
	SLEEP_CHECK_DEATH(8)
	blinking = FALSE


/mob/living/simple_animal/hostile/megafauna/hierophant/proc/chaser_swarm(blink_counter, target_slowness, cross_counter)
	ranged_cooldown = world.time + max(5, major_attack_cooldown - anger_modifier * 0.75)
	visible_message("<span class='hierophant'>\"Mx gerrsx lmhi.\"</span>")
	blinking = TRUE
	var/oldcolor = color
	animate(src, color = "#660099", time = 6)
	colour_shifting = TRUE
	remove_filter("rays")
	SLEEP_CHECK_DEATH(6)
	var/list/targets = ListTargets()
	var/list/cardinal_copy = GLOB.cardinal.Copy()
	while(length(targets) && length(cardinal_copy))
		var/mob/living/pickedtarget = pick(targets)
		if(length(targets) >= length(cardinal_copy))
			pickedtarget = pick_n_take(targets)
		if(!istype(pickedtarget) || pickedtarget.stat == DEAD)
			pickedtarget = target
			if(QDELETED(pickedtarget) || (istype(pickedtarget) && pickedtarget.stat == DEAD))
				break //main target is dead and we're out of living targets, cancel out
		var/obj/effect/temp_visual/hierophant/chaser/C = new(loc, src, pickedtarget, chaser_speed, FALSE)
		C.moving = 3
		C.moving_dir = pick_n_take(cardinal_copy)
		SLEEP_CHECK_DEATH(8 + target_slowness)
	chaser_cooldown = world.time + initial(chaser_cooldown)
	animate(src, color = oldcolor, time = 8)
	colour_shifting = FALSE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)
	SLEEP_CHECK_DEATH(8)
	blinking = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blasts(mob/victim, list/directions = GLOB.cardinal) //fires cross blasts with a delay
	var/turf/T = get_turf(victim)
	if(!T)
		return
	if(directions == GLOB.cardinal)
		new /obj/effect/temp_visual/hierophant/telegraph/cardinal(T, src)
	else if(directions == GLOB.diagonals)
		new /obj/effect/temp_visual/hierophant/telegraph/diagonal(T, src)
	else
		new /obj/effect/temp_visual/hierophant/telegraph(T, src)
	playsound(T,'sound/effects/bin_close.ogg', 75, TRUE)
	SLEEP_CHECK_DEATH(2)
	new /obj/effect/temp_visual/hierophant/blast(T, src, FALSE)
	for(var/d in directions)
		INVOKE_ASYNC(src, PROC_REF(blast_wall), T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blast_wall(turf/T, set_dir) //make a wall of blasts beam_range tiles long
	var/range = beam_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, set_dir)
	for(var/i in 1 to range)
		new /obj/effect/temp_visual/hierophant/blast(J, src, FALSE)
		previousturf = J
		J = get_step(previousturf, set_dir)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/arena_trap(mob/victim, forced = FALSE) //trap a target in an arena
	var/turf/T = get_turf(victim)
	if(!istype(victim) || victim.stat == DEAD || !T || arena_cooldown > world.time)
		return
	if((istype(get_area(T), /area/ruin/unpowered/hierophant) || istype(get_area(src), /area/ruin/unpowered/hierophant)) && victim != src)
		if(!forced)
			return
	arena_cooldown = world.time + initial(arena_cooldown)
	for(var/d in GLOB.cardinal)
		INVOKE_ASYNC(src, PROC_REF(arena_squares), T, d)
	for(var/t in RANGE_EDGE_TURFS(11, T))
		new /obj/effect/temp_visual/hierophant/wall(t, src)
		new /obj/effect/temp_visual/hierophant/blast(t, src, FALSE)
	if(get_dist(src, T) >= 11 || forced) //hey you're out of range I need to get closer to you!
		INVOKE_ASYNC(src, PROC_REF(blink), T)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/arena_squares(turf/T, set_dir) //make a fancy effect extending from the arena target
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, set_dir)
	for(var/i in 1 to 10)
		var/obj/effect/temp_visual/hierophant/squares/HS = new(J)
		HS.setDir(set_dir)
		previousturf = J
		J = get_step(previousturf, set_dir)
		SLEEP_CHECK_DEATH(0.5)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blink(mob/victim) //blink to a target
	if(blinking || !victim)
		return
	if(victim.z != z)
		return
	var/turf/T = get_turf(victim)
	var/turf/source = get_turf(src)
	new /obj/effect/temp_visual/hierophant/telegraph(T, src)
	new /obj/effect/temp_visual/hierophant/telegraph(source, src)
	playsound(T,'sound/magic/wand_teleport.ogg', 80, TRUE)
	playsound(source,'sound/machines/airlock_open.ogg', 80, TRUE)
	blinking = TRUE
	SLEEP_CHECK_DEATH(2) //short delay before we start...
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, src)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, src)
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/temp_visual/hierophant/blast/B = new(t, src, FALSE)
		B.damage = 30
	for(var/t in RANGE_TURFS(1, source))
		var/obj/effect/temp_visual/hierophant/blast/B = new(t, src, FALSE)
		B.damage = 30
	animate(src, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	SLEEP_CHECK_DEATH(1)
	visible_message("<span class='hierophant_warning'>[src] fades out!</span>")
	density = FALSE
	SLEEP_CHECK_DEATH(2)
	forceMove(T)
	SLEEP_CHECK_DEATH(1)
	animate(src, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	SLEEP_CHECK_DEATH(1)
	density = TRUE
	visible_message("<span class='hierophant_warning'>[src] fades in!</span>")
	SLEEP_CHECK_DEATH(1) //at this point the blasts we made detonate
	blinking = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/melee_blast(mob/victim) //make a 3x3 blast around a target
	if(!victim)
		return
	var/turf/T = get_turf(victim)
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph(T, src)
	playsound(T,'sound/effects/bin_close.ogg', 75, TRUE)
	SLEEP_CHECK_DEATH(2)
	for(var/t in RANGE_TURFS(1, T))
		new /obj/effect/temp_visual/hierophant/blast(t, src, FALSE)

//expanding square
/proc/hierophant_burst(mob/caster, turf/original, burst_range, spread_speed = 0.5)
	playsound(original,'sound/machines/airlock_open.ogg', 75, TRUE)
	var/last_dist = 0
	for(var/t in spiral_range_turfs(burst_range, original))
		var/turf/T = t
		if(!T)
			continue
		var/dist = get_dist(original, T)
		if(dist > last_dist)
			last_dist = dist
			sleep(1 + min(burst_range - last_dist, 12) * spread_speed) //gets faster as it gets further out
		new /obj/effect/temp_visual/hierophant/blast(T, caster, FALSE)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/burst(turf/original, spread_speed)
	hierophant_burst(src, original, burst_range, spread_speed)

/mob/living/simple_animal/hostile/megafauna/hierophant/float(on) //we don't want this guy to float, messes up his animations
	if(throwing)
		return
	floating = on

/mob/living/simple_animal/hostile/megafauna/hierophant/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!enraged) //We do not want it to animate attacking as that breaks the cool animation. If it is not enraged, it can do it. However this only happens if admin controlled
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Life()
	. = ..()
	if(enraged && !colour_shifting)
		var/new_filter = isnull(get_filter("ray"))
		ray_filter_helper(1, 40, "#660099", 6, 20, 16)
		if(new_filter)
			animate(get_filter("ray"), offset = 10, y = 8, time = 10 SECONDS, loop = -1)
			animate(offset = 0, time = 10 SECONDS)
	else
		remove_filter("ray")
	if(. && spawned_beacon && !QDELETED(spawned_beacon) && !client)
		if(target || loc == spawned_beacon.loc)
			timeout_time = initial(timeout_time)
		else
			timeout_time--
		if(timeout_time <= 0 && !did_reset)
			did_reset = TRUE
			visible_message("<span class='hierophant_warning'>\"Vixyvrmrk xs fewi...\"</span>")
			blink(spawned_beacon)
			adjustHealth(min((health - maxHealth) * 0.5, -250)) //heal for 50% of our missing health, minimum 10% of maximum health
			wander = FALSE
			if(health > maxHealth * 0.9)
				visible_message("<span class='hierophant'>\"Vitemvw gsqtpixi. Stivexmrk ex qebmqyq ijjmgmirgc.\"</span>")
			else
				visible_message("<span class='hierophant'>\"Vitemvw gsqtpixi. Stivexmsrep ijjmgmirgc gsqtvsqmwih.\"</span>")

/mob/living/simple_animal/hostile/megafauna/hierophant/death()
	if(health > 0 || stat == DEAD)
		return
	else
		for(var/mob/living/simple_animal/hostile/megafauna/colossus/C in GLOB.mob_list)
			UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE)
		set_stat(DEAD)
		blinking = TRUE //we do a fancy animation, release a huge burst(), and leave our staff.
		visible_message("<span class='hierophant'>\"Mrmxmexmrk wipj-hiwxvygx wiuyirgi...\"</span>")
		visible_message("<span class='hierophant_warning'>[src] shrinks, releasing a massive burst of energy!</span>")
		for(var/mob/living/L in view(7, src))
			stored_nearby += L // store the people to grant the achievements to once we die
		hierophant_burst(null, get_turf(src), 10)
		set_stat(CONSCIOUS) // deathgasp wont run if dead, stupid
		for(var/turf/simulated/wall/indestructible/hierophant/T in GLOB.hierophant_walls)
			T.collapse()
		icon = 'icons/mob/lavaland/corpses.dmi'
		DeleteComponent(/datum/component/boss_music)
		..(/* force_grant = stored_nearby */)

/mob/living/simple_animal/hostile/megafauna/hierophant/Destroy()
	QDEL_NULL(spawned_beacon)
	return ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/devour(mob/living/L)
	for(var/obj/item/W in L)
		if(!L.drop_item_to_ground(W))
			qdel(W)
	visible_message("<span class='hierophant_warning'>\"[pick(kill_phrases)]\"</span>")
	visible_message("<span class='hierophant_warning'>[src] annihilates [L]!</span>","<span class='userdanger'>You annihilate [L], restoring your health!</span>")
	adjustHealth(-L.maxHealth*0.5)
	L.dust()

/mob/living/simple_animal/hostile/megafauna/hierophant/CanAttack(atom/the_target)
	. = ..()
	if(istype(the_target, /mob/living/basic/mining/hivelordbrood)) //ignore temporary targets in favor of more permanent targets
		return FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		visible_message("<span class='hierophant_warning'>\"[pick(target_phrases)]\"</span>")
		if(spawned_beacon && loc == spawned_beacon.loc && did_reset)
			arena_trap(src)

/mob/living/simple_animal/hostile/megafauna/hierophant/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(src && . && !blinking)
		wander = TRUE
		did_reset = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/AttackingTarget()
	if(!blinking)
		if(target && isliving(target))
			var/mob/living/L = target
			if(L.stat != DEAD)
				if(enraged)
					..()
					if(L.move_resist < INFINITY)
						var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
						L.throw_at(throw_target, 1, 2) //Yeet them away. Makes crusher harder / stops endless backstab
				if(ranged_cooldown <= world.time)
					calculate_rage()
					ranged_cooldown = world.time + max(5, ranged_cooldown_time - anger_modifier * 0.75)
					INVOKE_ASYNC(src, PROC_REF(burst), get_turf(src))
				else
					burst_range = 3
					INVOKE_ASYNC(src, PROC_REF(burst), get_turf(src), 0.25) //melee attacks on living mobs cause it to release a fast burst if on cooldown
				OpenFire()
			else
				devour(L)
		else
			return ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/DestroySurroundings()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Move()
	if(!blinking)
		. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Moved(oldLoc, movement_dir)
	. = ..()
	if(stat == CONSCIOUS && .)
		var/obj/effect/temp_visual/hierophant/squares/HS = new(oldLoc)
		HS.setDir(movement_dir)
		playsound(src, 'sound/mecha/mechmove04.ogg', 65, TRUE, -4)
		if(target)
			arena_trap(target)

/mob/living/simple_animal/hostile/megafauna/hierophant/Goto(target, delay, minimum_distance)
	wander = TRUE
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/calculate_rage() //how angry we are overall
	did_reset = FALSE //oh hey we're doing SOMETHING, clearly we might need to heal if we recall
	anger_modifier = clamp((max((maxHealth - health) / 42, enraged ? 40 : 0)),0,50)
	burst_range = initial(burst_range) + round(anger_modifier * 0.08)
	beam_range = initial(beam_range) + round(anger_modifier * 0.12)

/mob/living/simple_animal/hostile/megafauna/hierophant/bullet_act(obj/item/projectile/P)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client)
		if(P.firer && get_dist(src, P.firer) <= aggro_vision_range)
			FindTarget(list(P.firer), 1)
		Goto(P.starting, move_to_delay, 3)
	..()

//Hierophant overlays
/obj/effect/temp_visual/hierophant
	name = "vortex energy"
	layer = BELOW_MOB_LAYER
	var/mob/living/caster //who made this, anyway

/obj/effect/temp_visual/hierophant/Initialize(mapload, new_caster)
	. = ..()
	if(new_caster)
		caster = new_caster

/obj/effect/temp_visual/hierophant/squares
	icon_state = "hierophant_squares"
	duration = 3
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	randomdir = FALSE

/obj/effect/temp_visual/hierophant/squares/Initialize(mapload, new_caster)
	. = ..()
	if(ismineralturf(loc))
		var/turf/simulated/mineral/M = loc
		M.gets_drilled(caster)

/// smoothing and pooling were not friends, but pooling is dead.
/obj/effect/temp_visual/hierophant/wall
	name = "vortex wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "hierophant_wall_temp-0"
	base_icon_state = "hierophant_wall_temp"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	duration = 100

/obj/effect/temp_visual/hierophant/wall/Initialize(mapload, new_caster)
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

/obj/effect/temp_visual/hierophant/wall/Destroy()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/temp_visual/hierophant/wall/CanPass(atom/movable/mover, border_dir)
	if(QDELETED(caster))
		return FALSE
	if(mover == caster.pulledby)
		return TRUE
	if(isprojectile(mover))
		var/obj/item/projectile/P = mover
		if(P.firer == caster)
			return TRUE
	if(mover == caster)
		return TRUE
	return FALSE

/// a hierophant's chaser. follows target around, moving and producing a blast every speed deciseconds.
/obj/effect/temp_visual/hierophant/chaser
	duration = 98
	var/mob/living/target //what it's following
	var/turf/targetturf //what turf the target is actually on
	var/moving_dir //what dir it's moving in
	var/previous_moving_dir //what dir it was moving in before that
	var/more_previouser_moving_dir //what dir it was moving in before THAT
	var/moving = 0 //how many steps to move before recalculating
	var/standard_moving_before_recalc = 4 //how many times we step before recalculating normally
	var/tiles_per_step = 1 //how many tiles we move each step
	var/speed = 3 //how many deciseconds between each step
	var/currently_seeking = FALSE
	var/friendly_fire_check = FALSE //if blasts produced apply friendly fire
	var/monster_damage_boost = TRUE
	var/damage = 10

/obj/effect/temp_visual/hierophant/chaser/Initialize(mapload, new_caster, new_target, new_speed, is_friendly_fire)
	. = ..()
	target = new_target
	friendly_fire_check = is_friendly_fire
	if(new_speed)
		speed = new_speed
	addtimer(CALLBACK(src, PROC_REF(seek_target)), 1)

/obj/effect/temp_visual/hierophant/chaser/proc/get_target_dir()
	. = get_cardinal_dir(src, targetturf)
	if((. != previous_moving_dir && . == more_previouser_moving_dir) || . == 0) //we're alternating, recalculate
		var/list/cardinal_copy = GLOB.cardinal.Copy()
		cardinal_copy -= more_previouser_moving_dir
		. = pick(cardinal_copy)

/obj/effect/temp_visual/hierophant/chaser/proc/seek_target()
	if(!currently_seeking)
		currently_seeking = TRUE
		targetturf = get_turf(target)
		while(target && src && !QDELETED(src) && currently_seeking && x && y && targetturf) //can this target actually be sook out
			if(!moving) //we're out of tiles to move, find more and where the target is!
				more_previouser_moving_dir = previous_moving_dir
				previous_moving_dir = moving_dir
				moving_dir = get_target_dir()
				var/standard_target_dir = get_cardinal_dir(src, targetturf)
				if((standard_target_dir != previous_moving_dir && standard_target_dir == more_previouser_moving_dir) || standard_target_dir == 0)
					moving = 1 //we would be repeating, only move a tile before checking
				else
					moving = standard_moving_before_recalc
			if(moving) //move in the dir we're moving in right now
				var/turf/T = get_turf(src)
				for(var/i in 1 to tiles_per_step)
					var/maybe_new_turf = get_step(T, moving_dir)
					if(maybe_new_turf)
						T = maybe_new_turf
					else
						break
				forceMove(T)
				make_blast() //make a blast, too
				moving--
				sleep(speed)
			targetturf = get_turf(target)

/obj/effect/temp_visual/hierophant/chaser/proc/make_blast()
	var/obj/effect/temp_visual/hierophant/blast/B = new(loc, caster, friendly_fire_check)
	B.damage = damage
	B.monster_damage_boost = monster_damage_boost

/obj/effect/temp_visual/hierophant/telegraph
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hierophant_telegraph"
	pixel_x = -32
	pixel_y = -32
	duration = 3

/obj/effect/temp_visual/hierophant/telegraph/diagonal
	icon_state = "hierophant_telegraph_diagonal"

/obj/effect/temp_visual/hierophant/telegraph/cardinal
	icon_state = "hierophant_telegraph_cardinal"

/obj/effect/temp_visual/hierophant/telegraph/teleport
	icon_state = "hierophant_telegraph_teleport"
	duration = 9

/obj/effect/temp_visual/hierophant/telegraph/edge
	icon_state = "hierophant_telegraph_edge"
	duration = 40

/obj/effect/temp_visual/hierophant/blast
	icon_state = "hierophant_blast"
	name = "vortex blast"
	light_range = 2
	light_power = 2
	desc = "Get out of the way!"
	duration = 9
	var/damage = 10 //how much damage do we do?
	var/monster_damage_boost = TRUE //do we deal extra damage to monsters? Used by the boss
	var/list/hit_things = list() //we hit these already, ignore them
	var/friendly_fire_check = FALSE
	var/bursting = FALSE //if we're bursting and need to hit anyone crossing us

/obj/effect/temp_visual/hierophant/blast/Initialize(mapload, new_caster, friendly_fire)
	. = ..()
	friendly_fire_check = friendly_fire
	if(new_caster)
		hit_things += new_caster
	if(ismineralturf(loc)) //drill mineral turfs
		var/turf/simulated/mineral/M = loc
		M.gets_drilled(caster)
	INVOKE_ASYNC(src, PROC_REF(blast))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/hierophant/blast/proc/blast()
	var/turf/T = get_turf(src)
	if(!T)
		return
	playsound(T,'sound/magic/blind.ogg', 65, TRUE, -5) //make a sound
	sleep(6) //wait a little
	bursting = TRUE
	do_damage(T) //do damage and mark us as bursting
	sleep(1.3) //slightly forgiving; the burst animation is 1.5 deciseconds
	bursting = FALSE //we no longer damage crossers

/obj/effect/temp_visual/hierophant/blast/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(!bursting)
		return

	if(ismecha(entered))
		damage_mech(entered)
	else if(isliving(entered))
		damage_living(entered)

/obj/effect/temp_visual/hierophant/blast/proc/damage_living(mob/living/target)
	if(!istype(target))
		return
	if(target in hit_things)
		return

	hit_things |= target
	if((friendly_fire_check && caster && target.faction_check_mob(caster)) || target.stat == DEAD)
		return

	target.flash_screen_color("#660099", 1)
	playsound(target,'sound/weapons/sear.ogg', 50, TRUE, -4)
	to_chat(target, "<span class='userdanger'>You're struck by \a [name]!</span>")
	var/limb_to_hit = target.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	var/armor = target.run_armor_check(limb_to_hit, MELEE, "Your armor absorbs [src]!", "Your armor blocks part of [src]!", "Your armor was penetrated by [src]!", 50)
	target.apply_damage(damage, BURN, limb_to_hit, armor)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target //mobs find and damage you...
		if(H.stat == CONSCIOUS && !H.target && H.AIStatus != AI_OFF && !H.client)
			if(!QDELETED(caster))
				if(get_dist(H, caster) <= H.aggro_vision_range)
					H.FindTarget(list(caster), 1)
				else
					H.Goto(get_turf(caster), H.move_to_delay, 3)
	if(monster_damage_boost && (ismegafauna(target) || istype(target, /mob/living/simple_animal/hostile/asteroid)))
		target.adjustBruteLoss(damage)
	if(caster)
		add_attack_logs(caster, target, "Struck with a [name]")

/obj/effect/temp_visual/hierophant/blast/proc/damage_mech(obj/mecha/target)
	if(!istype(target))
		return
	if(target in hit_things)
		return

	hit_things |= target
	if(target.occupant)
		if(friendly_fire_check && caster && caster.faction_check_mob(target.occupant))
			return
		to_chat(target.occupant, "<span class='userdanger'>Your [target.name] is struck by \a [name]!</span>")
	playsound(target, 'sound/weapons/sear.ogg', 50, TRUE, -4)
	target.take_damage(damage, BURN, 0, 0)

/obj/effect/temp_visual/hierophant/blast/proc/do_damage(turf/T)
	if(!damage)
		return
	for(var/mob/living/L in T.contents - hit_things) //find and damage mobs...
		damage_living(L)
	for(var/obj/mecha/M in T.contents - hit_things) //also damage mechs.
		damage_mech(M)

/obj/effect/hierophant
	name = "hierophant beacon"
	desc = "A strange beacon, allowing mass teleportation for those able to use it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "hierophant_tele_off"
	light_range = 2
	layer = LOW_OBJ_LAYER

/obj/effect/hierophant/ex_act()
	return

/obj/effect/hierophant/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/club = used
		if(club.timer > world.time)
			return ITEM_INTERACT_COMPLETE
		if(club.beacon == src)
			to_chat(user, "<span class='notice'>You start removing your hierophant beacon...</span>")
			club.timer = world.time + 51
			INVOKE_ASYNC(club, TYPE_PROC_REF(/obj/item/hierophant_club, prepare_icon_update))
			if(do_after(user, 50, target = src))
				playsound(src,'sound/magic/blind.ogg', 200, TRUE, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(get_turf(src), user)
				to_chat(user, "<span class='hierophant_warning'>You collect [src], reattaching it to the club!</span>")
				club.beacon = null
				user.update_action_buttons_icon()
				qdel(src)
			else
				club.timer = world.time
				INVOKE_ASYNC(club, TYPE_PROC_REF(/obj/item/hierophant_club, prepare_icon_update))
		else
			to_chat(user, "<span class='hierophant_warning'>You touch the beacon with the club, but nothing happens.</span>")
		return ITEM_INTERACT_COMPLETE

/obj/item/gps/internal/hierophant
	icon_state = null
	gpstag = "Zealous Signal"
	desc = "Heed its words."
