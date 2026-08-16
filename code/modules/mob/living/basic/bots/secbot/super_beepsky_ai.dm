/datum/ai_controller/basic_controller/bot/secbot/super_beepsky

	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/simple_find_target/target_allies,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)

/datum/ai_controller/basic_controller/bot/secbot/super_beepsky/on_target_set()
	. = ..()
	var/mob/living/basic/bot/secbot/griefsky/super_beeps = pawn
	if(!super_beeps.sword_active)
		super_beeps.on_weapon_transform()
	super_beeps.visible_message("<b>[super_beeps]</b> points at [blackboard[BB_BASIC_MOB_CURRENT_TARGET]]!")
