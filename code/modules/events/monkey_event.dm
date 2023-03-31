/datum/event/monkey_infestation
	announceWhen	= 400
	endWhen			= 240
	var/spawncount = 3
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/monkey_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/monkey_infestation/announce()
	if(successSpawn)
		GLOB.major_announcement.Announce("Confirmed outbreak of a couple monkeys on [station_name()]. Deal with them, we pay you for this.", "Biohazard Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak3.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Monkey Infestation")

/datum/event/monkey_infestation/start()
	INVOKE_ASYNC(src, PROC_REF(make_monkie))

/datum/event/monkey_infestation/proc/make_monkie()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a monkey?", source = /mob/living/carbon/human/monkey)
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE)
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning monkeys. Force picking from station vents regardless of state!")
		vents = get_valid_vent_spawns(unwelded_only = FALSE, min_network_size = 0)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		spawncount--
		if(C)
			C.remove_from_respawnable_list()
			var/mob/living/carbon/human/monkey/monkey = new(vent.loc)
			monkey.key = C.key
			monkey.forceMove(vent)
			monkey.add_ventcrawl(vent)
			ADD_TRAIT(monkey, TRAIT_HAS_MONKEY_VIRUS, "Monkey virus")
			to_chat(monkey, "<span class='userdanger'>You are an infected monkey! The touch of your hairy hands can infect anyone, and using your harm intent bite on people will cause them to turn to your side quicker.</span>")

			successSpawn = TRUE
