/datum/playingcard
	var/name = "playing card"
	/// The front of the card, with all the fun stuff.
	var/card_icon = "card_back"
	/// The back of the card, shown when face-down.
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

	throw_speed = 3
	throw_range = 10

	var/list/cards = list()
	/// How often the deck can be shuffled.
	var/shuffle_cooldown = 0
	/// How many copies of the base deck (built in build_deck()) should be added?
	var/deck_size = 1
	/// The number of cards in a full deck. Set on init after all cards are created/added.
	var/deck_total = 0
	/// Styling for the cards, if they have multiple sets of sprites
	var/card_style = null
	/// Styling for the deck, it they has multiple sets of sprites
	var/deck_style = null
	/// For decks without a full set of sprites
	var/simple_deck = FALSE
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
	/// ID used to track the decks and cardhands that can be combined into one another.
	var/main_deck_id = -1
	/// The name of the last player to interact with this deck.
	var/last_player_name
	/// The action that the last player made. Should be in the form of "played a card", "drew a card."
	var/last_player_action
	// var/datum/proximity_monitor/advanced/card_deck/proximity_monitor
	var/datum/card_deck_table_tracker/tracker

/obj/item/deck/Initialize(mapload, parent_deck_id = -1)
	. = ..()
	build_decks()
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	if(parent_deck_id == -1)
		// we're our own deck
		main_deck_id = rand(1, 99999)
	else
		main_deck_id = parent_deck_id

	return INITIALIZE_HINT_LATELOAD

/obj/item/deck/LateInitialize(mapload)
	. = ..()

	tracker = new(src)
	RegisterSignal(src, COMSIG_ATOM_RANGED_ATTACKED, PROC_REF(on_ranged_attack))

/obj/item/deck/Destroy()
	qdel(tracker)
	. = ..()

/obj/item/deck/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It contains <b>[length(cards) ? length(cards) : "no"]</b> card\s.</span>"
	if(last_player_name && last_player_action)
		. += "<span class='notice'>Most recent action: [last_player_name] [last_player_action].</span>"
	if(in_play_range(user) && !Adjacent(user))
		. += "<span class='boldnotice'>You're in range of this card-hand, and can use it at a distance!</span>"
	else
		. += "<span class='notice'>You're too far away from this deck to play from it.</span>"
	. += ""
	. += "<span class='notice'>Drag [src] to yourself to pick it up.</span>"
	. += "<span class='notice'>Examine this again to see some shortcuts for interacting with it.</span>"

/obj/item/deck/examine_more(mob/user)
	. = ..()
	. += "<span class='notice'><b>Click</b> to draw a card.</span>"
	. += "<span class='notice'><b>Alt-Click</b> to place a card.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> to split [src].</span>"
	. += "<span class='notice'>If you draw or return cards with <span class='danger'>harm</span> intent, your plays will be public!</span>"
	. += "<span class='notice'>With cards in your active hand...</span>"
	. += "\t<span class='notice'><b>Ctrl-Click</b> with cards to place them at the bottom of the deck.</span>"
	. += ""
	. += "You also notice a little number on the corner of [src]: it's tagged [main_deck_id]."

/obj/item/deck/proc/add_most_recent_action(mob/user, action)
	last_player_name = "[user]"
	last_player_action = action

/// Fill the deck with all the specified cards.
/// Uses deck_size to determine how many times to call build_deck()
/obj/item/deck/proc/build_decks()
	if(length(cards))
		// prevent building decks more than once
		return
	for(var/deck in 1 to deck_size)
		build_deck()
	deck_total = length(cards)

/// Stub, override this to define how a base deck should be filled and built.
/obj/item/deck/proc/build_deck()
	return

/obj/item/deck/proc/on_ranged_attack(mob/source, mob/living/carbon/human/attacker)
	SIGNAL_HANDLER  // COMSIG_ATOM_RANGED_ATTACKED
	if(!istype(attacker))
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attack_hand), attacker)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/deck/attackby__legacy__attackchain(obj/O, mob/user)
	// clicking is for drawing
	if(istype(O, /obj/item/deck))
		var/obj/item/deck/other_deck = O
		if(other_deck.main_deck_id != main_deck_id)
			to_chat(user, "<span class='warning'>These aren't the same deck!</span>")
			return

		merge_deck(user, O)
		return

	if(istype(O, /obj/item/pen))
		rename_interactive(user, O)
		return

	if(!istype(O, /obj/item/cardhand))
		return ..()
	var/obj/item/cardhand/H = O
	if(H.parent_deck_id != main_deck_id)
		to_chat(user, "<span class='warning'>You can't mix cards from different decks!</span>")
		return

	draw_card(user, user.a_intent == INTENT_HARM)

