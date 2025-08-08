/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon_state = "gift1"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE
	scatter_distance = 10

/obj/item/a_gift/New()
	..()
	scatter_atom()
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/gift/attack_self__legacy__attackchain(mob/user as mob)
	user.drop_item()
	if(src.gift)
		user.put_in_active_hand(gift)
		src.gift.add_fingerprint(user)
	else
		to_chat(user, "<span class='notice'>The gift was empty!</span>")
	qdel(src)

/obj/effect/spresent/relaymove(mob/user as mob)
	if(user.stat)
		return
	to_chat(user, "<span class='notice'>You can't move.</span>")

/obj/effect/spresent/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>I need wirecutters for that.</span>")
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='notice'>You cut open the present.</span>")
	for(var/mob/M in src) //Should only be one but whatever.
		M.forceMove(loc)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/a_gift/attack_self__legacy__attackchain(mob/M as mob)
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

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.unequip(src, force = TRUE)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

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

/obj/item/stack/wrapping_paper/attack_self__legacy__attackchain(mob/user)
	to_chat(user, "<span class='notice'>You need to use it on a package that has already been wrapped!</span>")
