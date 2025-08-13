/datum/element/red_alert_access

/datum/element/red_alert_access/Attach(datum/target, list/access = list())
	. = ..()
	if(!istype(target, /obj/item/card/id))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ID_GET_ACCESS, PROC_REF(add_access))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(examine))

/datum/element/red_alert_access/Detach(obj/item/card/id/source, force)
	UnregisterSignal(source, COMSIG_ID_GET_ACCESS)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/element/red_alert_access/proc/add_access(obj/item/card/id/source, list/new_access = list())
	SIGNAL_HANDLER
	if(!should_give_access(source.access))
		return
	var/static/list/red_alert_access = get_region_accesses(REGION_ALL) - get_region_accesses(REGION_COMMAND)
	new_access |= red_alert_access

/datum/element/red_alert_access/proc/examine(obj/item/card/id/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!should_give_access(source.access))
		return
	examine_list += span_notice("Мигает красная лампочка с надписью \"Расширенный доступ\".")

/datum/element/red_alert_access/proc/should_give_access(list/access)
	if(SSsecurity_level.current_security_level.number_level <= SEC_LEVEL_BLUE)
		return FALSE
	if(!has_access(list(), list(ACCESS_SECURITY), access))
		return FALSE
	return TRUE
