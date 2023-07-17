#define BODY_SHIELD_COOLDOWN_TIME 5 SECONDS
#define EXTRA_PLAYER_ANGER_NORMAL_CAP 6
#define EXTRA_PLAYER_ANGER_STATION_CAP 3
#define BLUESPACE 1
#define GRAV 2
#define PYRO 3
#define FLUX 4
#define VORTEX 5
#define CRYO 6
#define TOP_RIGHT 1
#define TOP_LEFT 2
#define BOTTOM_RIGHT 3
#define BOTTOM_LEFT 4


/*

Vetus Speculator

An old 4 legged self learning robot made from a long gone civilization. Likes to scan and learn from things... Including crewmembers.

Hybrid ranged / melee combatant, similar to bubblegum.

It has several attacks at it's disposal. It can melee with it's body and legs, however a person will not be hit by both at once unless poorly positioned. Legs also have a weak turret on each leg, that can be broken via damage.

Every 5 seconds it creates a shield around itself, that blocks 1 hit, or multiple non damaging hits. Crusher users will need blast tube to break the shield, OR melee the robot with shield up to de-activate it.

The main feature that makes it unique, is that it has 5 modes, based on each anomaly core, that can augment it's remaning attacks.

It can charge like bubblegum. If it has a pyro core, it makes a trail of fire and temporary lava. If it is bluespace, it charges with more delay between charges, but instead teleports between charges, to make it less predictable. Grav throws people if they bump into them during charge.

It can spawn 3 anomalies around it for 15 seconds with a low chance. They do not explode / mass teleport / spawn slimes.

Finaly, for each mode, it has a special attack.
	- Bluespace causes it's current target to have half attack speed for 10 seconds.
	- Grav picks up rocks from the terrain, and throws them at the target.
	- Pyro turns 3x3 areas around the target (but not too close) into lava.
	- Flux shoots weakened tesla revolver shots at all humans nearby.
	- Vortex causes a small earthquake, leading to rocks falling from the sky.

Upon reaching critical HP (normally death), it preps a 10 second self destruct, before exploding. Large tell, hard to miss.
Loot: Anomaly core that matches the mode that was picked of the robot. A pinpointer that can point to tendrils, which should be fine, as by the time this is killed, the round should be an hour or more over. As well as a variety of raw ores.
Crusher Loot: Adaptive inteligence core, a trophy that temporarly increases the force of a crusher against a target it has hit within the last 30 seconds by 2 per hit, up to 20 extra force.

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/ancient_robot
	name = "\improper Vetus Speculator"
	desc = "An ancient robot from a long forgotten civilization. Adapts to the environment, and what it finds, to be the ideal combatant."
	health = 2500
	maxHealth = 2500
	attacktext = "shocks"
	attack_sound = 'sound/machines/defib_zap.ogg'
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "ancient_robot"
	icon_living = "ancient_robot"
	friendly = "stares down"
	speak_emote = list("BUZZES")
	universal_speak = TRUE
	universal_understand = TRUE
	armour_penetration_percentage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_damage_type = BURN //Legs do the stomping, this is just a shock
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	pixel_y = -16
	del_on_death = TRUE
	loot = list(/obj/structure/closet/crate/necropolis/ancient)
	crusher_loot = list(/obj/structure/closet/crate/necropolis/ancient/crusher)
	internal_gps = /obj/item/gps/internal/ancient
	medal_type = BOSS_MEDAL_ROBOT
	score_type = ROBOT_SCORE
	deathmessage = "explodes into a shower of alloys"
	footstep_type = FOOTSTEP_MOB_HEAVY //make stomp like bubble
	attack_action_types = list()

	var/charging = FALSE
	var/revving_charge = FALSE
	var/player_cooldown = 0
	var/body_shield_enabled = FALSE
	var/extra_player_anger = 0
	var/mode = 0 //This variable controls the special attacks of the robot, one for each anomaly core.
	var/exploding = FALSE

/// Legs and the connector for the legs

	var/mob/living/simple_animal/hostile/ancient_robot_leg/TR = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/TL = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/BR = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/BL = null
	var/obj/effect/abstract/beam = null

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Initialize(mapload, mob/living/ancient) //We spawn and move them to clear out area for the legs, rather than risk the legs getting put in a wall
	. = ..()
	TR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, TOP_RIGHT)
	TL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, TOP_LEFT)
	BR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, BOTTOM_RIGHT)
	BL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, BOTTOM_LEFT)
	beam = new /obj/effect/abstract(loc)
	mode = pick(BLUESPACE, GRAV, PYRO, FLUX, VORTEX, CRYO) //picks one of the 6 cores
	if(mode == FLUX) // Main attack is shock, so flux makes it stronger
		melee_damage_lower = 25
		melee_damage_upper = 25
	body_shield()
	add_overlay("[mode]")
	add_overlay("eyes")
	return INITIALIZE_HINT_LATELOAD

/mob/living/simple_animal/hostile/megafauna/ancient_robot/LateInitialize()
	fix_specific_leg(TOP_RIGHT)
	fix_specific_leg(TOP_LEFT)
	fix_specific_leg(BOTTOM_RIGHT)
	fix_specific_leg(BOTTOM_LEFT)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/Destroy()
	QDEL_NULL(TR)
	QDEL_NULL(TL)
	QDEL_NULL(BR)
	QDEL_NULL(BL)
	QDEL_NULL(beam)
	return ..()

/obj/item/gps/internal/ancient
	icon_state = null
	gpstag = "Malfunctioning Signal"
	desc = "ERROR_NULL_ENTRY"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/ancient_robot/death(gibbed, allowed = FALSE)
	if(allowed)
		return ..()
	else if(exploding) //but it refused
		return
	adjustBruteLoss(-1)
	self_destruct()
	exploding = TRUE


/mob/living/simple_animal/hostile/megafauna/ancient_robot/Life(seconds, times_fired)
	..()
	if(!exploding)
		return
	playsound(src, 'sound/items/timer.ogg', 70, 0)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/drop_loot()
	var/core_type = null
	switch(mode)
		if(BLUESPACE)
			core_type = /obj/item/assembly/signaler/anomaly/bluespace
		if(GRAV)
			core_type = /obj/item/assembly/signaler/anomaly/grav
		if(PYRO)
			core_type = /obj/item/assembly/signaler/anomaly/pyro
		if(FLUX)
			core_type = /obj/item/assembly/signaler/anomaly/flux
		if(VORTEX)
			core_type = /obj/item/assembly/signaler/anomaly/vortex
		if(CRYO)
			core_type = /obj/item/assembly/signaler/anomaly/cryo

	var/crate_type = pick(loot)
	var/obj/structure/closet/crate/C = new crate_type(loc)
	new core_type(C)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/OpenFire()
	if(charging)
		return

	if(exploding)
		return

	anger_modifier = clamp(((maxHealth - health) / 50), 0, 20)
	ranged_cooldown = world.time + (ranged_cooldown_time * ((10 - extra_player_anger) / 10))

	if(prob(30 + (anger_modifier / 2))) //Less scaling as the weaker attack / first calculated.
		triple_charge()

	else if(prob(15 + anger_modifier))
		spawn_anomalies()

	else if(prob(60 + anger_modifier))
		do_special_move()

	calculate_extra_player_anger()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/triple_charge()
	if(mode == BLUESPACE)
		charge(delay = 24) //An extra charge, to make up for the longer time between teleports
		charge(delay = 18)
		charge(delay = 12)
		charge(delay = 6)
	else
		charge(delay = 9)
		charge(delay = 6)
		charge(delay = 3)
	SetRecoveryTime(15)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/charge(atom/chargeat = target, delay = 5, chargepast = 2) //add limb charge as well
	if(!chargeat)
		return
	if(mode == BLUESPACE)
		new /obj/effect/temp_visual/bsg_kaboom(get_turf(src))
		src.visible_message("<span class='danger'>[src] teleports somewhere nearby!</span>")
		do_teleport(src, target, 7, sound_in = 'sound/effects/phasein.ogg', safe_turf_pick = TRUE) //Teleport within 7 tiles of the target
		new /obj/effect/temp_visual/bsg_kaboom(get_turf(src))

		TR.health_and_snap_check(FALSE)// We want the legs to instantly teleport with it, without regening
		TL.health_and_snap_check(FALSE)
		BR.health_and_snap_check(FALSE)
		BL.health_and_snap_check(FALSE)

	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, chargepast)
	if(!T)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum/ancient_robot(T, beam)
	charging = TRUE
	revving_charge = TRUE
	DestroySurroundings()
	walk(src, 0)
	setDir(dir)
	SLEEP_CHECK_DEATH(delay)
	revving_charge = FALSE
	var/movespeed = 0.8
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/MeleeAction(patience = TRUE)
	if(charging)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Bump(atom/A, yes)
	if(charging)
		DestroySurroundings()
		if(isliving(A) && yes)
			var/mob/living/L = A
			if(!istype(A, /mob/living/simple_animal/hostile/ancient_robot_leg))
				L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
				forceMove(get_turf(L))
				var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
				L.apply_damage(25, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration_flat, armour_penetration_percentage))
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
				shake_camera(L, 4, 3)
				shake_camera(src, 2, 3)
				if(mode == GRAV)
					var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
					L.throw_at(throw_target, 3, 2)
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/body_shield()
	body_shield_enabled = TRUE
	visible_message("<span class='danger'>[src] creates some sort of energy shield!</span>")
	add_overlay("shield")

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_shield()
	visible_message("<span class='danger'>[src]'s shield fails!</span>")
	cut_overlay("shield")
	body_shield_enabled = FALSE
	addtimer(CALLBACK(src, PROC_REF(body_shield)), BODY_SHIELD_COOLDOWN_TIME)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/bullet_act(obj/item/projectile/P)
	if(!body_shield_enabled)
		return ..()
	do_sparks(2, 1, src)
	visible_message("<span class='danger'>[src]'s shield deflects [P] in a shower of sparks!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
	if(P.damage)
		disable_shield()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/attacked_by(obj/item/I, mob/living/user)
	if(!body_shield_enabled)
		return ..()
	do_sparks(2, 1, src)
	visible_message("<span class='danger'>[src]'s shield deflects [I] in a shower of sparks!</span>", "<span class='userdanger'>You deflect the attack!</span>")
	if(I.force)
		disable_shield()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/devour(mob/living/L)
	say(pick("JKYZXAIZOBK GTGREYKX GIZOBK", "OTZKMXGZOTM YAHPKIZ YZXKTMZNY", "JKIUSVOROTM GTJ RKGXTOTM", "LOTJOTM IXOZOIGR CKGQTKYYKY")) //what can I say, I like the trope of something talking in cypher
	visible_message("<span class='userdanger'>[src] disintigrates [L]!</span>","<span class='userdanger'>You analyse [L], restoring your health!</span>")
	if(client || !is_station_level(z))
		adjustHealth(-maxHealth * 0.1)
	L.dust()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/do_special_move()
	say(pick("JKVRUEOTM LUIAYKJ VUCKX", "JKVRUEOTM KDVKXOSKTZGR GZZGIQ", "LUIAYOTM VUCKX OTZU GTUSGRUAY UHPKIZ", "VUCKX UL ZNK YAT OT ZNK NKGXZ UL SE IUXK"))
	switch(mode)
		if(BLUESPACE)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				to_chat(H, "<span class='danger'>[src] starts to slow time around you!</span>")
				H.apply_status_effect(STATUS_EFFECT_BLUESPACESLOWDOWN)
		if(GRAV)
			visible_message("<span class='danger'>Debris from the battlefield begin to get compressed into rocks!</span>")
			var/list/turfs = new/list()
			var/rocks = 0
			for(var/turf/T in view(4, target))
				if(T.density)
					continue
				if(T in range (2, target))
					continue
				turfs += T
			while(rocks < 3 && length(turfs))
				var/turf/spot = pick_n_take(turfs)
				new /obj/effect/temp_visual/rock(spot)
				addtimer(CALLBACK(src, PROC_REF(throw_rock), spot, target), 2 SECONDS)
				rocks++
		if(PYRO)
			visible_message("<span class='danger'>The ground begins to heat up around you!</span>")
			var/list/turfs = new/list()
			var/volcanos = 0
			for(var/turf/T in view(4, target))
				if(T.density)
					continue
				if(T in range(1, target))
					continue
				turfs += T
			while(volcanos < 3 && length(turfs))
				var/turf/spot = pick_n_take(turfs)
				for(var/turf/around in range(1, spot))
					new /obj/effect/temp_visual/lava_warning(around)
				volcanos++
		if(FLUX)
			for(var/mob/living/carbon/human/H in view(7, src))
				var/turf/T = get_turf(H)
				var/turf/S = get_turf(src)
				if(!S || !T)
					return
				var/obj/item/projectile/energy/tesla_bolt/O = new /obj/item/projectile/energy/tesla_bolt(S)
				O.current = S
				O.yo = T.y - S.y
				O.xo = T.x - S.x
				O.fire()
		if(VORTEX)
			visible_message("<span class='danger'>[src] begins vibrate rapidly. It's causing an earthquake!</span>")
			for(var/turf/turf in range(9,get_turf(target)))
				if(prob(15))
					new /obj/effect/temp_visual/target/ancient(turf)
		if(CRYO)
			visible_message("<span class='danger'>[src]'s shell opens slightly, as sensors begin locking on to everyone around it!</span>")
			for(var/mob/living/carbon/human/H in view(7, src))
				H.apply_status_effect(STATUS_EFFECT_CRYO_BEAM, src)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/spawn_anomalies()
	say(pick("JKVRUEOTM XGC VUCKX", "KXXUX OT GTUSGRE IUTZGOTSKTZ", "YZGHOROZE OT OTYZGHOROZE OT YZGHOROZE OT OTYZGH-"))
	var/list/turfs = list()
	var/anomalies = 0
	for(var/turf/T in view(5, src))
		if(T.density)
			continue
		turfs += T
	while(anomalies < 3 && length(turfs))
		var/turf/spot = pick(turfs)
		turfs -= spot
		switch(mode)
			if(BLUESPACE)
				var/obj/effect/anomaly/bluespace/A = new(spot, 150, FALSE)
				A.mass_teleporting = FALSE
			if(GRAV)
				var/obj/effect/anomaly/grav/A = new(spot, 150, FALSE, FALSE)
				A.knockdown = TRUE
			if(PYRO)
				var/obj/effect/anomaly/pyro/A = new(spot, 150, FALSE)
				A.produces_slime = FALSE
			if(FLUX)
				var/obj/effect/anomaly/flux/A = new(spot, 150, FALSE)
				A.explosive = FALSE
				A.knockdown = TRUE
			if(VORTEX)
				new /obj/effect/anomaly/bhole(spot, 150, FALSE)
			if(CRYO)
				new /obj/effect/anomaly/cryo(spot, 150, FALSE)
		anomalies++
	return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/throw_rock(turf/spot, mob/target)
	var/turf/T = get_turf(target)
	if(!spot || !T)
		return
	var/obj/item/projectile/bullet/rock/O = new /obj/item/projectile/bullet/rock(spot)
	O.current = spot
	O.yo = T.y - spot.y
	O.xo = T.x - spot.x
	O.fire()

// To make this fight harder, it scales it's attacks based on number of players, or as injured. Capped lower on station.
/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/calculate_extra_player_anger()
	var/anger = 0
	var/cap = 0
	for(var/mob/living/carbon/human/H in range(10, src))
		if(stat == DEAD)
			continue
		anger++
	if(health <= health / 2)
		anger += 2
	cap = (is_station_level(loc.z) ? EXTRA_PLAYER_ANGER_STATION_CAP : EXTRA_PLAYER_ANGER_NORMAL_CAP)
	extra_player_anger = clamp(anger,1,cap) - 1

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/self_destruct()
	say(pick("OTZKMXOZE LGORAXK, YKRL JKYZXAIZ GIZOBK", "RUYY IKXZGOT, KTMGMKOTM XKIUBKXE JKTOGR", "VUCKX IUXKY 8-12 HXKGINKJ, UBKXRUGJOTM XKSGOTOTM IUXKY", "KXXUX KXXUX KXXUX KXXUX KXX-", "-ROQK ZKGXY OT XGOT- - -ZOSK ZU JOK"))
	visible_message("<span class='biggerdanger'>[src] begins to overload it's core. It is going to explode!</span>")
	walk(src, 0)
	playsound(src,'sound/machines/alarm.ogg',100,0,5)
	addtimer(CALLBACK(src, PROC_REF(kaboom)), 10 SECONDS)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/kaboom()
	explosion(get_turf(src), -1, 7, 15, 20)
	health = 0
	death(allowed = TRUE)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_legs()
	TR.ranged = FALSE

	TL.ranged = FALSE

	BR.ranged = FALSE

	BL.ranged = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/face_atom(atom/A) //This is used to make the legs get near the core when a user is meleeing the core
	. = ..()
	switch(dir)
		if(NORTH)
			leg_control_system(TOP_RIGHT, 1, 2)
			leg_control_system(TOP_LEFT, -1, 2)
		if(SOUTH)
			leg_control_system(BOTTOM_RIGHT, 1, -2)
			leg_control_system(BOTTOM_LEFT, -1, -2)
		if(EAST)
			leg_control_system(TOP_RIGHT, 2, 1)
			leg_control_system(BOTTOM_RIGHT, 2, -1)
		if(WEST)
			leg_control_system(TOP_LEFT, -2, 1)
			leg_control_system(BOTTOM_LEFT, -2,- 1)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/fix_specific_leg(input) //Used to reset legs to specific locations
	switch(input)
		if(TOP_RIGHT)
			leg_control_system(input, 2, 2)
		if(TOP_LEFT)
			leg_control_system(input, -2, 2)
		if(BOTTOM_RIGHT)
			leg_control_system(input, 2, -2)
		if(BOTTOM_LEFT)
			leg_control_system(input, -2, -2)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_walking_controler(dir) //This controls the legs. Here be pain.
	switch(dir)
		if(NORTH)
			leg_walking_orderer(TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT)
		if(SOUTH)
			leg_walking_orderer(BOTTOM_LEFT, BOTTOM_RIGHT, TOP_LEFT, TOP_RIGHT)
		if(EAST)
			leg_walking_orderer(TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT)
		if(WEST)
			leg_walking_orderer(BOTTOM_LEFT, BOTTOM_RIGHT, TOP_LEFT, TOP_RIGHT)
		if(NORTHEAST)
			leg_walking_orderer(TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT)
		if(SOUTHEAST)
			leg_walking_orderer(BOTTOM_RIGHT, TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT)
		if(NORTHWEST)
			leg_walking_orderer(TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT)
		if(SOUTHEAST)
			leg_walking_orderer(BOTTOM_LEFT, TOP_LEFT, BOTTOM_RIGHT, TOP_RIGHT)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_walking_orderer(A, B, C, D)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), A), 1)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), B), 2)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), C), 3)
	addtimer(CALLBACK(src, PROC_REF(fix_specific_leg), D), 4)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_control_system(input, horizontal, vertical)
	var/turf/target = locate(x + horizontal, y + vertical, z)
	switch(input)
		if(TOP_RIGHT)
			TR.leg_movement(target, 0.6)
		if(TOP_LEFT)
			TL.leg_movement(target, 0.6)
		if(BOTTOM_RIGHT)
			BR.leg_movement(target, 0.6)
		if(BOTTOM_LEFT)
			BL.leg_movement(target, 0.6)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(25)

		if(2)
			adjustBruteLoss(10)

		if(3)
			return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Goto()
	if(!exploding)
		return ..()
	return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(charging)
		DestroySurroundings()
	if(Dir)
		leg_walking_controler(Dir)
		if(charging)
			if(mode == PYRO)
				var/turf/C = get_turf(src)
				new /obj/effect/temp_visual/lava_warning(C)
				for(var/turf/T in range (1,src))
					new /obj/effect/hotspot(T)
					T.hotspot_expose(700,50,1)
			if(mode == VORTEX)
				var/turf/T = get_turf(src)
				for(var/atom/A in T)
					A.ex_act(3) //Body is immune to explosions of this strength.
				T.ex_act(3)
			if(mode == CRYO)
				var/turf/simulated/S = get_turf(src)
				S.MakeSlippery(TURF_WET_ICE)
				for(var/turf/T in range (1, src))
					new /obj/effect/snowcloud(T)
					for(var/mob/living/carbon/C in T.contents)
						C.bodytemperature = max(0, C.bodytemperature - 300) //Take a chill pill.
						C.apply_status_effect(/datum/status_effect/freon/watcher) // 0.8 seconds of no moving, should be funny.

	beam.forceMove(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/mob_negates_gravity() //No more being thrown around like a spastic child by grav anomalies
	return TRUE

/mob/living/simple_animal/hostile/ancient_robot_leg
	name = "leg"
	desc = "Legs with a mounted turret, for shooting and crushing small miners like you."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "leg"
	maxHealth = INFINITY //it's fine trust me
	health = INFINITY
	faction = list("mining", "boss") // No attacking your leg
	weather_immunities = list("lava","ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	flying = TRUE
	check_friendly_fire = 1
	ranged = TRUE
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/item/projectile/bullet/ancient_robot_bullet
	attacktext = "stomps on"
	armour_penetration_percentage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 400
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	stop_automated_movement = 1
	wander = 0
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	stat_attack = UNCONSCIOUS
	var/range = 3
	var/mob/living/simple_animal/hostile/megafauna/ancient_robot/core = null
	var/fake_max_hp = 300
	var/fake_hp = 300
	var/fake_hp_regen = 2
	var/transfer_rate = 0.75
	var/who_am_i = null
	var/datum/beam/leg_part

/mob/living/simple_animal/hostile/ancient_robot_leg/Initialize(mapload, mob/living/ancient, who)
	. = ..()
	if(!ancient)
		qdel(src) //no
	core = ancient
	who_am_i = who
	ranged_cooldown_time = rand(30, 60) // keeps them not running on the same time
	addtimer(CALLBACK(src, PROC_REF(beam_setup)), 1 SECONDS)


/mob/living/simple_animal/hostile/ancient_robot_leg/Destroy()
	QDEL_NULL(leg_part)
	return ..()

/mob/living/simple_animal/hostile/ancient_robot_leg/Life(seconds, times_fired)
	..()
	health_and_snap_check(TRUE)

/mob/living/simple_animal/hostile/ancient_robot_leg/bullet_act(obj/item/projectile/P)
	if(core.stat == CONSCIOUS && !core.target && core.AIStatus != AI_OFF && !core.client)
		if(P.firer && get_dist(core, P.firer) <= core.aggro_vision_range)
			core.FindTarget(list(P.firer), 1)
		core.Goto(P.starting, core.move_to_delay, 3)
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/death(gibbed)
	return //It shouldn't get gibbed by shuttle.

/mob/living/simple_animal/hostile/ancient_robot_leg/Goto()
	return // stops the legs from trying to move on their own

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/beam_setup()
	leg_part = Beam(core.beam, "leg_connection", 'icons/effects/effects.dmi', time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam)

/mob/living/simple_animal/hostile/ancient_robot_leg/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)
	if(leg_part)
		QDEL_NULL(leg_part)
	addtimer(CALLBACK(src, PROC_REF(beam_setup)), 1 SECONDS)

/mob/living/simple_animal/hostile/ancient_robot_leg/adjustHealth(amount, updating_health = TRUE)
	var/damage = amount * transfer_rate
	core.adjustBruteLoss(damage)
	fake_hp = clamp(fake_hp - damage, 0, fake_max_hp)
	if(damage && ranged && fake_hp <= 200)
		ranged = FALSE
		visible_message("<span class='danger'>[src]'s turret breaks and pulls back into the leg!</span>")
	if(damage && transfer_rate <= 0.25) //warn that you are not doing much damage
		visible_message("<span class='danger'>[src] looks too damaged to hurt it much more!</span>")
	health_and_snap_check(FALSE)

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/health_and_snap_check(regen = FALSE)
	if(regen)
		fake_hp = min(fake_hp + fake_hp_regen, fake_max_hp)
	transfer_rate = 0.75 * (fake_hp/fake_max_hp)
	if(fake_hp >= 250 && !ranged)
		ranged = TRUE
		visible_message("<span class='danger'>[src]'s turret pops out of it!</span>")
	if(get_dist(get_turf(core),get_turf(src)) <= range)
		return
	else
		forceMove(core.loc)
		core.fix_specific_leg(who_am_i)

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/leg_movement(turf/T, movespeed) //byond doesn't like calling walk_towards on the legs directly
	walk_towards(src, T, movespeed)
	DestroySurroundings()

/mob/living/simple_animal/hostile/ancient_robot_leg/Bump(atom/A, yes)
	if(!core.charging)
		return
	if(isliving(A) && yes)
		if(!istype(A, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
			forceMove(get_turf(L))
			var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			L.apply_damage(12.5, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration_flat, armour_penetration_percentage))
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(25)

		if(2)
			adjustBruteLoss(10)

		if(3)
			return

/mob/living/simple_animal/hostile/ancient_robot_leg/MeleeAction(patience = TRUE)
	if(core.charging || core.exploding)
		return
	return ..()

/mob/living/simple_animal/hostile/ancient_robot_leg/OpenFire() // This is (idealy) to keep the turrets on the legs from shooting people that are close to the robot. The guns will only shoot if they won't hit the robot, or if the user is between a leg and another leg / robot
	if(core.exploding)
		return
	if(get_dist(target, core) < 3)
		return
	if(prob(33))
		return
	ranged_cooldown_time = (rand(30, 60)) // keeps them not running on the same time
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/Moved(atom/OldLoc, Dir, Forced = FALSE)
	playsound(src, 'sound/effects/meteorimpact.ogg', 60, TRUE, 2, TRUE) //turned way down from bubblegum levels due to 4 legs

/mob/living/simple_animal/hostile/ancient_robot_leg/mob_negates_gravity()
	return TRUE

/obj/item/projectile/bullet/ancient_robot_bullet
	damage = 8
	damage_type = BRUTE

/obj/item/projectile/bullet/rock
	name= "thrown rock"
	damage = 25
	damage_type = BRUTE
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"

/obj/effect/temp_visual/rock
	name = "floating rock"
	desc = "Might want to focus on dodging, rather than looking at it."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	duration = 20


/obj/item/projectile/energy/tesla_bolt //Leaving here for adminbus / so vetus still uses it.
	name = "shock bolt"
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 5 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 3
	var/power = 10000

/obj/item/ammo_casing/energy/tesla_bolt/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/tesla_bolt/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1000, maxdistance = 30)

/obj/item/projectile/energy/tesla_bolt/on_hit(atom/target)
	. = ..()
	tesla_zap(src, zap_range, power, zap_flags)
	qdel(src)

/obj/item/projectile/energy/tesla_bolt/Bump(atom/A, yes) // Don't want the projectile hitting the legs
	if(!istype(/mob/living/simple_animal/hostile/ancient_robot_leg, A))
		return ..()
	var/turf/target_turf = get_turf(A)
	loc = target_turf

/obj/effect/temp_visual/dragon_swoop/bubblegum/ancient_robot //this is the worst path I have ever made
	icon_state = "target"

/obj/effect/temp_visual/dragon_swoop/bubblegum/ancient_robot/Initialize(mapload, target)
	. = ..()
	new /obj/effect/temp_visual/beam_target(get_turf(src), target) // Yup, we have to make *another* effect since beam doesn't work right with 64x64
	set_light(4, l_color = "#ee2e27")

/obj/effect/temp_visual/beam_target
	duration = 1.6 SECONDS
	var/datum/beam/charge

/obj/effect/temp_visual/beam_target/Initialize(mapload, target)
	. = ..()
	charge = Beam(target, "target_beam", 'icons/effects/effects.dmi', time=1.5 SECONDS, maxdistance=INFINITY, beam_type=/obj/effect/ebeam)


/obj/effect/temp_visual/beam_target/Destroy()
	QDEL_NULL(charge)
	return ..()

/obj/effect/temp_visual/target/ancient

/obj/effect/temp_visual/target/ancient/fall(list/flame_hit)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	new /obj/effect/temp_visual/fireball/rock(T)
	sleep(duration)
	if(ismineralturf(T))
		var/turf/simulated/mineral/M = T
		M.gets_drilled()
	playsound(T, 'sound/effects/meteorimpact.ogg', 80, TRUE)
	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
			continue
		L.adjustBruteLoss(35)
		to_chat(L, "<span class='userdanger'>You're hit by the falling rock!</span>")

/obj/effect/temp_visual/fireball/rock
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"

#undef BODY_SHIELD_COOLDOWN_TIME
#undef EXTRA_PLAYER_ANGER_NORMAL_CAP
#undef EXTRA_PLAYER_ANGER_STATION_CAP
#undef BLUESPACE
#undef GRAV
#undef PYRO
#undef FLUX
#undef CRYO
#undef VORTEX
