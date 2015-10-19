/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy Tommy Gun
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
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src

/obj/item/toy/balloon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		user << "\blue You fill the balloon with the contents of [A]."
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		src.update_icon()
	return

/obj/item/toy/balloon/attackby(obj/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				user << "The [O] is empty."
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent("facid", 1))
					user << "The acid chews through the balloon!"
					O.reagents.reaction(user)
					qdel(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					user << "\blue You fill the balloon with the contents of [O]."
					O.reagents.trans_to(src, 10)
	src.update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("\red The [src] bursts!","You hear a pop and a splash.")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		src.icon_state = "burst"
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
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = 4.0

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
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "There are 0 caps left. Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = 3.0
	materials = list(MAT_METAL=10, MAT_GLASS=10)
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

	examine(mob/user)
		if(..(user, 0))
			user << "There are [bullets] caps\s left. Looks almost like the real thing! Ages 8 and up."

	attackby(obj/item/toy/ammo/gun/A as obj, mob/user as mob, params)

		if (istype(A, /obj/item/toy/ammo/gun))
			if (src.bullets >= 7)
				user << "\blue It's already fully loaded!"
				return 1
			if (A.amount_left <= 0)
				user << "\red There is no more caps!"
				return 1
			if (A.amount_left < (7 - src.bullets))
				src.bullets += A.amount_left
				user << text("\red You reload [] caps\s!", A.amount_left)
				A.amount_left = 0
			else
				user << text("\red You reload [] caps\s!", 7 - src.bullets)
				A.amount_left -= 7 - src.bullets
				src.bullets = 7
			A.update_icon()
			return 1
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if (flag)
			return
		if (!user.IsAdvancedToolUser())
			user << "<span class='warning'>You don't have the dexterity to do this!</span>"
			return
		src.add_fingerprint(user)
		if (src.bullets < 1)
			user.show_message("<span class='alert'>*click* *click*</span>", 2)
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
			return
		playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
		src.bullets--
		user.visible_message("<span class='danger'>[user] fires a cap gun at [target]!</span>", null, "You hear a gunshot.")

/obj/item/toy/ammo/gun
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357-7"
	flags = CONDUCT
	w_class = 1.0
	materials = list(MAT_METAL=10, MAT_GLASS=10)
	var/amount_left = 7.0

	update_icon()
		src.icon_state = text("357-[]", src.amount_left)
		src.desc = text("There are [] caps\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
		return

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	w_class = 2.0
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

	examine(mob/user)
		..(user)
		if (bullets)
			user << "\blue It is loaded with [bullets] foam darts!"

	attackby(obj/item/I as obj, mob/user as mob, params)
		if(istype(I, /obj/item/toy/ammo/crossbow))
			if(bullets <= 4)
				user.drop_item()
				qdel(I)
				bullets++
				user << "\blue You load the foam dart into the crossbow."
			else
				usr << "\red It's already fully loaded."


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if(!isturf(target.loc) || target == user) return
		if(flag) return

		if (locate (/obj/structure/table, src.loc))
			return
		else if (bullets)
			var/turf/trg = get_turf(target)
			var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
			bullets--
			D.icon_state = "foamdart"
			D.name = "foam dart"
			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

			for(var/i=0, i<6, i++)
				if (D)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/M in D.loc)
						if(!istype(M,/mob/living)) continue
						if(M == user) continue
						D.visible_message("<span class='danger'>[M] was hit by the foam dart!</span>")
						new /obj/item/toy/ammo/crossbow(M.loc)
						qdel(D)
						return

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density)
							new /obj/item/toy/ammo/crossbow(A.loc)
							qdel(D)

				sleep(1)

			spawn(10)
				if(D)
					new /obj/item/toy/ammo/crossbow(D.loc)
					qdel(D)

			return
		else if (bullets == 0)
			user.Weaken(5)
			user.visible_message("<span class='danger'>[] realized they were out of ammo and starting scrounging for some!</span>")



	attack(mob/M as mob, mob/user as mob)
		src.add_fingerprint(user)

