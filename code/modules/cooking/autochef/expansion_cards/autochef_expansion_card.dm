/obj/item/autochef_expansion_card
	name = "autochef expansion card"
	icon = 'icons/obj/module.dmi'
	icon_state = "autochef_expansion_card"
	new_attack_chain = TRUE

	var/obj/machinery/autochef/autochef
	var/task_message
	var/list/registerable_machines = list()

/obj/item/autochef_expansion_card/proc/can_produce(obj/machinery/autochef/autochef, target_type)
	return AUTOCHEF_ACT_FAILED

/obj/item/autochef_expansion_card/proc/perform_step(datum/autochef_task/origin_task, target_type)
	return AUTOCHEF_ACT_FAILED

/obj/item/autochef_expansion_card/proc/is_valid_output(atom/movable/object)
	return FALSE

/obj/item/autochef_expansion_card/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/obj/machinery/autochef/autochef = target
	if(!istype(autochef))
		return

	if(!user.drop_item())
		return ITEM_INTERACT_COMPLETE

	autochef.try_insert_expansion(user, src)
	return ITEM_INTERACT_COMPLETE
