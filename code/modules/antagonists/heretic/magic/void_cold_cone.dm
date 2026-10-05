/datum/spell/cone/staggered/cone_of_cold
	name = "Cone of Cold"
	desc = "Shoots out a freezing cone in front of you."

	base_cooldown = 30 SECONDS
	cooldown_min = 14 SECONDS

	invocation = "ISAGE!" // What killed the dinosaurs? THE ICE AGE
	invocation_type = INVOCATION_SHOUT

	cone_levels = 4
	delay_between_level = 0.05 SECONDS

	/// What flags do we pass to MakeSlippery when affecting turfs?
	/// null / NONE / TURF_DRY means the turf is unaffected
	var/turf_freeze_type = TURF_WET_PERMAFROST
	/// How long do turfs remain slippery / frozen for?
	/// 0 seconds means the turf is unaffected, INFINITY means it's made perma-wet
	var/unfreeze_turf_duration = 45 SECONDS

	/// What status effect do we apply when affecting mobs?
	/// null means no status effect is applied
	var/datum/status_effect/frozen_status_effect_path = /datum/status_effect/freon
	/// How long do mobs remain frozen for?
	/// 0 seconds means no status effect is applied, INFINITY means infinite duration (or default duration of the status effect)
	var/unfreeze_mob_duration = 20 SECONDS
	/// How much brute do we apply on freeze?
	var/on_freeze_brute_damage = 10
	/// How much burn do we apply on freeze?
	var/on_freeze_burn_damage = 20

	/// How long do objects remain frozen for?
	/// 0 seconds mean no objects are frozen, INFINITY means infinite duration freeze
	var/unfreeze_object_duration = 20 SECONDS



/datum/spell/cone/staggered/cone_of_cold/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	if(!turf_freeze_type || unfreeze_turf_duration <= 0 SECONDS) // 0 duration = don't apply the slip
		return
	if(!isfloorturf(target_turf))
		return
	var/turf/simulated/frozen_floor = target_turf
	frozen_floor.MakeSlippery(turf_freeze_type, unfreeze_turf_duration)

/datum/spell/cone/staggered/cone_of_cold/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(target_mob.can_block_magic(antimagic_flags) || target_mob == caster || HAS_TRAIT(target_mob, TRAIT_RESISTCOLD))
		return

	if(ispath(frozen_status_effect_path) && unfreeze_mob_duration > 0 SECONDS) // 0 duration = don't apply the status effect
		var/datum/status_effect/freeze = target_mob.apply_status_effect(frozen_status_effect_path)
		if(unfreeze_mob_duration != INFINITY)
			freeze.duration = world.time + unfreeze_mob_duration

	if(on_freeze_brute_damage || on_freeze_burn_damage)
		target_mob.take_overall_damage(on_freeze_brute_damage, on_freeze_burn_damage)

	to_chat(target_mob, SPAN_USERDANGER("You feel a bitter cold!"))



/datum/spell/cone/staggered/cone_of_cold/void
	name = "Void Blast"
	desc = "Fires a cone of chilling void in front of you, freezing everything in its path. \
		Enemies in the cone of the blast will be damaged slightly, slowed, and chilled overtime. \
		Additionally, objects hit will be frozen and can shatter, and ground hit will be iced over and slippery - \
		though they may thaw shortly if used in room temperature."


	action_icon_state = "icebeam"

	is_a_heretic_spell = TRUE
	clothes_req = FALSE

	invocation = "FR'ZE!"

	//In room temperature, the ice won't last very long
	//...but in space / freezing rooms, it will stick around
	turf_freeze_type = TURF_WET_ICE
	unfreeze_turf_duration = 1 MINUTES
	// Applies an "infinite" version of basic void chill
	// (This stacks with mansus grasp's void chill)
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting
	unfreeze_mob_duration = 30 SECONDS
	// Does a smidge of damage
	on_freeze_brute_damage = 12
	on_freeze_burn_damage = 10
	// Also freezes stuff (Which will likely be unfrozen similarly to turfs)
	unfreeze_object_duration = 30 SECONDS

/datum/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()
