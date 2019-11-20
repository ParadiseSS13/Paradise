/obj/item/toy/UNO
	name = "UNO card"
	desc = "An UNO card."
	icon = 'icons/hispania/obj/UNO.dmi'
	icon_state = "uno"
	burn_state = FLAMMABLE
	var/flip_icon = null
	var/flip_name = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/bag/UNO
	name = "UNO Deck"
	desc = "An UNO Deck. You can empty it on a table"
	icon = 'icons/hispania/obj/UNO.dmi'
	icon_state = "deck"
	storage_slots = 108
	max_combined_w_class = 250
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(/obj/item/toy/UNO)
	use_to_pickup = TRUE
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE
	display_contents_with_number = TRUE

/obj/item/storage/bag/UNO/New()
	..()
	for(var/i in 1 to 4)
		new /obj/item/toy/UNO/wild(src)
		new /obj/item/toy/UNO/d4(src)
	for(var/j in 1 to 2)
		new /obj/item/toy/UNO/g1(src)
		new /obj/item/toy/UNO/g2(src)
		new /obj/item/toy/UNO/g3(src)
		new /obj/item/toy/UNO/g4(src)
		new /obj/item/toy/UNO/g5(src)
		new /obj/item/toy/UNO/g6(src)
		new /obj/item/toy/UNO/g7(src)
		new /obj/item/toy/UNO/g8(src)
		new /obj/item/toy/UNO/g9(src)
		new /obj/item/toy/UNO/gd2(src)
		new /obj/item/toy/UNO/gs(src)
		new /obj/item/toy/UNO/gr(src)
		new /obj/item/toy/UNO/r1(src)
		new /obj/item/toy/UNO/r2(src)
		new /obj/item/toy/UNO/r3(src)
		new /obj/item/toy/UNO/r4(src)
		new /obj/item/toy/UNO/r5(src)
		new /obj/item/toy/UNO/r6(src)
		new /obj/item/toy/UNO/r7(src)
		new /obj/item/toy/UNO/r8(src)
		new /obj/item/toy/UNO/r9(src)
		new /obj/item/toy/UNO/rd2(src)
		new /obj/item/toy/UNO/rs(src)
		new /obj/item/toy/UNO/rr(src)
		new /obj/item/toy/UNO/b1(src)
		new /obj/item/toy/UNO/b2(src)
		new /obj/item/toy/UNO/b3(src)
		new /obj/item/toy/UNO/b4(src)
		new /obj/item/toy/UNO/b5(src)
		new /obj/item/toy/UNO/b6(src)
		new /obj/item/toy/UNO/b7(src)
		new /obj/item/toy/UNO/b8(src)
		new /obj/item/toy/UNO/b9(src)
		new /obj/item/toy/UNO/bd2(src)
		new /obj/item/toy/UNO/bs(src)
		new /obj/item/toy/UNO/br(src)
		new /obj/item/toy/UNO/y1(src)
		new /obj/item/toy/UNO/y2(src)
		new /obj/item/toy/UNO/y3(src)
		new /obj/item/toy/UNO/y4(src)
		new /obj/item/toy/UNO/y5(src)
		new /obj/item/toy/UNO/y6(src)
		new /obj/item/toy/UNO/y7(src)
		new /obj/item/toy/UNO/y8(src)
		new /obj/item/toy/UNO/y9(src)
		new /obj/item/toy/UNO/yd2(src)
		new /obj/item/toy/UNO/ys(src)
		new /obj/item/toy/UNO/yr(src)
	new /obj/item/toy/UNO/g0(src)
	new /obj/item/toy/UNO/r0(src)
	new /obj/item/toy/UNO/b0(src)
	new /obj/item/toy/UNO/y0(src)

/obj/item/toy/UNO/attack_self(mob/user as mob)
	if(icon_state == "uno")
		icon_state = flip_icon
		name = flip_name
		to_chat(user, "<span class='notice'>You flip the card.</span>")
	else
		icon_state = "uno"
		name = "UNO card"
		to_chat(user, "<span class='notice'>You flip the card.</span>")
	return

/obj/item/toy/UNO/wild
	flip_name = "wild card"
	flip_icon = "wild"

/obj/item/toy/UNO/d4
	flip_name = "draw 4"
	flip_icon = "d4"

/obj/item/toy/UNO/g0
	flip_name = "green zero"
	flip_icon = "g0"

/obj/item/toy/UNO/g1
	flip_name = "green one"
	flip_icon = "g1"

/obj/item/toy/UNO/g2
	flip_name = "green two"
	flip_icon = "g2"

/obj/item/toy/UNO/g3
	flip_name = "green three"
	flip_icon = "g3"

/obj/item/toy/UNO/g4
	flip_name = "green four"
	flip_icon = "g4"

/obj/item/toy/UNO/g5
	flip_name = "green five"
	flip_icon = "g5"

