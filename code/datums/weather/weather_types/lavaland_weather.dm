//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounceic'>The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_trait = ORE_LEVEL
	immunity_type = "ash"
	probability = 0
	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/ash_storm/update_eligible_areas()
	. = ..()
	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

/datum/weather/ash_storm/update_audio()
	switch(stage)
		if(WEATHER_STARTUP_STAGE)
			sound_wo.start()
			sound_wi.start()

		if(WEATHER_MAIN_STAGE)
			sound_wo.stop()
			sound_wi.stop()

			sound_ao.start()
			sound_ai.start()

		if(WEATHER_WIND_DOWN_STAGE)
			sound_ao.stop()
			sound_ai.stop()

			sound_wo.start()
			sound_wi.start()

		if(WEATHER_END_STAGE)
			sound_wo.stop()
			sound_wi.stop()

/datum/weather/ash_storm/telegraph()
	. = ..()
	update_audio()

/datum/weather/ash_storm/start()
	. = ..()
	update_audio()

/datum/weather/ash_storm/wind_down()
	. = ..()
	update_audio()

/datum/weather/ash_storm/end()
	. = ..()
	update_audio()

/datum/weather/ash_storm/proc/is_ash_immune(atom/L)
	while(L && !isturf(L))
		if(ismecha(L)) //Mechs are immune
			return TRUE
		if(ishuman(L)) //Are you immune?
			var/mob/living/carbon/human/H = L
			var/thermal_protection = H.get_thermal_protection()
			if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
				return TRUE
		L = L.loc //Matryoshka check
	return FALSE //RIP you

/datum/weather/ash_storm/weather_act(mob/living/L)
	if(is_ash_immune(L))
		return
	L.adjustFireLoss(4)


//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"
	end_sound = null

	aesthetic = TRUE
	probability = 0

/datum/weather/volcano
	name = "volcanic activity"
	desc = "The shifting tectonic forces on the unstable planet have caused volcanic activity in the area. New rivers/chasms will form and chunks of rock will rain from the sky."

	telegraph_message = "<span class='userdanger'><i>The ground rumbles with an ominous strength, threatening to shift below you. Seek shelter.</i></span>"
	telegraph_duration = 600
	telegraph_sound = 'sound/weather/volcano/lavaland_volcano_warning.ogg'

	weather_message = "<span class='userdanger'><i>A massive plume of smoke and magma can be seen billowing in the distance. The ground quakes and threatens to split. Find shelder now!.</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_sound = 'sound/weather/volcano/lavaland_volcano_eruption.ogg'

	// No end message. Radar will give you the safety message on this one, or your instincts
	end_duration = 300

	area_type = /area/lavaland/surface/outdoors
	target_trait = ORE_LEVEL
	probability = 0
	barometer_predictable = TRUE
	area_act = TRUE
	// The time until the next rock falls from the sky
	var/next_rubble
	// Has a river already been generated this storm?
	var/generated_river = FALSE
	// What tiles can we hit with a rock?
	var/list/valid_targets = list()

/datum/weather/volcano/New()
	next_rubble = world.time + 10 SECONDS // Short delay

/datum/weather/volcano/area_act()
	if(prob(1) && !generated_river)
		generated_river = TRUE
		var/datum/river_spawner/new_river = new /datum/river_spawner(3)
		new_river.generate(nodes = 4, ignore_bridges = TRUE, warning = TRUE)
	if(world.time >= next_rubble)
		next_rubble = world.time + rand(5 DECISECONDS, 3 SECONDS)
		var/hits = 0
		for(var/turf/T in get_area_turfs(/area/lavaland/surface/outdoors))
			if(istype(T, /turf/simulated/floor/)) // dont waste our time hitting walls
				valid_targets += T
		while(hits <= 8) //sling a bunch of rocks around the map
			if(!valid_targets) // god forbid we run out of spots to sling rocks
				break
			var/target = pick(valid_targets)
			new /obj/effect/temp_visual/rock_target(target)
			hits++
			valid_targets -= target

/obj/effect/temp_visual/rockfall
	icon = 'icons/obj/meteor.dmi'
	icon_state = "clownish" // we shouldnt be seeing this
	name = "Ejected boulder"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	randomdir = FALSE
	duration = 10
	pixel_z = 270

/obj/effect/temp_visual/rockfall/Initialize(mapload)
	. = ..()
	icon_state = pick("small,","large", "sharp", "dust", "small1", "large1")
	animate(src, pixel_z = 0, time = duration)
	SpinAnimation()

/obj/effect/temp_visual/rock_target
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 10

/obj/effect/temp_visual/rock_target/ex_act()
	return

/obj/effect/temp_visual/rock_target/Initialize(mapload)
	. = ..()
	SpinAnimation()
	INVOKE_ASYNC(src, PROC_REF(fall))

