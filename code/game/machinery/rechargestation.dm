/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 1000
	occupy_whitelist = list(/mob/living/carbon/human, /mob/living/silicon/robot)
	occupy_delay = 0
	var/circuitboard = /obj/item/circuitboard/cyborgrecharger
	var/recharge_speed
	var/recharge_speed_nutrition
	var/repairs

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
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
		recharge_speed_nutrition += C.rating * 10
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		var/multiplier = C.maxcharge / 10000
		recharge_speed *= multiplier
		recharge_speed_nutrition *= multiplier

/obj/machinery/recharge_station/process()
	if(!(NOPOWER|BROKEN))
		return

	process_occupant()

	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(src.loc)
	return 1

/obj/machinery/recharge_station/narsie_act()
	unoccupy(force = TRUE)
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/recharge_station/Bumped(var/mob/AM)
	if(ismob(AM))
		occupy(AM, AM)

/obj/machinery/recharge_station/AllowDrop()
	return FALSE

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	occupant?.emp_act(severity)
	..(severity)

/obj/machinery/recharge_station/proc/build_icon()
	if(NOPOWER|BROKEN)
		if(occupant)
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
	if(occupant)
		if(istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			restock_modules()
			if(repairs)
				R.heal_overall_damage(repairs, repairs)
			if(R.cell)
				R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
		else if(istype(occupant, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = occupant
			if(H.get_int_organ(/obj/item/organ/internal/cell) && H.nutrition < 450)
				H.set_nutrition(min(H.nutrition + recharge_speed_nutrition, 450))
			if(repairs)
				H.heal_overall_damage(repairs, repairs, TRUE, 0, 1)

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		if(istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			var/coeff = recharge_speed / 200
			if(R.module && R.module.modules)
				var/list/um = R.contents|R.module.modules
				// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
				for(var/obj/O in um)
					// Engineering
					if(istype(O,/obj/item/stack/sheet))
						var/obj/item/stack/sheet/S = O
						if(S.amount < S.max_amount)
							S.amount += round(min(1 * coeff, S.max_amount - S.amount))
					// Security
					if(istype(O,/obj/item/flash))
						var/obj/item/flash/F = O
						if(F.broken)
							F.broken = 0
							F.times_used = 0
							F.icon_state = "flash"
					if(istype(O,/obj/item/gun/energy))
						var/obj/item/gun/energy/D = O
						if(D.cell.charge < D.cell.maxcharge)
							var/obj/item/ammo_casing/energy/E = D.ammo_type[D.select]
							D.cell.give(E.e_cost)
							D.on_recharge()
							D.update_icon()
						else
							D.charge_tick = 0
					if(istype(O,/obj/item/melee/baton))
						var/obj/item/melee/baton/B = O
						if(B.cell)
							B.cell.charge = B.cell.maxcharge
					//Service
					if(istype(O,/obj/item/reagent_containers/food/condiment/enzyme))
						if(O.reagents.get_reagent_amount("enzyme") < 50)
							O.reagents.add_reagent("enzyme", 2 * coeff)
					//Janitor
					if(istype(O, /obj/item/lightreplacer))
						var/obj/item/lightreplacer/LR = O
						var/i = 1
						for(1, i <= coeff, i++)
							LR.Charge(occupant)
					//Fire extinguisher
					if(istype(O, /obj/item/extinguisher))
						var/obj/item/extinguisher/ext = O
						ext.reagents.check_and_add("water", ext.max_water, 5 * coeff)
					//Welding tools
					if(istype(O, /obj/item/weldingtool))
						var/obj/item/weldingtool/weld = O
						weld.reagents.check_and_add("fuel", weld.maximum_fuel, 2 * coeff)
				if(R)
					if(R.module)
						R.module.respawn_consumable(R)

				//Emagged items for janitor and medical borg
				if(R.module.emag)
					if(istype(R.module.emag, /obj/item/reagent_containers/spray))
						var/obj/item/reagent_containers/spray/S = R.module.emag
						if(S.name == "polyacid spray")
							S.reagents.add_reagent("facid", 2 * coeff)
						if(S.name == "lube spray")
							S.reagents.add_reagent("lube", 2 * coeff)
						else if(S.name == "acid synthesizer")
							S.reagents.add_reagent("facid", 2 * coeff)
							S.reagents.add_reagent("sacid", 2 * coeff)

/obj/machinery/recharge_station/verb/move_eject()
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return
	unoccupy(usr)

/obj/machinery/recharge_station/verb/move_inside()
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return
	occupy(usr, usr)

/obj/machinery/recharge_station/can_occupy(mob/living/M, mob/user)
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(!R.cell)
			to_chat(user, "<span class='warning'>Required power cell not found.</span>")
			return FALSE
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.get_int_organ(/obj/item/organ/internal/cell))
			to_chat(user, "<span class='warning'>Only non-organics may enter the recharger!</span>")
			return FALSE
	return ..()

/obj/machinery/recharge_station/occupy(mob/living/M, mob/user, instant)
	. = ..()
	if(.)
		build_icon()
		update_use_power(1)

/obj/machinery/recharge_station/unoccupy(mob/user, force)
	. = ..()
	if(.)
		build_icon()
		use_power = IDLE_POWER_USE
