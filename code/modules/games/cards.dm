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
	/// To prevent spam shuffle
	var/cooldown = 0
	/// Decks default to a single pack, setting it higher will multiply them by that number
	var/deck_size = 1
	/// The total number of cards. Set on init after the deck is fully built
	var/deck_total = 0
	/// Styling for the cards, if they have multiple sets of sprites
	var/card_style = null
	/// Styling for the deck, it they has multiple sets of sprites
	var/deck_style = null
	/// For decks without a full set of sprites
	var/simple_deck = FALSE
	throw_speed = 3
	throw_range = 10
	throwforce = 0
	force = 0
	/// Inherited card hit sound
	var/card_hitsound
	/// Inherited card force
	var/card_force = 0
	/// Inherited card throw force
	var/card_throwforce = 0
	/// Inherited card throw speed
	var/card_throw_speed = 4
	/// Inherited card throw range
	var/card_throw_range = 20
	/// Inherited card verbs
	var/card_attack_verb
	/// Inherited card resistance
	var/card_resistance_flags = FLAMMABLE

/obj/item/deck/Initialize(mapload)
	. = ..()
	for(var/deck in 1 to deck_size)
		build_deck()
	deck_total = length(cards)
	update_icon(UPDATE_ICON_STATE)

/obj/item/deck/proc/build_deck()
	return

/obj/item/deck/attackby(obj/O as obj, mob/user as mob)
	if(istype(O,/obj/item/cardhand))
		var/obj/item/cardhand/H = O
		if(H.parentdeck == src)
			for(var/datum/playingcard/P in H.cards)
				cards += P
			qdel(H)
			to_chat(user,"<span class='notice'>You place your cards on the bottom of [src].</span>")
			update_icon(UPDATE_ICON_STATE)
			return
		else
			to_chat(user,"<span class='warning'>You can't mix cards from different decks!</span>")
			return

	..()

/obj/item/deck/examine(mob/user)
	. = ..()
	. +="<span class='notice'>It contains [length(cards) ? length(cards) : "no"] cards</span>"

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

	if(!length(cards))
		to_chat(user,"<span class='notice'>There are no cards in the deck.</span>")
		return

	var/obj/item/cardhand/H = M.is_in_hands(/obj/item/cardhand)
	if(H && (H.parentdeck != src))
		to_chat(user,"<span class='warning'>You can't mix cards from different decks!</span>")
		return
	if(H && length(H.cards) >= H.maxcardlen)
		to_chat(user,"<span class = 'warning'>You can't hold that many cards in one hand!</span>")
		return

	if(!H)
		H = new(get_turf(src))
		user.put_in_hands(H)

	var/datum/playingcard/P = cards[1]
	H.cards += P
	cards -= P
	update_icon(UPDATE_ICON_STATE)
	H.parentdeck = src
	H.update_values()
	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.visible_message("<span class='notice'>[user] draws a card.</span>","<span class='notice'>You draw a card.</span>")
	to_chat(user,"<span class='notice'>It's the [P].</span>")

/obj/item/deck/verb/deal_card()

	set category = "Object"
	set name = "Deal"
	set desc = "Deal a card from a deck."
	set src in view(1)

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(!length(cards))
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

	if(!length(cards))
		to_chat(usr,"<span class='notice'>There are no cards in the deck.</span>")
		return

	var/list/players = list()
	for(var/mob/living/player in viewers(3))
		if(!player.incapacitated())
			players += player
	var/maxcards = clamp(length(cards), 1, 10)
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
		update_icon(UPDATE_ICON_STATE)
		H.parentdeck = src
		H.update_values()
		H.concealed = TRUE
		H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(user == target)
		user.visible_message("<span class='notice'>[user] deals [dcard] card(s) to [user.p_themselves()].</span>")
	else
		user.visible_message("<span class='notice'>[user] deals [dcard] card(s) to [target].</span>")
	H.throw_at(get_step(target,target.dir),3,1,H)


/obj/item/deck/attack_self()
	deckshuffle()

/obj/item/deck/verb/verb_shuffle()
	if(!isobserver(usr))
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


