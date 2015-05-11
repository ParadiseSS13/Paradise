/*
#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"
*/

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	pass_flags = PASSTABLE
	mouse_opacity = 0
	hitsound = 'sound/weapons/pierce.ogg'
	animate_movement = 0
	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/obj/shot_from = null // the object which shot us
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid
	var/projectile_type = "/obj/item/projectile"
	var/kill_count = 50 //This will de-increment every process(). When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/slur = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0
	var/stamina = 0
	var/jitter = 0
	var/embed = 0 // whether or not the projectile can embed itself in the mob
	var/forcedodge = 0

	var/range = 0
	var/proj_hit = 0

	var/chatlog_attacks = 1

	var/speed = 1 //Amount of deciseconds it takes for projectile to travel. Animation is adjusted accordingly.
	var/Angle = 0 //For new projectiles
	var/spread = 0 //Amount of degrees by which the projectiles will be spread DURING MOVEMENT. It exists for chaotic types of projectiles, like bees or something.
	var/legacy = 0 //Use the legacy projectile system or new pixel movement?

	proc/delete()
		// Garbage collect the projectiles
		loc = null

	proc/Range()
		if(range)
			range--
			if(range <= 0)
				on_range()
		else
			return

	proc/on_range() //if we want there to be effects when they reach the end of their range
		proj_hit = 1
		qdel(src)

	proc/on_hit(var/atom/target, var/blocked = 0, var/hit_zone)
		if(!isliving(target))	return 0
		if(isanimal(target))	return 0
		var/mob/living/L = target
		return L.apply_effects(stun, weaken, paralyze, irradiate, slur, stutter, eyeblur, drowsy, agony, blocked, stamina, jitter)

	proc/check_fire(var/mob/living/target as mob, var/mob/living/user as mob)  //Checks if you can hit them or not.
		if(!istype(target) || !istype(user))
			return 0
		var/obj/item/projectile/test/in_chamber = new /obj/item/projectile/test(get_step_to(user,target)) //Making the test....
		in_chamber.target = target
		in_chamber.flags = flags //Set the flags...
		in_chamber.pass_flags = pass_flags //And the pass flags to that of the real projectile...
		in_chamber.firer = user
		var/output = in_chamber.process() //Test it!
		del(in_chamber) //No need for it anymore
		return output //Send it back to the gun!

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return 0 //cannot shoot yourself

		if(bumped)
			return 1
		bumped = 1
		if(firer && istype(A, /mob))
			var/mob/M = A
			if(!istype(A, /mob/living))
				loc = A.loc
				return 0// nope.avi

			var/reagent_note
			if(reagents && reagents.reagent_list)
				reagent_note = " REAGENTS:"
				for(var/datum/reagent/R in reagents.reagent_list)
					reagent_note += R.id + " ("
					reagent_note += num2text(R.volume) + ") "
			//Lower accurancy/longer range tradeoff. Distance matters a lot here, so at
			// close distance, actually RAISE the chance to hit.
			var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
			def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.
			/*
			if(!def_zone)
				visible_message("\blue \The [src] misses [M] narrowly!")
				forcedodge = -1
			else
			*/
			if(silenced)
				playsound(loc, hitsound, 5, 1, -1)
				M << "\red You've been shot in the [parse_zone(def_zone)] by the [src.name]!"
			else
				playsound(loc, hitsound, 20, 1, -1)
				visible_message("\red [A.name] is hit by the [src.name] in the [parse_zone(def_zone)]!")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
			if(istype(firer, /mob))
				M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src.type]</b>[reagent_note]"
				firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src.type]</b>[reagent_note]"
				if(M.ckey && chatlog_attacks)
					msg_admin_attack("[firer] ([firer.ckey])[isAntag(firer) ? "(ANTAG)" : ""] shot [M] ([M.ckey]) with a [src][reagent_note] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG
				if(!iscarbon(firer))
					M.LAssailant = null
				else
					M.LAssailant = firer
			else
				M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>[reagent_note]"
				if(M.ckey  && chatlog_attacks)
					msg_admin_attack("UNKNOWN shot [M] ([M.ckey]) with a [src][reagent_note] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[firer.x];Y=[firer.y];Z=[firer.z]'>JMP</a>)") //BS12 EDIT ALG

		spawn(0)
		if(A)
			var/turf/new_loc = get_turf(A)
			var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
			if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
				spawn(1)
					bumped = 0 // reset bumped variable... after a delay. We don't want the projectile to hit AGAIN. Fixes deflecting projectiles.
				loc = new_loc
				permutated.Add(A)
				return 0
			if(istype(A,/turf))
				for(var/obj/O in A)
					O.bullet_act(src)
				for(var/mob/M in A)
					M.bullet_act(src, def_zone)
			if(!istype(src, /obj/item/projectile/beam/lightning))
				density = 0
				invisibility = 101
			del(src)
		return 1


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			return prob(95)
		else
			return 1


	process(var/setAngle)
		if(setAngle) Angle = setAngle
		if(!legacy)
			spawn() //New projectile system
				while(loc)
					if(kill_count < 1)
						qdel(src)
						return
					kill_count--
					if((!( current ) || loc == current))
						current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)

					if(!Angle)
						Angle=round(Get_Angle(src,current))
					//world << "[Angle] angle"
					//overlays.Cut()
					//var/icon/I=new(initial(icon),icon_state) //using initial(icon) makes sure that the angle for that is reset as well
					//I.Turn(Angle)
					//I.DrawBox(rgb(255,0,0,50),1,1,32,32)
					//icon = I
					if(spread) //Chaotic spread
						Angle += (rand() - 0.5) * spread
					var/matrix/M = new//matrix(transform)
					M.Turn(Angle)
					transform = M

					var/Pixel_x=round(sin(Angle)+16*sin(Angle)*2)
					var/Pixel_y=round(cos(Angle)+16*cos(Angle)*2)
					var/pixel_x_offset = pixel_x + Pixel_x
					var/pixel_y_offset = pixel_y + Pixel_y
					var/new_x = x
					var/new_y = y
					//Not sure if using whiles for this is good
					while(pixel_x_offset > 16)
						//world << "Pre-adjust coords (x++): xy [pixel_x] xy offset [pixel_x_offset]"
						pixel_x_offset -= 32
						pixel_x -= 32
						new_x++// x++
					while(pixel_x_offset < -16)
						//world << "Pre-adjust coords (x--): xy [pixel_x] xy offset [pixel_x_offset]"
						pixel_x_offset += 32
						pixel_x += 32
						new_x--

					while(pixel_y_offset > 16)
						//world << "Pre-adjust coords (y++): py [pixel_y] py offset [pixel_y_offset]"
						pixel_y_offset -= 32
						pixel_y -= 32
						new_y++
					while(pixel_y_offset < -16)
						//world << "Pre-adjust coords (y--): py [pixel_y] py offset [pixel_y_offset]"
						pixel_y_offset += 32
						pixel_y += 32
						new_y--

					speed = round(speed) //Just in case.
					step_towards(src, locate(new_x, new_y, z)) //Original projectiles stepped towards 'current'
					if(speed <= 1) //We should really only animate at speed 2
						pixel_x = pixel_x_offset
						pixel_y = pixel_y_offset
					else
						animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (speed <= 3 ? speed - 1 : speed)))

