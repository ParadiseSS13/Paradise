/// Is this a hitscan projectile or not, if so move like one
#define MOVES_HITSCAN -1
/// How many pixels to move the muzzle flash up so your character doesn't look like they're shitting out lasers.
#define MUZZLE_EFFECT_PIXEL_INCREMENT 17

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	flags = ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/atom/firer_source_atom = null //the gun or object this came from
	var/obj/item/ammo_casing/ammo_casing = null
	var/suppressed = FALSE	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/paused = FALSE //for suspending the projectile midair
	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center
	var/speed = 1			//Amount of deciseconds it takes for projectile to travel
	var/Angle = null
	var/original_angle = null //Angle at firing
	var/spread = 0			//amount (in degrees) of projectile spread
	animate_movement = NO_STEPS

	var/ignore_source_check = FALSE

	var/damage = 10
	var/tile_dropoff = 0	//how much damage should be decremented as the bullet moves
	var/tile_dropoff_s = 0	//same as above but for stamina
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = FALSE //Determines if the projectile will skip any damage inflictions
	var/flag = BULLET //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = "/obj/item/projectile"
	var/range = 50 //This will de-increment every step. When 0, it will delete the projectile.
	/// Determines the reflectability level of a projectile, either REFLECTABILITY_NEVER, REFLECTABILITY_PHYSICAL, REFLECTABILITY_ENERGY in order of ease to reflect.
	var/reflectability = REFLECTABILITY_PHYSICAL
	var/alwayslog = FALSE // ALWAYS log this projectile on hit even if it doesn't hit a living target. Useful for AOE explosion / EMP.
	//Effects
	var/stun = 0
	var/weaken = 0
	var/knockdown = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	/// Number of times an object can pass through an object. -1 is infinite
	var/forcedodge = 0
	/// Does the projectile increase fire stacks / immolate mobs on hit? Applies fire stacks equal to the number on hit.
	var/immolate = 0
	var/dismemberment = 0 //The higher the number, the greater the bonus to dismembering. 0 will not dismember at all.
	var/impact_effect_type //what type of impact effect to show when hitting something

	var/log_override = FALSE //whether print to admin attack logs or just keep it in the diary

	/// For when you want your projectile to have a chain coming out of the gun
	var/chain = null

	/// Last world.time the projectile proper moved
	var/last_projectile_move = 0
	/// Left over ticks in movement calculation
	var/time_offset = 0
	/// The projectile's trajectory
	var/datum/point_precise/vector/trajectory
	/// Instructs forceMove to NOT reset our trajectory to the new location!
	var/trajectory_ignore_forcemove = FALSE

	/// Does this projectile do extra damage to / break shields?
	var/shield_buster = FALSE
	var/forced_accuracy = FALSE

	///Has the projectile been fired?
	var/has_been_fired = FALSE

	/// Does this projectile hit living non dense mobs?
	var/always_hit_living_nondense = FALSE

	//Hitscan
	var/hitscan = FALSE //Whether this is hitscan. If it is, speed is basically ignored.
	var/list/beam_segments //assoc list of datum/point_precise or datum/point_precise/vector, start = end. Used for hitscan effect generation.
	/// Last turf an angle was changed in for hitscan projectiles.
	var/turf/last_angle_set_hitscan_store
	var/datum/point_precise/beam_index
	var/turf/hitscan_last //last turf touched during hitscanning.
	var/tracer_type
	var/muzzle_type
	var/impact_type

	//Fancy hitscan lighting effects!
	var/hitscan_light_intensity = 1.5
	var/hitscan_light_range = 0.75
	var/hitscan_light_color_override
	var/muzzle_flash_intensity = 3
	var/muzzle_flash_range = 1.5
	var/muzzle_flash_color_override
	var/impact_light_intensity = 3
	var/impact_light_range = 2
	var/impact_light_color_override
	var/hitscan_duration = 0.3 SECONDS

	/// how many times we've ricochet'd so far (instance variable, not a stat)
	var/ricochets = 0
	/// how many times we can ricochet max
	var/ricochets_max = 0
	/// how many times we have to ricochet min (unless we hit an atom we can ricochet off)
	var/min_ricochets = 0
	/// 0-100 (or more, I guess), the base chance of ricocheting, before being modified by the atom we shoot and our chance decay
	var/ricochet_chance = 0
	/// 0-1 (or more, I guess) multiplier, the ricochet_chance is modified by multiplying this after each ricochet
	var/ricochet_decay_chance = 0.7
	/// 0-1 (or more, I guess) multiplier, the projectile's damage is modified by multiplying this after each ricochet
	var/ricochet_decay_damage = 0.7
	/// On ricochet, if nonzero, we consider all mobs within this range of our projectile at the time of ricochet to home in on like Revolver Ocelot, as governed by ricochet_auto_aim_angle
	var/ricochet_auto_aim_range = 0
	/// On ricochet, if ricochet_auto_aim_range is nonzero, we'll consider any mobs within this range of the normal angle of incidence to home in on, higher = more auto aim
	var/ricochet_auto_aim_angle = 30
	/// the angle of impact must be within this many degrees of the struck surface, set to 0 to allow any angle
	var/ricochet_incidence_leeway = 40
	/// Can our ricochet autoaim hit our firer?
	var/ricochet_shoots_firer = TRUE

	/// determines what type of antimagic can block the spell projectile
	var/antimagic_flags
	/// determines the drain cost on the antimagic item
	var/antimagic_charge_cost

