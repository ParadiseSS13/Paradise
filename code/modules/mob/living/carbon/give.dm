/mob/living/carbon/verb/give(mob/living/carbon/target in oview(1))
	set category = "IC"
	set name = "Give"

	if(!iscarbon(target)) //something is bypassing the give arguments, no clue what, adding a sanity check JIC
		to_chat(usr, span_danger("Wait a second... \the [target] HAS NO HANDS! AHH!"))//cheesy messages ftw
		return

	if(target.incapacitated() || usr.incapacitated() || target.client == null)
		return

	var/obj/item/I = get_active_hand()

	if(!I)
		to_chat(usr, span_warning(" You don't have anything in your hand to give to [target.name]"))
		return
	if((I.flags & NODROP) || (I.flags & ABSTRACT))
		to_chat(usr, span_notice("That's not exactly something you can give."))
		return
	if(target.r_hand == null || target.l_hand == null)
		var/ans = alert(target,"[usr] wants to give you \a [I]?",,"Yes","No")
		if(!I || !target)
			return
		switch(ans)
			if("Yes")
				if(target.incapacitated() || usr.incapacitated())
					return
				if(!Adjacent(target))
					to_chat(usr, span_warning(" You need to stay in reaching distance while giving an object."))
					to_chat(target, span_warning(" [usr.name] moved too far away."))
					return
				if((I.flags & NODROP) || (I.flags & ABSTRACT))
					to_chat(usr, span_warning("[I] stays stuck to your hand when you try to give it!"))
					to_chat(target, span_warning("[I] stays stuck to [usr.name]'s hand when you try to take it!"))
					return
				if(I != get_active_hand())
					to_chat(usr, span_warning(" You need to keep the item in your active hand."))
					to_chat(target, span_warning(" [usr.name] seem to have given up on giving [I] to you."))
					return
				if(target.r_hand != null && target.l_hand != null)
					to_chat(target, span_warning(" Your hands are full."))
					to_chat(usr, span_warning(" Their hands are full."))
					return
				usr.unEquip(I)
				target.put_in_hands(I)
				I.add_fingerprint(target)
				target.visible_message(span_notice(" [usr.name] handed [I] to [target.name]."))
				I.on_give(usr, target)
			if("No")
				target.visible_message(span_warning(" [usr.name] tried to hand [I] to [target.name] but [target.name] didn't want it."))
	else
		to_chat(usr, span_warning(" [target.name]'s hands are full."))