/obj/item/deck/proc/in_play_range(mob/user)

	if(HAS_TRAIT(user, TRAIT_TELEKINESIS))
		return TRUE

	if(HAS_TRAIT_FROM(user, TRAIT_PLAYING_CARDS, "deck_[main_deck_id]"))
		return TRUE

	return Adjacent(user)

/obj/item/deck/CtrlShiftClick(mob/living/carbon/human/user)
	. = ..()
	if(!Adjacent(user) || !istype(user))
		return
	if(length(cards) <= 1)
		to_chat(user, "<span class='notice'>You can't split this deck, it's too small!</span>")
		return

	var/num_cards = tgui_input_number(user, "How many cards would you like the new split deck to have?", "Split Deck", length(cards) / 2, length(cards), 0)
	if(isnull(num_cards) || !in_play_range(user))
		return

	// split it off, with our deck ID.
	var/obj/item/deck/new_deck = new src.type(get_turf(src), main_deck_id)
	QDEL_LIST_CONTENTS(new_deck.cards)
	new_deck.cards = cards.Copy(1, num_cards + 1)
	cards.Cut(1, num_cards + 1)
	user.put_in_any_hand_if_possible(new_deck)
	user.visible_message("<span class='notice'>[user] splits [src] in two.</span>", "<span class='notice'>You split [src] in two.</span>")
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	new_deck.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/deck/proc/merge_deck(mob/user, obj/item/deck/other_deck)
	if(main_deck_id != other_deck.main_deck_id)
		if(user)
			to_chat(user, "<span class='warning'>These decks didn't both come from the same original deck, you can't merge them!</span>")
			return
	for(var/card in other_deck.cards)
		cards += card
		other_deck.cards -= card
	qdel(other_deck)
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	if(user)
		add_most_recent_action(user, "merged with [other_deck]")
		user.visible_message("<span class='notice'>[user] mixes the two decks together.</span>", "<span class='notice'>You merge the two decks together.</span>")

/obj/item/deck/attack_hand(mob/user)
	draw_card(user, user.a_intent == INTENT_HARM)

/obj/item/deck/AltClick(mob/living/carbon/human/user)
	// alt-clicking is for putting back
	return_hand_click(user, TRUE)

/// Return a single card to the deck.
/obj/item/deck/proc/return_hand_click(mob/living/carbon/human/user, on_top = TRUE)
	if(!istype(user))
		return
	var/obj/item/cardhand/hand = user.get_active_card_hand()
	if(!istype(hand))
		return

	if(length(hand.cards) == 1)
		// we need to put this into a new list, otherwise things get funky if they reference both the hand list and this other list
		return_cards(user, hand, on_top, hand.cards.Copy())
		return
	var/datum/playingcard/selected_card = hand.select_card_radial(user)
	if(QDELETED(selected_card))
		return
	return_cards(user, hand, on_top, list(selected_card))

/obj/item/deck/MouseDrop_T(obj/item/I, mob/user)
	if(!istype(I, /obj/item/cardhand))
		return
	if(!in_play_range(user) || !user.Adjacent(I))
		return
	var/choice = tgui_alert(user, "Where would you like to return your hand to the deck?", "Return Hand", list("Top", "Bottom", "Cancel"))
	if(!in_play_range(user) || !user.Adjacent(I) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || isnull(choice) || choice == "Cancel")
		return

	return_cards(user, I, choice == "Top")

// is this getting too complicated?

/**
 * Return a number of cards to a deck.
 *
 * Arguments:
 * * user - The mob returning the cards.
 * * hand - The hand from which the cards are being returned.
 * * place_on_top - If true, cards will be placed on the top of the deck. Otherwise, they'll be placed on the bottom.
 * * chosen_cards - If not empty, will essentially override any selection dialogs and force these cards to be returned.
 */
