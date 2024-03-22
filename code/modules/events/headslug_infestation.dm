#define PLAYER_NEED 40
#define GAMEMODE_IS_SHADOWLING (SSticker && istype(SSticker.mode, /datum/game_mode/shadowling))
#define GAMEMODE_IS_CULTS (SSticker && (istype(SSticker.mode, /datum/game_mode/cult))

/datum/event/headslug_infestation
	announceWhen = 300
	var/spawncount
	var/successSpawn = FALSE

/datum/event/headslug_infestation/setup()
	spawncount = round(length(GLOB.clients) / 20)
	announceWhen = rand(announceWhen, announceWhen + 100)
	if(spawncount < 1)
		spawncount = 1

/datum/event/headslug_infestation/announce()
	if(successSpawn)
		GLOB.minor_announcement.Announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Headslug Infestation event")

/datum/event/headslug_infestation/start()
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))

/datum/event/headslug_infestation/proc/wrappedstart()
	if(length(GLOB.clients) < PLAYER_NEED || GAMEMODE_IS_CULTS || GAMEMODE_IS_NUCLEAR || GAMEMODE_IS_SHADOWLING)
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + (40 * 10)
		return

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Headslug?", ROLE_CHANGELING, TRUE, source = /mob/living/simple_animal/hostile/headslug)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			var/mob/living/simple_animal/hostile/headslug/new_slug = new(vent.loc)
			new_slug.key = C.key
			new_slug.origin = C.mind
			C.mind.transfer_to(new_slug)
			C.mind.assigned_role = SPECIAL_ROLE_HEADSLUG
			C.mind.special_role = SPECIAL_ROLE_HEADSLUG
			new_slug.evented = TRUE
			to_chat(new_slug, "<b><font size=3><span class='changeling'>We are a headslug.</font><br></b></span>")
			to_chat(new_slug,"<span class='changeling'><font size=2>Our eggs can be laid in any dead humanoid. Use <B>Alt-Click</B> on the valid mob.</span></font>")
			to_chat(new_slug,"<span class='changeling'>After this, we shall turn into our true form.</span>")
			SEND_SOUND(new_slug, sound('sound/ambience/antag/ling_alert.ogg'))
			spawncount--
			successSpawn = TRUE
			log_game("[new_slug.key] has become Changeling Headslug.")

#undef GAMEMODE_IS_CULTS
#undef GAMEMODE_IS_SHADOWLING
#undef PLAYER_NEED
