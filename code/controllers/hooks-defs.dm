/**
 * Roundstart hook.
 * Called in gameticker.dm when a round starts.
 */
/hook/roundstart

/**
 * Captain spawned hook.
 * Called in supervisor.dm when a captain spawns
 * Parameters: var/mob/living/carbon/human/captain
 */
/hook/captain_spawned

/**
 * Mob login hook.
 * Called in login.dm when a player logs in to a mob.
 * Parameters: var/client/client, var/mob/mob
 */
/hook/mob_login

 /**
 * Mob logout hook.
 * Called in logout.dm when a player logs out of a mob.
 * Parameters: var/client/client, var/mob/mob
 */
/hook/mob_logout
