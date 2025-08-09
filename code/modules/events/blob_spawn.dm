/datum/event/blob
	name = "Blob"
	announceWhen	= 180
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_DISASTER
	role_weights = list(ASSIGNMENT_SECURITY = 5, ASSIGNMENT_TOTAL = 3, ASSIGNMENT_MEDICAL = 3)
	role_requirements = list(ASSIGNMENT_SECURITY = 3, ASSIGNMENT_TOTAL = 60, ASSIGNMENT_MEDICAL = 4)
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.
	var/list/blob_things = list("cores" = list(), "mice" = 0)

/datum/event/blob/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.major_announcement.Announce("Unknown biological growth detected aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_blob.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Blob")

/datum/event/blob/start()
	INVOKE_ASYNC(src, PROC_REF(make_blob))

/datum/event/blob/process()
	if(!(length(blob_things["cores"]) + blob_things["mice"]))
		return kill()
	return ..()

/datum/event/blob/event_resource_cost()
	var/list/costs = list()
	var/cores = length(blob_things["cores"])
	var/blob_blocks = length(GLOB.blobs)
	var/nodes = length(GLOB.blob_nodes)
	var/blobbernauts = length(GLOB.blob_minions)
	for(var/role in role_requirements)
		cost += list(role = role_requirements[role] / role_requirements[ASSIGNMENT_TOTAL] * (cores * 10 + nodes * 2 + blob_blocks * 0.03 + blobbernauts))

/datum/event/blob/proc/make_blob()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a blob infested mouse?", ROLE_BLOB, TRUE, source = /mob/living/simple_animal/mouse/blobinfected)
	if(!length(candidates))
		return kill()

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning blob mouse. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
	var/obj/vent = pick(vents)
	var/mob/living/simple_animal/mouse/blobinfected/B = new(vent.loc)
	var/mob/M = pick(candidates)
	B.key = M.key
	dust_if_respawnable(M)
	B.mind.special_role = SPECIAL_ROLE_BLOB
	B.forceMove(vent)
	B.add_ventcrawl(vent)
	RegisterSignal(B, COMSIG_BLOB_MOUSE_BURST, PROC_REF(record_core))
	blob_things["mice"]++
	// Mark it on antag HUD
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_BLOB]
	antaghud.join_hud(B.mind.current)
	set_antag_hud(B.mind.current, "hudblob")

	to_chat(B, "<span class='userdanger'>You are now a mouse, infected with blob spores. Find somewhere isolated... before you burst and become the blob! Use ventcrawl (alt-click on vents) to move around.</span>")
	to_chat(B, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Blob)</span>")
	notify_ghosts("Infected Mouse has appeared in [get_area(B)].", source = B, action = NOTIFY_FOLLOW)
	successSpawn = TRUE
	SSevents.biohazards_this_round += BIOHAZARD_BLOB

/datum/event/blob/record_core(atom/source, /obj/structure/blob/core/core)
	SIGNAL_HANDLER // COMSIG_BLOB_MOUSE_BURST
	blob_things["mice--"]
	if(core)
		blob_things["cores"] += list(core)
