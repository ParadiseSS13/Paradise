#warn add the booster boxes to cargo
#warn add the new pack to the vendor
#warn make deck boxes
#warn make premade decks

#define ROTATED_ANGLE 90
#define UNROTATED_ANGLE 0

/datum/tcg_card
	var/id = "coder"
	var/name = "Chrono Legionnare"
	var/desc = "You shouldn't be seeing this. You should ahelp this!"
	var/level = INFINITY
	var/attack = INFINITY
	var/defense = INFINITY
	var/icon = DEFAULT_TCG_DMI_ICON
	var/icon_state = "chrono"
	var/rarity = "Unobtainable"
	var/faction = "Coderbus"
	var/card_type = "Unit"

	var/obj/item/tcg_card/card

/datum/tcg_card/proc/UseSelf(mob/living/user)
	return

/datum/tcg_card/proc/Rotate(mob/living/user)
	return

/datum/tcg_card/proc/Unrotate(mob/living/user)
	return

/obj/item/tcg_card
	var/id = ""
	var/series = ""
	var/flipped = FALSE
	var/rotated = FALSE
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
	/// Whether or not a card was either spawned in/bought from an uplink.
	var/illegal = FALSE

/obj/item/tcg_card/examine(mob/user)
	. = ..()
	if(flipped)
		return
	var/datum/card/data = extract_datum()
	if(!data)
		return
	. += "Faction: [data.faction] | Rarity: [data.rarity]"
	. += "Type: [data.cardtype][data.cardsubtype ? " — [data.cardsubtype]" : ""]"
	if(data.cardtype == "Unit")
		. += "Level: [data.level] | ATK: [data.attack] / DEF: [data.defense]"
	if(data.effect)
		. += "<i>[data.effect]</i>"
	. += "Rarity: [data.rarity]"
	. += "Type: [data.cardtype]"
	if(data.rules)
		. += "Effect: [data.rules]"
	if(illegal)
		. += "<span class='warning'>This card is a low-quality copy. You surely won't get any respect from this card.</span>"

/obj/item/tcg_card/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/tcg_card/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

/obj/item/tcg_card/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(flipped)
		flipped = !flipped
	if(!flipped)
		flipped = TRUE
	return ITEM_INTERACT_COMPLETE

/obj/item/tcg_card/New(loc, new_series, new_id, new_illegal = FALSE)
	. = ..()
	series = new_series
	id = new_id
	illegal = new_illegal
	var/datum/card/data = extract_datum()
	if(!data)
		return
	name = data.name
	desc = "<i>[data.desc]</i>"
	icon = data.icon
	icon_state = data.icon_state

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
				var/datum/card/data = extract_datum()
				if(data)
					name = data.name
					desc = "<i>[data.desc]</i>"
					icon_state = data.icon_state
		if("Rotate")
			var/matrix/ntransform = matrix(transform)
			if(rotated)
				ntransform.TurnTo(ROTATED_ANGLE, UNROTATED_ANGLE)
			else
				ntransform.TurnTo(UNROTATED_ANGLE, ROTATED_ANGLE)
			rotated = !rotated
			animate(src, transform = ntransform, time = 2, easing = (EASE_IN|EASE_OUT))

/obj/item/tcg_card/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/tcg_card))
		var/obj/item/tcg_card/second_card = used
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
			return ITEM_INTERACT_COMPLETE

		var/obj/item/tcgcard_deck/new_deck = new /obj/item/tcgcard_deck(drop_location())
		new_deck.flipped = flipped
		user.unequip(second_card)
		second_card.forceMove(new_deck)
		src.forceMove(new_deck)
		new_deck.update_icon(UPDATE_ICON_STATE)
		new_deck.update_icon()
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/tcgcard_deck))
		var/obj/item/tcgcard_deck/old_deck = used
		if(length(old_deck.contents) >= 30)
			to_chat(user, "<span class='notice'>This pile has too many cards for a regular deck!</span>")
			return ITEM_INTERACT_COMPLETE
		user.unequip(src)
		src.forceMove(old_deck)
		flipped = old_deck.flipped
		old_deck.update_icon()
		update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/cardpack
	name = "Trading Card Pack: Chrono & Friends"
	desc = "This unobtainable group certainly shouldn't be findable and you should ahelp this!"
	icon = 'icons/obj/tcg/misc.dmi'
	icon_state = "cardpack"
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
	/// The card series to look through
	var/list/series
	/// The chance there will be a coin in the pack
	var/contains_coin = -1
	/// The amount of cards you draw
	var/card_count = 6
	/// Whether or not all cards from a series is dropped
	var/drop_all_cards = FALSE
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
	series = "pack_1"
	contains_coin = 10 // there's a 10% a coin is included in the pack

