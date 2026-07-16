/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/gift
	name = "gift"
	desc = "A wrapped item."
	icon_state = "gift3"
	inhand_icon_state = "gift"
	w_class = WEIGHT_CLASS_BULKY
	var/size = 3.0
	var/obj/item/gift_inside = null
	new_attack_chain = TRUE

/obj/item/gift/emp_act(severity)
	..()
	gift_inside.emp_act(severity)

/obj/item/gift/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	user.unequip(src, force = TRUE)
	if(gift_inside)
		user.put_in_active_hand(gift_inside)
		gift_inside.add_fingerprint(user)
	else
		to_chat(user, SPAN_WARNING("The gift was empty!"))
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon_state = "gift1"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE
	scatter_distance = 10
	new_attack_chain = TRUE

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	scatter_atom()
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"

/obj/item/a_gift/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	var/gift_type = pick(
		/obj/effect/spawner/random/toy/carp_plushie,
		/obj/effect/spawner/random/plushies,
		/obj/effect/spawner/random/toy/action_figure,
		/obj/effect/spawner/random/toy/mech_figure,
		/obj/item/sord,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/silver,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/bikehorn,
		/obj/item/beach_ball,
		/obj/item/beach_ball/holoball,
		/obj/item/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/gun/projectile/shotgun/toy/crossbow,
		/obj/item/gun/projectile/revolver/capgun,
		/obj/item/toy/katana,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/paicard,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		/obj/item/deck/cards,
		/obj/item/deck/cards/tiny,
		/obj/item/deck/unum,
		/obj/item/toy/minimeteor,
		/obj/item/toy/redbutton,
		/obj/item/toy/figure/owl,
		/obj/item/toy/figure/griffin,
		/obj/item/clothing/head/blob,
		/obj/item/id_decal/gold,
		/obj/item/id_decal/silver,
		/obj/item/id_decal/prisoner,
		/obj/item/id_decal/centcom,
		/obj/item/id_decal/emag,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/toy/foamblade,
		/obj/item/toy/flash,
		/obj/item/toy/minigibber,
		/obj/item/toy/nuke,
		/obj/item/toy/ai,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/under/syndicate/greyman,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/gun/projectile/shotgun/toy/tommygun,
		/obj/item/stack/tile/fakespace/loaded,
		)

	if(!ispath(gift_type,/obj/item))
		return ITEM_INTERACT_COMPLETE

	var/obj/item/new_gift = new gift_type(user)
	user.unequip(src, force = TRUE)
	user.put_in_hands(new_gift)
	new_gift.add_fingerprint(user)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/*
 * Wrapping Paper
 */
/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "wrap_paper"
	singular_name = "wrapping paper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE

/obj/item/stack/wrapping_paper/activate_self(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("You need to use it on a package that has already been wrapped!"))
	return ITEM_INTERACT_COMPLETE

// The effect when you wrap a dead body in gift wrap.
/obj/effect/spresent
	name = "strange present"
	desc = "It's a ... present?"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = TRUE
	anchored = FALSE

/obj/effect/spresent/relaymove(mob/user)
	if(user.stat)
		return
	to_chat(user, SPAN_NOTICE("You can't move."))

/obj/effect/spresent/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/wirecutters))
		to_chat(user, SPAN_WARNING("You need wirecutters for that!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You cut open the present."))
	for(var/mob/M in src) // Should only be one but whatever.
		M.forceMove(loc)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

