/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	flag = "laser"
	eyeblur = 2

/obj/item/projectile/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	hitsound = null
	damage_type = BURN
	flag = "laser"
	eyeblur = 2
	chatlog_attacks = 0

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5


/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "sniperlaser"
	damage = 60
	stun = 5
	weaken = 5
	stutter = 5

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 15
	irradiate = 30
	forcedodge = 1

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 36
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50

/obj/item/projectile/beam/pulse/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target,/turf/)||istype(target,/obj/structure/))
		target.ex_act(2)
	..()

/obj/item/projectile/beam/pulse/shot
	damage = 40

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30

/obj/item/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/item/projectile/beam/emitter/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL

/obj/item/projectile/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	chatlog_attacks = 0

/obj/item/projectile/lasertag/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)
	return 1

/obj/item/projectile/lasertag/omni
	name = "laser tag beam"
	icon_state = "omnilaser"

/obj/item/projectile/lasertag/red
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)

/obj/item/projectile/lasertag/blue
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)

/obj/item/projectile/beam/lightning
	invisibility = 101
	name = "lightning"
	damage = 0
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	stun = 10
	weaken = 10
	stutter = 50
	eyeblur = 50
	var/tang = 0
	layer = 3
	var/turf/last = null
	kill_count = 6
	var/bullet_acted = 0

	Bump(var/atom/A)
		if((A != firer) && !bullet_acted)
			A.bullet_act(src)
			bullet_acted = 1

	proc/adjustAngle(angle)
		angle = round(angle) + 45
		if(angle > 180)
			angle -= 180
		else
			angle += 180
		if(!angle)
			angle = 1
		/*if(angle < 0)
			//angle = (round(abs(get_angle(A, user))) + 45) - 90
			angle = round(angle) + 45 + 180
		else
			angle = round(angle) + 45*/
		return angle

	process()
		var/first = 1 //So we don't make the overlay in the same tile as the firer
		var/broke = 0
		var/broken
		var/atom/curr = current
		var/Angle=round(Get_Angle(firer,curr))
		var/icon/I=new('icons/obj/zap.dmi',"lightning")
		I.Turn(Angle)
		var/DX=(32*curr.x+curr.pixel_x)-(32*firer.x+firer.pixel_x)
		var/DY=(32*curr.y+curr.pixel_y)-(32*firer.y+firer.pixel_y)
		var/N=0
		var/length=round(sqrt((DX)**2+(DY)**2))
		var/count = 0
		for(N,N<length,N+=32)
			if(count >= kill_count)
				break
			count++
			var/obj/effect/overlay/beam/X=new(loc)
			X.BeamSource=src
			if(N+32>length)
				var/icon/II=new(icon,icon_state)
				II.DrawBox(null,1,(length-N),32,32)
				II.Turn(Angle)
				X.icon=II
			else X.icon=I
			var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
			var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
			if(DX==0) Pixel_x=0
			if(DY==0) Pixel_y=0
			if(Pixel_x>32)
				for(var/a=0, a<=Pixel_x,a+=32)
					X.x++
					Pixel_x-=32
			if(Pixel_x<-32)
				for(var/a=0, a>=Pixel_x,a-=32)
					X.x--
					Pixel_x+=32
			if(Pixel_y>32)
				for(var/a=0, a<=Pixel_y,a+=32)
					X.y++
					Pixel_y-=32
			if(Pixel_y<-32)
				for(var/a=0, a>=Pixel_y,a-=32)
					X.y--
					Pixel_y+=32
			X.pixel_x=Pixel_x
			X.pixel_y=Pixel_y
			var/turf/TT = get_turf(X.loc)
			if(TT == firer.loc)
				continue
			if(TT.density)
				qdel(X)
				break
			for(var/atom/O in TT)
				if(istype(O,/mob/living))
					if(O.density)
						qdel(X)
						broke = 1
						break
				if(!O.CanPass(src))
					qdel(X)
					broke = 1
					break
			if(broke)
				if(X)
					qdel(X)
				break
		spawn
			while(src) //Move until we hit something
				if(first)
					icon = midicon
				if((!( current ) || loc == current)) //If we pass our target
					broken = 1
					icon = endicon
					tang = adjustAngle(get_angle(original,current))
					if(tang > 180)
						tang -= 180
					else
						tang += 180
					icon_state = "[tang]"
					var/turf/simulated/floor/f = current
					if(f && istype(f))
						if(!bullet_acted)
							f.break_tile()
							f.hotspot_expose(1000,CELL_VOLUME)
				if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
					//world << "deleting"
					//del(src) //Delete if it passes the world edge
					broken = 1
					return
				if(kill_count < 1)
					//world << "deleting"
					//del(src)
					broken = 1
				kill_count--
				//world << "[x] [y]"
				if(!bumped && !isturf(original))
					if(loc == get_turf(original))
						if(!(original in permutated))
							icon = endicon
						if(!broken)
							tang = adjustAngle(get_angle(original,current))
							if(tang > 180)
								tang -= 180
							else
								tang += 180
							icon_state = "[tang]"
						Bump(original)
				first = 0
				if(broken)
					//world << "breaking"
					break
				else
					last = get_turf(src.loc)
					step_towards(src, current) //Move~
					if(src.loc != current)
						tang = adjustAngle(get_angle(src.loc,current))
					icon_state = "[tang]"
			qdel(src)
		return
	/*cleanup(reference) //Waits .3 seconds then removes the overlay.
		//world << "setting invisibility"
		sleep(50)
		src.invisibility = 101
		return*/
	on_hit(atom/target, blocked = 0)
		if(istype(target, /mob/living))
			var/mob/living/M = target
			M.playsound_local(src, "explosion", 50, 1)
		..()

