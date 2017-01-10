/obj/structure/punching_bag
	name = "punching bag"
	desc = "A hanging bag filled with tightly packed foam, perfect for training your strength on."
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "punchingbag"
	anchored = 1
	layer = 5 // Same layer as potted plants. Hide behind punching bags!
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

/obj/structure/punching_bag/attack_hand(mob/user as mob)
	if(anchored)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)

		flick("[icon_state]2", src)
		playsound(src.loc, pick(src.hit_sounds), 50, 1)

/obj/structure/punching_bag/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user,20, target = src))
				anchored = 1
				icon_state = "punchingbag"
				user.visible_message( \
					"[user] bolts \the [src] to the ceiling.", \
					"<span class='notice'> You bolt \the [src]'s to the ceiling.</span>", \
					"You hear ratchet.")
				return

		else if(anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user,20, target = src))
				anchored = 0
				icon_state = "punchingbag3"
				user.visible_message( \
					"[user] unbolts \the [src] from the ceiling.", \
					"<span class='notice'> You unbolt \the [src]'s from the ceiling.</span>", \
					"You hear ratchet.")
				return

	if(istype(I, /obj/item/weapon) && anchored)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)

		flick("[icon_state]2", src)

		if(I.hitsound)
			playsound(src.loc, I.hitsound, 50, 1)
		else
			playsound(src.loc, pick(src.hit_sounds), 50, 1)

/obj/structure/punching_bag/red
	color = "#ff4444"

/obj/structure/punching_bag/green
	color = "#55ff55"

/obj/structure/punching_bag/blue
	color = "#7777ff"

/obj/structure/punching_bag/yellow
	color = "#ffff33"

/obj/structure/punching_bag/purple
	color = "#9975b9"

/obj/structure/punching_bag/brown
	color = "#cdba96"

/obj/structure/punching_bag/black
	color = "#777777"