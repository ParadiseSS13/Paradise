/*Contains:
* Prize balls
* Prize tickets
*/
/obj/item/toy/prizeball
	name = "prize ball"
	desc = "A toy is a toy, but a prize ball could be anything! It could even be a toy!"
	icon = 'icons/obj/arcade.dmi'
	icon_state = "prizeball_1"
	var/opening = 0
	var/possible_contents = list(/obj/random/carp_plushie, /obj/random/plushie, /obj/random/figure, /obj/item/toy/eight_ball, /obj/item/stack/tickets)

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
	var/prize_inside = pick(possible_contents)
	spawn(10)
		user.unEquip(src)
		if(ispath(prize_inside,/obj/item/stack))
			var/amount = pick(5, 10, 15, 25, 50)
			new prize_inside(user.loc, amount)
		else
			new prize_inside(user.loc)
		qdel(src)

/obj/item/toy/prizeball/mech
	name = "mecha figure capsule"
	desc = "Contains one collectible mecha figure!"
	possible_contents = list(/obj/random/mech)

/obj/item/toy/prizeball/carp_plushie
	name = "carp plushie capsule"
	desc = "Contains one space carp plushie!"
	possible_contents = list(/obj/random/carp_plushie)

/obj/item/toy/prizeball/plushie
	name = "plushie capsule"
	desc = "Contains one cuddly plushie!"
	possible_contents = list(/obj/random/plushie)

/obj/item/toy/prizeball/figure
	name = "action figure capsule"
	desc = "Contains one action figure!"
	possible_contents = list(/obj/random/figure)

/obj/item/toy/prizeball/therapy
	name = "therapy doll capsule"
	desc = "Contains one squishy therapy doll."
	possible_contents = list(/obj/random/therapy)

/obj/item/stack/tickets
	name = "prize ticket"
	desc = "Prize tickets from the arcade. Exchange them for fabulous prizes!"
	singular_name = "prize ticket"
	icon = 'icons/obj/arcade.dmi'
	icon_state = "tickets_1"
	force = 0
	throwforce = 0
	throw_speed = 1
	throw_range = 1
	w_class = WEIGHT_CLASS_TINY
	max_amount = 9999	//Dang that's a lot of tickets

/obj/item/stack/tickets/New(var/loc, var/amount=null)
	..()
	update_icon()

/obj/item/stack/tickets/attack_self(mob/user as mob)
	return

/obj/item/stack/tickets/update_icon()
	switch(get_amount())
		if(1 to 3)
			icon_state = "tickets_1"	// One ticket
		if(4 to 24)
			icon_state = "tickets_2"	// Couple tickets
		if(25 to 74)
			icon_state = "tickets_3"	// Buncha tickets
		else
			icon_state = "tickets_4"	// Ticket snake