/*
/*
 * Use: Caches beam state images and holds turfs that had these images overlaid.
 * Structure:
 * beam_master
 *     icon_states/dirs of beams
 *         image for that beam
 *     references for fired beams
 *         icon_states/dirs for each placed beam image
 *             turfs that have that icon_state/dir
 */
var/list/beam_master = list()

// Special laser the captains gun uses
/obj/item/projectile/beam/captain
	name = "captain laser"
	damage = 40

/obj/item/projectile/beam/lightning
	invisibility = 101
	name = "lightning"
	damage = 0
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	stun = 10
	weaken = 10
	stutter = 50
	eyeblur = 50
	var/tang = 0
	layer = 3
	var/turf/last = null
	kill_count = 6

	proc/adjustAngle(angle)
		angle = round(angle) + 45
		if(angle > 180)
			angle -= 180
		else
			angle += 180
		if(!angle)
			angle = 1
		/*if(angle < 0)
			//angle = (round(abs(get_angle(A, user))) + 45) - 90
			angle = round(angle) + 45 + 180
		else
			angle = round(angle) + 45*/
		return angle

	process()
		var/first = 1 //So we don't make the overlay in the same tile as the firer
		var/broke = 0
		var/broken
		var/atom/curr = current
		var/Angle=round(Get_Angle(firer,curr))
		var/icon/I=new('icons/obj/zap.dmi',"lightning")
		I.Turn(Angle)
		var/DX=(32*curr.x+curr.pixel_x)-(32*firer.x+firer.pixel_x)
		var/DY=(32*curr.y+curr.pixel_y)-(32*firer.y+firer.pixel_y)
		var/N=0
		var/length=round(sqrt((DX)**2+(DY)**2))
		var/count = 0
		for(N,N<length,N+=32)
			if(count >= kill_count)
				break
			count++
			var/obj/effect/overlay/beam/X=new(loc)
			X.BeamSource=src
			if(N+32>length)
				var/icon/II=new(icon,icon_state)
				II.DrawBox(null,1,(length-N),32,32)
				II.Turn(Angle)
				X.icon=II
			else X.icon=I
			var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
			var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
			if(DX==0) Pixel_x=0
			if(DY==0) Pixel_y=0
			if(Pixel_x>32)
				for(var/a=0, a<=Pixel_x,a+=32)
					X.x++
					Pixel_x-=32
			if(Pixel_x<-32)
				for(var/a=0, a>=Pixel_x,a-=32)
					X.x--
					Pixel_x+=32
			if(Pixel_y>32)
				for(var/a=0, a<=Pixel_y,a+=32)
					X.y++
					Pixel_y-=32
			if(Pixel_y<-32)
				for(var/a=0, a>=Pixel_y,a-=32)
					X.y--
					Pixel_y+=32
			X.pixel_x=Pixel_x
			X.pixel_y=Pixel_y
			var/turf/TT = get_turf(X.loc)
			if(TT == firer.loc)
				continue
			if(TT.density)
				del(X)
				break
			for(var/atom/O in TT)
				if(!O.CanPass(src))
					del(X)
					broke = 1
					break
			for(var/mob/living/O in TT.contents)
				if(istype(O, /mob/living))
					if(O.density)
						del(X)
						broke = 1
						break
			if(broke)
				if(X)
					del(X)
				break
		spawn
			while(src) //Move until we hit something
				if(first)
					icon = midicon
				if((!( current ) || loc == current)) //If we pass our target
					broken = 1
					icon = endicon
					tang = adjustAngle(get_angle(original,current))
					if(tang > 180)
						tang -= 180
					else
						tang += 180
					icon_state = "[tang]"
					var/turf/simulated/floor/f = current
					if(f && istype(f))
						f.break_tile()
						f.hotspot_expose(1000,CELL_VOLUME)
				if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
					//world << "deleting"
					//del(src) //Delete if it passes the world edge
					broken = 1
					return
				if(kill_count < 1)
					//world << "deleting"
					//del(src)
					broken = 1
				kill_count--
				//world << "[x] [y]"
				if(!bumped && !isturf(original))
					if(loc == get_turf(original))
						if(!(original in permutated))
							icon = endicon
						if(!broken)
							tang = adjustAngle(get_angle(original,current))
							if(tang > 180)
								tang -= 180
							else
								tang += 180
							icon_state = "[tang]"
						Bump(original)
				first = 0
				if(broken)
					//world << "breaking"
					break
				else
					last = get_turf(src.loc)
					step_towards(src, current) //Move~
					if(src.loc != current)
						tang = adjustAngle(get_angle(src.loc,current))
					icon_state = "[tang]"
			del(src)
		return
	/*cleanup(reference) //Waits .3 seconds then removes the overlay.
		//world << "setting invisibility"
		sleep(50)
		src.invisibility = 101
		return*/
	on_hit(atom/target, blocked = 0)
		if(istype(target, /mob/living))
			var/mob/living/M = target
			M.playsound_local(src, "explosion", 50, 1)
		..()

