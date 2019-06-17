#define AFK_WARNED       1
#define AFK_CRYOD    	 2

SUBSYSTEM_DEF(afk)
	name = "AFK Watcher"
	wait = 300
	flags = SS_BACKGROUND
	var/list/afk_players = list() // Associative list. client as key and AFK state as value


/datum/controller/subsystem/afk/Initialize()
    if(config.warn_afk_minimum <= 0 || config.auto_cryo_afk <= 0 || config.auto_despawn_afk <= 0)
        flags |= SS_NO_FIRE

/datum/controller/subsystem/afk/fire()
	var/list/toRemove = list()
	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		if(H.client == null || !H.client.prefs.afk_watch || !H.mind) // Only players and players with the AFK watch enabled
			continue
		
		var/turf/T = get_turf(H)
		
		if(H.stat || H.restrained() || !H.job || !is_station_level(T.z) || H.mind.special_role) // No dead, unconcious, restrained, people without jobs, people on other Z levels than the station or antags
			if(afk_players[H.client])
				toRemove += H.client
			continue
		
		var/mins_afk = round(H.client.inactivity / 600)
		if(mins_afk < config.warn_afk_minimum)
			if(afk_players[H.client])
				toRemove += H.client
			continue
		
		if(!afk_players[H.client])
			afk_players[H.client] = AFK_WARNED
			warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes. You will be cryod after [config.auto_cryo_afk] total minutes and fully despawned after [config.auto_despawn_afk] total minutes. Please move or click in game if you want to avoid being despawned.</span>")
		else 
			var/area/A = T.loc // Turfs loc is the area
			if(afk_players[H.client] == AFK_WARNED)
				if(mins_afk >= config.auto_cryo_afk && A.can_get_auto_cryod)
					if(A.fast_despawn)
						toRemove += H.client
						warn(H, "<span class='danger'>You are have been despawned after being AFK for [mins_afk] minutes. You have been despawned instantly due to you being in a secure area.</span>")
						msg_admins(H, mins_afk, T, "forcefully despawned", "AFK in a fast despawn area")
						force_cryo_human(H)
					else if(cryo_ssd(H))
						afk_players[H.client] = AFK_CRYOD
						msg_admins(H, mins_afk, T, "put into cryostorage")
						warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes and have been moved to cryostorage. After being AFK for [config.auto_despawn_afk] total minutes you will be fully despawned. Please eject yourself (right click, eject) out of the cryostorage if you want to avoid being despawned.</span>")
					
			else if(mins_afk >= config.auto_despawn_afk)
				var/obj/machinery/cryopod/P = H.loc
				msg_admins(H, mins_afk, T, "forcefully despawned")
				warn(H, "<span class='danger'>You are have been despawned after being AFK for [mins_afk] minutes.</span>")
				toRemove += H.client
				P.despawn_occupant()
	
	removeFromWatchList(toRemove)

/datum/controller/subsystem/afk/proc/warn(mob/living/carbon/human/H, text)
	to_chat(H, text)
	SEND_SOUND(H, 'sound/effects/adminhelp.ogg')
	if(H.client)
		window_flash(H.client)

/datum/controller/subsystem/afk/proc/msg_admins(mob/living/carbon/human/H, mins_afk,  turf/location, action, info)
	log_admin("[key_name(H)] has been [action] by the AFK Watcher subsystem after being AFK for [mins_afk] minutes.[info ? " Extra info:" + info : ""]")
	message_admins("[key_name_admin(H)] at ([get_area(location).name] [ADMIN_JMP(location)]) has been [action] by the AFK Watcher subsystem after being AFK for [mins_afk] minutes.[info ? " Extra info:" + info : ""]")

/datum/controller/subsystem/afk/proc/removeFromWatchList(list/toRemove)
	for(var/C in toRemove)
		for(var/i in 1 to afk_players.len)
			if(afk_players[i] == C)
				afk_players.Cut(i, i + 1)
				break

#undef AFK_WARNED
#undef AFK_CRYOD