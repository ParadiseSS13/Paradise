/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy swords
 *		Toy mechs
 *		Snap pops
 *		Water flower
 *		Toy Nuke
 *		Card Deck
 *		Therapy dolls
 *		Toddler doll
 *		Inflatable duck
 *		Foam armblade
 *		Mini Gibber
 *		Toy xeno
 *		Toy chainsaws
 *		Action Figures
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0


/*
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/balloon/New()
	..()
	create_reagents(10)

/obj/item/toy/balloon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/balloon/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(istype(A, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = A
		if(RD.reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>[RD] is empty.</span>")
		else if(reagents.total_volume >= 10)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			A.reagents.trans_to(src, 10)
			to_chat(user, "<span class='notice'>You fill the balloon with the contents of [A].</span>")
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_icon()

/obj/item/toy/balloon/wash(mob/user, atom/source)
	if(reagents.total_volume < 10)
		reagents.add_reagent("water", min(10-reagents.total_volume, 10))
		to_chat(user, "<span class='notice'>You fill the balloon from the [source].</span>")
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		update_icon()
	return

/obj/item/toy/balloon/attackby(obj/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/reagent_containers/glass) || istype(O, /obj/item/reagent_containers/food/drinks/drinkingglass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				to_chat(user, "The [O] is empty.")
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent("facid", 1))
					to_chat(user, "The acid chews through the balloon!")
					O.reagents.reaction(user)
					qdel(src)
				else
					desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, "<span class='notice'>You fill the balloon with the contents of [O].</span>")
					O.reagents.trans_to(src, 10)
	update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(reagents.total_volume >= 1)
		visible_message("<span class='warning'>The [src] bursts!</span>","You hear a pop and a splash.")
		reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			reagents.reaction(A)
		icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/balloon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = WEIGHT_CLASS_BULKY
	var/lastused = null

/obj/item/toy/syndicateballoon/attack_self(mob/user)
	if(world.time - lastused < CLICK_CD_MELEE)
		return
	var/playverb = pick("bat [src]", "tug on [src]'s string", "play with [src]")
	user.visible_message("<span class='notice'>[user] plays with [src].</span>", "<span class='notice'>You [playverb].</span>")
	lastused = world.time

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon_state = "sword0"
	item_state = "sword0"
	var/active = FALSE
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")

/obj/item/toy/sword/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>")
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		icon_state = "swordblue"
		item_state = "swordblue"
		w_class = WEIGHT_CLASS_BULKY
	else
		to_chat(user, "<span class='notice'>You push the plastic blade back down into the handle.</span>")
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		icon_state = "sword0"
		item_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

// Copied from /obj/item/melee/energy/sword/attackby
/obj/item/toy/sword/attackby(obj/item/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/toy/sword))
		if(W == src)
			to_chat(user, "<span class='notice'>You try to attach the end of the plastic sword to... itself. You're not very smart, are you?</span>")
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else if((W.flags & NODROP) || (flags & NODROP))
			to_chat(user, "<span class='notice'>\the [flags & NODROP ? src : W] is stuck to your hand, you can't attach it to \the [flags & NODROP ? W : src]!</span>")
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool.</span>")
			new /obj/item/twohanded/dualsaber/toy(user.loc)
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/twohanded/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords.  Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	force_unwielded = 0
	force_wielded = 0
	origin_tech = null
	attack_verb = list("attacked", "struck", "hit")
	brightness_on = 0
	sharp_when_wielded = FALSE // It's a toy

/obj/item/twohanded/dualsaber/toy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/twohanded/dualsaber/toy/IsReflect()//Stops Toy Dualsabers from reflecting energy projectiles
	return 0

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/toy/katana/suicide_act(mob/user)
	var/dmsg = pick("[user] tries to stab \the [src] into [user.p_their()] abdomen, but it shatters! [user.p_they(TRUE)] look[user.p_s()] as if [user.p_they()] might die from the shame.","[user] tries to stab \the [src] into [user.p_their()] abdomen, but \the [src] bends and breaks in half! [user.p_they(TRUE)] look[user.p_s()] as if [user.p_they()] might die from the shame.","[user] tries to slice [user.p_their()] own throat, but the plastic blade has no sharpness, causing [user.p_them()] to lose [user.p_their()] balance, slip over, and break [user.p_their()] neck with a loud snap!")
	user.visible_message("<span class='suicide'>[dmsg] It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS


/*
 * Snap pops viral shit
 */