/obj/item/projectile/New()
	return ..()

/obj/item/projectile/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/projectile/proc/Range()
	range--
	if(damage && tile_dropoff)
		damage = max(0, damage - tile_dropoff) // decrement projectile damage based on dropoff value for each tile it moves
	if(stamina && tile_dropoff_s)
		stamina = max(0, stamina - tile_dropoff_s) // as above, but with stamina
	if(range <= 0 && loc)
		on_range()
	if(!damage && !stamina && (tile_dropoff || tile_dropoff_s))
		on_range()

/obj/item/projectile/proc/on_range() //if we want there to be effects when they reach the end of their range
	qdel(src)

/obj/item/projectile/proc/prehit(atom/target)
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.can_block_magic(antimagic_flags, antimagic_charge_cost))
			visible_message("<span class='warning'>[src] fizzles on contact with [victim]!</span>")
			damage = 0
			nodamage = 1
			return FALSE
	return TRUE

/obj/item/projectile/proc/on_hit(atom/target, blocked = 0, hit_zone)
	var/turf/target_loca = get_turf(target)
	var/hitx
	var/hity
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.can_block_magic(antimagic_flags, antimagic_charge_cost)) // Yes we have to check this twice welcome to bullet hell code
			return FALSE
	if(target == original)
		hitx = target.pixel_x + p_x - 16
		hity = target.pixel_y + p_y - 16
	else
		hitx = target.pixel_x + rand(-8, 8)
		hity = target.pixel_y + rand(-8, 8)
	if(!nodamage && (damage_type == BRUTE || damage_type == BURN) && iswallturf(target_loca) && prob(75))
		var/turf/simulated/wall/W = target_loca
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)

		W.add_dent(PROJECTILE_IMPACT_WALL_DENT_SHOT, hitx, hity)
		return 0
	if(alwayslog)
		add_attack_logs(firer, target, "Shot with a [type]")
	if(!isliving(target))
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)
		return 0
	var/mob/living/L = target
	var/mob/living/carbon/human/H
	if(blocked != INFINITY) // not completely blocked
		if(damage && L.blood_volume && damage_type == BRUTE)
			var/splatter_dir = dir
			if(starting)
				splatter_dir = get_dir(starting, target_loca)
			if(isalien(L))
				new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target_loca, splatter_dir)
			else
				var/blood_color = "#C80000"
				if(ishuman(target))
					H = target
					blood_color = H.dna.species.blood_color
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(target_loca, splatter_dir, blood_color)
			if(prob(33))
				var/list/shift = list("x" = 0, "y" = 0)
				var/turf/step_over = get_step(target_loca, splatter_dir)

				if(get_splatter_blockage(step_over, target, splatter_dir, target_loca)) //If you can't cross the tile or any of its relevant obstacles...
					shift = pixel_shift_dir(splatter_dir) //Pixel shift the blood there instead (so you can't see wallsplatter through walls).
				else
					target_loca = step_over
				L.add_splatter_floor(target_loca, shift_x = shift["x"], shift_y = shift["y"])
				if(istype(H))
					for(var/mob/living/carbon/human/M in step_over) //Bloody the mobs who're infront of the spray.
						M.make_bloody_hands(H.get_blood_dna_list(), H.get_blood_color())
						/* Uncomment when bloody_body stops randomly not transferring blood colour.
						M.bloody_body(H) */
		else if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)
		var/organ_hit_text = ""
		if(L.has_limbs)
			organ_hit_text = " in \the [parse_zone(def_zone)]"
		if(suppressed)
			playsound(loc, hitsound, 5, TRUE, -1)
			to_chat(L, "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>")
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, TRUE, -1)
			L.visible_message("<span class='danger'>[L] is hit by \a [src][organ_hit_text]!</span>", \
								"<span class='userdanger'>[L] is hit by \a [src][organ_hit_text]!</span>")	//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
		if(immolate)
			L.adjust_fire_stacks(immolate)
			L.IgniteMob()

	var/additional_log_text
	if(blocked)
		additional_log_text = " [ARMOUR_VALUE_TO_PERCENTAGE(blocked)]% blocked"
	if(reagents && reagents.reagent_list)
		var/reagent_note = "REAGENTS:"
		for(var/datum/reagent/R in reagents.reagent_list)
			reagent_note += R.id + " ("
			reagent_note += num2text(R.volume) + ") "
		additional_log_text = "[additional_log_text] (containing [reagent_note])"

	var/were_affects_applied = L.apply_effects(stun, weaken, knockdown, paralyze, irradiate, slur, stutter, eyeblur, drowsy, blocked, stamina, jitter)

	if(!log_override && firer && !alwayslog)
		add_attack_logs(firer, L, "Shot with a [type][additional_log_text]")

	return were_affects_applied