// ******* Check

		if (src.bullets > 0 && M.lying)

			for(var/mob/O in viewers(M, null))
				if(O.client)
					O.show_message(text("<span class='danger'><B>[] casually lines up a shot with []'s head and pulls the trigger!</B></span>", user, M), 1, "<span class='danger'>You hear the sound of foam against skull.</span>", 2)
					O.show_message(text("\red [] was hit in the head by the foam dart!", M), 1)

			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
			new /obj/item/toy/ammo/crossbow(M.loc)
			src.bullets--
		else if (M.lying && src.bullets == 0)
			for(var/mob/O in viewers(M, null))
				if (O.client)  O.show_message(text("<span class='danger'><B>[] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</B></span>", user, M), 1, "<span class='danger'>You hear someone fall.</span>", 2)
			user.Weaken(5)
		return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "Its nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = 1.0

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0


/*
 * Tommy gun
 */

/obj/item/toy/crossbow/tommygun
    name = "tommy gun"
    desc = "Looks almost like the real thing! Great for practicing Drive-bys"
    icon_state = "tommy"
    item_state = "tommy"
    flags = CONDUCT
    w_class = 1.0
    attack_verb = list("struck", "hammered", "hit", "bashed")
    bullets = 20.0

/obj/item/toy/crossbow/tommygun/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/toy/ammo/crossbow))
		if(bullets <= 19)
			user.drop_item()
			qdel(I)
			bullets++
			user << "<span class='notice'>You load the foam dart into the tommy gun.</span>"
		else
			user << "<span class='danger'>It's already fully loaded.</span>"

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = 0.0
	w_class = 2.0
	flags = NOSHIELD
	attack_verb = list("attacked", "struck", "hit")

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			user << "\blue You extend the plastic blade with a quick flick of your wrist."
			playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = 4
		else
			user << "\blue You push the plastic blade back down into the handle."
			playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
			src.icon_state = "sword0"
			src.item_state = "sword0"
			src.w_class = 2

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()
		src.add_fingerprint(user)
		return

// Copied from /obj/item/weapon/melee/energy/sword/attackby
/obj/item/toy/sword/attackby(obj/item/weapon/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/toy/sword))
		if(W == src)
			user << "<span class='notice'>You try to attach the end of the plastic sword to... itself. You're not very smart, are you?</span>"
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else if((W.flags & NODROP) || (flags & NODROP))
			user << "<span class='notice'>\the [flags & NODROP ? src : W] is stuck to your hand, you can't attach it to \the [flags & NODROP ? W : src]!</span>"
		else
			user << "<span class='notice'>You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool.</span>"
			new /obj/item/weapon/twohanded/dualsaber/toy(user.loc)
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/weapon/twohanded/dualsaber/toy
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

/obj/item/weapon/twohanded/dualsaber/toy/IsShield()
	return 0

/obj/item/weapon/twohanded/dualsaber/toy/IsReflect()//Stops Toy Dualsabers from reflecting energy projectiles
	return 0

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/toy/katana/suicide_act(mob/user)
	var/dmsg = pick("[user] tries to stab \the [src] into their abdomen, but it shatters! They look as if they might die from the shame.","[user] tries to stab \the [src] into their abdomen, but \the [src] bends and breaks in half! They look as if they might die from the shame.","[user] tries to slice their own throat, but the plastic blade has no sharpness, causing them to lose their balance, slip over, and break their neck with a loud snap!")
	user.visible_message("<span class='suicide'>[dmsg] It looks like they are trying to commit suicide.</span>")
	return (BRUTELOSS)


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
	w_class = 1


	throw_impact(atom/hit_atom)
		..()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("\red The [src.name] explodes!","\red You hear a bang!")


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
	w_class = 1

	throw_impact(atom/hit_atom)
		..()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		qdel(src)

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == "run")
			M << "\red You step on the snap pop!"

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
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
		user << "<span class='notice'>You play with [src].</span>"
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			user << "<span class='notice'>You play with [src].</span>"
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

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


/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")


/*
|| A Deck of Cards for playing various games of chance ||
*/



obj/item/toy/cards
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
	w_class = 2.0
	var/cooldown = 0
	var/list/cards = list()

