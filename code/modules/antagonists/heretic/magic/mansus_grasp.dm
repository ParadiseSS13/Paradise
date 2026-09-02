/datum/spell/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "A touch spell that lets you channel the power of the Old Gods through your grip."

	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	clothes_req = FALSE

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT

	hand_path = /obj/item/melee/touch_attack/mansus_fist

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes knockdown, minor bruises, and major stamina damage. \
		It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus"
	inhand_icon_state = "mansus"
	catchphrase = null

/obj/item/melee/touch_attack/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune), \
		time_to_remove = 0.4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(setup_signal)), 0.1 SECONDS)

/obj/item/melee/touch_attack/mansus_fist/proc/setup_signal()
	RegisterSignal(loc, COMSIG_MOB_ALTCLICKON, PROC_REF(on_special_click))

/obj/item/melee/touch_attack/mansus_fist/Destroy()
	UnregisterSignal(loc, COMSIG_MOB_ALTCLICKON)
	return ..()


/*
 * Callback for effect_remover component.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	if(istype(target, /obj/effect/heretic_rune))
		var/obj/effect/heretic_rune/our_target = target
		new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, our_target.greyscale_colours)
	qdel(src)

/obj/item/melee/touch_attack/mansus_fist/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(user == target || blocked_by_antimagic)
		return
	if(!isliving(target))
		return
	else
		if(SEND_SIGNAL(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, target) & COMPONENT_BLOCK_HAND_USE)
			handle_delete(user)
			return

	var/mob/living/living_hit = target
	living_hit.apply_damage(10, BRUTE)
	if(!iscarbon(target))
		handle_delete(user)
		return

	var/mob/living/carbon/carbon_hit = target

	// Cultists are momentarily disoriented by the stunning aura. Enough for both parties to go 'oh shit' but only a mild combat ability.
	// Cultists have an identical effect on their stun hand. The heretic's faster spell charge time is made up for by their lack of teammates.
	if(IS_CULTIST(carbon_hit))
		carbon_hit.Stun(0.5 SECONDS)
		carbon_hit.AdjustConfused(3 SECONDS)
		carbon_hit.AdjustDizzy(3 SECONDS)
		carbon_hit.HereticSlur(30 SECONDS) // This prevents a cultist from calling for help on their mindspeak for 30 seconds. You are on your own.

		var/old_color = carbon_hit.color
		carbon_hit.color = COLOR_CULT_RED
		animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = EASE_IN)
		playsound(carbon_hit, 'sound/effects/curse.ogg', 50, TRUE)

		to_chat(user, SPAN_WARNING("An unholy force intervenes as you grasp [carbon_hit], absorbing most of the effects!"))
		to_chat(carbon_hit, SPAN_WARNING("As [user] grasps you with eldritch forces, your blood magic absorbs most of the effects!"))
		handle_delete(user)
		return

	//This doesn't mute for very long (by default), but does block AI tracking!
	ADD_TRAIT(carbon_hit, TRAIT_AI_UNTRACKABLE, "mansus_grasp")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(callback_remove_trait), carbon_hit, TRAIT_AI_UNTRACKABLE, "mansus_grasp"), 15 SECONDS)
	carbon_hit.HereticSlur(15 SECONDS)
	carbon_hit.Silence(3 SECONDS)
	carbon_hit.KnockDown(5 SECONDS)
	carbon_hit.apply_damage(80, STAMINA)
	handle_delete(user)
	return

/// Called when someone alt clicks with a grasp on something.
/obj/item/melee/touch_attack/mansus_fist/proc/on_special_click(mob/source, atom/target)
	SIGNAL_HANDLER
	if(source.get_int_organ(/obj/item/organ/internal/cyberimp/chest/bluespace_anchor))
		if(!HAS_TRAIT(source, TRAIT_ALLOW_HERETIC_CASTING))
			to_chat(source, SPAN_WARNING("Some anchoring force interfears with your grasp. Perhaps a focus would stabilize it!"))
			return FALSE
	if(!source.Adjacent(target))
		return FALSE
	if(SEND_SIGNAL(source, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, target) & COMPONENT_USE_HAND)
		INVOKE_ASYNC(src, PROC_REF(handle_delete), source)
	return COMSIG_MOB_CANCEL_CLICKON


