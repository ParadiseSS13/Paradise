/obj/tram/tram_controller
	name = ""
	desc = "tram controller"
	anchored = 1

	var/list/tram_floors = list()
	var/list/tram_walls = list()
	var/list/controllers = list()

	var/list/tram = list()

	var/list/collide_list = list()

	var/list/stored_anchor = list()
	var/last_played_rail

	var/automode = 0
	var/fast_mode = 0

	var/activated = 0
	var/looptick = 0

	var/delay_timer = null

	var/list/blacklist = list(/obj/tram/rail,/atom/movable/lighting_overlay)
	var/list/ancwhitelist = list(/obj/tram, /obj/vehicle, /obj/structure/stool/bed/chair, /obj/structure/grille, /obj/structure/window)

/obj/tram/tram_controller/New()
	spawn(1)
		init_floors() //Search and link floors
		init_walls() //Search and link walls
		spawn(1)
			init_tram() //Combine walls and floors and anything inside the tram
			init_controllers() //Find control pads
			gen_collision() //Generate collision system

/obj/tram/tram_controller/Destroy()
	for(var/obj/tram/floor/F in tram_floors)
		remove_floor(F)
	for(var/obj/tram/wall/TW in tram_walls)
		remove_wall(TW)
	for(var/obj/tram/controlpad/CP in controllers)
		remove_controller(CP)
	killLoop()
	return ..()

/obj/tram/tram_controller/emp_act(severity)
	if(automode)	automode = 0
	..()

/obj/tram/tram_controller/proc/startLoop()
	if(activated)	return
	activated = 1
	spawn(0)
		while(activated)
			process()
			looptick++
			sleep(1)

/obj/tram/tram_controller/proc/killLoop()
	activated = 0
	looptick = 0

/obj/tram/tram_controller/process()
	update_tram() //Update combine to account for new mobs and/or objects
	if(automode)
		tram_rail_follow()
		if(fast_mode)
			tram_rail_follow()

/obj/tram/tram_controller/proc/update_tram()
	tram.Cut()
	init_tram()

/obj/tram/tram_controller/proc/tram_rail_follow()
	var/stored_rail = null
	if(delay_timer >= world.time)	return
	for(var/obj/tram/rail/RT in get_turf(src))
		if(RT.stop_duration && !delay_timer)
			delay_timer = world.time + RT.stop_duration
			return
		if(RT.godir)
			handle_move(RT.godir)
			last_played_rail = RT
			return
		stored_rail = RT
	for(var/cdir in cardinal)
		for(var/obj/tram/rail/R in get_step(src,cdir))
			if(!istype(R))	continue
			if(R != last_played_rail)
				handle_move(get_dir(src,R))
				last_played_rail = stored_rail
				return

//INITIALIZATION PROCS

/obj/tram/tram_controller/proc/init_floors()
	var/turf/T = get_turf(src)
	if(!T)	return
	var/obj/tram/floor/TTF = locate(/obj/tram/floor) in T
	if(istype(TTF))	add_floor(TTF) //Find and link floor on controller turf
	for(var/cdir in cardinal)
		var/turf/T2 = get_step(T,cdir)
		var/obj/tram/floor/TF = locate(/obj/tram/floor) in T2
		if(istype(TF))
			if(TF in tram_floors)	continue
			add_floor(TF) //Find and link all cardinally surrounding floors
			spawn(1)
				TF.spread_floors() //Do the same thing over again from the floor itself

/obj/tram/tram_controller/proc/init_walls()
	var/turf/T = get_turf(src)
	if(!T)	return
	if(!tram_floors.len)	return
	var/obj/tram/floor/TTW = locate(/obj/tram/wall) in T //Find and link wall on controller turf
	if(istype(TTW))	add_wall(TTW)
	for(var/obj/tram/floor/TF in tram_floors)
		for(var/cdir in cardinal)
			var/obj/tram/wall/TW = locate(/obj/tram/wall) in get_step(TF,cdir)
			if(istype(TW))
				if(TW in tram_walls)	continue
				add_wall(TW) //Find and link all cardinally surrounding walls
				spawn(1)
					TW.spread_walls() //Do the same thing over again from the wall itself

/obj/tram/tram_controller/proc/init_tram()
	tram = tram_floors + tram_walls //Tram is everything that makes up the tram
	for(var/obj/tram/OT in tram)
		var/turf/T = get_turf(OT)
		for(var/atom/movable/AM in T) //Including anything inside of it
			if(AM in tram)	continue
			if(!check_validity(AM))	continue
			tram += AM
			if(!(src in tram))
				tram += src

/obj/tram/tram_controller/proc/check_validity(var/atom/movable/AM)
	if(!AM)	return 0
	if(is_type_in_list(AM, blacklist))	return 0
	if(!AM.simulated)	return 0
	if(AM.anchored)
		if(is_type_in_list(AM, ancwhitelist))
			return 1
		return 0
	return 1

/obj/tram/tram_controller/proc/init_controllers()
	for(var/obj/tram/controlpad/CCP in tram)
		add_controller(CCP) //Control pad not necessary until now, easiest to search through tram

//SYNC PROCS
//These procs are used for un/linking floors, walls, and control pads to the central tram controller

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

//COLLISION & MOVEMENT
//Collision detection system to prevent going through walls
//Tram does not use built-in byond Move(), it uses it's own logic and then forceMove()s itself.

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
	for(var/obj/tram/floor/F in tram_floors)
		for(var/cdir in cardinal)
			var/turf/T = get_step(F, cdir)
			if(istype(T))
				if(T.density)
					collisions += cdir
				if(!T.density)
					for(var/atom/movable/A in T)
						if(A.density)
							if(tram.Find(A))	continue
							collisions += cdir
	collide_list = collisions

/obj/tram/tram_controller/proc/handle_move(var/dir)
	delay_timer = null //reset delay
	gen_collision() //Look for collisions
	if(dir in collide_list) //Prevent moving if there are collisions in that direction
		return 0
	for(var/atom/movable/A in tram)
		var/turf/T = get_step(A,dir)
		A.forceMove(T) //Move everything inside the tram and the tram itself manually
		if(A.light_range)
			A.set_light()
	gen_collision() //Generate collision again
	return 1

//////////////////////DAMAGE PROCS
/obj/tram/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
			return
		if(3.0)
			if(prob(25))
				qdel(src)
			return

/obj/tram/blob_act()
	if(prob(50))
		qdel(src)

/obj/tram/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)	return
	if(prob(M.melee_damage_upper))
		qdel(src)
	src.visible_message("<span class='danger'>[M] has [M.attacktext] [src]!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")

/obj/tram/bullet_act(var/obj/item/projectile/proj)
	if(prob(proj.damage))
		qdel(src)
	..()