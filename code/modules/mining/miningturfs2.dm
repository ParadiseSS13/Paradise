/turf/closed/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith
	baseturf = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = "TEMP=2.7"
	opacity = 1
	density = 1
	blocks_air = 1
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	var/environment_type = "asteroid"
	var/turf/open/floor/plating/turf_type = /turf/open/floor/plating/asteroid/airless
	var/mineralType = null
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0
	var/scan_state = null //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = 0

/turf/closed/mineral/New()
	if(!canSmoothWith)
		canSmoothWith = list(/turf/closed/mineral, /turf/closed/wall)
	pixel_y = -4
	pixel_x = -4
	icon = smooth_icon
	..()
	if (mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/closed/mineral/random))
					Spread(T)

/turf/closed/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt
	baseturf = /turf/open/floor/plating/asteroid/basalt
	initial_gas_mix = "o2=14;n2=23;TEMP=300"

/turf/closed/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				src.gets_drilled(null, 1)
		if(2)
			if (prob(90))
				src.gets_drilled(null, 1)
		if(1)
			src.gets_drilled(null, 1)
	return

/turf/closed/mineral/Spread(turf/T)
	new src.type(T)

/turf/closed/mineral/random
	var/mineralSpawnChanceList
	var/mineralChance = 13
	var/display_icon_state = "rock"

/turf/closed/mineral/random/New()
	if(!mineralSpawnChanceList)
		mineralSpawnChanceList = list(
			/turf/closed/mineral/uranium = 5, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 10,
			/turf/closed/mineral/silver = 12, /turf/closed/mineral/plasma = 20, /turf/closed/mineral/iron = 40,
			/turf/closed/mineral/gibtonite = 4, /turf/open/floor/plating/asteroid/airless/cave = 2, /turf/closed/mineral/bscrystal = 1)
			//Currently, Adamantine won't spawn as it has no uses. -Durandan
	if(display_icon_state)
		icon_state = display_icon_state
	..()

	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		var/turf/T = new path(src)

		if(T && istype(T, /turf/closed/mineral))
			var/turf/closed/mineral/M = T
			M.mineralAmt = rand(1, 5)
			M.environment_type = src.environment_type
			M.turf_type = src.turf_type
			M.baseturf = src.baseturf
			src = M
			M.levelupdate()

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 35, /turf/closed/mineral/diamond = 30, /turf/closed/mineral/gold = 45,
		/turf/closed/mineral/silver = 50, /turf/closed/mineral/plasma = 50, /turf/closed/mineral/bscrystal = 20)

/turf/closed/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 2, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 4,
		/turf/closed/mineral/silver = 6, /turf/closed/mineral/plasma = 15, /turf/closed/mineral/iron = 40,
		/turf/closed/mineral/gibtonite = 2, /turf/closed/mineral/bscrystal = 1)

/turf/closed/mineral/iron
	mineralType = /obj/item/weapon/ore/iron
	spreadChance = 20
	spread = 1
	scan_state = "rock_Iron"

/turf/closed/mineral/uranium
	mineralType = /obj/item/weapon/ore/uranium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Uranium"

/turf/closed/mineral/diamond
	mineralType = /obj/item/weapon/ore/diamond
	spreadChance = 0
	spread = 1
	scan_state = "rock_Diamond"

/turf/closed/mineral/gold
	mineralType = /obj/item/weapon/ore/gold
	spreadChance = 5
	spread = 1
	scan_state = "rock_Gold"

/turf/closed/mineral/silver
	mineralType = /obj/item/weapon/ore/silver
	spreadChance = 5
	spread = 1
	scan_state = "rock_Silver"

/turf/closed/mineral/plasma
	mineralType = /obj/item/weapon/ore/plasma
	spreadChance = 8
	spread = 1
	scan_state = "rock_Plasma"

/turf/closed/mineral/clown
	mineralType = /obj/item/weapon/ore/bananium
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_Clown"

/turf/closed/mineral/bscrystal
	mineralType = /obj/item/weapon/ore/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_BScrystal"