/obj/item/toy/snappop/virus
	name = "unstable goo"
	desc = "Your palm is oozing this stuff!"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "red slime extract"
	throwforce = 5.0
	throw_speed = 10
	throw_range = 30
	w_class = WEIGHT_CLASS_TINY


/obj/item/toy/snappop/virus/throw_impact(atom/hit_atom)
	..()
	do_sparks(3, 1, src)
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message("<span class='warning'>The [name] explodes!</span>","<span class='warning'>You hear a bang!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/proc/pop_burst(var/n=3, var/c=1)
	do_sparks(n, c, src)
	new ash_type(loc)
	visible_message("<span class='warning'>[src] explodes!</span>",
		"<span class='italics'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/toy/snappop/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	..()
	pop_burst()

/obj/item/toy/snappop/Crossed(H as mob|obj, oldloc)
	if(ishuman(H) || issilicon(H)) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(issilicon(H) || M.m_intent == MOVE_INTENT_RUN)
			to_chat(M, "<span class='danger'>You step on the snap pop!</span>")
			pop_burst(2, 0)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/respawn), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)


/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/random/mech
	name = "Random Mech Prize"
	desc = "This is a random prize"
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"

/obj/random/mech/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/prize)) //exclude the base type.

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"



/*
|| A Deck of Cards for playing various games of chance ||
*/



obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/parentdeck = null
	var/deckstyle = "nanotrasen"
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 4
	var/card_throw_range = 20
	var/list/card_attack_verb = list("attacked")

obj/item/toy/cards/New()
	..()

obj/item/toy/cards/proc/apply_card_vars(obj/item/toy/cards/newobj, obj/item/toy/cards/sourceobj) // Applies variables for supporting multiple types of card deck
	if(!istype(sourceobj))
		return

obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/list/cards = list()

obj/item/toy/cards/deck/New()
	..()
	icon_state = "deck_[deckstyle]_full"
	for(var/i in 2 to 10)
		cards += "[i] of Hearts"
		cards += "[i] of Spades"
		cards += "[i] of Clubs"
		cards += "[i] of Diamonds"
	cards += "King of Hearts"
	cards += "King of Spades"
	cards += "King of Clubs"
	cards += "King of Diamonds"
	cards += "Queen of Hearts"
	cards += "Queen of Spades"
	cards += "Queen of Clubs"
	cards += "Queen of Diamonds"
	cards += "Jack of Hearts"
	cards += "Jack of Spades"
	cards += "Jack of Clubs"
	cards += "Jack of Diamonds"
	cards += "Ace of Hearts"
	cards += "Ace of Spades"
	cards += "Ace of Clubs"
	cards += "Ace of Diamonds"

obj/item/toy/cards/deck/attack_hand(mob/user as mob)
	var/choice = null
	if(cards.len == 0)
		icon_state = "deck_[deckstyle]_empty"
		to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	cards -= choice
	H.pickup(user)
	user.put_in_active_hand(H)
	visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()

obj/item/toy/cards/deck/attack_self(mob/user as mob)
	if(cooldown < world.time - 50)
		cards = shuffle(cards)
		playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")
		cooldown = world.time

obj/item/toy/cards/deck/attackby(obj/item/toy/cards/singlecard/C, mob/living/user, params)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			if(!user.unEquip(C))
				to_chat(user, "<span class='notice'>The card is stuck to your hand, you can't add it to the deck!</span>")
				return
			cards += C.cardname
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		update_icon()


obj/item/toy/cards/deck/attackby(obj/item/toy/cards/cardhand/C, mob/living/user, params)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			if(!user.unEquip(C))
				to_chat(user, "<span class='notice'>The hand of cards is stuck to your hand, you can't add it to the deck!</span>")
				return
			cards += C.currenthand
			user.visible_message("<span class='notice'>[user] puts [user.p_their()] hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		update_icon()

obj/item/toy/cards/deck/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M  && loc != M)
			M.put_in_hands(src)
			to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("l_hand")
					if(!remove_item_from_storage(M))
						M.unEquip(src)
					M.put_in_l_hand(src)
					to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
				if("r_hand")
					if(!remove_item_from_storage(M))
						M.unEquip(src)
					M.put_in_r_hand(src)
					to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
	else
		to_chat(usr, "<span class='notice'>You can't reach it from here.</span>")

