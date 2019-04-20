/mob/living/carbon/verb/give(var/mob/living/carbon/target in oview(1))
	set category = "IC"
	set name = "Give"

	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, "<span class='danger'>Wait a second... \the [target] HAS NO HANDS! AHH!</span>")//cheesy messages ftw
		return

	if(target.incapacitated() || usr.incapacitated() || target.client == null)
		return
	
	var/obj/item/I = get_active_hand()

	if(!I)
		to_chat(usr, "<span class='warning'> You don't have anything in your hand to give to [target.name]</span>")
		return
	if((I.flags & NODROP) || (I.flags & ABSTRACT))
		to_chat(usr, "<span class='notice'>That's not exactly something you can give.</span>")
		return
	if(target.r_hand == null || target.l_hand == null)
		switch(alert(target,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I)
					return
				if(target.incapacitated() || usr.incapacitated())
					return
				if(!Adjacent(target))
					to_chat(usr, "<span class='warning'> You need to stay in reaching distance while giving an object.</span>")
					to_chat(target, "<span class='warning'> [usr.name] moved too far away.</span>")
					return
				if((I.flags & NODROP) || (I.flags & ABSTRACT))
					to_chat(usr, "<span class='warning'>[I] stays stuck to your hand when you try to give it!</span>")
					to_chat(target, "<span class='warning'>[I] stays stuck to [usr.name]'s hand when you try to take it!</span>")
					return
				if(I != get_active_hand())
					to_chat(usr, "<span class='warning'> You need to keep the item in your active hand.</span>")
					to_chat(target, "<span class='warning'> [usr.name] seem to have given up on giving [I] to you.</span>")
					return
				if(target.r_hand != null && target.l_hand != null)
					to_chat(target, "<span class='warning'> Your hands are full.</span>")
					to_chat(usr, "<span class='warning'> Their hands are full.</span>")
					return
				usr.unEquip(I)
				target.put_in_hands(I)
				I.add_fingerprint(target)
				target.visible_message("<span class='notice'> [usr.name] handed [I] to [target.name].</span>")
				I.on_give(usr, target)
			if("No")
				target.visible_message("<span class='warning'> [usr.name] tried to hand [I] to [target.name] but [target.name] didn't want it.</span>")
	else
		to_chat(usr, "<span class='warning'> [target.name]'s hands are full.</span>")
