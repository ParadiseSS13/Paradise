/datum/event/blob
	announceWhen	= 180
	endWhen			= 240
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/blob/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.major_announcement.Announce("Unknown biological growth detected aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_blob.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Blob")

/datum/event/blob/start()
	INVOKE_ASYNC(src, PROC_REF(make_blob))

/datum/event/blob/proc/make_blob()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a blob infested mouse?", ROLE_BLOB, TRUE, source = /mob/living/basic/mouse/blobinfected)
	if(!length(candidates))
		return kill()

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning blob mouse. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
	var/obj/vent = pick(vents)
	var/mob/living/basic/mouse/blobinfected/B = new(vent.loc)
	var/mob/M = pick(candidates)
	B.key = M.key
	dust_if_respawnable(M)
	B.mind.special_role = SPECIAL_ROLE_BLOB
	B.forceMove(vent)
	B.add_ventcrawl(vent)

	// Mark it on antag HUD
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_BLOB]
	antaghud.join_hud(B.mind.current)
	set_antag_hud(B.mind.current, "hudblob")

	to_chat(B, "<span class='userdanger'>You are now a mouse, infected with blob spores. Find somewhere isolated... before you burst and become the blob! Use ventcrawl (alt-click on vents) to move around.</span>")
	to_chat(B, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Blob)</span>")
	notify_ghosts("Infected Mouse has appeared in [get_area(B)].", source = B, action = NOTIFY_FOLLOW)
	successSpawn = TRUE
	SSevents.biohazards_this_round += BIOHAZARD_BLOB
