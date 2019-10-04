/*

COLOSSUS

The colossus spawns randomly wherever a lavaland creature is able to spawn. It is powerful, ancient, and extremely deadly.
The colossus has a degree of sentience, proving this in speech during its attacks.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

The colossus' true danger lies in its ranged capabilities. It fires immensely damaging death bolts that penetrate all armor in a variety of ways:
 1. The colossus fires death bolts in alternating patterns: the cardinal directions and the diagonal directions.
 2. The colossus fires death bolts in a shotgun-like pattern, instantly downing anything unfortunate enough to be hit by all of them.
 3. The colossus fires a spiral of death bolts.
At 33% health, the colossus gains an additional attack:
 4. The colossus fires two spirals of death bolts, spinning in opposite directions.

When a colossus dies, it leaves behind a chunk of glowing crystal known as a black box. Anything placed inside will carry over into future rounds.
For instance, you could place a bag of holding into the black box, and then kill another colossus next round and retrieve the bag of holding from inside.

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 2500
	maxHealth = 2500
	attacktext = "judges"
	attack_sound = 'sound/magic/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	pixel_x = -32
	del_on_death = TRUE
	internal_type = /obj/item/gps/internal/colossus
	medal_type = BOSS_MEDAL_COLOSSUS
	score_type = COLOSSUS_SCORE
	crusher_loot = list(/obj/structure/closet/crate/necropolis/colossus/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/colossus)
	deathmessage = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/misc/demon_dies.ogg'
	attack_action_types = list(/datum/action/innate/megafauna_attack/spiral_attack,
							   /datum/action/innate/megafauna_attack/aoe_attack,
							   /datum/action/innate/megafauna_attack/shotgun,
							   /datum/action/innate/megafauna_attack/alternating_cardinals)

/datum/action/innate/megafauna_attack/spiral_attack
	name = "Spiral Shots"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now firing in a spiral.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/aoe_attack
	name = "All Directions"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "at_shield2"
	chosen_message = "<span class='colossus'>You are now firing in all directions.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/shotgun
	name = "Shotgun Fire"
	icon_icon = 'icons/obj/guns/projectile.dmi'
	button_icon_state = "shotgun"
	chosen_message = "<span class='colossus'>You are now firing shotgun shots where you aim.</span>"
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/alternating_cardinals
	name = "Alternating Shots"
	icon_icon = 'icons/obj/guns/projectile.dmi'
	button_icon_state = "pistol"
	chosen_message = "<span class='colossus'>You are now firing in alternating cardinal directions.</span>"
	chosen_attack_num = 4

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + 120

	if(client)
		switch(chosen_attack)
			if(1)
				select_spiral_attack()
			if(2)
				random_shots()
			if(3)
				blast()
			if(4)
				alternating_dir_shots()
		return

	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message("<span class='colossus'>\"<b>You can't dodge.</b>\"</span>")
		ranged_cooldown = world.time + 30
		telegraph()
		dir_shots(alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	if(prob(20+anger_modifier)) //Major attack
		select_spiral_attack()
	else if(prob(20))
		random_shots()
	else
		if(prob(70))
			blast()
		else
			alternating_dir_shots()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/enrage(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.martial_art && prob(H.martial_art.deflection_chance))
			. = TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/proc/alternating_dir_shots()
	ranged_cooldown = world.time + 40
	dir_shots(diagonals)
	SLEEP_CHECK_DEATH(10)
	dir_shots(cardinal)
	SLEEP_CHECK_DEATH(10)
	dir_shots(diagonals)
	SLEEP_CHECK_DEATH(10)
	dir_shots(cardinal)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/select_spiral_attack()
	telegraph()
	if(health < maxHealth/3)
		return double_spiral()
	visible_message("<span class='colossus'>\"<b>Judgement.</b>\"</span>")
	return spiral_shoot()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	visible_message("<span class='colossus'>\"<b>Die.</b>\"</span>")

	SLEEP_CHECK_DEATH(10)
	INVOKE_ASYNC(src, .proc/spiral_shoot, FALSE)
	INVOKE_ASYNC(src, .proc/spiral_shoot, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = pick(TRUE, FALSE), counter_start = 8)
	var/turf/start_turf = get_step(src, pick(alldirs))
	var/counter = counter_start
	for(var/i in 1 to 80)
		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 1
		if(counter < 1)
			counter = 16
		shoot_projectile(start_turf, counter * 22.5)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
		SLEEP_CHECK_DEATH(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker, set_angle)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	P.preparePixelProjectile(marker, marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots()
	ranged_cooldown = world.time + 30
	var/turf/U = get_turf(src)
	playsound(U, 'sound/magic/clockwork/invoke_general.ogg', 300, TRUE, 5)
	for(var/T in RANGE_TURFS(12, U) - U)
		if(prob(5))
			shoot_projectile(T)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast(set_angle)
	ranged_cooldown = world.time + 20
	var/turf/target_turf = get_turf(target)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = Get_Angle(src, target_turf)
	if(isnum(set_angle))
		angle_to_target = set_angle
	var/static/list/colossus_shotgun_shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)
	for(var/i in colossus_shotgun_shot_angles)
		shoot_projectile(target_turf, angle_to_target + i)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = alldirs.Copy()
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#C80000", 1)
			shake_camera(M, 4, 3)
	playsound(src, 'sound/magic/narsie_attack.ogg', 200, TRUE)


/mob/living/simple_animal/hostile/megafauna/colossus/devour(mob/living/L)
	visible_message("<span class='colossus'>[src] disintegrates [L]!</span>")
	L.dust()

/obj/effect/temp_visual/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	light_range = 2
	duration = 8
	var/target

/obj/effect/temp_visual/at_shield/Initialize(mapload, new_target)
	. = ..()
	target = new_target
	INVOKE_ASYNC(src, /atom/movable/proc/orbit, target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	return ..()

/obj/item/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/item/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(2)

/obj/item/gps/internal/colossus
	icon_state = null
	gpstag = "Angelic Signal"
	desc = "Get in the fucking robot."
	invisibility = 100
