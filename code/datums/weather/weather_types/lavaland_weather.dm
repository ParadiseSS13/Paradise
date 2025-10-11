#define ROCKFALL_DELAY 10 // For how long until the boulders hit the ground

/// MARK: Ash Storm
//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "Ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounceic'>The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.</span>"
	end_overlay = "light_ash"

	area_types = list(/area/lavaland/surface/outdoors, /area/lavaland/surface/gulag_rock)
	target_trait = ORE_LEVEL
	immunity_type = "ash"
	probability = 25
	barometer_predictable = TRUE

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

	/// Amount of thermal protection we need to be protected from this storm
	var/thermal_protection_threshold = FIRE_IMMUNITY_MAX_TEMP_PROTECT - 15
	/// Amount of burn damage we receive if we aren't immune
	var/burn_damage = 4

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

/datum/weather/ash_storm/on_shelter_placed(datum/source, turf/center)
	. = ..()
	if(center.z in impacted_z_levels)
		var/area/A = get_area(center)
		inside_areas |= A
		sound_ai.output_atoms |= A
		sound_wi.output_atoms |= A

/datum/weather/ash_storm/proc/is_ash_immune(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/target = user
		if(target.get_thermal_protection() >= thermal_protection_threshold)
			return TRUE
	if(is_mecha_occupant(user)) // mecha's occupants are immune
		return TRUE

/datum/weather/ash_storm/weather_act(mob/living/target)
	if(!is_ash_immune(target))
		target.adjustFireLoss(burn_damage)

/// MARK: Heavy Ash Storm
// Radar needed to detect the difference, but shouldnt matter much
/datum/weather/ash_storm/heavy
	name = "Heavy ash storm"
	desc = "An even more intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	//lasts longer
	weather_duration_lower = 800
	weather_duration_upper = 1600

	probability = 10

	thermal_protection_threshold = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	burn_damage = 6

/// MARK: Emberfall
//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "Emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"
	end_sound = null

	aesthetic = TRUE

/// MARK: Volcano
/datum/weather/volcano
	name = "Volcanic activity"
	desc = "The shifting tectonic forces on the unstable planet have caused volcanic activity in the area. New rivers/chasms will form and chunks of rock will rain from the sky."

	telegraph_message = "<span class='boldwarning'><i>The ground rumbles with an ominous strength, threatening to shift below you. Seek shelter.</i></span>"
	telegraph_duration = 600
	telegraph_sound = 'sound/weather/volcano/lavaland_volcano_warning.ogg'

	weather_message = "<span class='userdanger'><i>A massive plume of smoke and magma can be seen billowing in the distance. The ground quakes and threatens to split. Find shelter now!.</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_sound = 'sound/weather/volcano/lavaland_volcano_eruption.ogg'

	// No end message. Radar will give you the safety message on this one, or your instincts
	end_message = ""

	area_types = list(/area/lavaland/surface/outdoors, /area/lavaland/surface/gulag_rock)
	target_trait = ORE_LEVEL
	probability = 5
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
	. = ..()

/datum/weather/volcano/area_act()
	if(prob(1) && !generated_river && length(levels_by_trait(ORE_LEVEL)))
		generated_river = TRUE
		var/datum/river_spawner/new_river = new /datum/river_spawner(pick(levels_by_trait(ORE_LEVEL)))
		new_river.generate(nodes = 4, ignore_bridges = TRUE, warning = TRUE)
	if(world.time >= next_rubble)
		next_rubble = world.time + rand(3 DECISECONDS, 2 SECONDS)
		for(var/area/lavaland/surface/outdoors/N in GLOB.all_areas)
			if(istype(N, /area/lavaland/surface/outdoors/outpost/no_boulder))
				continue // No hitting the no boulder area
			for(var/turf/simulated/floor/T in N) // dont waste our time hitting walls
				valid_targets += T
		if(isnull(valid_targets)) // prevents a runtime when coding without lavaland enabled. Or theres somehow ZERO turfs.
			return
		var/hits = 0
		var/target
		while(hits <= 150 && length(valid_targets)) //sling a bunch of rocks around the map
			target = pick(valid_targets)
			new /obj/effect/temp_visual/rock_target(target)
			hits++
			valid_targets -= target
		//just play the play from the last hit in the bundle, it reaches across the map anyways
		INVOKE_ASYNC(src, PROC_REF(generate_boom), target)

//lets just fake some booms
/datum/weather/volcano/proc/generate_boom(turf/target)
	sleep(ROCKFALL_DELAY)
	for(var/mob/M in GLOB.player_list)
		var/turf/M_turf = get_turf(M)
		if(isnull(target))
			return
		if(M_turf.z == target.z)
			M.playsound_local(target, 'sound/effects/explosionfar.ogg', 50, 1, get_rand_frequency(), distance_multiplier = 0)
			shake_camera(M, 2, 4)

/obj/effect/temp_visual/rockfall
	icon = 'icons/obj/meteor.dmi'
	icon_state = "clownish" // we shouldnt be seeing this
	name = "Ejected boulder"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	randomdir = FALSE
	pixel_z = 270

/obj/effect/temp_visual/rockfall/Initialize(mapload)
	. = ..()
	icon_state = pick("small","large", "sharp", "dust", "small1", "large1")
	animate(src, pixel_z = 0, time = duration)
	SpinAnimation()

/obj/effect/temp_visual/rock_target
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2

/obj/effect/temp_visual/rock_target/ex_act()
	return

/obj/effect/temp_visual/rock_target/Initialize(mapload)
	. = ..()
	SpinAnimation()
	INVOKE_ASYNC(src, PROC_REF(fall))

/obj/effect/temp_visual/rock_target/proc/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 100, TRUE)
	new /obj/effect/temp_visual/rockfall(T)
	sleep(duration)
	T = get_turf(src)
	var/turf_area = get_area(T)
	if(istype(turf_area, /area/shuttle)) // prevent hitting the shuttle when it moves
		log_debug("A rockfall has somehow struck at [x], [y].")
		qdel(src)
		return
	playsound(T, 'sound/effects/break_stone.ogg', 80, TRUE)
	playsound(T, get_sfx("explosion"), 80, TRUE)
	for(var/mob/living/carbon/human/H in range(10, T))
		shake_camera(H, 3, 8)
	if(T.contents)
		for(var/mob/living/L in T.contents) // dont want to be crushing the hazards
			if(ismegafauna(L))
				L.visible_message("[L.name] easily withstands the hit of the massive rock!")
				return
			else
				L.visible_message("<span class='danger'>[L.name] is crushed under the massive impact of the boulder!</span>", "<span class='userdanger'>You are crushed as a massive weight suddenly descends upon you!</span>", "<span class='danger'>You hear wet splatters as something is hit with a massive object!</span>")
				L.gib()
	if(!islava(T) && !istype(T, /turf/simulated/floor/chasm)) // Splash harmlessly into the lava pools
		for(var/obj/structure/thing in T.contents) // dont cover the tendrils
			if(istype(thing, /obj/structure/spawner/lavaland))
				return
		T.ChangeTurf(/turf/simulated/mineral/random/high_chance/volcanic)




