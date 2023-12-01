/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 1000
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

/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	RefreshParts()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/recharge_station/upgraded/Initialize(mapload)
	. = ..()
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
		var/multiplier = C.maxcharge / 10000
		recharge_speed *= multiplier
		recharge_speed_nutrition *= multiplier

	// This coefficient can be anywhere from 1, to 16.
	consumable_recharge_coeff = max(1, recharge_speed / 200)

/obj/machinery/recharge_station/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(occupant)
		process_occupant()

	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else if(!ispulsedemon(M))
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
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/recharge_station/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/recharge_station/Bumped(mob/bumper)
	if(istype(bumper))
		move_inside(bumper, bumper)

/obj/machinery/recharge_station/AllowDrop()
	return FALSE

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(ispulsedemon(user))
		return
	if(user.stat)
		return
	go_out()

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
		go_out()
	..(severity)

/obj/machinery/recharge_station/update_icon_state()
	if(occupant)
		if(!(stat & (NOPOWER|BROKEN)))
			icon_state = "borgcharger1"
		else
			icon_state = "borgcharger2"
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
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, recharge_speed, repairs)
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
		if(H.get_int_organ(/obj/item/organ/internal/cell))
			if(H.nutrition < NUTRITION_LEVEL_FULL - 1)
				H.set_nutrition(min(H.nutrition + recharge_speed_nutrition, NUTRITION_LEVEL_FULL - 1))
			if(repairs)
				H.heal_overall_damage(repairs, repairs, TRUE, 0, 1)


/obj/machinery/recharge_station/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(loc)
	occupant = null
	update_icon(UPDATE_ICON_STATE)
	change_power_mode(IDLE_POWER_USE)

/obj/machinery/recharge_station/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return
	go_out()

/obj/machinery/recharge_station/force_eject_occupant(mob/target)
	go_out()

/obj/machinery/recharge_station/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target))
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/recharge_station, move_inside), user, target)
	return TRUE

/obj/machinery/recharge_station/proc/move_inside(mob/user, mob/target)
	if(!user || user.stat)
		return

	if(get_dist(src, user) > 2 || get_dist(target, user) > 1)
		to_chat(user, "<span class='notice'>[target] is too far away to put inside [src].</span>")
		return

	if(panel_open)
		to_chat(user, "<span class='warning'>Close the maintenance panel first.</span>")
		return

	var/can_accept_user
	if(isrobot(target))
		var/mob/living/silicon/robot/R = target

		if(R.stat == DEAD)
			//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
			return
		if(occupant)
			to_chat(R, "<span class='warning'>The cell is already occupied!</span>")
			return
		if(!R.cell)
			to_chat(R, "<span class='warning'>Without a power cell, you can't be recharged.</span>")
			//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
			return
		can_accept_user = 1

	else if(ishuman(target))
		var/mob/living/carbon/human/H = target

		if(H.stat == DEAD)
			return
		if(occupant)
			to_chat(H, "<span class='warning'>The cell is already occupied!</span>")
			return
		if(!ismodcontrol(H.back))
			if(!H.get_int_organ(/obj/item/organ/internal/cell))
				return
		can_accept_user = 1

	if(!can_accept_user)
		to_chat(user, "<span class='notice'>Only non-organics may enter the recharger!</span>")
		return

	target.stop_pulling()
	target.forceMove(src)
	occupant = target

	add_fingerprint(user)
	update_icon(UPDATE_ICON_STATE)
	change_power_mode(IDLE_POWER_USE)
