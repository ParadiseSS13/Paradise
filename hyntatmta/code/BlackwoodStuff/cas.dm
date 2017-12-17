//Порт Cards against spess с хиппи.

/obj/item/toy/cards/deck/cas
	name = "\improper CAS deck (white)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall.\nThis is the white deck."
	icon = 'hyntatmta/icons/obj/cas.dmi'
	icon_state = "deck_caswhite_full"
	deckstyle = "caswhite"
	var/blanks = 0
	var/decksize = 100
	var/card_text_file = "config/strings/cas_white.txt"
	var/list/allcards = list()

/obj/item/toy/cards/deck/cas/blanks
	name = "CAS deck (white blanks)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall.\nThis is a white deck which contains blanks to be used in custom games of CAS."
	decksize = 0
	blanks = 50

/obj/item/toy/cards/deck/cas/black
	name = "CAS deck (black)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall.\nThis is the black deck."
	icon_state = "deck_casblack_full"
	deckstyle = "casblack"
	blanks = 0
	decksize = 50
	card_text_file = "config/strings/cas_black.txt"

/obj/item/toy/cards/deck/cas/black/blanks
	name = "CAS deck (black blanks)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall.\nThis is a black deck which contains blanks to be used in custom games of CAS."
	decksize = 0
	blanks = 50

/obj/item/toy/cards/deck/cas/New()
	allcards = file2list(card_text_file)
	var/list/possiblecards = allcards.Copy()
	if(possiblecards.len < decksize) // sanity check
		decksize = (possiblecards.len - 1)
	var/list/randomcards = list()
	while (randomcards.len < decksize)
		randomcards += pick_n_take(possiblecards)
	for(var/i in 1 to randomcards.len)
		var/cardtext = randomcards[i]
		cards += "[cardtext]"
	if(!blanks)
		return
	for(var/x in 1 to blanks)
		cards += "Blank Card"

/obj/item/toy/cards/deck/cas/attack_hand(mob/user)
	if(user.lying)
		return
	var/choice = null
	if(!cards.len)
		user << "<span class='warning'>There are no more cards to draw!</span>"
		return
	var/obj/item/toy/cards/singlecard/cas/H = new/obj/item/toy/cards/singlecard/cas(user.loc)
	choice = cards[1]
	H.name = "[copytext(deckstyle,4)] [H.name]"
	if(deckstyle == "caswhite")
		H.pixel_x = 5
	H.cardname = choice
	if(choice == "Blank Card")
		H.blank = 1
	H.parentdeck = src
	H.icon_state = "singlecard_[deckstyle]"
	cards -= choice
	H.pickup(user)
	user.put_in_hands(H)
	user.visible_message("[user] draws a card from the deck.", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()

/obj/item/toy/cards/deck/cas/update_icon()
	if(cards.len < 26)
		icon_state = "deck_[deckstyle]_low"
	else if(!cards.len)
		icon_state = "deck_[deckstyle]_empty"

/obj/item/toy/cards/singlecard/cas
	name = "CAS card"
	desc = "A CAS card."
	icon = 'hyntatmta/icons/obj/cas.dmi'
	icon_state = "cas_white"
	var/blank = 0

/obj/item/toy/cards/singlecard/cas/examine(mob/user)
	if(ishuman(user))
		if(in_range(user, src))
			to_chat(user, "<span class='notice'>The card reads: [cardname]</span>")
		else
			to_chat(user, "<span class='warning'>You need to get closer to check the card!</span>")

/obj/item/toy/cards/singlecard/cas/Flip()
	return

/obj/item/toy/cards/singlecard/cas/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/pen))
		if(!blank)
			to_chat(user, "You cannot write on that card.")
			return
		var/cardtext = stripped_input(user, "What do you wish to write on the card?", "Card Writing", "", 50)
		if(!cardtext)
			return
		cardname = cardtext
		blank = 0

//Boxes
/obj/item/weapon/storage/box/cas
	name = "Cards Against Spess box"
	desc = "A cardboard box which contains the Cards Against Spess game."
	icon = 'hyntatmta/icons/obj/cas.dmi'
	icon_state = "cas"

/obj/item/weapon/storage/box/cas/New()
	..()
	new /obj/item/toy/cards/deck/cas(src)
	new /obj/item/toy/cards/deck/cas/black(src)
	new /obj/item/toy/cards/deck/cas/blanks(src)
	new /obj/item/toy/cards/deck/cas/black/blanks(src)