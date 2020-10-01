/**
  * # Rapid Crate Sender (RCS)
  *
  * Used to teleport crates and closets to cargo telepads.
  *
  * If emagged, it allows you to teleport crates to a random location, and also teleport yourself while inside a locker.
  */
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
	/// Power cell (10000W)
	var/obj/item/stock_parts/cell/high/rcell = null
	/// Selected telepad
	var/obj/machinery/pad = null

	/// Currently teleporting something?
	var/teleporting = FALSE
	/// How much power does each teleport use?
	var/chargecost = 1000

	// Random coordinates for if emagged
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = FALSE

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

/**
  * Used to select telepad location.
  */
/obj/item/rcs/attack_self(mob/user)
	if(teleporting)
		to_chat(user, "<span class='warning'>Error: Unable to change destination while in use.</span>")
		return

	var/list/L = list() // List of avaliable telepads
	var/list/areaindex = list() // Telepad area location
	for(var/obj/machinery/telepad_cargo/R in GLOB.machines)
		if(R.stage)
			continue
		var/turf/T = get_turf(R)
		var/locname = T.loc.name // The name of the turf area. (e.g. Cargo Bay, Experimentation Lab)

		if(areaindex[locname]) // If there's another telepad with the same area, increment the value so as to not override (e.g. Cargo Bay 2)
			locname = "[locname] ([++areaindex[locname]])"
		else // Else, 1
			areaindex[locname] = 1
		L[locname] = R

	if(emagged) // Add an 'Unknown' entry at the end if it's emagged
		L += "**Unknown**"

	var/select = input("Please select a telepad.", "RCS") in L
	if(select == "**Unknown**") // Randomise the teleport location
		rand_x = rand(50, 200)
		rand_y = rand(50, 200)
		pad = locate(rand_x, rand_y, 6)
	else // Else choose the value of the selection
		pad = L[select]
	playsound(src, 'sound/effects/pop.ogg', 25, TRUE) // And play a sound either way.


/obj/item/rcs/emag_act(user)
	if(!emagged)
		emagged = TRUE
		do_sparks(3, TRUE, src)
		to_chat(user, "<span class='boldwarning'>Warning: Safeties disabled.</span>")
		return


/obj/item/rcs/proc/try_send_container(mob/user, obj/structure/closet/C)
	if(teleporting)
		to_chat(user, "<span class='warning'>You're already using [src]!</span>")
		return
	if((user in C.contents) && (!emagged)) // If it's emagged, skip this check.
		to_chat(user, "<span class='warning'>Error: User located in container--aborting for safety.</span>")
		return
	if(!rcell || rcell.charge < chargecost)
		to_chat(user, "<span class='warning'>Unable to teleport, insufficient charge.</span>")
		return
	if(!pad)
		to_chat(user, "<span class='warning'>Error: No telepad selected.</span>")
		return
	if(!is_level_reachable(C.z))
		to_chat(user, "<span class='warning'>Warning: No telepads in range!</span>")
		return

	teleport(user, C, pad)


/obj/item/rcs/proc/teleport(mob/user, obj/structure/closet/C, target)
	to_chat(user, "<span class='notice'>Teleporting [C]...</span>")
	playsound(src, usesound, 50, TRUE)
	teleporting = TRUE
	if(!do_after(user, 50 * toolspeed, target = C))
		teleporting = FALSE
		return

	teleporting = FALSE
	rcell.use(chargecost)
	do_sparks(5, TRUE, C)
	do_teleport(C, target)
	to_chat(user, "<span class='notice'>Teleport successful. [round(rcell.charge/chargecost)] charge\s left.</span>")
