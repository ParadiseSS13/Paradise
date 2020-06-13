/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = null
	baseturf = /turf/simulated/floor/plating/asteroid/airless
	opacity = 1
	density = TRUE
	blocks_air = TRUE
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	var/environment_type = "asteroid"
	var/turf/simulated/floor/plating/turf_type = /turf/simulated/floor/plating/asteroid/airless
	var/mineralType = null
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0
	var/scan_state = "" //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = 0

/turf/simulated/mineral/Initialize(mapload)
	if(!canSmoothWith)
		canSmoothWith = list(/turf/simulated/mineral)
	var/matrix/M = new
	M.Translate(-4, -4)
	transform = M
	icon = smooth_icon
	. = ..()
	if(mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in GLOB.cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/simulated/mineral/random))
					Spread(T)

/turf/simulated/mineral/Spread(turf/T)
	T.ChangeTurf(type)

/turf/simulated/mineral/shuttleRotate(rotation)
	setDir(angle2dir(rotation + dir2angle(dir)))
	queue_smooth(src)

/turf/simulated/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()

/turf/simulated/mineral/attackby(obj/item/I, mob/user, params)
	if(!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(istype(I, /obj/item/pickaxe))
		var/obj/item/pickaxe/P = I
		var/turf/T = user.loc
		if(!isturf(T))
			return

		if(last_act + (40 * P.toolspeed) > world.time) // Prevents message spam
			return
		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")
		P.playDigSound()

		if(do_after(user, 40 * P.toolspeed, target = src))
			if(ismineralturf(src)) //sanity check against turf being deleted during digspeed delay
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				gets_drilled(user)
				feedback_add_details("pick_used_mining","[P.name]")
	else
		return attack_hand(user)

/turf/simulated/mineral/proc/gets_drilled()
	if(mineralType && (mineralAmt > 0))
		new mineralType(src, mineralAmt)
		feedback_add_details("ore_mined","[mineralType]|[mineralAmt]")
	for(var/obj/effect/temp_visual/mining_overlay/M in src)
		qdel(M)
	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		gets_drilled()
	..()

/turf/simulated/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, "<span class='notice'>You start digging into the rock...</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
	if(do_after(M, 40, target = src))
		to_chat(M, "<span class='notice'>You tunnel into the rock.</span>")
		gets_drilled(M)

/turf/simulated/mineral/Bumped(atom/movable/AM)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/pickaxe)) && H.hand)
			attackby(H.r_hand,H)
		return

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active, /obj/item/pickaxe))
			attackby(R.module_active, R)

	else if(ismecha(AM))
		var/obj/mecha/M = AM
		if(istype(M.selected, /obj/item/mecha_parts/mecha_equipment/drill))
			M.selected.action(src)


/turf/simulated/mineral/acid_melt()
	ChangeTurf(baseturf)

/turf/simulated/mineral/ex_act(severity)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				gets_drilled(null, 1)
		if(2)
			if (prob(90))
				gets_drilled(null, 1)
		if(1)
			gets_drilled(null, 1)

/turf/simulated/mineral/random
	var/mineralSpawnChanceList = list(/turf/simulated/mineral/uranium = 5, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 10,
		/turf/simulated/mineral/silver = 12, /turf/simulated/mineral/plasma = 20, /turf/simulated/mineral/iron = 40, /turf/simulated/mineral/titanium = 11,
		/turf/simulated/mineral/gibtonite = 4, /turf/simulated/floor/plating/asteroid/airless/cave = 2, /turf/simulated/mineral/bscrystal = 1)
		//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 13
	var/display_icon_state = "rock"

/turf/simulated/mineral/random/Initialize(mapload)

	mineralSpawnChanceList = typelist("mineralSpawnChanceList", mineralSpawnChanceList)

	if(display_icon_state)
		icon_state = display_icon_state
	. = ..()
	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		var/turf/T = ChangeTurf(path, FALSE, TRUE)

		if(T && ismineralturf(T))
			var/turf/simulated/mineral/M = T
			M.mineralAmt = rand(1, 5)
			M.environment_type = environment_type
			M.turf_type = turf_type
			M.baseturf = baseturf
			src = M
			M.levelupdate()

/turf/simulated/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 35, /turf/simulated/mineral/diamond = 30, /turf/simulated/mineral/gold = 45, /turf/simulated/mineral/titanium = 45,
		/turf/simulated/mineral/silver = 50, /turf/simulated/mineral/plasma = 50, /turf/simulated/mineral/bscrystal = 20)

/turf/simulated/mineral/random/high_chance/clown
	mineralChance = 40
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 35, /turf/simulated/mineral/diamond = 2, /turf/simulated/mineral/gold = 5, /turf/simulated/mineral/silver = 5,
		/turf/simulated/mineral/iron = 30, /turf/simulated/mineral/clown = 15, /turf/simulated/mineral/mime = 15, /turf/simulated/mineral/bscrystal = 10)

/turf/simulated/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 35, /turf/simulated/mineral/diamond/volcanic = 30, /turf/simulated/mineral/gold/volcanic = 45, /turf/simulated/mineral/titanium/volcanic = 45,
		/turf/simulated/mineral/silver/volcanic = 50, /turf/simulated/mineral/plasma/volcanic = 50, /turf/simulated/mineral/bscrystal/volcanic = 20)

