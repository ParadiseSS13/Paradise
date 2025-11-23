/mob/living/basic/megafauna/bluespace_horror
	name = "bluespace horror"
	desc = "An indescribable creature, mutated from extended exposure to bluespace energies. There is no telling what it once was."
	health = 1500
	maxHealth = 1500
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	icon_state = "bluespace_horror"
	speak_emote = list("emanates")
	melee_attack_cooldown_min = 1 SECONDS
	damage_coeff = list(BRUTE = 0.75, BURN = 1.1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 35
	melee_damage_upper = 45 // It's a megafauna. Don't get hit nerd.
	attack_verb_simple = "strike"
	attack_verb_continuous = "strikes"
	attack_sound = 'sound/magic/ratvar_attack.ogg'
	see_in_dark = 20 // I see you
	pixel_x = -32
	step_type = FOOTSTEP_MOB_HEAVY
	is_ranged = TRUE
	casing_type = /obj/item/ammo_casing/caseless/bluespace_shards
	projectile_sound = 'sound/magic/wand_teleport.ogg'
	ranged_burst_count = 2
	ranged_burst_interval = 0.4
	ranged_cooldown = 1.5 SECONDS
	crusher_loot = list()
	true_spawn = FALSE
	ai_controller = /datum/ai_controller/basic_controller/bluespace_horror
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/bluespace_horror/summon_mobs = BB_HORROR_SUMMON_MOBS_ACTION,
		/datum/action/cooldown/mob_cooldown/bluespace_horror/fireball_fan = BB_HORROR_FIREBALL_FAN_ACTION,
		/datum/action/cooldown/mob_cooldown/bluespace_horror/lifesteal_bolt = BB_HORROR_LIFESTEAL_BOLT_ACTION,
		/datum/action/cooldown/mob_cooldown/bluespace_horror/magic_missile = BB_HORROR_MAGIC_MISSILE_ACTION,
		/datum/action/cooldown/mob_cooldown/bluespace_horror/charge = BB_HORROR_CHARGE_ACTION,
		/datum/action/cooldown/mob_cooldown/bluespace_horror/blink = BB_HORROR_BLINK_ACTION)
	/// Did we do the big attack?
	var/final_burst = FALSE

/mob/living/basic/megafauna/bluespace_horror/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/megafauna/bluespace_horror/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/megafauna/bluespace_horror/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(!isliving(target))
		return ..()
	var/mob/living/L = target
	var/datum/status_effect/stacking/unstable_bluespace_threads/G = L.has_status_effect(STATUS_EFFECT_BLUESPACE_THREADS)
	if(!G)
		L.apply_status_effect(STATUS_EFFECT_BLUESPACE_THREADS, 1, src)
		return ..()
	if(G.add_stacks(stacks_added = 1, attacker = src))
		return ..()

/mob/living/basic/megafauna/bluespace_horror/adjustHealth(amount, updating_health)
	if(mind) // For whatever reason, if a player is in control, we want them in charge of their blinks
		return ..()
	var/datum/action/cooldown/mob_cooldown/bluespace_horror/blink/blink_action = ai_controller.blackboard[BB_HORROR_BLINK_ACTION]
	if(blink_action.IsAvailable())
		ai_controller.queue_behavior(/datum/ai_behavior/horror_blink_dodge, BB_HORROR_BLINK_ACTION)
		return
	. = ..()
	if(health < maxHealth / 3 && !final_burst)
		ai_controller.queue_behavior(/datum/ai_behavior/omega_fireball_fan)
		final_burst = TRUE

/// Proc used for various powers and spells
/mob/living/basic/megafauna/bluespace_horror/proc/shoot_projectile(atom/target_atom, obj/projectile/thing_to_shoot, set_angle)
	var/turf/startloc = get_turf(src)
	var/turf/endloc = get_turf(target_atom)

	if(!startloc || !endloc || endloc == loc)
		return

	var/obj/projectile/P = new thing_to_shoot(startloc)
	P.preparePixelProjectile(endloc, startloc)
	P.firer = src
	P.firer_source_atom = src

	if(isnum(set_angle))
		P.fire(set_angle)
	else
		P.fire()

