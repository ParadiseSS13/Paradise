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
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)

	flick("[icon_state]2", src)
	playsound(src.loc, pick(src.hit_sounds), 50, 1)

/obj/structure/punching_bag/attackby(obj/item/I as obj, mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)

	if(istype(I, /obj/item/weapon))
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