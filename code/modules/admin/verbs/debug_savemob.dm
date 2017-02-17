/client/proc/save_mob_to_file(var/mob/living/M as mob in mob_list)
	set category = "Admin"
	set name = "Save Mob To File"
		
	if(!check_rights(R_ADMIN))
		return
		
	if(!istype(M))	
		return	

	var/savefile/S = new /savefile("data/debug/[M.name].sav")
 	S["stored_player"] << M // yes, this works
