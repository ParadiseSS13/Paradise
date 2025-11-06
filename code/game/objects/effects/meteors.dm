#define DEFAULT_METEOR_LIFETIME 3 MINUTES
#define MAP_EDGE_PAD 5

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust = 3, /obj/effect/meteor/medium = 8, /obj/effect/meteor/big = 3,
						/obj/effect/meteor/flaming = 1, /obj/effect/meteor/irradiated = 3)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium = 4, /obj/effect/meteor/big = 8,
						/obj/effect/meteor/flaming = 3, /obj/effect/meteor/irradiated = 3, /obj/effect/meteor/bananium = 1)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium = 3, /obj/effect/meteor/big = 10,
						/obj/effect/meteor/flaming = 10, /obj/effect/meteor/irradiated = 10, /obj/effect/meteor/bananium = 2, /obj/effect/meteor/meaty = 2, /obj/effect/meteor/meaty/xeno = 2, /obj/effect/meteor/tunguska = 1)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meteors_gore, list(/obj/effect/meteor/meaty = 5, /obj/effect/meteor/meaty/xeno = 1)) //for meaty ore event


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteortypes)
	for(var/i = 0; i < number; i++)
		spawn_meteor(meteortypes)

/proc/spawn_meteor(list/meteortypes)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10 //number of tries to spawn meteor.
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinal)
		var/startZ = level_name_to_num(MAIN_STATION)
		pickedstart = pick_edge_loc(startSide, startZ)
		pickedgoal = pick_edge_loc(REVERSE_DIR(startSide), startZ)
		max_i--
		if(max_i <= 0)
			return
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart, pickedgoal)
	M.dest = pickedgoal

/proc/pick_edge_loc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy
			startx = rand(1, world.maxx)
		if(EAST)
			starty = rand(1, world.maxy)
			startx = world.maxx
		if(SOUTH)
			starty = 1
			startx = rand(1, world.maxx)
		if(WEST)
			starty = rand(1, world.maxy)
			startx = 1
	return locate(startx, starty, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "\proper the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	max_integrity = 400 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	var/explosion_strength = EXPLODE_HEAVY // Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = FALSE
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original
	var/lifetime = DEFAULT_METEOR_LIFETIME
	var/timerid = null
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	var/dropamt = 2

/obj/effect/meteor/Move(atom/destination)
	// Nullspace is scary.
	if(isnull(loc) || isnull(destination))
		qdel(src)
		return FALSE

	// Quietly delete if we reach our goal or somehow leave the Z level.
	if(z != z_original || loc == dest || destination.z != z_original || destination == dest)
		qdel(src)
		return FALSE

	// Dead meteors hit no atoms.
	if(obj_integrity <= 0 || QDELETED(src))
		return FALSE

	if(abs(destination.y - y) == 1 && abs(destination.x - x) == 1)
		// Hit one of the turfs beside the diagonal.
		crunch(locate(destination.x, y, z))

		// Dead meteors hit no atoms.
		if(obj_integrity <= 0 || QDELETED(src))
			return FALSE

	// Hit the target tile and move to it (even if we made it change).
	forceMove(crunch(destination))

	// Dead meteors don't move, either.
	if(obj_integrity <= 0 || QDELETED(src))
		return FALSE
	return TRUE

/obj/effect/meteor/proc/crunch(turf/target)
	// Keep track of the target coordinates so we can find the turf again if it changes.
	var/target_x = target.x
	var/target_y = target.y
	var/target_z = target.z

	if(iswallturf(target))
		// Ram into the wall.
		ram_wall(target)

	if(!target)
		// We broke the turf, find it again.
		target = locate(target_x, target_y, target_z)

	if(obj_integrity <= 0 || QDELETED(src))
		return target

	ram_turf_contents(target)

	if(!target)
		// We broke the turf, find it again.
		target = locate(target_x, target_y, target_z)

	return target

/obj/effect/meteor/Destroy()
	if(timerid)
		deltimer(timerid)
	GLOB.meteor_list -= src
	GLOB.move_manager.stop_looping(src) //this cancels the GLOB.move_manager.home_onto() proc
	return ..()

/obj/effect/meteor/Initialize(mapload, target)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_EDGE_TRANSITIONS, ROUNDSTART_TRAIT)
	z_original = z
	GLOB.meteor_list += src
	SpinAnimation()
	timerid = QDEL_IN(src, lifetime)
	chase_target(target)

