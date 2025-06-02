/// Minebot Melee Damage Upgrade
/obj/item/mine_bot_upgrade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	new_attack_chain = TRUE

/obj/item/mine_bot_upgrade/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/mob/living/basic/mining_drone/minebot = target
	if(!istype(minebot))
		return ..()

	upgrade_bot(minebot, user)
	return ITEM_INTERACT_COMPLETE

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/basic/mining_drone/M, mob/user)
	if(M.melee_damage_upper != initial(M.melee_damage_upper))
		to_chat(user, "<span class='warning'>[M] already has a combat upgrade installed!</span>")
		return
	M.melee_damage_lower += 7
	M.melee_damage_upper += 7
	to_chat(user, "<span class='notice'>You upgrade [M]'s combat module.</span>")
	qdel(src)

/// Minebot Health Upgrade
/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/basic/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		to_chat(user, "<span class='warning'>[M] already has a reinforced chassis!</span>")
		return
	M.maxHealth += 45
	M.updatehealth()
	to_chat(user, "<span class='notice'>You upgrade [M]'s chassis.</span>")
	qdel(src)

/// Minebot AI upgrade/sentience potion
/obj/item/slimepotion/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	sentience_type = SENTIENCE_MINEBOT
	origin_tech = "programming=6"
	var/base_health_add = 5 // sentient minebots are penalized for beign sentient; they have their stats reset to normal plus these values
	var/base_damage_add = 1 // this thus disables other minebot upgrades
	var/base_speed_add = 1
	var/base_cooldown_add = 10 // base cooldown isn't reset to normal, it's just added on, since it's not practical to disable the cooldown module

/obj/item/slimepotion/sentience/mining/after_success(mob/living/user, mob/living/simple_animal/SM)
	if(istype(SM, /mob/living/basic/mining_drone))
		var/mob/living/basic/mining_drone/M = SM
		M.maxHealth = initial(M.maxHealth) + base_health_add
		M.melee_damage_lower = initial(M.melee_damage_lower) + base_damage_add
		M.melee_damage_upper = initial(M.melee_damage_upper) + base_damage_add
		if(M.stored_gun)
			M.stored_gun.overheat_time += base_cooldown_add
		if(M.mind)
			M.mind.offstation_role = TRUE