obj/item/toy/cards/deck/update_icon()
	switch(cards.len)
		if(0)
			icon_state = "deck_[deckstyle]_empty"
		if(1 to 10)
			icon_state = "deck_[deckstyle]_low"
		if(11 to 26)
			icon_state = "deck_[deckstyle]_half"
		else
			icon_state = "deck_[deckstyle]_full"

obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	w_class = WEIGHT_CLASS_TINY
	var/list/currenthand = list()
	var/choice = null


obj/item/toy/cards/cardhand/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/item/toy/cards/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=[UID()];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()


obj/item/toy/cards/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	var/O = src
	if(href_list["pick"])
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/cards/singlecard/C = new/obj/item/toy/cards/singlecard(cardUser.loc)
			currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.apply_card_vars(C,O)
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from [cardUser.p_their()] hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)
			update_icon()
			if(currenthand.len == 1)
				var/obj/item/toy/cards/singlecard/N = new/obj/item/toy/cards/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				N.apply_card_vars(N,O)
				cardUser.unEquip(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				to_chat(cardUser, "<span class='notice'>You also take [currenthand[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

obj/item/toy/cards/cardhand/attackby(obj/item/toy/cards/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(C.parentdeck == parentdeck)
			currenthand += C.cardname
			user.unEquip(C)
			user.visible_message("<span class='notice'>[user] adds a card to [user.p_their()] hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			update_icon()
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

obj/item/toy/cards/cardhand/apply_card_vars(obj/item/toy/cards/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "[deckstyle]_hand2" // Another dumb hack, without this the hand is invisible (or has the default deckstyle) until another card is added.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb
	newobj.resistance_flags = sourceobj.resistance_flags


obj/item/toy/cards/singlecard
	name = "card"
	desc = "a card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_down"
	w_class = WEIGHT_CLASS_TINY
	var/cardname = null
	var/flipped = 0
	pixel_x = -5


obj/item/toy/cards/singlecard/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 0)
		if(ishuman(user))
			var/mob/living/carbon/human/cardUser = user
			if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
				cardUser.visible_message("<span class='notice'>[cardUser] checks [cardUser.p_their()] card.</span>", "<span class='notice'>The card reads: [src.cardname]</span>")
			else
				. += "<span class='notice'>You need to have the card in your hand to check it.</span>"


obj/item/toy/cards/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		flipped = 1
		if(cardname)
			icon_state = "sc_[cardname]_[deckstyle]"
			name = cardname
		else
			icon_state = "sc_Ace of Spades_[deckstyle]"
			name = "What Card"
		pixel_x = 5
	else
		flipped = 0
		icon_state = "singlecard_down_[deckstyle]"
		name = "card"
		pixel_x = -5

obj/item/toy/cards/singlecard/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/))
		var/obj/item/toy/cards/singlecard/C = I
		if(C.parentdeck == parentdeck)
			var/obj/item/toy/cards/cardhand/H = new/obj/item/toy/cards/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += cardname
			H.parentdeck = C.parentdeck
			H.apply_card_vars(H,C)
			user.unEquip(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			to_chat(user, "<span class='notice'>You combine the [C.cardname] and the [cardname] into a hand.</span>")
			qdel(C)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

	if(istype(I, /obj/item/toy/cards/cardhand/))
		var/obj/item/toy/cards/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] adds a card to [user.p_their()] hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			H.update_icon()
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

obj/item/toy/cards/cardhand/update_icon()
	switch(currenthand.len)
		if(0 to 1)
			return
		if(2)
			icon_state = "[deckstyle]_hand2"
		if(3)
			icon_state = "[deckstyle]_hand3"
		if(4)
			icon_state = "[deckstyle]_hand4"
		else
			icon_state = "[deckstyle]_hand5"


obj/item/toy/cards/singlecard/attack_self(mob/user)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	Flip()

obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb
	newobj.attack_verb = newobj.card_attack_verb


/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/

obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_throw_range = 20
	card_attack_verb = list("attacked", "sliced", "diced", "slashed", "cut")
	resistance_flags = NONE

/*
|| Custom card decks ||
*/
obj/item/toy/cards/deck/black
	deckstyle = "black"

obj/item/toy/cards/deck/syndicate/black
	deckstyle = "black"

/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] presses a button on [src]</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='notice'>You hear the click of a button.</span>")
		spawn(5) //gia said so
			icon_state = "nuketoy"
			playsound(src, 'sound/machines/alarm.ogg', 100, 0, 0)
			sleep(135)
			icon_state = "nuketoycool"
			sleep(cooldown - world.time)
			icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>")

/obj/item/toy/therapy
	name = "therapy doll"
	desc = "A toy for therapeutic and recreational purposes."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyred"
	item_state = "egg4"
	w_class = WEIGHT_CLASS_TINY
	var/cooldown = 0
	resistance_flags = FLAMMABLE

/obj/item/toy/therapy/New()
	..()
	if(item_color)
		name = "[item_color] therapy doll"
		desc += " This one is [item_color]."
		icon_state = "therapy[item_color]"

/obj/item/toy/therapy/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You relieve some stress with \the [src].</span>")
		playsound(user, 'sound/items/squeaktoy.ogg', 20, 1)
		cooldown = world.time

/obj/random/therapy
	name = "Random Therapy Doll"
	desc = "This is a random therapy doll."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyred"

/obj/random/therapy/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/therapy)) //exclude the base type.