////////////////////////////////Gibtonite
/turf/closed/mineral/gibtonite
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_Uranium"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = 0 //How far into the lifecycle of gibtonite we are, 0 is untouched, 1 is active and attempting to detonate, 2 is benign and ready for extraction
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/activated_image = null

/turf/closed/mineral/gibtonite/New()
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	..()

/turf/closed/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(is_mining_scanner(I) && stage == 1)
		user.visible_message("<span class='notice'>[user] holds [I] to [src]...</span>", "<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	..()

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == 0)
		var/image/I = image('icons/turf/smoothrocks.dmi', loc = src, icon_state = "rock_Gibtonite_active", layer = ON_EDGED_TURF_LAYER)
		overlays += I
		activated_image = I
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = 1
		visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/notify_admins = 0
		if(z != 5)
			notify_admins = 1
			if(!triggered_by_explosion)
				message_admins("[key_name_admin(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else
				message_admins("An explosion has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")

		if(!triggered_by_explosion)
			log_game("[key_name(user)] has triggered a gibtonite deposit reaction at [A.name] ([A.x], [A.y], [A.z]).")
		else
			log_game("An explosion has triggered a gibtonite deposit reaction at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")

		countdown(notify_admins)

/turf/closed/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == 1 && det_time > 0 && mineralAmt >= 1)
		det_time--
		sleep(5)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == 1 && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = 3
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/closed/mineral/gibtonite/proc/defuse()
	if(stage == 1)
		overlays -= activated_image
		var/image/I = image('icons/turf/smoothrocks.dmi', loc = src, icon_state = "rock_Gibtonite_inactive", layer = ON_EDGED_TURF_LAYER)
		overlays += I
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = 2
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [src.det_time] reactions left till the explosion!</span>")

/turf/closed/mineral/gibtonite/gets_drilled(mob/user, triggered_by_explosion = 0)
	if(stage == 0 && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == 1 && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = 3
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == 2) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/weapon/twohanded/required/gibtonite/G = new /obj/item/weapon/twohanded/required/gibtonite/(src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"

	ChangeTurf(turf_type, defer_change)
	spawn(10)
		AfterChange()

/turf/closed/mineral/gibtonite/volcanic
	initial_gas_mix = "o2=14;n2=23;TEMP=300"

////////////////////////////////End Gibtonite

/turf/open/floor/plating/asteroid/airless/cave
	var/length = 100
	var/mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goldgrub = 1, /mob/living/simple_animal/hostile/asteroid/goliath = 5, /mob/living/simple_animal/hostile/asteroid/basilisk = 4, /mob/living/simple_animal/hostile/asteroid/hivelord = 3)
	var/sanity = 1
	turf_type = /turf/open/floor/plating/asteroid/airless

/turf/open/floor/plating/asteroid/airless/cave/volcanic
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goldgrub = 10, /mob/living/simple_animal/hostile/asteroid/goliath/beast = 50, /mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 40, \
		/mob/living/simple_animal/hostile/asteroid/marrowweaver = 35, /mob/living/simple_animal/hostile/asteroid/hivelord/legion = 30, \
		/mob/living/simple_animal/hostile/spawner/lavaland = 2, /mob/living/simple_animal/hostile/spawner/lavaland/goliath = 3, /mob/living/simple_animal/hostile/spawner/lavaland/legion = 3, \
		/mob/living/simple_animal/hostile/megafauna/dragon = 2, /mob/living/simple_animal/hostile/megafauna/bubblegum = 2, /mob/living/simple_animal/hostile/megafauna/colossus = 2)

	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"

/turf/open/floor/plating/asteroid/airless/cave/New(loc, length, go_backwards = 1, exclude_dir = -1)
	// If length (arg2) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!length)
		src.length = rand(25, 50)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)
	..()

/turf/open/floor/plating/asteroid/airless/cave/proc/make_tunnel(dir)

	var/turf/closed/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/closed/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				new src.type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)


/turf/open/floor/plating/asteroid/airless/cave/proc/SpawnFloor(turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/open/space) || istype(S.loc, /area/mine/explored))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)
	new turf_type(T)
