/datum/spell/touch/flesh_surgery
	name = "Knit Flesh"
	desc = "A touch spell that allows you to either harvest or restore flesh of target. \
		Left-clicking will extract the organs of a victim without needing to complete surgery or disembowel. \
		If cast on summons or minions, will restore health. Can also be used to heal damaged organs."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mad_touch"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = null

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS
	invocation = "CL'M M'N!" // "CLAIM MINE", but also almost "KALI MA"
	invocation_type = INVOCATION_SHOUT

	hand_path = /obj/item/melee/touch_attack/flesh_surgery

/obj/item/melee/touch_attack/flesh_surgery/after_attack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || blocked_by_antimagic || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //There are better ways to get a good nights sleep in a bed.
		return
	if(is_organ(target))
		heal_organ(src, target, user)
		handle_delete(user)
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(IS_HERETIC_MONSTER(living_target))
		heal_heretic_monster(src, living_target, user)
		handle_delete(user)
		return
	if(iscarbon(living_target))
		steal_organ_from_mob(src, living_target, user)
		handle_delete(user)
		return

/// If cast on an organ, we'll restore its health and even un-fail it.
/obj/item/melee/touch_attack/flesh_surgery/proc/heal_organ(obj/item/melee/touch_attack/hand, obj/item/organ/to_heal, mob/living/carbon/caster)
	if(to_heal.damage == 0 && to_heal.germ_level >= 100)
		to_chat(caster, SPAN_NOTICE("The organ is already in good condition!"))
		return FALSE
	to_chat(caster, SPAN_NOTICE("You begin to heal the organ..."))
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = list(CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster))))
		to_chat(caster, SPAN_WARNING("You were interupted!"))
		return FALSE
	to_heal.germ_level = 0
	var/organ_hp_to_heal = to_heal.max_damage * organ_percent_healing
	to_heal.damage = (max(0 , to_heal.damage - organ_hp_to_heal))
	to_heal.surgeryize()
	if(to_heal.is_robotic())	//Robotic organs stay robotic.
		to_heal.status = ORGAN_ROBOT
	else
		to_heal.status = 0
	to_chat(caster, SPAN_NOTICE("The organ is has been healed."))
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	var/condition = (to_heal.damage > 0) ? "better" : "perfect"
	caster.visible_message(
		SPAN_WARNING("[caster]'s hand glows a brilliant red as [caster.p_they()] restore \the [to_heal] to [condition] condition!"),
		SPAN_NOTICE("Your hand glows a brilliant red as you restore \the [to_heal] to [condition] condition!"),
	)

	return TRUE

/// If cast on a heretic monster who's not dead we'll heal it a bit.
/obj/item/melee/touch_attack/flesh_surgery/proc/heal_heretic_monster(obj/item/melee/touch_attack/hand, mob/living/to_heal, mob/living/carbon/caster)
	var/what_are_we = ishuman(to_heal) ? "minion" : "summon"
	to_chat(caster, SPAN_NOTICE("You begin to heal your [what_are_we]..."))
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = list(CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster))))
		to_chat(caster, SPAN_WARNING("You were interupted!"))
		return FALSE

	// Keep in mind that, for simplemobs(summons), this will just flat heal the combined value of both brute and burn healing,
	// while for human minions(ghouls), this will heal brute and burn like normal. So be careful adjusting to bigger numbers
	to_heal.heal_overall_damage(monster_brute_healing, monster_burn_healing)
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		SPAN_WARNING("[caster]'s hand glows a brilliant red as [caster.p_they()] restore[caster.p_s()] [to_heal] to good condition!"),
		SPAN_NOTICE("Your hand glows a brilliant red as you restore [to_heal] to good condition!"),
	)
	return TRUE

