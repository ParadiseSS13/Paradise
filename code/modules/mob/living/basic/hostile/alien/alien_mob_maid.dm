/mob/living/basic/alien/maid
	name = "lusty xenomorph maid"
	melee_damage_lower = 0
	melee_damage_upper = 0
	a_intent = INTENT_HELP
	friendly_verb_continuous = "caresses"
	friendly_verb_simple = "caress"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/alien/maid
	icon_state = "maid"
	icon_living = "maid"
	icon_dead = "maid_dead"
	/// How fast do we clean?
	var/cleanspeed = 15

/mob/living/basic/alien/maid/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/// Clean instead of attack.
/mob/living/basic/alien/maid/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE

	clean_target(target)
	return FALSE

/mob/living/basic/alien/maid/proc/clean_target(atom/target)
	if(ishuman(target))
		var/atom/movable/H = target
		H.clean_blood()
		visible_message("<span class='notice'>\The [src] polishes \the [target].</span>")
		return FALSE
	target.cleaning_act(src, src, cleanspeed, text_description = ".") // LXM is both the user and the cleaning implement itself. Wow!

/mob/living/basic/alien/maid/can_clean()
	return TRUE

/mob/living/basic/alien/maid/lavaland
	maximum_survivable_temperature = INFINITY
