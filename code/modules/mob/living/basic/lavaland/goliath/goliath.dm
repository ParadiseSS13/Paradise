/// A slow but strong beast that tries to stun using its tentacles.
/mob/living/basic/mining/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensnare its prey, threatening them is not advised under any conditions."
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	icon_gib = "syndicate_gib"
	speak_emote = list("bellows")
	speed = 5
	maxHealth = 300
	health = 300
	harm_intent_damage = 1 // Only the manliest of men can kill a Goliath with only their fists.
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_simple = "pulverize"
	attack_verb_continuous = "pulverizes"
	throw_blocked_message = "does nothing to the rocky hide of the"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	ai_controller = /datum/ai_controller/basic_controller/goliath
	faction = list("mining")
	butcher_results = list(
		/obj/item/food/monstermeat/goliath = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 1,
		/obj/item/stack/sheet/bone = 2,
	)

	/// Icon state to use when tentacles are available
	var/tentacle_warning_state = "goliath2"
	/// Slight cooldown to prevent double-dipping if we use both abilities at once
	COOLDOWN_DECLARE(ability_animation_cooldown)
	/// Our base tentacles ability
	var/datum/action/cooldown/mob_cooldown/goliath_tentacles/tentacles
	/// Things we want to eat off the floor (or a plate, we're not picky)
	var/static/list/goliath_foods = list(
		/obj/item/food/grown/ash_flora,
	)


/mob/living/basic/mining/goliath/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_TENTACLE_IMMUNE, INNATE_TRAIT)

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/basic_eating, heal_amt_ = 10, food_types_ = goliath_foods)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HEAVY)

	tentacles = new(src)
	tentacles.Grant(src)

	tentacles_ready()
	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(used_ability))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(goliath_foods))
	ai_controller.set_blackboard_key(BB_GOLIATH_TENTACLES, tentacles)

/// Called slightly before tentacles ability comes off cooldown, as a warning
/mob/living/basic/mining/goliath/proc/tentacles_ready()
	if(stat == DEAD)
		return
	icon_state = tentacle_warning_state

/// When we use an ability, activate some kind of visual tell
/mob/living/basic/mining/goliath/proc/used_ability(mob/living/source, datum/action/cooldown/ability)
	SIGNAL_HANDLER
	if(stat == DEAD || ability.IsAvailable())
		return // We died or the action failed for some reason like being out of range
	if(istype(ability, /datum/action/cooldown/mob_cooldown/goliath_tentacles))
		if(ability.cooldown_time <= 2 SECONDS)
			return
		icon_state = icon_living
		addtimer(CALLBACK(src, PROC_REF(tentacles_ready)), ability.cooldown_time - 2 SECONDS, TIMER_DELETE_ME)
		return
	if(!COOLDOWN_FINISHED(src, ability_animation_cooldown))
		return
	COOLDOWN_START(src, ability_animation_cooldown, 2 SECONDS)
	Shake(1, 0, 1.5 SECONDS)

/mob/living/basic/mining/goliath/Destroy()
	. = ..()
	QDEL_NULL(tentacles)

/mob/living/basic/mining/goliath/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	..(gibbed)

/mob/living/basic/mining/goliath/ancient
	name = "ancient goliath"
	desc = "Goliaths are biologically immortal, and rare specimens have survived for centuries. This one is clearly ancient, and its tentacles constantly churn the earth around it."
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_dead = "Goliath_dead"
	maxHealth = 400
	health = 400
	speed = 4
	tentacle_warning_state = "Goliath_preattack"
	butcher_results = list(
		/obj/item/food/monstermeat/goliath = 2,
		/obj/item/stack/sheet/bone = 2,
	)
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide)
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle/ancient
	crusher_drop_mod = 100 //These things are rare (1/100 per spawner). You shouldn't have to hope for another stroke of luck to get it's trophy after finding it
	/// Don't re-check nearby turfs for this long
	COOLDOWN_DECLARE(retarget_turfs_cooldown)
	/// List of places we might spawn a tentacle, if we're alive
	var/list/tentacle_target_turfs

/mob/living/basic/mining/goliath/ancient/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!. || !isturf(loc))
		return
	if(!LAZYLEN(tentacle_target_turfs) || COOLDOWN_FINISHED(src, retarget_turfs_cooldown))
		cache_nearby_turfs()
	for(var/turf/target_turf in tentacle_target_turfs)
		if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
			tentacle_target_turfs -= target_turf
			continue
		if(prob(10))
			new /obj/effect/temp_visual/goliath_tentacle(target_turf)

/mob/living/basic/mining/goliath/ancient/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(loc == old_loc || stat == DEAD || !isturf(loc))
		return
	cache_nearby_turfs()

/// Store nearby turfs in our list so we can pop them out later
/mob/living/basic/mining/goliath/ancient/proc/cache_nearby_turfs()
	COOLDOWN_START(src, retarget_turfs_cooldown, 10 SECONDS)
	LAZYCLEARLIST(tentacle_target_turfs)
	for(var/turf/T in orange(4, loc))
		if(isfloorturf(T))
			LAZYADD(tentacle_target_turfs, T)

/mob/living/basic/mining/goliath/space

/mob/living/basic/mining/goliath/space/Process_Spacemove(movement_dir, continuous_move)
	return TRUE
