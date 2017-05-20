/mob/living/simple_animal/hostile
	faction = list("hostile")
	stop_automated_movement_when_pulled = 0
	environment_smash = 1 //Set to 1 to break closets,tables,racks, etc; 2 for walls; 3 for rwalls
	var/atom/target
	var/ranged = 0
	var/rapid = 0
	var/projectiletype
	var/projectilesound
	var/casingtype
	var/move_to_delay = 3 //delay for the automated movement.
	var/list/friends = list()
	var/ranged_message = "fires" //Fluff text for ranged mobs
	var/ranged_cooldown = 0 //What the starting cooldown is on ranged attacks
	var/ranged_cooldown_time = 30 //How long, in deciseconds, the cooldown of ranged attacks is
	var/ranged_ignores_vision = FALSE //if it'll fire ranged attacks even if it lacks vision on its target, only works with environment smash
	var/check_friendly_fire = 0 // Should the ranged mob check for friendlies when shooting
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/minimum_distance = 1 //Minimum approach distance, so ranged mobs chase targets down, but still keep their distance set in tiles to the target, set higher to make mobs keep distance

//These vars are related to how mobs locate and target
	var/robust_searching = 0 //By default, mobs have a simple searching method, set this to 1 for the more scrutinous searching (stat_attack, stat_exclusive, etc), should be disabled on most mobs
	var/vision_range = 9 //How big of an area to search for targets in, a vision of 9 attempts to find targets as soon as they walk into screen view
	var/aggro_vision_range = 9 //If a mob is aggro, we search in this radius. Defaults to 9 to keep in line with original simple mob aggro radius
	var/idle_vision_range = 9 //If a mob is just idling around, it's vision range is limited to this. Defaults to 9 to keep in line with original simple mob aggro radius
	var/search_objects = 0 //If we want to consider objects when searching around, set this to 1. If you want to search for objects while also ignoring mobs until hurt, set it to 2. To completely ignore mobs, even when attacked, set it to 3
	var/list/wanted_objects = list() //A list of objects that will be checked against to attack, should we have search_objects enabled
	var/stat_attack = 0 //Mobs with stat_attack to 1 will attempt to attack things that are unconscious, Mobs with stat_attack set to 2 will attempt to attack the dead.
	var/stat_exclusive = 0 //Mobs with this set to 1 will exclusively attack things defined by stat_attack, stat_attack 2 means they will only attack corpses
	var/attack_same = 0 //Set us to 1 to allow us to attack our own faction, or 2, to only ever attack our own faction

	var/AIStatus = AI_ON //The Status of our AI, can be set to AI_ON (On, usual processing), AI_IDLE (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever)

	//typecache of things this mob will attack in DestroySurroundings() if it has environment_smash
	var/list/environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/girder,
	/obj/structure/rack,
	/obj/structure/barricade) //turned into a typecache in New()
	var/atom/targets_from = null //all range/attack/etc. calculations should be done from this atom, defaults to the mob itself, useful for Vehicles and such
	var/list/emote_taunt = list()
	var/taunt_chance = 0

/mob/living/simple_animal/hostile/New()
	..()
	if(!targets_from)
		targets_from = src
	environment_target_typecache = typecacheof(environment_target_typecache)

/mob/living/simple_animal/hostile/Destroy()
	targets_from = null
	target = null
	return ..()

/mob/living/simple_animal/hostile/Life()
	. = ..()
	if(!.)
		walk(src, 0)
		return 0

/mob/living/simple_animal/hostile/process_ai()
	..()
	if(!AICanContinue())
		return 0
	return 1

/mob/living/simple_animal/hostile/handle_automated_action()
	if(AIStatus == AI_OFF)
		return 0
	var/list/possible_targets = ListTargets() //we look around for potential targets and make it a list for later use.
	if(environment_smash)
		EscapeConfinement()

	if(AICanContinue(possible_targets))
		DestroySurroundings()
		if(!MoveToTarget(possible_targets))     //if we lose our target
			if(AIShouldSleep(possible_targets))	// we try to acquire a new one
				AIStatus = AI_IDLE				// otherwise we go idle
	return 1

/mob/living/simple_animal/hostile/attacked_by(obj/item/I, mob/living/user)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client && user)
		FindTarget(list(user), 1)
	return ..()

/mob/living/simple_animal/hostile/bullet_act(obj/item/projectile/P)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client)
		if(P.firer && get_dist(src, P.firer) <= aggro_vision_range)
			FindTarget(list(P.firer), 1)
		Goto(P.starting, move_to_delay, 3)
	return ..()

//////////////HOSTILE MOB TARGETTING AND AGGRESSION////////////


/mob/living/simple_animal/hostile/proc/ListTargets()//Step 1, find out what we can see
	. = list()
	if(!search_objects)
		var/list/Mobs = hearers(vision_range, targets_from) - src //Remove self, so we don't suicide
		. += Mobs

		var/static/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/mecha, /obj/spacepod))

		for(var/HM in typecache_filter_list(range(vision_range, targets_from), hostile_machines))
			if(can_see(targets_from, HM, vision_range))
				. += HM
	else
		var/list/Objects = oview(vision_range, targets_from)
		. += Objects

