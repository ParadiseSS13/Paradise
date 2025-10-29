/obj/item/organ/internal/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	parent_organ = "r_arm"
	slot = "r_arm_device"
	icon_state = "toolkit_generic"
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

	update_icon(UPDATE_ICON_STATE)
	slot = parent_organ + "_device"
	items_list = contents.Copy()

/obj/item/organ/internal/cyberimp/arm/update_icon_state()
	if(parent_organ == "r_arm")
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/arm/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is assembled in the [parent_organ == "r_arm" ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/internal/cyberimp/arm/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(parent_organ == "r_arm")
		parent_organ = "l_arm"
	else
		parent_organ = "r_arm"
	slot = parent_organ + "_device"
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [parent_organ == "r_arm" ? "right" : "left"] arm.</span>")
	update_icon(UPDATE_ICON_STATE)

/obj/item/organ/internal/cyberimp/arm/insert(mob/living/carbon/M, special, dont_remove_slot)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract_to_linked_implant))

/obj/item/organ/internal/cyberimp/arm/remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_MOB_WILLINGLY_DROP)
	Retract()
	. = ..()

/obj/item/organ/internal/cyberimp/arm/emag_act()
	return FALSE

/obj/item/organ/internal/cyberimp/arm/emp_act(severity)
	if(emp_proof)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>[src] is hit by EMP!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()
	..()

/obj/item/organ/internal/cyberimp/arm/proc/get_overlay_state(image_layer)
	return "[augment_icon][parent_organ == BODY_ZONE_L_ARM ? "_left" : "_right"]"

/obj/item/organ/internal/cyberimp/arm/render()
	. = ..()
	if(!.)
		return

	var/mutable_appearance/arm_overlay = mutable_appearance(
		icon = augment_state,
		icon_state = get_overlay_state(),
		layer = -INTORGAN_LAYER,
	)
	return arm_overlay

/obj/item/organ/internal/cyberimp/arm/extra_render()
	. = ..()
	if(!.)
		return
	var/mutable_appearance/hand_overlay = mutable_appearance(
		icon = augment_state,
		icon_state = "[get_overlay_state()]_hand",
		layer = -HAND_INTORGAN_LAYER,
	)
	return hand_overlay



/obj/item/organ/internal/cyberimp/arm/proc/retract_to_linked_implant()
	SIGNAL_HANDLER
	if(holder && holder == owner.get_active_hand())
		INVOKE_ASYNC(src, PROC_REF(retract_and_show_radial))

/obj/item/organ/internal/cyberimp/arm/proc/retract_and_show_radial()
	Retract()
	if(length(items_list) != 1)
		radial_menu(owner)

/obj/item/organ/internal/cyberimp/arm/proc/check_cuffs()
	if(owner.handcuffed)
		to_chat(owner, "<span class='warning'>The handcuffs interfere with [src]!</span>")
		return TRUE

/obj/item/organ/internal/cyberimp/arm/proc/Retract()
	if(!holder || (holder in src))
		return
	if(status & ORGAN_DEAD)
		return

	owner.visible_message("<span class='notice'>[owner] retracts [holder] back into [owner.p_their()] [parent_organ == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='notice'>[holder] snaps back into your [parent_organ == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")

	if(istype(holder, /obj/item/flash/armimplant))
		var/obj/item/flash/F = holder
		F.set_light(0)

	owner.transfer_item_to(holder, src, force = TRUE)
	holder = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/internal/cyberimp/arm/proc/Extend(obj/item/item)
	if(!(item in src) || check_cuffs())
		return
	if(status & ORGAN_DEAD)
		return

	holder = item

	holder.set_nodrop(TRUE, owner)
	holder.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder.slot_flags = null
	holder.w_class = WEIGHT_CLASS_HUGE
	holder.materials = null

	if(istype(holder, /obj/item/flash/armimplant))
		var/obj/item/flash/F = holder
		F.set_light(7)

	var/arm_slot = (parent_organ == "r_arm" ? ITEM_SLOT_RIGHT_HAND : ITEM_SLOT_LEFT_HAND)
	var/obj/item/arm_item = owner.get_item_by_slot(arm_slot)

	if(arm_item)
		if(istype(arm_item, /obj/item/offhand))
			var/obj/item/offhand_arm_item = owner.get_active_hand()
			to_chat(owner, "<span class='warning'>Your hands are too encumbered wielding [offhand_arm_item] to deploy [src]!</span>")
			return
		else if(!owner.drop_item_to_ground(arm_item))
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
	return TRUE

/obj/item/organ/internal/cyberimp/arm/ui_action_click()
	if(crit_fail || (!holder && !length(contents)) || status & ORGAN_DEAD)
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return

	// You can emag the arm-mounted implant by activating it while holding emag in it's hand.
	var/arm_slot = (parent_organ == "r_arm" ? ITEM_SLOT_RIGHT_HAND : ITEM_SLOT_LEFT_HAND)
	if(istype(owner.get_item_by_slot(arm_slot), /obj/item/card/emag) && emag_act(owner))
		return

	if(!holder || (holder in src))
		holder = null
		if(length(contents) == 1)
			Extend(contents[1])
		else
			radial_menu(owner)
	else
		Retract()

