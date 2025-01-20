/*
Компонент на органы, который бы позволяли объединять многочисленные действия органов в одну радиальную кнопку
*/

/datum/component/organ_action
	var/obj/item/organ/internal/organ
	var/radial_additive_state
	var/radial_additive_icon

/datum/component/organ_action/Initialize(state, icon)
	organ = parent
	radial_additive_state = state
	radial_additive_icon = icon

/datum/component/organ_action/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_GROUP_ACTION_CALL, PROC_REF(call_actions))
	RegisterSignal(parent, COMSIG_ORGAN_GROUP_ACTION_RESORT, PROC_REF(resort_buttons))

/datum/component/organ_action/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ORGAN_GROUP_ACTION_CALL)
	UnregisterSignal(parent, COMSIG_ORGAN_GROUP_ACTION_RESORT)


/datum/component/organ_action/proc/check_actions(mob/user)
	return (organ.owner && organ.owner == user && organ.owner.stat != DEAD && (organ in organ.owner.internal_organs))

//Прок, вызывается непосредственно в кнопке действия органа
/datum/component/organ_action/proc/call_actions(mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(open_actions), user)

/datum/component/organ_action/proc/open_actions(mob/user)
	var/list/choices = list()
	var/list/organs_list = list()
	for(var/obj/item/organ/internal/O in organ.owner.internal_organs)
		if(length(O.actions_types) > 0 && !istype(O, /obj/item/organ/internal/cyberimp))
			organs_list += O

	for(var/obj/item/organ/internal/I in organs_list)
		if(I.radial_action_state && I.radial_action_icon)
			choices["[I.name]"] = image(icon = I.radial_action_icon, icon_state = I.radial_action_state)

	var/choice = show_radial_menu(user, user, choices, custom_check = CALLBACK(src, PROC_REF(check_actions), user))
	if(!check_actions(user))
		return

	var/obj/item/organ/internal/selected
	for(var/obj/item in organs_list)
		if(item.name == choice)
			selected = item
			break

	if(istype(selected) && (selected in organs_list))
		selected.switch_mode()

//Прок для ресортировки кнопок (убирает лишние дубли) (должен вызываться на insert/remove конкретного органа, чтобы не трогать остальные)
/datum/component/organ_action/proc/resort_buttons()
	SIGNAL_HANDLER

	var/list/organs_list = list()
	if(organ.owner)
		for(var/obj/item/organ/internal/O in organ.owner.internal_organs)
			if(length(O.actions_types) > 0 && !istype(O, /obj/item/organ/internal/cyberimp))
				organs_list += O

		for(var/obj/item/organ/internal/O in organs_list)
			organs_list -= O
			for(var/obj/item/organ/internal/D in organs_list)
				var/datum/action/action_candidate = D.actions[1]
				if(D != O)
					if(action_candidate in organ.owner.actions)
						action_candidate.Remove(organ.owner)
				else
					if(!(action_candidate in organ.owner.actions))
						action_candidate.Grant(organ.owner)
				break

/obj/item/organ/internal
	var/radial_action_state
	var/radial_action_icon
