#define RCS_MODE_CALIBRATED 0
#define RCS_MODE_UNCALIBRATED 1

/obj/item/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "A device used to teleport crates and closets to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	item_state = "rcd"
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	toolspeed = 1
	usesound = 'sound/machines/click.ogg'
	var/obj/item/stock_parts/cell/high/rcell = null
	var/obj/machinery/pad = null
	var/mode = RCS_MODE_CALIBRATED
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = FALSE
	var/teleporting = FALSE
	var/chargecost = 1000

/obj/item/rcs/get_cell()
	return rcell

/obj/item/rcs/New()
	..()
	rcell = new(src)

/obj/item/rcs/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are [round(rcell.charge/chargecost)] charge\s left.</span>"

/obj/item/rcs/Destroy()
	QDEL_NULL(rcell)
	return ..()

/obj/item/rcs/attack_self(mob/user)
	if(!emagged)
		return
	if(mode == RCS_MODE_CALIBRATED)
		mode = RCS_MODE_UNCALIBRATED
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		to_chat(user, "<span class='caution'>The telepad locator has become uncalibrated.</span>")
	else
		mode = RCS_MODE_CALIBRATED
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
		to_chat(user, "<span class='caution'>You calibrate the telepad locator.</span>")

/obj/item/rcs/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		do_sparks(5, 1, src)
		to_chat(user, "<span class='caution'>You emag the RCS. Activate it to toggle between modes.</span>")
		return

/obj/item/rcs/proc/try_send_container(mob/user, obj/structure/closet/C)
	if(teleporting)
		to_chat(user, "<span class='warning'>You're already using [src]!</span>")
		return
	if(user in C.contents) //to prevent self-teleporting.
		return
	if(!rcell || (rcell.charge < chargecost))
		to_chat(user, "<span class='warning'>Out of charges.</span>")
		return

	if(!is_level_reachable(C.z))
		to_chat(user, "<span class='warning'>The rapid-crate-sender can't locate any telepads!</span>")
		return

	if(mode == RCS_MODE_CALIBRATED)
		var/list/L = list()
		var/list/areaindex = list()
		for(var/obj/machinery/telepad_cargo/R in GLOB.machines)
			if(R.stage)
				continue
			var/turf/T = get_turf(R)
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R

		var/desc = input("Please select a telepad.", "RCS") in L
		pad = L[desc]
		try_teleport(user, C, pad)
	else
		rand_x = rand(50,200)
		rand_y = rand(50,200)
		var/L = locate(rand_x, rand_y, 6)
		try_teleport(user, C, L)

/obj/item/rcs/proc/try_teleport(mob/user, obj/structure/closet/C, target)
	if(!C.Adjacent(user))
		to_chat(user, "<span class='notice'>Unable to teleport, too far from [C].</span>")
		return
	var/turf/ownTurf = get_turf(src)
	playsound(ownTurf, usesound, 50, 1)
	to_chat(user, "<span class='notice'>Teleporting [C]...</span>")
	teleporting = TRUE
	if(!do_after(user, 50 * toolspeed, target = C))
		teleporting = FALSE
		return
	teleporting = FALSE
	if(user in C.contents)
		to_chat(user, "<span class='warning'>Error: User located in container--aborting for safety.</span>")
		playsound(ownTurf, 'sound/machines/buzz-sigh.ogg', 50, 1)
		return
	if(!(rcell && rcell.use(chargecost)))
		to_chat(user, "<span class='notice'>Unable to teleport, insufficient charge.</span>")
		return
	do_sparks(5, 1, C)
	do_teleport(C, target)
	to_chat(user, "<span class='notice'>Teleport successful. [round(rcell.charge/chargecost)] charge\s left.</span>")

#undef RCS_MODE_CALIBRATED
#undef RCS_MODE_UNCALIBRATED
