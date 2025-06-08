/*
===Парные импланты===
Элемент дял парных имплантов, который позволяет их синхронную активацию и скрытие второй кнопки (1 кнопка на 2 импланта)
*/

/datum/element/paired_implants

/datum/element/paired_implants/Attach(obj/item/organ/internal/cyberimp/arm/target)
	. = ..()
	RegisterSignal(target, COMSIG_DOUBLEIMP_SYNCHONIZE, PROC_REF(synchonize_implants))
	RegisterSignal(target, COMSIG_DOUBLEIMP_ACTION_REBUILD, PROC_REF(action_rebuild))

/datum/element/paired_implants/Detach(obj/item/organ/internal/cyberimp/arm/target)
	UnregisterSignal(target, COMSIG_DOUBLEIMP_SYNCHONIZE)
	UnregisterSignal(target, COMSIG_DOUBLEIMP_ACTION_REBUILD)
	return ..()

/datum/element/paired_implants/proc/action_rebuild(processed_implant)
	SIGNAL_HANDLER
	var/obj/item/organ/internal/cyberimp/arm/pair_implant = null
	var/obj/item/organ/internal/cyberimp/arm/assigned_implant = processed_implant
	var/list/organs = assigned_implant.owner.internal_organs
	for(var/obj/item/organ/internal/O in organs)
		if(istype(O, /obj/item/organ/internal/cyberimp/arm) && assigned_implant != O)
			pair_implant = O
			break

	var/datum/action/action_candidate = assigned_implant.actions[1]
	if(!isnull(pair_implant))
		if(action_candidate in assigned_implant.owner.actions)
			action_candidate.Remove(assigned_implant.owner)
	else
		if(!(action_candidate in assigned_implant.owner.actions))
			action_candidate.Grant(assigned_implant.owner)
	assigned_implant.owner.update_action_buttons()

/datum/element/paired_implants/proc/synchonize_implants(processed_implant)
	SIGNAL_HANDLER
	var/obj/item/organ/internal/cyberimp/arm/pair_implant = null
	var/obj/item/organ/internal/cyberimp/arm/assigned_implant = processed_implant
	var/list/organs = assigned_implant.owner.internal_organs
	for(var/obj/item/organ/internal/O in organs)
		if(istype(O, /obj/item/organ/internal/cyberimp/arm) && istype(assigned_implant, /obj/item/organ/internal/cyberimp/arm) && assigned_implant != O)
			pair_implant = O
			break

	if(!isnull(pair_implant))
		var/main_implant_retracted = !assigned_implant.holder || (assigned_implant.holder in assigned_implant)
		var/pair_implant_retracted = !pair_implant.holder || (pair_implant.holder in pair_implant)

		if(main_implant_retracted != pair_implant_retracted)
			if(!main_implant_retracted)
				pair_implant.holder = null
				if(assigned_implant.holder)
					var/content_object = assigned_implant.holder.type
					for(var/obj/item/candidate in pair_implant.contents)
						if(istype(candidate,content_object))
							pair_implant.Extend(candidate)
							break
			else
				pair_implant.Retract()
