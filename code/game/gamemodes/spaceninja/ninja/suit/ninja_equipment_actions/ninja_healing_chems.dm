

/datum/action/item_action/ninjaheal
	check_flags = NONE
	name = "Restorative Cocktail"
	desc = "Injects a series of chemicals that will heal most of the user's injuries, cure internal damage and bones. \
			But healing comes with a price of sleeping while your body regenerates!"
	use_itemicon = FALSE
	button_icon_state = "chem_injector"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green_active"
	action_initialisation_text = "Integrated Restorative Cocktail Mixer"

/**
 * Proc called to activate space ninja's adrenaline.
 *
 * Proc called to use space ninja's adrenaline.  Gets the ninja out of almost any stun.
 * Also makes them shout MGS references when used.  After a bit, it injects the user with
 * radium by calling a different proc.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjaheal()
	if(ninjacost(0,N_HEAL))
		return
	var/mob/living/carbon/human/ninja = affecting
	if(alert(ninja, "Вы уверены что хотите ввести себе лечащие реагенты? Это усыпит вас на время пока ваше тело регенерирует!",,"Да","Нет") == "Нет")
		return
	if(!do_after(ninja, 5 SECONDS, FALSE, ninja, use_default_checks = FALSE))
		to_chat(ninja, span_warning("Введение реагентов прервано!"))
		return

	ninja.reagents.add_reagent("syndicate_nanites", 20)				// Ожоги + Физ.+ Гипоксия + Токсины + Ген. Урон + Мозг
	ninja.reagents.add_reagent("antihol", 20)						// Алкоголь
	ninja.reagents.add_reagent("mitocholide", 20)					// Органы
	ninja.reagents.add_reagent("nanocalcium", 20)					// Кости
	ninja.reagents.add_reagent("oculine", 5)						// Глазки и уши

	// Лечим органы
	for(var/organ_name in ninja.bodyparts_by_name)
		var/obj/item/organ/external/ninja_organ = ninja.bodyparts_by_name[organ_name]
		if(!ninja_organ)
			continue
		ninja_organ.germ_level = 0
		QDEL_NULL(ninja_organ.hidden)
		ninja_organ.open = 0
		ninja_organ.internal_bleeding = FALSE
		ninja_organ.perma_injury = 0
		ninja_organ.status = 0
		ninja_organ.trace_chemicals.Cut()

	for(var/obj/item/organ/internal/ninja_organ in ninja.internal_organs)
		ninja_organ.rejuvenate()
		ninja_organ.trace_chemicals.Cut()
	ninja.remove_all_embedded_objects()
	ninja.restore_blood()

	to_chat(ninja, span_notice("Реагенты успешно введены в пользователя."))
	add_attack_logs(ninja, null, "Activated healing chems.")
	s_coold = 3 SECONDS
	heal_available = FALSE
	for(var/datum/action/item_action/ninjaheal/ninja_action in actions)
		toggle_ninja_action_active(ninja_action, FALSE)
	addtimer(CALLBACK(src, .proc/ninjaheal_after), 50)

/obj/item/clothing/suit/space/space_ninja/proc/ninjaheal_after()
	var/mob/living/carbon/human/ninja = affecting
	to_chat(ninja, span_danger("Вы начинаете чувствовать побочные эффекты медикаментов..."))
	ninja.SetSleeping(40)
