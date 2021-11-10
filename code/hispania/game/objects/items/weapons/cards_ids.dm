/obj/item/card/id/captains_spare/pickup(mob/living/user)
	var/mob/living/carbon/human/H = user
	if(H.get_assignment()!="Captain")
		user.create_log(MISC_LOG, "Captain's Spare taken.")
		message_admins("Captain's Spare has been taken  by [key_name(user)] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>).")
		log_game("Captain's Spare has been taken  by [key_name(user)]).")
	..()

/obj/item/card/id/captains_spare/proc/cooldown_confirmacion()
	spawn(10 MINUTES)
		confirmacion_pickeo = FALSE

/obj/item/card/id/captains_spare/attack_hand(mob/living/user)
	if(iswizard(user) || (isabductor(user)) || isshadowling(user))
		if(iswizard(user))
			to_chat(user, "<span class='userdanger'>Dudo que la federacion de magos aprobaria esto .. Si quiero abrir puertas puedo usar magia como el hechizo Knock knock!..</span>")
			to_chat(usr, "<span class='boldannounce'>Esto podria causar una llamada de atencion de un admin y eventualmente una sancion ¿Estas seguro?</span>")
			if(!confirmacion_pickeo)
				cooldown_confirmacion()
				confirmacion_pickeo = TRUE
				return FALSE
		if(isshadowling(user))
			to_chat(user, "<span class='userdanger'>Ughh... esta ID es muy brillosa. No seria buena idea tomarla.</span>")
			to_chat(usr, "<span class='boldannounce'>Esto podria causar una llamada de atencion de un admin y eventualmente una sancion ¿Estas seguro?</span>")
			if(!confirmacion_pickeo)
				confirmacion_pickeo = TRUE
				cooldown_confirmacion()
				return FALSE
		if(isabductor(user))
			to_chat(user, "<span class='userdanger'>Algo me dice que esta tecnologia primitiva no me sera necesaria...</span>")
			return FALSE
	..()
