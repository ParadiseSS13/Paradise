

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
	attack_sound = 'sound/misc/demon_attack1.ogg'
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	speak_emote = list("BUZZES")
	armour_penetration = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_damage_type = BURN //Legs do the stomping, this is just a shock
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	pixel_x = -16
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	var/charging = FALSE
	var/revving_charge = FALSE
	var/player_cooldown = 0
	var/body_shield_enabled = FALSE
	internal_type = /obj/item/gps/internal/ancient
	medal_type = BOSS_MEDAL_DRAKE
	score_type = DRAKE_SCORE
	deathmessage = "explodes in a shower of alloys"
	death_sound = 'sound/misc/demon_dies.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list()


/obj/item/gps/internal/ancient
	icon_state = null
	gpstag = "Malfunctioning Signal"
	desc = "ERROR_NULL_ENTRY"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/ancient_robot/OpenFire()
	if(charging)
		return

	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time

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

	else if(prob(10+anger_modifier))
		do_special_move()

	else if(prob(20) && !body_shield_enabled)
		body_shield()
	else
		visible_message("<span class='danger'>DOING FUCK ALL CAPTAIN</span>", "<span class='userdanger'>You deflect the projectile!</span>")

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
		if(isturf(A) || isobj(A) && A.density)
			A.ex_act(EXPLODE_HEAVY)
		DestroySurroundings()
		if(isliving(A))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] tramples you into the ground!</span>")
			forceMove(get_turf(L))
			L.apply_damage(15, BRUTE) // ignores armor, might hit twice, TEST THIS SHIT.
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
	..()

/mob/living/simple_animal/hostile/megafauna/ancient_robot/proc/body_shield()
	//add overlay of shield, give it immunity to ranged (but not melee) during duration.
	body_shield_enabled = TRUE
	visible_message("<span class='danger'>SHIELD ON MOTHAFAKA</span>", "<span class='userdanger'>You deflect the projectile!</span>")
	addtimer(CALLBACK(src, .proc/disable_shield), 15 SECONDS)
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


/mob/living/simple_animal/hostile/megafauna/ancient_robot/ex_act(severity, target)
	if(severity == EXPLODE_LIGHT)
		return
	..()

///mob/living/simple_animal/hostile/megafauna/dragon/adjustHealth(amount, updating_health = TRUE) //CHANGE THIS FOR CRITICAL DEATH KAABOOM
//	if(swooping & SWOOP_INVULNERABLE)
//		return FALSE
//	return ..()