/obj/item/organ/internal/cyberimp/arm/proc/check_menu(mob/user)
	return (owner && owner == user && owner.stat != DEAD && (src in owner.internal_organs) && !holder)

/obj/item/organ/internal/cyberimp/arm/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/obj/I in items_list)
		choices["[I.name]"] = image(icon = I.icon, icon_state = I.icon_state)
	var/choice = show_radial_menu(user, user, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
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
		to_chat(owner, "<span class='userdanger'>You feel an explosion erupt inside your [parent_organ == "r_arm" ? "right" : "left"] arm as your implant misfires!</span>")
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		crit_fail = TRUE
		addtimer(VARSET_CALLBACK(src, crit_fail, FALSE), 60 SECONDS) //I would rather not have the weapon be permamently disabled, especially as there is no way to fix it.
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

/datum/action/item_action/organ_action/toggle/utility_belt
	button_icon = 'icons/obj/clothing/belts.dmi'
	button_icon_state = "utilitybelt"

/obj/item/organ/internal/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm. Contains all neccessary tools."
	icon_state = "toolkit_engineering"
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4"
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)
	actions_types = list(/datum/action/item_action/organ_action/toggle/utility_belt)
	augment_icon = "toolkit_engi"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/toolset/l
	parent_organ = "l_arm"

/obj/item/organ/internal/cyberimp/arm/toolset/emag_act(mob/user)
	if(!(locate(/obj/item/kitchen/knife/combat/cyborg) in items_list))
		to_chat(user, "<span class='notice'>You unlock [src]'s integrated knife!</span>")
		items_list += new /obj/item/kitchen/knife/combat/cyborg(src)
		return TRUE
	return FALSE

/datum/action/item_action/organ_action/toggle/abductor_belt
	button_icon = 'icons/obj/abductor.dmi'
	button_icon_state = "belt"

/obj/item/organ/internal/cyberimp/arm/toolset_abductor
	name = "alien toolset implant"
	desc = "An alien toolset, designed to be installed on subject's arm."
	icon_state = "toolkit_engineering"
	origin_tech = "materials=5;engineering=5;plasmatech=5;powerstorage=4;abductor=3"
	contents = newlist(/obj/item/screwdriver/abductor, /obj/item/wirecutters/abductor, /obj/item/crowbar/abductor, /obj/item/wrench/abductor, /obj/item/weldingtool/abductor, /obj/item/multitool/abductor)
	actions_types = list(/datum/action/item_action/organ_action/toggle/abductor_belt)
	augment_icon = "toolkit_engi"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/toolset_abductor/l
	parent_organ = "l_arm"

/datum/action/item_action/organ_action/toggle/abductor_janibelt
	button_icon = 'icons/obj/abductor.dmi'
	button_icon_state = "janibelt_abductor"

/obj/item/organ/internal/cyberimp/arm/janitorial_abductor
	name = "alien janitorial toolset implant"
	desc = "A set of alien janitorial tools, designed to be installed on subject's arm."
	icon_state = "toolkit_janitor"
	origin_tech = "materials=5;engineering=5;biotech=5;powerstorage=4;abductor=2"
	contents = newlist(/obj/item/mop/advanced/abductor, /obj/item/soap/syndie/abductor, /obj/item/lightreplacer/bluespace/abductor, /obj/item/holosign_creator/janitor, /obj/item/melee/flyswatter/abductor, /obj/item/reagent_containers/spray/cleaner/safety/abductor)
	actions_types = list(/datum/action/item_action/organ_action/toggle/abductor_belt)
	augment_icon = "toolkit_jani"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/janitorial_abductor/l
	parent_organ = "l_arm"

/obj/item/organ/internal/cyberimp/arm/surgical_abductor
	name = "alien surgical toolset implant"
	desc = "An alien surgical toolset, designed to be installed on the subject's arm."
	icon_state = "toolkit_surgical"
	origin_tech = "materials=5;engineering=5;plasmatech=5;powerstorage=4;abductor=2"
	contents = newlist(/obj/item/retractor/alien, /obj/item/hemostat/alien, /obj/item/bonesetter/alien, /obj/item/scalpel/laser/alien, /obj/item/circular_saw/alien, /obj/item/bonegel/alien, /obj/item/fix_o_vein/alien, /obj/item/surgicaldrill/alien)
	actions_types = list(/datum/action/item_action/organ_action/toggle/abductor_belt)
	augment_icon = "toolkit_med"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/surgical_abductor/l
	parent_organ = "l_arm"

/obj/item/organ/internal/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal, and highly dangerous cybernetic implant that can project a deadly blade of concentrated enregy."
	contents = newlist(/obj/item/melee/energy/blade/hardlight)
	origin_tech = "materials=4;combat=5;biotech=3;powerstorage=2;syndicate=5"

/datum/action/item_action/organ_action/toggle/medibeam
	button_icon = 'icons/obj/chronos.dmi'
	button_icon_state = "chronogun"

/obj/item/organ/internal/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	contents = newlist(/obj/item/gun/medbeam)
	icon_state = "toolkit_surgical"
	origin_tech = "materials=5;combat=2;biotech=5;powerstorage=4;syndicate=1"
	actions_types = list(/datum/action/item_action/organ_action/toggle/medibeam)
	augment_icon = "toolkit_med"
	do_extra_render = TRUE

