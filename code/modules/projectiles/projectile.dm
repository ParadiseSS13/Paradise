/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 0
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	flags = ABSTRACT
	pass_flags = PASSTABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""
	pressure_resistance = INFINITY
	burn_state = LAVA_PROOF
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/obj/item/ammo_casing/ammo_casing = null
	var/suppressed = 0	//Attack message
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
	var/Angle = 0
	var/spread = 0			//amount (in degrees) of projectile spread
	var/legacy = FALSE			//legacy projectile system
	animate_movement = 0
	
	var/ignore_source_check = FALSE
	
	var/damage = 10
	var/tile_dropoff = 0	//how much damage should be decremented as the bullet moves
	var/tile_dropoff_s = 0	//same as above but for stamina
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = FALSE //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = "/obj/item/projectile"
	var/range = 50 //This will de-increment every step. When 0, it will delete the projectile.
	var/is_reflectable = FALSE // Can it be reflected or not?
	var/alwayslog = FALSE // ALWAYS log this projectile on hit even if it doesn't hit a living target. Useful for AOE explosion / EMP.
	//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	var/forcedodge = 0 //to pass through everything
	var/dismemberment = 0 //The higher the number, the greater the bonus to dismembering. 0 will not dismember at all.
	var/ricochets = 0
	var/ricochets_max = 2
	var/ricochet_chance = 0

	var/log_override = FALSE //whether print to admin attack logs or just keep it in the diary

/obj/item/projectile/New()
	permutated = list()
	return ..()

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

/obj/item/projectile/proc/on_hit(atom/target, blocked = 0, hit_zone)
	var/turf/target_loca = get_turf(target)
	if(alwayslog)
		add_attack_logs(firer, target, "Shot with a [type]")
	if(!isliving(target))
		return 0
	var/mob/living/L = target
	var/mob/living/carbon/human/H
	if(blocked < 100) // not completely blocked
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
						M.bloody_hands(H)
						/* Uncomment when bloody_body stops randomly not transferring blood colour.
						M.bloody_body(H) */

		var/organ_hit_text = ""
		if(L.has_limbs)
			organ_hit_text = " in \the [parse_zone(def_zone)]"
		if(suppressed)
			playsound(loc, hitsound, 5, 1, -1)
			to_chat(L, "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>")
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, 1, -1)
			L.visible_message("<span class='danger'>[L] is hit by \a [src][organ_hit_text]!</span>", \
								"<span class='userdanger'>[L] is hit by \a [src][organ_hit_text]!</span>")	//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter

	var/reagent_note
	var/has_reagents = FALSE
	if(reagents && reagents.reagent_list)
		reagent_note = " REAGENTS:"
		for(var/datum/reagent/R in reagents.reagent_list)
			reagent_note += R.id + " ("
			reagent_note += num2text(R.volume) + ") "
			has_reagents = TRUE
	if(!log_override && firer && !alwayslog)
		if(has_reagents)
			add_attack_logs(firer, L, "Shot with a [type] (containing [reagent_note])")
		else
			add_attack_logs(firer, L, "Shot with a [type]")
	return L.apply_effects(stun, weaken, paralyze, irradiate, slur, stutter, eyeblur, drowsy, blocked, stamina, jitter)

/obj/item/projectile/proc/get_splatter_blockage(var/turf/step_over, var/atom/target, var/splatter_dir, var/target_loca) //Check whether the place we want to splatter blood is blocked (i.e. by windows).
	var/turf/step_cardinal = !(splatter_dir in list(NORTH, SOUTH, EAST, WEST)) ? get_step(target_loca, get_cardinal_dir(target_loca, step_over)) : null

	if(step_over.density && !step_over.CanPass(target, step_over, 1)) //Preliminary simple check.
		return TRUE
	for(var/atom/movable/border_obstacle in step_over) //Check to see if we're blocked by a (non-full) window or some such. Do deeper investigation if we're splattering blood diagonally.
		if(border_obstacle.flags&ON_BORDER && get_dir(step_cardinal ? step_cardinal : target_loca, step_over) ==  turn(border_obstacle.dir, 180))
			return TRUE

