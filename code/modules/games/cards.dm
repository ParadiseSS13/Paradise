/datum/playingcard
	var/name = "playing card"
	var/card_icon = "card_back"
	var/back_icon = "card_back"

/datum/playingcard/New(newname, newcard_icon, newback_icon)
	..()
	if(newname)
		name = newname
	if(newcard_icon)
		card_icon = newcard_icon
	if(newback_icon)
		back_icon = newback_icon

/obj/item/deck
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/playing_cards.dmi'
	actions_types = list(/datum/action/item_action/draw_card, /datum/action/item_action/deal_card, /datum/action/item_action/deal_card_multi, /datum/action/item_action/shuffle)
	var/list/cards = list()
	var/cooldown = 0 // to prevent spam shuffle
	throw_speed = 3
	throw_range = 10
	throwforce = 0
	force = 0

/obj/item/deck/attackby(obj/O as obj, mob/user as mob)
	if(istype(O,/obj/item/cardhand))
		var/obj/item/cardhand/H = O
		if(H.parentdeck == src)
			for(var/datum/playingcard/P in H.cards)
				cards += P
			qdel(H)
			to_chat(user,"<span class='notice'>You place your cards on the bottom of [src]</span>.")
			return
		else
			to_chat(user,"<span class='warning'>You can't mix cards from different decks!</span>")
			return

	..()

/obj/item/deck/examine(mob/user)
	. = ..()
	. +="<span class='notice'>It contains [cards.len ? cards.len : "no"] cards</span>"

/obj/item/deck/attack_hand(mob/user as mob)
	draw_card(user)

// Datum actions
/datum/action/item_action/draw_card
	name = "Draw - Draw one card"
	button_icon_state = "draw"
	use_itemicon = FALSE

/datum/action/item_action/draw_card/Trigger()
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.draw_card(owner)
	return ..()

/datum/action/item_action/deal_card
	name = "Deal - deal one card to a person next to you"
	button_icon_state = "deal_card"
	use_itemicon = FALSE

/datum/action/item_action/deal_card/Trigger()
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card()
	return ..()

/datum/action/item_action/deal_card_multi
	name = "Deal multiple card - Deal multiple card to a person next to you"
	button_icon_state = "deal_card_multi"
	use_itemicon = FALSE

/datum/action/item_action/deal_card_multi/Trigger()
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card_multi()
	return ..()

/datum/action/item_action/shuffle
	name = "Shuffle - shuffle the deck"
	button_icon_state = "shuffle"
	use_itemicon = FALSE

/datum/action/item_action/shuffle/Trigger()
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deckshuffle()
	return ..()

// Datum actions

/obj/item/deck/verb/draw_card(mob/user)

	set category = "Object"
	set name = "Draw"
	set desc = "Draw a card from a deck."
	set src in view(1)

	var/mob/living/carbon/human/M = user

	if(user.incapacitated() || !Adjacent(user))
		return

	if(!cards.len)
		to_chat(user,"<span class='notice'>There are no cards in the deck.</span>")
		return

	var/obj/item/cardhand/H = M.is_in_hands(/obj/item/cardhand)
	if(H && !(H.parentdeck == src))
		to_chat(user,"<span class='warning'>You can't mix cards from different decks!</span>")
		return
	if(H && ((1 + H.cards.len) > H.maxcardlen))
		to_chat(user,"<span class = 'warning'>You can't hold that many cards in one hand!</span>")
		return

	if(!H)
		H = new(get_turf(src))
		user.put_in_hands(H)

	var/datum/playingcard/P = cards[1]
	H.cards += P
	cards -= P
	H.parentdeck = src
	H.update_icon()
	user.visible_message("<span class='notice'>[user] draws a card.</span>","<span class='notice'>You draws a card.</span>")
	to_chat(user,"<span class='notice'>It's [P].</span>")

/obj/item/deck/verb/deal_card()

	set category = "Object"
	set name = "Deal"
	set desc = "Deal a card from a deck."
	set src in view(1)

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(!cards.len)
		to_chat(usr,"<span class='notice'>There are no cards in the deck.</span>")
		return

	var/list/players = list()
	for(var/mob/living/player in viewers(3))
		if(!player.incapacitated())
			players += player
	//players -= usr

	var/mob/living/M = input("Who do you wish to deal a card to?") as null|anything in players
	if(!usr || !src || !M) return

	deal_at(usr, M, 1)

