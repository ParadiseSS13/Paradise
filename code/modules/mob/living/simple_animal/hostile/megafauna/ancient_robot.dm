#define BODY_SHIELD_COOLDOWN_TIME = 45
#define EXTRA_PLAYER_ANGER_NORMAL_CAP = 6
#define EXTRA_PLAYER_ANGER_STATION_CAP = 3

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
	health = 2500
	maxHealth = 2500
	attacktext = "shocks"
	attack_sound = 'sound/machines/defib_zap.ogg'
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "ancient_robot"
	icon_living = "ancient_robot"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	speak_emote = list("BUZZES")
	armour_penetration = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_damage_type = BURN //Legs do the stomping, this is just a shock
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	pixel_y = -16
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	var/charging = FALSE
	var/revving_charge = FALSE
	var/player_cooldown = 0
	var/body_shield_enabled = FALSE
	var/body_shield_cooldown = 0
	var/extra_player_anger = 0
	internal_type = /obj/item/gps/internal/ancient
	medal_type = BOSS_MEDAL_DRAKE
	score_type = DRAKE_SCORE
	deathmessage = "explodes in a shower of alloys"
	death_sound = 'sound/misc/demon_dies.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY //make stomp like bubble
	attack_action_types = list()

	var/mob/living/simple_animal/hostile/ancient_robot_leg/TR = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/TL = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/BR = null
	var/mob/living/simple_animal/hostile/ancient_robot_leg/BL = null

///These variables are used to track what position the legs (should) be in, to hopefully make them move smoothly.
	var/step_right = 0
	var/step_up = 0
	var/step_upright = 0

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Initialize(mapload, mob/living/ancient) //We spawn and move them to clear out area for the legs, rather than risk the legs getting put in a wall
	. = ..()
	TR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "TR")
	TL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "TL")
	BR = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "BR")
	BL = new /mob/living/simple_animal/hostile/ancient_robot_leg(loc, src, "BL")
	addtimer(CALLBACK(src, .proc/leg_setup), 1 SECONDS)


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

	if(prob(15 + anger_modifier))
		triple_charge()

	else if(prob(10 + anger_modifier))
		do_special_move()

	else if(prob(50) && !body_shield_enabled && !body_shield_cooldown)
		body_shield()
	else
		visible_message("<span class='danger'>DOING FUCK ALL CAPTAIN</span>", "<span class='userdanger'>You deflect the projectile!</span>")

	calculate_extra_player_anger()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/triple_charge()
	charge(delay = 9)
	charge(delay = 6)
	charge(delay = 3)
	SetRecoveryTime(15)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/charge(atom/chargeat = target, delay = 5, chargepast = 2) //add limb charge as well
	if(!chargeat)
		return
	var/chargeturf = get_turf(chargeat)
	if(!chargeturf)
		return
	var/dir = get_dir(src, chargeturf)
	var/turf/T = get_ranged_target_turf(chargeturf, dir, chargepast)
	if(!T)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(T) //make robotic target + beam
	charging = TRUE
	revving_charge = TRUE
	DestroySurroundings()
	walk(src, 0)
	setDir(dir)
	SLEEP_CHECK_DEATH(delay)
	revving_charge = FALSE
	var/movespeed = 0.7
	walk_towards(src, T, movespeed)
	SLEEP_CHECK_DEATH(get_dist(src, T) * movespeed)
	walk(src, 0) // cancel the movement
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Bump(atom/A)
	if(charging)
		DestroySurroundings()
		if(isliving(A))
			var/mob/living/L = A
			if(!istype(A, /mob/living/simple_animal/hostile/ancient_robot_leg))
				L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
				forceMove(get_turf(L))
				L.apply_damage(15, BRUTE) // ignores armor, might hit twice, TEST THIS SHIT. it does
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
				shake_camera(L, 4, 3)
				shake_camera(src, 2, 3)
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/body_shield()
	//add overlay of shield, give it immunity to ranged (but not melee) during duration.
	body_shield_enabled = TRUE
	visible_message("<span class='danger'>SHIELD ON MOTHAFAKA</span>", "<span class='userdanger'>You deflect the projectile!</span>")
	addtimer(CALLBACK(src, .proc/disable_shield), 15 SECONDS)
	body_shield_cooldown = world.time + 4500
	//visable chat message / sound here

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/disable_shield()
	visible_message("<span class='danger'>SHIELD DOWN CAPTAIN</span>", "<span class='userdanger'>You deflect the projectile!</span>")
	body_shield_enabled = FALSE
	//remove overlay here, sounds, ect.

