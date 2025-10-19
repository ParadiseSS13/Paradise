#define HERALD_TRISHOT 1
#define HERALD_DIRECTIONALSHOT 2
#define HERALD_TELESHOT 3
#define HERALD_MIRROR 4

/**
 * # Herald
 *
 * A slow-moving projectile user with a few tricks up it's sleeve.  Less unga-bunga than Colossus, with more cleverness in it's fighting style.
 * As it's health gets lower, the amount of projectiles fired per-attack increases.
 * It's attacks are as follows:
 * - Fires three projectiles in a given direction.
 * - Fires a spread in every cardinal and diagonal direction at once, then does it again after a bit.
 * - Shoots a single, golden bolt.  Wherever it lands, the herald will be teleported to the location.
 * - Spawns a mirror which reflects projectiles directly at the target.
 * Herald is a more concentrated variation of the Colossus fight, having less projectiles overall, but more focused attacks.
 */

/mob/living/simple_animal/hostile/asteroid/elite/herald
	name = "herald"
	desc = "A monstrous beast which fires deadly projectiles at threats and prey."
	icon_state = "herald"
	icon_living = "herald"
	icon_aggro = "herald"
	icon_dead = "herald_dying"
	icon_gib = "syndicate_gib"
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 20
	melee_damage_upper = 20
	armor_penetration_percentage = 50
	light_power = 5
	light_range = 2
	light_color = "#FF0000"
	attacktext = "preaches to"
	attack_sound = 'sound/magic/ratvar_attack.ogg'
	throw_message = "doesn't affect the purity of"
	speed = 2
	move_to_delay = 10
	death_sound = 'sound/misc/demon_dies.ogg'
	deathmessage = "begins to shudder as it becomes transparent..."
	loot_drop = /obj/item/clothing/neck/cloak/herald_cloak
	contains_xeno_organ = TRUE
	ignore_generic_organs = TRUE
	surgery_container = /datum/xenobiology_surgery_container/herald

	attack_action_types = list(/datum/action/innate/elite_attack/herald_trishot,
								/datum/action/innate/elite_attack/herald_directionalshot,
								/datum/action/innate/elite_attack/herald_teleshot,
								/datum/action/innate/elite_attack/herald_mirror)

	var/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/my_mirror = null
	var/is_mirror = FALSE

/mob/living/simple_animal/hostile/asteroid/elite/herald/death()
	. = ..()
	if(!is_mirror)
		addtimer(CALLBACK(src, PROC_REF(become_ghost)), 0.8 SECONDS)
		if(my_mirror)
			QDEL_NULL(my_mirror)


/mob/living/simple_animal/hostile/asteroid/elite/herald/Destroy()
	if(my_mirror)
		QDEL_NULL(my_mirror)
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/become_ghost()
	icon_state = "herald_ghost"

/mob/living/simple_animal/hostile/asteroid/elite/herald/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	. = ..()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)

/datum/action/innate/elite_attack/herald_trishot
	name = "Triple Shot"
	button_icon_state = "herald_trishot"
	chosen_message = "<span class='boldwarning'>You are now firing three shots in your chosen direction.</span>"
	chosen_attack_num = HERALD_TRISHOT

/datum/action/innate/elite_attack/herald_directionalshot
	name = "Circular Shot"
	button_icon_state = "herald_directionalshot"
	chosen_message = "<span class='boldwarning'>You are firing projectiles in all directions.</span>"
	chosen_attack_num = HERALD_DIRECTIONALSHOT

/datum/action/innate/elite_attack/herald_teleshot
	name = "Teleport Shot"
	button_icon_state = "herald_teleshot"
	chosen_message = "<span class='boldwarning'>You will now fire a shot which teleports you where it lands.</span>"
	chosen_attack_num = HERALD_TELESHOT

/datum/action/innate/elite_attack/herald_mirror
	name = "Summon Mirror"
	button_icon_state = "herald_mirror"
	chosen_message = "<span class='boldwarning'>You will spawn a mirror which duplicates your attacks.</span>"
	chosen_attack_num = HERALD_MIRROR

