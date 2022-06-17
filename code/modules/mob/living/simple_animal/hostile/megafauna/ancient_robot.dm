#define BODY_SHIELD_COOLDOWN_TIME 45 SECONDS
#define EXTRA_PLAYER_ANGER_NORMAL_CAP 6
#define EXTRA_PLAYER_ANGER_STATION_CAP 3
#define VORTEX_HEAL_CAP 250
#define BLUESPACE 1
#define GRAV 2
#define PYRO 3
#define FLUX 4
#define VORTEX 5

/// DISABLE MELEE WHEN CHARGING. TONE DOWN GUNS. PREVENT DOUBLE BUMP.


/*

ROBOT BITCH

Ash drakes spawn randomly wherever a lavaland creature is able to spawn. They are the draconic guardians of the Necropolis.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

Whenever possible, the drake will breathe fire directly at it's target, igniting and heavily damaging anything caught in the blast.
It also often causes lava to pool from the ground around you - many nearby turfs will temporarily turn into lava, dealing damage to anything on the turfs.
The drake also utilizes its wings to fly into the sky, flying after its target and attempting to slam down on them. Anything near when it slams down takes huge damage.
 - Sometimes it will chain these swooping attacks over and over, making swiftness a necessity.
 - Sometimes, it will encase its target in an arena of lava

When an ash drake dies, it leaves behind a chest that can contain four things:
 1. A spectral blade that allows its wielder to call ghosts to it, enhancing its power
 2. A lava staff that allows its wielder to create lava
 3. A spellbook and wand of fireballs
 4. A bottle of dragon's blood with several effects, including turning its imbiber into a drake themselves.

When butchered, they leave behind diamonds, sinew, bone, and ash drake hide. Ash drake hide can be used to create a hooded cloak that protects its wearer from ash storms.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/ancient_robot
	name = "old ass hunk of junk"
	desc = "what is this piece of shit?"
	health = 2700 //slight more hp as insurance for it's self destruct
	maxHealth = 2700
	attacktext = "shocks"
	attack_sound = 'sound/machines/defib_zap.ogg'
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "ancient_robot"
	icon_living = "ancient_robot"
	friendly = "stares down"
	speak_emote = list("BUZZES")
	universal_speak = TRUE
	universal_understand = TRUE
	armour_penetration = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_damage_type = BURN //Legs do the stomping, this is just a shock
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	pixel_y = -16
	del_on_death = TRUE
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	internal_type = /obj/item/gps/internal/ancient
	medal_type = BOSS_MEDAL_ROBOT
	score_type = ROBOT_SCORE
	deathmessage = "explodes in a shower of alloys"
	footstep_type = FOOTSTEP_MOB_HEAVY //make stomp like bubble
	attack_action_types = list()

	var/charging = FALSE
	var/revving_charge = FALSE
	var/player_cooldown = 0
	var/body_shield_enabled = FALSE
	var/body_shield_cooldown = FALSE
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
	TR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "TR")
	TL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "TL")
	BR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "BR")
	BL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "BL")
	beam = new /obj/effect/abstract(loc)
	addtimer(CALLBACK(src, .proc/leg_setup), 1 SECONDS)
	mode = rand(BLUESPACE, VORTEX) //picks one of the 5 cores.
	if(mode == FLUX) // Main attack is shock, so flux makes it stronger
		melee_damage_lower = 25
		melee_damage_upper = 25

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Destroy()
	QDEL_NULL(TR)
	QDEL_NULL(TL)
	QDEL_NULL(BR)
	QDEL_NULL(BL)
	QDEL_NULL(beam)
	return ..()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_setup()
	fix_specific_leg("TR")
	fix_specific_leg("TL")
	fix_specific_leg("BR")
	fix_specific_leg("BL")

/obj/item/gps/internal/ancient
	icon_state = null
	gpstag = "Malfunctioning Signal"
	desc = "ERROR_NULL_ENTRY"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Life(seconds, times_fired)
	if(health <= 200 && !exploding)
		self_destruct()
		exploding = TRUE
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/OpenFire()
	if(charging)
		return

	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + (ranged_cooldown_time * ((10 - extra_player_anger)/10))

	//if(client)
	//	switch(chosen_attack)
	//		if(1)
	//			fire_cone(meteors = FALSE)
	//		if(2)
	//			fire_cone()
	//		if(3)
	//			mass_fire()
	//		if(4)
	//			lava_swoop()
	//	return

	if(exploding)
		return

	if(prob(30 + anger_modifier))
		triple_charge()

	else if(prob(50) && !body_shield_enabled && !body_shield_cooldown)
		body_shield()

	else if(prob(60 + anger_modifier))
		do_special_move()
	else
		visible_message("<span class='danger'>DOING FUCK ALL CAPTAIN</span>", "<span class='userdanger'>You deflect the projectile!</span>")

	calculate_extra_player_anger()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/triple_charge()
	if(mode == BLUESPACE)
		charge(delay = 18)
		charge(delay = 12)
		charge(delay = 6)
		SetRecoveryTime(30)
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
		src.visible_message("<span class='danger'>[src] teleports somewhere nearbye!</span>")
		do_teleport(src, target, 7, asoundin = 'sound/effects/phasein.ogg', safe_turf_pick = TRUE) //Teleport within 7 tiles of the target
		new /obj/effect/temp_visual/bsg_kaboom(get_turf(src))
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

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Bump(atom/A) //list of bumped in current charge
	if(charging)
		DestroySurroundings()
		if(isliving(A))
			var/mob/living/L = A
			if(!istype(A, /mob/living/simple_animal/hostile/ancient_robot_leg))
				L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
				forceMove(get_turf(L))
				var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
				L.apply_damage(15, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration))
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
				shake_camera(L, 4, 3)
				shake_camera(src, 2, 3)
				if(mode == GRAV)
					var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
					L.throw_at(throw_target, 3, 2)
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/body_shield()
	//add overlay of shield, give it immunity to ranged (but not melee) during duration.
	body_shield_enabled = TRUE
	visible_message("<span class='danger'>[src] creates some sort of energy shield!</span>")
	addtimer(CALLBACK(src, .proc/disable_shield), 15 SECONDS)
	add_overlay("shield")

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_shield()
	visible_message("<span class='danger'>[src]'s shield fails!</span>")
	cut_overlay("shield")
	body_shield_enabled = FALSE
	body_shield_cooldown = TRUE
	addtimer(CALLBACK(src, .proc/reset_shield_cooldown), 30 SECONDS)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/reset_shield_cooldown()
	body_shield_cooldown = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/bullet_act(obj/item/projectile/P)
	if(body_shield_enabled)
		visible_message("<span class='danger'>[src]'s shield deflects the projectile in a shower of sparks!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		playsound(src, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg'), 300, TRUE)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/devour(mob/living/L)
	say("JKYZXAIZOBK GTGREYKX GIZOBK") //what can I say, I like the trope of something talking in cypher
	visible_message("<span class='userdanger'>[src] disintigrates [L]!</span>","<span class='userdanger'>You analyse [L], restoring your health!</span>")
	if(!is_station_level(z) || client)
		adjustHealth(-L.maxHealth * 0.2)
	L.dust()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/do_special_move()
	if(prob(20))
		say("JKVRUEOTM XGC VUCKX")
		var/list/turfs = new/list()
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
					new /obj/effect/anomaly/grav(spot, 150, FALSE)
				if(PYRO)
					var/obj/effect/anomaly/pyro/A = new(spot, 150, FALSE)
					A.slimey = FALSE
				if(FLUX)
					var/obj/effect/anomaly/flux/A = new(spot, 150, FALSE)
					A.explosive = FALSE
				if(VORTEX)
					new /obj/effect/anomaly/bhole(spot, 150, FALSE)
			anomalies += 1
		return
	say("JKVRUEOTM LUIAYKJ VUCKX")
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
				var/turf/spot = pick(turfs)
				turfs -= spot
				new /obj/effect/temp_visual/rock(spot)
				addtimer(CALLBACK(src, .proc/throw_rock, spot, target), 2 SECONDS)
				rocks += 1
		if(PYRO)
			visible_message("<span class='danger'>The ground begins to heat up around you!</span>")
			var/list/turfs = new/list()
			var/volcanos = 0
			for(var/turf/T in view(4, target))
				if(T.density)
					continue
				if(T in range(2, target))
					continue
				turfs += T
			while(volcanos < 3 && length(turfs))
				var/turf/spot = pick(turfs)
				turfs -= spot
				for(var/turf/around in range(1, spot))
					new /obj/effect/temp_visual/lava_warning(around)
				volcanos += 1
		if(FLUX)
			for(var/mob/living/carbon/human/H in view(7, src))
				var/turf/T = get_turf(H)
				var/turf/S = get_turf(src)
				if(!S || !T)
					return
				var/obj/item/projectile/energy/shock_revolver/ancient/O = new /obj/item/projectile/energy/shock_revolver/ancient(S)
				O.current = S
				O.yo = T.y - S.y
				O.xo = T.x - S.x
				O.fire()
		if(VORTEX)
			visible_message("<span class='danger'>[src] begins to pull in materials towards themself!</span>")
			for(var/obj/item/stack/O in range(5, src))
				O.throw_at(src, 5, 10)
			addtimer(CALLBACK(src, .proc/material_heal), 1 SECONDS)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/material_heal()
	var/heal_amount = 0
	for(var/obj/item/stack/O in range(3, src))
		if(!(istype(O, /obj/item/stack/sheet) || istype(O, /obj/item/stack/ore)))
			continue
		heal_amount += 5 * O.amount
		qdel(O)
	adjustBruteLoss(-min(heal_amount, (is_station_level(loc.z) ? VORTEX_HEAL_CAP / 5 : VORTEX_HEAL_CAP))) //Heavily capped on station, since as everything gets broken materials drop everywhere



/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/throw_rock(turf/spot, mob/target)
	var/turf/T = get_turf(target)
	if(!spot || !T)
		return
	var/obj/item/projectile/rock/O = new /obj/item/projectile/rock(spot)
	O.current = spot
	O.yo = T.y - spot.y
	O.xo = T.x - spot.x
	O.fire()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/calculate_extra_player_anger()// To make this fight harder, it scales it's attacks based on number of players. Capped lower on station.
	var/anger = 0
	var/cap = 0
	for(var/mob/living/carbon/human/H in range(10, src))
		if(stat == DEAD)
			continue
		anger += 1
		cap = (is_station_level(loc.z) ? EXTRA_PLAYER_ANGER_STATION_CAP : EXTRA_PLAYER_ANGER_NORMAL_CAP)
	extra_player_anger = min(max(anger, 1), cap) - 1

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/self_destruct()
	status_flags ^= GODMODE
	say("OTZKMXOZE LGORAXK YKRL JKYZXAIZ GIZOBK")
	visible_message("<span class='biggerdanger'>[src] begins to overload it's core. It is going to explode!</span>")
	playsound(src,'sound/machines/alarm.ogg',100,0,5)
	addtimer(CALLBACK(src, .proc/kaboom), 10 SECONDS)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/kaboom()
	explosion(get_turf(src), -1, 10, 20, 20)
	status_flags ^= GODMODE
	death()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_legs()
	TR.disabled = TRUE
	TR.ranged = FALSE

	TL.disabled = TRUE
	TL.ranged = FALSE

	BR.disabled = TRUE
	BR.ranged = FALSE

	BL.disabled = TRUE
	BL.ranged = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/fix_specific_leg(input) //Used to reset legs to specific locations
	switch(input)
		if("TR")
			leg_control_system(input, 2, 2)
		if("TL")
			leg_control_system(input, -2, 2)
		if("BR")
			leg_control_system(input, 2, -2)
		if("BL")
			leg_control_system(input, -2, -2)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_walking_controler(dir) //This controls the legs. Here be pain.
	switch(dir)
		if(1)
			leg_walking_orderer("TR", "TL", "BR", "BL")
		if(2)
			leg_walking_orderer("BL", "BR", "TL", "TR")
		if(4)
			leg_walking_orderer("TR", "TL", "BR", "BL")
		if(8)
			leg_walking_orderer("BL", "BR", "TL", "TR")
		if(5)
			leg_walking_orderer("TR", "TL", "BR", "BL")
		if(6)
			leg_walking_orderer("BR", "TL", "BL", "TR")
		if(9)
			leg_walking_orderer("TL", "TR", "BL", "BR")
		if(10)
			leg_walking_orderer("BL", "TL", "BR", "TR")



/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_walking_orderer(A, B, C, D)
	addtimer(CALLBACK(src, .proc/fix_specific_leg, A), 1)
	addtimer(CALLBACK(src, .proc/fix_specific_leg, B), 2)
	addtimer(CALLBACK(src, .proc/fix_specific_leg, C), 3)
	addtimer(CALLBACK(src, .proc/fix_specific_leg, D), 4)


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/leg_control_system(input, right, up)
	var/turf/target = locate(src.x + right, src.y + up, src.z)
	switch(input)
		if("TR")
			TR.leg_movement(target, 0.6)
		if("TL")
			TL.leg_movement(target, 0.6)
		if("BR")
			BR.leg_movement(target, 0.6)
		if("BL")
			BL.leg_movement(target, 0.6)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/ex_act(severity, target)
	if(severity == EXPLODE_LIGHT)
		return
	..()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/Goto()
	if(!exploding)
		return ..()
	return

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(charging)
		DestroySurroundings()
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
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
				var/turf/C = get_turf(src)
				C.ex_act(3)

	beam.forceMove(get_turf(src))
	return ..()


/mob/living/simple_animal/hostile/ancient_robot_leg
	name = "leg"
	desc = "leg"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	maxHealth = INFINITY //it's fine trust me
	health = INFINITY
	faction = list("mining", "boss") // No attacking your leg
	weather_immunities = list("lava","ash")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	flying = TRUE
	check_friendly_fire = 1
	ranged = 1
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/item/projectile/ancient_robot_bullet
	attacktext = "stomps on"
	armour_penetration = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 400
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	stat_attack = DEAD
	var/range = 3
	var/mob/living/simple_animal/hostile/megafauna/ancient_robot/core = null
	var/fake_max_hp = 400
	var/fake_hp = 400
	var/fake_hp_regen = 10
	var/transfer_rate = 0.75
	var/who_am_i = null
	var/disabled = FALSE
	var/datum/beam/leg_part

/mob/living/simple_animal/hostile/ancient_robot_leg/Initialize(mapload, mob/living/ancient, who)
	. = ..()
	if(!ancient)
		qdel(src) //no
	core = ancient
	who_am_i = who
	ranged_cooldown_time = (rand(30, 60)) // keeps them not running on the same time
	addtimer(CALLBACK(src, .proc/beam_setup), 1 SECONDS)

/mob/living/simple_animal/hostile/ancient_robot_leg/Life(seconds, times_fired)
	..()
	health_and_snap_check(TRUE)

/mob/living/simple_animal/hostile/ancient_robot_leg/Goto()
	return // stops the legs from trying to move on their own

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/beam_setup()
	leg_part = Beam(core.beam, "rped_upgrade", 'icons/effects/effects.dmi', time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam)

/mob/living/simple_animal/hostile/ancient_robot_leg/adjustHealth(amount, updating_health = TRUE) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * transfer_rate
	core.adjustBruteLoss(damage)
	fake_hp = clamp(fake_hp - damage, 0, fake_max_hp)
	if(damage && fake_hp <= 160) //warn that you are not doing much damage
		src.visible_message("<span class='danger'>[src] looks too damaged to hurt it much more!</span>")
	health_and_snap_check(FALSE)

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/health_and_snap_check(regen = FALSE)
	if(regen)
		fake_hp = min(fake_hp + fake_hp_regen, fake_max_hp)
	transfer_rate = 0.75 * (fake_hp/fake_max_hp)
	if(get_dist(get_turf(core),get_turf(src)) <= range)
		return
	else
		forceMove(core.loc) //move to summoner's tile, don't recall
		core.fix_specific_leg(who_am_i)

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/leg_movement(turf/T, movespeed) //byond doesn't like calling walk_towards on the legs directly
	walk_towards(src, T, movespeed)
	DestroySurroundings()

/mob/living/simple_animal/hostile/ancient_robot_leg/Bump(atom/A)
	if(!core.charging)
		return
	if(isliving(A))
		if(!istype(A, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
			forceMove(get_turf(L))
			var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			L.apply_damage(5, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration))
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/MeleeAction(patience = TRUE)
	if(core.charging || disabled)
		return
	return ..()

/mob/living/simple_animal/hostile/ancient_robot_leg/OpenFire() // This is (idealy) to keep the turrets on the legs from shooting people that are close to the robot. The guns will only shoot if they won't hit the robot, or if the user is between a leg and another leg / robot
	if(get_dist(target, core) < 3)
		return
	if(prob(33))
		return
	ranged_cooldown_time = (rand(30, 60)) // keeps them not running on the same time
	..()

/obj/item/projectile/ancient_robot_bullet
	damage = 5
	damage_type = BRUTE

/obj/item/projectile/rock
	name= "thrown rock"
	damage = 20
	damage_type = BRUTE
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"

/obj/effect/temp_visual/rock
	name = "floating rock"
	desc = "Might want to focus on dodging, rather than looking at it."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	duration = 20

/obj/item/projectile/energy/shock_revolver/ancient
	damage = 5

/obj/item/projectile/energy/shock_revolver/ancien/Bump(atom/A, yes) // Don't want the projectile hitting the legs
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
	var/datum/beam/charge

/obj/effect/temp_visual/beam_target/Initialize(mapload, target)
	. = ..()
	charge = Beam(target, "target_beam", 'icons/effects/effects.dmi', time=1.5 SECONDS, maxdistance=INFINITY, beam_type=/obj/effect/ebeam)

#undef BODY_SHIELD_COOLDOWN_TIME
#undef EXTRA_PLAYER_ANGER_NORMAL_CAP
#undef EXTRA_PLAYER_ANGER_STATION_CAP
#undef VORTEX_HEAL_CAP
#undef BLUESPACE
#undef GRAV
#undef PYRO
#undef FLUX
#undef VORTEX
