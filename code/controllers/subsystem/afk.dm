#define AFK_WARNED        1
#define AFK_CRYOD    	  2
#define AFK_ADMINS_WARNED 2

#define AFK_FAST_CRYO_WARN 3
#define AFK_FAST_CRYO_CRYO 5

SUBSYSTEM_DEF(afk)
	name = "AFK Watcher"
	wait = 300
	flags = SS_BACKGROUND
	var/list/afk_players = list() // Associative list. ckey as key and AFK state as value
	var/list/non_cryo_antags = list( \
								SPECIAL_ROLE_ABDUCTOR_AGENT, SPECIAL_ROLE_ABDUCTOR_SCIENTIST, \
								SPECIAL_ROLE_SHADOWLING, SPECIAL_ROLE_WIZARD, SPECIAL_ROLE_WIZARD_APPRENTICE, SPECIAL_ROLE_NUKEOPS)


/datum/controller/subsystem/afk/Initialize()
    if(config.warn_afk_minimum <= 0 || config.auto_cryo_afk <= 0 || config.auto_despawn_afk <= 0)
        flags |= SS_NO_FIRE

/datum/controller/subsystem/afk/fire()
	var/list/toRemove = list()
	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		if(!H.ckey) // Useless non ckey creatures
			continue
		
		var/turf/T 
		// Only players who have a mind
		// No dead, unconcious, restrained, people without jobs, people on other Z levels than the station
		if(!H.client || !H.mind || H.stat || H.restrained() || \
			!H.job || !is_station_level((T = get_turf(H)).z)) // Assign the turf as last. Small optimization
			if(afk_players[H.ckey]) 
				toRemove += H.ckey
			continue
		
		var/mins_afk = round(H.client.inactivity / 600)
		var/afk_warn_min = H.client.prefs.afk_fast_cryo ? AFK_FAST_CRYO_WARN : config.warn_afk_minimum
		if(mins_afk < afk_warn_min)
			if(afk_players[H.ckey])
				toRemove += H.ckey
			continue
		
		var/afk_cryo_min = H.client.prefs.afk_fast_cryo ? AFK_FAST_CRYO_CRYO : config.auto_cryo_afk
		if(!afk_players[H.ckey])
			afk_players[H.ckey] = AFK_WARNED
			warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes. You will be cryod after [afk_cryo_min] total minutes and fully despawned after another [config.auto_despawn_afk] minutes. Please move or click in game if you want to avoid being despawned.</span>")
		else 
			var/area/A = T.loc // Turfs loc is the area
			if(afk_players[H.ckey] == AFK_WARNED)
				if(mins_afk >= afk_cryo_min && A.can_get_auto_cryod)
					if(A.fast_despawn)
						toRemove += H.ckey
						warn(H, "<span class='danger'>You are have been despawned after being AFK for [mins_afk] minutes. You have been despawned instantly due to you being in a secure area.</span>")
						log_admins(H, mins_afk, T, "despawned", "AFK in a fast despawn area")
						force_cryo_human(H)
					else 
						if(can_cryo_antag(H))
							if(cryo_ssd(H))
								afk_players[H.ckey] = AFK_CRYOD
								log_admins(H, mins_afk, T, "put into cryostorage")
								warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes and have been moved to cryostorage. After being AFK for another [config.auto_despawn_afk] minutes you will be fully despawned. Please eject yourself (right click, eject) out of the cryostorage if you want to avoid being despawned.</span>")
						else
							message_admins("[key_name_admin(H)] at ([get_area(T).name] [ADMIN_JMP(T)]) is AFK for [mins_afk] and can't be cryod due to it's antag status: ([H.mind.special_role]).")
							afk_players[H.ckey] = AFK_ADMINS_WARNED
					
			else if(mins_afk >= config.auto_despawn_afk + afk_cryo_min)
				var/obj/machinery/cryopod/P = H.loc
				log_admins(H, mins_afk, T, "despawned")
				warn(H, "<span class='danger'>You are have been despawned after being AFK for [mins_afk] minutes.</span>")
				toRemove += H.ckey
				P.despawn_occupant()
	
	removeFromWatchList(toRemove)

/datum/controller/subsystem/afk/proc/warn(mob/living/carbon/human/H, text)
	to_chat(H, text)
	SEND_SOUND(H, 'sound/effects/adminhelp.ogg')
	if(H.client)
		window_flash(H.client)

/datum/controller/subsystem/afk/proc/can_cryo_antag(mob/living/carbon/human/H)
	return !(H.mind.special_role in non_cryo_antags)

/datum/controller/subsystem/afk/proc/log_admins(mob/living/carbon/human/H, mins_afk,  turf/location, action, info)
	log_admin("[key_name(H)] has been [action] by the AFK Watcher subsystem after being AFK for [mins_afk] minutes.[info ? " Extra info:" + info : ""]")

/datum/controller/subsystem/afk/proc/removeFromWatchList(list/toRemove)
	for(var/C in toRemove)
		for(var/i in 1 to afk_players.len)
			if(afk_players[i] == C)
				afk_players.Cut(i, i + 1)
				break

#undef AFK_WARNED
#undef AFK_CRYOD
#undef AFK_ADMINS_WARNED
#undef AFK_FAST_CRYO_WARN
#undef AFK_FAST_CRYO_CRYO