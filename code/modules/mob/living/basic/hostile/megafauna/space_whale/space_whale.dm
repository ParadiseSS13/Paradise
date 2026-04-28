/mob/living/basic/megafauna/space_whale
	name = "space whale"
	desc = "A massive, generally non-hostile, creature swimming on the solar currents and eating space fish for food. Beware threatening them or their kin however."
	health = 1500
	maxHealth = 1500
	icon = 'icons/mob/lavaland/192x192megafauna.dmi'
	icon_state = "space_whale"
	icon_living = "space_whale"
	icon_dead = "space_whale_dead"
	icon_gib = "carp_gib"
	butcher_results = list(/obj/item/food/meat = 30,
		/obj/item/stack/sheet/leather = 30) //In the future might add more unique loot,
	speak_emote = list("calls")
	melee_attack_cooldown_min = 1 SECONDS
	damage_coeff = list(BRUTE = 0.75, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	melee_damage_lower = 35
	melee_damage_upper = 45 // It's a megafauna. Don't get hit nerd.
	attack_verb_simple = "bites"
	attack_verb_continuous = "bites"
	attack_sound = 'sound/effects/bite.ogg'
	see_in_dark = 20 // I see you
	pixel_x = -80
	pixel_y = -96
	faction = list("neutral", "whale")
	step_type = FOOTSTEP_MOB_HEAVY
	true_spawn = FALSE
	ai_controller = /datum/ai_controller/basic_controller/space_whale
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/space_whale/charge = BB_WHALE_CHARGE_ACTION)
	/// Did we do the big attack?
	var/final_burst = FALSE

	/// List of stuff (space fish) that we want to eat
	var/static/list/edibles = list(
		/mob/living/basic/carp,
		/mob/living/basic/carp/megacarp,
		/mob/living/simple_animal/hostile/retaliate/carp,
		/mob/living/simple_animal/hostile/retaliate/carp/koi,
		/mob/living/simple_animal/hostile/retaliate/carp/koi/honk,
	)

/mob/living/basic/megafauna/space_whale/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	AddElement(/datum/element/basic_eating, heal_amt_ = 30, food_types_ = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

/mob/living/basic/megafauna/space_whale/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/megafauna/space_whale/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/megafauna/space_whale/harbringer in oview(src, 7))
		if(harbringer == attacker) // Do not commit suicide attacking yourself
			continue
		harbringer.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)
