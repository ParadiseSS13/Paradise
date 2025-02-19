// ID upgrader - swipe an ID on it to gain access types. Used on ruins.
/obj/machinery/computer/id_upgrader
	name = "ID Upgrade Machine"
	icon_state = "guest"
	icon_screen = "pass"
	/// Access to give
	var/list/access_to_give = list(ACCESS_AWAY01)
	/// Have we been used?
	var/used = FALSE

/obj/machinery/computer/id_upgrader/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/card/id))
		var/obj/item/card/id/D = used
		if(!length(access_to_give))
			to_chat(user, "<span class='notice'>This machine appears to be configured incorrectly.</span>")
			return ITEM_INTERACT_COMPLETE

		var/did_upgrade = FALSE
		var/list/id_access = D.GetAccess()

		for(var/this_access in access_to_give)
			if(!(this_access in id_access))
				// don't have it - add it
				D.access |= this_access
				did_upgrade = TRUE

		if(did_upgrade)
			to_chat(user, "<span class='notice'>An access type was added to your ID card.</span>")
		else
			to_chat(user, "<span class='notice'>Your ID card already has all the access this machine can give.</span>")

		return ITEM_INTERACT_COMPLETE

	return ..()
