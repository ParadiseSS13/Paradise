//Helper object for picking dionaea (and other creatures) up.
/obj/item/weapon/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_HEAD

/obj/item/weapon/holder/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/holder/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/holder/process()

	if(istype(loc,/turf) || !(contents.len))

		for(var/mob/M in contents)

			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))
			M.reset_view()

		qdel(src)

/obj/item/weapon/holder/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	for(var/mob/M in src.contents)
		M.attackby(W,user, params)

/obj/item/weapon/holder/proc/show_message(var/message, var/m_type)
	for(var/mob/living/M in contents)
		M.show_message(message,m_type)

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(var/mob/living/carbon/grabber)
	if(!holder_type)	return

	var/obj/item/weapon/holder/H = new holder_type(loc)
	src.forceMove(H)
	H.name = name
	if(desc)	H.desc = desc
	H.attack_hand(grabber)

	grabber << "<span class='notice'>You scoop up \the [src]."
	src << "<span class='notice'>\The [grabber] scoops you up.</span>"
	grabber.status_flags |= PASSEMOTES
	return H

//Mob specific holders.

/obj/item/weapon/holder/diona

	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"
	origin_tech = "magnets=3;biotech=5"

/obj/item/weapon/holder/drone

	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	origin_tech = "magnets=3;engineering=5"

/obj/item/weapon/holder/pai
	name = "pAI"
	desc = "It's a little robot."
	icon_state = "pai"
