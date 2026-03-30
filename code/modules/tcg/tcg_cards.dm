#define ROTATED_ANGLE 90
#define UNROTATED_ANGLE 0

// Need a TCG coin or two to replace the gold one that can be dropped. Make it shrink like the cards/packs

/datum/tcg_card
	var/name = "Chrono Legionnare"
	var/desc = "You shouldn't be seeing this. You should ahelp this!"
	var/icon_state = "chrono"
	var/pack = 'icons/obj/tcg/pack1.dmi'

	// This will be probably implemented.... sometime.
	// var/health = 0
	// var/attack = 0
	// var/mana = 0

	var/faction = "Coderbus"
	var/rarity = "Unobtainable"
	var/card_type = "Unit"

	var/obj/item/tcg_card/card

/datum/tcg_card/proc/UseSelf(mob/living/user)
	return

/datum/tcg_card/proc/Rotate(mob/living/user)
	return

/datum/tcg_card/proc/Unrotate(mob/living/user)
	return

/obj/item/tcg_card
	name = "trading card"
	desc = "A flipped trading card."
	icon_state = "cardback"
	icon = 'icons/obj/tcg/pack1.dmi'

	var/datum_type = /datum/tcg_card
	var/datum/tcg_card/card_datum
	var/flipped = FALSE
	var/rotated = FALSE

	w_class = WEIGHT_CLASS_TINY

/obj/item/tcg_card/examine(mob/user)
	. = ..()
	if(flipped)
		return

	. += ""
	. += "This card has the following stats:"
	. += "Rarity: [card_datum.rarity]"
	. += "Card Type: [card_datum.card_type]"

/obj/item/tcg_card/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/tcg_card/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

/obj/item/tcg_card/attack_self__legacy__attackchain(mob/user)
	if(flipped)
		flipped = !flipped
	if(!flipped)
		flipped = TRUE

/obj/item/tcg_card/New(loc, new_datum)
	. = ..()

	if(new_datum)
		datum_type = new_datum
	card_datum = new datum_type
	icon = card_datum.pack
	icon_state = card_datum.icon_state
	name = card_datum.name
	desc = card_datum.desc

/obj/item/tcg_card/attack_hand(mob/user)
	var/list/choices = list(
		"Pick Up" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_pickup"),
		"Rotate" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_rotate"),
		"Flip" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_flip"),
	)
	var/result = show_radial_menu(user, src, choices, require_near = TRUE)
	switch(result)
		if("Pick Up")
			. = ..()
		if("Flip")
			flipped = !flipped
			if(flipped)
				icon_state = "cardback"
				name = "Battles of Orion card"
				desc = "A flipped Battles of Orion-branded card."
			else
				name = card_datum.name
				desc = card_datum.desc
				icon_state = card_datum.icon_state
		if("Rotate")
			var/matrix/ntransform = matrix(transform)
			if(rotated)
				ntransform.TurnTo(ROTATED_ANGLE , UNROTATED_ANGLE)
			else
				ntransform.TurnTo(UNROTATED_ANGLE , ROTATED_ANGLE)
			rotated = !rotated
			animate(src, transform = ntransform, time = 2, easing = (EASE_IN|EASE_OUT))
			if(rotated)
				card_datum.Rotate(user)
			else
				card_datum.Unrotate(user)

/obj/item/tcg_card/attackby__legacy__attackchain(obj/I, mob/user)
	if(istype(I, /obj/item/tcg_card))
		var/obj/item/tcg_card/second_card = I
		if(loc == user && second_card.loc == user)
			var/obj/item/tcgcard_hand/hand = new(get_turf(user))
			user.unequip(src)
			user.unequip(second_card)
			src.forceMove(hand)
			second_card.forceMove(hand)
			hand.cards.Add(src)
			hand.cards.Add(second_card)
			user.put_in_hands(hand)
			hand.update_icon()
			return
		var/obj/item/tcgcard_deck/new_deck = new /obj/item/tcgcard_deck(drop_location())
		new_deck.flipped = flipped
		user.unequip(second_card)
		second_card.forceMove(new_deck)
		src.forceMove(new_deck)
		new_deck.update_icon(UPDATE_ICON_STATE)
		new_deck.update_icon()
		return
	if(istype(I, /obj/item/tcgcard_deck))
		var/obj/item/tcgcard_deck/old_deck = I
		if(length(old_deck.contents) >= 30)
			to_chat(user, "<span class='notice'>This pile has too many cards for a regular deck!</span>")
			return
		user.unequip(src)
		src.forceMove(old_deck)
		flipped = old_deck.flipped
		old_deck.update_icon()
		update_icon()
	return