/mob/living/simple_animal/hostile/asteroid/elite/herald/OpenFire()
	if(client)
		switch(chosen_attack)
			if(HERALD_TRISHOT)
				herald_trishot(target)
				my_mirror?.herald_trishot(target)
			if(HERALD_DIRECTIONALSHOT)
				herald_directionalshot()
				my_mirror?.herald_directionalshot()
			if(HERALD_TELESHOT)
				herald_teleshot(target)
				my_mirror?.herald_teleshot(target)
			if(HERALD_MIRROR)
				herald_mirror()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(HERALD_TRISHOT)
			herald_trishot(target)
			my_mirror?.herald_trishot(target)
		if(HERALD_DIRECTIONALSHOT)
			herald_directionalshot()
			my_mirror?.herald_directionalshot()
		if(HERALD_TELESHOT)
			herald_teleshot(target)
			my_mirror?.herald_teleshot(target)
		if(HERALD_MIRROR)
			herald_mirror()

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/shoot_projectile(turf/marker, set_angle, is_teleshot, is_trishot)
	var/turf/startloc = get_turf(src)
	if(!is_teleshot)
		var/obj/item/projectile/H = new /obj/item/projectile/herald(startloc)
		H.preparePixelProjectile(marker, startloc)
		H.firer = src
		H.firer_source_atom = src
		if(target)
			H.original = target
		H.fire(set_angle)
		if(is_trishot)
			shoot_projectile(marker, set_angle + 15, FALSE, FALSE)
			shoot_projectile(marker, set_angle - 15, FALSE, FALSE)
	else
		var/obj/item/projectile/H = new /obj/item/projectile/herald/teleshot(startloc)
		H.preparePixelProjectile(marker, startloc)
		H.firer = src
		H.firer_source_atom = src
		if(target)
			H.original = target
		H.fire(set_angle)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_trishot(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	var/target_turf = get_turf(target)
	var/angle_to_target = get_angle(src, target_turf)
	say("Pray")
	SLEEP_CHECK_DEATH(0.5 SECONDS)// no point blank instant shotgun.
	shoot_projectile(target_turf, angle_to_target, FALSE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(shoot_projectile), target_turf, angle_to_target, FALSE, TRUE), 0.2 SECONDS)
	if(health < maxHealth * 0.5 && !is_mirror)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
		addtimer(CALLBACK(src, PROC_REF(shoot_projectile), target_turf, angle_to_target, FALSE, TRUE), 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(shoot_projectile), target_turf, angle_to_target, FALSE, TRUE), 1.2 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_circleshot(offset)
	var/static/list/directional_shot_angles = list(1, 45, 90, 135, 180, 225, 270, 315) //Trust me, use 1. It really doesn't like zero.
	for(var/i in directional_shot_angles)
		shoot_projectile(get_turf(src), i + offset, FALSE, FALSE)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/unenrage()
	if(stat == DEAD || is_mirror)
		return
	icon_state = "herald"

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_directionalshot()
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	if(!is_mirror)
		icon_state = "herald_enraged"
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(herald_circleshot), 0), 0.5 SECONDS)
	if(health < maxHealth * 0.5 && !is_mirror)
		addtimer(CALLBACK(src, PROC_REF(herald_circleshot), 22.5), 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(unenrage)), 20)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_teleshot(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	var/target_turf = get_turf(target)
	var/angle_to_target = get_angle(src, target_turf)
	shoot_projectile(target_turf, angle_to_target, TRUE, FALSE)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_mirror()
	ranged_cooldown = world.time + 4 SECONDS * revive_multiplier()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	if(my_mirror != null)
		QDEL_NULL(my_mirror)
	var/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/new_mirror = new /mob/living/simple_animal/hostile/asteroid/elite/herald/mirror(loc)
	my_mirror = new_mirror
	my_mirror.my_master = src
	my_mirror.faction = faction.Copy()

/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror
	name = "herald's mirror"
	desc = "This fiendish work of magic copies the herald's attacks. Seems logical to smash it."
	health = 60
	maxHealth = 60
	icon_state = "herald_mirror"
	icon_aggro = "herald_mirror"
	deathmessage = "shatters violently!"
	death_sound = 'sound/effects/glassbr1.ogg'
	del_on_death = TRUE
	is_mirror = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING // no dragging your mirror around
	var/mob/living/simple_animal/hostile/asteroid/elite/herald/my_master = null
	initial_traits = list(TRAIT_FLYING)

/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/Initialize(mapload)
	. = ..()
	toggle_ai(AI_OFF)

/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/Destroy()
	my_master?.my_mirror = null
	my_master = null
	. = ..()

/obj/item/projectile/herald
	name = "death bolt"
	icon_state = "chronobolt"
	damage = 15
	armor_penetration_percentage = 50
	speed = 2

/obj/item/projectile/herald/teleshot
	name = "golden bolt"
	damage = 0
	color = rgb(255,255,102)

/obj/item/projectile/herald/prehit(atom/target)
	if(ismob(target) && ismob(firer))
		var/mob/living/mob_target = target
		if(mob_target.faction_check_mob(firer))
			nodamage = TRUE
			damage = 0
			return
		if(mob_target.buckled && mob_target.stat == DEAD)
			mob_target.dust() //no body cheese

/obj/item/projectile/herald/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismineralturf(target))
		var/turf/simulated/mineral/M = target
		M.gets_drilled()

