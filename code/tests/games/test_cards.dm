/datum/game_test/room_test/card_deck/proc/validate_deck(obj/item/deck/deck)
	var/list/card_count = list()
	for(var/datum/playingcard/card in deck.cards)
		if(card_count[card.name] == null)
			card_count[card.name] = 1
		else if(card.name == "Joker")
			card_count[card.name]++
		else
			// duplicate card in deck
			return FALSE

	if(length(card_count) != 53) // 2 Jokers, so 53 unique cards
		return FALSE
	return TRUE


/datum/game_test/room_test/card_deck/Run()
	// setup
	var/loc = pick(available_turfs)
	var/obj/item/deck/cards/cards = allocate(/obj/item/deck/cards, loc)
	cards.build_decks()

	// is deck proper upon spawning
	if(!validate_deck(cards))
		TEST_FAIL("52 card deck not initialized correctly.")

	// is deck proper after shuffling
	cards.deckshuffle()
	if(!validate_deck(cards))
		TEST_FAIL("52 card deck broken after shuffling.")
