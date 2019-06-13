/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith
	baseturf = /turf/simulated/floor/plating/asteroid/airless
	temperature = 2.7
	opacity = 1
	density = 1
	blocks_air = 1
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	var/environment_type = "asteroid"
	var/turf/simulated/floor/plating/turf_type = /turf/simulated/floor/plating/asteroid/airless
	var/mineralType = null
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0
	var/scan_state = null //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = FALSE

/turf/simulated/mineral/New()
	if (!canSmoothWith)
		canSmoothWith = list(/turf/simulated/mineral)
	pixel_y = -4
	pixel_x = -4
	icon = smooth_icon

	..()
	GLOB.mineral_turfs += src

	if (mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/simulated/mineral/random))
					Spread(T)

/turf/simulated/mineral/Spread(turf/T)
	T.ChangeTurf(type)

/turf/simulated/mineral/shuttleRotate(rotation)
	setDir(angle2dir(rotation + dir2angle(dir)))
	queue_smooth(src)

/turf/simulated/mineral/attackby(var/obj/item/pickaxe/P as obj, mob/user as mob, params)
	if(!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(istype(P, /obj/item/pickaxe))
		var/turf/T = user.loc
		if(!isturf(T))
			return

		if(last_act + (40 * P.toolspeed) > world.time) // Prevents message spam
			return

		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")
		P.playDigSound()

		if(do_after(user, 40 * P.toolspeed, target = src))
			if(istype(src, /turf/simulated/mineral)) //sanity check against turf being deleted during digspeed delay
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				P.update_icon()
				gets_drilled(user)
				feedback_add_details("pick_used_mining","[P.name]")
	else
		return attack_hand(user)

/turf/simulated/mineral/proc/gets_drilled()
	if(mineralType && (mineralAmt > 0) && (mineralAmt < 11))
		var/i
		for(i=0; i < mineralAmt; i++)
			new mineralType(src)
		feedback_add_details("ore_mined","[mineralType]|[mineralAmt]")
	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction

	if(rand(1, 750) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		new /obj/structure/closet/crate/secure/loot(src)

	return

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user as mob)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		gets_drilled()
	..()

/turf/simulated/mineral/attack_alien(var/mob/living/carbon/alien/M)
	to_chat(M, "<span class='notice'>You start digging into the rock...</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	if(do_after(M, 40, target = src))
		to_chat(M, "<span class='notice'>You tunnel into the rock.</span>")
		gets_drilled()

/turf/simulated/mineral/Bumped(AM as mob|obj)
	. = ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/pickaxe)) && H.hand)
			attackby(H.r_hand,H)
		return

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)

	else if(ismecha(AM))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/drill))
			M.selected.action(src)

/turf/simulated/mineral/ex_act(severity, target)
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
	var/mineralSpawnChanceList
	var/mineralChance = 13
	var/display_icon_state = "rock"

/turf/simulated/mineral/random/New()
	if (!mineralSpawnChanceList)
		mineralSpawnChanceList = list(
			/turf/simulated/mineral/uranium = 5, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 10,
			/turf/simulated/mineral/silver = 12, /turf/simulated/mineral/plasma = 20, /turf/simulated/mineral/iron = 40, /turf/simulated/mineral/titanium = 11,
			/turf/simulated/mineral/gibtonite = 4, /turf/simulated/floor/plating/asteroid/airless/cave = 2, /turf/simulated/mineral/bscrystal = 1)
	if (display_icon_state)
		icon_state = display_icon_state
	..()
	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		var/turf/T = ChangeTurf(path,FALSE,TRUE)

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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
	defer_change = 1

	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 5, /turf/simulated/mineral/diamond/volcanic = 1, /turf/simulated/mineral/gold/volcanic = 10, /turf/simulated/mineral/titanium/volcanic = 11,
		/turf/simulated/mineral/silver/volcanic = 12, /turf/simulated/mineral/plasma/volcanic = 20, /turf/simulated/mineral/iron/volcanic = 40,
		/turf/simulated/mineral/gibtonite/volcanic = 4, /turf/simulated/floor/plating/asteroid/airless/cave/volcanic = 1, /turf/simulated/mineral/bscrystal/volcanic = 1)

/turf/simulated/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium = 2, /turf/simulated/mineral/diamond = 1, /turf/simulated/mineral/gold = 3, /turf/simulated/mineral/titanium = 4,
		/turf/simulated/mineral/silver = 6, /turf/simulated/mineral/plasma = 15, /turf/simulated/mineral/iron = 80,
		/turf/simulated/mineral/gibtonite = 3)
	icon_state = "rock_labor"

/turf/simulated/mineral/random/labormineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/simulated/mineral/uranium/volcanic = 2, /turf/simulated/mineral/diamond/volcanic = 1, /turf/simulated/mineral/gold/volcanic = 3, /turf/simulated/mineral/titanium/volcanic = 4,
		/turf/simulated/mineral/silver/volcanic = 6, /turf/simulated/mineral/plasma/volcanic = 15, /turf/simulated/mineral/iron/volcanic = 80,
		/turf/simulated/mineral/gibtonite/volcanic = 3)

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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
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
	planetary_atmos = TRUE
	defer_change = 1

/turf/simulated/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE

/turf/simulated/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	defer_change = 1

// Gibtonite
/turf/simulated/mineral/gibtonite
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_Gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = 0 //How far into the lifecycle of gibtonite we are, 0 is untouched, 1 is active and attempting to detonate, 2 is benign and ready for extraction
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/activated_image = null

/turf/simulated/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	defer_change = 1

/turf/simulated/mineral/gibtonite/New()
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	..()

/turf/simulated/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) && stage == 1)
		user.visible_message("<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	..()

/turf/simulated/mineral/gibtonite/proc/explosive_reaction(var/mob/user = null, triggered_by_explosion = 0)
	if(stage == 0)
		var/image/I = image('icons/turf/smoothrocks.dmi', loc = src, icon_state = "rock_Gibtonite_active", layer = ON_EDGED_TURF_LAYER)
		add_overlay(I)
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
	while(istype(src, /turf/simulated/mineral/gibtonite) && stage == 1 && det_time > 0 && mineralAmt >= 1)
		det_time--
		sleep(5)
	if(istype(src, /turf/simulated/mineral/gibtonite))
		if(stage == 1 && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = 3
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/simulated/mineral/gibtonite/proc/defuse()
	if(stage == 1)
		overlays -= activated_image
		var/image/I = image('icons/turf/smoothrocks.dmi', loc = src, icon_state = "rock_Gibtonite_inactive", layer = ON_EDGED_TURF_LAYER)
		add_overlay(I)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = 2
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [src.det_time] reactions left till the explosion!</span>")

/turf/simulated/mineral/gibtonite/gets_drilled(var/mob/user, triggered_by_explosion = 0)
	if(stage == 0 && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == 1 && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = 3
		explosion(bombturf, 1, 2, 5, adminlog = 0)
	if(stage == 2) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/twohanded/required/gibtonite/G = new /obj/item/twohanded/required/gibtonite/(src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"

	ChangeTurf(turf_type, defer_change)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)
