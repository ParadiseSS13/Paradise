/mob/living/carbon/verb/give(var/mob/living/carbon/target in oview(1))
	set category = "IC"
	set name = "Give"

	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, "<span class='danger'>Wait a second... \the [target] HAS NO HANDS! AHH!</span>")//cheesy messages ftw

		return
	if(target.stat == 2 || usr.stat == 2|| target.client == null)
		return
	var/obj/item/I
	if(!usr.hand && usr.r_hand == null)
		to_chat(usr, "<span class='warning'> You don't have anything in your right hand to give to [target.name]</span>")
		return
	if(usr.hand && usr.l_hand == null)
		to_chat(usr, "<span class='warning'> You don't have anything in your left hand to give to [target.name]</span>")
		return
	if(usr.hand)
		I = usr.l_hand
	else if(!usr.hand)
		I = usr.r_hand
	if(!I)
		return
	if((I.flags & NODROP) || (I.flags & ABSTRACT))
		to_chat(usr, "<span class='notice'>That's not exactly something you can give.</span>")
		return
	if(target.r_hand == null || target.l_hand == null)
		switch(alert(target,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(usr))
					to_chat(usr, "<span class='warning'> You need to stay in reaching distance while giving an object.</span>")
					to_chat(target, "<span class='warning'> [usr.name] moved too far away.</span>")
					return
				if((usr.hand && usr.l_hand != I) || (!usr.hand && usr.r_hand != I))
					to_chat(usr, "<span class='warning'> You need to keep the item in your active hand.</span>")
					to_chat(target, "<span class='warning'> [usr.name] seem to have given up on giving \the [I.name] to you.</span>")
					return
				if(target.r_hand != null && target.l_hand != null)
					to_chat(target, "<span class='warning'> Your hands are full.</span>")
					to_chat(usr, "<span class='warning'> Their hands are full.</span>")
					return
				else
					usr.drop_item()
					if(target.r_hand == null)
						target.r_hand = I
					else
						target.l_hand = I
				I.loc = target
				I.layer = 20
				I.plane = HUD_PLANE
				I.add_fingerprint(target)
				src.update_inv_l_hand()
				src.update_inv_r_hand()
				target.update_inv_l_hand()
				target.update_inv_r_hand()
				target.visible_message("<span class='notice'> [usr.name] handed \the [I.name] to [target.name].</span>")
			if("No")
				target.visible_message("<span class='warning'> [usr.name] tried to hand [I.name] to [target.name] but [target.name] didn't want it.</span>")
	else
		to_chat(usr, "<span class='warning'> [target.name]'s hands are full.</span>")
