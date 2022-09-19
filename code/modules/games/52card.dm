/obj/item/deck/holder
	name = "card box"
	desc = "A small leather case to show how classy you are compared to everyone else."
	icon_state = "card_holder"

/obj/item/deck/cards
	name = "deck of cards"
	desc = "A simple deck of playing cards."
	icon_state = "deck_nanotrasen_full"
	card_style = "nanotrasen"

/obj/item/deck/cards/build_deck()
	for(var/suit in list("Spades","Clubs","Diamonds","Hearts"))
		var/card_appearance
		var/colour
		var/rank
		if(simple_deck)
			if(suit in list("Spades","Clubs"))
				colour = "black"
			else
				colour = "red"
		for(var/number in list("Ace","2","3","4","5","6","7","8","9","10","Jack","Queen","King"))
			if(simple_deck)
				if(number in list("Jack","Queen","King"))
					rank = "col"
				else
					rank = "num"
				card_appearance = "sc_[colour]_[rank]_[card_style]"
			else
				card_appearance = "sc_[number] of [suit]_[card_style]"
			cards += new /datum/playingcard("[number] of [suit]", card_appearance, "singlecard_down_[card_style]")

	for(var/jokers in 1 to 2)
		cards += new /datum/playingcard("Joker", "sc_Joker_[card_style]", "singlecard_down_[card_style]")

/obj/item/deck/cards/update_icon_state()
	if(!length(cards))
		icon_state = "deck_[card_style]_empty"
		return
	var/percent = round((length(cards) / deck_total) * 100) // Rounding due to switch freaking out
	switch(percent)
		if(0 to 20)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_low"
		if(21 to 50)
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_half"
		else
			icon_state = "deck_[deck_style ? "[deck_style]_" : ""][card_style]_full"

/obj/item/deck/cards/doublecards
		name = "double deck of cards"
		icon_state = "deck_double_nanotrasen_full"
		desc = "A simple deck of playing cards. Multiplied by two. Does not necessarily come with twice the fun."
		deck_size = 2
		deck_style = "double"

/obj/item/deck/cards/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	icon_state = "deck_syndicate_full"
	card_style = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_attack_verb = list("attacked", "sliced", "diced", "slashed", "cut")
	card_resistance_flags = NONE

/obj/item/deck/cards/black
	card_style = "black"

/obj/item/deck/cards/syndicate/black
	card_style = "black"

/obj/item/deck/cards/tiny
	name = "deck of tiny cards"
	desc = "A simple deck of tiny playing cards."
	icon_state = "deck"
	card_style = "simple"
	simple_deck = TRUE

/obj/item/deck/cards/tiny/update_icon_state()
	return

/obj/item/deck/cards/tiny/doublecards
	name = "double deck of tiny cards"
	desc = "A simple deck of tiny playing cards. Multiplied by two. Does not necessarily come with twice the fun."
	icon_state = "doubledeck"
	deck_size = 2
