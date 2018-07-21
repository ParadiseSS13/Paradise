/obj/item/organ/internal/cell_mount
	name = "cell mount"
	desc = "A small mechanical augment capable of holding a battery."
	icon = 'icons/obj/robot_parts.dmi'
	icon_state = "chest"
	dead_icon = "chest"
	organ_tag = "cell_mount"
	parent_organ = "chest"
	slot = "cell_mount"
	status = ORGAN_ROBOT
	var/obj/item/stock_parts/cell/cell

/obj/item/organ/internal/cell_mount/full/New()
	cell = new(src)
	..()

/obj/item/organ/internal/cell_mount/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/organ/internal/cell_mount/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I) && cell)
		to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
		cell.forceMove(get_turf(src))
		cell = null
		return
	if(istype(I, /obj/item/stock_parts/cell))
		if(!cell)
			if(user.drop_item())
				I.forceMove(src)
				cell = I
				to_chat(user, "<span class='notice'>You install [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		return
	return ..()

/obj/item/organ/internal/cell_mount/on_life()
	if(owner)
		if(cell)
			cell.use(1) // ~33 minutes to go from full to nothing
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					owner.clear_alert("cell_organ")
				if(0.5 to 0.75)
					owner.throw_alert("cell_organ", /obj/screen/alert/lowcell, 1)
				if(0.25 to 0.5)
					owner.throw_alert("cell_organ", /obj/screen/alert/lowcell, 2)
				if(0.01 to 0.25)
					owner.throw_alert("cell_organ", /obj/screen/alert/lowcell, 3)
				else
					owner.throw_alert("cell_organ", /obj/screen/alert/emptycell)
		else
			owner.throw_alert("cell_organ", /obj/screen/alert/nocell)

/obj/item/organ/internal/cell_mount/emp_act(severity)
	if(emp_proof)
		return
	if(cell)
		cell.emp_act(severity)

/obj/item/organ/internal/cyberimp/arm/power_cord
	name = "APC-compatible power adapter implant"
	desc = "An implant installed in order to allow an internal battery to be recharged."
	origin_tech = "materials=3;biotech=2;powerstorage=3"
	contents = newlist(/obj/item/apc_powercord)

/obj/item/organ/internal/cyberimp/arm/power_cord/emp_act(severity)
	// To allow repair via nanopaste/screwdriver
	// also so IPCs don't also catch on fire and fall even more apart upon EMP
	if(emp_proof)
		return
	damage = 1
	crit_fail = TRUE

/obj/item/organ/internal/cyberimp/arm/power_cord/surgeryize()
	if(crit_fail && owner)
		to_chat(owner, "<span class='notice'>Your [src] feels functional again.</span>")
	crit_fail = FALSE


/obj/item/apc_powercord
	name = "power cable"
	desc = "Insert into a nearby APC to draw power from it."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	flags = NOBLUDGEON

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/machinery/power/apc/A = target
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/internal/cell_mount/cell_mount = H.get_int_organ(/obj/item/organ/internal/cell_mount)
	if(cell_mount && cell_mount.cell)
		if(A.emagged || A.stat & BROKEN)
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, A)
			s.start()
			to_chat(H, "<span class='warning'>The APC power currents surge erratically, damaging your chassis!</span>")
			H.adjustFireLoss(10,0)
		else if(A.cell && A.cell.charge)
			if(cell_mount.cell.charge >= cell_mount.cell.maxcharge)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
			else
				INVOKE_ASYNC(src, .proc/powerdraw_loop, A, H, cell_mount.cell)
		else
			to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")
	else
		to_chat(user, "<span class='warning'>You lack a cell in which to store charge!</span>")

/obj/item/apc_powercord/proc/powerdraw_loop(obj/machinery/power/apc/A, mob/living/carbon/human/H, obj/item/stock_parts/cell/C)
	H.visible_message("<span class='notice'>[H] inserts a power connector into [A].</span>", "<span class='notice'>You begin to draw power from [A].</span>")
	while(do_after(H, 10, target = A))
		if(loc != H)
			to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
			break
		if(!A.cell.charge)
			to_chat(H, "<span class='warning'>[A] has no more charge.</span>")
			break
		A.charging = 1
		if(A.cell.charge >= 50)
			C.give(50)
			A.cell.use(50)
			to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
		else
			C.give(A.cell.charge)
			A.cell.use(A.cell.charge)
			to_chat(H, "<span class='notice'>You siphon off the last of [A]'s charge.</span>")
			break
		if(C.charge >= C.maxcharge)
			to_chat(H, "<span class='notice'>You are now fully charged.</span>")
			break
	H.visible_message("<span class='notice'>[H] unplugs from [A].</span>", "<span class='notice'>You unplug from [A].</span>")