/turf/open/floor/plating/asteroid/airless/cave/proc/SpawnMonster(turf/T)
	if(prob(30))
		if(istype(loc, /area/mine/explored))
			return
		for(var/atom/A in urange(12,T))//Lowers chance of mob clumps
			if(T.x < 75)
				return
			if(T.y < 55)
				return
			if(istype(A, /mob/living/simple_animal/hostile/asteroid))
				return
		var/randumb = pickweight(mob_spawn_list)
		new randumb(T)
	return

/turf/closed/mineral/attackby(obj/item/weapon/pickaxe/P, mob/user, params)

	if (!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (istype(P, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(last_act+P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")
		P.playDigSound()

		if(do_after(user,P.digspeed, target = src))
			if(istype(src, /turf/closed/mineral))
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				gets_drilled(user)
				feedback_add_details("pick_used_mining","[P.type]")
	return

/turf/closed/mineral/proc/gets_drilled()
	if (mineralType && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			new mineralType(src)
		feedback_add_details("ore_mined","[mineralType]|[mineralAmt]")
	ChangeTurf(turf_type, defer_change)
	spawn(10)
		AfterChange()
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction
	return

/turf/closed/mineral/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash >= 2)
		gets_drilled()
	..()

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, "<span class='notice'>You start digging into the rock...</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	if(do_after(M,40, target = src))
		to_chat(M, "<span class='notice'>You tunnel into the rock.</span>")
		gets_drilled(M)

/turf/closed/mineral/Bumped(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
			src.attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
			src.attackby(H.r_hand,H)
		return
	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			src.attackby(R.module_active,R)
			return
/*	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/drill))
			src.attackby(M.selected,M)
			return*/
//Aparantly mechs are just TOO COOL to call Bump(), so fuck em (for now)
	else
		return

/**********************Asteroid**************************/

/turf/open/floor/plating/asteroid //floor piece
	name = "asteroid sand"
	baseturf = /turf/open/floor/plating/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	var/environment_type = "asteroid"
	var/turf_type = /turf/open/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	var/sand_type = /obj/item/weapon/ore/glass

/turf/open/floor/plating/asteroid/airless
	initial_gas_mix = "TEMP=2.7"
	turf_type = /turf/open/floor/plating/asteroid/airless

/turf/open/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturf = /turf/open/floor/plating/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	sand_type = /obj/item/weapon/ore/glass/basalt

/turf/open/floor/plating/asteroid/basalt/lava //lava underneath
	baseturf = /turf/open/floor/plating/lava/smooth

/turf/open/floor/plating/asteroid/basalt/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/plating/asteroid/snow
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturf = /turf/open/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	initial_gas_mix = "TEMP=180"
	slowdown = 2
	environment_type = "snow"
	sand_type = /obj/item/stack/sheet/mineral/snow

/turf/open/floor/plating/asteroid/snow/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/plating/asteroid/snow/temperatre
	initial_gas_mix = "TEMP=255.37"

/turf/open/floor/plating/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	if(prob(20))
		icon_state = "[environment_type][rand(0,12)]"

/turf/open/floor/plating/asteroid/burn_tile()
	return

/turf/open/floor/plating/asteroid/ex_act(severity, target)
	contents_explosion(severity, target)
	switch(severity)
		if(3)
			return
		if(2)
			if (prob(20))
				src.gets_dug()
		if(1)
			src.gets_dug()
	return

/turf/open/floor/plating/asteroid/attackby(obj/item/weapon/W, mob/user, params)
	//note that this proc does not call ..()
	if(!W || !user)
		return 0
	var/digging_speed = 0
	if (istype(W, /obj/item/weapon/shovel))
		var/obj/item/weapon/shovel/S = W
		digging_speed = S.digspeed
	else if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W
		digging_speed = P.digspeed
	if (digging_speed)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			to_chat(user, "<span class='warning'>This area has already been dug!</span>")
			return

		to_chat(user, "<span class='notice'>You start digging...</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)

		if(do_after(user, digging_speed, target = src))
			if(istype(src, /turf/open/floor/plating/asteroid))
				to_chat(user, "<span class='notice'>You dig a hole.</span>")
				gets_dug()
				feedback_add_details("pick_used_mining","[W.type]")

	if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode == 1)
			for(var/obj/item/weapon/ore/O in src.contents)
				O.attackby(W,user)
				return

	if(istype(W, /obj/item/stack/tile))
		var/obj/item/stack/tile/Z = W
		if(!Z.use(1))
			return
		var/turf/open/floor/T = ChangeTurf(Z.turf_type)
		if(istype(Z,/obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
			var/obj/item/stack/tile/light/L = Z
			var/turf/open/floor/light/F = T
			F.state = L.state
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/open/floor/plating/asteroid/proc/gets_dug()
	if(dug)
		return
	for(var/i in 1 to 5)
		new sand_type(src)
	dug = 1
	icon_plating = "[environment_type]_dug"
	icon_state = "[environment_type]_dug"
	slowdown = 0
	return

/turf/open/floor/plating/asteroid/singularity_act()
	return

/turf/open/floor/plating/asteroid/singularity_pull(S, current_size)
	return

/**********************Lavaland Turfs**************************/

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface

/turf/open/chasm/straight_down/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/straight_down/lava_land_surface

/turf/open/chasm/straight_down/lava_land_surface/drop(atom/movable/AM)
	if(!AM)
		return
	if(!AM.invisibility)
		AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall \
		into the enveloping dark.</span>")
		if(isliving(AM))
			var/mob/living/L = AM
			L.notransform = TRUE
			L.Stun(10)
			L.resting = TRUE
		animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
		for(var/i in 1 to 5)
			AM.pixel_y--
			sleep(2)
		if(isrobot(AM))
			var/mob/living/silicon/robot/S = AM
			qdel(S.mmi)
		qdel(AM)

/turf/closed/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	defer_change = 1

/turf/closed/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 5, /turf/closed/mineral/diamond/volcanic = 1, /turf/closed/mineral/gold/volcanic = 10,
		/turf/closed/mineral/silver/volcanic = 12, /turf/closed/mineral/plasma/volcanic = 20, /turf/closed/mineral/iron/volcanic = 40,
		/turf/closed/mineral/gibtonite/volcanic = 4, /turf/open/floor/plating/asteroid/airless/cave/volcanic = 1, /turf/closed/mineral/bscrystal/volcanic = 1)

/turf/closed/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 35, /turf/closed/mineral/diamond/volcanic = 30, /turf/closed/mineral/gold/volcanic = 45,
		/turf/closed/mineral/silver/volcanic = 50, /turf/closed/mineral/plasma/volcanic = 50, /turf/closed/mineral/bscrystal/volcanic = 20)

/turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/straight_down/lava_land_surface

/turf/closed/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/iron/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1


//BECAUSE ONE PLANET WASNT ENOUGH

/turf/closed/mineral/ash_rock //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/rock_wall.dmi'
	icon_state = "rock"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed/mineral, /turf/closed/wall)
	baseturf = /turf/open/floor/plating/ash
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	environment_type = "waste"
	turf_type = /turf/open/floor/plating/ash
	defer_change = 1

/turf/open/floor/plating/ash
	icon = 'icons/turf/mining.dmi'
	name = "ash"
	icon_state = "ash"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/open/floor/plating/ash, /turf/closed)
	var/smooth_icon = 'icons/turf/floors/ash.dmi'
	desc = "The ground is covered in volcanic ash."
	baseturf = /turf/open/floor/plating/ash //I assume this will be a chasm eventually, once this becomes an actual surface
	slowdown = 1
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE

/turf/open/floor/plating/ash/New()
	pixel_y = -4
	pixel_x = -4
	icon = smooth_icon
	..()

/turf/open/floor/plating/ash/break_tile()
	return

/turf/open/floor/plating/ash/burn_tile()
	return

/turf/open/floor/plating/ash/rocky
	name = "rocky ground"
	icon_state = "rockyash"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/floors/rocky_ash.dmi'
	slowdown = 0
	smooth = SMOOTH_MORE|SMOOTH_BORDER
canSmoothWith = list (/turf/open/floor/plating/ash/rocky, /turf/closed)