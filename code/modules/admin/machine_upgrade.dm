/proc/machine_upgrade(obj/machinery/M in world)
	set name = "Tweak Component Ratings"
	set category = null

	if(!check_rights(R_DEBUG))
		return

	if(!istype(M))
		to_chat(usr, "<span class='danger'>This can only be used on subtypes of /obj/machinery.</span>")
		return

	var/new_rating = input("Enter new rating:","Num") as num
	if(!isnull(new_rating) && M.component_parts)
		for(var/obj/item/stock_parts/P in M.component_parts)
			P.rating = new_rating
		M.RefreshParts()

		message_admins("[key_name_admin(usr)] has set the component rating of [M] to [new_rating]")
		log_admin("[key_name(usr)] has set the component rating of [M] to [new_rating]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Machine Upgrade") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
