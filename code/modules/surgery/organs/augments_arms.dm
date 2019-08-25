/obj/item/organ/internal/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	parent_organ = "r_arm"
	slot = "r_arm_device"
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	var/list/items_list = list()
	// Used to store a list of all items inside, for multi-item implants.
	// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.

	var/obj/item/holder = null
	// You can use this var for item path, it would be converted into an item on New()

/obj/item/organ/internal/cyberimp/arm/New()
	..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon()
	slot = parent_organ + "_device"
	items_list = contents.Copy()

/obj/item/organ/internal/cyberimp/arm/update_icon()
	if(parent_organ == "r_arm")
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/arm/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[src] is assembled in the [parent_organ == "r_arm" ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>")

/obj/item/organ/internal/cyberimp/arm/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		if(parent_organ == "r_arm")
			parent_organ = "l_arm"
		else
			parent_organ = "r_arm"
		slot = parent_organ + "_device"
		to_chat(user, "<span class='notice'>You modify [src] to be installed on the [parent_organ == "r_arm" ? "right" : "left"] arm.</span>")
		update_icon()
	else
		return ..()

/obj/item/organ/internal/cyberimp/arm/remove(mob/living/carbon/M, special = 0)
	Retract()
	. = ..()

/obj/item/organ/internal/cyberimp/arm/emag_act()
	return 0

/obj/item/organ/internal/cyberimp/arm/emp_act(severity)
	if(emp_proof)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>[src] is hit by EMP!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()
	..()

/obj/item/organ/internal/cyberimp/arm/proc/Retract()
	if(!holder || (holder in src))
		return

	owner.visible_message("<span class='notice'>[owner] retracts [holder] back into [owner.p_their()] [parent_organ == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='notice'>[holder] snaps back into your [parent_organ == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")

	if(istype(holder, /obj/item/flash/armimplant))
		var/obj/item/flash/F = holder
		F.set_light(0)

	owner.unEquip(holder, 1)
	holder.forceMove(src)
	holder = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/internal/cyberimp/arm/proc/Extend(var/obj/item/item)
	if(!(item in src))
		return


	holder = item

	holder.flags |= NODROP
	holder.unacidable = 1
	holder.slot_flags = null
	holder.w_class = WEIGHT_CLASS_HUGE
	holder.materials = null

	if(istype(holder, /obj/item/flash/armimplant))
		var/obj/item/flash/F = holder
		F.set_light(7)

	var/arm_slot = (parent_organ == "r_arm" ? slot_r_hand : slot_l_hand)
	var/obj/item/arm_item = owner.get_item_by_slot(arm_slot)

	if(arm_item)
		if(!owner.unEquip(arm_item))
			to_chat(owner, "<span class='warning'>Your [arm_item] interferes with [src]!</span>")
			return
		else
			to_chat(owner, "<span class='notice'>You drop [arm_item] to activate [src]!</span>")

	if(parent_organ == "r_arm" ? !owner.put_in_r_hand(holder) : !owner.put_in_l_hand(holder))
		to_chat(owner, "<span class='warning'>Your [src] fails to activate!</span>")
		return

	// Activate the hand that now holds our item.
	if(parent_organ == "r_arm" ? owner.hand : !owner.hand)
		owner.swap_hand()

	owner.visible_message("<span class='notice'>[owner] extends [holder] from [owner.p_their()] [parent_organ == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='notice'>You extend [holder] from your [parent_organ == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/internal/cyberimp/arm/ui_action_click()
	if(crit_fail || (!holder && !contents.len))
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return

	// You can emag the arm-mounted implant by activating it while holding emag in it's hand.
	var/arm_slot = (parent_organ == "r_arm" ? slot_r_hand : slot_l_hand)
	if(istype(owner.get_item_by_slot(arm_slot), /obj/item/card/emag) && emag_act(owner))
		return

	if(!holder || (holder in src))
		holder = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			radial_menu(owner)
	else
		Retract()

/obj/item/organ/internal/cyberimp/arm/proc/check_menu(var/mob/user)
	return (owner && owner == user && owner.stat != DEAD && (src in owner.internal_organs) && !holder)

/obj/item/organ/internal/cyberimp/arm/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/obj/I in items_list)
		choices["[I.name]"] = image(icon = I.icon, icon_state = I.icon_state)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user))
	if(!check_menu(user))
		return
	var/obj/item/selected
	for(var/obj/item in items_list)
		if(item.name == choice)
			selected = item
			break
	if(istype(selected) && (selected in contents))
		Extend(selected)

/obj/item/organ/internal/cyberimp/arm/gun/emp_act(severity)
	if(emp_proof)
		return
	if(prob(30/severity) && owner && !crit_fail)
		Retract()
		owner.visible_message("<span class='danger'>A loud bang comes from [owner]\'s [parent_organ == "r_arm" ? "right" : "left"] arm!</span>")
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, 1)
		to_chat(owner, "<span class='userdanger'>You feel an explosion erupt inside your [parent_organ == "r_arm" ? "right" : "left"] arm as your implant breaks!</span>")
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		crit_fail = 1
	else // The gun will still discharge anyway.
		..()


/obj/item/organ/internal/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	origin_tech = "materials=4;combat=4;biotech=4;powerstorage=4;syndicate=3"
	contents = newlist(/obj/item/gun/energy/laser/mounted)

/obj/item/organ/internal/cyberimp/arm/gun/laser/l
	parent_organ = "l_arm"

