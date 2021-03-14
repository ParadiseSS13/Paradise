/obj/item/toy/uno
	name = "UNO card"
	desc = "An UNO card."
	icon = 'icons/hispania/obj/uno.dmi'
	icon_state = "uno"
	resistance_flags = FLAMMABLE
	var/flip_icon
	var/flip_name
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/uno/attack_self(mob/user)
	if(icon_state == "uno")
		icon_state = flip_icon
		name = flip_name
		to_chat(user, "<span class='notice'>You flip the card.</span>")
	else
		icon_state = "uno"
		name = "UNO card"
		to_chat(user, "<span class='notice'>You flip the card.</span>")
	return

/obj/item/storage/bag/uno
	name = "UNO Deck"
	desc = "An UNO Deck. An ancient card game used to destroy friendships."
	icon = 'icons/hispania/obj/uno.dmi'
	icon_state = "deck"
	storage_slots = 108
	max_combined_w_class = 250
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	can_hold = list(/obj/item/toy/uno, /obj/item/cardholder, /obj/item/cardholder/withcards)
	use_to_pickup = TRUE
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = FALSE

/obj/item/storage/bag/uno/New()
	..()
	new /obj/item/cardholder/withcards(src)
	for(var/j in 1 to 13)
		new /obj/item/cardholder(src)

/obj/item/cardholder
	name = "UNO Cardholder"
	desc = "An UNO Cardholder. For holding UNO cards."
	icon = 'icons/hispania/obj/uno.dmi'
	icon_state = "holder_e"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/cardholder/withcards
	icon_state = "holder_f" // One starts with cards to be used as the initial deck.

/obj/item/cardholder/Destroy()
	QDEL_LIST(contents)
	return ..()

/obj/item/cardholder/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(M.restrained() || M.stat || !Adjacent(M))
		return
	if(!ishuman(M))
		return

	if(over_object == M)
		if(!remove_item_from_storage(M))
			M.unEquip(src)
		M.put_in_hands(src)

	else if(istype(over_object, /obj/screen))
		switch(over_object.name)
			if("r_hand")
				if(!remove_item_from_storage(M))
					M.unEquip(src)
				M.put_in_r_hand(src)
			if("l_hand")
				if(!remove_item_from_storage(M))
					M.unEquip(src)
				M.put_in_l_hand(src)
	add_fingerprint(M)

/obj/item/cardholder/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/toy/uno))
		var/obj/item/toy/uno/last_card = W
		user.drop_item()
		W.loc = src
		if(get_turf(src) == get_turf(user))
			to_chat(user, "<span class='notice'>You put [W] in [src].</span>")
		else
			user.visible_message("<span class='notice'>[user] puts [W] in [src].</span>")
		contents.Add(W)
		overlays += last_card.icon_state
	if(istype(W, /obj/item/cardholder))
		for(var/obj/item/toy/uno/C in W.contents)
			W.contents.Remove(C)
			C.loc = src.loc
			contents.Add(C)
			C.icon_state = "uno"
			C.name = "UNO card"
		W.icon_state = "holder_e"
		W.cut_overlays()
		icon_state = "holder_f"
		cut_overlays()
		user.visible_message("<span class='notice'>[user] puts all the UNO cards of [W] in [src] and shuffles them.</span>")
		contents = shuffle(contents)
	else
		return ..()