/obj/item/deck/proc/return_cards(mob/living/carbon/human/user, obj/item/cardhand/hand, place_on_top = TRUE, chosen_cards = list())

	if(!istype(hand))
		return

	if(!in_play_range(user))
		return

	if(hand.parent_deck_id != main_deck_id)
		to_chat(user, "<span class='warning'>You can't mix cards from different decks!</span>")
		return

	var/side = place_on_top ? "top" : "bottom"

	// if we have chosen cards, we can skip confirmation since that should have probably happened before us
	if(!length(chosen_cards))
		if(length(hand.cards) > 1)
			var/confirm = tgui_alert(user, "Are you sure you want to put your [length(hand.cards)] card\s into the [side] of the deck?", "Return Hand to Bottom", list("Yes", "No"))
			if(confirm != "Yes" || !in_play_range(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
				return
		chosen_cards = hand.cards.Copy()  // copy the list since we might be deleting the ref

	if(place_on_top)
		cards = chosen_cards + cards
	else
		// equiv to += but here for clarity
		cards = cards + chosen_cards
	hand.cards -= chosen_cards
	if(!length(hand.cards))
		qdel(hand)
	else
		hand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(length(chosen_cards) == 1)
		if(!hand.concealed)
			// do the attack animation with the single card being played
			var/datum/playingcard/P = chosen_cards[1]
			if(user.a_intent == INTENT_HARM)
				var/obj/effect/temp_visual/card_preview/draft = new /obj/effect/temp_visual/card_preview(user, P.card_icon)
				user.vis_contents += draft
				QDEL_IN(draft, 1 SECONDS)
				sleep(1 SECONDS)
			add_most_recent_action(user, "placed [P] on the [side]")
			user.visible_message("<span class='notice'>[user] places [P] on the [side] of [src].</span>", "<span class='notice'>You place [P] on the [side] of [src].</span>")
			user.do_attack_animation(src, hand)
			update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
			return
			// don't attack with the open hand lol
		user.do_attack_animation(src, no_effect = TRUE)

	add_most_recent_action(user, "placed [length(chosen_cards)] card\s on the [side]")
	user.visible_message("<span class='notice'>[user] returns [length(chosen_cards)] card\s to the [side] of [src].</span>", "<span class='notice'>You return [length(chosen_cards)] card\s to the [side] of [src].</span>")


// deck datum actions
/datum/action/item_action/draw_card
	name = "Draw - Draw one card"
	button_icon_state = "draw"

/datum/action/item_action/draw_card/Trigger(left_click)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.draw_card(owner)
	return ..()

/datum/action/item_action/deal_card
	name = "Deal - deal one card to a person next to you"
	button_icon_state = "deal_card"

/datum/action/item_action/deal_card/Trigger(left_click)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card(owner)
	return ..()

/datum/action/item_action/deal_card_multi
	name = "Deal multiple card - Deal multiple card to a person next to you"
	button_icon_state = "deal_card_multi"

/datum/action/item_action/deal_card_multi/Trigger(left_click)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card_multi(owner)
	return ..()

/datum/action/item_action/shuffle
	name = "Shuffle - shuffle the deck"
	button_icon_state = "shuffle"

/datum/action/item_action/shuffle/Trigger(left_click)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deckshuffle(owner)
	return ..()

/**
 * Draw a card from this deck.
 * Arguments:
 * * user - The mob drawing the card.
 * * public - If true, the drawn card will be displayed to people around the table.
 * * draw_from_top - If true, the card will be drawn from the top of the deck.
 */
/obj/item/deck/proc/draw_card(mob/living/carbon/human/user, public = FALSE, draw_from_top = TRUE)

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_play_range(user) || !istype(user))
		return

	if(!length(cards))
		to_chat(user,"<span class='notice'>There are no cards in the deck.</span>")
		return

	var/obj/item/cardhand/H = user.get_active_card_hand()
	if(H && (H.parent_deck_id != main_deck_id))
		to_chat(user,"<span class='warning'>You can't mix cards from different decks!</span>")
		return

	if(!H)
		H = new(get_turf(src))
		user.put_in_hands(H)

	var/datum/playingcard/P = draw_from_top ? cards[1] : cards[length(cards)]
	H.cards += P
	cards -= P
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	H.parent_deck_id = main_deck_id
	H.update_values_from_deck(src)
	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

	user.do_attack_animation(src, no_effect = TRUE)
	if(public)
		add_most_recent_action(user, "drew \a [P.name]")
		user.visible_message("<span class='danger'>[user] draws \a [P.name]!</span>", "<span class='danger'>You draw \a [P]!</span>", "<span class='notice'>You hear a card be drawn.</span>")
		var/obj/effect/temp_visual/card_preview/draft = new /obj/effect/temp_visual/card_preview(user, P.card_icon)
		user.vis_contents += draft
		QDEL_IN(draft, 1 SECONDS)
		sleep(1 SECONDS)
	else
		add_most_recent_action(user, "drew a card")
		user.visible_message("<span class='notice'>[user] draws a card.</span>", "<span class='notice'>You draw a card.</span>", "<span class='notice'>You hear a card be drawn.</span>")
		to_chat(user, "<span class='notice'>It's \a [P.name].</span>")

// Classic action
/obj/item/deck/proc/deal_card(mob/user)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_play_range(user))
		return

	if(!length(cards))
		to_chat(user, "<span class='notice'>There are no cards in the deck.</span>")
		return

	var/list/players = list()
	for(var/mob/living/player in viewers(3))
		players += player

	var/mob/living/M = tgui_input_list(user, "Who do you wish to deal a card to?", "Deal Card", players)
	if(QDELETED(user) || QDELETED(src) || QDELETED(M) || !in_play_range(user))
		return

	deal_at(usr, M, 1)

