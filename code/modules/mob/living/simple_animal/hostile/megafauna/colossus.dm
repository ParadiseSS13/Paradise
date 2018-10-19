
#define MEDAL_PREFIX "Colossus"
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
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -32
	del_on_death = 1
	medal_type = MEDAL_PREFIX
	score_type = COLOSSUS_SCORE
	loot = list(/obj/machinery/anomalous_crystal/random, /obj/item/organ/internal/vocal_cords/colossus)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	deathmessage = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/misc/demon_dies.ogg'

/mob/living/simple_animal/hostile/megafauna/colossus/devour(mob/living/L)
	visible_message("<span class='colossus'>[src] disintegrates [L]!</span>")
	L.dust()

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + 120

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
		telegraph()

		if(health < maxHealth/3)
			double_spiral()
		else
			visible_message("<span class='colossus'>\"<b>Judgement.</b>\"</span>")
			spawn(0)
				spiral_shoot(rand(0, 1))

	else if(prob(20))
		ranged_cooldown = world.time + 30
		random_shots()
	else
		if(prob(70))
			ranged_cooldown = world.time + 20
			blast()
		else
			ranged_cooldown = world.time + 40
			spawn(0)
				alternating_dir_shots()


/mob/living/simple_animal/hostile/megafauna/colossus/New()
	..()
	internal_gps = new/obj/item/gps/internal/colossus(src)

/obj/effect/temp_visual/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	luminosity = 2
	duration = 8
	var/target

/obj/effect/temp_visual/at_shield/New(new_loc, new_target)
	..()
	target = new_target
	spawn(0)
		orbit(target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	..()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/enrage(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.martial_art && prob(H.martial_art.deflection_chance))
			. = TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/proc/alternating_dir_shots()
	dir_shots(diagonals)
	sleep(10)
	dir_shots(cardinal)
	sleep(10)
	dir_shots(diagonals)
	sleep(10)
	dir_shots(cardinal)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	visible_message("<span class='colossus'>\"<b>Die.</b>\"</span>")

	sleep(10)
	spawn(0)
		spiral_shoot()
	spawn(0)
		spiral_shoot(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = 0, counter_start = 1)
	var/counter = counter_start
	var/turf/marker
	for(var/i in 1 to 80)
		switch(counter)
			if(1)
				marker = locate(x, y - 2, z)
			if(2)
				marker = locate(x - 1, y - 2, z)
			if(3)
				marker = locate(x - 2, y - 2, z)
			if(4)
				marker = locate(x - 2, y - 1, z)
			if(5)
				marker = locate(x - 2, y, z)
			if(6)
				marker = locate(x - 2, y + 1, z)
			if(7)
				marker = locate(x - 2, y + 2, z)
			if(8)
				marker = locate(x - 1, y + 2, z)
			if(9)
				marker = locate(x, y + 2, z)
			if(10)
				marker = locate(x + 1, y + 2, z)
			if(11)
				marker = locate(x + 2, y + 2, z)
			if(12)
				marker = locate(x + 2, y + 1, z)
			if(13)
				marker = locate(x + 2, y, z)
			if(14)
				marker = locate(x + 2, y - 1, z)
			if(15)
				marker = locate(x + 2, y - 2, z)
			if(16)
				marker = locate(x + 1, y - 2, z)

		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 1
		if(counter < 1)
			counter = 16
		shoot_projectile(marker)
		playsound(get_turf(src), 'sound/magic/invoke_general.ogg', 20, 1)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots()
	var/turf/U = get_turf(src)
	playsound(U, 'sound/magic/invoke_general.ogg', 300, 1, 5)
	for(var/T in RANGE_TURFS(12, U) - U)
		if(prob(5))
			shoot_projectile(T)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast()
	playsound(get_turf(src), 'sound/magic/invoke_general.ogg', 200, 1, 2)
	var/turf/T = get_turf(target)
	newtonian_move(get_dir(T, targets_from))
	for(var/turf/turf in range(1, T))
		shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = alldirs.Copy()
	playsound(get_turf(src), 'sound/magic/invoke_general.ogg', 200, 1, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, rgb(200, 0, 0), 1)
			shake_camera(M, 4, 3)
	playsound(get_turf(src),'sound/magic/narsie_attack.ogg', 200, 1)

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

#undef MEDAL_PREFIX
