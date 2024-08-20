/// A deck of unum cards. Classic.
/obj/item/deck/unum
	name = "\improper UNUM! deck"
	desc = "A deck of UNUM! cards. House rules to argue over not included."
	icon_state = "deck_unum_full"
	card_style = "unum"
	/// Whether or not this deck should show the backs or fronts of its cards.
	var/show_front = FALSE

/obj/item/deck/unum/examine(mob/user)
	. = ..()
	. += "<span class='notice'>When held in hand, <b>Alt-Shift-Click</b> to flip [src].</span>"

/obj/item/deck/unum/AltShiftClick(mob/user)
	if(!Adjacent(user) || (user.get_active_hand() != src) && (user.get_inactive_hand() != src))
		return
	show_front = !show_front
	visible_message("<span class='notice'>[user] flips over [src].</span>")
	update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/deck/unum/build_deck()
	for(var/color in list("Red", "Yellow", "Green", "Blue"))
		cards += new /datum/playingcard("[color] 0", "sc_[color] 0_[card_style]", "singlecard_down_[card_style]")
		for(var/k in 0 to 1)
			cards += new /datum/playingcard("[color] skip", "sc_[color] skip_[card_style]", "singlecard_down_[card_style]")
			cards += new /datum/playingcard("[color] reverse", "sc_[color] reverse_[card_style]", "singlecard_down_[card_style]")
			cards += new /datum/playingcard("[color] draw 2", "sc_[color] draw 2_[card_style]", "singlecard_down_[card_style]")
			for(var/i in 1 to 9)
				cards += new /datum/playingcard("[color] [i]", "sc_[color] [i]_[card_style]", "singlecard_down_[card_style]")
	for(var/k in 0 to 3)
		cards += new /datum/playingcard("Wildcard", "sc_Wildcard_[card_style]", "singlecard_down_[card_style]")
		cards += new /datum/playingcard("Draw 4", "sc_Draw 4_[card_style]", "singlecard_down_[card_style]")

/obj/item/deck/unum/update_icon_state()
	if(!length(cards))
		icon_state = "deck_[card_style]_empty"
		show_front = FALSE
		return
	var/percent = round((length(cards) / deck_total) * 100)
	switch(percent)
		if(0 to 20)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_low"
		if(21 to 50)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_half"
		else
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_full"

/obj/item/deck/unum/update_overlays()
	. = ..()
	if(!length(cards) || !show_front)
		return
	var/percent = round((length(cards) / deck_total) * 100)
	var/datum/playingcard/P = cards[1]
	var/image/I = new(icon, P.card_icon)
	switch(percent)
		if(0 to 20)
			I.pixel_y = 1
		if(21 to 50)
			I.pixel_y = 2
		else
			I.pixel_y = 4
	. += I