/// MARK: Acid Rain
/datum/weather/acid
	name = "Acidic rain"
	desc = "Emissions of sulfur and carbon into the atmosphere results in the formation of acid particulate in the ashen clouds. Eventually, enough collects that it will fall back down as sulfuric acid rain. NT brand shelter pods capsules are not rated for this level of acid."

	telegraph_message = "<span class='boldwarning'><i>The sound of tiny drops begins to splatter against the ground, sizzling against the ash and stone. Seek shelter.</i></span>"
	telegraph_duration = 600
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Acidic rain begins to pour down in thick sheets, melting rock and flesh alike. Get inside now!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "acid_rain"

	end_message = "<span class='boldannounceic'>The pitter of acidic dropples slows to silence. It should be safe to go outside now.</span>"
	end_overlay = "light_ash"

	area_types = list(/area/lavaland/surface/outdoors, /area/lavaland/surface/gulag_rock)
	target_trait = ORE_LEVEL
	probability = 10
	barometer_predictable = TRUE
	area_act = TRUE
	// how long do you get before it melts a hole?
	var/melt_delay = 5 SECONDS

	var/datum/looping_sound/active_outside_acid/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_acid/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_acid/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_acid/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/acid/update_eligible_areas()
	. = ..()
	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

/datum/weather/acid/update_audio()

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

/datum/weather/acid/area_act()
	if(!length(GLOB.all_shelter_pods)) // don't need to act if there's nothing in the list so we don't runtime
		return
	for(var/turf/current_turf in GLOB.all_shelter_pods)
		if(!is_mining_level(current_turf.z)) // dont want to melt pods on other Z levels
			continue
		if(istype(get_area(current_turf), /area/survivalpod/luxurypod)) // luxury pods are immune to the storm
			continue
		if(prob(2))
			current_turf.visible_message("<span class = 'danger'>The ceiling begins to drip as acid starts eating holes in the roof!</span>", "<span class = 'danger'>You hear droplets hitting the floor as acid leaks in through the roof.</span>")
			addtimer(CALLBACK(src, PROC_REF(melt_pod), current_turf), melt_delay)

/datum/weather/acid/on_shelter_placed(datum/source, turf/center)
	. = ..()
	if(center.z in impacted_z_levels)
		var/area/A = get_area(center)
		inside_areas |= A
		sound_ai.output_atoms |= A
		sound_wi.output_atoms |= A

