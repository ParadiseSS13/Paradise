var/const/SAFETY_COOLDOWN = 100

/obj/machinery/recycler
	name = "crusher"
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

/obj/machinery/recycler/New()
	// On us
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()
	update_icon()

/obj/machinery/recycler/RefreshParts() //If you want to make the machine upgradable, this is where you would change any vars basd on its stock parts.
	return

/obj/machinery/recycler/examine()
	set src in view()
	..()
	usr << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	usr << "The safety-mode light is [safety_mode ? "on" : "off"]."
	usr << "The safety-sensors status light is [emagged ? "off" : "on"]."

/obj/machinery/recycler/power_change()
	..()
	update_icon()


/obj/machinery/recycler/attackby(var/obj/item/I, var/mob/user, params)
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

/obj/machinery/recycler/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		if(safety_mode)
			safety_mode = 0
			update_icon()
		playsound(src.loc, "sparks", 75, 1, -1)

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

/obj/machinery/recycler/proc/recycle(var/obj/item/I, var/sound = 1)
	I.loc = src.loc
	if(!istype(I,/obj/item/flag/nation))
		qdel(I)
		if(prob(15))
			new /obj/item/stack/sheet/metal(loc)
		if(prob(10))
			new /obj/item/stack/sheet/glass(loc)
		if(prob(2))
			new /obj/item/stack/sheet/plasteel(loc)
		if(prob(1))
			new /obj/item/stack/sheet/rglass(loc)
		if(sound)
			playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)


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
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
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
		usr << "[src] is fastened to the floor!"
		return 0
	eat_dir = turn(eat_dir, 270)
	user << "<span class='notice'>[src] will now accept items from [dir2text(eat_dir)].</span>"
	return 1

/obj/machinery/recycler/verb/rotateccw()
	set name = "Rotate Counter Clockwise"
	set category = "Object"
	set src in oview(1)

	var/mob/living/user = usr

	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if (src.anchored)
		usr << "[src] is fastened to the floor!"
		return 0
	eat_dir = turn(eat_dir, 90)
	user << "<span class='notice'>[src] will now accept items from [dir2text(eat_dir)].</span>"
	return 1

/obj/item/weapon/paper/recycler
	name = "paper - 'garbage duty instructions'"
	info = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect the said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then deliver these minerals to cargo or engineering. You are our last hope for a clean station, do not screw this up!"