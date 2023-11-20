/obj/item/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	materials = list(MAT_METAL=100)
	origin_tech = "combat=1;materials=2;engineering=1"
	var/armed = FALSE

	bomb_name = "contact mine"

/obj/item/assembly/mousetrap/examine(mob/user)
	. = ..()
	if(armed)
		. += "It looks like it's armed."
	. += "<span class='notice'><b>Alt-Click</b> to hide it.</span>"

/obj/item/assembly/mousetrap/activate()
	if(!..())
		return

	armed = !armed
	if(!armed)
		if(ishuman(usr))
			var/mob/living/carbon/human/user = usr
			if((user.getBrainLoss() >= 60 || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
				to_chat(user, "Your hand slips, setting off the trigger.")
				pulse(0)

	update_icon()

	if(usr)
		playsound(usr.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)


/obj/item/assembly/mousetrap/update_icon_state()
	icon_state = "mousetrap[armed ? "armed": ""]"
	if(holder)
		holder.update_icon()

/obj/item/assembly/mousetrap/proc/triggered(mob/target, type = "feet")
	if(!armed)
		return

	var/obj/item/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
			armed = FALSE
			update_icon()
			pulse(FALSE)
			return FALSE

		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_organ(pick("l_leg", "r_leg"))
					H.Weaken(6 SECONDS)

			if("l_hand", "r_hand")
				if(!H.gloves)
					affecting = H.get_organ(type)
					H.Stun(6 SECONDS)

		if(affecting)
			affecting.receive_damage(1, 0)

	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message("<span class='danger'>SPLAT!</span>")
		M.death()
		M.splat()

	playsound(loc, 'sound/effects/snap.ogg', 50, 1)
	layer = MOB_LAYER - 0.2
	armed = FALSE
	update_icon()
	pulse(0)

/obj/item/assembly/mousetrap/attack_self(mob/living/user)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		if((user.getBrainLoss() >= 60 || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"

			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking [user.p_their()] fingers.</span>", "<span class='warning'>You accidentally trigger [src]!</span>")
			return

		to_chat(user, "<span class='notice'>You disarm [src].</span>")

	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)

/obj/item/assembly/mousetrap/attack_hand(mob/living/user)
	if(armed)
		if((user.getBrainLoss() >= 60 || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"

			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking [user.p_their()] fingers.</span>", "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()

/obj/item/assembly/mousetrap/Crossed(atom/movable/AM, oldloc)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == MOVE_INTENT_RUN)
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", "<span class='warning'>You accidentally step on [src]</span>")

		else if(ismouse(AM))
			triggered(AM)

		else if(AM.density) // For mousetrap grenades, set off by anything heavy
			triggered(AM)

	..()

/obj/item/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking [finder.p_their()] fingers.</span>", "<span class='warning'>You accidentally trigger [src]!</span>")
		triggered(finder, finder.hand ? "l_hand" : "r_hand")
		return TRUE	//end the search!

	return FALSE

/obj/item/assembly/mousetrap/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!armed)
		return ..()

	visible_message("<span class='warning'>[src] is triggered by [AM].</span>")
	triggered(null)

/obj/item/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = TRUE


/obj/item/assembly/mousetrap/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	layer = TURF_LAYER + 0.2
	to_chat(user, "<span class='notice'>You hide [src].</span>")
