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
		if(H.client == null)
			continue
		if(H.stat == DEAD && H.job) // No clientless or dead
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
		else if(afk_players[H.client] == AFK_WARNED)
			if(mins_afk >= config.auto_cryo_afk && cryo_ssd(H))
				afk_players[H.client] = AFK_CRYOD
				warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes and have been moved to cryostorage. After being AFK for [config.auto_despawn_afk] total minutes you will be fully despawned. Please move out of cryostorage if you want to avoid being despawned.</span>")
		else
			if(mins_afk >= config.auto_despawn_afk)
				var/obj/machinery/cryopod/P = H.loc
				warn(H, "<span class='danger'>You are have been despawned after being AFK for [mins_afk] minutes.</span>")
				P.despawn_occupant()
				toRemove += H.client
	
	removeFromWatchList(toRemove)

/datum/controller/subsystem/afk/proc/warn(mob/living/carbon/human/H, text)
	to_chat(H, text)
	SEND_SOUND(H, 'sound/effects/adminhelp.ogg')
	if(H.client)
		window_flash(H.client)

/datum/controller/subsystem/afk/proc/removeFromWatchList(list/toRemove)
	for(var/C in toRemove)
		for(var/i in 1 to afk_players.len)
			if(afk_players[i] == C)
				afk_players.Cut(i, i + 1)
				break

#undef AFK_WARNED
#undef AFK_CRYOD