/obj/item/deck/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	var/mob/M = usr
	if(M.incapacitated() || !Adjacent(M))
		return
	if(!ishuman(M))
		return

	if(istype(over, /obj/screen))
		if(!remove_item_from_storage(get_turf(M)))
			M.unEquip(src)
		switch(over.name)
			if("r_hand")
				if(M.put_in_r_hand(src))
					add_fingerprint(M)
					usr.visible_message("<span class='notice'>[usr] picks up the deck.</span>")
			if("l_hand")
				if(M.put_in_l_hand(src))
					add_fingerprint(M)
					usr.visible_message("<span class='notice'>[usr] picks up the deck.</span>")
		return

	if(over == M && loc != M)
		if(M.put_in_hands(src))
			add_fingerprint(M)
			usr.visible_message("<span class='notice'>[usr] picks up the deck.</span>")

/obj/item/pack
	name = "card pack"
	desc = "For those with disposable income."

	icon_state = "card_pack"
	icon = 'icons/obj/playing_cards.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/cards = list()
	var/parentdeck = null // For future card pack that need to be compatible with eachother i.e. cardemon


/obj/item/pack/attack_self(mob/user as mob)
	user.visible_message("<span class='notice'>[name] rips open [src]!</span>", "<span class='notice'>You rip open [src]!</span>")
	var/obj/item/cardhand/H = new(get_turf(user))

	H.cards += cards
	cards.Cut()
	user.unEquip(src, force = 1)
	qdel(src)

	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.put_in_hands(H)

/obj/item/cardhand
	name = "hand of cards"
	desc = "Some playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "empty"
	w_class = WEIGHT_CLASS_TINY
	var/maxcardlen = 20
	actions_types = list(/datum/action/item_action/remove_card, /datum/action/item_action/discard)

	var/concealed = FALSE
	var/list/cards = list()
	/// Tracked direction, which is used when updating the hand's appearance instead of messing with the local dir
	var/direction = NORTH
	var/parentdeck = null
	/// The player's picked card they want to take out. Stored in the hand so it can be passed onto the verb
	var/pickedcard = null

/obj/item/cardhand/proc/update_values()
	if(!parentdeck)
		return
	var/obj/item/deck/D = parentdeck
	hitsound = D.card_hitsound
	force = D.card_force
	throwforce = D.card_throwforce
	throw_speed = D.card_throw_speed
	throw_range = D.card_throw_range
	attack_verb = D.card_attack_verb
	resistance_flags = D.card_resistance_flags

/obj/item/cardhand/attackby(obj/O, mob/user)
	if(length(cards) == 1 && is_pen(O))
		var/datum/playingcard/P = cards[1]
		if(P.name != "Blank Card")
			to_chat(user,"<span class='notice'>You cannot write on that card.</span>")
			return
		var/t = rename_interactive(user, P, use_prefix = FALSE, actually_rename = FALSE)
		if(t && P.name == "Blank Card")
			P.name = t
		// SNOWFLAKE FOR CAG, REMOVE IF OTHER CARDS ARE ADDED THAT USE THIS.
		P.card_icon = "cag_white_card"
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	else if(istype(O,/obj/item/cardhand))
		var/obj/item/cardhand/H = O
		if((length(H.cards) + length(cards)) > maxcardlen)
			to_chat(user,"<span class='warning'>You can't hold that many cards in one hand!</span>")
			return
		if(H.parentdeck == parentdeck)
			for(var/datum/playingcard/P in cards)
				H.cards += P
			H.concealed = concealed
			qdel(src)
			H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
			return
		else
			to_chat(user,"<span class='notice'>You cannot mix cards from other deck!</span>")
			return
	..()

/obj/item/cardhand/attack_self(mob/user)
	if(length(cards) == 1)
		turn_hand(user)
		return
	user.set_machine(src)
	interact(user)

/obj/item/cardhand/proc/turn_hand(mob/user)
	concealed = !concealed
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.visible_message("<span class='notice'>[user] [concealed ? "conceals" : "reveals"] their hand.</span>")

/obj/item/cardhand/interact(mob/user)
	var/dat = "You have:<br>"
	for(var/t in cards)
		dat += "<a href='?src=[UID()];pick=[t]'>The [t]</a><br>"
	dat += "Which card will you remove next?<br>"
	dat += "<a href='?src=[UID()];pick=Turn'>Turn the hand over</a>"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/item/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr))
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if(href_list["pick"] == "Turn")
			turn_hand(usr)
		else
			if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
				pickedcard = href_list["pick"]
				Removecard()
		cardUser << browse(null, "window=cardhand")