/obj/item/deck/proc/deal_card_multi(mob/user)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!length(cards))
		to_chat(user, "<span class='notice'>There are no cards in the deck.</span>")
		return

	var/list/players = list()
	for(var/mob/living/player in viewers(3))
		if(!player.incapacitated())
			players += player
	var/dcard = tgui_input_number(user, "How many card(s) do you wish to deal? You may deal up to [length(cards)] card\s.", "Deal Cards", 1, length(cards), 1)
	if(isnull(dcard))
		return
	var/mob/living/M = tgui_input_list(user, "Who do you wish to deal [dcard] card\s?", "Deal Card", players)
	if(!user || !src || !M || !Adjacent(user))
		return

	deal_at(user, M, dcard)

/obj/item/deck/proc/deal_at(mob/user, mob/target, dcard) // Take in the no. of card to be dealt
	var/obj/item/cardhand/H = new(get_step(user, user.dir))
	for(var/i in 1 to dcard)
		H.cards += cards[1]
		cards -= cards[1]
		update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	H.parent_deck_id = main_deck_id
	H.update_values_from_deck(src)
	H.concealed = TRUE
	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(user == target)
		add_most_recent_action(user, "dealt [dcard] card\s to [user.p_themselves()]")
		user.visible_message(
			"<span class='notice'>[user] deals [dcard] card\s to [user.p_themselves()].</span>",
			"<span class='notice'>You deal [dcard] card\s to yourself.</span>",
			"<span class='notice'>You hear cards being dealt.</span>"
		)
	else
		add_most_recent_action(user, "dealt [dcard] card\s to [target]")
		user.visible_message(
			"<span class='notice'>[user] deals [dcard] card\s to [target].</span>",
			"<span class='notice'>You deal [dcard] card\s to [target].</span>",
			"<span class='notice'>You hear cards being dealt.</span>"
		)
	H.throw_at(get_step(target, target.dir), 3, 1, null)

/obj/item/deck/attack_self__legacy__attackchain(mob/user)
	deckshuffle(user)

/obj/item/deck/proc/deckshuffle(mob/user)
	if(shuffle_cooldown < world.time - 1 SECONDS)
		cards = shuffle(cards)

		if(user)
			add_most_recent_action(user, "shuffled [src]")
			user.visible_message(
				"<span class='notice'>[user] shuffles [src].</span>",
				"<span class='notice'>You shuffle [src].</span>",
				"<span class='notice'>You hear cards being shuffled.</span>"
			)
			playsound(user, 'sound/items/cardshuffle.ogg', 50, TRUE)
		shuffle_cooldown = world.time

	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

/obj/item/deck/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	var/mob/M = usr
	if(M.incapacitated() || !Adjacent(M))
		return ..()

	if(!ishuman(M))
		return ..()

	if(is_screen_atom(over))
		if(!remove_item_from_storage(get_turf(M)))
			M.drop_item_to_ground(src)
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

	return ..()


/obj/item/pack
	name = "card pack"
	desc = "For those with disposable income."

	icon_state = "card_pack"
	icon = 'icons/obj/playing_cards.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/cards = list()
	var/parentdeck = null // For future card pack that need to be compatible with eachother i.e. cardemon


/obj/item/pack/attack_self__legacy__attackchain(mob/user as mob)
	user.visible_message(
		"<span class='notice'>[name] rips open [src]!</span>",
		"<span class='notice'>You rip open [src]!</span>",
		"<span class='notice'>You hear the sound of a packet being ripped open.</span>"
	)
	var/obj/item/cardhand/H = new(get_turf(user))

	H.cards += cards
	cards.Cut()
	user.unequip(src, force = TRUE)
	qdel(src)

	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.put_in_hands(H)

/obj/item/cardhand
	name = "hand of cards"
	desc = "Some playing cards."
	icon = 'icons/obj/playing_cards.dmi'
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/remove_card, /datum/action/item_action/discard)
	/// If true, the cards will be face down.
	var/concealed = FALSE
	/// All of the cards in the deck.
	var/list/cards = list()
	/// Tracked direction, which is used when updating the hand's appearance instead of messing with the local dir
	var/direction = NORTH
	/// The ID of the base deck that we belong to.
	// This ID can correspond to multiple decks, but those decks will only ever be sub-decks of the original deck this hand's cards came from.
	var/parent_deck_id = null

