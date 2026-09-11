SUBSYSTEM_DEF(bloopers)
	name = "Bloopers"
	init_order = INIT_ORDER_BLOOPERS
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 1
	offline_implications = "You will no longer hear bloopers. Not a big deal, but you may hear complaints about it."

	var/list/mob_queue = list() // Mobs we're processing over. They add themselves to this.

/datum/controller/subsystem/bloopers/fire(resumed)
	for(var/mob/living/char as anything in mob_queue.Copy())
		char.process_bloopers(char)
		if(LAZYLEN(char.blooper_queue) <= 0)
			mob_queue -= char
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/bloopers/proc/queue(mob/living/char)
	if(!mob_queue[char])
		mob_queue[char] = char

/datum/controller/subsystem/bloopers/proc/remove_from_queue(mob/living/char)
	mob_queue -= char
