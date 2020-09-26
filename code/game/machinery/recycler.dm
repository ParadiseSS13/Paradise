#define SAFETY_COOLDOWN 100

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle small items inefficiently. There are lights on the side."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	damage_deflection = 15
	var/emergency_mode = FALSE // Temporarily stops machine if it detects a mob
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_dir = WEST
	var/amount_produced = 1
	var/crush_damage = 1000
	var/eat_victim_items = 1
	var/item_recycle_sound = 'sound/machines/recycler.ogg'

/obj/machinery/recycler/New()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_PLASTIC, MAT_BLUESPACE), 0, TRUE, null, null, null, TRUE)
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/recycler(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/recycler/RefreshParts()
	var/amt_made = 0
	var/mat_mod = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		mat_mod = 2 * B.rating
	mat_mod *= 50000
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		amt_made = 25 * M.rating //% of materials salvaged
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = mat_mod
	amount_produced = min(100, amt_made)

/obj/machinery/recycler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The power light is [(stat & NOPOWER) ? "<b>off</b>" : "<b>on</b>"]."
	. += "The operation light is [emergency_mode ? "<b>off</b>. [src] has detected a forbidden object with its sensors, and has shut down temporarily." : "<b>on</b>. [src] is active."]"
	. += "The safety sensor light is [emagged ? "<b>off</b>!" : "<b>on</b>."]</span>"

/obj/machinery/recycler/power_change()
	..()
	update_icon()

/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/recycler/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/recycler/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return TRUE

/obj/machinery/recycler/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I))
		return TRUE



/obj/machinery/recycler/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(emergency_mode)
			emergency_mode = FALSE
			update_icon()
		playsound(loc, "sparks", 75, 1, -1)
		to_chat(user, "<span class='notice'>You use the cryptographic sequencer on the [name].</span>")

/obj/machinery/recycler/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(emergency_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

// This is purely for admin possession !FUN!.
/obj/machinery/recycler/Bump(atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)

/obj/machinery/recycler/Bumped(atom/movable/AM)

	if(stat & (BROKEN|NOPOWER))
		return
	if(!anchored)
		return
	if(emergency_mode)
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		eat(AM)

/obj/machinery/recycler/proc/eat(atom/AM0, sound = 1)
	var/list/to_eat = list(AM0)
	if(istype(AM0, /obj/item))
		to_eat += AM0.GetAllContents()
	var/items_recycled = 0

	for(var/i in to_eat)
		var/atom/movable/AM = i
		if(QDELETED(AM))
			continue
		else if(isliving(AM))
			if(emagged)
				crush_living(AM)
			else
				emergency_stop(AM)
		else if(istype(AM, /obj/item))
			recycle_item(AM)
			items_recycled++
		else
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.forceMove(loc)

	if(items_recycled && sound)
		playsound(loc, item_recycle_sound, 100, 0)

/obj/machinery/recycler/proc/recycle_item(obj/item/I)
	I.forceMove(loc)

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/material_amount = materials.get_item_material_amount(I)
	if(!material_amount)
		qdel(I)
		return
	materials.insert_item(I, multiplier = (amount_produced / 100))
	qdel(I)
	materials.retrieve_all()


/obj/machinery/recycler/proc/emergency_stop(mob/living/L)
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	emergency_mode = TRUE
	update_icon()
	L.loc = loc
	addtimer(CALLBACK(src, .proc/reboot), SAFETY_COOLDOWN)

/obj/machinery/recycler/proc/reboot()
	playsound(loc, 'sound/machines/ping.ogg', 50, 0)
	emergency_mode = FALSE
	update_icon()

/obj/machinery/recycler/proc/crush_living(mob/living/L)

	L.loc = loc

	if(issilicon(L))
		playsound(loc, 'sound/items/welder.ogg', 50, 1)
	else
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = 1
	// By default, the emagged recycler will gib all non-carbons. (human simple animal mobs don't count)
	if(iscarbon(L))
		gib = 0
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!")
		add_mob_blood(L)

	if(!blood && !issilicon(L))
		blood = 1
		update_icon()

	// Remove and recycle the equipped items
	if(eat_victim_items)
		for(var/obj/item/I in L.get_equipped_items(TRUE))
			if(L.unEquip(I))
				eat(I, sound = 0)

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Paralyse(5)

	// For admin fun, var edit emagged to 2.
	if(gib || emagged == 2)
		L.gib()
	else if(emagged == 1)
		L.adjustBruteLoss(crush_damage)


/obj/machinery/recycler/verb/rotate()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)

	var/mob/living/user = usr

	if(usr.incapacitated())
		return
	if(anchored)
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

	if(usr.incapacitated())
		return
	if(anchored)
		to_chat(usr, "[src] is fastened to the floor!")
		return 0
	eat_dir = turn(eat_dir, 90)
	to_chat(user, "<span class='notice'>[src] will now accept items from [dir2text(eat_dir)].</span>")
	return 1


/obj/machinery/recycler/deathtrap
	name = "dangerous old crusher"
	emagged = 1
	crush_damage = 120


/obj/item/paper/recycler
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"