obj/item/toy/cards/deck/New()
	..()
	icon_state = "deck_[deckstyle]_full"
	for(var/i = 2; i <= 10; i++)
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
		src.icon_state = "deck_[deckstyle]_empty"
		user << "<span class='notice'>There are no more cards to draw.</span>"
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	src.cards -= choice
	H.pickup(user)
	user.put_in_active_hand(H)
	src.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	if(cards.len > 26)
		src.icon_state = "deck_[deckstyle]_full"
	else if(cards.len > 10)
		src.icon_state = "deck_[deckstyle]_half"
	else if(cards.len > 1)
		src.icon_state = "deck_[deckstyle]_low"

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
				user << "<span class='notice'>The card is stuck to your hand, you can't add it to the deck!</span>"
				return
			src.cards += C.cardname
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_[deckstyle]_full"
		else if(cards.len > 10)
			src.icon_state = "deck_[deckstyle]_half"
		else if(cards.len > 1)
			src.icon_state = "deck_[deckstyle]_low"


obj/item/toy/cards/deck/attackby(obj/item/toy/cards/cardhand/C, mob/living/user, params)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			if(!user.unEquip(C))
				user << "<span class='notice'>The hand of cards is stuck to your hand, you can't add it to the deck!</span>"
				return
			src.cards += C.currenthand
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_[deckstyle]_full"
		else if(cards.len > 10)
			src.icon_state = "deck_[deckstyle]_half"
		else if(cards.len > 1)
			src.icon_state = "deck_[deckstyle]_low"

obj/item/toy/cards/deck/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M  && loc != M)
			M.put_in_hands(src)
			usr << "<span class='notice'>You pick up the deck.</span>"

		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("l_hand")
					if(!remove_item_from_storage(M))
						M.unEquip(src)
					M.put_in_l_hand(src)
				else if("r_hand")
					if(!remove_item_from_storage(M))
						M.unEquip(src)
					M.put_in_r_hand(src)
				usr << "<span class='notice'>You pick up the deck.</span>"
	else
		usr << "<span class='notice'>You can't reach it from here.</span>"



obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	w_class = 1.0
	var/list/currenthand = list()
	var/choice = null


obj/item/toy/cards/cardhand/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/item/toy/cards/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
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
		if (cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/cards/singlecard/C = new/obj/item/toy/cards/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.apply_card_vars(C,O)
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from \his hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)
			if(src.currenthand.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.currenthand.len == 1)
				var/obj/item/toy/cards/singlecard/N = new/obj/item/toy/cards/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				N.apply_card_vars(N,O)
				cardUser.unEquip(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				cardUser << "<span class='notice'>You also take [currenthand[1]] and hold it.</span>"
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

obj/item/toy/cards/cardhand/attackby(obj/item/toy/cards/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.unEquip(C)
			user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "[deckstyle]_hand5"
			else if(currenthand.len > 3)
				src.icon_state = "[deckstyle]_hand4"
			else if(currenthand.len > 2)
				src.icon_state = "[deckstyle]_hand3"
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"

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


obj/item/toy/cards/singlecard
	name = "card"
	desc = "a card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_down"
	w_class = 1.0
	var/cardname = null
	var/flipped = 0
	pixel_x = -5


obj/item/toy/cards/singlecard/examine(mob/user)
	if(..(user, 0))
		if(ishuman(user))
			var/mob/living/carbon/human/cardUser = user
			if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
				cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.</span>", "<span class='notice'>The card reads: [src.cardname]</span>")
			else
				cardUser << "<span class='notice'>You need to have the card in your hand to check it.</span>"


obj/item/toy/cards/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]_[deckstyle]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades_[deckstyle]"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

obj/item/toy/cards/singlecard/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/))
		var/obj/item/toy/cards/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cards/cardhand/H = new/obj/item/toy/cards/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			H.apply_card_vars(H,C)
			user.unEquip(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			user << "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>"
			qdel(C)
			qdel(src)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"

	if(istype(I, /obj/item/toy/cards/cardhand/))
		var/obj/item/toy/cards/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] adds a card to \his hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			if(H.currenthand.len > 4)
				H.icon_state = "[deckstyle]_hand5"
			else if(H.currenthand.len > 3)
				H.icon_state = "[deckstyle]_hand4"
			else if(H.currenthand.len > 2)
				H.icon_state = "[deckstyle]_hand3"
			qdel(src)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"


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
	w_class = 2.0
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] presses a button on [src]</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='notice'>You hear the click of a button.</span>")
		spawn(5) //gia said so
			icon_state = "nuketoy"
			playsound(src, 'sound/machines/Alarm.ogg', 100, 0, 0)
			sleep(135)
			icon_state = "nuketoycool"
			sleep(cooldown - world.time)
			icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		user << "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>"


