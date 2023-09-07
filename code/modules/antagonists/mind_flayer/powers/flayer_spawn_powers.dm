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

/obj/effect/proc_holder/spell/flayer/self/summon/caast(list/targets, mob/user)
	if(length(current_mobs) < max_summons)
		spawn_the_mob

/obj/effect/proc_holder/spell/flayer/summon/proc/spawn_the_mob()
	var/turf/spawn_turf = get_turf
	var/mob/living/L = new mob_to_spawn(spawn_turf)
	current_mobs += L
