/datum/spell/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "A touch spell that lets you channel the power of the Old Gods through your grip."

	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	base_cooldown = 10 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/mansus_fist

/obj/item/melee/touch_attack/mansus_fist/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target))
		SEND_SIGNAL(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, target)
		return

	if(SEND_SIGNAL(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, target) & COMPONENT_BLOCK_HAND_USE)
		return

	var/mob/living/living_hit = target
	living_hit.apply_damage(10, BRUTE)
	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_hit = target

	// Cultists are momentarily disoriented by the stunning aura. Enough for both parties to go 'oh shit' but only a mild combat ability.
	// Cultists have an identical effect on their stun hand. The heretic's faster spell charge time is made up for by their lack of teammates.
	if(IS_CULTIST(carbon_hit))
		carbon_hit.KnockDown(0.5 SECONDS)
		carbon_hit.AdjustConfused(3 SECONDS)
		carbon_hit.AdjustDizzy(3 SECONDS)

		var/old_color = carbon_hit.color
		carbon_hit.color = COLOR_CULT_RED
		animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = EASE_IN)
		playsound(carbon_hit, 'sound/effects/curse.ogg', 50, TRUE)

		to_chat(user, "<span class='warning'>An unholy force intervenes as you grasp [carbon_hit], absorbing most of the effects!</span>")
		to_chat(carbon_hit, "<span class='warning'>As [user] grasps you with eldritch forces, your blood magic absorbs most of the effects!</span>")
		return TRUE

	carbon_hit.HereticSlur(15 SECONDS)
	carbon_hit.KnockDown(5 SECONDS)
	carbon_hit.adjustStaminaLoss(80)
	//qwertodo: some status effect to do the last 20

	return TRUE

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes knockdown, minor bruises, and major stamina damage. \
		It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus"
	item_state = "mansus"

/obj/item/melee/touch_attack/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune), \
		time_to_remove = 0.4 SECONDS)

/*
 * Callback for effect_remover component.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	//new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target.greyscale_colors)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc)
	qdel(src)

