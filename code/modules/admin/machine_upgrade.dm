USER_CONTEXT_MENU(machine_upgrade, R_DEBUG, "\[Admin\] Tweak Component Ratings", obj/machinery/M as obj in world)
	if(!istype(M))
		to_chat(client, SPAN_DANGER("This can only be used on subtypes of /obj/machinery."))
		return

	var/new_rating = input(client, "Enter new rating:","Num") as num
	if(!isnull(new_rating) && M.component_parts)
		for(var/obj/item/stock_parts/P in M.component_parts)
			P.rating = new_rating
		M.RefreshParts()

		message_admins("[key_name_admin(client)] has set the component rating of [M] to [new_rating]")
		log_admin("[key_name(client)] has set the component rating of [M] to [new_rating]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Machine Upgrade") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