/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	flag = "laser"
	eyeblur = 4
	var/frequency = 1

	process()
		var/reference = "\ref[src]" //So we do not have to recalculate it a ton
		var/first = 1 //So we don't make the overlay in the same tile as the firer
		spawn while(src) //Move until we hit something

			if((!( current ) || loc == current)) //If we pass our target
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				del(src) //Delete if it passes the world edge
				return
			step_towards(src, current) //Move~

			if(kill_count < 1)
				del(src)
				return
			kill_count--

			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						Bump(original)

			if(!first) //Add the overlay as we pass over tiles
				var/target_dir = get_dir(src, current) //So we don't call this too much

				//If the icon has not been added yet
				if( !("[icon_state][target_dir]" in beam_master) )
					var/image/I = image(icon,icon_state,10,target_dir) //Generate it.
					beam_master["[icon_state][target_dir]"] = I //And cache it!

				//Finally add the overlay
				src.loc.overlays += beam_master["[icon_state][target_dir]"]

				//Add the turf to a list in the beam master so they can be cleaned up easily.
				if(reference in beam_master)
					var/list/turf_master = beam_master[reference]
					if("[icon_state][target_dir]" in turf_master)
						var/list/turfs = turf_master["[icon_state][target_dir]"]
						turfs += loc
					else
						turf_master["[icon_state][target_dir]"] = list(loc)
				else
					var/list/turfs = list()
					turfs["[icon_state][target_dir]"] = list(loc)
					beam_master[reference] = turfs
			else
				first = 0
		cleanup(reference)
		return
	dumbfire(var/dir)
		var/reference = "\ref[src]" //So we do not have to recalculate it a ton
		var/first = 1 //So we don't make the overlay in the same tile as the firer
		if(!dir)
			del(src)
		spawn while(src) //Move until we hit something
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				del(src) //Delete if it passes the world edge
				return
			var/turf/T = get_step(src, dir)
			step_towards(src, T) //Move~

			if(kill_count < 1)
				del(src)
			kill_count--

			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						Bump(original)

			if(!first) //Add the overlay as we pass over tiles
				var/target_dir = dir //So we don't call this too much

				//If the icon has not been added yet
				if( !("[icon_state][target_dir]" in beam_master) )
					var/image/I = image(icon,icon_state,10,target_dir) //Generate it.
					beam_master["[icon_state][target_dir]"] = I //And cache it!

				//Finally add the overlay
				src.loc.overlays += beam_master["[icon_state][target_dir]"]

				//Add the turf to a list in the beam master so they can be cleaned up easily.
				if(reference in beam_master)
					var/list/turf_master = beam_master[reference]
					if("[icon_state][target_dir]" in turf_master)
						var/list/turfs = turf_master["[icon_state][target_dir]"]
						turfs += loc
					else
						turf_master["[icon_state][target_dir]"] = list(loc)
				else
					var/list/turfs = list()
					turfs["[icon_state][target_dir]"] = list(loc)
					beam_master[reference] = turfs
			else
				first = 0
		cleanup(reference)
		return

	proc/cleanup(reference) //Waits .3 seconds then removes the overlay.
		src = null // Redundant.
		spawn(3)
			var/list/turf_master = beam_master[reference]
			for(var/laser_state in turf_master)
				var/list/turfs = turf_master[laser_state]
				for(var/turf/T in turfs)
					T.overlays -= beam_master[laser_state]
		return

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

//Heavy lasers now deal slightly more damage, but have a slower firing rate; overall DPS still identical to lasers.
/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 50

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 15
	irradiate = 30
	kill_count = 50


/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target,/turf/)||istype(target,/obj/structure/))
			target.ex_act(2)
		..()


/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30


/obj/item/projectile/beam/lastertag/blue
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/red
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/omni//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
				M.Weaken(5)
		return 1


/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	nodamage = 1
	damage = 0
	agony = 40
	damage_type = HALLOSS
*/