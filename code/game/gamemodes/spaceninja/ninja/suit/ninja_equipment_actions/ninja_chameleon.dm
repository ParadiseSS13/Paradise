
/*
 * Chameleon ability, that allows you to change your appearance to the appearance of a crewmember
 */
/datum/action/item_action/advanced/ninja/ninja_chameleon
	name = "Chameleon Disguise"
	desc = "Toggles Chameleon mode on and off. Passively encrease suit energy consumption."
	check_flags = AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	charge_type = ADV_ACTION_TYPE_TOGGLE
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "chameleon"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Kitsune - Adaptive Chameleon Device"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_chameleon_scanner_mode()
	var/mob/living/carbon/human/ninja = affecting
	if(chameleon_scanner)
		qdel(chameleon_scanner)
		chameleon_scanner = null
	else
		chameleon_scanner = new
		chameleon_scanner.my_suit = src
		for(var/datum/action/item_action/advanced/ninja/ninja_chameleon/ninja_action in actions)
			chameleon_scanner.my_action = ninja_action
			break
		if(disguise_active)
			chameleon_scanner.icon_state = "[initial(chameleon_scanner.icon_state)]_act"
		ninja.put_in_hands(chameleon_scanner)

/*
 * The scanner object and all the logic behind it below
 */

/obj/item/ninja_chameleon_scanner
	name = "chameleon scanner"
	desc = "A device sneakily hidden inside Spider Clan ninja suits. Scans a person's visual appearance and voice, which makes it possible for the ninja, to impersonate them"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "chameleon_device"
	item_state = ""
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = 0
	flags =  DROPDEL | ABSTRACT | NOBLUDGEON | NOPICKUP
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/datum/action/item_action/advanced/ninja/ninja_chameleon/my_action = null

/obj/item/ninja_chameleon_scanner/Destroy()
	. = ..()
	my_suit.chameleon_scanner = null
	my_suit = null
	my_action = null

/obj/item/ninja_chameleon_scanner/equip_to_best_slot(mob/M)
	qdel(src)

/obj/item/ninja_chameleon_scanner/attack_self(mob/user)
	if(!my_suit.s_busy)	//Боремся со спамом кнопок
		ninja_chameleon(user, user)


/obj/item/ninja_chameleon_scanner/afterattack(atom/target, mob/living/user, proximity)
	var/mob/target_mob = get_mob_in_atom_without_warning(target)
	if(!my_suit.s_busy)	//Боремся со спамом кнопок
		ninja_chameleon(target_mob, user)

/obj/item/ninja_chameleon_scanner/proc/ninja_chameleon(mob/living/target, mob/living/ninja)
	if(target == ninja)
		INVOKE_ASYNC(my_suit, /obj/item/clothing/suit/space/space_ninja/.proc/pick_form, ninja)
		return
	INVOKE_ASYNC(my_suit, /obj/item/clothing/suit/space/space_ninja/.proc/remember_form, target, ninja)

/*
 * Suit procs
 */

/obj/item/clothing/suit/space/space_ninja/proc/remember_form(mob/living/carbon/human/target_mob, mob/living/carbon/human/ninja)
	if(!ishuman(target_mob))
		return
	if(disguise && target_mob.name == disguise.name)
		to_chat(ninja, span_warning("Внешность \"[target_mob]\" уже доступна вам."))
		return

	to_chat(ninja, span_notice("Вы начали сканировать [target_mob]."))
	if(!s_busy)
		s_busy = TRUE
		if(!do_after(ninja, 2 SECONDS, FALSE, ninja))
			to_chat(ninja, span_warning("Сканирование прервано!"))
			s_busy = FALSE
			return
		s_busy = FALSE
	// Forget the old disguise if needed
	if(disguise)
		qdel(disguise) // Delete the value using the key

	disguise = new /datum/icon_snapshot
	disguise.copyInfoFrom(target_mob)

	to_chat(ninja, span_notice("Вы просканировали внешность [target_mob]."))

/obj/item/clothing/suit/space/space_ninja/proc/pick_form(mob/living/carbon/human/ninja)
	if(!disguise && !disguise_active)
		to_chat(ninja, span_warning("Вы ещё никого не сканировали! Используйте эту способность, чтобы просканировать чужую внешность!"))
		return

	if(!disguise_active)
		to_chat(ninja, span_notice("Вы начали маскироваться под [disguise.name]."))
		var/obj/effect/temp_visual/holo_scan/my_scan_effect = new(get_turf(src), color_choice, "alpha", TRUE)
		if(!s_busy)
			s_busy = TRUE
			if(!do_after(ninja, 2 SECONDS, FALSE, ninja) )
				to_chat(ninja, span_warning("Вы прервали маскировку!"))
				s_busy = FALSE
				do_sparks(3, FALSE, ninja)
				qdel(my_scan_effect)
				return
			s_busy = FALSE
		toggle_chameleon(ninja)
	else
		restore_form(ninja)
		return