/obj/item/toy/therapy_red
	name = "red therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is red."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "therapyred"
	item_state = "egg4" // It's the red egg in items_left/righthand
	w_class = 1

/obj/item/toy/therapy_purple
	name = "purple therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is purple."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "therapypurple"
	item_state = "egg1" // It's the magenta egg in items_left/righthand
	w_class = 1

/obj/item/toy/therapy_blue
	name = "blue therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is blue."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "therapyblue"
	item_state = "egg2" // It's the blue egg in items_left/righthand
	w_class = 1

/obj/item/toy/therapy_yellow
	name = "yellow therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is yellow."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "therapyyellow"
	item_state = "egg5" // It's the yellow egg in items_left/righthand
	w_class = 1

/obj/item/toy/therapy_orange
	name = "orange therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is orange."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "therapyorange"
	item_state = "egg4" // It's the red one again, lacking an orange item_state and making a new one is pointless
	w_class = 1

/obj/item/toy/therapy_green
	name = "green therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is green."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "therapygreen"
	item_state = "egg3" // It's the green egg in items_left/righthand
	w_class = 1

/obj/item/weapon/toddler
	icon_state = "toddler"
	name = "toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	force = 5
	w_class = 4.0
	slot_flags = SLOT_BACK


//This should really be somewhere else but I don't know where. w/e

/obj/item/weapon/inflatable_duck
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
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor"
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = 2.0

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

// Attack mob
/obj/item/toy/carpplushie/attack(mob/M as mob, mob/user as mob)
	playsound(loc, bitesound, 20, 1)	// Play bite sound in local area
	return ..()

// Attack self
/obj/item/toy/carpplushie/attack_self(mob/user as mob)
	playsound(src.loc, bitesound, 20, 1)
	return ..()

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
 	w_class = 2

/*
 * Toy/fake flash
 */
/obj/item/toy/flash
	name = "toy flash"
	desc = "FOR THE REVOLU- Oh wait, that's just a toy."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"
	w_class = 1

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
	w_class = 2.0
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message("<span class='warning'>[user] presses the big red button.</span>", "<span class='notice'>You press the button, it plays a loud noise!</span>", "<span class='notice'>The button clicks loudly.</span>")
		playsound(src, 'sound/effects/explosionfar.ogg', 50, 0, 0)
		for(var/mob/M in range(10, src)) // Checks range
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) // Checks to make sure whoever's getting shaken is alive/not the AI
				sleep(8) // Short delay to match up with the explosion sound
				shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

	else
		user << "<span class='alert'>Nothing happens.</span>"


/*
 * AI core prizes
 */
/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	w_class = 2.0
	var/cooldown = 0

