/mob/living/carbon/verb/give(var/mob/living/carbon/target in oview(1))
	set category = "IC"
	set name = "Give"

	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, "<span class='danger'>Wait a second... \the [target] HAS NO HANDS! AHH!</span>")//cheesy messages ftw

		return
	if(target.stat == 2 || usr.stat == 2|| target.client == null)
		return
	var/obj/item/I = usr.get_active_held_item()
	if(I == null)
		to_chat(usr, "<span class='warning'> You don't have anything in your [usr.get_held_index_name(usr.active_hand_index)] to give to [target.name]</span>")
		return
	if(!I)
		return
	if((I.flags & NODROP) || (I.flags & ABSTRACT))
		to_chat(usr, "<span class='notice'>That's not exactly something you can give.</span>")
		return
	var/target_index = target.get_empty_held_index()
	if(target_index)
		switch(alert(target,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(!Adjacent(usr))
					to_chat(usr, "<span class='warning'> You need to stay in reaching distance while giving an object.</span>")
					to_chat(target, "<span class='warning'> [usr.name] moved too far away.</span>")
					return
				if(I != usr.get_active_held_item())
					to_chat(usr, "<span class='warning'> You need to keep the item in your active hand.</span>")
					to_chat(target, "<span class='warning'> [usr.name] seem to have given up on giving \the [I.name] to you.</span>")
					return
				if(!target.get_empty_held_index())
					to_chat(target, "<span class='warning'> Your hands are full.</span>")
					to_chat(usr, "<span class='warning'> Their hands are full.</span>")
					return
				else
					usr.drop_item()
					target.put_in_hands(I)
				I.add_fingerprint(target)
				src.update_inv_hands()
				target.update_inv_hands()
				target.visible_message("<span class='notice'> [usr.name] handed \the [I.name] to [target.name].</span>")
			if("No")
				target.visible_message("<span class='warning'> [usr.name] tried to hand [I.name] to [target.name] but [target.name] didn't want it.</span>")
	else
		to_chat(usr, "<span class='warning'> [target.name]'s hands are full.</span>")