/datum/action/item_action/organ_action/toggle/flash
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "flash"

/obj/item/organ/internal/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm, that is able to be used as a powerful flash."
	contents = newlist(/obj/item/flash/armimplant)
	origin_tech = "materials=4;combat=3;biotech=4;magnets=4;powerstorage=3"
	actions_types = list(/datum/action/item_action/organ_action/toggle/flash)
	augment_icon = "toolkit"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/flash/New()
	..()
	if(locate(/obj/item/flash/armimplant) in items_list)
		var/obj/item/flash/armimplant/F = locate(/obj/item/flash/armimplant) in items_list
		F.implant = src

/obj/item/organ/internal/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	contents = newlist(/obj/item/borg/stun)
	origin_tech = "materials=3;combat=5;biotech=4;powerstorage=4;syndicate=3"
	augment_icon = "toolkit"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	contents = newlist(/obj/item/melee/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/flash/armimplant)
	origin_tech = "materials=5;combat=7;biotech=5;powerstorage=5;syndicate=6;programming=5"
	stealth_level = 4 //Only surgery or a body scanner with the highest tier of stock parts can detect this.

/obj/item/organ/internal/cyberimp/arm/combat/New()
	..()
	if(locate(/obj/item/flash/armimplant) in items_list)
		var/obj/item/flash/armimplant/F = locate(/obj/item/flash/armimplant) in items_list
		F.implant = src

/obj/item/organ/internal/cyberimp/arm/combat/centcom
	name = "NT specops cybernetics implant"
	desc = "An extremely powerful cybernetic implant that contains combat and utility modules used by NT special forces."
	contents = newlist(/obj/item/gun/energy/pulse/pistol/m1911, /obj/item/door_remote/omni, /obj/item/melee/energy/blade/hardlight, /obj/item/reagent_containers/hypospray/combat/nanites, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/bio_chip_implanter/mindshield, /obj/item/flash/armimplant)
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "m1911"
	emp_proof = 1

/datum/action/item_action/organ_action/toggle/dufflebag_med
	button_icon = 'icons/obj/storage.dmi'
	button_icon_state = "duffel-med"

/obj/item/organ/internal/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_surgical"
	contents = newlist(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/bonesetter/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment, /obj/item/bonegel/augment, /obj/item/fix_o_vein/augment, /obj/item/surgicaldrill/augment)
	origin_tech = "materials=3;engineering=3;biotech=3;programming=2;magnets=3"
	actions_types = list(/datum/action/item_action/organ_action/toggle/dufflebag_med)
	augment_icon = "toolkit_med"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/surgery/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

/datum/action/item_action/organ_action/toggle/janibelt
	button_icon = 'icons/obj/clothing/belts.dmi'
	button_icon_state = "janibelt"

/obj/item/organ/internal/cyberimp/arm/janitorial
	name = "janitorial toolset implant"
	desc = "A set of janitorial tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_janitor"
	contents = newlist(/obj/item/mop/advanced, /obj/item/soap, /obj/item/lightreplacer, /obj/item/holosign_creator/janitor, /obj/item/melee/flyswatter, /obj/item/reagent_containers/spray/cleaner/safety)
	origin_tech = "materials=3;engineering=4;biotech=3"
	actions_types = list(/datum/action/item_action/organ_action/toggle/janibelt)
	augment_icon = "toolkit_jani"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/janitorial/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

/// ERT implant, i dont overly expect this to get into the hands of crew
/obj/item/organ/internal/cyberimp/arm/janitorial/advanced
	name = "advanced janitorial toolset implant"
	desc = "A set of advanced janitorial tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/mop/advanced, /obj/item/soap/deluxe, /obj/item/lightreplacer/bluespace, /obj/item/holosign_creator/janitor, /obj/item/melee/flyswatter, /obj/item/reagent_containers/spray/cleaner/advanced)
	origin_tech = "materials=5;engineering=6;biotech=5"
	actions_types = list(/datum/action/item_action/organ_action/toggle/janibelt)
	emp_proof = TRUE

/// its for ERT, but still probably a good idea.
/obj/item/organ/internal/cyberimp/arm/janitorial/advanced/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

/datum/action/item_action/organ_action/toggle/botanybelt
	button_icon = 'icons/obj/clothing/belts.dmi'
	button_icon_state = "botanybelt"

/obj/item/organ/internal/cyberimp/arm/botanical
	name = "botanical toolset implant"
	desc = "A set of botanical tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_hydro"
	contents = newlist(/obj/item/plant_analyzer, /obj/item/cultivator, /obj/item/hatchet, /obj/item/shovel/spade, /obj/item/reagent_containers/spray/weedspray, /obj/item/reagent_containers/spray/pestspray)
	origin_tech = "materials=3;engineering=4;biotech=3"
	actions_types = list(/datum/action/item_action/organ_action/toggle/botanybelt)
	augment_icon = "toolkit_hydro"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/botanical/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