/obj/item/cardpack/series_one_deluxe
	name = "Battles of Orion: Series 1 DELUXE"
	desc = "A limited edition pack that contains EVERY card in Series 1. Contact your local Administrator or Developer if you find this!"
	series = "pack_1"
	contains_coin = 100
	drop_all_cards = TRUE

/obj/item/cardpack/series_two
	name = "Battles of Orion: Series 2"
	desc = "Contains six cards straight from Donk Co.! Don't ask how Donk made the cards so accurate."
	series = "pack_2"
	contains_coin = 10

/obj/item/cardpack/series_two_deluxe
	name = "Battles of Orion: Series 2 DELUXE"
	desc = "A limited edition pack that contains EVERY card in Series 2. Contact your local Administrator or Developer if you find this!"
	series = "pack_2"
	contains_coin = 100
	drop_all_cards = TRUE

/obj/item/cardpack/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/cardpack/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.5,0,0,0,0.5,0)

/obj/item/cardpack/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	var/list/cards
	if(drop_all_cards)
		var/list/all_cards = SStrading_card_game.cached_cards[series]["ALL"]
		if(!all_cards)
			to_chat(user, "<span class='warning'>No cards found for series [series]!</span>")
			qdel(src)
			return ITEM_INTERACT_COMPLETE
		cards = all_cards
	else
		cards = buildCardListWithRarity(card_count, guaranteed_count)

	var/obj/item/tcgcard_hand/hand = new(get_turf(user))
	for(var/id in cards)
		var/obj/item/tcg_card/card = new(hand, series, id, drop_all_cards)
		hand.cards.Add(card)
	user.put_in_hands(hand)
	hand.update_icon()
	to_chat(user, "<span_class='notice'>Wow! Check out these cards!</span>")
	playsound(loc, 'sound/items/poster_ripped.ogg', 20, TRUE)
	if(prob(contains_coin))
		to_chat(user, "<span_class='notice'>...and it came with a flipper, too!</span>")
		new /obj/item/coin/thunderdome(get_turf(user))
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/cardpack/proc/buildCardListWithRarity(card_cnt, rarity_cnt)
	var/list/return_cards = list()
	return_cards += returnCardsByRarity(rarity_cnt, guar_rarity)
	return_cards += returnCardsByRarity(card_cnt, rarity_table)
	return return_cards

/obj/item/cardpack/proc/returnCardsByRarity(count, list/table)
	var/list/result = list()
	for(var/i in 1 to count)
		var/rarity = pickweight(table)
		var/list/cards = SStrading_card_game.cached_cards[series][rarity]
		if(cards && length(cards))
			result += pick(cards)
		else
			CRASH("No cards found for rarity [rarity] in series [series]")
	return result

/obj/item/tcgcard_deck
	name = "Trading Card Deck"
	desc = "A stack of Battle of Orion cards."
	icon = 'icons/obj/tcg/misc.dmi'
	icon_state = "deck_up"
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE

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

/obj/item/tcgcard_deck/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/tcg_card))
		if(contents.len >= max_cards)
			to_chat(user, "<span class='notice'>This pile has too many cards for a single deck!</span>")
			return ITEM_INTERACT_COMPLETE

		var/obj/item/tcg_card/new_card = used
		new_card.flipped = flipped
		user.unequip(new_card)
		new_card.forceMove(src)
		update_icon()
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/tcgcard_hand))
		var/obj/item/tcgcard_hand/hand = used
		for(var/obj/item/tcg_card/card in hand.cards)
			if(contents.len >= max_cards)
				return ITEM_INTERACT_COMPLETE

			card.flipped = flipped
			card.forceMove(src)
			hand.cards.Remove(card)
		update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/tcgcard_deck/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE


	shuffle_deck(user)
	return ITEM_INTERACT_COMPLETE

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
	icon_state = "runtime"
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
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


/obj/item/tcgcard_hand/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/tcg_card))
		return ..()

	var/obj/item/tcg_card/card = used
	if(loc == user && card.loc == user)
		user.unequip(card)
		card.forceMove(src)
		cards.Add(card)
		update_icon()
	return ITEM_INTERACT_COMPLETE

/obj/item/tcgcard_hand/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(loc != user)
		return ITEM_INTERACT_COMPLETE

	if(length(cards) == 1)
		var/obj/item/tcg_card/last_card = cards[1]
		last_card.forceMove(get_turf(src))
		user.put_in_hands(last_card)
		cards.Remove(last_card)
		qdel(src)
		return ITEM_INTERACT_COMPLETE

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
	return ITEM_INTERACT_COMPLETE

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
