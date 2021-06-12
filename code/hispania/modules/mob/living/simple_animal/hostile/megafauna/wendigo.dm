#define WENDIGO_ENRAGED (health <= maxHealth*0.5)
#define WENDIGO_CIRCLE_SHOTCOUNT 24
#define WENDIGO_CIRCLE_REPEATCOUNT 8
#define WENDIGO_SPIRAL_SHOTCOUNT 40
#define WENDIGO_WAVE_SHOTCOUNT 7
#define WENDIGO_WAVE_REPEATCOUNT 32
#define WENDIGO_SHOTGUN_SHOTCOUNT 5
#define COOLDOWN_DECLARE(cd_index) var/##cd_index = 0
#define COOLDOWN_FINISHED(cd_source, cd_index) (cd_source.cd_index < world.time)
#define COOLDOWN_RESET(cd_source, cd_index) cd_source.cd_index = 0
#define COOLDOWN_START(cd_source, cd_index, cd_time) (cd_source.cd_index = world.time + cd_time)
#define HEAR_1 (1<<0)

/mob/living/simple_animal/hostile/megafauna/wendigo
	name = "wendigo"
	desc = "A mythological man-eating legendary creature, you probably aren't going to survive this."
	health = 2500
	maxHealth = 2500
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"
	icon = 'icons/hispania/mob/lavaland/wendigo.dmi'
	attacktext = "claws"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	faction = list("creature")
	footstep_type = FOOTSTEP_MOB_HEAVY
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	vision_range = 9
	aggro_vision_range = 18 // man-eating for a reason
	speed = 6
	move_to_delay = 6
	rapid_melee = 8
	melee_queue_distance = 18
	ranged = TRUE
	pixel_x = -16
	internal_type = /obj/item/gps/internal/wendigo
	loot = list()
	butcher_results = list(/obj/item/wendigo_blood = 1, /obj/item/wendigo_skull = 1)
	crusher_loot = list(/obj/item/crusher_trophy/wendigo_horn)
	wander = FALSE
	del_on_death = FALSE
	blood_volume = BLOOD_VOLUME_NORMAL
	deathmessage = "falls, shaking the ground around it"
	death_sound = 'sound/hispania/effects/gravhit.ogg'
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/heavy_stomp,
							   /datum/action/innate/megafauna_attack/teleport,
							   /datum/action/innate/megafauna_attack/shockwave_scream)
	var/turf/starting
	var/stomp_range = 1
	var/stored_move_dirs = 0
	var/can_move = TRUE
	var/scream_cooldown_time = 10 SECONDS
	COOLDOWN_DECLARE(scream_cooldown)

/obj/item/gps/internal/wendigo
	icon_state = null
	gpstag = "Berserk Signal"
	desc = "Fear the man eating creature"
	invisibility = 100

/datum/action/innate/megafauna_attack/heavy_stomp
	name = "Heavy Stomp"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now stomping the ground around you.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/teleport
	name = "Teleport"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='colossus'>You are now teleporting at the target you click on.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/shockwave_scream
	name = "Shockwave Scream"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall-0"
	chosen_message = "<span class='colossus'>You are now screeching, disorienting targets around you.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize()
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/OpenFire()
	SetRecoveryTime(10 SECONDS)
	if(WENDIGO_ENRAGED)
		speed = 4
		move_to_delay = 4
	else
		stomp_range = initial(stomp_range)
		speed = initial(speed)
		move_to_delay = initial(move_to_delay)

	if(client)
		switch(chosen_attack)
			if(1)
				heavy_stomp()
			if(2)
				try_teleport()
			if(3)
				shockwave_scream()
		return

	if(COOLDOWN_FINISHED(src, scream_cooldown))
		chosen_attack = rand(1, 3)
	else
		chosen_attack = rand(1, 2)
	switch(chosen_attack)
		if(1)
			heavy_stomp()
		if(2)
			try_teleport()
		if(3)
			do_teleport(src, starting, 0, "bluespace", bypass_area_flag = TRUE)
			shockwave_scream()

/mob/living/simple_animal/hostile/megafauna/wendigo/Move(atom/newloc, direct)
	if(!can_move)
		return
	stored_move_dirs |= direct
	return ..()

/mob/living/simple_animal/hostile/megafauna/wendigo/Moved(atom/oldloc, direct)
	. = ..()
	stored_move_dirs &= ~direct
	if(!stored_move_dirs)
		INVOKE_ASYNC(GLOBAL_PROC, .proc/wendigo_slam, src, stomp_range, 1, 8)

/proc/get_ranged_target_turf_direct(atom/A, atom/target, range, offset) //No se donde mas ponerlo lol
	var/angle = ATAN2(target.x - A.x, target.y - A.y)
	if(offset)
		angle += offset
	var/turf/T = get_turf(A)
	for(var/i in 1 to range)
		var/turf/check = locate(A.x + cos(angle) * i, A.y + sin(angle) * i, A.z)
		if(!check)
			break
		T = check

	return T