/obj/effect/meteor/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

/obj/effect/meteor/proc/ram_wall(turf/simulated/wall/wall)
	var/damage_cap = wall.damage_cap
	if(wall.rotting)
		damage_cap /= 10
	var/damage_needed = (damage_cap - wall.damage) * OBJ_INTEGRITY_TO_WALL_DAMAGE 
	if(damage_needed <= 0)
		wall.dismantle_wall()
	else if(damage_needed < obj_integrity)
		obj_integrity -= damage_needed
		wall.dismantle_wall()
	else
		wall.take_damage(obj_integrity / OBJ_INTEGRITY_TO_WALL_DAMAGE)
		if(wall) // In case we somehow broke it despite not thinking we could.
			wall.ex_act(explosion_strength)
		deconstruct(FALSE)

/obj/effect/meteor/proc/ram_turf_contents(turf/T)
	. = FALSE // Tracks whether we hit anything.

	for(var/atom/thing in T)
		if(thing == src || QDELETED(thing))
			continue

		if(isliving(thing))
			. = TRUE // Hit a mob.

			var/mob/living/living_thing = thing
			living_thing.visible_message("<span class='warning'>[src] slams into [living_thing].</span>", "<span class='userdanger'>[src] slams into you!</span>")
			thing.ex_act(explosion_strength)

		if(!isobj(thing))
			continue

		var/obj/obstacle = thing
		if(obstacle.obj_integrity <= 0)
			// It's already broken.
			continue

		if(!obstacle.density)
			// Doesn't block our way, but we still damage it on our way past.
			obstacle.ex_act(explosion_strength)
			continue

		. = TRUE // Hit an object.

		var/damage_needed = obstacle.calculate_oneshot_damage(BRUTE, MELEE)
		if(obj_integrity > damage_needed)
			obj_integrity -= damage_needed
			obstacle.obj_break(MELEE)
			obstacle.obj_destruction(MELEE)
		else
			obstacle.take_damage(obj_integrity, BRUTE, MELEE)
			obstacle.ex_act(explosion_strength)
			obj_integrity = 0
			deconstruct(FALSE)
			return

	// Do some damage to the floor (if any) in passing.
	T.ex_act(explosion_strength)

/obj/effect/meteor/deconstruct(disassembled)
	make_debris()
	meteor_effect()
	return ..()

/obj/effect/meteor/ex_act()
	return

/obj/effect/meteor/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/pickaxe))
		make_debris()
		qdel(src)
		return ITEM_INTERACT_COMPLETE

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		if(ispath(thing_to_spawn))
			new thing_to_spawn(get_turf(src))

/obj/effect/meteor/proc/chase_target(atom/chasing, delay = 0.5)
	set waitfor = FALSE
	if(chasing)
		GLOB.move_manager.home_onto(src, chasing, delay)

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		var/sound/meteor_sound = sound(meteorsound)
		var/random_frequency = get_rand_frequency()

		for(var/P in GLOB.player_list)
			var/mob/M = P
			var/turf/T = get_turf(M)
			if(!T || T.z != z)
				continue
			var/dist = get_dist(M.loc, loc)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(loc, null, 50, TRUE, random_frequency, 10, S = meteor_sound)

///////////////////////
//Meteor types
///////////////////////

//Fake
/obj/effect/meteor/fake
	name = "simulated meteor"
	desc = "A simulated meteor for testing shield satellites. How did you see this, anyway?"
	invisibility = INVISIBILITY_MAXIMUM
	density = FALSE
	pass_flags = NONE
	/// The station goal that is simulating this meteor.
	var/datum/station_goal/station_shield/goal
	/// Did we crash into something? Used to avoid falsely reporting success when qdeleted.
	var/failed = FALSE

/obj/effect/meteor/fake/Initialize(mapload)
	. = ..()
	for(var/datum/station_goal/station_shield/found_goal in SSticker.mode.station_goals)
		goal = found_goal
		return

