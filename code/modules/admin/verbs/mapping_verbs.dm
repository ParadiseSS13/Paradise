/client/proc/set_next_map()
	set category = "Server"
	set name = "Set Next Map"

	if(!check_rights(R_SERVER))
		return

	var/list/map_datums = list()
	for(var/x in subtypesof(/datum/map))
		var/datum/map/M = x
		if(initial(M.voteable))
			map_datums["[initial(M.fluff_name)] ([initial(M.technical_name)])"] = M // Put our map in

	var/target_map_name = input(usr, "Select target map", "Next map", null) as null|anything in map_datums

	if(!target_map_name)
		return

	var/datum/map/TM = map_datums[target_map_name]
	SSmapping.next_map = new TM
	var/announce_to_players = alert(usr, "Do you wish to tell the playerbase about your choice?", "Announce", "Yes", "No")
	message_admins("[key_name_admin(usr)] has set the next map to [SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])")
	log_admin("[key_name(usr)] has set the next map to [SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])")
	if(announce_to_players == "Yes")
		to_chat(world, "<span class='boldannounce'>[key] has chosen the following map for next round: <font color='cyan'>[SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])</font></span>")
