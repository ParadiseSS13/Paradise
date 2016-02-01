
/obj/item/toy/prizeball
	name = "prize ball"
	desc = "A toy is a toy, but a prize ball could be anything! It could even be a toy!"
	icon = 'icons/obj/arcade.dmi'
	icon_state = "prizeball_1"
	var/opening = 0

/obj/item/toy/prizeball/New()
	..()
	icon_state = pick("prizeball_1","prizeball_2","prizeball_3")

/obj/item/toy/prizeball/attack_self(mob/user as mob)
	if(opening)
		return
	opening = 1
	playsound(src.loc, 'sound/items/bubblewrap.ogg', 30, 1, extrarange = -4, falloff = 10)
	icon_state = "prizeconfetti"
	src.color = pick(random_color_list)
	var/prize_inside = pick(/obj/random/carp_plushie, /obj/random/plushie, /obj/random/figure, /obj/item/toy/eight_ball)	//will add ticket bundles later
	spawn(10)
		user.unEquip(src)
		new prize_inside(user.loc)
		qdel(src)