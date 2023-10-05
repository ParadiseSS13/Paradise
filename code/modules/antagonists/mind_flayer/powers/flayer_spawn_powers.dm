/*
 * This is a file with all the flayer powers that spawn mobs.
 * Default mobs will be offered to dchat. If you don't want your mob to be
 * offered to dchat, override the `spawn_the_mob` proc
 *
 */

/obj/effect/proc_holder/spell/flayer/self/summon
	name = "Summon minion"
	desc = "This really shouldn't be here"
	power_type = FLAYER_UNOBTAINABLE_POWER
	base_cooldown = 10 SECONDS
	/// What kind of mob we have to spawn
	var/mob/living/mob_to_spawn
	/// How many of the mobs do we currently have?
	var/list/current_mobs = list()
	/// What is the max amount of mobs we can even spawn?
	var/max_summons = 1
	var/failure_message = "Failed to create a robot!" // TODO: make this message not shit

/obj/effect/proc_holder/spell/flayer/self/summon/cast(list/targets, mob/user)
	if(length(current_mobs) < max_summons)
		check_for_ghosts(user)

/obj/effect/proc_holder/spell/flayer/self/summon/proc/check_for_ghosts(mob/user)
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as the ([mob_to_spawn]) of [user.real_name]?", ROLE_MIND_FLAYER, FALSE, 10 SECONDS, source = src, role_cleanname = "[mob_to_spawn]")
	var/mob/dead/observer/theghost = null

	if(length(candidates))
		theghost = pick(candidates)
		spawn_the_mob(user, theghost.key, mob_to_spawn)
	else
		to_chat(user, "[failure_message]")

/obj/effect/proc_holder/spell/flayer/self/summon/proc/spawn_the_mob(mob/living/user, key, guardian_type)
	var/turf/user_turf = get_turf(user)
	var/mob/living/simple_animal/hostile/flayer/flayerbot = new mob_to_spawn(user_turf)
	current_mobs += flayerbot
	flayerbot.key = key
	to_chat(flayerbot, "You are a [name] bound to serve [user.real_name].") //TODO: make these into one to_chat
	to_chat(flayerbot, "You are capable of manifesting or recalling to your master with verbs in the Guardian tab. You will also find a verb to communicate with them privately there.")
	to_chat(flayerbot, "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself.")
	to_chat(flayerbot, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Guardian)</span>")

//	SSblackbox.record_feedback("tally", "guardian_pick", 1, "[pickedtype]")

/obj/effect/proc_holder/spell/flayer/self/summon/proc/deduct_mob_from_list(mob_to_remove)
	SIGNAL_HANDLER
	current_mobs -= mob_to_remove