/obj/item/toy/therapy/red
	item_state = "egg4" // It's the red egg in items_left/righthand
	item_color = "red"

/obj/item/toy/therapy/purple
	item_state = "egg1" // It's the magenta egg in items_left/righthand
	item_color = "purple"

/obj/item/toy/therapy/blue
	item_state = "egg2" // It's the blue egg in items_left/righthand
	item_color = "blue"

/obj/item/toy/therapy/yellow
	item_state = "egg5" // It's the yellow egg in items_left/righthand
	item_color = "yellow"

/obj/item/toy/therapy/orange
	item_state = "egg4" // It's the red one again, lacking an orange item_state and making a new one is pointless
	item_color = "orange"

/obj/item/toy/therapy/green
	item_state = "egg3" // It's the green egg in items_left/righthand
	item_color = "green"

/obj/item/toddler
	icon_state = "toddler"
	name = "toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK


//This should really be somewhere else but I don't know where. w/e

/obj/item/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	slot_flags = SLOT_BELT

/*
 * Fake meteor
 */

/obj/item/toy/minimeteor
	name = "Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom)
	..()
	playsound(src, 'sound/effects/meteorimpact.ogg', 40, 1)
	for(var/mob/M in range(10, src))
		if(!M.stat && !istype(M, /mob/living/silicon/ai))\
			shake_camera(M, 3, 1)
	qdel(src)

/*
 * Carp plushie
 */

/obj/item/toy/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	attack_verb = list("bitten", "eaten", "fin slapped")
	var/bitesound = 'sound/weapons/bite.ogg'
	resistance_flags = FLAMMABLE

// Attack mob
/obj/item/toy/carpplushie/attack(mob/M as mob, mob/user as mob)
	playsound(loc, bitesound, 20, 1)	// Play bite sound in local area
	return ..()

// Attack self
/obj/item/toy/carpplushie/attack_self(mob/user as mob)
	playsound(src.loc, bitesound, 20, 1)
	return ..()


/obj/random/carp_plushie
	name = "Random Carp Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"

/obj/random/carp_plushie/item_to_spawn()
	return pick(typesof(/obj/item/toy/carpplushie)) //can pick any carp plushie, even the original.

/obj/item/toy/carpplushie/ice
	icon_state = "icecarp"

/obj/item/toy/carpplushie/silent
	icon_state = "silentcarp"

/obj/item/toy/carpplushie/electric
	icon_state = "electriccarp"

/obj/item/toy/carpplushie/gold
	icon_state = "goldcarp"

/obj/item/toy/carpplushie/toxin
	icon_state = "toxincarp"

/obj/item/toy/carpplushie/dragon
	icon_state = "dragoncarp"

/obj/item/toy/carpplushie/pink
	icon_state = "pinkcarp"

/obj/item/toy/carpplushie/candy
	icon_state = "candycarp"

/obj/item/toy/carpplushie/nebula
	icon_state = "nebulacarp"

/obj/item/toy/carpplushie/void
	icon_state = "voidcarp"

/*
 * Plushie
 */


/obj/item/toy/plushie
	name = "plushie"
	desc = "An adorable, soft, and cuddly plushie."
	icon = 'icons/obj/toy.dmi'
	var/poof_sound = 'sound/weapons/thudswoosh.ogg'
	attack_verb = list("poofed", "bopped", "whapped","cuddled","fluffed")
	resistance_flags = FLAMMABLE

/obj/item/toy/plushie/attack(mob/M as mob, mob/user as mob)
	playsound(loc, poof_sound, 20, 1)	// Play the whoosh sound in local area
	if(iscarbon(M))
		if(prob(10))
			M.reagents.add_reagent("hugs", 10)
	return ..()