// lets make some holes!
/datum/weather/acid/proc/melt_pod(turf/melt_this)
	var/area/new_area = GLOB.all_unique_areas[/area/lavaland/surface/outdoors] || new /area/lavaland/surface/outdoors
	for(var/turf/simulated/nearby_turf in RANGE_TURFS(3, melt_this)) // danger, but probably wont make the whole pod unusable unless you're VERY unlucky
		var/area/turf_area = get_area(nearby_turf)
		if(prob(70) && turf_area.type == /area/survivalpod)
			new_area.contents.Add(nearby_turf)
			if(isfloorturf(nearby_turf))
				nearby_turf.break_tile()
			if(iswallturf(nearby_turf))
				nearby_turf.dismantle_wall()
			for(var/obj/machinery/sleeper/survival_pod/pod in nearby_turf.contents)
				pod.visible_message("<span class = 'danger'>The sleeper melts away into a useless heap of junk!</span>", "<span class = 'danger'>You hear something nearby collapse from the acidic rain!</span>")
				pod.Destroy()

	impacted_areas.Cut()
	generate_area_list()
	update_areas()
	update_eligible_areas()

/datum/weather/acid/weather_act(mob/living/carbon/human/target)
	if(!istype(target)) // natural fauna shouldnt be affected by acid rain
		return
	if(!is_acid_proof(target))
		target.adjustFireLoss(2)
		target.adjustBruteLoss(2)

/datum/weather/acid/proc/is_acid_proof(mob/living/carbon/human/target)
	if(isgrey(target) || is_mecha_occupant(target)) // grays and mecha's occupants are immune to acid
		return TRUE
	if(!target.wear_suit || !target.head) // No need to check further if they dont have clothing on
		return FALSE
	if(target.wear_suit.resistance_flags & ACID_PROOF && target.head.resistance_flags & ACID_PROOF) // their clothing is acid proof
		return TRUE

/// MARK: Wind Storm
/datum/weather/wind
	name = "High-velocity wind"
	desc = "High-pressure barometrics in the area have caused a radical change in air pressure, resulting in high-speed winds in the immediate vicinity."

	telegraph_message = "<span class='boldwarning'><i>The wind begins to pick up, whipping against your body with an ominous intensity. Seek shelter.</i></span>"
	telegraph_duration = 600
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>The wind rises into a furious rage, kicking up dirt and ash in its wake. Get inside now!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "wind"

	end_message = "<span class='boldannounceic'>The wind calms into its normal rhythms, dust settling back to the ashen surface. It should be safe to go outside now.</span>"
	end_overlay = "light_ash"

	area_types = list(/area/lavaland/surface/outdoors, /area/lavaland/surface/gulag_rock)
	target_trait = ORE_LEVEL
	probability = 25
	barometer_predictable = TRUE
	var/wind_dir
	var/next_dir_change

	var/datum/looping_sound/active_outside_ashstorm/sound_ao = new(list(), FALSE, TRUE)
	var/datum/looping_sound/active_inside_ashstorm/sound_ai = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_outside_ashstorm/sound_wo = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_inside_ashstorm/sound_wi = new(list(), FALSE, TRUE)

/datum/weather/wind/update_eligible_areas()
	. = ..()
	sound_ao.output_atoms = outside_areas
	sound_ai.output_atoms = inside_areas
	sound_wo.output_atoms = outside_areas
	sound_wi.output_atoms = inside_areas

/datum/weather/wind/update_audio()
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

/datum/weather/wind/on_shelter_placed(datum/source, turf/center)
	. = ..()
	if(center.z in impacted_z_levels)
		var/area/A = get_area(center)
		inside_areas |= A
		sound_ai.output_atoms |= A
		sound_wi.output_atoms |= A

/datum/weather/wind/start() //give it our custom overlay
	custom_overlay = 'icons/effects/tile_effects.dmi'
	wind_dir = pick(GLOB.alldirs)
	overlay_dir = wind_dir
	next_dir_change = world.time + rand(10 SECONDS, 30 SECONDS)
	. = ..()

/datum/weather/wind/wind_down() // back to normal overlay
	custom_overlay = null
	overlay_dir = null
	. = ..()

/datum/weather/wind/weather_act(mob/living/carbon/human/target)
	if(next_dir_change <= world.time)
		next_dir_change = world.time + rand(10 SECONDS, 30 SECONDS)
		wind_dir = pick(GLOB.alldirs)
		overlay_dir = wind_dir
		update_areas()
	if(!istype(target)) // lets not push around lavaland mobs
		return
	if(isturf(target.loc)) // only affected if outside and not dead.
		target.air_push(wind_dir, MOVE_FORCE_NORMAL * 2)

#undef ROCKFALL_DELAY