/obj/item/projectile/proc/vol_by_damage()
	if(damage)
		return Clamp((damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/item/projectile/Bump(atom/A, yes)
	if(!yes) //prevents double bumps.
		return
		
	if(check_ricochet(A) && check_ricochet_flag(A) && ricochets < ricochets_max)
		ricochets++
	if(A.handle_ricochet(src))
		on_ricochet(A)
		ignore_source_check = TRUE
		range = initial(range)
		return TRUE
	if(firer)
		if(A == firer || (A == firer.loc && istype(A, /obj/mecha))) //cannot shoot yourself or your mech
			loc = A.loc
			return 0

	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.

	if(isturf(A) && hitsound_wall)
		var/volume = Clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)
	else if(ishuman(A))
		var/mob/living/carbon/human/H = A
		var/obj/item/organ/external/organ = H.get_organ(check_zone(def_zone))
		if(isnull(organ))
			return

	var/turf/target_turf = get_turf(A)

	var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		loc = target_turf
		if(A)
			permutated.Add(A)
		return 0
	else
		if(A && A.density && !ismob(A) && !(A.flags & ON_BORDER)) //if we hit a dense non-border obj or dense turf then we also hit one of the mobs on that tile.
			var/list/mobs_list = list()
			for(var/mob/living/L in target_turf)
				mobs_list += L
			if(mobs_list.len)
				var/mob/living/picked_mob = pick(mobs_list)
				picked_mob.bullet_act(src, def_zone)
	qdel(src)

/obj/item/projectile/Process_Spacemove(var/movement_dir = 0)
	return 1 //Bullets don't drift in space

/obj/item/projectile/proc/fire(var/setAngle)
	if(setAngle)
		Angle = setAngle
	if(!legacy) //new projectiles
		set waitfor = 0
		while(loc)
			if(!paused)
				if((!( current ) || loc == current))
					current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)

				if(!Angle)
					Angle=round(Get_Angle(src,current))
				if(spread)
					Angle += (rand() - 0.5) * spread
				var/matrix/M = new
				M.Turn(Angle)
				transform = M

				var/Pixel_x=round(sin(Angle)+16*sin(Angle)*2)
				var/Pixel_y=round(cos(Angle)+16*cos(Angle)*2)
				var/pixel_x_offset = pixel_x + Pixel_x
				var/pixel_y_offset = pixel_y + Pixel_y
				var/new_x = x
				var/new_y = y

				while(pixel_x_offset > 16)
					pixel_x_offset -= 32
					pixel_x -= 32
					new_x++// x++
				while(pixel_x_offset < -16)
					pixel_x_offset += 32
					pixel_x += 32
					new_x--

				while(pixel_y_offset > 16)
					pixel_y_offset -= 32
					pixel_y -= 32
					new_y++
				while(pixel_y_offset < -16)
					pixel_y_offset += 32
					pixel_y += 32
					new_y--

				speed = round(speed)
				step_towards(src, locate(new_x, new_y, z))
				if(speed <= 1)
					pixel_x = pixel_x_offset
					pixel_y = pixel_y_offset
				else
					animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (speed <= 3 ? speed - 1 : speed)))

				if(original && (original.layer>=2.75) || ismob(original))
					if(loc == get_turf(original))
						if(!(original in permutated))
							Bump(original, 1)
				Range()
			sleep(max(1, speed))
	else //old projectile system
		set waitfor = 0
		while(loc)
			if(!paused)
				if((!( current ) || loc == current))
					current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)
				step_towards(src, current)
				if(original && (original.layer>=2.75) || ismob(original))
					if(loc == get_turf(original))
						if(!(original in permutated))
							Bump(original, 1)
				Range()
			sleep(1)

obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	..()
	if(isliving(AM) && AM.density && !checkpass(PASSMOB))
		Bump(AM, 1)

/obj/item/projectile/Destroy()
	ammo_casing = null
	return ..()

/obj/item/projectile/proc/dumbfire(var/dir)
	current = get_ranged_target_turf(src, dir, world.maxx) //world.maxx is the range. Not sure how to handle this better.
	fire()
	

/obj/item/projectile/proc/on_ricochet(atom/A)
	return

/obj/item/projectile/proc/check_ricochet()
	if(prob(ricochet_chance))
		return TRUE
	return FALSE

/obj/item/projectile/proc/check_ricochet_flag(atom/A)
	if(A.flags_2 & CHECK_RICOCHET_1)
		return TRUE
	return FALSE
	
/obj/item/projectile/proc/setAngle(new_angle)	//wrapper for overrides.
	Angle = new_angle
	return TRUE
