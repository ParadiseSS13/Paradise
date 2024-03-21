/obj/item/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/staves_righthand.dmi'
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
	AddComponent(/datum/component/two_handed, force_wielded = 5, force_unwielded = 3, wield_callback = CALLBACK(src, PROC_REF(wield)), unwield_callback = CALLBACK(src, PROC_REF(unwield)))

/obj/item/staff/broom/proc/wield(obj/item/source, mob/user)
	attack_verb = list("rammed into", "charged at")
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	if(iswizard(user))
		user.flying = TRUE
		user.say("QUID 'ITCH")
		animate(user, pixel_y = pixel_y + 10 , time = 10, loop = 1, easing = SINE_EASING)
	to_chat(user, "<span class='notice'>You hold [src] between your legs.</span>")

/obj/item/staff/broom/proc/unwield(obj/item/source, mob/user)
	attack_verb = list("bludgeoned", "whacked", "cleaned")
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	if(iswizard(user))
		animate(user, pixel_y = pixel_y + 10 , time = 1, loop = 1)
		animate(user, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
		animate(user)

/obj/item/staff/broom/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/clothing/mask/horsehead))
		new/obj/item/staff/broom/horsebroom(get_turf(src))
		user.unEquip(O)
		qdel(O)
		qdel(src)
		return
	..()

/obj/item/staff/broom/dropped(mob/user)
	if(iswizard(user) && user.flying)
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
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
