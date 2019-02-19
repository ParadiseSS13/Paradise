/sound/turntable/test
	file = 'sound/turntable/testloop1.ogg'
	falloff = 2
	repeat = 1

/mob/var/music = 0

/obj/machinery/party/turntable
	name = "turntable"
	desc = "A turntable used for parties and shit."
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "turntable"
	var/playing = 0
	anchored = 1

/obj/machinery/party/mixer
	name = "mixer"
	desc = "A mixing board for mixing music"
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "mixer"
	anchored = 1


/obj/machinery/party/turntable/New()
	..()
	sleep(2)
	new /sound/turntable/test(src)
	return

/obj/machinery/party/turntable/attack_hand(mob/user as mob)

	var/t = "<B>Turntable Interface</B><br><br>"
	//t += "<A href='?src=[UID()];on=1'>On</A><br>"
	t += "<A href='?src=[UID()];off=1'>Off</A><br><br>"
	t += "<A href='?src=[UID()];on1=Testloop1'>One</A><br>"
	t += "<A href='?src=[UID()];on2=Testloop2'>TestLoop2</A><br>"
	t += "<A href='?src=[UID()];on3=Testloop3'>TestLoop3</A><br>"

	user << browse(t, "window=turntable;size=420x700")


/obj/machinery/party/turntable/Topic(href, href_list)
	..()
	if( href_list["on1"] )
		if(src.playing == 0)
//			to_chat(world, "Should be working...")
			var/sound/S = sound('sound/turntable/testloop1.ogg')
			S.repeat = 1
			S.channel = 10
			S.falloff = 2
			S.wait = 1
			S.environment = 0
			//for(var/mob/M in world)
			//	if(M.loc.loc == src.loc.loc && M.music == 0)
//					to_chat(world, "Found the song...")
//					M << S
			//		M.music = 1
			var/area/A = src.loc.loc

			for(var/obj/machinery/party/lasermachine/L in A)
				L.turnon()
			playing = 1
			while(playing == 1)
				for(var/mob/M in world)
					if((M.loc.loc in A) && M.music == 0)
//						to_chat(world, "Found the song...")
						M << S
						M.music = 1
					else if(!(M.loc.loc in A) && M.music == 1)
						var/sound/Soff = sound(null)
						Soff.channel = 10
						M << Soff
						M.music = 0
				sleep(10)
			return
	if( href_list["on2"] )
		if(src.playing == 0)
//			to_chat(world, "Should be working...")
			var/sound/S = sound('sound/turntable/testloop2.ogg')
			S.repeat = 1
			S.channel = 10
			S.falloff = 2
			S.wait = 1
			S.environment = 0
			//for(var/mob/M in world)
			//	if(M.loc.loc == src.loc.loc && M.music == 0)
//					to_chat(world, "Found the song...")
//					M << S
			//		M.music = 1
			var/area/A = src.loc.loc
			for(var/obj/machinery/party/lasermachine/L in A)
				L.turnon()
			playing = 1
			while(playing == 1)
				for(var/mob/M in world)
					if(M.loc.loc == src.loc.loc && M.music == 0)
//						to_chat(world, "Found the song...")
						M << S
						M.music = 1
					else if(M.loc.loc != src.loc.loc && M.music == 1)
						var/sound/Soff = sound(null)
						Soff.channel = 10
						M << Soff
						M.music = 0
				sleep(10)
			return
	if( href_list["on3"] )
		if(src.playing == 0)
//			to_chat(world, "Should be working...")
			var/sound/S = sound('sound/turntable/testloop3.ogg')
			S.repeat = 1
			S.channel = 10
			S.falloff = 2
			S.wait = 1
			S.environment = 0
			//for(var/mob/M in world)
			//	if(M.loc.loc == src.loc.loc && M.music == 0)
//					to_chat(world, "Found the song...")
//					M << S
			//		M.music = 1
			var/area/A = src.loc.loc
			for(var/obj/machinery/party/lasermachine/L in A)
				L.turnon()
			playing = 1
			while(playing == 1)
				for(var/mob/M in world)
					if(M.loc.loc == src.loc.loc && M.music == 0)
//						to_chat(world, "Found the song...")
						M << S
						M.music = 1
					else if(M.loc.loc != src.loc.loc && M.music == 1)
						var/sound/Soff = sound(null)
						Soff.channel = 10
						M << Soff
						M.music = 0
				sleep(10)
			return


	if( href_list["off"] )
		if(src.playing == 1)
			var/sound/S = sound(null)
			S.channel = 10
			S.wait = 1
			for(var/mob/M in world)
				M << S
				M.music = 0
			playing = 0
			var/area/A = src.loc.loc
			for(var/obj/machinery/party/lasermachine/L in A)
				L.turnoff()



/obj/machinery/party/lasermachine
	name = "laser machine"
	desc = "A laser machine that shoots lasers."
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "lasermachine"
	anchored = 1
	var/mirrored = 0

/obj/effect/turntable_laser
	name = "laser"
	desc = "A laser..."
	icon = 'icons/effects/lasers2.dmi'
	icon_state = "laserred1"
	anchored = 1
	layer = 4

/obj/item/lasermachine/New()
	..()

/obj/machinery/party/lasermachine/proc/turnon()
	var/wall = 0
	var/cycle = 1
	var/area/A = get_area(src)
	var/X = 1
	var/Y = 0
	if(mirrored == 0)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effect/turntable_laser/F = new(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred1"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 2)
				var/obj/effect/turntable_laser/F = new(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred2"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 3)
				var/obj/effect/turntable_laser/F = new(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred3"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
	if(mirrored == 1)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effect/turntable_laser/F = new(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred1m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 2)
				var/obj/effect/turntable_laser/F = new(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred2m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 3)
				var/obj/effect/turntable_laser/F = new(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred3m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					qdel(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++



/obj/machinery/party/lasermachine/proc/turnoff()
	var/area/A = src.loc.loc
	for(var/obj/effect/turntable_laser/F in A)
		qdel(F)
