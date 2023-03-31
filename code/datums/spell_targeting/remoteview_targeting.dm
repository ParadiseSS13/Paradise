/**
 * A spell targeting system which will return one user picked target from all alive mobs who have the remoteview block but do not have the psyresist block active.
 */
/datum/spell_targeting/remoteview

/datum/spell_targeting/remoteview/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	var/list/remoteviewers = list()
	for(var/mob/M in GLOB.alive_mob_list)
		if(M == user)
			continue
		if(M.dna?.GetSEState(GLOB.psyresistblock))
			continue
		if(M.dna?.GetSEState(GLOB.remoteviewblock))
			remoteviewers += M

	if(!length(remoteviewers))
		return

	var/mob/target = input("Choose the target to spy on.", "Targeting") as null|anything in remoteviewers

	if(QDELETED(target))
		return

	return list(target)
