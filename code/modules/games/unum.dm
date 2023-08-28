/// A deck of unum cards. Classic.
/obj/item/deck/unum
	name = "\improper UNUM! deck"
	desc = "A deck of UNUM! cards. House rules to argue over not included."
	icon_state = "deck_unum_full"
	card_style = "unum"

/obj/item/deck/unum/build_deck()
	for(var/colour in list("Red", "Yellow", "Green", "Blue"))
		cards += new /datum/playingcard("[colour] 0", "sc_[colour] 0_[card_style]", "singlecard_down_[card_style]")
		for(var/k in 0 to 1)
			cards += new /datum/playingcard("[colour] skip", "sc_[colour] skip_[card_style]", "singlecard_down_[card_style]")
			cards += new /datum/playingcard("[colour] reverse", "sc_[colour] reverse_[card_style]", "singlecard_down_[card_style]")
			cards += new /datum/playingcard("[colour] draw 2", "sc_[colour] draw 2_[card_style]", "singlecard_down_[card_style]")
			for(var/i in 1 to 9)
				cards += new /datum/playingcard("[colour] [i]", "sc_[colour] [i]_[card_style]", "singlecard_down_[card_style]")
	for(var/k in 0 to 3)
		cards += new /datum/playingcard("Wildcard", "sc_Wildcard_[card_style]", "singlecard_down_[card_style]")
		cards += new /datum/playingcard("Draw 4", "sc_Draw 4_[card_style]", "singlecard_down_[card_style]")

/obj/item/deck/unum/update_icon_state()
	if(!length(cards))
		icon_state = "deck_[card_style]_empty"
		return
	var/percent = round((length(cards) / deck_total) * 100)
	switch(percent)
		if(0 to 20)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_low"
		if(21 to 50)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_half"
		else
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_full"