/obj/item/cardhand/examine(mob/user)
	. = ..()
	if(!concealed && length(cards))
		. += "<span class='notice'>It contains:</span>"
		for(var/datum/playingcard/P as anything in cards)
			. += "\t<span class='notice'>the [P.name].</span>"

	if(Adjacent(user))
		. += "<span class='notice'><b>Click</b> this in-hand to select a card to draw.</span>"
		. += "<span class='notice'><b>Ctrl-Click</b> this to flip it.</span>"
		if(loc == user)
			. += "<span class='notice'><b>Alt-Click</b> this in-hand to see the legacy interaction menu.</span>"
		else
			. += "<span class='notice'><b>Alt-Click</b> this to add a card from your deck to it.</span>"

		. += "<span class='notice'><b>Drag</b> this to its associated deck to return all cards at once to it.</span>"
		. += "<span class='notice'><b>Enable throw mode</b> to automatically catch cards and add them to your hand.</span>"
		. += "<span class='notice'><b>Drag-and-Drop</b> this onto another hand to merge the cards together.</span>"
		if(loc != user)
			. += "<span class='notice'>You can <b>Drag</b> this to yourself from here to draw cards from it.</span>"

/obj/item/cardhand/examine_more(mob/user)
	. = ..()
	. += "You notice a little number on the corner of [src]: it's tagged [parent_deck_id]."

/obj/item/cardhand/proc/single()
	return length(cards) == 1

/obj/item/cardhand/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	// this is how we handle our ranged attacks.
	. = ..()
	if(!istype(target, /obj/item/deck) || proximity_flag)
		// if we're adjacent to the deck, don't do anything since we'll already be using attackby.
		return

	var/obj/item/deck/D = target
	if(D.in_play_range(user))
		return D.attackby__legacy__attackchain(src, user)

/obj/item/deck/hitby(atom/movable/thrown, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)

	if(!istype(thrown, /obj/item/cardhand))
		return ..()

	var/obj/item/cardhand/hand = thrown

	if(hand.parent_deck_id != main_deck_id)
		return ..()

	// you can only throw single cards in this way
	if(length(hand.cards) > 1)
		return ..()

	if(hand.concealed)
		visible_message("<span class='warning'>A card lands on top of [src].</span>")
	else
		var/datum/playingcard/C = hand.cards[1]
		visible_message("<span class='warning'>[C] lands atop [src]!</span>")

	cards = hand.cards + cards
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	hand.cards.Cut()
	qdel(hand)

/obj/item/cardhand/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!ishuman(hit_atom))
		return ..()

	var/mob/living/carbon/human/M = hit_atom


	var/obj/item/cardhand/hand = M.get_active_card_hand()
	if(!istype(hand) || !M.in_throw_mode || hand.parent_deck_id != parent_deck_id)
		return ..()

	M.visible_message(
		"<span class='warning'>[M] catches [hand] and adds it to [M.p_their()] hand!</span>",
		"<span class='danger'>You catch [hand] and add it to your existing hand!</span>"
	)
	add_cardhand_to_self(hand)

/// Merge the target cardhand into the current cardhand
/obj/item/cardhand/proc/add_cardhand_to_self(obj/item/cardhand/hand)
	if(!parent_deck_id == hand.parent_deck_id)
		stack_trace("merge_into tried to merge two different parent decks together!")
		return

	for(var/card in hand.cards)
		cards += card
		hand.cards -= card

	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

	qdel(hand)

/obj/item/cardhand/proc/transfer_card_to_self(obj/item/cardhand/source_hand, datum/playingcard/card)
	if(!istype(source_hand) || !(card in source_hand.cards) || (source_hand.parent_deck_id != parent_deck_id))
		return
	source_hand.cards -= card
	cards += card

	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(!length(source_hand.cards))
		qdel(source_hand)
	else
		source_hand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

/// Update our card values based on those set on a deck
/obj/item/cardhand/proc/update_values_from_deck(obj/item/deck/D)
	if(!parent_deck_id)
		return
	hitsound = D.card_hitsound
	force = D.card_force
	throwforce = D.card_throwforce
	throw_speed = D.card_throw_speed
	throw_range = D.card_throw_range
	attack_verb = D.card_attack_verb
	resistance_flags = D.card_resistance_flags

/// Update our own card values to reflect that of some source hand
/obj/item/cardhand/proc/update_values_from_cards(obj/item/cardhand/source)
	if(isnull(source) || !istype(source))
		return

	hitsound = source.hitsound
	force = source.force
	throwforce = source.throwforce
	throw_speed = source.throw_speed
	throw_range = source.throw_range
	attack_verb = source.attack_verb
	resistance_flags = source.resistance_flags

