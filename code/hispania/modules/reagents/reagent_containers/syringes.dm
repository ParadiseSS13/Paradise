/obj/item/reagent_containers/syringe/proc/syringedump(atom/target, mob/user)
	if(isfloorturf(target))
		if(!reagents.total_volume)
			to_chat(user, "<span class='notice'>[src] is empty.</span>")
			return
		if(user.a_intent == INTENT_HARM)
			user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
							"<span class='notice'>You splash the contents of [src] onto [target].</span>")
			reagents.reaction(target, REAGENT_TOUCH)
			reagents.clear_reagents()
		if(user.a_intent == INTENT_HELP)
			user.visible_message("<span class='danger'>[user] almost splash the contents of [src] onto [target]!</span>")
	return
