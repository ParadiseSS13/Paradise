/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/living/occupant = null
	var/circuitboard = /obj/item/circuitboard/cyborgrecharger
	var/recharge_speed
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

/obj/machinery/recharge_station/Destroy()
	go_out()
	return ..()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		var/multiplier = C.maxcharge / 10000
		recharge_speed *= multiplier

/obj/machinery/recharge_station/process()
	if(!(NOPOWER|BROKEN))
		return

	if(occupant)
		process_occupant()

	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else
			M.forceMove(get_turf(src))
	return TRUE

/obj/machinery/recharge_station/ex_act(severity)
	var/mob/living/L = occupant
	switch(severity)
		if(1)
			qdel(src)
			if(L)
				L.ex_act(severity)
		if(2)
			if(prob(50))
				qdel(src)
				if(L)
					L.ex_act(severity)
		if(3)
			if(prob(25))
				qdel(src)
				if(L)
					L.ex_act(severity)

/obj/machinery/recharge_station/blob_act()
	if(prob(50) && occupant)
		var/mob/living/L = occupant
		qdel(src)
		L.blob_act()

/obj/machinery/recharge_station/narsie_act()
	new /obj/effect/gibspawner/generic(get_turf(src)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)


/obj/machinery/recharge_station/attack_animal(mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)

/obj/machinery/recharge_station/Bumped(atom/movable/AM)
	if(isrobot(AM) || ishuman(AM))
		move_inside(AM)

/obj/machinery/recharge_station/allow_drop()
	return FALSE

/obj/machinery/recharge_station/relaymove(mob/user)
	if(user.stat)
		return
	go_out()

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		var/mob/living/L = occupant
		go_out()
		L.emp_act(severity)
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
	if(isscrewdriver(I))
		if(occupant)
			to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
			return
		default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", I)
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/recharge_station/proc/process_occupant()
	if(occupant)
		if(isrobot(occupant))
			var/mob/living/silicon/robot/R = occupant
			restock_modules()
			if(repairs)
				R.adjustBruteLoss(-(repairs))
				R.adjustFireLoss(-(repairs))
				R.updatehealth()
			if(R.cell)
				R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
		else if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			var/obj/item/organ/internal/cell_mount/cell_mount = H.get_int_organ(/obj/item/organ/internal/cell_mount)
			if(cell_mount)
				if(cell_mount.cell)
					cell_mount.cell.charge = min(cell_mount.cell.charge + recharge_speed, cell_mount.cell.maxcharge)
				if(repairs)
					H.heal_overall_damage(repairs, repairs, FALSE, TRUE)

/obj/machinery/recharge_station/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(get_turf(src))
	occupant = null
	build_icon()
	use_power = IDLE_POWER_USE

/obj/machinery/recharge_station/proc/restock_modules()
	if(occupant)
		if(isrobot(occupant))
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
					if(istype(O,/obj/item/gun/energy/disabler/cyborg))
						var/obj/item/gun/energy/disabler/cyborg/D = O
						if(D.power_supply.charge < D.power_supply.maxcharge)
							var/obj/item/ammo_casing/energy/E = D.ammo_type[D.select]
							D.power_supply.give(E.e_cost)
							D.update_icon()
						else
							D.charge_tick = 0
					if(istype(O,/obj/item/melee/baton))
						var/obj/item/melee/baton/B = O
						if(B.bcell)
							B.bcell.charge = B.bcell.maxcharge
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

	if(usr.stat != CONSCIOUS)
		return
	go_out()
	add_fingerprint(usr)

/obj/machinery/recharge_station/proc/move_inside(mob/living/L)
	if(!L)
		return

	if(panel_open)
		to_chat(L, "<span class='warning'>Close the maintenance panel first.</span>")
		return

	if(occupant)
		to_chat(L, "<span class='warning'>The cell is already occupied!</span>")
		return

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(!H.get_int_organ(/obj/item/organ/internal/cell_mount))
			to_chat(H, "<span class='warning'>Without a cell mount, you can't interface with [src].</span>")
			return

	L.stop_pulling()
	L.forceMove(src)
	occupant = L

	add_fingerprint(L)
	build_icon()
	update_use_power(1)