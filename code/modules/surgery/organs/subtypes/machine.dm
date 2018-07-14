// IPC limbs.
/obj/item/organ/external/head/ipc
	can_intake_reagents = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/head/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/chest/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/chest/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/groin/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/groin/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/arm/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/arm/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/arm/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/arm/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()
/obj/item/organ/external/leg/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/leg/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/leg/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/leg/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/foot/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/foot/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/foot/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/foot/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/hand/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/hand/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/external/hand/right/ipc
	encased = null
	status = ORGAN_ROBOT
	species = "Machine"

/obj/item/organ/external/hand/right/ipc/New()
	robotize("Morpheus Cyberkinetics")
	..()

/obj/item/organ/internal/cell
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/obj/power.dmi'
	icon_state = "scell"
	organ_tag = "heart"
	parent_organ = "chest"
	slot = "heart"
	vital = TRUE
	status = ORGAN_ROBOT
	species = "Machine"
	var/obj/item/stock_parts/cell/cell

/obj/item/organ/internal/cell/New()
	cell = new(src)
	..()

/obj/item/organ/internal/cell/on_life()
	if(owner)
		if(cell)
			cell.use(10)
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
					if(vital)
						owner.Paralyse(10)
		else
			owner.throw_alert("cell_organ", /obj/screen/alert/nocell)
			if(vital)
				owner.Paralyse(10)

/obj/item/organ/internal/cell/emp_act(severity)
	if(emp_proof)
		return
	if(cell)
		cell.emp_act(severity)

/obj/item/organ/internal/eyes/optical_sensor
	name = "optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	status = ORGAN_ROBOT
	species = "Machine"
//	dead_icon = "camera_broken"
	weld_proof = 1

/obj/item/organ/internal/eyes/optical_sensor/New()
	robotize()
	..()


/obj/item/organ/internal/eyes/optical_sensor/remove(var/mob/living/user,special = 0)
	if(!special)
		to_chat(owner, "Error 404:Optical Sensors not found.")

	. = ..()

// Used for an MMI or posibrain being installed into a human.
/obj/item/organ/internal/brain/mmi_holder
	name = "brain"
	organ_tag = "brain"
	parent_organ = "chest"
	vital = TRUE
	max_damage = 200
	slot = "brain"
	status = ORGAN_ROBOT
	species = "Machine"
	var/obj/item/mmi/stored_mmi

/obj/item/organ/internal/brain/mmi_holder/Destroy()
	QDEL_NULL(stored_mmi)
	return ..()

/obj/item/organ/internal/brain/mmi_holder/insert(var/mob/living/target,special = 0)
	..()
	// To supersede the over-writing of the MMI's name from `insert`
	update_from_mmi()

/obj/item/organ/internal/brain/mmi_holder/remove(var/mob/living/user,special = 0)
	if(!special)
		if(stored_mmi)
			. = stored_mmi
			if(owner.mind)
				owner.mind.transfer_to(stored_mmi.brainmob)
			stored_mmi.forceMove(get_turf(owner))
			stored_mmi = null
	..()
	if(!QDELETED(src))
		qdel(src)

/obj/item/organ/internal/brain/mmi_holder/proc/update_from_mmi()
	if(!stored_mmi)
		return
	name = stored_mmi.name
	desc = stored_mmi.desc
	icon = stored_mmi.icon
	icon_state = stored_mmi.icon_state
	set_dna(stored_mmi.brainmob.dna)

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	robotize()
	stored_mmi = new /obj/item/mmi/posibrain/ipc(src)
	..()
	spawn(1)
		if(!QDELETED(src))
			if(owner)
				stored_mmi.name = "positronic brain ([owner.real_name])"
				stored_mmi.brainmob.real_name = owner.real_name
				stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
				stored_mmi.icon_state = "posibrain-occupied"
				update_from_mmi()
			else
				stored_mmi.loc = get_turf(src)
				qdel(src)

// lets make IPCs even *more* vulnerable to EMPs!
/obj/item/organ/internal/cyberimp/arm/power_cord
	name = "APC-compatible power adapter implant"
	desc = "An implant commonly installed inside IPCs in order to allow them to easily collect energy from their environment"
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
	var/obj/item/organ/internal/cell/organ_cell = H.get_int_organ(/obj/item/organ/internal/cell)
	if(organ_cell && organ_cell.cell)
		if(A.emagged || A.stat & BROKEN)
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, A)
			s.start()
			to_chat(H, "<span class='warning'>The APC power currents surge erratically, damaging your chassis!</span>")
			H.adjustFireLoss(10,0)
		else if(A.cell && A.cell.charge)
			if(organ_cell.cell.charge >= organ_cell.cell.maxcharge)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
			else
				INVOKE_ASYNC(src, .proc/powerdraw_loop, A, H, organ_cell.cell)
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