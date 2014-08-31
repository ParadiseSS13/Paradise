/datum/playingcard
	var/name = "playing card"
	var/card_icon = "card_back"

/obj/item/weapon/deck
	name = "deck of cards"
	desc = "A simple deck of playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "deck"
	w_class = 2

	var/list/cards = list()

/obj/item/weapon/deck/New()
	..()

	var/datum/playingcard/P
	for(var/suit in list("spades","clubs","diamonds","hearts"))

		var/colour
		if(suit == "spades" || suit == "clubs")
			colour = "black_"
		else
			colour = "red_"

		for(var/number in list("ace","two","three","four","five","six","seven","eight","nine","ten"))
			P = new()
			P.name = "[number] of [suit]"
			P.card_icon = "[colour]num"
			cards += P

		for(var/number in list("jack","queen","king"))
			P = new()
			P.name = "[number] of [suit]"
			P.card_icon = "[colour]col"
			cards += P


	for(var/i = 0,i<2,i++)
		P = new()
		P.name = "joker"
		P.card_icon = "joker"
		cards += P

/obj/item/weapon/deck/attackby(obj/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/hand))
		var/obj/item/weapon/hand/H = O
		for(var/datum/playingcard/P in H.cards)
			cards += P
		del(O)
		user << "You place your cards on the bottom of the deck."
		return
	..()

/obj/item/weapon/deck/verb/draw_card()

	set category = "Object"
	set name = "Draw"
	set desc = "Draw a card from a deck."
	set src in oview(1)

	if(usr.stat || !Adjacent(usr)) return

	if(!istype(usr,/mob/living/carbon))
		return

	var/mob/living/carbon/user = usr

	if(!cards.len)
		usr << "There are no cards in the deck."
		return

	var/obj/item/weapon/hand/H
	if(user.l_hand && istype(user.l_hand,/obj/item/weapon/hand))
		H = user.l_hand
	else if(user.r_hand && istype(user.r_hand,/obj/item/weapon/hand))
		H = user.r_hand
	else
		H = new(get_turf(src))
		user.put_in_hands(H)

	if(!H || !user) return

	var/datum/playingcard/P = cards[1]
	H.cards += P
	cards -= P
	H.update_icon()
	user.visible_message("\The [user] draws a card.")
	user << "It's the [P]."

/obj/item/weapon/deck/verb/deal_card()

	set category = "Object"
	set name = "Deal"
	set desc = "Deal a card from a deck."

	if(usr.stat || !Adjacent(usr)) return

	if(!cards.len)
		usr << "There are no cards in the deck."
		return

	var/list/players = list()
	for(var/mob/living/player in orange(3))
		if(!player.stat)
			players += player
	players -= usr

	var/mob/living/M = input("Who do you wish to deal a card?") as null|anything in players
	if(!usr || !src || !M) return

	var/obj/item/weapon/hand/H = new(get_turf(src))

	H.cards += cards[1]
	cards -= cards[1]
	H.concealed = 1
	H.update_icon()
	usr.visible_message("\The [usr] deals a card to \the [M].")
	H.throw_at(get_step(M,M.dir),10,1,H)

/obj/item/weapon/hand/attackby(obj/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/hand))
		var/obj/item/weapon/hand/H = O
		for(var/datum/playingcard/P in H.cards)
			cards += P
		del(O)
		user.put_in_hands(src)
		update_icon()
		return
	..()

/obj/item/weapon/deck/attack_self(var/mob/user as mob)

	var/list/newcards = list()
	while(cards.len)
		var/datum/playingcard/P = pick(cards)
		newcards += P
		cards -= P
	cards = newcards
	user.visible_message("\The [user] shuffles [src].")

/obj/item/weapon/hand
	name = "hand of cards"
	desc = "Some playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "empty"
	w_class = 1

	var/concealed = 0
	var/list/cards = list()

/obj/item/weapon/hand/verb/discard()

	set category = "Object"
	set name = "Discard"
	set desc = "Place a card from your hand in front of you."

	var/list/to_discard = list()
	for(var/datum/playingcard/P in cards)
		to_discard[P.name] = P
	var/discarding = input("Which card do you wish to put down?") as null|anything in to_discard

	if(!discarding || !to_discard[discarding] || !usr || !src) return

	var/datum/playingcard/card = to_discard[discarding]
	del(to_discard)

	var/obj/item/weapon/hand/H = new(src.loc)
	H.cards += card
	cards -= card
	H.concealed = 0
	H.update_icon()
	usr.visible_message("\The [usr] plays \the [discarding].")
	H.loc = get_step(usr,usr.dir)

	if(!cards.len)
		del(src)

/obj/item/weapon/hand/attack_self(var/mob/user as mob)
	concealed = !concealed
	update_icon()
	user.visible_message("\The [user] [concealed ? "conceals" : "reveals"] their hand.")

/obj/item/weapon/hand/examine()
	..()
	if((!concealed || src.loc == usr) && cards.len)
		usr << "It contains: "
		for(var/datum/playingcard/P in cards)
			usr << "The [P.name]."

/obj/item/weapon/hand/update_icon()

	if(!cards.len)
		del(src)
		return
	else if(cards.len > 1)
		name = "hand of cards"
		desc = "Some playing cards."
	else
		name = "a playing card"
		desc = "A playing card."

	overlays.Cut()


	if(cards.len == 1)
		var/datum/playingcard/P = cards[1]
		var/image/I = new(src.icon, (concealed ? "card_back" : "[P.card_icon]") )
		I.pixel_x += (-5+rand(10))
		I.pixel_y += (-5+rand(10))
		overlays += I
		return

	var/origin = -12
	var/offset = Floor(32/cards.len)

	var/i = 0
	for(var/datum/playingcard/P in cards)
		var/image/I = new(src.icon, (concealed ? "card_back" : "[P.card_icon]") )
		I.pixel_x = origin+(offset*i)
		overlays += I
		i++