/obj/item/toy/UNO/g6
	flip_name = "green six"
	flip_icon = "g6"

/obj/item/toy/UNO/g7
	flip_name = "green seven"
	flip_icon = "g7"

/obj/item/toy/UNO/g8
	flip_name = "green eight"
	flip_icon = "g8"

/obj/item/toy/UNO/g9
	flip_name = "green nine"
	flip_icon = "g9"

/obj/item/toy/UNO/gd2
	flip_name = "green draw 2"
	flip_icon = "gd2"

/obj/item/toy/UNO/gs
	flip_name = "green skip"
	flip_icon = "gs"

/obj/item/toy/UNO/gr
	flip_name = "green reverse"
	flip_icon = "gr"

/obj/item/toy/UNO/r0
	flip_name = "red zero"
	flip_icon = "r0"

/obj/item/toy/UNO/r1
	flip_name = "red one"
	flip_icon = "r1"

/obj/item/toy/UNO/r1
	flip_name = "red one"
	flip_icon = "r1"

/obj/item/toy/UNO/r2
	flip_name = "red two"
	flip_icon = "r2"

/obj/item/toy/UNO/r3
	flip_name = "red three"
	flip_icon = "r3"

/obj/item/toy/UNO/r4
	flip_name = "red four"
	flip_icon = "r4"

/obj/item/toy/UNO/r5
	flip_name = "red five"
	flip_icon = "r5"

/obj/item/toy/UNO/r6
	flip_name = "red six"
	flip_icon = "r6"

/obj/item/toy/UNO/r7
	flip_name = "red seven"
	flip_icon = "r7"

/obj/item/toy/UNO/r8
	flip_name = "red eight"
	flip_icon = "r8"

/obj/item/toy/UNO/r9
	flip_name = "red nine"
	flip_icon = "r9"

/obj/item/toy/UNO/rd2
	flip_name = "red draw 2"
	flip_icon = "rd2"

/obj/item/toy/UNO/rs
	flip_name = "red skip"
	flip_icon = "rs"

/obj/item/toy/UNO/rr
	flip_name = "red reverse"
	flip_icon = "rr"

/obj/item/toy/UNO/b0
	flip_name = "blue zero"
	flip_icon = "b0"

/obj/item/toy/UNO/b1
	flip_name = "blue one"
	flip_icon = "b1"

/obj/item/toy/UNO/b2
	flip_name = "blue two"
	flip_icon = "b2"

/obj/item/toy/UNO/b3
	flip_name = "blue three"
	flip_icon = "b3"

/obj/item/toy/UNO/b4
	flip_name = "blue four"
	flip_icon = "b4"

/obj/item/toy/UNO/b5
	flip_name = "blue five"
	flip_icon = "b5"

/obj/item/toy/UNO/b6
	flip_name = "blue six"
	flip_icon = "b6"

/obj/item/toy/UNO/b7
	flip_name = "blue seven"
	flip_icon = "b7"

/obj/item/toy/UNO/b8
	flip_name = "blue eight"
	flip_icon = "b8"

/obj/item/toy/UNO/b9
	flip_name = "blue nine"
	flip_icon = "b9"

/obj/item/toy/UNO/bd2
	flip_name = "blue draw 2"
	flip_icon = "bd2"

/obj/item/toy/UNO/bs
	flip_name = "blue skip"
	flip_icon = "bs"

/obj/item/toy/UNO/br
	flip_name = "blue reverse"
	flip_icon = "br"

/obj/item/toy/UNO/y0
	flip_name = "yellow zero"
	flip_icon = "y0"

/obj/item/toy/UNO/y1
	flip_name = "yellow one"
	flip_icon = "y1"

/obj/item/toy/UNO/y2
	flip_name = "yellow two"
	flip_icon = "y2"

/obj/item/toy/UNO/y3
	flip_name = "yellow three"
	flip_icon = "y3"

/obj/item/toy/UNO/y4
	flip_name = "yellow four"
	flip_icon = "y4"

/obj/item/toy/UNO/y5
	flip_name = "yellow five"
	flip_icon = "y5"

/obj/item/toy/UNO/y6
	flip_name = "yellow six"
	flip_icon = "y6"

/obj/item/toy/UNO/y7
	flip_name = "yellow seven"
	flip_icon = "y7"

/obj/item/toy/UNO/y8
	flip_name = "yellow eight"
	flip_icon = "y8"

/obj/item/toy/UNO/y9
	flip_name = "yellow nine"
	flip_icon = "y9"

/obj/item/toy/UNO/yd2
	flip_name = "yellow draw 2"
	flip_icon = "yd2"

/obj/item/toy/UNO/ys
	flip_name = "yellow skip"
	flip_icon = "ys"

/obj/item/toy/UNO/yr
	flip_name = "yellow reverse"
	flip_icon = "yr"