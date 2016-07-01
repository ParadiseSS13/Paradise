var/const/SAFETY_COOLDOWN = 100

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine which is used to recycle small items ineffeciently; there are lights on the side of it."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/grinding = 0
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_dir = WEST
	var/amount_produced = 1
	var/datum/material_container/materials

/obj/machinery/recycler/New()
	// On us
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	materials = new /datum/material_container(src, list(MAT_METAL=1, MAT_GLASS=1, MAT_SILVER=1, MAT_GOLD=1, MAT_DIAMOND=1, MAT_PLASMA=1, MAT_URANIUM=1, MAT_BANANIUM=1, MAT_TRANQUILLITE=1))
	RefreshParts()
	update_icon()

/obj/machinery/recycler/Destroy()
	qdel(materials)
	materials = null
	return ..()

/obj/machinery/recycler/RefreshParts()
	var/amt_made = 0
	var/mat_mod = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		mat_mod = 2 * B.rating
	mat_mod *= 50000
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		amt_made = 25 * M.rating //% of materials salvaged
	materials.max_amount = mat_mod
	amount_produced = min(100, amt_made)

/obj/machinery/recycler/examine(mob/user)
	..(user)
	to_chat(user, "The power light is [(stat & NOPOWER) ? "off" : "on"].")
	to_chat(user, "The safety-mode light is [safety_mode ? "on" : "off"].")
	to_chat(user, "The safety-sensors status light is [emagged ? "off" : "on"].")

/obj/machinery/recycler/power_change()
	..()
	update_icon()


/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		if(!panel_open)
			update_icon()
		return

	if(exchange_parts(user, I))
		return

	if(default_unfasten_wrench(user, I))
		return

	default_deconstruction_crowbar(I)
	..()
	add_fingerprint(user)
	return

/obj/machinery/recycler/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(safety_mode)
			safety_mode = 0
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)
		to_chat(user, "<span class='notice'>You use the cryptographic sequencer on the [src.name].</span>")

/obj/machinery/recycler/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

// This is purely for admin possession !FUN!.
/obj/machinery/recycler/Bump(var/atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)


/obj/machinery/recycler/Bumped(var/atom/movable/AM)

	if(stat & (BROKEN|NOPOWER))
		return
	if(safety_mode)
		return
	if(!anchored)
		return
	// If we're not already grinding something.
	if(!grinding)
		grinding = 1
		spawn(1)
			grinding = 0
	else
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(isliving(AM))
			if(emagged)
				eat(AM)
			else
				stop(AM)
		else if(istype(AM, /obj/item))
			recycle(AM)
		else // Can't recycle
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc

/obj/machinery/recycler/proc/recycle(obj/item/I, sound = 1)
	I.loc = src.loc
	if(!istype(I))
		return

	if(sound)
		playsound(src.loc, 'sound/machines/recycler.ogg', 100, 0)
	var/material_amount = materials.get_item_material_amount(I)
	if(!material_amount)
		qdel(I)
		return
	materials.insert_item(I, multiplier = (amount_produced / 100))
	qdel(I)
	materials.retrieve_all()


/obj/machinery/recycler/proc/stop(var/mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/recycler/proc/eat(var/mob/living/L)

	L.loc = src.loc

	if(issilicon(L))
		playsound(src.loc, 'sound/machines/recycler.ogg', 100, 0)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = 1
	// By default, the emagged recycler will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!")
		add_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()

	// Remove and recycle the equipped items.
	for(var/obj/item/I in L.get_equipped_items())
		if(L.unEquip(I))
			recycle(I, 0)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)

	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
	else if(emagged == 1)
		L.adjustBruteLoss(1000)

/obj/machinery/recycler/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	var/mob/living/user = usr

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (src.anchored)
		to_chat(usr, "[src] is fastened to the floor!")
		return 0
	eat_dir = turn(eat_dir, 270)
	to_chat(user, "<span class='notice'>[src] will now accept items from [dir2text(eat_dir)].</span>")
	return 1

/obj/machinery/recycler/verb/rotateccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	var/mob/living/user = usr

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (src.anchored)
		to_chat(usr, "[src] is fastened to the floor!")
		return 0
	eat_dir = turn(eat_dir, 90)
	to_chat(user, "<span class='notice'>[src] will now accept items from [dir2text(eat_dir)].</span>")
	return 1

/obj/item/weapon/paper/recycler
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"
