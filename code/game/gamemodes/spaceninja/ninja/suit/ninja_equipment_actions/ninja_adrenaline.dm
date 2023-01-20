//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.

/datum/action/item_action/advanced/ninja/ninjaboost
	name = "Adrenaline Boost"
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_CHARGES
	charge_max = 1
	use_itemicon = FALSE
	button_icon_state = "adrenal"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green_active"
	action_initialisation_text = "Integrated Adrenaline Injector"

/**
 * Proc called to activate space ninja's adrenaline.
 *
 * Proc called to use space ninja's adrenaline.  Gets the ninja out of almost any stun.
 * Also makes them shout MG and DMC references when used.  After a bit, it injects the user with
 * radium by calling a different proc.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()
	if(ninjacost(0,N_ADRENALINE))
		return
	var/mob/living/carbon/human/ninja = affecting
	ninja.SetStunned(0)
	ninja.SetWeakened(0)
	ninja.SetParalysis(0)
	ninja.SetSleeping(0)
	ninja.adjustStaminaLoss(-75)
	ninja.lying = 0
	ninja.update_canmove()
	ninja.SetStuttering(0, force)
	ninja.reagents.add_reagent("synaptizine", 20)
	ninja.reagents.add_reagent("stimulative_agent", 20)
	add_attack_logs(ninja, null, "Activated ninja-boost(adrenaline).")
	//Никакого омнизина как в трейторском адренале. Наш адренал не хилит!
	ninja.say(pick(boost_phrases))
	to_chat(ninja, span_notice("Вы чувствуете мощный прилив адреналина!"))
	for(var/datum/action/item_action/advanced/ninja/ninjaboost/ninja_action in actions)
		ninja_action.use_action()
		if(!ninja_action.charge_counter)
			ninja_action.action_ready = FALSE
			ninja_action.toggle_button_on_off()
		break
	addtimer(CALLBACK(src, .proc/ninjaboost_after), 70)

/**
 * Proc called to inject the ninja with radium.
 *
 * Used after 7 seconds of using the ninja's adrenaline.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost_after()
	var/mob/living/carbon/human/ninja = affecting
	ninja.reagents.add_reagent("radium", a_transfer * 0.5)
	to_chat(ninja, span_danger("Вы начинаете чувствовать побочные эффекты стимулянтов..."))