/obj/item/deck/verb/deal_card_multi()

	set category = "Object"
	set name = "Deal Multiple Cards"
	set desc = "Deal multiple cards from a deck."
	set src in view(1)

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(!cards.len)
		to_chat(usr,"<span class='notice'>There are no cards in the deck.</span>")
		return

	var/list/players = list()
	for(var/mob/living/player in viewers(3))
		if(!player.incapacitated())
			players += player
	var/maxcards = max(min(cards.len,10),1)
	var/dcard = input("How many card(s) do you wish to deal? You may deal up to [maxcards] cards.") as num
	if(dcard > maxcards)
		return
	var/mob/living/M = input("Who do you wish to deal [dcard] card(s)?") as null|anything in players
	if(!usr || !src || !M || !Adjacent(usr))
		return

	deal_at(usr, M, dcard)

/obj/item/deck/proc/deal_at(mob/user, mob/target, dcard) // Take in the no. of card to be dealt
	var/obj/item/cardhand/H = new(get_step(user, user.dir))
	for(var/i in 1 to dcard)
		H.cards += cards[1]
		cards -= cards[1]
		H.parentdeck = src
		H.concealed = TRUE
		H.update_icon()
	if(user == target)
		user.visible_message("<span class='notice'>[user] deals [dcard] card(s) to \himself.</span>")
	else
		user.visible_message("<span class='notice'>[user] deals [dcard] card(s) to [target].</span>")
	H.throw_at(get_step(target,target.dir),3,1,H)


/obj/item/deck/attack_self()
	deckshuffle()

/obj/item/deck/verb/verb_shuffle()
	set category = "Object"
	set name = "Shuffle"
	set desc = "Shuffle the cards in the deck."
	set src in view(1)
	deckshuffle()

/obj/item/deck/proc/deckshuffle()
	var/mob/living/user = usr
	if(cooldown < world.time - 5 SECONDS)
		cards = shuffle(cards)
		user.visible_message("<span class='notice'>[user] shuffles [src].</span>")
		playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
		cooldown = world.time


/obj/item/deck/MouseDrop(atom/over_object) // Code from Paper bin, so you can still pick up the deck
	var/mob/M = usr
	if(M.incapacitated() || !Adjacent(M))
		return
	if(!ishuman(M))
		return

	if(over_object == M || istype(over_object, /obj/screen))
		if(!remove_item_from_storage(M))
			M.unEquip(src)
		if(over_object != M)
			switch(over_object.name)
				if("r_hand")
					M.put_in_r_hand(src)
				if("l_hand")
					M.put_in_l_hand(src)
		else
			M.put_in_hands(src)

		add_fingerprint(M)
		usr.visible_message("<span class='notice'>[usr] picks up the deck.</span>")

/obj/item/pack
	name = "Card Pack"
	desc = "For those with disposable income."

	icon_state = "card_pack"
	icon = 'icons/obj/playing_cards.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/cards = list()
	var/parentdeck = null // For future card pack that need to be compatible with eachother i.e. cardemon


/obj/item/pack/attack_self(mob/user as mob)
	user.visible_message("<span class='notice'>[name] rips open the [src]!</span>", "<span class='notice'>You rips open the [src]!</span>")
	var/obj/item/cardhand/H = new(get_turf(user))

	H.cards += cards
	cards.Cut()
	user.unEquip(src, force = 1)
	qdel(src)

	H.update_icon()
	user.put_in_hands(H)

/obj/item/cardhand
	name = "hand of cards"
	desc = "Some playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "empty"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	throwforce = 0
	force = 0
	var/maxcardlen = 20
	actions_types = list(/datum/action/item_action/remove_card, /datum/action/item_action/discard)

	var/concealed = FALSE
	var/list/cards = list()
	var/parentdeck = null

/obj/item/cardhand/attackby(obj/O as obj, mob/user as mob)
	if(cards.len == 1 && istype(O, /obj/item/pen))
		var/datum/playingcard/P = cards[1]
		if(P.name != "Blank Card")
			to_chat(user,"<span class='notice'>You cannot write on that card.</span>")
			return
		var/cardtext = sanitize(input(user, "What do you wish to write on the card?", "Card Editing") as text|null, MAX_PAPER_MESSAGE_LEN)
		if(!cardtext)
			return
		P.name = cardtext
		// SNOWFLAKE FOR CAG, REMOVE IF OTHER CARDS ARE ADDED THAT USE THIS.
		P.card_icon = "cag_white_card"
		update_icon()
	else if(istype(O,/obj/item/cardhand))
		var/obj/item/cardhand/H = O
		if((H.cards.len + cards.len) > maxcardlen)
			to_chat(user,"<span class='warning'>You can't hold that many cards in one hand!</span>")
			return
		if(H.parentdeck == src.parentdeck)
			for(var/datum/playingcard/P in cards)
				H.cards += P
			H.concealed = src.concealed
			qdel(src)
			H.update_icon()
			return
		else
			to_chat(user,"<span class='notice'>You cannot mix cards from other deck!</span>")
			return
	..()

