/obj/item/card/id
	var/list/red_alert_given_access // Accesses that were given on red alert

/obj/item/card/id/Initialize(mapload)
	. = ..()
	red_alert_given_access = list()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_update))

/obj/item/card/id/Destroy()
	return ..()

/obj/item/card/id/proc/on_red_alert()
	if(!has_access(list(), list(ACCESS_SECURITY), access))
		return
	red_alert_given_access = get_region_accesses(REGION_ALL) - get_region_accesses(REGION_COMMAND)
	red_alert_given_access -= access

	access |= red_alert_given_access

/obj/item/card/id/proc/after_red_alert()
	if(!has_access(list(), list(ACCESS_SECURITY), access))
		return
	access -= red_alert_given_access
	red_alert_given_access.Cut()

/obj/item/card/id/proc/on_security_level_update()
	if(SSsecurity_level.current_security_level.number_level > SEC_LEVEL_BLUE)
		on_red_alert()
	else
		after_red_alert()