/obj/item/toy/plushie/attack_self(mob/user as mob)
	var/cuddle_verb = pick("hugs","cuddles","snugs")
	user.visible_message("<span class='notice'>[user] [cuddle_verb] the [src].</span>")
	playsound(get_turf(src), poof_sound, 50, 1, -1)
	return ..()

/obj/random/plushie
	name = "Random Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "redfox"

/obj/random/plushie/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/plushie) - typesof(/obj/item/toy/plushie/fluff)) //exclude the base type.

/obj/item/toy/plushie/corgi
	name = "corgi plushie"
	icon_state = "corgi"

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"

//foxes are basically the best

/obj/item/toy/plushie/red_fox
	name = "red fox plushie"
	icon_state = "redfox"

/obj/item/toy/plushie/black_fox
	name = "black fox plushie"
	icon_state = "blackfox"

/obj/item/toy/plushie/marble_fox
	name = "marble fox plushie"
	icon_state = "marblefox"

/obj/item/toy/plushie/blue_fox
	name = "blue fox plushie"
	icon_state = "bluefox"

/obj/item/toy/plushie/orange_fox
	name = "orange fox plushie"
	icon_state = "orangefox"

/obj/item/toy/plushie/coffee_fox
	name = "coffee fox plushie"
	icon_state = "coffeefox"

/obj/item/toy/plushie/pink_fox
	name = "pink fox plushie"
	icon_state = "pinkfox"

/obj/item/toy/plushie/purple_fox
	name = "purple fox plushie"
	icon_state = "purplefox"

/obj/item/toy/plushie/crimson_fox
	name = "crimson fox plushie"
	icon_state = "crimsonfox"

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"

/obj/item/toy/plushie/black_cat
	name = "black cat plushie"
	icon_state = "blackcat"

/obj/item/toy/plushie/grey_cat
	name = "grey cat plushie"
	icon_state = "greycat"

/obj/item/toy/plushie/white_cat
	name = "white cat plushie"
	icon_state = "whitecat"

/obj/item/toy/plushie/orange_cat
	name = "orange cat plushie"
	icon_state = "orangecat"

/obj/item/toy/plushie/siamese_cat
	name = "siamese cat plushie"
	icon_state = "siamesecat"

/obj/item/toy/plushie/tabby_cat
	name = "tabby cat plushie"
	icon_state = "tabbycat"

/obj/item/toy/plushie/tuxedo_cat
	name = "tuxedo cat plushie"
	icon_state = "tuxedocat"

/obj/item/toy/plushie/voxplushie
	name = "vox plushie"
	desc = "A stitched-together vox, fresh from the skipjack. Press its belly to hear it skree!"
	icon_state = "plushie_vox"
	item_state = "plushie_vox"
	var/cooldown = 0

/obj/item/toy/plushie/voxplushie/attack_self(mob/user)
	if(!cooldown)
		playsound(user, 'sound/voice/shriek1.ogg', 10, 0)
		visible_message("<span class='danger'>Skreee!</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

//New generation TG plushies

/obj/item/toy/plushie/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "plushie_lizard"
	item_state = "plushie_lizard"

/obj/item/toy/plushie/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "plushie_snake"
	item_state = "plushie_snake"

/obj/item/toy/plushie/nukeplushie
	name = "operative plushie"
	desc = "An stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	item_state = "plushie_nuke"

/obj/item/toy/plushie/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "plushie_slime"
	item_state = "plushie_slime"

/*
 * Foam Armblade
 */

 /obj/item/toy/foamblade
 	name = "foam armblade"
 	desc = "it says \"Sternside Changs #1 fan\" on it. "
 	icon = 'icons/obj/toy.dmi'
 	icon_state = "foamblade"
 	item_state = "arm_blade"
 	attack_verb = list("pricked", "absorbed", "gored")
 	w_class = WEIGHT_CLASS_SMALL
 	resistance_flags = FLAMMABLE

/*
 * Toy/fake flash
 */
/obj/item/toy/flash
	name = "toy flash"
	desc = "FOR THE REVOLU- Oh wait, that's just a toy."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/flash/attack(mob/living/M, mob/user)
	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[initial(icon_state)]2", src)
	user.visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")


/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks?' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message("<span class='warning'>[user] presses the big red button.</span>", "<span class='notice'>You press the button, it plays a loud noise!</span>", "<span class='notice'>The button clicks loudly.</span>")
		playsound(src, 'sound/effects/explosionfar.ogg', 50, 0, 0)
		for(var/mob/M in range(10, src)) // Checks range
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) // Checks to make sure whoever's getting shaken is alive/not the AI
				sleep(8) // Short delay to match up with the explosion sound
				shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

	else
		to_chat(user, "<span class='alert'>Nothing happens.</span>")