/obj/item/cardhand/attackby__legacy__attackchain(obj/O, mob/user)
	// Augh I really don't like this
	if(length(cards) == 1 && is_pen(O))
		var/datum/playingcard/P = cards[1]
		if(P.name != "Blank Card")
			to_chat(user,"<span class='notice'>You cannot write on this card.</span>")
			return
		var/card_text = rename_interactive(user, O, use_prefix = FALSE, actually_rename = FALSE)
		if(card_text && P.name == "Blank Card")
			P.name = card_text
		// SNOWFLAKE FOR CAG, REMOVE IF OTHER CARDS ARE ADDED THAT USE THIS.
		P.card_icon = "cag_white_card"
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	else if(istype(O, /obj/item/cardhand))
		var/obj/item/cardhand/H = O
		// if you're attacking a cardhand with one in hand, merge it into our deck.
		// remember that "we" are the one being attacked here.
		if(H.parent_deck_id == parent_deck_id)
			if(!Adjacent(user))
				return
			var/datum/playingcard/chosen = select_card_radial(user)
			if(QDELETED(chosen))
				return
			user.visible_message(
				"<span class='notice'>[user] adds [concealed ? "a card" : chosen.name] to [user.p_their()] hand.</span>",
				"<span clas='notice'>You add [chosen.name] to your deck.</span>",
				"<span class='notice'>You hear cards being shuffled together.</span>"
			)
			H.transfer_card_to_self(src, chosen)
			return
		else
			to_chat(user, "<span class='notice'>You cannot mix cards from other decks!</span>")
			return
	return ..()

/obj/item/cardhand/attack_self__legacy__attackchain(mob/user)
	if(length(cards) == 1)
		turn_hand(user)
		return
	var/datum/playingcard/card = select_card_radial(user)
	if(QDELETED(card))
		return
	remove_card(user, card)

/mob/living/carbon/proc/get_active_card_hand()
	var/obj/item/cardhand/hand = get_active_hand()
	if(!istype(hand))
		hand = get_inactive_hand()
	if(istype(hand))
		return hand

/obj/item/cardhand/AltClick(mob/living/carbon/human/user)
	. = ..()
	if(!istype(user))
		return
	var/obj/item/cardhand/active_hand = user.get_active_card_hand()
	if(istype(active_hand) && active_hand == src)
		user.set_machine(src)
		interact(user)
		return
	// otherwise, it's somewhere else. We'll try to play a card to that hand.
	if(!Adjacent(user))
		return

	if(!istype(active_hand))
		return

	if(active_hand.parent_deck_id != parent_deck_id)
		to_chat(user, "<span class='warning'>These cards don't all come from the same deck!</span>")
		return


	var/datum/playingcard/card_to_insert = active_hand.select_card_radial(user)
	if(QDELETED(card_to_insert))
		return

	transfer_card_to_self(active_hand, card_to_insert)
	user.visible_message(
		"<span class='notice'>[user] moves [concealed ? "a card" : "[card_to_insert]"] to the other hand.</span>",
		"<span class='notice'>You move [concealed ? "a card" : "[card_to_insert]"] to the other hand.</span>",
		"<span class='notice'>You hear a card being drawn, followed by a card being added to a hand.</span>"
	)



/obj/item/cardhand/CtrlClick(mob/user)
	turn_hand(user)