/proc/wendigo_slam(atom/source, range, delay, throw_range)
	var/turf/orgin = get_turf(source)
	var/list/all_turfs = RANGE_TURFS(range, orgin)
	for(var/i = 0 to range)
		playsound(orgin,'sound/effects/bamf.ogg', 600, TRUE, 10)
		for(var/turf/stomp_turf in all_turfs)
			if(get_dist(orgin, stomp_turf) > i)
				continue
			new /obj/effect/temp_visual/small_smoke/halfsecond(stomp_turf)
			for(var/mob/living/L in stomp_turf)
				if(L == source || L.throwing)
					continue
				to_chat(L, "<span class='userdanger'>[source]'s ground slam shockwave sends you flying!</span>")
				var/turf/thrownat = get_ranged_target_turf_direct(source, L, throw_range, rand(-10, 10))
				L.throw_at(thrownat, 8, 2, null, TRUE, force = MOVE_FORCE_OVERPOWERING)
				L.apply_damage(40, BRUTE)
				shake_camera(L, 2, 1)
			all_turfs -= stomp_turf
		sleep(delay)

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/heavy_stomp()
	can_move = FALSE
	wendigo_slam(src, 5, 3 - WENDIGO_ENRAGED, 8)
	SetRecoveryTime(0 SECONDS)
	can_move = TRUE

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/try_teleport()
	teleport(6)
	if(WENDIGO_ENRAGED)
		playsound(loc, 'sound/magic/clockwork/invoke_general.ogg', 100, TRUE)
		for(var/shots in 1 to WENDIGO_SHOTGUN_SHOTCOUNT)
			var/spread = shots * 10 - 30
			var/turf/startloc = get_step(get_turf(src), get_dir(src, target))
			var/turf/endloc = get_turf(target)
			if(!endloc)
				break
			var/obj/item/projectile/wendigo_shockwave/shockwave = new /obj/item/projectile/wendigo_shockwave (loc)
			shockwave.speed = 8
			shockwave.preparePixelProjectile(endloc, startloc, null, spread)
			shockwave.firer = src
			if(target)
				shockwave.original = target
			shockwave.fire()
	SetRecoveryTime(0 SECONDS)

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/teleport(range = 6)
	var/list/possible_ends = view(range, target.loc) - view(range - 1, target.loc)
	for(var/turf/simulated/floor/cant_teleport_turf in possible_ends)
		possible_ends -= cant_teleport_turf
	if(!possible_ends.len)
		return
	var/turf/end = pick(possible_ends)
	do_teleport(src, end, 0, "bluespace", bypass_area_flag = TRUE)

/proc/get_hearers_in_view(R, atom/source)
	var/turf/T = get_turf(source)
	. = list()
	if(!T)
		return
	var/list/processing_list = list()
	if (R == 0)
		processing_list += T.contents
	else
		var/lum = T.luminosity
		T.luminosity = 6
		for(var/mob/M in view(R, T))
			processing_list += M
		for(var/obj/O in view(R, T))
			processing_list += O
		T.luminosity = lum

	var/i = 0
	while(i < length(processing_list))
		var/atom/A = processing_list[++i]
		if(A.flags & HEAR_1)
			. += A
			SEND_SIGNAL(A, COMSIG_ATOM_HEARER_IN_VIEW, processing_list, .)
		processing_list += A.contents

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/shockwave_scream()
	can_move = FALSE
	COOLDOWN_START(src, scream_cooldown, scream_cooldown_time)
	SLEEP_CHECK_DEATH(5)
	playsound(loc, 'sound/misc/demon_dies.ogg', 600, FALSE, 10)
	animate(src, pixel_z = rand(5, 15), time = 1, loop = 20)
	animate(pixel_z = 0, time = 1)
	for(var/mob/living/dizzy_target in get_hearers_in_view(7, src) - src)
		dizzy_target.Dizzy(6)
		to_chat(dizzy_target, "<span class='danger'>The wendigo screams loudly!</span>")
	SLEEP_CHECK_DEATH(1 SECONDS)
	spiral_attack()
	SetRecoveryTime(3 SECONDS)
	SLEEP_CHECK_DEATH(3 SECONDS)
	can_move = TRUE

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/spiral_attack()
	var/list/choices = list("Alternating Circle", "Spiral")
	if(WENDIGO_ENRAGED)
		choices += "Wave"
	var/spiral_type = pick(choices)
	switch(spiral_type)
		if("Alternating Circle")
			var/shots_per = WENDIGO_CIRCLE_SHOTCOUNT
			for(var/shoot_times in 1 to WENDIGO_CIRCLE_REPEATCOUNT)
				var/offset = shoot_times % 2
				for(var/shot in 1 to shots_per)
					var/angle = shot * 360 / shots_per + (offset * 360 / shots_per) * 0.5
					var/obj/item/projectile/wendigo_shockwave/shockwave = new /obj/item/projectile/wendigo_shockwave(loc)
					shockwave.firer = src
					shockwave.speed = 3 - WENDIGO_ENRAGED
					shockwave.fire(angle)
				SLEEP_CHECK_DEATH(6 - WENDIGO_ENRAGED * 2)
		if("Spiral")
			var/shots_spiral = WENDIGO_SPIRAL_SHOTCOUNT
			var/angle_to_target = Get_Angle(src, target)
			var/spiral_direction = pick(-1, 1)
			for(var/shot in 1 to shots_spiral)
				var/shots_per_tick = 5 - WENDIGO_ENRAGED * 3
				var/angle_change = (5 + WENDIGO_ENRAGED * shot / 6) * spiral_direction
				for(var/count in 1 to shots_per_tick)
					var/angle = angle_to_target + shot * angle_change + count * 360 / shots_per_tick
					var/obj/item/projectile/wendigo_shockwave/shockwave = new /obj/item/projectile/wendigo_shockwave(loc)
					shockwave.firer = src
					shockwave.damage = 15
					shockwave.fire(angle)
				SLEEP_CHECK_DEATH(1)
		if("Wave")
			var/shots_per = WENDIGO_WAVE_SHOTCOUNT
			var/difference = 360 / shots_per
			var/wave_direction = pick(-1, 1)
			for(var/shoot_times in 1 to WENDIGO_WAVE_REPEATCOUNT)
				for(var/shot in 1 to shots_per)
					var/angle = shot * difference + shoot_times * 5 * wave_direction * -1
					var/obj/item/projectile/wendigo_shockwave/shockwave = new /obj/item/projectile/wendigo_shockwave(loc)
					shockwave.firer = src
					shockwave.speed = 8
					shockwave.wave_speed = 10 * wave_direction
					shockwave.fire(angle)
				SLEEP_CHECK_DEATH(2)
