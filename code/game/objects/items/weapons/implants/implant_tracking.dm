/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = IMPLANT_ACTIVATED_PASSIVE
	origin_tech = "materials=2;magnets=2;programming=2;biotech=2"
	implant_data = /datum/implant_fluff/tracking
	implant_state = "implant-nanotrasen"
	var/warn_cooldown = 0

/obj/item/implant/tracking/Initialize(mapload)
	. = ..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implanter/tracking
	name = "implanter (tracking)"

/obj/item/implanter/tracking/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/tracking(src)

/obj/item/implantcase/tracking
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."

/obj/item/implantcase/tracking/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/tracking(src)