/obj/item/projectile/proc/get_splatter_blockage(turf/step_over, atom/target, splatter_dir, target_loca) //Check whether the place we want to splatter blood is blocked (i.e. by windows).
	var/turf/step_cardinal = !(splatter_dir in list(NORTH, SOUTH, EAST, WEST)) ? get_step(target_loca, get_cardinal_dir(target_loca, step_over)) : null

	if(step_over.density && !step_over.CanPass(target, step_over, 1)) //Preliminary simple check.
		return TRUE
	for(var/atom/movable/border_obstacle in step_over) //Check to see if we're blocked by a (non-full) window or some such. Do deeper investigation if we're splattering blood diagonally.
		if(border_obstacle.flags&ON_BORDER && get_dir(step_cardinal ? step_cardinal : target_loca, step_over) ==  turn(border_obstacle.dir, 180))
			return TRUE

/obj/item/projectile/proc/vol_by_damage()
	if(damage)
		return clamp((damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/item/projectile/proc/store_hitscan_collision(datum/point_precise/point_cache)
	beam_segments[beam_index] = point_cache
	beam_index = point_cache
	beam_segments[beam_index] = null

/obj/item/projectile/Bump(atom/A)
	if(check_ricochet(A) && check_ricochet_flag(A) && ricochets < ricochets_max && is_reflectable(REFLECTABILITY_PHYSICAL))
		if(hitscan && ricochets_max > 10)
			ricochets_max = 10 //I do not want a chucklefuck editing this higher, sorry.
		ricochets++
		if(A.handle_ricochet(src))
			on_ricochet(A)
			permutated.Cut()
			ignore_source_check = TRUE
			range = initial(range)
			return TRUE
	if(firer && !ignore_source_check)
		if(A == firer || (A == firer.loc && ismecha(A))) //cannot shoot yourself or your mech
			loc = A.loc
			return 0

	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	if(!forced_accuracy)
		if(get_dist(A, original) <= 1)
			def_zone = ran_zone(def_zone, max(100 - (7 * distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.
		else
			def_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg") // If we were aiming at one target but another one got hit, no accuracy is applied

	if(isturf(A) && hitsound_wall)
		var/volume = clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, TRUE, -1)
	else if(ishuman(A))
		var/mob/living/carbon/human/H = A
		var/obj/item/organ/external/organ = H.get_organ(check_zone(def_zone))
		if(isnull(organ))
			return

	var/turf/target_turf = get_turf(A)
	prehit(A)
	var/pre_permutation = A.atom_prehit(src)
	var/permutation = -1
	if(pre_permutation != ATOM_PREHIT_FAILURE && !(A in permutated))
		permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		if(forcedodge)
			forcedodge -= 1
		loc = target_turf
		if(A)
			permutated.Add(A)
		return 0
	else
		if(A && A.density && !ismob(A) && !(A.flags & ON_BORDER)) //if we hit a dense non-border obj or dense turf then we also hit one of the mobs on that tile.
			var/list/mobs_list = list()
			for(var/mob/living/L in target_turf)
				mobs_list += L
			if(length(mobs_list))
				var/mob/living/picked_mob = pick(mobs_list)
				prehit(picked_mob)
				picked_mob.bullet_act(src, def_zone)
	qdel(src)

/obj/item/projectile/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1 //Bullets don't drift in space

/obj/item/projectile/process()
	if(!loc || !trajectory)
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move = world.time
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = hitscan ? MOVES_HITSCAN : FLOOR(elapsed_time_deciseconds / speed, 1)
	if(required_moves == MOVES_HITSCAN)
		required_moves = SSprojectiles.global_max_tick_moves
	if(required_moves > SSprojectiles.global_max_tick_moves)
		var/overrun = required_moves - SSprojectiles.global_max_tick_moves
		required_moves = SSprojectiles.global_max_tick_moves
		time_offset += overrun * speed
	time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(1)

/obj/item/projectile/proc/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	// Keep on course
	if(!hitscanning)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	// Iterate
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			// if we've gone off of the map, we need to step back once so that hitscanning projectiles have a valid end turf
			trajectory.increment(-trajectory_multiplier)
			qdel(src)
			return
		if(T.z != loc.z)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			if(!hitscanning)
				pixel_x = trajectory.return_px()
				pixel_y = trajectory.return_py()
			forcemoved = TRUE
			hitscan_last = loc
		else if(T != loc)
			step_towards(src, T)
			hitscan_last = loc
		if(original && (ismob(original) || original.proj_ignores_layer || original.layer >= PROJECTILE_HIT_THRESHHOLD_LAYER))
			if(loc == get_turf(original) && !(original in permutated))
				Bump(original, TRUE)
	if(QDELETED(src)) //deleted on last move
		return
	if(!hitscanning && !forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()

/obj/item/projectile/proc/fire(setAngle)
	if(setAngle)
		Angle = setAngle
	if(!current || loc == current)
		current = locate(clamp(x + xo, 1, world.maxx), clamp(y + yo, 1, world.maxy), z)
	if(isnull(Angle))
		Angle = round(get_angle(src, current))
	original_angle = Angle
	if(spread)
		Angle += (rand() - 0.5) * spread
	// Turn right away
	var/matrix/M = new
	M.Turn(Angle)
	transform = M
	// Start flying
	trajectory = new(x, y, z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)
	last_projectile_move = world.time
	has_been_fired = TRUE
	if(hitscan)
		process_hitscan()
	START_PROCESSING(SSprojectiles, src)
	pixel_move(1, FALSE)

/obj/item/projectile/proc/reflect_back(atom/source, list/position_modifiers = list(0, 0, 0, 0, 0, -1, 1, -2, 2))
	if(!starting)
		return
	var/new_x = starting.x + pick(position_modifiers)
	var/new_y = starting.y + pick(position_modifiers)
	var/turf/curloc = get_turf(source)
	if(!curloc)
		return

	if(ismob(source))
		firer = source // The reflecting mob will be the new firer

	// redirect the projectile
	original = locate(new_x, new_y, z)
	starting = curloc
	current = curloc
	yo = new_y - curloc.y
	xo = new_x - curloc.x
	set_angle(get_angle(curloc, original))

/// A mob moving on a tile with a projectile is hit by it.
/obj/item/projectile/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(!isliving(entered))
		return
	var/mob/living_entered = entered
	if(((living_entered.density || !living_entered.projectile_hit_check(src))) && !checkpass(PASSMOB) && !(living_entered in permutated) && (living_entered.loc == loc))
		Bump(entered, 1)

/obj/item/projectile/Destroy()
	if(hitscan)
		finalize_hitscan_and_generate_tracers()
	STOP_PROCESSING(SSprojectiles, src)
	ammo_casing = null
	firer_source_atom = null
	firer = null
	return ..()

/obj/item/projectile/proc/dumbfire(dir)
	current = get_ranged_target_turf(src, dir, world.maxx) //world.maxx is the range. Not sure how to handle this better.
	fire()


/obj/item/projectile/proc/on_ricochet(atom/A)
	if(!ricochet_auto_aim_angle || !ricochet_auto_aim_range)
		return

	var/mob/living/unlucky_sob
	var/best_angle = ricochet_auto_aim_angle
	for(var/mob/living/L in range(ricochet_auto_aim_range, src.loc))
		if(L.stat == DEAD || !isInSight(src, L) || (!ricochet_shoots_firer && L == firer))
			continue
		var/our_angle = abs(closer_angle_difference(Angle, get_angle(src.loc, L.loc)))
		if(our_angle < best_angle)
			best_angle = our_angle
			unlucky_sob = L

	if(unlucky_sob)
		set_angle(get_angle(src, unlucky_sob.loc))

/obj/item/projectile/proc/check_ricochet()
	if(prob(ricochet_chance))
		return TRUE
	return FALSE

/obj/item/projectile/proc/check_ricochet_flag(atom/A)
	if((flag in list(ENERGY, LASER)) && (A.flags_ricochet & RICOCHET_SHINY))
		return TRUE

	if((flag in list(BOMB, BULLET)) && (A.flags_ricochet & RICOCHET_HARD))
		return TRUE

	return FALSE

/obj/item/projectile/set_angle(new_angle)
	..()

	Angle = new_angle
	if(trajectory)
		trajectory.set_angle(new_angle)
	if(has_been_fired && hitscan && isloc(loc) && (loc != last_angle_set_hitscan_store))
		last_angle_set_hitscan_store = loc
		var/datum/point/point_cache = new (src)
		point_cache = trajectory.copy_to()
		store_hitscan_collision(point_cache)
	return TRUE

/obj/item/projectile/proc/set_angle_centered(new_angle)
	set_angle(new_angle)
	var/list/coordinates = trajectory.return_coordinates()
	trajectory.set_location(coordinates[1], coordinates[2], coordinates[3]) // Sets the trajectory to the center of the tile it bounced at
	if(has_been_fired && hitscan && isloc(loc))// Handles hitscan projectiles
		last_angle_set_hitscan_store = loc
		var/datum/point_precise/point_cache = new (src)
		point_cache.initialize_location(coordinates[1], coordinates[2], coordinates[3]) // Take the center of the hitscan collision tile
		store_hitscan_collision(point_cache)
	return TRUE

/obj/item/projectile/experience_pressure_difference()
	return // Immune to gas flow.

/obj/item/projectile/forceMove(atom/target)
	. = ..()
	if(QDELETED(src)) // we coulda bumped something
		return
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		if(hitscan)
			finalize_hitscan_and_generate_tracers(FALSE)
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)
		if(hitscan)
			record_hitscan_start(RETURN_PRECISE_POINT(src))

/obj/item/projectile/proc/is_reflectable(desired_reflectability_level)
	if(reflectability == REFLECTABILITY_NEVER) //You'd trust coders not to try and override never reflectable things, but heaven help us I do not
		return FALSE
	if(reflectability < desired_reflectability_level)
		return FALSE
	return TRUE

/obj/item/projectile/proc/record_hitscan_start(datum/point_precise/point_cache)
	if(point_cache)
		beam_segments = list()
		beam_index = point_cache
		beam_segments[beam_index] = null //record start.

/obj/item/projectile/proc/process_hitscan()
	//Safety here is to make hitscan stop if something goes wrong. Why is it equal to range * 10, when range is the maximum amount of tiles it can go? No clue.
	var/safety = range * 10
	record_hitscan_start(RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1))
	while(loc && !QDELETED(src))
		if(paused)
			stoplag(1)
			continue
		if(safety-- <= 0)
			if(loc)
				Bump(loc)
			if(!QDELETED(src))
				qdel(src)
			return //Kill!
		pixel_move(1, TRUE)

/obj/item/projectile/proc/finalize_hitscan_and_generate_tracers(impacting = TRUE)
	if(trajectory && beam_index)
		var/datum/point_precise/point_cache = trajectory.copy_to()
		beam_segments[beam_index] = point_cache
	generate_hitscan_tracers(null, hitscan_duration, impacting)

/obj/item/projectile/proc/generate_hitscan_tracers(cleanup = TRUE, duration = 3, impacting = TRUE)
	if(!length(beam_segments))
		return
	if(tracer_type)
		var/tempuid = UID()
		for(var/datum/point_precise/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity, tempuid)
	if(muzzle_type && duration > 0)
		var/datum/point_precise/p = beam_segments[1]
		var/atom/movable/thing = new muzzle_type
		p.move_atom_to_src(thing)
		var/matrix/matrix = new
		matrix.Turn(original_angle)
		thing.transform = matrix
		thing.color = color
		thing.set_light(muzzle_flash_range, muzzle_flash_intensity, muzzle_flash_color_override? muzzle_flash_color_override : color)
		QDEL_IN(thing, duration)
	if(impacting && impact_type && duration > 0)
		var/datum/point_precise/p = beam_segments[beam_segments[length(beam_segments)]]
		var/atom/movable/thing = new impact_type
		p.move_atom_to_src(thing)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		thing.transform = matrix
		thing.color = color
		thing.set_light(impact_light_range, impact_light_intensity, impact_light_color_override? impact_light_color_override : color)
		QDEL_IN(thing, duration)
	if(cleanup)
		cleanup_beam_segments()

/obj/item/projectile/proc/cleanup_beam_segments()
	QDEL_LIST_ASSOC(beam_segments)

/**
 * Is this projectile considered "hostile"?
 *
 * By default all projectiles which deal damage or impart crowd control effects (including stamina) are hostile
 *
 * This is NOT used for pacifist checks, that's handled by [/obj/item/ammo_casing/var/harmful]
 * This is used in places such as AI responses to determine if they're being threatened or not (among other places)
 */
/obj/item/projectile/proc/is_hostile_projectile()
	if(damage > 0 || stamina > 0)
		return TRUE

	if(stun + weaken + paralyze + knockdown > 0 SECONDS)
		return TRUE

	return FALSE

/// Fire a projectile from this atom at another atom
/atom/proc/fire_projectile(projectile_type, atom/target, sound, firer, list/ignore_targets = list())
	if(!isnull(sound))
		playsound(src, sound, vol = 100, vary = TRUE)

	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/bullet = new projectile_type(startloc)
	bullet.starting = startloc
	bullet.firer = firer || src
	bullet.firer_source_atom = src
	bullet.yo = target.y - startloc.y
	bullet.xo = target.x - startloc.x
	bullet.original = target
	bullet.preparePixelProjectile(target, src)
	bullet.fire()
	return bullet

#undef MOVES_HITSCAN
#undef MUZZLE_EFFECT_PIXEL_INCREMENT