/mob/living/simple_animal/hostile/megafauna/ancient_robot/bullet_act(obj/item/projectile/P)
	if(body_shield_enabled)
		visible_message("<span class='danger'>[src]'s shield deflects the projectile in a shower of sparks!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 300, TRUE) // sparky sounds
		return
	..()


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/do_special_move()
	visible_message("<span class='danger'>halp I have no anomaly core</span>", "<span class='userdanger'>You deflect the projectile!</span>")


/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/calculate_extra_player_anger()// To make this fight harder, it scales it's attacks based on number of players. Capped lower on station.
	var/anger = 0
	var/cap = 0
	for(var/mob/living/carbon/human/H in range(10, src))
		if(stat == DEAD)
			continue
		anger += 1
		cap = (is_station_level(loc.z) ? 1 : 2)
	extra_player_anger = min(max(anger, 1), cap) - 1

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
			//TR.forceMove(target)
		if("TL")
			TL.leg_movement(target, 0.6)
			//TL.forceMove(target)
		if("BR")
			BR.leg_movement(target, 0.6)
			//BR.forceMove(target)
		if("BL")
			BL.leg_movement(target, 0.6)
			//BL.forceMove(target)

/mob/living/simple_animal/hostile/megafauna/ancient_robot/ex_act(severity, target)
	if(severity == EXPLODE_LIGHT)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(charging)
		DestroySurroundings()
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	if(Dir)
		leg_walking_controler(Dir)
	return ..()

///mob/living/simple_animal/hostile/megafauna/dragon/adjustHealth(amount, updating_health = TRUE) //CHANGE THIS FOR CRITICAL DEATH KAABOOM
//	if(swooping & SWOOP_INVULNERABLE)
//		return FALSE
//	return ..()

/mob/living/simple_animal/hostile/ancient_robot_leg
	name = "leg"
	desc = "leg"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	maxHealth = INFINITY //it's fine trust me
	health = INFINITY
	faction = list("mining", "boss") // No attacking your leg
	stop_automated_movement = 1
	wander = 0
	check_friendly_fire = 1
	ranged = 1
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	projectiletype = /obj/item/projectile/ancient_robot_bullet
	attacktext = "stomps on"
	armour_penetration = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	var/range = 4
	var/mob/living/simple_animal/hostile/megafauna/ancient_robot/core = null
	var/fake_max_hp = 400
	var/fake_hp = 400
	var/fake_hp_regen = 10
	var/transfer_rate = 0.5
	var/who_am_i = null
	var/fuck_people_up = FALSE
	var/datum/beam/leg_part

/mob/living/simple_animal/hostile/ancient_robot_leg/Initialize(mapload, mob/living/ancient, who)
	. = ..()
	if(!ancient)
		qdel(src) //no
	core = ancient
	who_am_i = who
	leg_part = Beam(core.internal_gps, "rped_upgrade", 'icons/effects/effects.dmi', time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam)
	ranged_cooldown_time = (rand(30, 60)) // keeps them not running on the same time

/mob/living/simple_animal/hostile/ancient_robot_leg/Life(seconds, times_fired)
	..()
	health_and_snap_check(TRUE)

/mob/living/simple_animal/hostile/ancient_robot_leg/Goto()
		return // stops the legs from trying to move on their own

/mob/living/simple_animal/hostile/ancient_robot_leg/adjustHealth(amount, updating_health = TRUE) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * transfer_rate
	core.adjustBruteLoss(damage)
	fake_hp = clamp(fake_hp - damage, 0, fake_max_hp)
	if(damage && fake_hp <= 160) //warn that you are not doing much damage
		src.visible_message("<span class='danger'>[src] looks too damaged to hurt it much more!</span>")
	health_and_snap_check(FALSE)

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/health_and_snap_check(regen = FALSE)
	if(get_dist(get_turf(core),get_turf(src)) <= range)
		return
	else
		forceMove(core.loc) //move to summoner's tile, don't recall
		core.fix_specific_leg(who_am_i)
	if(regen)
		fake_hp = min(fake_hp + fake_hp_regen, fake_max_hp)
	transfer_rate = 0.5 ** (3 * (fake_hp / fake_max_hp)) * 0.5

/mob/living/simple_animal/hostile/ancient_robot_leg/proc/leg_movement(turf/T, movespeed) //byond doesn't like calling walk_towards on the legs directly
	walk_towards(src, T, movespeed)

/mob/living/simple_animal/hostile/ancient_robot_leg/Bump(atom/A)
	if(!core.charging)
		return
	DestroySurroundings()
	if(isliving(A))
		if(!istype(A, /mob/living/simple_animal/hostile/megafauna/ancient_robot))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
			forceMove(get_turf(L))
			L.apply_damage(5, BRUTE) // ignores armor, might hit twice, TEST THIS SHIT. it does
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
	..()

/mob/living/simple_animal/hostile/ancient_robot_leg/OpenFire() // This is (idealy) to keep the turrets on the legs from shooting people that are close to the robot. The guns will only shoot if they won't hit the robot, or if the user is between a leg and another leg / robot
	if(get_dist(target, core) < 3)
		return
	ranged_cooldown_time = (rand(30, 60)) // keeps them not running on the same time
	..()

/obj/item/projectile/ancient_robot_bullet
	damage = 7.5
	armour_penetration = 40
	damage_type = BRUTE
	stamina = 7.5 //you actually have to dodge a bit, rather than just, you know, tank.