/obj/item/cardhand/attack_self(var/mob/user as mob)
	concealed = !concealed
	update_icon()
	user.visible_message("<span class='notice'>[user] [concealed ? "conceals" : "reveals"] their hand.</span>")

/obj/item/cardhand/examine(mob/user)
	. = ..()
	if((!concealed) && cards.len)
		. +="<span class='notice'>It contains:</span>"
		for(var/datum/playingcard/P in cards)
			. +="<span class='notice'>the [P.name].</span>"

// Datum action here

/datum/action/item_action/remove_card
	name = "Remove a card - Remove a single card from the hand."
	button_icon_state = "remove_card"
	use_itemicon = FALSE

/datum/action/item_action/remove_card/Trigger()
	if(istype(target, /obj/item/cardhand))
		var/obj/item/cardhand/C = target
		return C.Removecard()
	return ..()

/datum/action/item_action/discard
	name = "Discard - Place (a) card(s) from your hand in front of you."
	button_icon_state = "discard"
	use_itemicon = FALSE

/datum/action/item_action/discard/Trigger()
	if(istype(target, /obj/item/cardhand))
		var/obj/item/cardhand/C = target
		return C.discard()
	return ..()

// No more datum action here

/obj/item/cardhand/verb/Removecard()

	set category = "Object"
	set name = "Remove card"
	set desc = "Remove a card from the hand."
	set src in view(1)

	var/mob/living/carbon/user = usr

	if(user.incapacitated() || !Adjacent(user))
		return

	var/pickablecards = list()
	for(var/datum/playingcard/P in cards)
		pickablecards[P.name] = P
	var/pickedcard = input("Which card do you want to remove from the hand?") as null|anything in pickablecards

	if(QDELETED(src))
		return

	var/datum/playingcard/card = pickablecards[pickedcard]

	var/obj/item/cardhand/H = new(get_turf(src))
	user.put_in_hands(H)
	H.cards += card
	cards -= card
	H.parentdeck = parentdeck
	H.concealed = concealed
	H.update_icon()

	if(!cards.len)
		qdel(src)
		return
	update_icon()

/obj/item/cardhand/verb/discard(var/mob/user as mob)

	set category = "Object"
	set name = "Discard"
	set desc = "Place (a) card(s) from your hand in front of you."

	var/maxcards = min(cards.len,5)
	var/discards = input("How many cards do you want to discard? You may discard up to [maxcards] card(s)") as num
	if(discards > maxcards)
		return
	for(var/i in 1 to discards)
		var/list/to_discard = list()
		for(var/datum/playingcard/P in cards)
			to_discard[P.name] = P
		var/discarding = input("Which card do you wish to put down?") as null|anything in to_discard

		if(QDELETED(src))
			return

		var/datum/playingcard/card = to_discard[discarding]
		to_discard.Cut()

		var/obj/item/cardhand/H = new(get_turf(src))
		H.cards += card
		cards -= card
		H.concealed = FALSE
		H.parentdeck = parentdeck
		H.update_icon()
		if(cards.len)
			update_icon()
		if(H.cards.len)
			usr.visible_message("<span class='notice'>The [usr] plays the [discarding].</span>", "<span class='notice'>You play the [discarding].</span>")
		H.loc = get_step(usr,usr.dir)

	if(!cards.len)
		qdel(src)

/obj/item/cardhand/update_icon(var/direction = 0)

	if(!cards.len)
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
		var/image/I = new(icon, (concealed ? "[P.back_icon]" : "[P.card_icon]") )
		I.pixel_x += (-5+rand(10))
		I.pixel_y += (-5+rand(10))
		overlays += I
		return

	var/offset = Floor(20/cards.len + 1)

	var/matrix/M = matrix()
	if(direction)
		switch(direction)
			if(NORTH)
				M.Translate( 0,  0)
			if(SOUTH)
				M.Translate( 0,  4)
			if(WEST)
				M.Turn(90)
				M.Translate( 3,  0)
			if(EAST)
				M.Turn(90)
				M.Translate(-2,  0)
	var/i = 0
	for(var/datum/playingcard/P in cards)
		var/image/I = new(icon, (concealed ? "[P.back_icon]" : "[P.card_icon]") )
		//I.pixel_x = origin+(offset*i)
		switch(direction)
			if(SOUTH)
				I.pixel_x = 8-(offset*i)
			if(WEST)
				I.pixel_y = -6+(offset*i)
			if(EAST)
				I.pixel_y = 8-(offset*i)
			else
				I.pixel_x = -7+(offset*i)
		I.transform = M
		overlays += I
		i++

/obj/item/cardhand/dropped(mob/user as mob)
	..()
	if(locate(/obj/structure/table, loc))
		update_icon(user.dir)
	else
		update_icon()

/obj/item/cardhand/pickup(mob/user as mob)
	. = ..()
	update_icon()
