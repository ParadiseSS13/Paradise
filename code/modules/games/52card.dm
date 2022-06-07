/obj/item/deck/holder
	name = "card box"
	desc = "A small leather case to show how classy you are compared to everyone else."
	icon_state = "card_holder"

/obj/item/deck/cards
	name = "deck of cards"
	desc = "A simple deck of playing cards."
	icon_state = "deck_nanotrasen_full"
	deckstyle = "nanotrasen"
	var/double = FALSE

/obj/item/deck/cards/New()
	..()
	for(double, double != -1, double--)
		for(var/suit in list("Spades","Clubs","Diamonds","Hearts"))
			for(var/number in list("Ace","2","3","4","5","6","7","8","9","10","Jack","Queen","King"))
				cards += new /datum/playingcard("[number] of [suit]", "sc_[number] of [suit]_[deckstyle]", "singlecard_down_[deckstyle]")

		for(var/i = 0, i<2, i++)
			cards += new /datum/playingcard("Joker", "sc_Joker_[deckstyle]", "singlecard_down_[deckstyle]")

/obj/item/deck/cards/update_icon()
	switch(cards.len)
		if(0)
			icon_state = "deck_[deckstyle]_empty"
		if(1 to 10)
			icon_state = "deck_[deckstyle]_low"
		if(11 to 26)
			icon_state = "deck_[deckstyle]_half"
		else
			icon_state = "deck_[deckstyle]_full"

/obj/item/deck/cards/doublecards
		name = "double deck of cards"
		desc = "A simple deck of playing cards. Multiplied by two. Does not necessarily come with twice the fun."
		double = TRUE

/obj/item/deck/cards/doublecards/update_icon()
	switch(cards.len)
		if(0)
			icon_state = "deck_[deckstyle]_empty"
		if(1 to 20)
			icon_state = "deck_double_[deckstyle]_low"
		if(22 to 52)
			icon_state = "deck_double_[deckstyle]_half"
		else
			icon_state = "deck_double_[deckstyle]_full"

/obj/item/deck/cards/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	icon_state = "deck_syndicate_full"
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_attack_verb = list("attacked", "sliced", "diced", "slashed", "cut")
	card_resistance_flags = NONE

/obj/item/deck/cards/black
	deckstyle = "black"

/obj/item/deck/cards/syndicate/black
	deckstyle = "black"

/obj/item/deck/tiny
	name = "deck of tiny cards"
	desc = "A simple deck of tiny playing cards."
	icon_state = "deck"
	var/double = FALSE

/obj/item/deck/tiny/New()
	..()
	for(double, double != -1, double--)
		for(var/suit in list("Spades","Clubs","Diamonds","Hearts"))
			var/colour
			if(suit == "Spades" || suit == "Clubs")
				colour = "black_"
			else
				colour = "red_"

			for(var/number in list("Ace","2","3","4","5","6","7","8","9","10"))
				cards += new /datum/playingcard("[number] of [suit]", "[colour]num")
		
			for(var/number in list("Jack","Queen","King"))
				cards += new /datum/playingcard("[number] of [suit]", "[colour]col")

			for(var/i = 0, i<2, i++)
			cards += new /datum/playingcard("Joker", "joker")

/obj/item/deck/tiny/doublecards
	name = "double deck of tiny cards"
	desc = "A simple deck of tiny playing cards. Multiplied by two. Does not necessarily come with twice the fun."
	icon_state = "doubledeck"
	double = TRUE