/// When reloading our disguise via helper, we don't need to do some things.
/// That's why the "extra_important_things" flag is here.
/obj/item/clothing/suit/space/space_ninja/proc/toggle_chameleon(extra_important_things = TRUE)
	var/mob/living/carbon/human/ninja = affecting
	var/old_name = "[ninja]"

	if(extra_important_things)
		//Voice changing
		n_mask.voice_changer.set_voice(ninja, disguise.name)
		if(!n_mask.voice_changer.active)
			n_mask.voice_changer.attack_self(ninja)
		//ID card initialisation
		n_id_card = new
		toggle_ninja_nodrop(n_id_card)
		n_id_card.flags ^= DROPDEL
		n_id_card.assignment = disguise.assignment
		n_id_card.rank = disguise.rank
		if(!ninja.wear_id)
			ninja.equip_to_slot(n_id_card, slot_wear_id)
		else
			qdel(n_id_card)
			n_id_card = null
		//Sparks
		playsound(ninja, "sparks", 75, TRUE)
		spark_system.start()
		//Log and info
		ninja.visible_message(span_warning("[old_name] начинает светиться и меняет форму становясь [ninja]!"), span_notice("Вы маскируете свою внешность становясь [ninja]."), "Вы слышите странный электрический звук!")
		add_game_logs("Замаскировался под [ninja]", ninja)
		//Components
		ninja.AddComponent(/datum/component/examine_override, disguise.examine_text)
		ninja.AddComponent(/datum/component/ninja_states_breaker, src)
		ninja.AddComponent(/datum/component/ninja_chameleon_helper, src)
		//Chameleon_scanner icon reloading
		if(chameleon_scanner)
			chameleon_scanner.icon_state = "[initial(chameleon_scanner.icon_state)]_act"
		//Action icon
		for(var/datum/action/item_action/advanced/ninja/ninja_chameleon/ninja_action in actions)
			ninja_action.action_ready = TRUE
			ninja_action.use_action()

	//Disguise
	ninja.name_override = disguise.name
	ninja.icon = disguise.icon
	ninja.icon_state = disguise.icon_state
	ninja.overlays = disguise.overlays
	//Disguise flag
	disguise_active = TRUE


/*
* Proc восстанавливающий внешность ниндзя и отрубающий хамелион.
*/
/obj/item/clothing/suit/space/space_ninja/proc/restore_form()
	//Disguise flag
	disguise_active = FALSE

	var/mob/living/carbon/human/ninja = affecting
	var/old_name = "[ninja.name_override]"
	//Disguise off
	ninja.cut_overlays()
	ninja.icon = initial(ninja.icon)
	ninja.icon_state = initial(ninja.icon_state)
	ninja.name_override = null
	ninja.regenerate_icons()
	ninja.name = initial(ninja.name)
	ninja.desc = initial(ninja.desc)
	ninja.color = initial(ninja.color)

	//Voice changing off
	if(n_mask.voice_changer.active)
		n_mask.voice_changer.attack_self(ninja)
	//ID card deinitialisation
	qdel(n_id_card)
	n_id_card = null
	//Sparks
	playsound(ninja, "sparks", 150, TRUE)
	spark_system.start()
	//Info
	ninja.visible_message(span_warning("[old_name] начинает светиться и меняет форму становясь [ninja]!"), span_notice("Вы возвращаете себе свою внешность."), "Вы слышите странный электрический звук!")
	//Chameleon_scanner icon reloading
	if(chameleon_scanner)
		chameleon_scanner.icon_state = "[initial(chameleon_scanner.icon_state)]"
	//Action icon
	for(var/datum/action/item_action/advanced/ninja/ninja_chameleon/ninja_action in actions)
		ninja_action.action_ready = FALSE
		ninja_action.use_action()
	//Components
	qdel(ninja.GetComponent(/datum/component/examine_override))
	qdel(ninja.GetComponent(/datum/component/ninja_states_breaker))
	qdel(ninja.GetComponent(/datum/component/ninja_chameleon_helper))