/obj/effect/temp_visual/rock_target/proc/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	new /obj/effect/temp_visual/rockfall(T)
	sleep(duration)
	generate_boom(T)
	for(var/mob/living/L in T.contents)
		if(istype(T, /mob/living/simple_animal/hostile/megafauna))
			L.visible_message("[L.name] easily withstands the hit of the massive rock!")
			return
		else
			L.visible_message("<span class='danger'>[L.name] is crushed under the massive impact of the boulder!</span>", "<span class='userdanger'>You are crushed as a massive weight suddenly descends upon you!</span>", "<span class='danger'>You hear wet splatters as something is hit with a massive object!</span>")
			L.gib()
	if(!islava(T) && !istype(T, /turf/simulated/floor/chasm)) // Splash harmlessly into the lava pools
		T.ChangeTurf(/turf/simulated/mineral/random/high_chance/volcanic)

// shamelessly stolen and modified from explosion.dm
/obj/effect/temp_visual/rock_target/proc/generate_boom(turf/epicenter)
	for(var/MN in GLOB.player_list)
		var/mob/M = MN
		var/turf/M_turf = get_turf(M)
		if(M_turf && M_turf.z == epicenter.z)
			var/baseshakeamount
			var/frequency = get_rand_frequency()
			var/dist = get_dist(M_turf, epicenter)
			var/far_volume = clamp(dist / 2, 40, 60)
			if(dist < 10)
				playsound(epicenter, "explosion", 80, TRUE)
				playsound(epicenter, 'sound/effects/break_stone.ogg', 50, TRUE)
				shake_camera(M, 4, 3)
			else if(dist >= 10 && dist <= 40)
				M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, distance_multiplier = 0)
				baseshakeamount = sqrt((dist - 10) * 0.1)
				shake_camera(M, 2, clamp(baseshakeamount * 0.25, 0, 2.5))
			else if(dist > 40)
				M.playsound_local(epicenter, 'sound/effects/explosion_distant.ogg', far_volume, 1, frequency, distance_multiplier = 0)

/datum/weather/acid
	name = "acidic rain"
	desc = "Emissions of sulfur and carbon into the atmosphere results in the formation of acid particulate in the ashen clouds. Eventually, enough collects that it will fall back down as sulfuric acid rain. NT brand shelter pods capsules are not rated for this level of acid."

	telegraph_message = "<span class='userdanger'><i>The sound of tiny drops begins to splatter against the ground, sizzling against the ash and stone. Seek shelter.</i></span>"
	telegraph_duration = 600
	telegraph_sound = null //place me!
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Acidic rain begins to pour down in thick sheets, melting rock and flesh alike. Get inside now!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_sound = null //place me!
	weather_overlay = "ash_storm" // replace this

	end_message = "<span class='boldannounceic'>The pitter of acidic dropples slows to silence. It should be safe to go outside now.</span>"
	end_duration = 300
	end_overlay = null // Place me!

	area_type = /area/lavaland/surface/outdoors
	target_trait = ORE_LEVEL
	probability = 100
	barometer_predictable = TRUE
	area_act = TRUE
	// how long do you get before it melts a hole?
	var/melt_delay = 5 SECONDS
	var/melted_already

/datum/weather/acid/area_act()
	if(prob(5) && melted_already != TRUE)
		melted_already = TRUE
		if(!get_area_turfs(/area/survivalpod)) // dont continue if we havnt made pods yet
			return
		var/turf/melt_this = pick(get_area_turfs(/area/survivalpod))
		addtimer(CALLBACK(src, PROC_REF(melt_pod), melt_this), melt_delay)

/datum/weather/acid/proc/melt_pod(turf/melt_this)
	to_chat(world, "melted a roof at [melt_this.x] X, [melt_this.y]")
	melt_this.change_area(melt_this, /area/lavaland/surface/outdoors)
	impacted_areas += melt_this
	for(var/turf/nearby_turf in RANGE_TURFS(1, melt_this) - melt_this)
		if(prob(40))
			nearby_turf.change_area(nearby_turf, /area/lavaland/surface/outdoors)
			to_chat(world, "melted a roof at [nearby_turf.x] X, [nearby_turf.y]")
			impacted_areas += nearby_turf
	update_eligible_areas()

/datum/weather/acid/weather_act(atom/L)
	if(ismecha(L)) //Mechs are immune
		return
	if(!ishuman(L) || isgrey(L)) // greys and natural fauna shouldnt be affected by acid rain
		return
	var/mob/living/carbon/human/H = L
	if(!H.wear_suit && !H.head) // No need to check further if they
		return
	if((H.head.resistance_flags & ACID_PROOF) && (H.wear_suit.resistance_flags & ACID_PROOF))
		return

	H.adjustFireLoss(2)
	H.adjustBruteLoss(2)