// lets make IPCs even *more* vulnerable to EMPs!
/obj/item/organ/internal/cyberimp/arm/power_cord
	name = "APC-compatible power adapter implant"
	desc = "An implant commonly installed inside IPCs in order to allow them to easily collect energy from their environment."
	icon_state = "toolkit_ipc"
	origin_tech = "materials=3;biotech=2;powerstorage=3"
	contents = newlist(/obj/item/apc_powercord)
	requires_robotic_bodypart = TRUE

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
	var/drawing_power = FALSE

/obj/item/apc_powercord/afterattack__legacy__attackchain(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !ishuman(user) || !proximity_flag)
		return ..()
	if(drawing_power)
		to_chat(user, "<span class='warning'>You're already charging.</span>")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/machinery/power/apc/A = target
	var/mob/living/carbon/human/H = user
	var/datum/organ/battery/power_source = H.get_int_organ_datum(ORGAN_DATUM_BATTERY)
	if(istype(power_source))
		if(A.emagged || A.stat & BROKEN)
			do_sparks(3, 1, A)
			to_chat(H, "<span class='warning'>The APC power currents surge erratically, damaging your chassis!</span>")
			H.adjustFireLoss(10,0)
		else if(A.cell && A.cell.charge > 0)
			if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
			else
				INVOKE_ASYNC(src, PROC_REF(powerdraw_loop), A, H)
		else
			to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")
	else
		to_chat(user, "<span class='warning'>You lack a power source in which to store charge!</span>")

/obj/item/apc_powercord/proc/powerdraw_loop(obj/machinery/power/apc/A, mob/living/carbon/human/H)
	H.visible_message("<span class='notice'>[H] inserts a power connector into \the [A].</span>", "<span class='notice'>You begin to draw power from \the [A].</span>")
	drawing_power = TRUE
	while(do_after(H, 10, target = A))
		if(loc != H)
			to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
			break
		if(A.cell.charge == 0)
			to_chat(H, "<span class='warning'>\The [A] has no more charge.</span>")
			break
		A.charging = APC_IS_CHARGING
		if(A.cell.charge >= 500)
			H.adjust_nutrition(50)
			A.cell.charge -= 500
			to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
		else
			H.adjust_nutrition(A.cell.charge * 0.1)
			A.cell.charge = 0
			to_chat(H, "<span class='notice'>You siphon off the last of \the [A]'s charge.</span>")
			break
		if(H.nutrition > NUTRITION_LEVEL_WELL_FED)
			to_chat(H, "<span class='notice'>You are now fully charged.</span>")
			break
	H.visible_message("<span class='notice'>[H] unplugs from \the [A].</span>", "<span class='notice'>You unplug from \the [A].</span>")
	drawing_power = FALSE

/datum/action/item_action/organ_action/toggle/telebaton
	button_icon = 'icons/obj/items.dmi'
	button_icon_state = "baton"

/obj/item/organ/internal/cyberimp/arm/telebaton
	name = "telebaton implant"
	desc = "Telescopic baton implant. Does what it says on the tin" // A better description

	contents = newlist(/obj/item/melee/classic_baton)
	actions_types = list(/datum/action/item_action/organ_action/toggle/telebaton)
	augment_icon = "toolkit"
	do_extra_render = TRUE

/datum/action/item_action/organ_action/toggle/advanced_mop
	button_icon = 'icons/obj/janitor.dmi'
	button_icon_state = "advmop"

/obj/item/organ/internal/cyberimp/arm/advmop
	name = "advanced mop implant"
	desc = "Advanced mop implant. Does what it says on the tin" // A better description
	icon_state = "toolkit_janitor"

	contents = newlist(/obj/item/mop/advanced)
	actions_types = list(/datum/action/item_action/organ_action/toggle/advanced_mop)
	augment_icon = "toolkit_jani"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/cargo
	name = "integrated cargo implant"
	desc = "Everything you need to run the cargo bay, except a Forklift."
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4"
	icon_state = "toolkit_cargo"
	contents = newlist(
		/obj/item/stamp/granted,
		/obj/item/stamp/denied,
		/obj/item/hand_labeler,
		/obj/item/dest_tagger,
		/obj/item/clipboard,
		/obj/item/pen/multi,
		/obj/item/mail_scanner
	)
	actions_types = list(/datum/action/item_action/organ_action/toggle/stamp)

/datum/action/item_action/organ_action/toggle/stamp
	button_icon = 'icons/obj/bureaucracy.dmi'
	button_icon_state = "stamp-ok"

// Razorwire implant, long reach whip made of extremely thin wire, ouch!

/obj/item/melee/razorwire
	name = "implanted razorwire"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble; \
		even from a few steps away. However, results against anything more durable will heavily vary."
	icon = 'icons/obj/weapons/energy_melee.dmi'
	icon_state = "razorwire"
	righthand_file = 'icons/mob/inhands/implants_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/implants_lefthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	sharp = TRUE
	force = 18
	armor_penetration_percentage = -100 //This means that armor twice as effective against it
	reach = 2
	hitsound = 'sound/weapons/whip.ogg'
	attack_verb = list("slashes", "whips", "lashes", "lacerates")
	///List of skins for the razorwire.
	var/list/razorwire_skin_options = list()