/obj/item/cardpack
	name = "Trading Card Pack: Chrono & Friends"
	desc = "This unobtainable group certainly shouldn't be findable and you should ahelp this!"
	icon = 'icons/obj/tcg/misc.dmi'
	icon_state = "cardpack"
	w_class = WEIGHT_CLASS_TINY

	/// The card series to look through
	var/list/series = list(/datum/tcg_card/pack_1)
	/// The chance there will be a coin in the pack
	var/contains_coin = -1
	/// The amount of cards you draw
	var/card_count = 5
	/// The rarity table
	var/list/rarity_table = list(
		"Common" = 900,
		"Uncommon" = 300,
		"Rare" = 50,
		"Legendary" = 3
	)
	/// The amount of cards to draw from the guarenteed rarity table
	var/guaranteed_count = 1
	/// The guaranteed rarity table, acts about the same as the rarity table.
	var/list/guar_rarity = list(
		"Uncommon" = 30,
		"Rare" = 9,
		"Legendary" = 1
	)

/obj/item/cardpack/series_one
	name = "Battles of Orion: Series 1"
	desc = "Contains five cards from the Series 1 of Battles of Orion! Collect them all!"
	series = list(/datum/tcg_card/pack_1)
	contains_coin = 10

/obj/item/cardpack/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/cardpack/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

/obj/item/cardpack/attack_self__legacy__attackchain(mob/user)
	. = ..()
	var/list/cards = buildCardListWithRarity(card_count, guaranteed_count)
	var/obj/item/tcgcard_hand/hand = new(get_turf(user))

	for(var/template in cards)
		var/obj/item/tcg_card/card = new(hand, template)
		hand.cards.Add(card)
	user.put_in_hands(hand)
	hand.update_icon()
	to_chat(user, "<span_class='notice'>Wow! Check out these cards!</span>")
	playsound(loc, 'sound/items/poster_ripped.ogg', 20, TRUE)
	if(prob(contains_coin))
		to_chat(user, "<span_class='notice'>...and it came with a flipper, too!</span>")
		new /obj/item/coin/thunderdome(get_turf(user))
	// new rulebook goes here
	qdel(src)

/obj/item/cardpack/proc/buildCardListWithRarity(card_cnt, rarity_cnt)
	var/list/return_cards = list()

	var/list/cards = list()
	for(var/card_type in series)
		for(var/card in subtypesof(card_type))
			var/datum/tcg_card/new_card = new card()
			if(new_card.name == "Chrono Legionnare")
				continue
			cards.Add(card)
			qdel(new_card)
	var/list/possible_cards = list()
	var/list/rarity_cards = list("Legendary" = list(),"Rare" = list(),"Uncommon" = list(),"Common" = list())
	for(var/card in cards)
		var/datum/tcg_card/new_card = new card()
		if(new_card.name == "Stupid Coder")
			continue
		possible_cards[card] = rarity_table[new_card.rarity]
		var/list/rarity_card_type = rarity_cards[new_card.rarity]
		if(!rarity_card_type)
			rarity_card_type = list()
		rarity_card_type.Add(card)
		rarity_cards[new_card.rarity] = rarity_card_type
		qdel(new_card)

	for(var/card_counter = 1 to card_count)
		var/cardtype = pickweight(possible_cards)
		return_cards.Add(cardtype)

	for(var/card_counter = 1 to guaranteed_count)
		var/card_list = pickweight(guar_rarity)
		return_cards.Add(pick(rarity_cards[card_list]))

	return return_cards

/obj/item/coin/thunderdome
	name = "Thunderdome Flipper"
	desc = "A Thunderdome TCG flipper, for deciding who gets to go first. Also conveniently acts as a counter, for various purposes."
	icon = 'icons/obj/tcg/misc.dmi'
	icon_state = "coin_nanotrasen"
	sideslist = list("nanotrasen", "syndicate")

/obj/item/coin/thunderdome/Initialize(mapload)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

/obj/item/coin/thunderdome/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/coin/thunderdome/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

/obj/item/tcgcard_deck
	name = "Trading Card Deck"
	desc = "A stack of Battle of Orion cards."
	icon = 'icons/obj/tcg/misc.dmi'
	icon_state = "deck_up"
	w_class = WEIGHT_CLASS_TINY

	var/flipped = TRUE
	var/max_cards = 30

/obj/item/tcgcard_deck/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] has [contents.len] cards inside.</span>"

/obj/item/tcgcard_deck/update_icon()
	. = ..()
	cut_overlays()
	if(flipped)
		switch(contents.len)
			if(1 to 10)
				icon_state = "deck_low"
			if(11 to 20)
				icon_state = "deck_half"
			if(21 to INFINITY)
				icon_state = "deck_full"
	else
		icon_state = "deck_up"

/obj/item/tcgcard_deck/Destroy()
	for(var/obj/item/tcg_card/stored_card in contents)
		stored_card.forceMove(drop_location())
	. = ..()