/*
 * AI core prizes
 */
/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/AI/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = generate_ion_law()
		to_chat(user, "<span class='notice'>You press the button on [src].</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	icon_state = "demonomicon"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = FALSE

/obj/item/toy/codex_gigas/attack_self(mob/user)
	if(!cooldown)
		user.visible_message(
			"<span class='notice'>[user] presses the button on \the [src].</span>",
			"<span class='notice'>You press the button on \the [src].</span>",
			"<span class='notice'>You hear a soft click.</span>")
		var/list/messages = list()
		var/datum/devilinfo/devil = randomDevilInfo()
		messages += "Some fun facts about: [devil.truename]"
		messages += "[GLOB.lawlorify[LORE][devil.bane]]"
		messages += "[GLOB.lawlorify[LORE][devil.obligation]]"
		messages += "[GLOB.lawlorify[LORE][devil.ban]]"
		messages += "[GLOB.lawlorify[LORE][devil.banish]]"
		playsound(loc, 'sound/machines/click.ogg', 20, 1)
		cooldown = TRUE
		for(var/message in messages)
			user.loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
			sleep(10)
		spawn(20)
			cooldown = FALSE
		return
		..()

/obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		playsound(user, 'sound/creatures/hoot.ogg', 25, 1)
		visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon = 'icons/obj/toy.dmi'
	icon_state = "griffinprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		playsound(user, 'sound/creatures/caw.ogg', 25, 1)
		visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

// DND Character minis. Use the naming convention (type)character for the icon states.
/obj/item/toy/character
	icon = 'icons/obj/toy.dmi'
	w_class = WEIGHT_CLASS_SMALL
	pixel_z = 5

/obj/item/toy/character/alien
	name = "Xenomorph Miniature"
	desc = "A miniature xenomorph. Scary!"
	icon_state = "aliencharacter"
/obj/item/toy/character/cleric
	name = "Cleric Miniature"
	desc = "A wee little cleric, with his wee little staff."
	icon_state = "clericcharacter"
/obj/item/toy/character/warrior
	name = "Warrior Miniature"
	desc = "That sword would make a decent toothpick."
	icon_state = "warriorcharacter"
/obj/item/toy/character/thief
	name = "Thief Miniature"
	desc = "Hey, where did my wallet go!?"
	icon_state = "thiefcharacter"
/obj/item/toy/character/wizard
	name = "Wizard Miniature"
	desc = "MAGIC!"
	icon_state = "wizardcharacter"
/obj/item/toy/character/cthulhu
	name = "Cthulhu Miniature"
	desc = "The dark lord has risen!"
	icon_state = "darkmastercharacter"
/obj/item/toy/character/lich
	name = "Lich Miniature"
	desc = "Murderboner extraordinaire."
	icon_state = "lichcharacter"
/obj/item/storage/box/characters
	name = "Box of Miniatures"
	desc = "The nerd's best friends."
	icon_state = "box"
/obj/item/storage/box/characters/New()
	..()
	new /obj/item/toy/character/alien(src)
	new /obj/item/toy/character/cleric(src)
	new /obj/item/toy/character/warrior(src)
	new /obj/item/toy/character/thief(src)
	new /obj/item/toy/character/wizard(src)
	new /obj/item/toy/character/cthulhu(src)
	new /obj/item/toy/character/lich(src)


//Pet Rocks, just like from the 70's!

/obj/item/toy/pet_rock
	name = "pet rock"
	desc = "The perfect pet!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "pet_rock"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 5
	attack_verb = list("attacked", "bashed", "smashed", "stoned")
	hitsound = "swing_hit"

/obj/item/toy/pet_rock/fred
	name = "fred"
	desc = "Fred, the bestest boy pet in the whole wide universe!"
	icon_state = "fred"

/obj/item/toy/pet_rock/roxie
	name = "roxie"
	desc = "Roxie, the bestest girl pet in the whole wide universe!"
	icon_state = "roxie"

//minigibber, so cute

/obj/item/toy/minigibber
	name = "miniature gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"
	attack_verb = list("grinded", "gibbed")
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/obj/stored_minature = null

/obj/item/toy/minigibber/attack_self(var/mob/user)

	if(stored_minature)
		to_chat(user, "<span class='danger'>\The [src] makes a violent grinding noise as it tears apart the miniature figure inside!</span>")
		QDEL_NULL(stored_minature)
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, 1)
		cooldown = world.time

	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You hit the gib button on \the [src].</span>")
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/minigibber/attackby(var/obj/O, var/mob/user, params)
	if(istype(O,/obj/item/toy/character) && O.loc == user)
		to_chat(user, "<span class='notice'>You start feeding \the [O] [bicon(O)] into \the [src]'s mini-input.</span>")
		if(do_after(user, 10, target = src))
			if(O.loc != user)
				to_chat(user, "<span class='alert'>\The [O] is too far away to feed into \the [src]!</span>")
			else
				to_chat(user, "<span class='notice'>You feed \the [O] [bicon(O)] into \the [src]!</span>")
				user.unEquip(O)
				O.forceMove(src)
				stored_minature = O
		else
			to_chat(user, "<span class='warning'>You stop feeding \the [O] into \the [src]'s mini-input.</span>")
	else ..()

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message("<span class='notice'>[user] pulls back the string on [src].</span>")
		icon_state = "[initial(icon_state)]_used"
		sleep(5)
		audible_message("<span class='danger'>[bicon(src)] Hiss!</span>")
		var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
		playsound(get_turf(src), pick(possible_sounds), 50, 1)
		spawn(45)
			if(src)
				icon_state = "[initial(icon_state)]"
	else
		to_chat(user, "<span class='warning'>The string on [src] hasn't rewound all the way!</span>")
		return