/// If cast on a carbon, we'll try to steal one of their organs directly from their person.
/obj/item/melee/touch_attack/flesh_surgery/proc/steal_organ_from_mob(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/carbon/carbon_victim = victim
	if(!istype(carbon_victim) || !length(carbon_victim.internal_organs))
		to_chat(caster, SPAN_WARNING("[victim] has no organs!"))
		return FALSE


	var/list/organs_we_can_remove = list()
	for(var/obj/item/organ/internal/free_snack in carbon_victim.internal_organs)
		if(free_snack.vital)
			continue
		organs_we_can_remove += free_snack

	var/obj/item/organ/chosen_organ = tgui_input_list(caster, "Please select an organ for removal", "Organ Selection", organs_we_can_remove)

	// Don't let people stam crit into steal heart true combo
	var/time_it_takes = carbon_victim.stat == DEAD ? 3 SECONDS : 15 SECONDS

	// Sure you can remove your own organs, fun party trick
	if(carbon_victim == caster)
		var/are_you_sure = tgui_alert(caster, "Are you sure you want to remove your own [chosen_organ]?", "Are you sure?", list("Yes", "No"))
		if(are_you_sure != "Yes" || extraction_checks(chosen_organ, hand, victim, caster))
			return FALSE

		time_it_takes = 6 SECONDS
		caster.visible_message(
			SPAN_DANGER("[caster]'s hand glows a brilliant red as [caster.p_they()] reach[caster.p_es()] directly into [caster.p_their()] own [chosen_organ.parent_organ]!"),
			SPAN_USERDANGER("Your hand glows a brilliant red as you reach directly into your own [chosen_organ.parent_organ]!"),
		)

	else
		carbon_victim.visible_message(
			SPAN_DANGER("[caster]'s hand glows a brilliant red as [caster.p_they()] reach[caster.p_es()] directly into [carbon_victim]'s [chosen_organ.parent_organ]!"),
			SPAN_USERDANGER("[caster]'s hand glows a brilliant red as [caster.p_they()] reach[caster.p_es()] directly into your [chosen_organ.parent_organ]!"),
		)

	to_chat(caster, SPAN_NOTICE("You begin to extract [chosen_organ]..."))
	playsound(victim, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	carbon_victim.add_atom_colour(COLOR_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, target = carbon_victim, extra_checks = list(CALLBACK(src, PROC_REF(extraction_checks), chosen_organ, hand, victim, caster))))
		to_chat(caster, SPAN_WARNING("You were interupted!"))
		carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_RED)
		return FALSE

	// Visible message done before Remove()
	// Mainly so it gets across if you're taking the eyes of someone who's conscious
	if(carbon_victim == caster)
		caster.visible_message(
			SPAN_BOLDDANGER("[caster] pulls [caster.p_their()] own [chosen_organ.name] out of [caster.p_their()] [chosen_organ.parent_organ]!!"),
			SPAN_USERDANGER("You pull your own [chosen_organ.name] out of your [chosen_organ.parent_organ]!!"),
		)

	else
		carbon_victim.visible_message(
			SPAN_BOLDDANGER("[caster] pulls [carbon_victim]'s [chosen_organ.name] out of [carbon_victim.p_their()] [chosen_organ.parent_organ]!!"),
			SPAN_USERDANGER("[caster] pulls your [chosen_organ.name] out of your [chosen_organ.parent_organ]!!"),
		)

	chosen_organ.remove(carbon_victim)
	carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_RED)
	if(carbon_victim.stat == CONSCIOUS)
		carbon_victim.HereticSlur(15 SECONDS)
		carbon_victim.emote("scream")

	// We need to wait for the spell to actually finish casting to put the organ in their hands, hence, 1 ms timer.
	addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob, put_in_hands), chosen_organ), 0.1 SECONDS)
	return TRUE

/// Extra checks ran while we're extracting an organ to make sure we can continue to do.
/obj/item/melee/touch_attack/flesh_surgery/proc/extraction_checks(obj/item/organ/picked_organ, obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(picked_organ) || QDELETED(victim))
		return TRUE

	return FALSE

/// Extra checks ran while we're healing something (organ, mob).
/obj/item/melee/touch_attack/flesh_surgery/proc/heal_checks(obj/item/melee/touch_attack/hand, atom/healing, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(healing))
		return TRUE

	return FALSE

/obj/item/melee/touch_attack/flesh_surgery
	name = "\improper knit flesh"
	desc = "Let's go practice medicine."
	catchphrase = null
	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5