/mob/living/simple_animal/hostile/proc/FindTarget(var/list/possible_targets, var/HasTargetsList = 0)//Step 2, filter down possible targets to things we actually care about
	. = list()
	if(!HasTargetsList)
		possible_targets = ListTargets()
	for(var/pos_targ in possible_targets)
		var/atom/A = pos_targ
		if(Found(A))//Just in case people want to override targetting
			. = list(A)
			break
		if(CanAttack(A))//Can we attack it?
			. += A
			continue
	var/Target = PickTarget(.)
	GiveTarget(Target)
	return Target //We now have a target

/mob/living/simple_animal/hostile/proc/PossibleThreats()
	. = list()
	for(var/pos_targ in ListTargets())
		var/atom/A = pos_targ
		if(Found(A))
			. = list(A)
			break
		if(CanAttack(A))
			. += A
			continue

/mob/living/simple_animal/hostile/proc/Found(var/atom/A)//This is here as a potential override to pick a specific target if available
	return

/mob/living/simple_animal/hostile/proc/PickTarget(list/Targets)//Step 3, pick amongst the possible, attackable targets
	if(target != null)//If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets
		for(var/pos_targ in Targets)
			var/atom/A = pos_targ
			var/target_dist = get_dist(targets_from, target)
			var/possible_target_distance = get_dist(targets_from, A)
			if(target_dist < possible_target_distance)
				Targets -= A
	if(!Targets.len)//We didnt find nothin!
		return
	var/chosen_target = pick(Targets)//Pick the remaining targets (if any) at random
	return chosen_target

/mob/living/simple_animal/hostile/CanAttack(var/atom/the_target)//Can we actually attack a possible target?
	if(!the_target)
		return 0
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return 0
	if(search_objects < 2)
		if(isliving(the_target))
			var/mob/living/L = the_target
			var/faction_check = faction_check(L)
			if(robust_searching)
				if(L.stat > stat_attack || L.stat != stat_attack && stat_exclusive == 1)
					return 0
				if(faction_check && !attack_same || !faction_check && attack_same == 2)
					return 0
				if(L in friends)
					return 0
			else
				if(L.stat)
					return 0
				if(faction_check && !attack_same)
					return 0
			return 1

		if(ishuman(the_target))
			var/mob/living/carbon/human/H = the_target
			if(is_type_in_list(src, H.species.ignored_by))
				return 0

		if(istype(the_target, /obj/mecha))
			var/obj/mecha/M = the_target
			if(M.occupant)//Just so we don't attack empty mechs
				if(CanAttack(M.occupant))
					return 1

		if(istype(the_target, /obj/spacepod))
			var/obj/spacepod/S = the_target
			if(S.pilot) //Just so we don't attack empty pods
				if(CanAttack(S.pilot))
					return 1

		if(istype(the_target, /obj/machinery/porta_turret))
			var/obj/machinery/porta_turret/P = the_target
			if(P.faction in faction)
				return 0
			if(!P.raised) //Don't attack invincible turrets
				return 0
			if(P.stat & BROKEN) //Or turrets that are already broken
				return 0
			return 1
	if(isobj(the_target))
		if(is_type_in_list(the_target, wanted_objects))
			return 1
	return 0

/mob/living/simple_animal/hostile/proc/GiveTarget(new_target)//Step 4, give us our selected target
	target = new_target
	if(target != null)
		Aggro()
		return 1

/mob/living/simple_animal/hostile/proc/MoveToTarget(var/list/possible_targets)//Step 5, handle movement between us and our target
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return 0
	if(target in possible_targets)
		if(target.z != z)
			LoseTarget()
			return 0
		var/target_distance = get_dist(targets_from,target)
		if(ranged) //We ranged? Shoot at em
			if(!target.Adjacent(targets_from) && ranged_cooldown <= world.time) //But make sure they're not in range for a melee attack and our range attack is off cooldown
				OpenFire(target)
		if(retreat_distance != null) //If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance) //If target's closer than our retreat distance, run
				walk_away(src,target,retreat_distance,move_to_delay)
			else
				Goto(target,move_to_delay,minimum_distance) //Otherwise, get to our minimum distance so we chase them
		else
			Goto(target,move_to_delay,minimum_distance)
		if(target)
			if(targets_from && isturf(targets_from.loc) && target.Adjacent(targets_from)) //If they're next to us, attack
				AttackingTarget()
			return 1
		return 0
	if(environment_smash)
		if(target.loc != null && get_dist(targets_from, target.loc) <= vision_range) //We can't see our target, but he's in our vision range still
			if(ranged_ignores_vision && ranged_cooldown <= world.time) //we can't see our target... but we can fire at them!
				OpenFire(target)
			if(environment_smash >= 2) //If we're capable of smashing through walls, forget about vision completely after finding our target
				Goto(target,move_to_delay,minimum_distance)
				FindHidden()
				return 1
			else
				if(FindHidden())
					return 1
	LoseTarget()
	return 0

/mob/living/simple_animal/hostile/proc/Goto(target, delay, minimum_distance)
	walk_to(src, target, minimum_distance, delay)