/obj/item/cardhand/AltShiftClick(mob/user)
	. = ..()
	if(!Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	shuffle_inplace(cards)
	update_appearance(UPDATE_DESC|UPDATE_OVERLAYS)
	playsound(user, 'sound/items/cardshuffle.ogg', 30, TRUE)
	user.visible_message(
		"<span class='notice'>[user] shuffles [user.p_their()] hand.</span>",
		"<span class='notice'>You shuffle your hand.</span>",
		"<span class='notice'>You hear cards shuffling.</span>"
	)

/// Dragging a card to your hand will let you draw from it without picking it up.
/obj/item/cardhand/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!isliving(usr) || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(istype(over, /obj/item/deck))
		return over.MouseDrop_T(src, usr)
	if(over != usr || !Adjacent(usr))
		return ..()

	to_chat(usr, "<span class='notice'>Select a card to draw from the hand.</span>")
	var/datum/playingcard/card_chosen = select_card_radial(usr)
	if(QDELETED(card_chosen))
		return

	remove_card(usr, card_chosen)

/obj/item/cardhand/MouseDrop_T(obj/item/I, mob/user)
	// dropping our hand onto another
	if(!istype(I, /obj/item/cardhand))
		return
	if(!user.Adjacent(I) || !Adjacent(user))
		return
	var/obj/item/cardhand/other_hand = I
	if(other_hand.parent_deck_id != parent_deck_id)
		to_chat(user, "<span class='warning'>These cards don't all come from the same deck!</span>")
		return
	if(length(other_hand.cards) > 1)
		var/response = tgui_alert(user, "Are you sure you want to merge [length(other_hand.cards)] cards into your currently held hand?", "Merge cards", list("Yes", "No"))
		if(response != "Yes" || QDELETED(src) || QDELETED(other_hand) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
			return

	add_cardhand_to_self(other_hand)


/// Open a radial menu to select a single card from a hand.
/obj/item/cardhand/proc/select_card_radial(mob/user)
	if(!length(cards) || QDELETED(user) || !Adjacent(user))
		return
	var/list/options = list()
	for(var/datum/playingcard/P in cards)
		if(isnull(options[P]))
			options[P] = image(icon = 'icons/obj/playing_cards.dmi', icon_state = !concealed ? P.card_icon : P.back_icon)

	var/datum/playingcard/choice = show_radial_menu(user, src, options)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.stat != CONSCIOUS || QDELETED(choice) || !(choice in cards) || !Adjacent(user))
		return

	return choice


/obj/item/cardhand/proc/turn_hand(mob/user)
	concealed = !concealed
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.visible_message(
		"<span class='notice'>[user] [concealed ? "conceals" : "reveals"] [user.p_their()] hand.</span>",
		"<span class='notice'>You [concealed ? "conceal" : "reveal"] your hand.</span>",
		"<span class='notice'>You hear a hand of cards being flipped over.</span>"
	)

/obj/item/cardhand/interact(mob/user)
	var/dat = "You have:<br>"
	for(var/datum/playingcard/C in cards)
		dat += "<a href='byond://?src=[UID()];pick=[C.UID()]'>The [C]</a><br>"
	dat += "Which card will you remove next?<br>"
	dat += "<a href='byond://?src=[UID()];pick=Turn'>Turn the hand over</a>"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
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
			if(cardUser.get_item_by_slot(ITEM_SLOT_LEFT_HAND) == src || cardUser.get_item_by_slot(ITEM_SLOT_RIGHT_HAND) == src)
				var/datum/playingcard/picked_card = locateUID(href_list["pick"])
				if(istype(picked_card) && Adjacent(cardUser) && (picked_card in cards) && !QDELETED(src))
					remove_card(cardUser, picked_card)
		cardUser << browse(null, "window=cardhand")


/obj/item/cardhand/point_at(atom/pointed_atom)

	if(!isturf(loc))
		return

	if(length(cards) != 1)
		return ..()

	var/datum/playingcard/card = cards[1]

	if(!(pointed_atom in src) && !(pointed_atom.loc in src))
		return

	var/obj/effect/temp_visual/card_preview/draft = new /obj/effect/temp_visual/card_preview(usr, card.card_icon)
	usr.vis_contents += draft

	QDEL_IN(draft, 0.6 SECONDS)


// Datum action here

/datum/action/item_action/remove_card
	name = "Remove a card - Remove a single card from the hand."
	button_icon_state = "remove_card"

/datum/action/item_action/remove_card/IsAvailable(show_message = TRUE)
	var/obj/item/cardhand/C = target
	if(length(C.cards) <= 1)
		return FALSE
	return ..()

/datum/action/item_action/remove_card/Trigger(left_click)
	if(!IsAvailable())
		return
	if(istype(target, /obj/item/cardhand))
		var/obj/item/cardhand/C = target
		return C.remove_card(owner)
	return ..()

/datum/action/item_action/discard
	name = "Discard - Place one or more cards from your hand in front of you."
	button_icon_state = "discard"

/datum/action/item_action/discard/Trigger(left_click)
	if(istype(target, /obj/item/cardhand))
		var/obj/item/cardhand/C = target
		return C.discard(owner)
	return ..()

// No more datum action here

/// Create a new card-hand from a list of cards in the other hand.
/obj/item/cardhand/proc/split(list/cards_in_new_hand)
	if(length(cards) == 0 || length(cards_in_new_hand) == 0)
		return

	var/obj/item/cardhand/new_hand = new()
	for(var/datum/playingcard/card in cards_in_new_hand)
		new_hand.cards += card
		cards -= card

	new_hand.parent_deck_id = parent_deck_id
	new_hand.update_values_from_cards(src)
	new_hand.concealed = concealed
	new_hand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

	return new_hand



/// Draw a card from a card hand.
/// If a picked card isn't given,
/obj/item/cardhand/proc/remove_card(mob/living/carbon/user, datum/playingcard/picked_card)

	if(!istype(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!picked_card)
		var/pickablecards = list()
		for(var/datum/playingcard/P in cards)
			pickablecards[P.name] = P
		var/selected_card = tgui_input_list(user, "Which card do you want to remove from the hand?", "Remove Card", pickablecards)
		picked_card = pickablecards[selected_card]
		if(!picked_card)
			return

	if(QDELETED(src))
		return

	if(!Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !ishuman(user)) // Don't want people teleporting cards
		return

	// let people draw cards from tables with this mechanism, as well as removing from their hand.
	var/obj/item/cardhand/active_hand = user.get_active_card_hand()
	if(user.l_hand == src || user.r_hand == src)
		// if you're drawing a card from your left hand, you probably want it in your right.
		user.visible_message(
			"<span class='notice'>[user] draws [concealed ? "a card" : "[picked_card]"] from [user.p_their()] hand.</span>",
			"<span class='notice'>You take \the [picked_card] from your hand.</span>",
			"<span class='notice'>You hear a card being drawn.</span>"
		)
	else if(istype(active_hand))
		// you're drawing from a hand the user isn't holding to one that the user is.
		// try to put that card into our currently held hand.
		active_hand.transfer_card_to_self(src, picked_card)
		user.visible_message(
			"<span class='notice'>[user] draws [concealed ? "a card" : "[picked_card]"] to [user.p_their()].</span>",
			"<span class='notice'>You draw \the [picked_card] to your hand.</span>",
			"<span class='notice'>You hear a card being drawn.</span>"
		)
		return


	var/obj/item/cardhand/H = new(get_turf(src))
	. = H

	H.cards += picked_card
	cards -= picked_card
	H.parent_deck_id = parent_deck_id
	H.update_values_from_cards(src)
	H.concealed = concealed
	H.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(!length(cards))
		qdel(src)
		return
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

	user.put_in_hands(H)

/obj/item/cardhand/proc/discard(mob/living/carbon/user)

	if(!istype(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	var/discards = tgui_input_number(user, "How many cards do you want to discard?", "Discard Cards", max_value = length(cards))

	if(!istype(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || QDELETED(src))
		return
	for(var/i in 1 to discards)
		if(!length(cards))
			break
		var/datum/playingcard/selected = select_card_radial(user)
		if(!selected || !Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || QDELETED(src))
			break

		if(QDELETED(src))
			return

		var/obj/item/cardhand/new_hand = remove_card(user, selected)

		new_hand.direction = user.dir
		new_hand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(length(cards))
			update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(length(new_hand.cards))
			user.visible_message(
				"<span class='notice'>[user] plays \the [selected].</span>",
				"<span class='notice'>You play \the [selected].</span>",
				"<span class='notice'>You hear a card being played.</span>"
			)
		user.drop_item_to_ground(new_hand)
		var/atom/drop_location = get_step(user, user.dir)
		var/obj/item/cardhand/hand_on_the_table = locate(/obj/item/cardhand) in drop_location
		if(istype(hand_on_the_table) && parent_deck_id == hand_on_the_table.parent_deck_id)
			hand_on_the_table.add_cardhand_to_self(new_hand)
			continue  // get outtie since this qdels the hand
		new_hand.forceMove(drop_location)

	if(!length(cards))
		qdel(src)

/obj/item/cardhand/update_appearance(updates=ALL)
	if(!length(cards))
		return
	if(length(cards) <= 2)
		update_action_buttons()
	..()

/obj/item/cardhand/update_name()
	. = ..()
	if(length(cards) > 1)
		name = "hand of [length(cards)] card\s"
	else
		name = "playing card"

/obj/item/cardhand/update_desc()
	. = ..()
	if(length(cards) > 1)
		desc = "Some playing cards."
	else
		if(concealed)
			desc = "A playing card. You can only see the back."
		else
			var/datum/playingcard/card = cards[1]
			desc = "\A [card.name]."

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
	// var/i = 0
	for(var/i in 1 to length(cards))
		var/datum/playingcard/P = cards[i]
		if(i >= 20)
			// skip the rest and just draw the last one on top
			. += render_card(cards[length(cards)], M, i, offset)
			break
		. += render_card(P, M, i, offset)
		i++

/obj/item/cardhand/proc/render_card(datum/playingcard/card, matrix/mat, index, offset)
	var/image/I = new(icon, (concealed ? "[card.back_icon]" : "[card.card_icon]") )
	switch(direction)
		if(SOUTH)
			I.pixel_x = 8 - (offset * index)
		if(WEST)
			I.pixel_y = -6 + (offset * index)
		if(EAST)
			I.pixel_y = 8 - (offset * index)
		else
			I.pixel_x = -7 + (offset * index)
	I.transform = mat
	return I

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