/obj/effect/meteor/fake/Destroy()
	if(!failed)
		succeed()
	goal = null
	return ..()

/obj/effect/meteor/fake/ram_wall(turf/simulated/wall/wall)
	fail()
	return TRUE

/obj/effect/meteor/fake/ram_turf_contents(turf/T)
	for(var/obj/thing in T)
		if(!iseffect(thing) && !QDELETED(thing))
			fail()
			return TRUE
	return FALSE

/obj/effect/meteor/fake/proc/succeed()
	if(istype(goal))
		goal.update_coverage(TRUE, get_turf(src))

/obj/effect/meteor/fake/proc/fail()
	if(istype(goal))
		goal.update_coverage(FALSE, get_turf(src))
	failed = TRUE
	qdel(src)

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 100 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	explosion_strength = EXPLODE_LIGHT
	meteorsound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	meteordrop = list(/obj/item/stack/ore/glass)

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(loc, 0, 1, 2, 3, 0, cause = name)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	max_integrity = 600 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	heavy = TRUE
	dropamt = 4

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(loc, 1, 2, 3, 4, 0, cause = name)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	max_integrity = 500 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(loc, 1, 2, 3, 4, 0, 0, 5, cause = name)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/uranium)


/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(loc, 0, 0, 4, 3, 0, cause = name)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, 20000, 7, ALPHA_RAD)
	for(var/turf/target_turf in range(loc, 3))
		contaminate_target(target_turf, src, 2000, ALPHA_RAD)
	//Hot take on this one. This often hits walls. It really has to breach into somewhere important to matter. This at leats makes the area slightly dangerous for a bit

/obj/effect/meteor/bananium
	name = "bananium meteor"
	desc = "Well this would be just an awful way to die."
	icon_state = "clownish"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/bananium)

/obj/effect/meteor/bananium/meteor_effect()
	..()
	explosion(loc, 0, 0, 3, 2, 0, cause = name)
	var/turf/current_turf = get_turf(src)
	new /obj/item/grown/bananapeel(current_turf)
	for(var/obj/target in range(4, current_turf))
		if(prob(15))
			target.cmag_act()

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	max_integrity = 3000 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	explosion_strength = EXPLODE_DEVASTATE
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)

/obj/effect/meteor/tunguska/Move(atom/destination)
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(loc, 5, 10, 15, 20, 0, cause = "[name]: End explosion")

/obj/effect/meteor/tunguska/ram_wall()
	. = ..()
	if(prob(20))
		explosion(loc, 2, 4, 6, 8, cause = "[name]: Wall collision explosion")

/obj/effect/meteor/tunguska/ram_turf_contents()
	. = ..()
	if(. && prob(20))
		explosion(loc, 2, 4, 6, 8, cause = "[name]: Object or mob collision explosion")

//Meaty Ore
/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	max_integrity = 200 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	heavy = TRUE
	meteorsound = 'sound/effects/blobattack.ogg'
	var/bloodtype = /obj/effect/decal/cleanable/blood
	meteordrop = list(/obj/item/food/meat/human, /obj/item/organ/internal/heart, /obj/item/organ/internal/lungs, /obj/item/organ/internal/appendix)
	var/meteorgibs = /obj/effect/gibspawner/generic

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/meaty/ram_turf_contents()
	. = ..()
	var/turf/T = get_turf(src)
	if(bloodtype && !isspaceturf(T))
		new bloodtype(T)

//Meaty Ore Xeno edition
/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	bloodtype = /obj/effect/decal/cleanable/blood/xeno
	meteordrop = list(/obj/item/food/monstermeat/xenomeat)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/effect/meteor/meaty/xeno/Initialize(mapload, target)
	meteordrop += subtypesof(/obj/item/organ/internal/alien)
	return ..()

//////////////////////////
//Spookoween meteors
/////////////////////////

/obj/effect/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	max_integrity = 1000 * OBJ_INTEGRITY_TO_WALL_DAMAGE
	heavy = TRUE
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/hardhat/pumpkinhead, /obj/item/food/grown/pumpkin)

/obj/effect/meteor/pumpkin/Initialize(mapload, target)
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')

//////////////////////////
#undef DEFAULT_METEOR_LIFETIME
#undef MAP_EDGE_PAD
