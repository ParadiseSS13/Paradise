/obj/item/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
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
	QDEL_LIST(papers)
	return ..()

/obj/item/paper_bin/burn()
	amount = 0
	extinguish()
	update_icon()


/obj/item/paper_bin/MouseDrop(atom/over)
	. = ..()
	if(!.)
		return FALSE

	var/mob/user = usr
	if(over != user || user.incapacitated() || !ishuman(user))
		return FALSE

	if(user.put_in_hands(src, ignore_anim = FALSE))
		add_fingerprint(user)
		user.visible_message(span_notice("[user] picks up [src]."))
		return TRUE

	return FALSE


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
		if(papers.len > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
			P.forceMove_turf()
		else
			if(letterhead_type && alert("Choose a style",,"Letterhead","Blank")=="Letterhead")
				P = new letterhead_type(drop_location())
			else
				P = new /obj/item/paper(drop_location())
			if(SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()
		if(in_range(user, src))
			user.put_in_hands(P, ignore_anim = FALSE)
			P.add_fingerprint(user)
			to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

	add_fingerprint(user)
	return


/obj/item/paper_bin/attackby(obj/item/paper/I, mob/user, params)
	if(istype(I))
		user.drop_transfer_item_to_loc(I, src)
		to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		papers.Add(I)
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

/obj/item/paper_bin/update_icon()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"
	..()

/obj/item/paper_bin/carbon
	name = "carbonless paper bin"
	icon_state = "paper_bin2"

/obj/item/paper_bin/carbon/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--
		if(amount==0)
			update_icon()

		var/obj/item/paper/carbon/P
		if(papers.len > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
		else
			P = new /obj/item/paper/carbon(drop_location())
		user.put_in_hands(P, ignore_anim = FALSE)
		to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")
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

/obj/item/paper_bin/ussp
	name = "ussp paper bin"
	letterhead_type = /obj/item/paper/ussp
