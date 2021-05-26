/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 1000
	/// A reference to the occupant currently sitting inside the recharger.
	var/mob/occupant = null
	/// What type of circuit board is required to build this machine.
	var/circuitboard = /obj/item/circuitboard/cyborgrecharger
	/// How fast the recharger can give charge to the occupants energy cell. Based on capacitors and the cell the recharger has.
	var/recharge_speed
	/// How much nutrition is given to the occupant. Based on capacitors and the cell the recharger has. Only relevent for IPCs.
	var/recharge_speed_nutrition
	/// How much the occupant is repaired every cycle. Based on what manipulator the recharger has.
	var/repairs
	/// How efficiently the recharger is able to recharge consumable items such as metal, glass, chemicals in sprays, welding tool fuel, etc.
	var/consumable_recharge_coeff

/obj/machinery/recharge_station/Destroy()
	go_out()
	return ..()

/obj/machinery/recharge_station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	RefreshParts()
	build_icon()

/obj/machinery/recharge_station/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	recharge_speed_nutrition = 0
	repairs = 0
	// The recharge_speed can be anywhere from 200 to 3200, depending on the capacitors and the cell.
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
		recharge_speed_nutrition += C.rating * 10
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		var/multiplier = C.get_part_rating() / 10000
		recharge_speed *= multiplier
		recharge_speed_nutrition *= multiplier

	// This coefficient can be anywhere from 1, to 16.
	consumable_recharge_coeff = max(1, recharge_speed / 200)

/obj/machinery/recharge_station/process()
	if(!(NOPOWER|BROKEN))
		return

	if(occupant)
		process_occupant()

	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(src.loc)
	return 1

/obj/machinery/recharge_station/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/recharge_station/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon()

/obj/machinery/recharge_station/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/recharge_station/Bumped(mob/AM)
	if(ismob(AM))
		move_inside(AM)

/obj/machinery/recharge_station/AllowDrop()
	return FALSE

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	src.go_out()
	return

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
		go_out()
	..(severity)

/obj/machinery/recharge_station/proc/build_icon()
	if(NOPOWER|BROKEN)
		if(src.occupant)
			icon_state = "borgcharger1"
		else
			icon_state = "borgcharger0"
	else
		icon_state = "borgcharger0"

/obj/machinery/recharge_station/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return

	else
		return ..()

/obj/machinery/recharge_station/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/recharge_station/screwdriver_act(mob/user, obj/item/I)
	if(occupant)
		to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
		return TRUE
	if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", I))
		return TRUE

/obj/machinery/recharge_station/proc/process_occupant()
	if(isrobot(occupant))
		var/mob/living/silicon/robot/R = occupant
		if(R.module)
			R.module.recharge_consumables(R, consumable_recharge_coeff) // This will handle all of a cyborg's items.
		if(repairs)
			R.heal_overall_damage(repairs, repairs)
		if(R.cell)
			R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
	else if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant
		if(H.get_int_organ(/obj/item/organ/internal/cell) && H.nutrition < 450)
			H.set_nutrition(min(H.nutrition + recharge_speed_nutrition, 450))
		if(repairs)
			H.heal_overall_damage(repairs, repairs, TRUE, 0, 1)

/obj/machinery/recharge_station/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	build_icon()
	use_power = IDLE_POWER_USE
	return

/obj/machinery/recharge_station/verb/move_eject()
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/recharge_station/verb/move_inside(mob/user = usr)
	set category = "Object"
	set src in oview(1)
	if(!user || !usr)
		return

	if(usr.stat != CONSCIOUS)
		return

	if(get_dist(src, user) > 2 || get_dist(usr, user) > 1)
		to_chat(usr, "They are too far away to put inside")
		return

	if(panel_open)
		to_chat(usr, "<span class='warning'>Close the maintenance panel first.</span>")
		return

	var/can_accept_user
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user

		if(occupant)
			to_chat(R, "<span class='warning'>The cell is already occupied!</span>")
			return
		if(!R.cell)
			to_chat(R, "<span class='warning'>Without a power cell, you can't be recharged.</span>")
			//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
			return
		can_accept_user = 1

	else if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(occupant)
			to_chat(H, "<span class='warning'>The cell is already occupied!</span>")
			return
		if(isrobot(H))
			can_accept_user = TRUE
		else if(!H.get_int_organ(/obj/item/organ/internal/cell))
			to_chat(user, "<span class='notice'>Only non-organics may enter the recharger!</span>")
			return
		can_accept_user = 1

	else if(istype(user, /mob/living/simple_animal/spiderbot))
		can_accept_user = TRUE

	if(!can_accept_user)
		to_chat(user, "<span class='notice'>Only non-organics may enter the recharger!</span>")
		return

	user.stop_pulling()
	user.forceMove(src)
	occupant = user

	add_fingerprint(user)
	build_icon()
	update_use_power(1)
	return