/*
					var/turf/T = get_turf(src)
					if(T)
						T.color = "#6666FF"
						spawn(10)
							T.color = initial(T.color)
*/

					if(!bumped && ((original && original.layer>=2.75) || ismob(original)))
						if(loc == get_turf(original))
							if(!(original in permutated))
								Bump(original)
					Range()
					sleep(max(1, speed))
		else
			spawn() //Old projectile system
				while(loc)
					if(kill_count < 1)
						qdel(src)
						return
					kill_count--
					if((!( current ) || loc == current))
						current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)
					if(!Angle)
						Angle=round(Get_Angle(src,current))
					var/matrix/M = new//matrix(transform)
					M.Turn(Angle)
					transform = M //So there's no need to give icons directions again
					step_towards(src, current)
					if(!bumped && ((original && original.layer>=2.75) || ismob(original)))
						if(loc == get_turf(original))
							if(!(original in permutated))
								Bump(original)
					Range()
					sleep(1)

	proc/dumbfire(var/dir)
		current = get_ranged_target_turf(src, dir, world.maxx) //world.maxx is the range. Not sure how to handle this better.
		process()

/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101 //Nope!  Can't see me!
	yo = null
	xo = null
	var/target = null
	var/result = 0 //To pass the message back to the gun.

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return //cannot shoot yourself
		if(istype(A, /obj/item/projectile))
			return
		if(istype(A, /mob/living))
			result = 2 //We hit someone, return 1!
			return
		result = 1
		return

	process()
		var/turf/curloc = get_turf(src)
		var/turf/targloc = get_turf(target)
		if(!curloc || !targloc)
			return 0
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		target = targloc
		while(src) //Loop on through!
			if(result)
				return (result - 1)
			if((!( target ) || loc == target))
				target = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge
			step_towards(src, target)
			var/mob/living/M = locate() in get_turf(src)
			if(istype(M)) //If there is someting living...
				return 1 //Return 1
			else
				M = locate() in get_step(src,target)
				if(istype(M))
					return 1