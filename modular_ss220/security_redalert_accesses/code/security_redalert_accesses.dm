/obj/item/card/id/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/red_alert_access)

/obj/item/card/id/GetAccess()
	var/list/current_access = ..()
	. = current_access.Copy()
	SEND_SIGNAL(src, COMSIG_ID_GET_ACCESS, .)
