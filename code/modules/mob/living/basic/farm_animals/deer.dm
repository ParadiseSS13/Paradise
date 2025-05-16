/mob/living/basic/deer
	name = "deer"
	desc = "A strong, brave deer."
	icon_state = "deer"
	icon_living = "deer"
	icon_dead = "deer_dead"
	faction = list("neutral", "jungle")
	see_in_dark = 0 //I'm so funny
	butcher_results = list(/obj/item/food/meat = 4)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/deer
	/// Things that will scare us into being stationary. Vehicles are scary to deers because they might have headlights.
	var/static/list/stationary_scary_things = list(
		/obj/vehicle,
		/obj/tgvehicle,
	)

/mob/living/basic/deer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_SHOE)
	var/time_to_freeze_for = (rand(5, 10) SECONDS)
	ai_controller.set_blackboard_key(BB_STATIONARY_SECONDS, time_to_freeze_for)
	ai_controller.set_blackboard_key(BB_STATIONARY_COOLDOWN, (time_to_freeze_for * (rand(3, 5))))
	ai_controller.set_blackboard_key(BB_STATIONARY_TARGETS, typecacheof(stationary_scary_things))
