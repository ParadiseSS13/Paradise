/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "Use this to send crates and closets to cargo telepads."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcs"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	var/rcharges = 10
	var/obj/machinery/pad = null
	var/last_charge = 30
	var/mode = 0
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = 0
	var/teleporting = 0

/obj/item/weapon/rcs/New()
	processing_objects.Add(src)
	desc = "Use this to send crates and closets to cargo telepads. There are [rcharges] charges left."

/obj/item/weapon/rcs/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/rcs/process()
	if(rcharges > 10)
		rcharges = 10
	if(last_charge == 0)
		rcharges++
		desc = "Use this to send crates and closets to cargo telepads. There are [rcharges] charges left."
		last_charge = 30
	else
		last_charge--

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		if(mode == 0)
			mode = 1
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
			user << "\red The telepad locator has become uncalibrated."
		else
			mode = 0
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
			user << "\blue You calibrate the telepad locator."

/obj/item/weapon/rcs/attackby(obj/item/W, mob/user)
	if(istype(W,  /obj/item/weapon/card/emag) && emagged == 0)
		emagged = 1
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		user << "\red You emag the RCS. Click on it to toggle between modes."
		return