/obj/item/toy/russian_revolver
	name = "russian revolver"
	desc = "for fun and games!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective_gold"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	hitsound = "swing_hit"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	var/bullets_left = 0
	var/max_shots = 6

/obj/item/toy/russian_revolver/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] quickly loads six bullets into [src]'s cylinder and points it at [user.p_their()] head before pulling the trigger! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, 1)
	return BRUTELOSS

/obj/item/toy/russian_revolver/New()
	..()
	spin_cylinder()

/obj/item/toy/russian_revolver/attack_self(mob/user)
	if(!bullets_left)
		user.visible_message("<span class='warning'>[user] loads a bullet into [src]'s cylinder before spinning it.</span>")
		spin_cylinder()
	else
		user.visible_message("<span class='warning'>[user] spins the cylinder on [src]!</span>")
		spin_cylinder()

/obj/item/toy/russian_revolver/attack(mob/M, mob/living/user)
	return

/obj/item/toy/russian_revolver/afterattack(atom/target, mob/user, flag, params)
	if(flag)
		if(target in user.contents)
			return
		if(!ismob(target))
			return
	shoot_gun(user)

/obj/item/toy/russian_revolver/proc/spin_cylinder()
	bullets_left = rand(1, max_shots)

/obj/item/toy/russian_revolver/proc/post_shot(mob/user)
	return

/obj/item/toy/russian_revolver/proc/shoot_gun(mob/living/carbon/human/user)
	if(bullets_left > 1)
		bullets_left--
		user.visible_message("<span class='danger'>*click*</span>")
		playsound(src, 'sound/weapons/empty.ogg', 100, 1)
		return FALSE
	if(bullets_left == 1)
		bullets_left = 0
		var/zone = "head"
		if(!(user.has_organ(zone))) // If they somehow don't have a head.
			zone = "chest"
		playsound(src, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, 1)
		user.visible_message("<span class='danger'>[src] goes off!</span>")
		post_shot(user)
		user.apply_damage(300, BRUTE, zone, sharp = TRUE, used_weapon = "Self-inflicted gunshot wound to the [zone].")
		user.bleed(BLOOD_VOLUME_NORMAL)
		user.death() // Just in case
		return TRUE
	else
		to_chat(user, "<span class='warning'>[src] needs to be reloaded.</span>")
		return FALSE

/obj/item/toy/russian_revolver/trick_revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	max_shots = 1
	var/fake_bullets = 0

/obj/item/toy/russian_revolver/trick_revolver/New()
	..()
	fake_bullets = rand(2, 7)

/obj/item/toy/russian_revolver/trick_revolver/examine(mob/user) //Sneaky sneaky
	. = ..()
	. += "Has [fake_bullets] round\s remaining."
	. += "[fake_bullets] of those are live rounds."

