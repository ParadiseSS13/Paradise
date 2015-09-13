/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/occupant = null
	var/circuitboard = "/obj/item/weapon/circuitboard/cyborgrecharger"
	var/recharge_speed
	var/recharge_speed_nutrition
	var/repairs

/obj/machinery/recharge_station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()
	build_icon()

/obj/machinery/recharge_station/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	recharge_speed_nutrition = 0
	repairs = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
		recharge_speed_nutrition += C.rating * 10
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/weapon/stock_parts/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000

/obj/machinery/recharge_station/process()
	if(!(NOPOWER|BROKEN))
		return

	if(src.occupant)
		process_occupant()
	return 1

/obj/machinery/recharge_station/Bumped(var/mob/AM)
	move_inside(AM)	
	
/obj/machinery/recharge_station/allow_drop()
	return 0

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

/obj/machinery/recharge_station/attackby(obj/item/P as obj, mob/user as mob, params)
	if (istype(P, /obj/item/weapon/screwdriver))
		if(src.occupant)
			user << "<span class='notice'>The maintenance panel is locked.</span>"
			return
		default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P)
		return

	if(exchange_parts(user, P))
		return

	default_deconstruction_crowbar(P)

/obj/machinery/recharge_station/proc/process_occupant()
	if(src.occupant)
		if (istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			restock_modules()
			if(repairs)
				R.adjustBruteLoss(-(repairs))
				R.adjustFireLoss(-(repairs))
				R.updatehealth()
			if(R.cell)
				if(R.cell.charge >= R.cell.maxcharge)
					R.cell.charge = R.cell.maxcharge
				else
					R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
		else if(istype(occupant, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = occupant
			if(!isnull(H.internal_organs_by_name["cell"]) && H.nutrition < 450)
				H.nutrition = min(H.nutrition+recharge_speed_nutrition, 450)
				if(repairs)
					H.adjustBruteLoss(-(repairs))
					H.adjustFireLoss(-(repairs))
					H.updatehealth()

/obj/machinery/recharge_station/proc/go_out()
	if(!( src.occupant ))
		return
	//for(var/obj/O in src)
	//	O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	build_icon()
	src.use_power = 1
	return

/obj/machinery/recharge_station/proc/restock_modules()
	if(src.occupant)
		if(istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			var/coeff = recharge_speed / 200
			if(R.module && R.module.modules)
				var/list/um = R.contents|R.module.modules
				// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
				for(var/obj/O in um)
					// Engineering
					if(istype(O,/obj/item/stack/sheet/metal) || istype(O,/obj/item/stack/sheet/rglass) || istype(O,/obj/item/stack/cable_coil))
						if(O:amount < 50)
							O:amount += 1 * coeff
					// Security
					if(istype(O,/obj/item/device/flash))
						if(O:broken)
							O:broken = 0
							O:times_used = 0
							O:icon_state = "flash"
					if(istype(O,/obj/item/weapon/gun/energy/disabler/cyborg))
						if(O:power_supply.charge < O:power_supply.maxcharge)
							O:power_supply.give(O:charge_cost)
							O:update_icon()
						else
							O:charge_tick = 0
					if(istype(O,/obj/item/weapon/melee/baton))
						var/obj/item/weapon/melee/baton/B = O
						if(B.bcell)
							B.bcell.charge = B.bcell.maxcharge
					//Service
					if(istype(O,/obj/item/weapon/reagent_containers/food/condiment/enzyme))
						if(O.reagents.get_reagent_amount("enzyme") < 50)
							O.reagents.add_reagent("enzyme", 2 * coeff)
					//Medical
					if(istype(O,/obj/item/weapon/reagent_containers/glass/bottle/robot))
						var/obj/item/weapon/reagent_containers/glass/bottle/robot/B = O
						if(B.reagent && (B.reagents.get_reagent_amount(B.reagent) < B.volume))
							B.reagents.add_reagent(B.reagent, 2 * coeff)
					//Janitor
					if(istype(O, /obj/item/device/lightreplacer))
						var/obj/item/device/lightreplacer/LR = O
						var/i = 1
						for(1, i <= coeff, i++)
							LR.Charge(occupant)
					//Alien
					if(istype(O,/obj/item/weapon/reagent_containers/spray/alien/smoke))
						if(O.reagents.get_reagent_amount("water") < 50)
							O.reagents.add_reagent("water", 2 * coeff)
					if(istype(O,/obj/item/weapon/reagent_containers/spray/alien/stun))
						if(O.reagents.get_reagent_amount("ether") < 250)
							O.reagents.add_reagent("ether", 2 * coeff)


				if(R)
					if(R.module)
						R.module.respawn_consumable(R)

				//Emagged items for janitor and medical borg
				if(R.module.emag)
					if(istype(R.module.emag, /obj/item/weapon/reagent_containers/spray))
						var/obj/item/weapon/reagent_containers/spray/S = R.module.emag
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
	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/recharge_station/verb/move_inside(var/mob/user = usr)
	set category = "Object"
	set src in oview(1)
	
	if(!user)
		return
	
	if (panel_open)
		usr << "<span class='warning'>Close the maintenance panel first.</span>"
		return	
	
	var/can_accept_user
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user

		if(R.stat == DEAD)
			//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
			return
		if(occupant)
			R << "<span class='warning'>The cell is already occupied!</span>"
			return
		if(!R.cell)
			R << "<span class='warning'>Without a power cell, you can't be recharged.</span>"
			//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
			return
		can_accept_user = 1	
	
	else if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		
		if(H.stat == DEAD)
			return		
		if(occupant)
			H << "<span class='warning'>The cell is already occupied!</span>"
			return			
		if(isnull(H.internal_organs_by_name["cell"]))
			return
		can_accept_user = 1

	if(!can_accept_user)
		user << "<span class='notice'>Only non-organics may enter the recharger!</span>"
		return

	user.stop_pulling()
	if(user && user.client)
		user.client.perspective = EYE_PERSPECTIVE
		user.client.eye = src
	user.forceMove(src)
	occupant = user

	add_fingerprint(user)
	build_icon()
	update_use_power(1)
	return
	