/turf/simulated/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 2, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 4, /turf/simulated/mineral/titanium = 4,
		/turf/simulated/mineral/silver = 6, /turf/simulated/mineral/plasma = 15, /turf/simulated/mineral/iron = 40,
		/turf/simulated/mineral/gibtonite = 2, /turf/simulated/mineral/bscrystal = 1)

/turf/simulated/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 5, /turf/simulated/mineral/diamond/volcanic = 1, /turf/simulated/mineral/gold/volcanic = 10, /turf/simulated/mineral/titanium/volcanic = 11,
		/turf/simulated/mineral/silver/volcanic = 12, /turf/simulated/mineral/plasma/volcanic = 20, /turf/simulated/mineral/iron/volcanic = 40,
		/turf/simulated/mineral/gibtonite/volcanic = 4, /turf/simulated/floor/plating/asteroid/airless/cave/volcanic = 1, /turf/simulated/mineral/bscrystal/volcanic = 1)

/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 3, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 8, /turf/simulated/mineral/titanium = 8,
		/turf/simulated/mineral/silver = 20, /turf/simulated/mineral/plasma = 30, /turf/simulated/mineral/iron = 95,
		/turf/simulated/mineral/gibtonite = 2)
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 3, /turf/simulated/mineral/diamond/volcanic = 1, /turf/simulated/mineral/gold/volcanic = 8, /turf/simulated/mineral/titanium/volcanic = 8,
		/turf/simulated/mineral/silver/volcanic = 20, /turf/simulated/mineral/plasma/volcanic = 30, /turf/simulated/mineral/bscrystal/volcanic = 1, /turf/simulated/mineral/gibtonite/volcanic = 2,
		/turf/simulated/mineral/iron/volcanic = 95)

// Actual minerals
/turf/simulated/mineral/iron
	mineralType = /obj/item/stack/ore/iron
	spreadChance = 20
	spread = 1
	scan_state = "rock_Iron"

/turf/simulated/mineral/iron/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/uranium
	mineralType = /obj/item/stack/ore/uranium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Uranium"

/turf/simulated/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/diamond
	mineralType = /obj/item/stack/ore/diamond
	spreadChance = 0
	spread = 1
	scan_state = "rock_Diamond"

/turf/simulated/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/gold
	mineralType = /obj/item/stack/ore/gold
	spreadChance = 5
	spread = 1
	scan_state = "rock_Gold"

/turf/simulated/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/silver
	mineralType = /obj/item/stack/ore/silver
	spreadChance = 5
	spread = 1
	scan_state = "rock_Silver"

/turf/simulated/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/titanium
	mineralType = /obj/item/stack/ore/titanium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Titanium"

/turf/simulated/mineral/titanium/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/plasma
	mineralType = /obj/item/stack/ore/plasma
	spreadChance = 8
	spread = 1
	scan_state = "rock_Plasma"

/turf/simulated/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/clown
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_Clown"

/turf/simulated/mineral/clown/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/mime
	mineralType = /obj/item/stack/ore/tranquillite
	mineralAmt = 3
	spreadChance = 0
	spread = 0

/turf/simulated/mineral/mime/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_BScrystal"

/turf/simulated/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

/turf/simulated/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/simulated/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	defer_change = 1

//gibtonite state defines
#define GIBTONITE_UNSTRUCK 0
#define GIBTONITE_ACTIVE 1
#define GIBTONITE_STABLE 2
#define GIBTONITE_DETONATE 3

// Gibtonite
/turf/simulated/mineral/gibtonite
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_Gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = GIBTONITE_UNSTRUCK //How far into the lifecycle of gibtonite we are
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/mutable_appearance/activated_overlay

/turf/simulated/mineral/gibtonite/Initialize(mapload)
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	. = ..()

/turf/simulated/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) && stage == 1)
		user.visible_message("<span class='notice'>[user] holds [I] to [src]...</span>", "<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	else
		return ..()

/turf/simulated/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK)
		activated_overlay = mutable_appearance('icons/turf/smoothrocks.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER)
		add_overlay(activated_overlay)
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = GIBTONITE_ACTIVE
		visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/notify_admins = 0
		if(z != 5)
			notify_admins = 1
			if(!triggered_by_explosion)
				message_admins("[key_name_admin(user)] has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else
				message_admins("An explosion has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")

		if(!triggered_by_explosion)
			log_game("[key_name(user)] has triggered a gibtonite deposit reaction at [A.name] ([A.x], [A.y], [A.z]).")
		else
			log_game("An explosion has triggered a gibtonite deposit reaction at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")

		countdown(notify_admins)

/turf/simulated/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/simulated/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0 && mineralAmt >= 1)
		det_time--
		sleep(5)
	if(istype(src, /turf/simulated/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = GIBTONITE_DETONATE
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/simulated/mineral/gibtonite/proc/defuse()
	if(stage == GIBTONITE_ACTIVE)
		cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		add_overlay(activated_overlay)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [det_time] reactions left till the explosion!</span>")

/turf/simulated/mineral/gibtonite/gets_drilled(var/mob/user, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg', 50, TRUE)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == GIBTONITE_ACTIVE && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = GIBTONITE_DETONATE
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == GIBTONITE_STABLE) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/twohanded/required/gibtonite/G = new(src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"

	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)


/turf/simulated/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	defer_change = 1

#undef GIBTONITE_UNSTRUCK
#undef GIBTONITE_ACTIVE
#undef GIBTONITE_STABLE
#undef GIBTONITE_DETONATE
