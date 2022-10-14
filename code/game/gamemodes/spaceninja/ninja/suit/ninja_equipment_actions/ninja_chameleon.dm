
/*
* Chameleon ability, that allows you to change your appearance to the appearance of a crewmember
*/
/datum/action/item_action/ninja_chameleon
	check_flags = AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
	name = "Chameleon Disguise"
	desc = "Toggles Chameleon mode on and off. Passively encrease suit energy consumption."
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
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = 0
	flags = NODROP | DROPDEL | ABSTRACT
	var/effect_color = "#ffaa00"
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null

/obj/item/ninja_chameleon_scanner/Destroy()
	. = ..()
	my_suit.chameleon_scanner = null
	my_suit = null

/obj/item/ninja_chameleon_scanner/equip_to_best_slot(mob/M)
	qdel(src)

/obj/item/ninja_chameleon_scanner/attack_self(mob/user)
	ninja_chameleon(user, user)

/obj/item/ninja_chameleon_scanner/attack()
	return

/obj/item/ninja_chameleon_scanner/afterattack(atom/target, mob/living/user, proximity)
	var/mob/target_mob = get_mob_in_atom_without_warning(target)
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
	if(!do_after(ninja, 2 SECONDS, FALSE, ninja))
		to_chat(ninja, span_warning("Сканирование прервано!"))
		return

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

		ninja.color = chameleon_scanner.effect_color
		/*Копипаст анимации саботёр борга*/
		var/start = ninja.filters.len
		var/X
		var/Y
		var/rsq
		var/i
		var/f
		for(i in 1 to 7)
			do
				X = 60 * rand() - 30
				Y = 60 * rand() - 30
				rsq = X * X + Y * Y
			while(rsq < 100 || rsq > 900)
			ninja.filters += filter(type = "wave", x = X, y = Y, size = rand() * 2.5 + 0.5, offset = rand())
		for(i in 1 to 7)
			f = ninja.filters[start+i]
			animate(f, offset = f:offset, time = 0, loop = 3, flags = ANIMATION_PARALLEL)
			animate(offset = f:offset - 1, time = rand() * 20 + 10)
		/*Конец копипаста*/

		if(!do_after(ninja, 2 SECONDS, FALSE, ninja))
			to_chat(ninja, span_warning("Вы прервали маскировку!"))
			/*Копипаст анимации саботёр борга 2*/
			do_sparks(3, FALSE, ninja)
			for(i in 1 to min(7, ninja.filters.len)) // removing filters that are animating does nothing, we gotta stop the animations first
				f = ninja.filters[start + i]
				animate(f)
			ninja.filters = null
			/*Конец копипаста 2*/
			ninja.color = initial(ninja.color)
			return
		ninja.filters = null
		ninja.color = initial(ninja.color)
		toggle_chameleon(ninja)
	else
		restore_form(ninja)
		return

/obj/item/clothing/suit/space/space_ninja/proc/toggle_chameleon()
	var/mob/living/carbon/human/ninja = affecting
	var/old_name = "[ninja]"

	ninja.name_override = disguise.name
	ninja.icon = disguise.icon
	ninja.icon_state = disguise.icon_state
	ninja.overlays = disguise.overlays
	ninja.update_inv_r_hand()
	ninja.update_inv_l_hand()

	n_mask.voice_changer.set_voice(ninja, disguise.name)
	if(!n_mask.voice_changer.active)
		n_mask.voice_changer.attack_self(ninja)

	playsound(ninja, "sparks", 75, TRUE)
	spark_system.start()

	ninja.visible_message(span_warning("[old_name] начинает светиться и меняет форму становясь [ninja]!"), span_notice("Вы маскируете свою внешность становясь [ninja]."), "Вы слышите странный электрический звук!")
	add_game_logs("Замаскировался под [ninja]", ninja)

	ninja.AddComponent(/datum/component/examine_override, disguise.examine_text)
	ninja.AddComponent(/datum/component/ninja_states_breaker, src)

	if(chameleon_scanner)
		chameleon_scanner.icon_state = "[initial(chameleon_scanner.icon_state)]_act"

	for(var/datum/action/item_action/ninja_chameleon/ninja_action in actions)
		toggle_ninja_action_active(ninja_action, TRUE)
	disguise_active = TRUE
/*
* Proc восстанавливающий внешность ниндзя и отрубающий хамелион.
*/
/obj/item/clothing/suit/space/space_ninja/proc/restore_form()
	disguise_active = FALSE
	var/mob/living/carbon/human/ninja = affecting
	if(chameleon_scanner)
		chameleon_scanner.icon_state = "[initial(chameleon_scanner.icon_state)]"
	var/old_name = "[ninja.name_override]"

	ninja.cut_overlays()
	ninja.icon = initial(ninja.icon)
	ninja.icon_state = initial(ninja.icon_state)
	ninja.name_override = null
	ninja.regenerate_icons()
	ninja.name = initial(ninja.name)
	ninja.desc = initial(ninja.desc)
	ninja.color = initial(ninja.color)

	if(n_mask.voice_changer.active)
		n_mask.voice_changer.attack_self(ninja)

	playsound(ninja, "sparks", 150, TRUE)
	spark_system.start()

	ninja.visible_message(span_warning("[old_name] начинает светиться и меняет форму становясь [ninja]!"), span_notice("Вы возвращаете себе свою внешность."), "Вы слышите странный электрический звук!")

	for(var/datum/action/item_action/ninja_chameleon/ninja_action in actions)
		toggle_ninja_action_active(ninja_action, FALSE)

	qdel(ninja.GetComponent(/datum/component/examine_override))
	qdel(ninja.GetComponent(/datum/component/ninja_states_breaker))

