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


//APC power adapter for cyborgs, adapted from apc_powercord code
//Allows cyborgs to recharge via APC, at first faster than a stock cyborg recharging station, upgraded stations are faster.
obj/item/ccharger
	name = "APC power adapter"
	desc = "A cyborg specific power adapter, allowing cyborgs to siphon power from APCs to recharge their powercells"
	icon = 'icons/obj/cyborg.dmi'
	icon_state = "c-charger"
	flags = NOBLUDGEON

/obj/item/ccharger/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !issilicon(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/machinery/power/apc/A = target
	var/mob/living/silicon/robot/H = user
	if(H.cell)
		if(A.emagged || A.stat & BROKEN)
			do_sparks(3, 1, A)
			to_chat(H, "<span class='warning'>The APC power currents surge erratically, damaging your chassis!</span>")
			H.adjustFireLoss(10,0)
		else if(A.cell && A.cell.charge > 0)
			if(H.cell.charge >= H.cell.maxcharge)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
			else
				INVOKE_ASYNC(src, .proc/powerdraw_loop, A, H)
		else
			to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")
	else
		to_chat(user, "<span class='warning'>You lack a cell in which to store charge!</span>")

/obj/item/ccharger/proc/powerdraw_loop(obj/machinery/power/apc/A, mob/living/silicon/robot/H)
	H.visible_message("<span class='notice'>[H] inserts a power connector into \the [A].</span>", "<span class='notice'>You begin to draw power from \the [A].</span>")
	while(do_after(H, 10, target = A))
		if(loc != H)
			to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
			break
		if(A.cell.charge == 0)
			to_chat(H, "<span class='warning'>\The [A] has no more charge.</span>")
			break
		A.charging = 1
		if(A.cell.charge >= 200)
			H.cell.charge += 200 * H.cell.rating // replenishment scales with higher capacity cells
			A.cell.charge -= 200 // as to not rapidly drain and depower rooms 
			to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
		else
			H.cell.charge += A.cell.charge
			A.cell.charge = 0
			to_chat(H, "<span class='notice'>You siphon off the last of \the [A]'s charge.</span>")
			break
		if(H.cell.charge >= H.cell.maxcharge)
			to_chat(H, "<span class='notice'>You are now fully charged.</span>")
			break
	H.visible_message("<span class='notice'>[H] unplugs from \the [A].</span>", "<span class='notice'>You unplug from \the [A].</span>")