/obj/item/projectile/herald/teleshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!istype(target, /mob/living/simple_animal/hostile/asteroid/elite/herald))
		firer.forceMove(get_turf(src))


//Herald's loot: Cloak of the Prophet

/obj/item/clothing/neck/cloak/herald_cloak
	name = "cloak of the prophet"
	desc = "A cloak which lts you travel through a perfect reflection of the world."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "herald_cloak"
	actions_types = list(/datum/action/item_action/herald)

/obj/item/clothing/neck/cloak/herald_cloak/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_NECK)
		return TRUE

/obj/item/clothing/neck/cloak/herald_cloak/ui_action_click()
	var/found_mirror = FALSE
	var/list/mirrors_to_use = list()
	var/list/areaindex = list()
	var/obj/starting_mirror = null

	for(var/obj/i in GLOB.mirrors)
		var/turf/T = get_turf(i)
		if(!is_teleport_allowed(i.z))
			continue
		if(T.z != usr.z) //No crossing zlvls
			continue
		if(istype(i, /obj/item/shield/mirror) && !IS_CULTIST(usr)) //No teleporting to cult bases
			continue
		if(istype(i, /obj/structure/mirror))
			var/obj/structure/mirror/B = i
			if(B.broken)
				continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		mirrors_to_use[tmpname] = i
		if(get_dist(src, i) > 1)
			continue
		found_mirror = TRUE
		starting_mirror = i

	if(!found_mirror)
		to_chat(usr, "<span class='warning'>You are not close enough to a working mirror to teleport!</span>")
		return
	var/input_mirror = tgui_input_list(usr, "Choose a mirror to teleport to.", "Mirror to Teleport to", mirrors_to_use)
	var/obj/chosen = mirrors_to_use[input_mirror]
	if(chosen == null)
		return
	usr.visible_message("<span class='warning'>[usr] starts to crawl into [starting_mirror]...</span>", \
			"<span class='notice'>You start to crawl into the [starting_mirror]...</span>")
	if(do_after(usr, 2 SECONDS, target = usr))
		var/turf/destination = get_turf(chosen)
		if(QDELETED(chosen) || !usr|| HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !chosen || (get_dist(src, starting_mirror) > 1 || destination.z != usr.z))
			return
		usr.visible_message("<span class='warning'>[usr] crawls into the [starting_mirror], and [usr.p_they()] disappear into it!</span>", \
			"<span class='notice'>You crawl into the [starting_mirror]...</span>")
		usr.forceMove(destination)
		usr.visible_message("<span class='warning'>[usr] crawls out of [chosen], causing it to shatter!</span>", \
			"<span class='warning'>You crawl out of your own reflection, shattering the mirror!</span>")
		if(istype(chosen, /obj/structure/mirror))
			var/obj/structure/mirror/M = chosen
			M.obj_break("brute")
		else if(istype(chosen, /obj/item/shield/mirror) || istype(chosen, /obj/item/handheld_mirror))
			var/turf/T = get_turf(usr)
			new /obj/effect/temp_visual/cult/sparks(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
			for(var/mob/living/L in T)
				if(L == usr)
					continue
				L.Weaken(6 SECONDS)
			qdel(chosen)

#undef HERALD_TRISHOT
#undef HERALD_DIRECTIONALSHOT
#undef HERALD_TELESHOT
#undef HERALD_MIRROR
