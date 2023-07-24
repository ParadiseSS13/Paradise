/obj/item/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration_percentage = 100
	attack_verb = list("bludgeoned", "whacked", "disciplined")
	resistance_flags = FLAMMABLE

/obj/item/staff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed)

/obj/item/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"
	item_state = "broom0"

/obj/item/staff/broom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded=5, \
		force_unwielded=3)


/obj/item/staff/broom/attack_self(mob/user as mob)
	. = ..()
	var/wielded = HAS_TRAIT(src, TRAIT_WIELDED)
	item_state = "broom[wielded ? 1 : 0]"
	attack_verb = wielded ? list("rammed into", "charged at") : list("bludgeoned", "whacked", "cleaned")
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()
		if(user.mind in SSticker.mode.wizards)
			user.flying = wielded ? 1 : 0
			if(wielded)
				to_chat(user, "<span class='notice'>You hold \the [src] between your legs.</span>")
				user.say("QUID 'ITCH")
				animate(user, pixel_y = pixel_y + 10 , time = 10, loop = 1, easing = SINE_EASING)
			else
				animate(user, pixel_y = pixel_y + 10 , time = 1, loop = 1)
				animate(user, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
				animate(user)
		else
			if(wielded)
				to_chat(user, "<span class='notice'>You hold \the [src] between your legs.</span>")

/obj/item/staff/broom/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/clothing/mask/horsehead))
		new/obj/item/staff/broom/horsebroom(get_turf(src))
		user.unEquip(O)
		qdel(O)
		qdel(src)
		return
	..()

/obj/item/staff/broom/dropped(mob/user)
	if((user.mind in SSticker.mode.wizards) && user.flying)
		user.flying = FALSE
	..()

/obj/item/staff/broom/horsebroom
	name = "broomstick horse"
	desc = "Saddle up!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "horsebroom"
	item_state = "horsebroom0"

/obj/item/staff/broom/horsebroom/attack_self(mob/user as mob)
	..()
	item_state = "horsebroom[HAS_TRAIT(src, TRAIT_WIELDED) ? 1 : 0]"

/obj/item/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