/obj/item/melee/razorwire/Initialize(mapload)
	. = ..()
	var/random_colour = pick("razorwire", "razorwire_teal", "razorwire_yellow", "razorwire_purple", "razorwire_green")
	icon_state = random_colour
	update_icon()
	razorwire_skin_options["Reliable Red"] = "razorwire"
	razorwire_skin_options["Troubling Teal"] = "razorwire_teal"
	razorwire_skin_options["Yearning Yellow"] = "razorwire_yellow"
	razorwire_skin_options["Plasma Purple"] = "razorwire_purple"
	razorwire_skin_options["Great Green"] = "razorwire_green"

/obj/item/melee/razorwire/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click it to reskin it.</span>"

/obj/item/melee/razorwire/examine_more(mob/user)
	. = ..()
	. += "<i>A byproduct of Cybersun Incorporated's mistakes turned concept, the Razorwire Spool is a remarkable accident in itself. \
	It consists of a fine, thread-like laser capable of being manipulated and swung like a whip. Designed for ease of deployment, the wire originates from the wrist, \
	allowing users with the implant to perform wide swings and precise cuts against soft targets. It's the same energy found in other common energy weapons, such as swords and daggers.</i>"
	. += "<i>Cybersun's investment into energy weapon development inadvertently led to the Razorwire Spool. Initially attempting to create an Energy Sword, \
	they ended up with a material that, while superheated and correctly composed, failed to maintain a solid blade shape. Curious about this error, \
	Cybersun repeated the process, producing an energy as thin as a wire. After several prototypes, they achieved a long, energy-like thread. \
	Further innovation allowed them to conceal this in a forearm-sized container, \
	with a hand and wrist replacement made of the same durable material used to contain energy weapons. They would call it, the Razorwire.</i>"
	. += "<i>Favored by assassins for their stealth and efficiency, Cybersun exercises discretion in its distribution, favoring clients in their good graces. \
	It falls behind other energy weapons due to its thinner and more loose pressure, however it is praised more as a side-arm for unarmored soft targets.</i>"

/obj/item/melee/razorwire/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(loc == user)
		reskin(user)

/obj/item/melee/razorwire/proc/reskin(mob/M)
	var/list/skins = list()
	for(var/I in razorwire_skin_options)
		skins[I] = image(icon, icon_state = razorwire_skin_options[I])
	var/choice = show_radial_menu(M, src, skins, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), M), require_near = TRUE)

	if(choice && reskin_radial_check(M))
		icon_state = razorwire_skin_options[choice]
		update_icon()
		M.update_inv_r_hand()
		M.update_inv_l_hand()