/mob/living/simple_animal/hostile/adjustHealth(damage)
	. = ..()
	if(!ckey && !stat && search_objects < 3 && damage > 0)//Not unconscious, and we don't ignore mobs
		if(search_objects)//Turn off item searching and ignore whatever item we were looking at, we're more concerned with fight or flight
			search_objects = 0
			target = null
		if(AIStatus == AI_IDLE)
			AIStatus = AI_ON
			FindTarget()
		else if(target != null && prob(40))//No more pulling a mob forever and having a second player attack it, it can switch targets now if it finds a more suitable one
			FindTarget()

/mob/living/simple_animal/hostile/proc/AttackingTarget()
	target.attack_animal(src)

/mob/living/simple_animal/hostile/proc/Aggro()
	vision_range = aggro_vision_range
	if(target && emote_taunt.len && prob(taunt_chance))
		emote("me", 1, "[pick(emote_taunt)] at [target].")
		taunt_chance = max(taunt_chance-7,2)

/mob/living/simple_animal/hostile/proc/LoseAggro()
	stop_automated_movement = 0
	vision_range = idle_vision_range
	taunt_chance = initial(taunt_chance)

/mob/living/simple_animal/hostile/proc/LoseTarget()
	target = null
	walk(src, 0)
	LoseAggro()

//////////////END HOSTILE MOB TARGETTING AND AGGRESSION////////////

/mob/living/simple_animal/hostile/death(gibbed)
	LoseTarget()
	..(gibbed)

/mob/living/simple_animal/hostile/proc/summon_backup(distance)
	do_alert_animation(src)
	playsound(loc, 'sound/machines/chime.ogg', 50, 1, -1)
	for(var/mob/living/simple_animal/hostile/M in oview(distance, targets_from))
		var/list/L = M.faction&faction
		if(L.len)
			if(M.AIStatus == AI_OFF)
				return
			else
				M.Goto(src,M.move_to_delay,M.minimum_distance)

/mob/living/simple_animal/hostile/proc/OpenFire(atom/A)
	if(check_friendly_fire)
		for(var/turf/T in getline(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check(L) && !attack_same)
					return
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")

	if(rapid)
		spawn(1)
			Shoot(A)
		spawn(4)
			Shoot(A)
		spawn(6)
			Shoot(A)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/proc/Shoot(atom/targeted_atom)
	if(targeted_atom == targets_from.loc || targeted_atom == targets_from)
		return

	var/turf/startloc = get_turf(targets_from)
	if(casingtype)
		var/obj/item/ammo_casing/casing = new casingtype(startloc)
		playsound(src, projectilesound, 100, 1)
		casing.fire(targeted_atom, src, zone_override = ran_zone())
	else if(projectiletype)
		var/obj/item/projectile/P = new projectiletype(startloc)
		playsound(src, projectilesound, 100, 1)
		P.current = startloc
		P.starting = startloc
		P.firer = src
		P.yo = targeted_atom.y - startloc.y
		P.xo = targeted_atom.x - startloc.x
		if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
			newtonian_move(get_dir(targeted_atom, targets_from))
		P.original = targeted_atom
		P.fire()
		return P

/mob/living/simple_animal/hostile/proc/DestroySurroundings()
	if(environment_smash)
		EscapeConfinement()
		for(var/dir in cardinal)
			var/turf/T = get_step(targets_from, dir)
			if(iswallturf(T) || ismineralturf(T))
				if(T.Adjacent(targets_from))
					T.attack_animal(src)
			for(var/a in T)
				var/atom/A = a
				if(!A.Adjacent(targets_from))
					continue
				if(is_type_in_typecache(A, environment_target_typecache))
					A.attack_animal(src)
	return

/mob/living/simple_animal/hostile/proc/EscapeConfinement()
	if(buckled)
		buckled.attack_animal(src)
	if(!isturf(targets_from.loc) && targets_from.loc != null)//Did someone put us in something?
		var/atom/A = get_turf(targets_from)
		A.attack_animal(src)//Bang on it till we get out
	return

/mob/living/simple_animal/hostile/proc/FindHidden()
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper) || istype(target.loc, /obj/machinery/bodyscanner) || istype(target.loc, /obj/machinery/recharge_station))
		var/atom/A = target.loc
		Goto(A,move_to_delay,minimum_distance)
		if(A.Adjacent(targets_from))
			A.attack_animal(src)
		return 1

/mob/living/simple_animal/hostile/RangedAttack(atom/A, params) //Player firing
	if(ranged && ranged_cooldown <= world.time)
		target = A
		OpenFire(A)
	..()



////// AI Status ///////
/mob/living/simple_animal/hostile/proc/AICanContinue(var/list/possible_targets)
	switch(AIStatus)
		if(AI_ON)
			. = 1
		if(AI_IDLE)
			if(FindTarget(possible_targets, 1))
				. = 1
				AIStatus = AI_ON //Wake up for more than one Life() cycle.
			else
				. = 0

/mob/living/simple_animal/hostile/proc/AIShouldSleep(var/list/possible_targets)
	return !FindTarget(possible_targets, 1)