/obj/item/tcgcard_deck/attack_hand(mob/user)
	var/list/choices = list(
		"Draw" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_draw"),
		"Shuffle" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_shuffle"),
		"Pickup" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_pickup"),
	)
	var/choice = show_radial_menu(user, src, choices, require_near = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Draw")
			draw_card(user)
		if("Shuffle")
			shuffle_deck(user)
		if("Pickup")
			user.put_in_hands(src)
		if("Flip")
			flip_deck()

/obj/item/tcgcard_deck/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/tcgcard_deck/attackby__legacy__attackchain(obj/I, mob/user)
	if(istype(I, /obj/item/tcg_card))
		if(contents.len >= max_cards)
			to_chat(user, "<span class='notice'>This pile has too many cards for a single deck!</span>")
			return FALSE
		var/obj/item/tcg_card/new_card = I
		new_card.flipped = flipped
		user.unequip(new_card)
		new_card.forceMove(src)
		update_icon()

	if(istype(I, /obj/item/tcgcard_hand))
		var/obj/item/tcgcard_hand/hand = I
		for(var/obj/item/tcg_card/card in hand.cards)
			if(contents.len >= max_cards)
				return FALSE
			card.flipped = flipped
			card.forceMove(src)
			hand.cards.Remove(card)
		update_icon()

/obj/item/tcgcard_deck/attack_self__legacy__attackchain(mob/user)
	shuffle_deck(user)
	return ..()

/obj/item/tcgcard_deck/proc/draw_card(mob/user)
	if(!contents.len)
		return
	var/obj/item/tcg_card/drawn_card = contents[contents.len]
	drawn_card.flipped = flipped
	drawn_card.forceMove(get_turf(user))
	user.put_in_hands(drawn_card)
	drawn_card.update_icon()
	user.visible_message("<span class='notice'>[user] draws a card from \the [src]!</span>", \
					"<span class='notice'>You draw a card from \the [src]!</span>")
	update_icon()
	if(!contents.len)
		qdel(src)

/obj/item/tcgcard_deck/proc/shuffle_deck(mob/user, visible = TRUE)
	if(!contents.len)
		return
	var/turf/T = get_turf(src)
	var/list/shuffled = shuffle(contents.Copy())
	for(var/obj/item/tcg_card/card in contents)
		card.forceMove(T)
	for(var/obj/item/tcg_card/card in shuffled)
		card.forceMove(src)
	if(visible)
		user.visible_message("<span class='notice'>[user] shuffles \the [src]!</span>", \
						"<span class='notice'>You shuffle \the [src]!</span>")

/obj/item/tcgcard_deck/proc/flip_deck()
	flipped = !flipped
	var/turf/T = get_turf(src)
	var/list/temp_cards = list()
	for(var/obj/item/tcg_card/card in contents)
		temp_cards.Add(card)
	for(var/obj/item/tcg_card/card in temp_cards)
		card.forceMove(T)
	for(var/i = temp_cards.len to 1 step -1)
		var/obj/item/tcg_card/card = temp_cards[i]
		card.forceMove(src)
		card.flipped = flipped
		card.update_icon()
	update_icon()

/obj/item/tcgcard_hand
	name = "Card Hand"
	desc = "A hand full of Battle of Orion cards."
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	w_class = WEIGHT_CLASS_TINY
	var/list/cards = list()

/obj/item/tcgcard_hand/update_icon()
	. = ..()
	cut_overlays()
	var/angular = length(cards) / 2 * -30 + 15
	for(var/obj/item/tcg_card/card in cards)
		var/image/I = image(icon = card.icon, icon_state = card.icon_state)
		var/matrix/ntransform = matrix(I.transform)
		ntransform.TurnTo(angular, 0)
		ntransform.Translate(sin(angular) * -15, cos(angular) * 15)
		I.transform = ntransform
		angular += 30
		overlays += I


/obj/item/tcgcard_hand/attackby__legacy__attackchain(obj/I, mob/user)
	if(istype(I, /obj/item/tcg_card))
		var/obj/item/tcg_card/card = I
		if(loc == user && card.loc == user)
			user.unequip(card)
			card.forceMove(src)
			cards.Add(card)
			update_icon()
			return
	. = ..()

/obj/item/tcgcard_hand/attack_self__legacy__attackchain(mob/user)
	if(loc == user)
		var/list/choices = list()
		for(var/obj/item/tcg_card/card in cards)
			choices[card] = image(icon = card.icon, icon_state = card.icon_state)
		var/obj/item/tcg_card/choice = show_radial_menu(user, src, choices, require_near = TRUE)

		if(choice)
			choice.forceMove(get_turf(src))
			user.put_in_hands(choice)
			cards.Remove(choice)
			update_icon()
			if(length(cards) == 0)
				qdel(src)
			return
	. = ..()

/obj/item/tcgcard_hand/Destroy()
	for(var/obj/item/tcg_card/card in cards)
		card.forceMove(drop_location())
	cards = list()
	. = ..()

/obj/item/tcgcard_hand/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/tcgcard_hand/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

#undef ROTATED_ANGLE
#undef UNROTATED_ANGLE
