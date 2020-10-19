//Sound environment defines. Reverb preset for sounds played in an area, see sound datum reference for more.
#define GENERIC 0
#define PADDED_CELL 1
#define ROOM 2
#define BATHROOM 3
#define LIVINGROOM 4
#define STONEROOM 5
#define AUDITORIUM 6
#define CONCERT_HALL 7
#define CAVE 8
#define ARENA 9
#define HANGAR 10
#define CARPETED_HALLWAY 11
#define HALLWAY 12
#define STONE_CORRIDOR 13
#define ALLEY 14
#define FOREST 15
#define CITY 16
#define MOUNTAINS 17
#define QUARRY 18
#define PLAIN 19
#define PARKING_LOT 20
#define SEWER_PIPE 21
#define UNDERWATER 22
#define DRUGGED 23
#define WOOZY 24
#define PSYCHOTIC 25

#define STANDARD_STATION STONEROOM
#define LARGE_ENCLOSED HANGAR
#define SMALL_ENCLOSED BATHROOM
#define TUNNEL_ENCLOSED CAVE
#define LARGE_SOFTFLOOR CARPETED_HALLWAY
#define MEDIUM_SOFTFLOOR LIVINGROOM
#define SMALL_SOFTFLOOR ROOM
#define ASTEROID CAVE
#define SPACE UNDERWATER

/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, is_global = null)
	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/turf/turf_source = get_turf(source)
	if(!turf_source)
		return
	if(!SSsounds.channel_list) // Not ready yet
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/sound/S = sound(get_sfx(soundin))
	var/maxdistance = (world.view + extrarange) * 3
	var/list/listeners = GLOB.player_list
	if(!ignore_walls) //these sounds don't carry through walls
		listeners = listeners & hearers(maxdistance, turf_source)
	for(var/P in listeners)
		var/mob/M = P
		if(!M || !M.client)
			continue

		var/turf/T = get_turf(M) // These checks need to be changed if z-levels are ever further refactored
		if(!T)
			continue
		if(T.z != turf_source.z)
			continue

		var/distance = get_dist(M, turf_source)

		if(distance <= maxdistance)
			M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, pressure_affected, S, is_global)

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE, sound/S, distance_multiplier = 1, is_global)
	if(!client || !can_hear())
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0 //No queue
	S.channel = channel || SSsounds.random_available_channel()
	S.volume = vol
	S.environment = -1

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	var/pressure_factor = 1.0
	if(isturf(turf_source))
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)
		distance *= distance_multiplier

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		if(pressure_affected)
			//Atmosphere affects sound
			var/datum/gas_mixture/hearer_env = T.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			S.volume *= pressure_factor
			//End Atmosphere affecting sound

		if(S.volume <= 0)
			return //No sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx * distance_multiplier
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz * distance_multiplier
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

		if(S.file == 'sound/goonstation/voice/howl.ogg' && distance > 0 && S.volume > 60 && isvulpkanin(src))
			addtimer(CALLBACK(src, /mob/.proc/emote, "howl"), rand(10,30)) // Vulps cant resist! >)

	if(!is_global)
		if(istype(src,/mob/living/))
			var/mob/living/carbon/M = src
//			if (istype(M) && M.hallucination_power > 50 && M.chem_effects[CE_MIND] < 1)
//				S.environment = PSYCHOTIC
//			else if (M.druggy)
			if (M.druggy)
				S.environment = DRUGGED
			else if (M.drowsyness)
				S.environment = WOOZY
			else if (M.confused)
				S.environment = WOOZY
			else if (M.stat == UNCONSCIOUS)
				S.environment = UNDERWATER
			else if (pressure_factor < 0.5)
				S.environment = SPACE
			else
				var/area/A = get_area(src)
				S.environment = A.sound_env

		else if (pressure_factor < 0.5)
			S.environment = SPACE
		else
			var/area/A = get_area(src)
			S.environment = A.sound_env
	else
		S.environment = PADDED_CELL

	SEND_SOUND(src, S)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, falloff = FALSE, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, falloff, channel, pressure_affected, S)

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/playtitlemusic()
	if(!SSticker || !SSticker.login_music || config.disable_lobby_music)
		return
	if(prefs.sound & SOUND_LOBBY)
		var/sound/S = sound(SSticker.login_music, repeat = 0, wait = 0, volume = 35, channel = CHANNEL_LOBBYMUSIC)
		S.environment = PADDED_CELL
		SEND_SOUND(src, S) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if("shatter")
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if("explosion")
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if("sparks")
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if("rustle")
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if("bodyfall")
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if("punch")
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if("clownstep")
				soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if("jackboot")
				soundin = pick('sound/effects/jackboot1.ogg','sound/effects/jackboot2.ogg')
			if("swing_hit")
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if("hiss")
				soundin = pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
			if("pageturn")
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if("gunshot")
				soundin = pick('sound/weapons/gunshots/gunshot.ogg', 'sound/weapons/gunshots/gunshot2.ogg','sound/weapons/gunshots/gunshot3.ogg','sound/weapons/gunshots/gunshot4.ogg')
			if("casingdrop")
				soundin = pick('sound/weapons/gun_interactions/casingfall1.ogg', 'sound/weapons/gun_interactions/casingfall2.ogg', 'sound/weapons/gun_interactions/casingfall3.ogg')
			if("computer_ambience")
				soundin = pick('sound/goonstation/machines/ambicomp1.ogg', 'sound/goonstation/machines/ambicomp2.ogg', 'sound/goonstation/machines/ambicomp3.ogg')
			if("ricochet")
				soundin = pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg','sound/weapons/effects/ric3.ogg','sound/weapons/effects/ric4.ogg','sound/weapons/effects/ric5.ogg')
			if("terminal_type")
				soundin = pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg',
							  'sound/machines/terminal_button04.ogg', 'sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg',
							  'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg')
			if("growls")
				soundin = pick('sound/goonstation/voice/growl1.ogg', 'sound/goonstation/voice/growl2.ogg', 'sound/goonstation/voice/growl3.ogg')

			if("bonebreak")
				soundin = pick('sound/effects/bone_break_1.ogg', 'sound/effects/bone_break_2.ogg', 'sound/effects/bone_break_3.ogg', 'sound/effects/bone_break_4.ogg', 'sound/effects/bone_break_5.ogg', 'sound/effects/bone_break_6.ogg')
			if("honkbot_e")
				soundin = pick('sound/items/bikehorn.ogg', 'sound/items/AirHorn2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/items/AirHorn.ogg', 'sound/items/WEEOO1.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bcreep.ogg','sound/magic/Fireball.ogg' ,'sound/effects/pray.ogg', 'sound/voice/hiss1.ogg','sound/machines/buzz-sigh.ogg', 'sound/machines/ping.ogg', 'sound/weapons/flashbang.ogg', 'sound/weapons/bladeslice.ogg')
	return soundin