/obj/item/cardholder/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(H.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(H, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return

	add_fingerprint(user)
	var/obj/item/toy/uno/C
	if(contents.len == 1) //Takes the last card and empties the holder.
		C = contents[contents.len]
		contents.Remove(C)
		C.loc = user.loc
		user.put_in_hands(C)
		to_chat(user, "<span class='notice'></span>")
		if(get_turf(src) == get_turf(user))
			to_chat(user, "<span class='notice'>You take [C] out of the [src].</span>")
		else
			user.visible_message("<span class='notice'>[user] takes [C] out of the [src].</span>")
		cut_overlays()
		icon_state = "holder_e"
		return
	if(contents.len > 1) //Takes the top card and shows the previous one.
		C = contents[contents.len]
		var/obj/item/toy/uno/D
		D = contents[contents.len-1]
		overlays += D.icon_state
		contents.Remove(C)
		C.loc = user.loc
		user.put_in_hands(C)
		if(get_turf(src) == get_turf(user))
			to_chat(user, "<span class='notice'>You take [C] out of the [src].</span>")
		else
			user.visible_message("<span class='notice'>[user] takes [C] out of the [src].</span>")
		return
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

/obj/item/cardholder/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(contents.len > 0)
			. += "<span class='notice'>There " + (contents.len > 1 ? "are [contents.len] UNO cards" : "is 1 UNO card") + " in the cardholder.</span>"
		else
			. += "<span class='notice'>There are no UNO cards in the cardholder.</span>"

/obj/item/cardholder/withcards/New()
	..()
	for(var/j in 1 to 2)
		new /obj/item/toy/uno/g1(src)
		new /obj/item/toy/uno/g2(src)
		new /obj/item/toy/uno/g3(src)
		new /obj/item/toy/uno/g4(src)
		new /obj/item/toy/uno/g5(src)
		new /obj/item/toy/uno/g6(src)
		new /obj/item/toy/uno/g7(src)
		new /obj/item/toy/uno/g8(src)
		new /obj/item/toy/uno/g9(src)
		new /obj/item/toy/uno/gd2(src)
		new /obj/item/toy/uno/gs(src)
		new /obj/item/toy/uno/gr(src)
		new /obj/item/toy/uno/r1(src)
		new /obj/item/toy/uno/r2(src)
		new /obj/item/toy/uno/r3(src)
		new /obj/item/toy/uno/r4(src)
		new /obj/item/toy/uno/r5(src)
		new /obj/item/toy/uno/r6(src)
		new /obj/item/toy/uno/r7(src)
		new /obj/item/toy/uno/r8(src)
		new /obj/item/toy/uno/r9(src)
		new /obj/item/toy/uno/rd2(src)
		new /obj/item/toy/uno/rs(src)
		new /obj/item/toy/uno/rr(src)
		new /obj/item/toy/uno/b1(src)
		new /obj/item/toy/uno/b2(src)
		new /obj/item/toy/uno/b3(src)
		new /obj/item/toy/uno/b4(src)
		new /obj/item/toy/uno/b5(src)
		new /obj/item/toy/uno/b6(src)
		new /obj/item/toy/uno/b7(src)
		new /obj/item/toy/uno/b8(src)
		new /obj/item/toy/uno/b9(src)
		new /obj/item/toy/uno/bd2(src)
		new /obj/item/toy/uno/bs(src)
		new /obj/item/toy/uno/br(src)
		new /obj/item/toy/uno/y1(src)
		new /obj/item/toy/uno/y2(src)
		new /obj/item/toy/uno/y3(src)
		new /obj/item/toy/uno/y4(src)
		new /obj/item/toy/uno/y5(src)
		new /obj/item/toy/uno/y6(src)
		new /obj/item/toy/uno/y7(src)
		new /obj/item/toy/uno/y8(src)
		new /obj/item/toy/uno/y9(src)
		new /obj/item/toy/uno/yd2(src)
		new /obj/item/toy/uno/ys(src)
		new /obj/item/toy/uno/yr(src)
	for(var/i in 1 to 4)
		new /obj/item/toy/uno/wild(src)
		new /obj/item/toy/uno/d4(src)
	new /obj/item/toy/uno/g0(src)
	new /obj/item/toy/uno/r0(src)
	new /obj/item/toy/uno/b0(src)
	new /obj/item/toy/uno/y0(src)
	contents = shuffle(contents)

/obj/item/toy/uno/wild
	flip_name = "wild card"
	flip_icon = "wild"

/obj/item/toy/uno/d4
	flip_name = "draw 4"
	flip_icon = "d4"

/obj/item/toy/uno/g0
	flip_name = "green zero"
	flip_icon = "g0"

/obj/item/toy/uno/g1
	flip_name = "green one"
	flip_icon = "g1"

/obj/item/toy/uno/g2
	flip_name = "green two"
	flip_icon = "g2"

/obj/item/toy/uno/g3
	flip_name = "green three"
	flip_icon = "g3"

/obj/item/toy/uno/g4
	flip_name = "green four"
	flip_icon = "g4"

/obj/item/toy/uno/g5
	flip_name = "green five"
	flip_icon = "g5"

/obj/item/toy/uno/g6
	flip_name = "green six"
	flip_icon = "g6"

/obj/item/toy/uno/g7
	flip_name = "green seven"
	flip_icon = "g7"

/obj/item/toy/uno/g8
	flip_name = "green eight"
	flip_icon = "g8"

/obj/item/toy/uno/g9
	flip_name = "green nine"
	flip_icon = "g9"

/obj/item/toy/uno/gd2
	flip_name = "green draw 2"
	flip_icon = "gd2"

/obj/item/toy/uno/gs
	flip_name = "green skip"
	flip_icon = "gs"

/obj/item/toy/uno/gr
	flip_name = "green reverse"
	flip_icon = "gr"

/obj/item/toy/uno/r0
	flip_name = "red zero"
	flip_icon = "r0"

/obj/item/toy/uno/r1
	flip_name = "red one"
	flip_icon = "r1"

/obj/item/toy/uno/r1
	flip_name = "red one"
	flip_icon = "r1"

/obj/item/toy/uno/r2
	flip_name = "red two"
	flip_icon = "r2"

/obj/item/toy/uno/r3
	flip_name = "red three"
	flip_icon = "r3"

/obj/item/toy/uno/r4
	flip_name = "red four"
	flip_icon = "r4"

/obj/item/toy/uno/r5
	flip_name = "red five"
	flip_icon = "r5"

/obj/item/toy/uno/r6
	flip_name = "red six"
	flip_icon = "r6"

/obj/item/toy/uno/r7
	flip_name = "red seven"
	flip_icon = "r7"

/obj/item/toy/uno/r8
	flip_name = "red eight"
	flip_icon = "r8"

/obj/item/toy/uno/r9
	flip_name = "red nine"
	flip_icon = "r9"

/obj/item/toy/uno/rd2
	flip_name = "red draw 2"
	flip_icon = "rd2"

/obj/item/toy/uno/rs
	flip_name = "red skip"
	flip_icon = "rs"

/obj/item/toy/uno/rr
	flip_name = "red reverse"
	flip_icon = "rr"

/obj/item/toy/uno/b0
	flip_name = "blue zero"
	flip_icon = "b0"

/obj/item/toy/uno/b1
	flip_name = "blue one"
	flip_icon = "b1"

/obj/item/toy/uno/b2
	flip_name = "blue two"
	flip_icon = "b2"

/obj/item/toy/uno/b3
	flip_name = "blue three"
	flip_icon = "b3"

/obj/item/toy/uno/b4
	flip_name = "blue four"
	flip_icon = "b4"

/obj/item/toy/uno/b5
	flip_name = "blue five"
	flip_icon = "b5"

/obj/item/toy/uno/b6
	flip_name = "blue six"
	flip_icon = "b6"

/obj/item/toy/uno/b7
	flip_name = "blue seven"
	flip_icon = "b7"

/obj/item/toy/uno/b8
	flip_name = "blue eight"
	flip_icon = "b8"

/obj/item/toy/uno/b9
	flip_name = "blue nine"
	flip_icon = "b9"

/obj/item/toy/uno/bd2
	flip_name = "blue draw 2"
	flip_icon = "bd2"

/obj/item/toy/uno/bs
	flip_name = "blue skip"
	flip_icon = "bs"

/obj/item/toy/uno/br
	flip_name = "blue reverse"
	flip_icon = "br"

/obj/item/toy/uno/y0
	flip_name = "yellow zero"
	flip_icon = "y0"

/obj/item/toy/uno/y1
	flip_name = "yellow one"
	flip_icon = "y1"

/obj/item/toy/uno/y2
	flip_name = "yellow two"
	flip_icon = "y2"

/obj/item/toy/uno/y3
	flip_name = "yellow three"
	flip_icon = "y3"

/obj/item/toy/uno/y4
	flip_name = "yellow four"
	flip_icon = "y4"

/obj/item/toy/uno/y5
	flip_name = "yellow five"
	flip_icon = "y5"

/obj/item/toy/uno/y6
	flip_name = "yellow six"
	flip_icon = "y6"

/obj/item/toy/uno/y7
	flip_name = "yellow seven"
	flip_icon = "y7"

/obj/item/toy/uno/y8
	flip_name = "yellow eight"
	flip_icon = "y8"

/obj/item/toy/uno/y9
	flip_name = "yellow nine"
	flip_icon = "y9"

/obj/item/toy/uno/yd2
	flip_name = "yellow draw 2"
	flip_icon = "yd2"

/obj/item/toy/uno/ys
	flip_name = "yellow skip"
	flip_icon = "ys"

/obj/item/toy/uno/yr
	flip_name = "yellow reverse"
	flip_icon = "yr"
