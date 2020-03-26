#define AFK_WARNED			1
#define AFK_CRYOD			2
#define AFK_ADMINS_WARNED	3

SUBSYSTEM_DEF(afk)
	name = "AFK Watcher"
	wait = 300
	flags = SS_BACKGROUND
	offline_implications = "Players will no longer be marked as AFK. No immediate action is needed."
	var/list/afk_players = list() // Associative list. ckey as key and AFK state as value
	var/list/non_cryo_antags


/datum/controller/subsystem/afk/Initialize()
	if(config.warn_afk_minimum <= 0 || config.auto_cryo_afk <= 0 || config.auto_despawn_afk <= 0)
		flags |= SS_NO_FIRE
	else
		non_cryo_antags = list(SPECIAL_ROLE_ABDUCTOR_AGENT, SPECIAL_ROLE_ABDUCTOR_SCIENTIST, \
							SPECIAL_ROLE_SHADOWLING, SPECIAL_ROLE_WIZARD, SPECIAL_ROLE_WIZARD_APPRENTICE, SPECIAL_ROLE_NUKEOPS)
	return ..()

/datum/controller/subsystem/afk/fire()
	var/list/toRemove = list()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(!H?.ckey) // Useless non ckey creatures
			continue

		var/turf/T
		// Only players and players with the AFK watch enabled
		// No dead, unconcious, restrained, people without jobs or people on other Z levels than the station
		if(!H.client || !(H.client.prefs.toggles2 & PREFTOGGLE_2_AFKWATCH) || !H.mind || \
			H.stat || H.restrained() || !H.job || !is_station_level((T = get_turf(H)).z)) // Assign the turf as last. Small optimization
			if(afk_players[H.ckey])
				toRemove += H.ckey
			continue

		var/mins_afk = round(H.client.inactivity / 600)
		if(mins_afk < config.warn_afk_minimum)
			if(afk_players[H.ckey])
				toRemove += H.ckey
			continue

		if(!afk_players[H.ckey])
			afk_players[H.ckey] = AFK_WARNED
			warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes. You will be cryod after [config.auto_cryo_afk] total minutes and fully despawned after [config.auto_despawn_afk] total minutes. Please move or click in game if you want to avoid being despawned.</span>")
		else
			var/area/A = T.loc // Turfs loc is the area
			if(afk_players[H.ckey] == AFK_WARNED)
				if(mins_afk >= config.auto_cryo_afk && A.can_get_auto_cryod)
					if(A.fast_despawn)
						toRemove += H.ckey
						warn(H, "<span class='danger'>You have been despawned after being AFK for [mins_afk] minutes. You have been despawned instantly due to you being in a secure area.</span>")
						log_afk_action(H, mins_afk, T, "despawned", "AFK in a fast despawn area")
						force_cryo_human(H)
					else
						if(!(H.mind.special_role in non_cryo_antags))
							if(cryo_ssd(H))
								H.create_log(MISC_LOG, "Put into cryostorage by the AFK subsystem")
								afk_players[H.ckey] = AFK_CRYOD
								log_afk_action(H, mins_afk, T, "put into cryostorage")
								warn(H, "<span class='danger'>You are AFK for [mins_afk] minutes and have been moved to cryostorage. \
									After being AFK for another [config.auto_despawn_afk] minutes you will be fully despawned. \
									Please eject yourself (right click, eject) out of the cryostorage if you want to avoid being despawned.</span>")
						else
							message_admins("[key_name_admin(H)] at ([get_area(T)] [ADMIN_JMP(T)]) is AFK for [mins_afk] and can't be automatically cryod due to it's antag status: ([H.mind.special_role]).")
							afk_players[H.ckey] = AFK_ADMINS_WARNED

			else if(afk_players[H.ckey] != AFK_ADMINS_WARNED && mins_afk >= config.auto_despawn_afk)
				log_afk_action(H, mins_afk, T, "despawned")
				warn(H, "<span class='danger'>You have been despawned after being AFK for [mins_afk] minutes.</span>")
				toRemove += H.ckey
				force_cryo_human(H)

	removeFromWatchList(toRemove)

/datum/controller/subsystem/afk/proc/warn(mob/living/carbon/human/H, text)
	to_chat(H, text)
	SEND_SOUND(H, 'sound/effects/adminhelp.ogg')
	if(H.client)
		window_flash(H.client)

/datum/controller/subsystem/afk/proc/log_afk_action(mob/living/carbon/human/H, mins_afk, turf/location, action, info)
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
