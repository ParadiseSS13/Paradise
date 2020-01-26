// SCP-106 HAS BREACHED CONTAINMENT
/mob/living/simple_animal/hostile/oldman
	name = "old man"
	real_name = "old man"
	desc = "A putrid, rotten humanoid, leaving a trail of death and decay. Has an unpleasant smile and is looking at you..."
	speak = list("spuaj...", "bletz...", "grur...", "hungry...", "blood...", "jaks...", "blerg...", "ajj...", "kreg...")
	speak_emote = list("gasps")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/hispania/mob/oldman.dmi'
	icon_state = "idle"
	icon_living = "oldman"
	incorporeal_move = 3
	invisibility = INVISIBILITY_REVENANT
	density = 0
	move_resist = INFINITY
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	var/dimension = TRUE
	speed = 1
	wander = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/hispania/effects/oldman/gasp1.ogg'
	death_sound = 'sound/misc/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "lashes"
	maxHealth = 1000
	health = 1000
	environment_smash = 1
	universal_understand = 1
	obj_damage = 50
	melee_damage_type = "fire"
	melee_damage_lower = 20
	melee_damage_upper = 25
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/vialspawned = FALSE

	var/devoured = 0
	var/list/consumed_mobs = list()

	loot = list(/obj/effect/decal/cleanable/blood/oil, /obj/effect/decal/cleanable/blood/oil, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic)
	var/playstyle_string = "<B>You are the Old Man, an ancient entity who has been hunting humanity for centuries and still hungers for more.  \
						You are slow, but very durable. Your attacks slows and corrode your victims. \
						You may Click on walls to travel through them, appearing and disappearing from the station at will. \
						Pulling a dead or critical mob while you enter a wall will pull them in with you, sending them to your pocket dimension. </B>"
	del_on_death = 1
	deathmessage = "lets out a screeching scream as it escapes to its pocket dimension!"

	vision_range = 1
	aggro_vision_range = 1


/mob/living/simple_animal/hostile/oldman/New()
	..()
	remove_from_all_data_huds()
	if(mind)
		to_chat(src, src.playstyle_string)
		to_chat(src, "<B><span class ='notice'>You are not currently in the same plane of existence as the station. Click a wall to emerge.</span></B>")
		if(!(vialspawned))
			to_chat(src, "<B>Objective #[1]</B>: Hunt down as much of the crew as you can.")

/mob/living/simple_animal/hostile/oldman/Life(seconds, times_fired)
	..()
	if(!dimension)
		if(prob(10))
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))

/mob/living/simple_animal/hostile/oldman/Destroy()
	// Only execute the below if we successfully died
	for(var/mob/living/M in consumed_mobs)
		release_consumed(M)
	. = ..()

/mob/living/simple_animal/hostile/oldman/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))

/mob/living/simple_animal/hostile/oldman/AttackingTarget()
	if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/T = target
		if(dimension)
			outdimension(T)
		else
			indimension(T)
		return
	if(dimension)
		return
	if(isliving(target) && (!client || a_intent == INTENT_HARM))
		var/attack = pick(list('sound/hispania/effects/oldman/gasp1.ogg','sound/hispania/effects/oldman/gasp2.ogg','sound/hispania/effects/oldman/sludge.ogg'))
		attack_sound = attack
		var/mob/living/carbon/human/L = target
		L.staminaloss += 20
		L.toxloss += 3
		if(prob(10))
			for(var/obj/item/organ/O in (L.bodyparts))
				O.germ_level = INFECTION_LEVEL_ONE
		..()
	else
		..()