/obj/item/deck/holder
	name = "card box"
	desc = "A small leather case to show how classy you are compared to everyone else."
	icon_state = "card_holder"

/obj/item/deck/cards
	name = "deck of cards"
	desc = "A simple deck of playing cards."
	icon_state = "deck"

/obj/item/deck/cards/New()
	..()
	for(var/suit in list("spades","clubs","diamonds","hearts"))
		var/colour
		if(suit == "spades" || suit == "clubs")
			colour = "black_"
		else
			colour = "red_"

		for(var/number in list("ace","two","three","four","five","six","seven","eight","nine","ten"))
			cards += new /datum/playingcard("[number] of [suit]", "[colour]num")

		for(var/number in list("jack","queen","king"))
			cards += new /datum/playingcard("[number] of [suit]", "[colour]col")

	for(var/i = 0, i<2, i++)
		cards += new /datum/playingcard("joker", "joker")

/obj/item/deck/doublecards
		name = "double deck of cards"
		desc = "A simple deck of playing cards. Multiplied by two. Does not necessarily come with twice the fun."
		icon_state = "doubledeck"

/obj/item/deck/doublecards/New()
	..()
	for(var/f = 0, f<2, f++)
		for(var/suit in list("spades","clubs","diamonds","hearts"))

			var/colour
			if(suit == "spades" || suit == "clubs")
				colour = "black_"
			else
				colour = "red_"
			for(var/number in list("ace","two","three","four","five","six","seven","eight","nine","ten",))
				cards += new /datum/playingcard("[number] of [suit]", "[colour]num")
			for(var/number in list("jack","queen","king"))
				cards += new /datum/playingcard("[number] of [suit]", "[colour]col")

		for(var/i = 0, i<2, i++)
			cards += new /datum/playingcard("joker", "joker")
