/*
 * This is a file with all the flayer powers that spawn mobs.
 * Default mobs will be offered to dchat. If you don't want your mob to be
 * offered to dchat, override the `spawn_the_mob` proc
 */


/* Dgamer Note on 20/8 - this code is most likely very bad and should be updated. View at your own sanity's risk */

/datum/spell/flayer/self/summon
	name = "Summon minion"
	desc = "This really shouldn't be here"
	action_icon_state = "artificer"
	power_type = FLAYER_UNOBTAINABLE_POWER
	base_cooldown = 10 SECONDS // This is testing purposes ONLY. If this comment makes it into the TM, something went wrong
	category = CATEGORY_SWARMER
	/// What kind of mob we have to spawn
	var/mob/living/mob_to_spawn
	/// How many of the mobs do we currently have?
	var/list/current_mobs = list()
	/// What is the max amount of mobs we can even spawn?
	var/max_summons = 1
	/// What projectile should our mob fire
	var/projectile_type
	/// How much damage should our melee attacks do
	var/melee_damage
	/// If we want the mobs to do different kinds of damage
	var/damage_type
	/// This var is used to edit the minion's max HP. Defaults to 100
	var/max_mob_hp = 100

/datum/spell/flayer/self/summon/cast(list/targets, mob/user)
	if(length(current_mobs) < max_summons)
		check_for_ghosts(user)
	else
		flayer.send_swarm_message("You have as many robots as you can handle now!")

/datum/spell/flayer/self/summon/proc/check_for_ghosts(mob/user)
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as the ([mob_to_spawn]) of [user.real_name]?", poll_time = 10 SECONDS, source = src, role_cleanname = "[mob_to_spawn]")
	var/mob/dead/observer/theghost

	if(length(candidates))
		theghost = pick(candidates)
		spawn_the_mob(user, theghost.key, mob_to_spawn)
	else
		flayer.send_swarm_message("Failed to create a robot! Try again later.")

/datum/spell/flayer/self/summon/proc/spawn_the_mob(mob/living/user, key, guardian_type)
	var/turf/user_turf = get_turf(user)
	var/mob/living/simple_animal/flayerbot = new mob_to_spawn(user_turf)
	current_mobs += flayerbot
	flayerbot.key = key
	RegisterSignal(flayerbot, COMSIG_MOB_DEATH, TYPE_PROC_REF(/datum/spell/flayer/self/summon, deduct_mob_from_list))
	var/list/msg = list()
	msg += "You are a [name] bound to serve [user.real_name]."
	msg += "You are capable of manifesting or recalling to your master with verbs in the Guardian tab. You will also find a verb to communicate with them privately there."
	msg += "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself."
	msg += "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Guardian)</span>" // TODO: Wikipage???
	to_chat(flayerbot, msg.Join())

//	SSblackbox.record_feedback("tally", "guardian_pick", 1, "[pickedtype]") // TODO: make a tally

/datum/spell/flayer/self/summon/proc/deduct_mob_from_list(gibbed, mob_to_remove)
	SIGNAL_HANDLER
	current_mobs -= mob_to_remove

/*
	* My god this looks like a feverdream, anyways:
	* All mob upgrades are split into 2 upgrade types: ranged or melee. If your power doesn't apply to either the melee or ranged weapon, override it for your power.
	* If you want to do both your special thing and an upgrade to melee/ranged damage, call parent on your own proc.
*/

/datum/spell/flayer/self/summon/on_purchase_upgrade(upgrade_type)
	switch(type)
		if(RANGED_ATTACK_BASE)
			check_which_projectile()
		if(MELEE_ATTACK_BASE)
			check_melee_upgrade()
		else
			check_army_upgrades()
	upgrade_all_mobs()

/datum/spell/flayer/self/summon/proc/check_melee_upgrade()
	switch(level)
		if(POWER_LEVEL_ONE)
			melee_damage += 10 // 20 is at base
		if(POWER_LEVEL_TWO)
			melee_damage += 10
		if(POWER_LEVEL_FOUR)
			damage_type = BRUTE
			max_summons += 1

/datum/spell/flayer/self/summon/proc/check_which_projectile()
	switch(level)
		if(POWER_LEVEL_ONE)
			projectile_type = /obj/item/projectile/beam/disabler
		if(POWER_LEVEL_THREE)
			projectile_type = /obj/item/projectile/beam/laser
		if(POWER_LEVEL_FOUR)
			projectile_type = /obj/item/projectile/energy/charged_plasma // ZZZAP

/datum/spell/flayer/self/summon/proc/check_army_upgrades()
	switch(level)
		if(POWER_LEVEL_TWO)
			max_summons += 1
		if(POWER_LEVEL_THREE)
			max_mob_hp = 200

/datum/spell/flayer/self/summon/proc/upgrade_all_mobs()
	for(var/mob/living/simple_animal/hostile/flayer/flayer_bot in current_mobs)
		flayer_bot.projectiletype = projectile_type
		flayer_bot.melee_damage_lower = melee_damage
		flayer_bot.melee_damage_upper = melee_damage
		if(damage_type)
			flayer_bot.melee_damage_type = damage_type

/*
	* Alright, this is where the actual mindflayer spells come in.
	* - List different bots here
	*
*/

/datum/spell/flayer/self/summon/melee
	name = "Summon melee robot"
	desc = "Summmon a robot powered by the souls of the dead to fight for you!"
	mob_to_spawn = /mob/living/simple_animal/hostile/flayer
	power_type = FLAYER_INNATE_POWER
