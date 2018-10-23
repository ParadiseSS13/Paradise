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
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"
	burn_state = FLAMMABLE

/obj/item/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/gift/attack_self(mob/user as mob)
	user.drop_item()
	if(src.gift)
		user.put_in_active_hand(gift)
		src.gift.add_fingerprint(user)
	else
		to_chat(user, "<span class='notice'>The gift was empty!</span>")
	qdel(src)
	return

/obj/item/a_gift/ex_act()
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user as mob)
	if(user.stat)
		return
	to_chat(user, "<span class='notice'>You cant move.</span>")

/obj/effect/spresent/attackby(obj/item/W as obj, mob/user as mob, params)
	..()

	if(!istype(W, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>I need wirecutters for that.</span>")
		return

	to_chat(user, "<span class='notice'>You cut open the present.</span>")

	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		M.reset_perspective(null)

	qdel(src)

/obj/item/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(/obj/item/sord,
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
		/obj/random/mech,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/paicard,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/accessory/horrible,
		/obj/random/carp_plushie,
		/obj/random/plushie,
		/obj/random/figure,
		/obj/item/toy/minimeteor,
		/obj/item/toy/redbutton,
		/obj/item/toy/owl,
		/obj/item/toy/griffin,
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
		/obj/item/toy/cards/deck,
		/obj/item/toy/AI,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/gun/projectile/shotgun/toy/tommygun,
		/obj/item/stack/tile/fakespace/loaded,
		)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.unEquip(src, 1)
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
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"
	singular_name = "wrapping paper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	burn_state = FLAMMABLE

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You need to use it on a package that has already been wrapped!</span>")