/obj/item/cardhand/examine(mob/user)
	. = ..()
	if(!concealed && length(cards))
		. +="<span class='notice'>It contains:</span>"
		for(var/datum/playingcard/P in cards)
			. +="<span class='notice'>the [P.name].</span>"

// Datum action here

/datum/action/item_action/remove_card
	name = "Remove a card - Remove a single card from the hand."
	button_icon_state = "remove_card"
	use_itemicon = FALSE

/datum/action/item_action/remove_card/IsAvailable()
	var/obj/item/cardhand/C = target
	if(length(C.cards) <= 1)
		return FALSE
	return ..()

/datum/action/item_action/remove_card/Trigger()
	if(!IsAvailable())
		return
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
	if(!pickedcard)
		pickedcard = input("Which card do you want to remove from the hand?") as null|anything in pickablecards
		if(!pickedcard)
			return

	if(QDELETED(src))
		return

	var/datum/playingcard/card = pickablecards[pickedcard]
	if(loc != user) // Don't want people teleporting cards
		return
	user.visible_message("<span class='notice'>[user] draws a card from [user.p_their()] hand.</span>", "<span class='notice'>You take the [pickedcard] from your hand.</span>")
	pickedcard = null

	var/obj/item/cardhand/H = new(get_turf(src))
	user.put_in_hands(H)
	H.cards += card
	cards -= card
	H.parentdeck = parentdeck
	H.update_values()
	H.concealed = concealed
	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(!length(cards))
		qdel(src)
		return
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

/obj/item/cardhand/verb/discard()

	set category = "Object"
	set name = "Discard"
	set desc = "Place (a) card(s) from your hand in front of you."

	var/mob/living/carbon/user = usr

	var/maxcards = min(length(cards), 5)
	var/discards = input("How many cards do you want to discard? You may discard up to [maxcards] card(s)") as num
	if(discards > maxcards)
		return
	for(var/i in 1 to discards)
		var/list/to_discard = list()
		for(var/datum/playingcard/P in cards)
			to_discard[P.name] = P
		var/discarding = input("Which card do you wish to put down?") as null|anything in to_discard

		if(!discarding)
			continue

		if(loc != user) // Don't want people teleporting cards
			return

		if(QDELETED(src))
			return

		var/datum/playingcard/card = to_discard[discarding]
		to_discard.Cut()

		var/obj/item/cardhand/H = new type(get_turf(src))
		H.cards += card
		cards -= card
		H.concealed = FALSE
		H.parentdeck = parentdeck
		H.update_values()
		H.direction = user.dir
		H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(length(cards))
			update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(length(H.cards))
			user.visible_message("<span class='notice'>[user] plays the [discarding].</span>", "<span class='notice'>You play the [discarding].</span>")
		H.loc = get_step(user, user.dir)

	if(!length(cards))
		qdel(src)

/obj/item/cardhand/update_appearance(updates=ALL)
	if(!length(cards))
		return
	if(length(cards) <= 2)
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	..()

/obj/item/cardhand/update_name()
	. = ..()
	if(length(cards) > 1)
		name = "hand of cards"
	else
		name = "a playing card"

/obj/item/cardhand/update_desc()
	. = ..()
	if(length(cards) > 1)
		desc = "Some playing cards."
	else
		desc = "A playing card."

/obj/item/cardhand/update_icon_state()
	return

/obj/item/cardhand/update_overlays()
	. = ..()
	var/matrix/M = matrix()
	switch(direction)
		if(NORTH)
			M.Translate( 0,  0)
		if(SOUTH)
			M.Turn(180)
			M.Translate( 0,  4)
		if(WEST)
			M.Turn(-90)
			M.Translate( 3,  0)
		if(EAST)
			M.Turn(90)
			M.Translate(-2,  0)

	if(length(cards) == 1)
		var/datum/playingcard/P = cards[1]
		var/image/I = new(icon, (concealed ? "[P.back_icon]" : "[P.card_icon]") )
		I.transform = M
		I.pixel_x += (-5+rand(10))
		I.pixel_y += (-5+rand(10))
		. += I
		return

	var/offset = FLOOR(20/length(cards) + 1, 1)
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
		. += I
		i++

/obj/item/cardhand/dropped(mob/user)
	..()
	if(user)
		direction = user.dir
	else
		direction = NORTH
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

/obj/item/cardhand/pickup(mob/user as mob)
	. = ..()
	direction = NORTH
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