/obj/item/melee/razorwire/proc/reskin_radial_check(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!src || !H.is_in_hands(src) || HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
		return FALSE
	return TRUE

/datum/action/item_action/organ_action/toggle/razorwire
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "razorwire"

/obj/item/organ/internal/cyberimp/arm/razorwire
	name = "razorwire spool implant"
	desc = "An integrated spool of razorwire, capable of being used as a weapon when whipped at your foes. \
		Built into the back of your hand, try your best to not get it tangled."
	contents = newlist(/obj/item/melee/razorwire)
	icon_state = "razorwire"
	actions_types = list(/datum/action/item_action/organ_action/toggle/razorwire)
	origin_tech = "combat=5;biotech=5;syndicate=2"
	stealth_level = 1 // Hidden from health analyzers
	augment_icon = "razor" // Note: By default the autosurgeons apply the highest level of cover plating.
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/razorwire/examine_more(mob/user)
	. = ..()
	for(var/obj/I in contents)
		return I.examine_more()

// Shell launch system, an arm mounted single-shot shotgun that comes out of your arm

/obj/item/gun/projectile/revolver/doublebarrel/shell_launcher
	name = "shell launch system"
	desc = "A mounted cannon seated comfortably in a forearm compartment. This humanitarian device is capable of firing essentially any shotgun shell."
	icon_state = "shell_cannon"
	righthand_file = 'icons/mob/inhands/implants_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/implants_lefthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	weapon_weight = WEAPON_LIGHT
	mag_type = /obj/item/ammo_box/magazine/internal/shot/shell_cannon
	unique_reskin = FALSE
	can_sawoff = FALSE

/obj/item/gun/projectile/revolver/doublebarrel/shell_launcher/proc/missfire(mob/living/carbon/human/H, our_organ)
	to_chat(H, "<span class='warning'>Your [name] misfires!</span>")
	process_fire(H, H, 1, zone_override = our_organ)

/obj/item/gun/projectile/revolver/doublebarrel/shell_launcher/examine_more(mob/user)
	. = ..()
	. += "<i>A Shellguard Munitions classic, the Shellguard Launch System (SLS) was originally a MODsuit heavy weapons accessory, \
	later being developed into a forearm-mounted tactical shotgun implant. Though its compact design precludes the use of large ammunition like rockets or burning plasma, \
	it excels in firing a variety of smaller shells, both energy and kinetic, thanks to its advanced plasma alloy barrel.<i>"
	. += "<i>Adapting an accessory intended for a mechanical suit's gauntlet posed significant hurdles, \
	primarily in miniaturizing the barrel and components without sacrificing performance. The limitations initially damaged its perception of the market. \
	However, executives would later pivot their niche to concealed carry and versatile shell ammunition, \
	focusing on deployability and concealment through neural activation. \
	The shift in approach would lead to the SLS being advertised as a powerful and compact holdout weapon, easily concealable and reliably lethal.<i>"
	. += "<i>Despite its initial issues, the SLS today holds a strong following in the implant market, being highly sought after among assassins, \
	mercenaries, and firearm enthusiasts. Its appeal lies not just in its stealth but also in its compatibility with Shellguard's range of modular products, \
	and the potential beyond its advertised capabilities.</i>"

/obj/item/ammo_box/magazine/internal/shot/shell_cannon
	name = "shell launch system internal magazine"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 1

/datum/action/item_action/organ_action/toggle/shell_cannon
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "shell_cannon"

/obj/item/organ/internal/cyberimp/arm/shell_launcher
	name = "shell launch system implant"
	desc = "A mounted, single-shot housing for a shell launch cannon; capable of firing twelve-gauge shotgun shells."
	contents = newlist(/obj/item/gun/projectile/revolver/doublebarrel/shell_launcher)
	icon_state = "shell_cannon"
	actions_types = list(/datum/action/item_action/organ_action/toggle/shell_cannon)
	augment_icon = "razor"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/shell_launcher/emp_act(severity)
	if(!owner)
		return
	if(emp_proof)
		return
	Retract()
	for(var/obj/item/gun/projectile/revolver/doublebarrel/shell_launcher/SL in contents)
		if(SL.chambered)
			if(!SL.chambered.BB)//found a spent ammo
				return

			if(istype(SL.chambered, /obj/item/ammo_casing/shotgun/ion))
				emp_proof = TRUE //This kills the server without it. Do not remove this.
				SL.missfire(owner, parent_organ)
				emp_proof = FALSE
				to_chat(owner, "<span class='warning'>The misfired [SL.chambered] causes your [name] to break!</span>")
				necrotize()
				return
			if(istype(SL.chambered, /obj/item/ammo_casing/shotgun/frag12))
				SL.missfire(owner, parent_organ)
				var/obj/item/organ/external/probable_organ = owner.get_limb_by_name(parent_organ)
				if(probable_organ) //In case it gets popped off by the damage
					probable_organ.droplimb(FALSE, DROPLIMB_BLUNT)
				return
			if(istype(SL.chambered, /obj/item/ammo_casing/shotgun/pulseslug))
				SL.missfire(owner, parent_organ)
				var/obj/item/organ/external/probable_organ = owner.get_limb_by_name(parent_organ)
				if(probable_organ) //In case it gets popped off by the damage
					probable_organ.droplimb(FALSE, DROPLIMB_BURN)
				return
			SL.chambered.BB.damage *= 2 //Stronger since it is inside you
			SL.missfire(owner, parent_organ)

/obj/item/organ/internal/cyberimp/arm/shell_launcher/examine_more(mob/user)
	. = ..()
	. += "<i>A Shellguard Munitions classic, the Shellguard Launch System (SLS) was originally a MODsuit heavy weapons accessory, \
	later being developed into a forearm-mounted tactical shotgun implant. Though its compact design precludes the use of large ammunition like rockets or burning plasma, \
	it excels in firing a variety of smaller shells, both energy and kinetic, thanks to its advanced plasma alloy barrel.<i>"
	. += "<i>Adapting an accessory intended for a mechanical suit's gauntlet posed significant hurdles, \
	primarily in miniaturizing the barrel and components without sacrificing performance. The limitations initially damaged its perception of the market. \
	However, executives would later pivot their niche to concealed carry and versatile shell ammunition, \
	focusing on deployability and concealment through neural activation. \
	The shift in approach would lead to the SLS being advertised as a powerful and compact holdout weapon, easily concealable and reliably lethal.<i>"
	. += "<i>Despite its initial issues, the SLS today holds a strong following in the implant market, being highly sought after among assassins, \
	mercenaries, and firearm enthusiasts. Its appeal lies not just in its stealth but also in its compatibility with Shellguard's range of modular products, \
	and the potential beyond its advertised capabilities.</i>"

/datum/action/item_action/organ_action/toggle/v1_arm
	button_icon = 'icons/obj/items.dmi'
	button_icon_state = "v1_arm"

/obj/item/organ/internal/cyberimp/arm/v1_arm
	name = "vortex feedback arm implant"
	desc = "An implant, that when deployed surrounds the users arm in armor and circuitry, allowing them to redirect nearby projectiles with feedback from the vortex anomaly core."
	origin_tech = "combat=6;magnets=6;biotech=6;engineering=6"
	icon = 'icons/obj/items.dmi'
	icon_state = "v1_arm"
	parent_organ = "l_arm" //Left arm by default
	slot = "l_arm_device"

	contents = newlist(/obj/item/shield/v1_arm)
	actions_types = list(/datum/action/item_action/organ_action/toggle/v1_arm)
	augment_icon = "v1_arm"
	do_extra_render = TRUE
	var/disabled = FALSE

/obj/item/organ/internal/cyberimp/arm/v1_arm/emp_act(severity)
	if(emp_proof && !disabled)
		return
	disabled = TRUE
	addtimer(VARSET_CALLBACK(src, disabled, FALSE), 10 SECONDS)

/obj/item/organ/internal/cyberimp/arm/v1_arm/Extend(obj/item/item)
	if(disabled)
		to_chat(owner, "<span class='warning'>Your arm fails to extend!</span>")
		return FALSE
	..()

/obj/item/organ/internal/cyberimp/arm/v1_arm/Retract()
	if(disabled)
		to_chat(owner, "<span class='warning'>Your arm fails to retract!</span>")
		return FALSE
	..()

/obj/item/organ/internal/cyberimp/arm/v1_arm/render()
	if(isvox(owner))
		augment_icon = "v1_arm_vox"
	else if(isdrask(owner))
		augment_icon = "v1_arm_drask"
	else
		augment_icon = "v1_arm"
	return ..()

/obj/item/shield/v1_arm
	name = "vortex feedback arm"
	desc = "A modification to a users arm, allowing them to use a vortex core energy feedback, to parry, reflect, and even empower projectile attacks. Rumors that it runs on the user's blood are unconfirmed."
	icon_state = "v1_arm"
	icon = 'icons/obj/items.dmi'
	sprite_sheets_inhand = list("Drask" = 'icons/mob/clothing/species/drask/held.dmi', "Vox" = 'icons/mob/clothing/species/vox/held.dmi')
	force = 20 //bonk, not sharp
	attack_verb = list("slamed", "punched", "parried", "judged", "styled on", "disrespected", "interrupted", "gored")
	hitsound = 'sound/effects/bang.ogg'
	light_power = 3
	light_color = "#9933ff"
	hit_reaction_chance = -1
	flags = ABSTRACT
	/// The damage the reflected projectile will be increased by
	var/reflect_damage_boost = 10
	/// The cap of the reflected damage. Damage will not be increased above 50, however it will not be reduced to 50 either.
	var/reflect_damage_cap = 50
	var/disabled = FALSE
	var/force_when_disabled = 5 //still basically a metal pipe, just hard to move

/obj/item/shield/v1_arm/customised_abstract_text(mob/living/carbon/owner)
	return "<span class='warning'>[owner.p_their(TRUE)] [owner.l_hand == src ? "left arm" : "right arm"] is covered in metal.</span>"

/obj/item/shield/v1_arm/emp_act(severity)
	if(disabled)
		return
	to_chat(loc, "<span class='warning'>Your arm seises up!</span>")
	disabled = TRUE
	force = force_when_disabled
	addtimer(CALLBACK(src, PROC_REF(reboot)), 10 SECONDS)

/obj/item/shield/v1_arm/proc/reboot()
	disabled = FALSE
	force = initial(force)

/obj/item/shield/v1_arm/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.35, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _no_parry_sound = TRUE) // 0.3333 seconds of cooldown for 75% uptime, countered by ions and plasma pistols

