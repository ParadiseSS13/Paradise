/datum/martial_combo
	var/name = "Code Fu"							// Name used to explain the combo
	var/list/steps									// Which steps need to be performed
	var/current_step_index = 1						// What index to check
	var/current_combo_target = null
	var/combos_require_same_target = TRUE			// If you require to do the combo's on the same target
	var/explaination_text = "Ability to break shit"	// What does it do
	var/combo_text_override							// How to do the combo. If null it'll auto generate it from the steps

/datum/martial_combo/proc/check_combo(step, mob/living/target)
	if(!combos_require_same_target || current_combo_target == null || current_combo_target == target)
		if(!LAZYLEN(steps) || step == steps[current_step_index])
			return TRUE
	return FALSE

/datum/martial_combo/proc/progress_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	current_combo_target = target
	if(current_step_index++ >= LAZYLEN(steps))
		return perform_combo(user, target, MA)
	return MARTIAL_COMBO_CONTINUE

/datum/martial_combo/proc/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	return MARTIAL_COMBO_FAIL // Override this

/datum/martial_combo/proc/give_explaination(user)
	var/final_combo_text = combo_text_override
	if(!final_combo_text)
		final_combo_text = english_list(steps, and_text = " ", comma_text = " ")
	to_chat(user, "<span class='notice'>[name]</span>: [final_combo_text]. [explaination_text]")
