//Helper object for picking dionaea (and other creatures) up.
/obj/item/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_NECK

/obj/item/holder/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/holder/process()

	if(isturf(loc) || !(length(contents)))

		for(var/mob/M in contents)

			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))

		qdel(src)

/obj/item/holder/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	for(var/mob/M in src.contents)
		M.attack_by(W, user, params)

/obj/item/holder/proc/show_message(message, m_type, chat_message_type)
	for(var/mob/living/M in contents)
		M.show_message(message, m_type, chat_message_type)

/obj/item/holder/emp_act(intensity)
	for(var/mob/living/M in contents)
		M.emp_act(intensity)

/obj/item/holder/ex_act(intensity)
	for(var/mob/living/M in contents)
		M.ex_act(intensity)

/obj/item/holder/examine(mob/user)
	for(var/mob/living/M in contents)
		. += M.examine(user)

/obj/item/holder/container_resist(mob/living/L)
	var/mob/M = src.loc                      //Get our mob holder (if any).

	if(istype(M))
		M.drop_item_to_ground(src)
		to_chat(M, "[src] wriggles out of your grip!")
		to_chat(L, "You wriggle out of [M]'s grip!")
	else if(isitem(loc))
		to_chat(L, "You struggle free of [loc].")
		forceMove(get_turf(src))

	if(istype(M))
		for(var/atom/A in M.contents)
			if(istype(A, /obj/item/holder))
				return
		M.status_flags &= ~PASSEMOTES

	return

/mob/living/proc/get_scooped(mob/living/carbon/grabber, has_variant = FALSE)
	if(!holder_type)
		return

	var/obj/item/holder/H = new holder_type(loc)
	forceMove(H)
	H.name = name
	if(has_variant)
		H.icon_state = icon_state
	if(desc)
		H.desc = desc
	H.attack_hand(grabber)

	to_chat(grabber, "<span class='notice'>You scoop up \the [src].")
	to_chat(src, "<span class='notice'>\The [grabber] scoops you up.</span>")
	grabber.status_flags |= PASSEMOTES
	return H

//Mob specific holders.

/obj/item/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"

/obj/item/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"

/obj/item/holder/nian_caterpillar
	name = "nian caterpillar"
	desc = "It's a tiny little itty bitty critter."
	icon_state = "mothroach"
	slot_flags = ITEM_SLOT_HEAD

/obj/item/holder/drone/emagged
	icon_state = "drone-emagged"

/obj/item/holder/pai
	name = "pAI"
	desc = "It's a little robot."
	icon_state = null

/obj/item/holder/mouse
	name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/holder/bunny
	name = "bunny"
	desc = "Awww a cute bunny."
	icon = 'icons/mob/animal.dmi'
	icon_state = "m_bunny"

/obj/item/holder/chicken
	name = "chicken"
	desc = "Hopefully the eggs are good this season."
	icon = 'icons/mob/animal.dmi'
	icon_state = "chicken_brown"

/obj/item/holder/chick
	name = "chick"
	desc = "You're one of this chick's favorite peeps."
	icon = 'icons/mob/animal.dmi'
	icon_state = "chick"
