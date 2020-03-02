// A special pen for service droids. Can be toggled to switch between normal writing mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/pen/multi/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/pen/multi/robopen/attack_self(mob/user as mob)

	var/choice = input("Would you like to change colour or mode?") as null|anything in list("Colour","Mode")
	if(!choice) return

	switch(choice)

		if("Colour")
			select_colour(user)

		if("Mode")
			if(mode == 1)
				mode = 2
			else
				mode = 1
			to_chat(user, "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'")
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)

	return

// Copied over from paper's rename verb
// see code\modules\paperwork\paper.dm line 62

/obj/item/pen/multi/robopen/proc/RenamePaper(mob/user as mob,obj/paper as obj)
	if( !user || !paper )
		return
	var/n_name = input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text
	if( !user || !paper )
		return

	n_name = copytext(n_name, 1, 32)
	if(( get_dist(user,paper) <= 1  && user.stat == 0))
		paper.name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(user)
	return

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"

/obj/item/form_printer/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/form_printer/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)

	if(!target || !flag)
		return

	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))

/obj/item/form_printer/attack_self(mob/user as mob)
	deploy_paper(get_turf(src))

/obj/item/form_printer/proc/deploy_paper(var/turf/T)
	T.visible_message("<span class='notice'>\The [src.loc] dispenses a sheet of crisp white paper.</span>")
	new /obj/item/paper(T)


//Personal shielding for the combat module.
/obj/item/borg
	var/powerneeded // Percentage of power remaining required to run item

/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	powerneeded = 25
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if(N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	powerneeded = 25



//Allows cyborgs to recharge via any sort of charging station, and allows a cyborg to funnel power into powercells and energy weapons.
obj/item/borg/charger
	name = "cyborg power adapter"
	desc = "A cyborg specific power adapter, allowing cyborgs to siphon power from APCs or power cells to recharge for own, or it can pump power to recharge power cells or energy weapons."
	icon = 'icons/obj/cyborg.dmi'
	icon_state = "c-charger"
	flags = NOBLUDGEON
	var/mode = "siphon"
	var/static/list/charge_machines = typecacheof(list(/obj/machinery/power/apc)) //technically capable of charging from any machine with a power cell
	var/static/list/charge_items = typecacheof(list(/obj/item/stock_parts/cell, /obj/item/gun/energy)) //technically capable of recharging from anything too

/obj/item/borg/charger/examine(mob/user)
	. = ..()
	. += "it's in [mode = "siphon" ? "siphoning" : "charging"] mode."


/obj/item/borg/charger/attack_self(mob/user)
	if(mode == "siphon")
		mode = "charge"
	else
		mode = "siphon"
	to_chat(user, "<span class='notice'>You toggle [src] to \"[mode]\" mode.</span>")

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !issilicon(user))
		return
	if(mode == "siphon") // what happens if we are in siphon mode?
		if(is_type_in_list(target, charge_machines)) // if the target is a machine
			var/obj/machinery/M = target
			if((M.stat & (NOPOWER|BROKEN)) || !M.anchored) //doesn't work if broken, has no power or not anchored
				to_chat(user, "<span class='warning'>[M] is unpowered!</span>")
				return

			to_chat(user, "<span class='notice'>You connect to [M]'s power line...</span>")
			while(do_after(user, 15, target = M, progress = 0)) // drawing power from machines
				if(!user || !user.cell || mode != "siphon")
					return

				if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
					break

				if(!user.cell.give(150))
					break

				M.use_power(200)

			to_chat(user, "<span class='notice'>You stop charging yourself.</span>")

		else if(is_type_in_list(target, charge_items)) // drawing power from powercells in side objects
			var/obj/item/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/cell) in target
			if(!cell)
				to_chat(user, "<span class='warning'>[target] has no power cell!</span>")
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, "<span class='warning'>[target] has no power port!</span>")
					return

			if(!cell.charge)
				to_chat(user, "<span class='warning'>[target] has no power!</span>")


			to_chat(user, "<span class='notice'>You connect to [target]'s power port...</span>")

			while(do_after(user, 15, target = target, progress = 0)) //drawing power from target
				if(!user || !user.cell || mode != "siphon")
					return

				if(!cell || !target)
					return

				if(cell != target && cell.loc != target)
					return

				var/draw = min(cell.charge, cell.chargerate*0.5, user.cell.maxcharge-user.cell.charge) //sets the rate of charge.
				if(!cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
				target.update_icon()

			to_chat(user, "<span class='notice'>You stop charging yourself.</span>")

	else if(is_type_in_list(target, charge_items)) // what happens when we are in charge mode?
		var/obj/item/stock_parts/cell/cell = target // if target is a power cell
		if(!istype(cell)) 
			cell = locate(/obj/item/stock_parts/cell) in target
		if(!cell)
			to_chat(user, "<span class='warning'>[target] has no power cell!</span>")
			return

		if(istype(target, /obj/item/gun/energy)) // if target is a energy gun
			var/obj/item/gun/energy/E = target
			if(!E.can_charge)
				to_chat(user, "<span class='warning'>[target] has no power port!</span>")
				return

		if(cell.charge >= cell.maxcharge)
			to_chat(user, "<span class='warning'>[target] is already charged!</span>")

		to_chat(user, "<span class='notice'>You connect to [target]'s power port...</span>")

		while(do_after(user, 15, target = target, progress = 0)) //giving power to target
			if(!user || !user.cell || mode != "charge")
				return

			if(!cell || !target)
				return

			if(cell != target && cell.loc != target)
				return

			var/draw = min(user.cell.charge, cell.chargerate*0.5, cell.maxcharge-cell.charge) //sets charge rate
			if(!user.cell.use(draw))
				break
			if(!cell.give(draw))
				break
			target.update_icon()

		to_chat(user, "<span class='notice'>You stop charging [target].</span>")