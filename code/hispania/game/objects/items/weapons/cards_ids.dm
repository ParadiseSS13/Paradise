/obj/item/card/id/captains_spare/pickup(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(H.get_assignment()!="Captain")
		user.create_log(MISC_LOG, "Captain's Spare taken.")
		message_admins("Captain's Spare has been taken  by [key_name(user)] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>).")
		log_game("Captain's Spare has been taken  by [key_name(user)]).")
	..()
