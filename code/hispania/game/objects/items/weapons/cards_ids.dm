/obj/item/card/id/captains_spare/pickup(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(H.get_assignment()!="Captain")
		user.create_log(MISC_LOG, "Captain's Spare taken.")
		message_admins("Captain's Spare has been taken  by [key_name(user)] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>).")
		log_game("Captain's Spare has been taken  by [key_name(user)]).")
	
	if(iswizard(user) || (isabductor(user)) || isshadowling(user))
		if(iswizard(user))
			to_chat(H, "<span class='userdanger'>Dudo que la federacion de magos aprobaria esto .. Si quiero abrir puertas puedo usar magia como el hechizo Knock knock!</span>")

		if(isabductor(user))
			to_chat(H, "<span class='userdanger'>Algo me dice que esta tecnologia primitiva no me sera necesaria...</span>")

		if(isshadowling(user))
			to_chat(H, "<span class='userdanger'>Ughh... esta ID es muy brillosa. No seria buena idea tomarla.</span>")
		user.Weaken(3)

	..()