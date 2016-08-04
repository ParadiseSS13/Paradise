/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/weapon/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"
	burn_state = FLAMMABLE

/obj/item/weapon/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/weapon/gift/attack_self(mob/user as mob)
	user.drop_item()
	if(src.gift)
		user.put_in_active_hand(gift)
		src.gift.add_fingerprint(user)
	else
		to_chat(user, "\blue The gift was empty!")
	qdel(src)
	return

/obj/item/weapon/a_gift/ex_act()
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user as mob)
	if(user.stat)
		return
	to_chat(user, "\blue You cant move.")

/obj/effect/spresent/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()

	if(!istype(W, /obj/item/weapon/wirecutters))
		to_chat(user, "\blue I need wirecutters for that.")
		return

	to_chat(user, "\blue You cut open the present.")

	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	qdel(src)

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(/obj/item/weapon/sord,
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/photo_album,
		/obj/item/weapon/storage/box/snappops,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/weapon/storage/belt/champion,
		/obj/item/weapon/soap/deluxe,
		/obj/item/weapon/pickaxe/silver,
		/obj/item/weapon/pen/invisible,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/corncob,
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/bikehorn,
		/obj/item/weapon/beach_ball,
		/obj/item/weapon/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/weapon/gun/projectile/shotgun/toy/crossbow,
		/obj/item/weapon/gun/projectile/revolver/capgun,
		/obj/item/toy/katana,
		/obj/random/mech,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/device/paicard,
		/obj/item/device/violin,
		/obj/item/device/guitar,
		/obj/item/weapon/storage/belt/utility/full,
		/obj/item/clothing/accessory/horrible,
		/obj/random/carp_plushie,
		/obj/random/plushie,
		/obj/random/figure,
		/obj/item/toy/minimeteor,
		/obj/item/toy/redbutton,
		/obj/item/toy/owl,
		/obj/item/toy/griffin,
		/obj/item/clothing/head/blob,
		/obj/item/weapon/id_decal/gold,
		/obj/item/weapon/id_decal/silver,
		/obj/item/weapon/id_decal/prisoner,
		/obj/item/weapon/id_decal/centcom,
		/obj/item/weapon/id_decal/emag,
		/obj/item/weapon/spellbook/oneuse/fake_gib,
		/obj/item/toy/foamblade,
		/obj/item/toy/flash,
		/obj/item/toy/minigibber,
		/obj/item/toy/nuke,
		/obj/item/toy/cards/deck,
		/obj/item/toy/AI,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/weapon/storage/box/fakesyndiesuit,
		/obj/item/weapon/gun/projectile/shotgun/toy/tommygun,
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
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	burn_state = FLAMMABLE

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You need to use it on a package that has already been wrapped!</span>")
