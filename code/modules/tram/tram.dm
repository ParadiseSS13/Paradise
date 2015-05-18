/obj/tram/tram_controller
	name = ""
	desc = "tram controller"
	anchored = 1
	simulated = 0
	var/list/tram_floors = list()
	var/list/tram_walls = list()
	var/list/controllers = list()

	var/list/tram = list()

	var/list/collide_list = list()

	var/list/stored_anchor = list()

/obj/tram/tram_controller/New()
	init_floors()
	init_walls()
	spawn(1)
		init_tram()
		init_controllers()
		gen_collision()
		processing_objects.Add(src)

/obj/tram/tram_controller/process()
	update_tram()

/obj/tram/tram_controller/proc/init_floors()
	var/turf/T = get_turf(src)
	if(!T)	return
	var/obj/tram/floor/TTF = locate(/obj/tram/floor in T)
	if(istype(TTF))	add_floor(TTF)
	for(var/cdir in cardinal)
		var/turf/T2 = get_step(T,cdir)
		var/obj/tram/floor/TF = locate(/obj/tram/floor) in T2
		if(istype(TF))
			if(TF in tram_floors)	continue
			add_floor(TF)
			spawn(1)
				TF.spread_floors()

/obj/tram/tram_controller/proc/init_walls()
	var/turf/T = get_turf(src)
	if(!T)	return
	if(!tram_floors.len)	return
	var/obj/tram/floor/TTW = locate(/obj/tram/wall in T)
	if(istype(TTW))	add_wall(TTW)
	for(var/obj/tram/floor/TF in tram_floors)
		for(var/cdir in cardinal)
			var/obj/tram/wall/TW = locate(/obj/tram/wall) in get_step(TF,cdir)
			if(istype(TW))
				if(TW in tram_walls)	continue
				add_wall(TW)
				spawn(1)
					TW.spread_walls()

/obj/tram/tram_controller/proc/init_tram()
	tram = tram_floors + tram_walls
	for(var/obj/tram/OT in tram)
		var/turf/T = get_turf(OT)
		for(var/atom/movable/AM in T)
			if(AM in tram)	continue
			tram += AM

/obj/tram/tram_controller/proc/init_controllers()
	for(var/obj/tram/controlpad/CCP in tram)
		add_controller(CCP)

/obj/tram/tram_controller/proc/add_floor(var/obj/tram/floor/TF)
	if(!istype(TF))	return
	if(TF in tram_floors)	return
	tram_floors += TF
	TF.controller = src

/obj/tram/tram_controller/proc/remove_floor(var/obj/tram/floor/TF)
	if(!istype(TF))	return
	if(TF in tram_floors)
		tram_floors -= TF
	TF.controller = null



/obj/tram/tram_controller/proc/add_wall(var/obj/tram/wall/TW)
	if(!istype(TW))	return
	if(TW in tram_walls)	return
	tram_walls += TW
	TW.controller = src

/obj/tram/tram_controller/proc/remove_wall(var/obj/tram/wall/TW)
	if(!istype(TW))	return
	if(TW in tram_walls)
		tram_walls -= TW
	TW.controller = null



/obj/tram/tram_controller/proc/add_controller(var/obj/tram/controlpad/CCT)
	if(!istype(CCT))	return
	if(CCT in controllers)	return
	controllers += CCT
	CCT.tram_linked = src

/obj/tram/tram_controller/proc/remove_controller(var/obj/tram/controlpad/CCT)
	if(!istype(CCT))	return
	if(CCT in controllers)
		controllers -= CCT
	CCT.tram_linked = null



/obj/tram/tram_controller/proc/gen_collision()
	collide_list.Cut()
	var/list/collisions = list()
	for(var/obj/tram/wall/W in tram_walls)
		for(var/cdir in cardinal)
			var/turf/T = get_step(W, cdir)
			if(istype(T))
				if(T.density)
					collisions += cdir
				if(!T.density)
					for(var/atom/movable/A in T)
						if(A.density)
							if(tram.Find(A))	continue
							collisions += cdir
	collide_list = collisions

/obj/tram/tram_controller/proc/update_tram()
	tram.Cut()
	init_tram()

/obj/tram/tram_controller/proc/handle_move(var/dir)
	gen_collision()
	if(dir in collide_list)
		return 0
	for(var/atom/movable/A in tram)
		var/turf/T = get_step(A,dir)
		A.forceMove(T)
	gen_collision()
	return 1

/obj/tram/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	var/obj/tram/tram_controller/controller
	anchored = 1

/obj/tram/floor/proc/spread_floors()
	var/turf/T = get_turf(src)
	if(!T)	return
	if(!controller)	return
	for(var/cdir in cardinal)
		var/turf/T2 = get_step(T,cdir)
		var/obj/tram/floor/TF = locate(/obj/tram/floor) in T2
		if(istype(TF))
			if(TF in controller.tram_floors)	continue
			controller.add_floor(TF)
			TF.spread_floors()

/obj/tram/wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	var/obj/tram/tram_controller/controller
	anchored = 1

/obj/tram/wall/proc/spread_walls()
	var/turf/T = get_turf(src)
	if(!T)	return
	if(!controller)	return
	for(var/cdir in cardinal)
		var/turf/T2 = get_step(T,cdir)
		var/obj/tram/wall/TW = locate(/obj/tram/wall) in T2
		if(istype(TW))
			if(TW in controller.tram_walls)	continue
			controller.add_wall(TW)
			TW.spread_walls()

/obj/tram/controlpad
	name = "tram controller interface"
	desc = "Controls the tram."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	var/obj/tram/tram_controller/tram_linked

/obj/tram/controlpad/attack_hand(var/mob/user)
	if(!tram_linked)	return
	var/dat = "Tram Controller"
	for(var/cdir in cardinal)
		dat += "<br>Move to: <a href=?src=\ref[src];movedir=[cdir]>[cdir]</a>"
	user << browse(dat, "window=trampad")
	onclose(user,"trampad")

/obj/tram/controlpad/Topic(href, href_list)
	if(href_list["movedir"])
		var/dir = text2num(href_list["movedir"])
		tram_linked.handle_move(dir)