/obj/item/paper_bin
	name = "paper bin"
	desc = "The second-most important part of bureaucracy, after the pen of course."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	throwforce = 1
	throw_speed = 3
	pressure_resistance = 8
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = list()	//List of papers put in the bin for reference.
	var/letterhead_type

/obj/item/paper_bin/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(amount)
		amount = 0
		update_icon()
	..()

/obj/item/paper_bin/Destroy()
	QDEL_LIST_CONTENTS(papers)
	return ..()

/obj/item/paper_bin/burn()
	amount = 0
	extinguish()
	update_icon()

/obj/item/paper_bin/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(M.restrained() || M.stat || !Adjacent(M))
		return
	if(!ishuman(M))
		return

	if(over_object == M)
		if(!remove_item_from_storage(M))
			M.drop_item_to_ground(src)
		M.put_in_hands(src)

	else if(is_screen_atom(over_object))
		switch(over_object.name)
			if("r_hand")
				if(!remove_item_from_storage(M))
					M.drop_item_to_ground(src)
				M.put_in_r_hand(src)
			if("l_hand")
				if(!remove_item_from_storage(M))
					M.drop_item_to_ground(src)
				M.put_in_l_hand(src)

	add_fingerprint(M)


/obj/item/paper_bin/attack_hand(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(H.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(H, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon()

		var/obj/item/paper/P
		if(length(papers) > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[length(papers)]
			papers.Remove(P)
		else
			var/choice = letterhead_type ? tgui_alert(user, "Choose a style", "Paperbin", list("Letterhead", "Blank", "Cancel")) : "Blank"
			if(isnull(choice) || !Adjacent(user))
				return
			switch(choice)
				if("Letterhead")
					P = new letterhead_type
				if("Blank")
					P = new /obj/item/paper
				if("Cancel")
					return

			if(isnull(P))
				return

			if(SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = TRUE
					P.updateinfolinks()

		P.loc = user.loc
		user.put_in_hands(P)
		P.add_fingerprint(user)
		P.scatter_atom()
		to_chat(user, "<span class='notice'>You take [P] out of [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

	add_fingerprint(user)
	return


/obj/item/paper_bin/attackby__legacy__attackchain(obj/item/paper/i as obj, mob/user as mob, params)
	if(istype(i))
		user.drop_item()
		i.loc = src
		to_chat(user, "<span class='notice'>You put [i] in [src].</span>")
		papers.Add(i)
		amount++
	else
		return ..()


/obj/item/paper_bin/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(amount)
			. += "<span class='notice'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>"
		else
			. += "<span class='notice'>There are no papers in the bin.</span>"


/obj/item/paper_bin/update_icon_state()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"

/obj/item/paper_bin/carbon
	name = "carbonless paper bin"
	icon_state = "paper_bin2"

/obj/item/paper_bin/carbon/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon()

		var/obj/item/paper/carbon/P
		if(length(papers) > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[length(papers)]
			papers.Remove(P)
		else
			P = new /obj/item/paper/carbon
		P.loc = user.loc
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

	add_fingerprint(user)
	return


/obj/item/paper_bin/nanotrasen
	name = "nanotrasen paper bin"
	letterhead_type = /obj/item/paper/nanotrasen

/obj/item/paper_bin/syndicate
	name = "syndicate paper bin"
	letterhead_type = /obj/item/paper/syndicate

