/*

LEGION

Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort.

It has two attack modes that it constantly rotates between.

In ranged mode, it will behave like a normal legion - retreating when possible and firing legion skulls at the target.
In charge mode, it will spin and rush its target, attacking with melee whenever possible.

When Legion dies, it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 2500
	maxHealth = 2500
	icon_state = "mega_legion"
	icon_living = "mega_legion"
	icon_dead = "mega_legion_dead"
	desc = "One of many."
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	attacktext = "chomps"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	speak_emote = list("echoes")
	armor_penetration_percentage = 50
	melee_damage_lower = 40
	melee_damage_upper = 40
	wander = FALSE
	speed = 2
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	pixel_x = -32
	ranged_cooldown_time = 20
	var/charging = FALSE
	var/firing_laser = FALSE
	internal_gps = /obj/item/gps/internal/legion
	medal_type = BOSS_MEDAL_LEGION
	score_type = LEGION_SCORE
	loot = list(/obj/item/storm_staff)
	difficulty_ore_modifier = 3
	crusher_loot = list(/obj/item/crusher_trophy/empowered_legion_skull)
	enraged_loot = /obj/item/disk/fauna_research/legion
	vision_range = 13
	elimination = TRUE
	stat_attack = UNCONSCIOUS // Overriden from /tg/ - otherwise Legion starts chasing its minions
	appearance_flags = 512
	contains_xeno_organ = TRUE
	ignore_generic_organs = TRUE
	surgery_container = /datum/xenobiology_surgery_container/legion

/mob/living/simple_animal/hostile/megafauna/legion/Initialize(mapload)
	. = ..()
	transform *= 2

/mob/living/simple_animal/hostile/megafauna/legion/enrage()
	if(enraged || ((health / maxHealth) * 100 <= 80))
		return
	enraged = TRUE
	health = 1250
	maxHealth = 1250
	transform /= 1.5
	loot = list()
	crusher_loot = list()
	var/mob/living/simple_animal/hostile/megafauna/legion/legiontwo = new /mob/living/simple_animal/hostile/megafauna/legion(get_turf(src))
	legiontwo.enraged = TRUE
	legiontwo.health = 1250
	legiontwo.maxHealth = 1250
	legiontwo.transform /= 1.5
	legiontwo.loot = list()
	legiontwo.crusher_loot = list()

/mob/living/simple_animal/hostile/megafauna/legion/unrage()
	. = ..()
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_list)
		if(other != src)
			other.loot = list(/obj/item/storm_staff) //Initial does not work with lists.
			other.crusher_loot = list(/obj/item/crusher_trophy/empowered_legion_skull)
			other.maxHealth = 2500
			other.health = 2500
	qdel(src) //Suprise, it's the one on lavaland that regrows to full.

/mob/living/simple_animal/hostile/megafauna/legion/drop_loot()
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_list)
		if(other != src && other.stat != DEAD)
			return
	..()

/mob/living/simple_animal/hostile/megafauna/legion/death(gibbed)
	icon = 'icons/mob/lavaland/corpses.dmi'
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_list)
		if(other != src)
			other.loot = list(/obj/item/storm_staff) //Initial does not work with lists.
			other.crusher_loot = list(/obj/item/crusher_trophy/empowered_legion_skull)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/L = target
		if(L.stat == UNCONSCIOUS)
			var/mob/living/basic/mining/hivelordbrood/legion/A = new(loc)
			A.infest(L)

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(world.time >= ranged_cooldown && !charging)
		if(prob(30))
			visible_message("<span class='warning'><b>[src] charges!</b></span>")
			SpinAnimation(speed = 20, loops = 5, parallel = FALSE)
			ranged = FALSE
			retreat_distance = 0
			minimum_distance = 0
			move_to_delay = 2
			speed = 0
			charging = TRUE
			ranged_cooldown = world.time + 3 SECONDS
			SLEEP_CHECK_DEATH(3 SECONDS)
			set_ranged()
		else if(prob(60))
			firing_laser = TRUE
			var/beam_angle = get_angle(src, locate(target.x - 1, target.y, target.z)) // -1 to account for the legion sprite offset.
			var/turf/target_location = locate(x + (50 * sin(beam_angle)), y + (50 * cos(beam_angle)), z)
			var/beam_time = 0.25 SECONDS + ((health / maxHealth) SECONDS)
			playsound(loc, 'sound/effects/basscannon.ogg', 200, TRUE)
			Beam(target_location, icon_state = "death_laser", time = beam_time, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/disintegration_telegraph)
			addtimer(CALLBACK(src, PROC_REF(fire_disintegration_laser), target_location), beam_time)
			ranged_cooldown = world.time + beam_time + 2 SECONDS
			SLEEP_CHECK_DEATH(beam_time + 2 SECONDS)
			firing_laser = FALSE
		else if(prob(40))
			var/mob/living/basic/mining/big_legion/A = new(loc)
			A.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
			A.ai_controller.set_blackboard_key(BB_FRIENDS_LIST, friends)
			A.faction = faction
			visible_message("<span class='danger'>A monstrosity emerges from [src]</span>",
			"<span class='userdanger'>You summon a big [A]!</span>")
			ranged_cooldown = world.time + 5 SECONDS
		else
			var/mob/living/basic/mining/hivelord/legion/A
			if(enraged)
				A = new /mob/living/basic/mining/hivelord/legion/advanced(loc)
				ADD_TRAIT(A, TRAIT_FROM_TENDRIL, INNATE_TRAIT)
			else
				A = new /mob/living/basic/mining/hivelord/legion(loc)
				ADD_TRAIT(A, TRAIT_FROM_TENDRIL, INNATE_TRAIT)
			A.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
			A.ai_controller.set_blackboard_key(BB_FRIENDS_LIST, friends)
			A.faction = faction
			visible_message("<span class='danger'>A [A] emerges from [src]!</span>",
			"<span class='userdanger'>You summon a [A]!</span>")
			ranged_cooldown = world.time + 2 SECONDS

/mob/living/simple_animal/hostile/megafauna/legion/MoveToTarget()
	if(firing_laser)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/legion/Move()
	if(firing_laser)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/megafauna/legion/Goto(target, delay, minimum_distance)
	if(firing_laser)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/legion/proc/set_ranged()
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	move_to_delay = 2
	speed = 2
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/legion/proc/fire_disintegration_laser(location)
	playsound(loc, 'sound/weapons/marauder.ogg', 200, TRUE)
	Beam(location, icon_state = "death_laser", time = 2 SECONDS, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/disintegration)
	for(var/turf/t in get_line(src, location))
		if(ismineralturf(t))
			var/turf/simulated/mineral/M = t
			M.gets_drilled(src)
		if(iswallturf(t))
			var/turf/simulated/wall/W = t
			W.thermitemelt(speed = 1 SECONDS) //Melt that shit DOWN
		for(var/mob/living/M in t)
			if(faction_check(M.faction, faction, FALSE))
				continue

			if(M.stat == DEAD)
				visible_message("<span class='danger'>[M] is disintegrated by the beam!</span>")
				M.dust()
			else if(M != src)
				playsound(M,'sound/weapons/sear.ogg', 50, TRUE, -4)
				to_chat(M, "<span class='userdanger'>You're struck by a disintegration laser!</span>")
				var/limb_to_hit = M.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
				var/armor = M.run_armor_check(limb_to_hit, LASER)
				M.apply_damage(70 - ((health / maxHealth) * 20), BURN, limb_to_hit, armor)

/mob/living/simple_animal/hostile/megafauna/legion/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1

/mob/living/simple_animal/hostile/megafauna/legion/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(QDELETED(src))
		return
	if(GLOB.necropolis_gate && !GLOB.necropolis_gate.open)
		GLOB.necropolis_gate.toggle_the_gate(src)
	if(.)
		var/matrix/M = new
		resize = (enraged ? 0.33 : 1) + (health / maxHealth)
		M.Scale(resize, resize)
		transform = M
		if(amount > 0 && (enraged || prob(33)))
			var/mob/living/basic/mining/hivelordbrood/A
			if(enraged)
				A = new /mob/living/basic/mining/hivelordbrood/legion/advanced(loc)
			else
				A = new /mob/living/basic/mining/hivelordbrood/legion(loc)
			if(!enraged || prob(33))
				A.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
			else
				for(var/mob/living/carbon/human/H in range(7, src))
					if(H.stat == DEAD)
						A.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, H)
						break
			A.ai_controller.set_blackboard_key(BB_FRIENDS_LIST, friends)
			A.faction = faction

/obj/item/gps/internal/legion
	icon_state = null
	gpstag = "Echoing Signal"
	desc = "The message repeats."