/obj/item/shield/v1_arm/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(disabled)
		return FALSE
	// Hit by a melee weapon or blocked a projectile
	. = ..()
	if(!.) // they did not block the attack
		return
	if(. == 1) // a normal block
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
		playsound(src, 'sound/weapons/effects/ric3.ogg', 100, TRUE)
		return TRUE

	set_light(3)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 0.25 SECONDS)

	if(isprojectile(hitby))
		var/obj/item/projectile/P = hitby
		if(P.shield_buster || istype(P, /obj/item/projectile/ion)) //EMP's and unpariable attacks, after all.
			return FALSE
		if(P.reflectability == REFLECTABILITY_NEVER) //only 1 magic spell does this, but hey, needed
			owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
			playsound(src, 'sound/weapons/effects/ric3.ogg', 100, TRUE)
			return TRUE

		P.damage = clamp((P.damage + 10), P.damage, reflect_damage_cap)
		var/sound = pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg', 'sound/effects/meteorimpact.ogg')
		P.hitsound = sound
		P.hitsound_wall = sound
		P.add_overlay("parry")
		playsound(src, 'sound/weapons/v1_parry.ogg', 100, TRUE)
		owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
		add_attack_logs(P.firer, src, "hit by [P.type] but got parried by [src]")
		return -1

	owner.visible_message("<span class='danger'>[owner] parries [attack_text] with [src]!</span>")
	playsound(src, 'sound/weapons/v1_parry.ogg', 100, TRUE)
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		if(!isitem(hitby))
			return TRUE
		var/obj/item/TT = hitby
		addtimer(CALLBACK(TT, TYPE_PROC_REF(/atom/movable, throw_at), locateUID(TT.thrownby), 10, 4, owner), 0.2 SECONDS) //Timer set to 0.2 seconds to ensure item finshes the throwing to prevent double embeds
		return TRUE
	if(isitem(hitby))
		melee_attack_chain(owner, hitby.loc)
	else
		melee_attack_chain(owner, hitby)
	return TRUE

/obj/item/v1_arm_shell
	name = "vortex feedback arm implant frame"
	desc = "An implant awaiting installation of a vortex anomaly core."
	icon_state = "v1_arm"

/obj/item/v1_arm_shell/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/assembly/signaler/anomaly/vortex))
		to_chat(user, "<span class='notice'>You insert [I] into the back of the hand, and the implant begins to boot up.</span>")
		new /obj/item/organ/internal/cyberimp/arm/v1_arm(get_turf(src))
		qdel(src)
		qdel(I)
	return ..()

