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
					//qdel(src) //Delete if it passes the world edge
					broken = 1
					return
				if(kill_count < 1)
					//world << "deleting"
					//qdel(src)
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