/obj/item/organ/internal/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	origin_tech = "materials=5;combat=5;biotech=4;powerstorage=4"
	contents = newlist(/obj/item/gun/energy/gun/advtaser/mounted)

/obj/item/organ/internal/cyberimp/arm/gun/taser/l
	parent_organ = "l_arm"


/obj/item/organ/internal/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm. Contains all neccessary tools."
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4"
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "utilitybelt")

/obj/item/organ/internal/cyberimp/arm/toolset/l
	parent_organ = "l_arm"

/obj/item/organ/internal/cyberimp/arm/toolset/emag_act(mob/user)
	if(!(locate(/obj/item/kitchen/knife/combat/cyborg) in items_list))
		to_chat(user, "<span class='notice'>You unlock [src]'s integrated knife!</span>")
		items_list += new /obj/item/kitchen/knife/combat/cyborg(src)
		return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal, and highly dangerous cybernetic implant that can project a deadly blade of concentrated enregy."
	contents = newlist(/obj/item/melee/energy/blade/hardlight)
	origin_tech = "materials=4;combat=5;biotech=3;powerstorage=2;syndicate=5"

/obj/item/organ/internal/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	contents = newlist(/obj/item/gun/medbeam)
	origin_tech = "materials=5;combat=2;biotech=5;powerstorage=4;syndicate=1"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/chronos.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "chronogun")

/obj/item/organ/internal/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm, that is able to be used as a powerful flash."
	contents = newlist(/obj/item/flash/armimplant)
	origin_tech = "materials=4;combat=3;biotech=4;magnets=4;powerstorage=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/device.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "flash")

/obj/item/organ/internal/cyberimp/arm/flash/New()
	..()
	if(locate(/obj/item/flash/armimplant) in items_list)
		var/obj/item/flash/armimplant/F = locate(/obj/item/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/internal/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	contents = newlist(/obj/item/borg/stun)
	origin_tech = "materials=3;combat=5;biotech=4;powerstorage=4;syndicate=3"

/obj/item/organ/internal/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm"
	contents = newlist(/obj/item/melee/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/flash/armimplant)
	origin_tech = "materials=5;combat=7;biotech=5;powerstorage=5;syndicate=6;programming=5"

/obj/item/organ/internal/cyberimp/arm/combat/New()
	..()
	if(locate(/obj/item/flash/armimplant) in items_list)
		var/obj/item/flash/armimplant/F = locate(/obj/item/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/internal/cyberimp/arm/combat/centcom
	name = "NT specops cybernetics implant"
	desc = "An extremely powerful cybernetic implant that contains combat and utility modules used by NT special forces."
	contents = newlist(/obj/item/gun/energy/pulse/pistol/m1911, /obj/item/door_remote/omni, /obj/item/melee/energy/blade/hardlight, /obj/item/reagent_containers/hypospray/combat/nanites, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/implanter/mindshield, /obj/item/flash/armimplant)
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "m1911"
	emp_proof = 1

/obj/item/organ/internal/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm"
	contents = newlist(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/bonesetter/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment, /obj/item/bonegel/augment, /obj/item/FixOVein/augment, /obj/item/surgicaldrill/augment)
	origin_tech = "materials=3;engineering=3;biotech=3;programming=2;magnets=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/storage.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "duffel-med")

/obj/item/organ/internal/cyberimp/arm/surgery/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

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
	if(H.get_int_organ(/obj/item/organ/internal/cell))
		if(A.emagged || A.stat & BROKEN)
			do_sparks(3, 1, A)
			to_chat(H, "<span class='warning'>The APC power currents surge erratically, damaging your chassis!</span>")
			H.adjustFireLoss(10,0)
		else if(A.cell && A.cell.charge > 0)
			if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
			else
				INVOKE_ASYNC(src, .proc/powerdraw_loop, A, H)
		else
			to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")
	else
		to_chat(user, "<span class='warning'>You lack a cell in which to store charge!</span>")

/obj/item/apc_powercord/proc/powerdraw_loop(obj/machinery/power/apc/A, mob/living/carbon/human/H)
	H.visible_message("<span class='notice'>[H] inserts a power connector into \the [A].</span>", "<span class='notice'>You begin to draw power from \the [A].</span>")
	while(do_after(H, 10, target = A))
		if(loc != H)
			to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
			break
		if(A.cell.charge == 0)
			to_chat(H, "<span class='warning'>\The [A] has no more charge.</span>")
			break
		A.charging = 1
		if(A.cell.charge >= 500)
			H.nutrition += 50
			A.cell.charge -= 500
			to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
		else
			H.nutrition += A.cell.charge/10
			A.cell.charge = 0
			to_chat(H, "<span class='notice'>You siphon off the last of \the [A]'s charge.</span>")
			break
		if(H.nutrition > NUTRITION_LEVEL_WELL_FED)
			to_chat(H, "<span class='notice'>You are now fully charged.</span>")
			break
	H.visible_message("<span class='notice'>[H] unplugs from \the [A].</span>", "<span class='notice'>You unplug from \the [A].</span>")

/obj/item/organ/internal/cyberimp/arm/telebaton
	name = "telebaton implant"
	desc = "Telescopic baton implant. Does what it says on the tin" // A better description

	contents = newlist(/obj/item/melee/classic_baton)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/items.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "baton")

/obj/item/organ/internal/cyberimp/arm/advmop
	name = "advanced mop implant"
	desc = "Advanced mop implant. Does what it says on the tin" // A better description

	contents = newlist(/obj/item/mop/advanced)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/janitor.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "advmop")