/obj/item/projectile/wendigo_shockwave
	name ="wendigo shockwave"
	icon_state= "meatproj"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 5
	damage_type = BRUTE
	pass_flags = PASSTABLE
	var/wave_speed = 15
	var/pixel_moves = 0

/obj/item/wendigo_blood
	name = "bottle of wendigo blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/wendigo_blood/attack_self(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(!human_user.mind)
		return
	to_chat(human_user, "<span class='danger'>Power courses through you! You can now shift your form at will.</span>")
	var/obj/effect/proc_holder/spell/targeted/shapeshift/polar_bear/transformation_spell = new
	human_user.mind.AddSpell(transformation_spell)
	playsound(human_user.loc, 'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

/mob/living/simple_animal/hostile/bear/wendigo_version //¿Alguien si quiera puede matarlo?
	name = "Polar Bear"
	maxHealth = 500
	health = 500
	melee_damage_lower = 50
	melee_damage_upper = 50
	icon = 'icons/hispania/mob/animals.dmi'
/obj/effect/proc_holder/spell/targeted/shapeshift/polar_bear
	name = "Polar Bear Form"
	desc = "Take on the shape of a polar bear."
	invocation = "RAAAAAAAAWR!"
	shapeshift_type = /mob/living/simple_animal/hostile/bear/wendigo_version

/obj/item/crusher_trophy/wendigo_horn //OP SHIT
	name = "wendigo horn"
	desc = "A horn from the head of an unstoppable beast."
	icon_state = "wendigo_horn"
	denied_type = /obj/item/crusher_trophy/wendigo_horn

/obj/item/crusher_trophy/wendigo_horn/effect_desc()
	return

/obj/item/crusher_trophy/wendigo_horn/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	H.force += (bonus_value*2)

/obj/item/crusher_trophy/wendigo_horn/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	H.force -= (bonus_value*2)

/obj/item/wendigo_skull
	name = "wendigo skull"
	desc = "A skull of a massive hulking beast."
	icon = 'icons/hispania/obj/lavaland/artefacts.dmi'
	icon_state = "wendigo_skull"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0

/mob/living/simple_animal/hostile/megafauna/wendigo/meatoverlord
	name = "Redspace Overlord"
	desc = "A disgusting creature that makes you wanna vomit, you probably aren't going to survive this."
	icon_state = "meatboss"
	icon_living = "meatboss"
	icon_dead = "meatboss_dead"
	icon = 'icons/hispania/mob/lavaland/meatoverlord.dmi'

#undef WENDIGO_CIRCLE_SHOTCOUNT
#undef WENDIGO_CIRCLE_REPEATCOUNT
#undef WENDIGO_SPIRAL_SHOTCOUNT
#undef WENDIGO_WAVE_SHOTCOUNT
#undef WENDIGO_WAVE_REPEATCOUNT
#undef WENDIGO_SHOTGUN_SHOTCOUNT
