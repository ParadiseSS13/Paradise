/mob/living/basic/mining
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	status_flags = NONE // don't inherit standard basicmob flags
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	faction = list("mining")
	weather_immunities = list("lava","ash")
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	a_intent = INTENT_HARM
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	/// Special loot drops for crushers
	var/crusher_loot
	/// What is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_mod = 25
	/// Alternate icon for mobs that are angry
	var/icon_aggro = null
	/// If we want the mob to have 66% resist from burn damage projectiles
	var/has_laser_resist = TRUE
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message = "bounces off"

/mob/living/basic/mining/bullet_act(obj/item/projectile/P) // Reduces damage from most projectiles to curb off-screen kills
	if(P.damage < 30 && P.damage_type != BRUTE && has_laser_resist)
		P.damage = (P.damage / 3)
		visible_message("<span class='danger'>[P] has a reduced effect on [src]!</span>")
	..()

/mob/living/basic/mining/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) // No floor tiling them to death, wiseguy
	if(isitem(AM))
		var/obj/item/T = AM
		if(T.throwforce <= 20)
			visible_message("<span class='notice'>[T] [throw_blocked_message] [src.name]!</span>")
			return
	..()

/mob/living/basic/mining/death(gibbed)
	var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(C && crusher_loot && prob((C.total_damage/maxHealth) * crusher_drop_mod)) // on average, you'll need to kill 4 creatures before getting the item
		spawn_crusher_loot()
	..(gibbed)

/mob/living/basic/mining/proc/spawn_crusher_loot()
	butcher_results[crusher_loot] = 1