/obj/item/organ/internal/cyberimp/arm/muscle
	name = "strong-arm empowered musculature implant"
	desc = "When implanted, this cybernetic implant will enhance the muscles of the arm to deliver more power-per-action. Only has to be installed in one arm."
	icon_state = "muscle_imp"

	parent_organ = "l_arm" //Left arm by default
	slot = "l_arm_device"

	actions_types = list()
	augment_icon = "strongarm"
	var/datum/martial_art/muscle_implant/muscle_implant

/obj/item/organ/internal/cyberimp/arm/muscle/Initialize(mapload)
	. = ..()
	muscle_implant = new()

/obj/item/organ/internal/cyberimp/arm/muscle/insert(mob/living/carbon/M, special, dont_remove_slot)
	. = ..()
	muscle_implant.teach(M, TRUE)

/obj/item/organ/internal/cyberimp/arm/muscle/remove(mob/living/carbon/M, special)
	. = ..()
	muscle_implant.remove(M)

/obj/item/organ/internal/cyberimp/arm/muscle/emp_act(severity)
	. = ..()
	if(emp_proof)
		return
	muscle_implant.emp_act(severity, owner)

// Mantis blades

/obj/item/melee/mantis_blade
	name = "mantis blade"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action. \
	When both blades are equipped, they enable the user to perform double attacks."
	lefthand_file = 'icons/mob/inhands/implants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/implants_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	new_attack_chain = TRUE
	var/double_attack = TRUE
	var/double_attack_cd = 1.5 // seconds, so every second attack
	sharp = TRUE
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "lacerated", "ripped", "diced", "cut")

/obj/item/melee/mantis_blade/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_LEFT_HAND)
		transform = matrix(-1, 0, 0, 0, 1, 0)
	else
		transform = null

// make double attack if blades in both hands and not on CD
/obj/item/melee/mantis_blade/attack(mob/living/target, mob/living/user, params)
	var/obj/item/melee/mantis_blade/secondblade = user.get_inactive_hand()
	if(!istype(secondblade, /obj/item/melee/mantis_blade) || !double_attack)
		return ..()

	double_attack(target, user, params, secondblade)
	return FINISH_ATTACK

/obj/item/melee/mantis_blade/proc/double_attack(mob/living/target, mob/living/user, params, obj/item/melee/mantis_blade/secondblade)
	// first attack
	single_attack(target, user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	// second attack
	addtimer(CALLBACK(secondblade, PROC_REF(single_attack), target, user, params), 0.2 SECONDS) // not instant second attack

/obj/item/melee/mantis_blade/proc/single_attack(mob/living/target, mob/living/user, params)
	if(QDELETED(src))
		return
	double_attack = FALSE
	attack(target, user, params)
	addtimer(VARSET_CALLBACK(src, double_attack, TRUE), double_attack_cd SECONDS)

/obj/item/melee/mantis_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/forces_doors_open/mantis)

/obj/item/melee/mantis_blade/syndicate
	name = "'Naginata' mantis blade"
	icon_state = "syndie_mantis"
	force = 15
	armor_penetration_percentage = 30

/obj/item/melee/mantis_blade/syndicate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.35, _parryable_attack_types = NON_PROJECTILE_ATTACKS, _parry_cooldown = (4 / 3) SECONDS) // 0.3333 seconds of cooldown for 75% uptime, non projectile

/obj/item/melee/mantis_blade/nt
	name = "'Scylla' mantis blade"
	icon_state = "mantis"
	force = 12

/obj/item/melee/mantis_blade/nt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.35, _parryable_attack_types = NON_PROJECTILE_ATTACKS, _parry_cooldown = (5 / 3) SECONDS) // 0.666667 seconds for 60% uptime, non projectile

//  Mantis blades implants
/obj/item/organ/internal/cyberimp/arm/syndie_mantis
	name = "'Naginata' mantis blade implants"
	desc = "A powerful and concealable mantis blade with a monomolecular edge, produced by Cybersun Industries. Cuts through flesh and armor alike with ease."
	origin_tech = "materials=5;combat=5;biotech=5;syndicate=4"
	contents = newlist(/obj/item/melee/mantis_blade/syndicate)
	icon_state = "syndie_mantis"
	icon = 'icons/obj/weapons/melee.dmi'
	augment_icon = "razor"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/syndie_mantis/l
	parent_organ = "l_arm"

/obj/item/organ/internal/cyberimp/arm/nt_mantis
	name = "'Scylla' mantis blade implant"
	desc = "A reverse-engineered mantis blade design produced by Nanotrasen. While still quite deadly, the loss of the monomolecular blade has drastically reduced its armor penetration capability."
	origin_tech = "materials=5;combat=5;biotech=5;syndicate=4"
	contents = newlist(/obj/item/melee/mantis_blade/nt)
	icon_state = "mantis"
	icon = 'icons/obj/weapons/melee.dmi'
	augment_icon = "razor"
	do_extra_render = TRUE

/obj/item/organ/internal/cyberimp/arm/nt_mantis/l
	parent_organ = "l_arm"