/obj/item/toy/russian_revolver/trick_revolver/post_shot(user)
	to_chat(user, "<span class='danger'>[src] did look pretty dodgey!</span>")
	SEND_SOUND(user, 'sound/misc/sadtrombone.ogg') //HONK
/*
 * Rubber Chainsaw
 */
/obj/item/twohanded/toy/chainsaw
	name = "Toy Chainsaw"
	desc = "A toy chainsaw with a rubber edge. Ages 8 and up"
	icon_state = "chainsaw0"
	force = 0
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	wieldsound = 'sound/weapons/chainsawstart.ogg'
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")

/obj/item/twohanded/toy/chainsaw/update_icon()
	if(wielded)
		icon_state = "chainsaw[wielded]"
	else
		icon_state = "chainsaw0"

/*
 * Cat Toy
  */
/obj/item/toy/cattoy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_mouse"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	var/cooldown = 0

/*
 * Action Figures
 */


/obj/random/figure
	name = "Random Action Figure"
	desc = "This is a random toy action figure"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"

/obj/random/figure/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/figure))


/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"

/obj/item/toy/figure/New()
	..()
	desc = "A \"Space Life\" brand [name]"

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(cooldown < world.time)
		cooldown = (world.time + 30) //3 second cooldown
		user.visible_message("<span class='notice'>[bicon(src)] The [src] says \"[toysay]\".</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	icon_state = "assistant"
	toysay = "Grey tide station wide!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	icon_state = "bartender"
	toysay = "Wheres my monkey?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	icon_state = "botanist"
	toysay = "Dude, I see colors..."

/obj/item/toy/figure/captain
	name = "Captain action figure"
	icon_state = "captain"
	toysay = "Crew, the Nuke Disk is safely up my ass."

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	icon_state = "chaplain"
	toysay = "Gods make me a killing machine please!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	icon_state = "chef"
	toysay = "I swear it's not human meat."

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"

/obj/item/toy/figure/ian
	name = "Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	icon_state = "dsquad"
	toysay = "Eliminate all threats!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	icon_state = "geneticist"
	toysay = "I'm not qualified for this job."

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	icon_state = "hos"
	toysay = "I'm here to win, anything else is secondary."

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	icon_state = "qm"
	toysay = "Hail Cargonia!"

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/lawyer
	name = "Internal Affairs Agent action figure"
	icon_state = "lawyer"
	toysay = "Standard Operating Procedure says they're guilty! Hacking is proof they're an Enemy of the Corporation!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "A \"Space Life\" brand Mime action figure."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	icon_state = "miner"
	toysay = "Oh god it's eating my intestines!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	icon_state = "roboticist"
	toysay = "He asked to be borged!"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	icon_state = "scientist"
	toysay = "Someone else must have made those bombs!"

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the law!"

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	icon_state = "virologist"
	toysay = "The cure is potassium!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	icon_state = "warden"
	toysay = "Execute him for breaking in!"

//////////////////////////////////////////////////////
//				Magic 8-Ball / Conch				//
//////////////////////////////////////////////////////

/obj/item/toy/eight_ball
	name = "Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "eight-ball"
	var/use_action = "shakes the ball"
	var/cooldown = 0
	var/list/possible_answers = list("Definitely", "All signs point to yes.", "Most likely.", "Yes.", "Ask again later.", "Better not tell you now.", "Future Unclear.", "Maybe.", "Doubtful.", "No.", "Don't count on it.", "Never.")

/obj/item/toy/eight_ball/attack_self(mob/user as mob)
	if(!cooldown)
		var/answer = pick(possible_answers)
		user.visible_message("<span class='notice'>[user] focuses on [user.p_their()] question and [use_action]...</span>")
		user.visible_message("<span class='notice'>[bicon(src)] The [src] says \"[answer]\"</span>")
		spawn(30)
			cooldown = 0
		return

/obj/item/toy/eight_ball/conch
	name = "Magic Conch Shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	use_action = "pulls the string"
	possible_answers = list("Yes.", "No.", "Try asking again.", "Nothing.", "I don't think so.", "Neither.", "Maybe someday.")

/*
 *Fake cuffs (honk honk)
 */

/obj/item/restraints/handcuffs/toy
	desc = "Toy handcuffs. Plastic and extremely cheaply made."
	throwforce = 0
	breakouttime = 0
	ignoresClumsy = TRUE