/// WHen hitting a mob five times, does something random
/mob/living/basic/megafauna/bluespace_horror/proc/instability_correction()
	switch(rand(1,5))
		// ZAP
		if(1)
			var/list/shock_mobs = list()
			for(var/mob/living/C in view(get_turf(src), 5))
				if(isliving(C) && !faction_check_mob(C))
					shock_mobs += C
			if(length(shock_mobs))
				for(var/i in 1 to 3)
					var/mob/living/sucker = pick_n_take(shock_mobs)
					sucker.electrocute_act(rand(5, 25), "instability correction")
					playsound(get_turf(sucker), 'sound/effects/eleczap.ogg', 75, TRUE)
					Beam(sucker, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5)
		// Vwoop!
		if(2)
			var/list/desto_turfs = list()
			for(var/turf/possible in view(get_turf(src), 3))
				if(possible.is_blocked_turf(exclude_mobs = TRUE))
					continue
				if(isspaceturf(possible))
					continue
				desto_turfs += possible
			for(var/mob/living/C in oview(get_turf(src), 3))
				C.forceMove(pick(desto_turfs))
				to_chat(C, "<span class='danger'>You are teleported a short distance!</span>")
				do_sparks(3, TRUE, C)
		// Yoink!
		if(3)
			for(var/mob/living/C in oview(get_turf(src), 5))
				var/dir = get_dir(C.loc, loc)
				var/turf/step = get_step(C, dir)
				C.forceMove(step)
				to_chat(C, "<span class='danger'>You feel a strong force pulling you towards [src]!</span>")

		// Shazam!
		if(4)
			for(var/mob/living/C in oview(get_turf(src), 1))
				shoot_projectile(C, /obj/projectile/magic/lifesteal_bolt)
			playsound(src, 'sound/magic/invoke_general.ogg', 200, TRUE, 2)
		// Kablooey!
		if(5)
			playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
			new /obj/effect/temp_visual/stomp(loc)
			for(var/mob/living/L in range(3, src))
				if(faction_check(faction, L.faction, FALSE))
					continue

				L.visible_message("<span class='danger'>[L] was thrown by [src]!</span>",
				"<span class='userdanger'>You feel a strong force throwing you!</span>",
				"<span class='danger'>You hear a thud.</span>")
				var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, src)))
				L.throw_at(throw_target, 4, 4)
				var/limb_to_hit = L.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
				var/armor = L.run_armor_check(def_zone = limb_to_hit, armor_type = MELEE, armor_penetration_percentage = 50)
				L.apply_damage(20, BRUTE, limb_to_hit, armor)


/obj/item/ammo_casing/caseless/bluespace_shards
	name = "bluespace shards"
	projectile_type = /obj/projectile/magic/bluespace_shards
	fire_sound = 'sound/magic/wand_teleport.ogg'
	pellets = 4
	variance = 90

/obj/projectile/magic/bluespace_shards
	name = "bluespace shard"
	icon_state = "u_laser_alt"
	damage = 20
	damage_type = BRUTE
	nodamage = FALSE

/datum/status_effect/stacking/unstable_bluespace_threads
	id = "unstable_bluespace_threads"
	tick_interval = 5 SECONDS
	stack_threshold = 5
	max_stacks = 5
	reset_ticks_on_stack = TRUE
	var/mob/living/basic/megafauna/bluespace_horror/latest_attacker

/datum/status_effect/stacking/unstable_bluespace_threads/on_creation(mob/living/new_owner, stacks_to_apply, mob/living/attacker)
	. = ..()
	if(.)
		latest_attacker = attacker

/datum/status_effect/stacking/unstable_bluespace_threads/add_stacks(stacks_added, mob/living/attacker)
	. = ..()
	if(.)
		latest_attacker = attacker
	if(stacks != stack_threshold)
		return TRUE

/datum/status_effect/stacking/unstable_bluespace_threads/stacks_consumed_effect()
	addtimer(CALLBACK(latest_attacker, TYPE_PROC_REF(/mob/living/basic/megafauna/bluespace_horror, instability_correction)), 1 SECONDS)

/datum/status_effect/stacking/unstable_bluespace_threads/on_remove()
	latest_attacker = null