/obj/item/toy/AI/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = generate_ion_law()
		user << "<span class='notice'>You press the button on [src].</span>"
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		src.loc.visible_message("<span class='danger'>\icon[src] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = 2.0
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
		user << "<span class='notice'>You pull the string on the [src].</span>"
		playsound(user, 'sound/misc/hoot.ogg', 25, 1)
		src.loc.visible_message("<span class='danger'>\icon[src] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon = 'icons/obj/toy.dmi'
	icon_state = "griffinprize"
	w_class = 2.0
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
		user << "<span class='notice'>You pull the string on the [src].</span>"
		playsound(user, 'sound/misc/caw.ogg', 25, 1)
		src.loc.visible_message("<span class='danger'>\icon[src] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

// DND Character minis. Use the naming convention (type)character for the icon states.
/obj/item/toy/character
	icon = 'icons/obj/toy.dmi'
	w_class = 2
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
/obj/item/weapon/storage/box/characters
	name = "Box of Miniatures"
	desc = "The nerd's best friends."
	icon_state = "box"
/obj/item/weapon/storage/box/characters/New()
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
	w_class = 2
	force = 5
	throwforce = 5
	attack_verb = list("attacked", "bashed", "smashed", "stoned")

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
	desc = "A miniature recreation of NanoTrasen's famous meat grinder."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"
	attack_verb = list("grinded", "gibbed")
	w_class = 2.0
	var/cooldown = 0
	var/obj/stored_minature = null

/obj/item/toy/minigibber/attack_self(var/mob/user)

	if(stored_minature)
		user << "<span class='danger'>\The [src] makes a violent grinding noise as it tears apart the miniature figure inside!</span>"
		qdel(stored_minature)
		stored_minature = null
		playsound(user, 'sound/effects/gib.ogg', 20, 1)
		cooldown = world.time

	if(cooldown < world.time - 8)
		user << "<span class='notice'>You hit the gib button on \the [src].</span>"
		playsound(user, 'sound/effects/gib.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/minigibber/attackby(var/obj/O, var/mob/user, params)
	if(istype(O,/obj/item/toy/character) && O.loc == user)
		user << "<span class='notice'>You start feeding \the [O] \icon[O] into \the [src]'s mini-input.</span>"
		if(do_after(user,10, target = src))
			if(O.loc != user)
				user << "<span class='alert'>\The [O] is too far away to feed into \the [src]!</span>"
			else
				user << "<span class='notice'>You feed \the [O] \icon[O] into \the [src]!</span>"
				user.unEquip(O)
				O.forceMove(src)
				stored_minature = O
		else
			user << "<span class='warning'>You stop feeding \the [O] into \the [src]'s mini-input.</span>"
	else ..()

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = 2
	var/cooldown = 0

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message("<span class='notice'>[user] pulls back the string on [src].</span>")
		icon_state = "[initial(icon_state)]_used"
		sleep(5)
		audible_message("<span class='danger'>\icon[src] Hiss!</span>")
		var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
		playsound(get_turf(src), pick(possible_sounds), 50, 1)
		spawn(45)
			if(src)
				icon_state = "[initial(icon_state)]"
	else
		user << "<span class='warning'>The string on [src] hasn't rewound all the way!</span>"
		return

/obj/item/toy/russian_revolver
	name = "russian revolver"
	desc = "for fun and games!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective_gold"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	var/bullet_position = 1
	var/is_empty = 0

/obj/item/toy/russian_revolver/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] quickly loads six bullets into the [src.name]'s cylinder and points it at \his head before pulling the trigger! It looks like they are trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/Gunshot.ogg', 50, 1)
	return (BRUTELOSS)

/obj/item/toy/russian_revolver/New()
	spin_cylinder()
	..()


/obj/item/toy/russian_revolver/attack_self(mob/user)
	if(is_empty)
		user.visible_message("<span class='warning'>[user] loads a bullet into the [src]'s cylinder.</span>")
		is_empty = 0
	else
		spin_cylinder()
		user.visible_message("<span class='warning'>[user] spins the cylinder on the [src]!</span>")


/obj/item/toy/russian_revolver/attack(mob/living/carbon/M, mob/user)
	if(M != user) //can't use this on other people
		return
	if(is_empty)
		user << "<span class='notice'>The [src] is empty.</span>"
		return
	user.visible_message("<span class='danger'>[user] points the [src] at their head, ready to pull the trigger!</span>")
	if(do_after(user, 30, target = M))
		if(bullet_position != 1)
			user.visible_message("<span class='danger'>*click*</span>")
			playsound(src, 'sound/weapons/empty.ogg', 100, 1)
			bullet_position -= 1
			return
		if(bullet_position == 1)
			is_empty = 1
			playsound(src, 'sound/weapons/Gunshot.ogg', 50, 1)
			user.visible_message("<span class='danger'>The [src] goes off!</span>")
			M.apply_damage(200, "brute", "head", used_weapon = "Self-inflicted gunshot would to the head.", sharp=1)
			M.death()
	else
		user.visible_message("<span class='danger'>[user] lowers the [src] from their head.</span>")


/obj/item/toy/russian_revolver/proc/spin_cylinder()
	bullet_position = rand(1,6)