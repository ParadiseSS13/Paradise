#define RANDOM_SHOTS "Wrath"
#define BLAST "Retribution"
#define DIR_SHOTS "Lament"

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
	armour_penetration_percentage = 50
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	pixel_x = -32
	del_on_death = TRUE
	universal_speak = TRUE
	internal_gps = /obj/item/gps/internal/colossus
	medal_type = BOSS_MEDAL_COLOSSUS
	score_type = COLOSSUS_SCORE
	crusher_loot = list(/obj/structure/closet/crate/necropolis/colossus/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/colossus)
	deathmessage = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/misc/demon_dies.ogg'
	enraged_loot = /obj/item/disk/fauna_research/colossus
	attack_action_types = list(/datum/action/innate/megafauna_attack/spiral_attack,
							/datum/action/innate/megafauna_attack/aoe_attack,
							/datum/action/innate/megafauna_attack/shotgun,
							/datum/action/innate/megafauna_attack/alternating_cardinals)
	/// Have we used our final attack yet?
	var/final_available = TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/mob/living/simple_animal/hostile/megafauna/colossus/LateInitialize()
	. = ..()
	for(var/mob/living/simple_animal/hostile/megafauna/hierophant/H in GLOB.mob_list)
		H.RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, TYPE_PROC_REF(/mob/living/simple_animal/hostile/megafauna/hierophant, easy_anti_cheese))

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

/mob/living/simple_animal/hostile/megafauna/colossus/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	. = ..(("<span class='colossus'><b>[uppertext(message)]</b></span>"), sanitize = FALSE, ignore_speech_problems = TRUE, ignore_atmospherics = TRUE)


/mob/living/simple_animal/hostile/megafauna/colossus/enrage()
	. = ..()
	move_to_delay = 5

/mob/living/simple_animal/hostile/megafauna/colossus/unrage()
	. = ..()
	move_to_delay = initial(move_to_delay)

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
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

	if(target_trying_to_cheese_us(target))
		if(move_to_delay == initial(move_to_delay))
			say("You can't dodge")
		ranged_cooldown = world.time + 30
		telegraph()
		dir_shots(GLOB.alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	if(health <= maxHealth / (enraged ? 10 : 9) && final_available) //One time use final attack. Want to make it not get skipped as much on base colossus, but a little easier to skip on enraged as it can be used multiple times
		final_attack()
		if(!enraged)
			final_available = FALSE
	else if(prob(20 + anger_modifier)) //Major attack
		select_spiral_attack()
	else if(prob(20))
		random_shots()
	else
		if(prob(70))
			blast()
		else
			alternating_dir_shots()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/target_trying_to_cheese_us(mob/living/L)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(H.mind && H.mind.martial_art && prob(H.mind.martial_art.deflection_chance))
		return TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/proc/alternating_dir_shots(telegraphing = TRUE)
	var/rage = enraged ? 5 : 10
	if(telegraphing)
		ranged_cooldown = world.time + 4 SECONDS
		telegraph(DIR_SHOTS)
		SLEEP_CHECK_DEATH(1.5 SECONDS)
	dir_shots(GLOB.diagonals)
	SLEEP_CHECK_DEATH(rage)
	dir_shots(GLOB.cardinal)
	SLEEP_CHECK_DEATH(rage)
	dir_shots(GLOB.diagonals)
	SLEEP_CHECK_DEATH(rage)
	dir_shots(GLOB.cardinal)
	if(telegraphing)
		alternating_dir_shots(FALSE)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/select_spiral_attack()
	if(health < maxHealth/3)
		return double_spiral()
	say("Judgement.")
	telegraph()
	SLEEP_CHECK_DEATH(1.5 SECONDS)
	return spiral_shoot()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	say("Die.")
	telegraph()
	SLEEP_CHECK_DEATH(2.5 SECONDS)
	INVOKE_ASYNC(src, PROC_REF(spiral_shoot), FALSE)
	INVOKE_ASYNC(src, PROC_REF(spiral_shoot), TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = pick(TRUE, FALSE), counter_start = 8)
	icon_state = "eva_attack"
	var/turf/start_turf = get_step(src, pick(GLOB.alldirs))
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
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker, set_angle)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	P.preparePixelProjectile(marker, marker, startloc)
	P.firer = src
	P.firer_source_atom = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots(do_sleep = TRUE)
	ranged_cooldown = world.time + 30
	if(do_sleep)
		telegraph(RANDOM_SHOTS)
		SLEEP_CHECK_DEATH(1.5 SECONDS)
	var/turf/U = get_turf(src)
	playsound(U, 'sound/magic/clockwork/invoke_general.ogg', 300, TRUE, 5)
	for(var/T in RANGE_TURFS(12, U) - U)
		if(prob(enraged ? 10 : 5))
			shoot_projectile(T)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast(set_angle, do_sleep = TRUE)
	ranged_cooldown = world.time + 20
	if(do_sleep)
		telegraph(BLAST)
		SLEEP_CHECK_DEATH(enraged ? 0.1 SECONDS : 1.5 SECONDS)
	var/turf/target_turf = get_turf(target)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = get_angle(src, target_turf)
	if(isnum(set_angle))
		angle_to_target = set_angle
	var/static/list/colossus_shotgun_shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)
	for(var/i in colossus_shotgun_shot_angles)
		shoot_projectile(target_turf, angle_to_target + i)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph(mode)
	for(var/mob/M in range(10, src))
		M.flash_screen_color("#C80000", 1)
		shake_camera(M, 4, 3)
	playsound(src, 'sound/magic/narsie_attack.ogg', 200, TRUE)
	if(mode)
		say("[mode]")

/mob/living/simple_animal/hostile/megafauna/colossus/proc/final_attack()
	icon_state = "eva_attack"
	say("PERISH MORTAL!")
	telegraph()
	ranged_cooldown = world.time + 20 SECONDS // Yeah let us NOT have people get triple attacked
	SLEEP_CHECK_DEATH(2.5 SECONDS) //run

	var/finale_counter = 10
	for(var/i in 1 to 20)
		if(finale_counter > 4)
			telegraph()
			blast(do_sleep = FALSE)

		if(finale_counter > 1)
			finale_counter--

		var/turf/start_turf = get_turf(src)
		for(var/turf/target_turf in RANGE_TURFS(12, start_turf))
			if(prob(min(finale_counter, 2)) && target_turf != get_turf(src))
				shoot_projectile(target_turf)

		SLEEP_CHECK_DEATH(finale_counter + 0.2 SECONDS) //Doubled from TG, this was insane

	for(var/i in 1 to 3)
		telegraph()
		random_shots(do_sleep = FALSE)
		finale_counter += 6
		SLEEP_CHECK_DEATH(finale_counter)

	for(var/i in 1 to 3)
		telegraph()
		dir_shots()
		SLEEP_CHECK_DEATH(1 SECONDS)
	icon_state = initial(icon_state)
	ranged_cooldown = world.time + 4 SECONDS

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
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, orbit), target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	return ..()

/mob/living/simple_animal/hostile/megafauna/colossus/float(on) //we don't want this guy to float, messes up his animations
	if(throwing)
		return
	floating = on

/obj/item/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration_percentage = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/item/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(2)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			L.dust()

/obj/item/gps/internal/colossus
	icon_state = null
	gpstag = "Angelic Signal"
	desc = "Get in the fucking robot."
	invisibility = 100

#undef RANDOM_SHOTS
#undef BLAST
#undef DIR_SHOTS
