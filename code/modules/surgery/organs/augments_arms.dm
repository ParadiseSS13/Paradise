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
	. += "<span class='info'>[src] is assembled in the [parent_organ == "r_arm" ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>"

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
	if(!holder || (holder in src) || check_cuffs())
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

/obj/item/organ/internal/cyberimp/arm/proc/Extend(obj/item/item)
	if(!(item in src) || check_cuffs())
		return

	holder = item

	holder.flags |= NODROP
	holder.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder.slot_flags = null
	holder.w_class = WEIGHT_CLASS_HUGE
	holder.materials = null

	if(istype(holder, /obj/item/flash/armimplant))
		var/obj/item/flash/F = holder
		F.set_light(7)

	var/arm_slot = (parent_organ == "r_arm" ? SLOT_HUD_RIGHT_HAND : SLOT_HUD_LEFT_HAND)
	var/obj/item/arm_item = owner.get_item_by_slot(arm_slot)

	if(arm_item)
		if(istype(arm_item, /obj/item/offhand))
			var/obj/item/offhand_arm_item = owner.get_active_hand()
			to_chat(owner, "<span class='warning'>Your hands are too encumbered wielding [offhand_arm_item] to deploy [src]!</span>")
			return
		else if(!owner.unEquip(arm_item))
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
	var/arm_slot = (parent_organ == "r_arm" ? SLOT_HUD_RIGHT_HAND : SLOT_HUD_LEFT_HAND)
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

/obj/item/organ/internal/cyberimp/arm/proc/check_menu(mob/user)
	return (owner && owner == user && owner.stat != DEAD && (src in owner.internal_organs) && !holder)

/obj/item/organ/internal/cyberimp/arm/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/obj/I in items_list)
		choices["[I.name]"] = image(icon = I.icon, icon_state = I.icon_state)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
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

/obj/item/organ/internal/cyberimp/arm/toolset_abductor
	name = "Alien Toolset implant"
	desc = "An alien toolset, designed to be installed on subject's arm."
	origin_tech = "materials=5;engineering=5;plasmatech=5;powerstorage=4;abductor=3"
	contents = newlist(/obj/item/screwdriver/abductor, /obj/item/wirecutters/abductor, /obj/item/crowbar/abductor, /obj/item/wrench/abductor, /obj/item/weldingtool/abductor, /obj/item/multitool/abductor)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/abductor.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "belt")

/obj/item/organ/internal/cyberimp/arm/toolset_abductor/l
	parent_organ = "l_arm"

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
		F.implant = src

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
		F.implant = src

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

/obj/item/organ/internal/cyberimp/arm/janitorial
	name = "janitorial toolset implant"
	desc = "A set of janitorial tools hidden behind a concealed panel on the user's arm"
	contents = newlist(/obj/item/mop/advanced, /obj/item/soap, /obj/item/lightreplacer, /obj/item/holosign_creator/janitor, /obj/item/melee/flyswatter, /obj/item/reagent_containers/spray/cleaner/safety)
	origin_tech = "materials=3;engineering=4;biotech=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "janibelt")

/obj/item/organ/internal/cyberimp/arm/janitorial/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

/obj/item/organ/internal/cyberimp/arm/janitorial/advanced /// ERT implant, i dont overly expect this to get into the hands of crew
	name = "advanced janitorial toolset implant"
	desc = "A set of advanced janitorial tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/mop/advanced, /obj/item/soap/deluxe, /obj/item/lightreplacer/bluespace, /obj/item/holosign_creator/janitor, /obj/item/melee/flyswatter, /obj/item/reagent_containers/spray/cleaner/advanced)
	origin_tech = "materials=5;engineering=6;biotech=5"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "janibelt")
	emp_proof = TRUE

/obj/item/organ/internal/cyberimp/arm/janitorial/advanced/l /// its for ERT, but still probably a good idea.
	parent_organ = "l_arm"
	slot = "l_arm_device"

/obj/item/organ/internal/cyberimp/arm/botanical
	name = "botanical toolset implant"
	desc = "A set of botanical tools hidden behind a concealed panel on the user's arm"
	contents = newlist(/obj/item/plant_analyzer, /obj/item/cultivator, /obj/item/hatchet, /obj/item/shovel/spade, /obj/item/wirecutters, /obj/item/wrench)
	origin_tech = "materials=3;engineering=4;biotech=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "botanybelt")

/obj/item/organ/internal/cyberimp/arm/botanical/l
	parent_organ = "l_arm"
	slot = "l_arm_device"

// lets make IPCs even *more* vulnerable to EMPs!
/obj/item/organ/internal/cyberimp/arm/power_cord
	name = "APC-compatible power adapter implant"
	desc = "An implant commonly installed inside IPCs in order to allow them to easily collect energy from their environment"
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

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !ishuman(user) || !proximity_flag)
		return ..()
	if(drawing_power)
		to_chat(user, "<span class='warning'>You're already charging.</span>")
		return
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
				INVOKE_ASYNC(src, PROC_REF(powerdraw_loop), A, H)
		else
			to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")
	else
		to_chat(user, "<span class='warning'>You lack a cell in which to store charge!</span>")

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

/obj/item/organ/internal/cyberimp/arm/v1_arm
	name = "vortex feedback arm implant"
	desc = "An implant, that when deployed surrounds the users arm in armor and circuitry, allowing them to redirect nearby projectiles with feedback from the vortex anomaly core."
	origin_tech = "combat=6;magnets=6;biotech=6;engineering=6"
	icon = 'icons/obj/items.dmi'
	icon_state = "v1_arm"
	parent_organ = "l_arm" //Left arm by default
	slot = "l_arm_device"

	contents = newlist(/obj/item/shield/v1_arm)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/items.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "v1_arm")
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

/obj/item/shield/v1_arm
	name = "vortex feedback arm"
	desc = "A modification to a users arm, allowing them to use a vortex core energy feedback, to parry, reflect, and even empower projectile attacks. Rumors that it runs on the user's blood are unconfirmed."
	icon_state = "v1_arm"
	item_state = "v1_arm"
	sprite_sheets_inhand = list("Drask" = 'icons/mob/clothing/species/drask/held.dmi', "Vox" = 'icons/mob/clothing/species/vox/held.dmi')
	force = 20 //bonk, not sharp
	attack_verb = list("slamed", "punched", "parried", "judged", "styled on", "disrespected", "interrupted", "gored")
	hitsound = 'sound/effects/bang.ogg'
	light_power = 3
	light_range = 0
	light_color = "#9933ff"
	hit_reaction_chance = -1
	flags = ABSTRACT
	/// The damage the reflected projectile will be increased by
	var/reflect_damage_boost = 10
	/// The cap of the reflected damage. Damage will not be increased above 50, however it will not be reduced to 50 either.
	var/reflect_damage_cap = 50
	var/disabled = FALSE
	var/force_when_disabled = 5 //still basically a metal pipe, just hard to move

/obj/item/shield/v1_arm/customised_abstract_text()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/owner = loc
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
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.35, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (1 / 3) SECONDS, _no_parry_sound = TRUE) // 0.3333 seconds of cooldown for 75% uptime, countered by ions and plasma pistols

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

	if(istype(hitby, /obj/item/projectile))
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
	desc = "An implant awaiting installation of a vortex anomaly core"
	icon_state = "v1_arm"

/obj/item/v1_arm_shell/attackby(obj/item/I, mob/user, params)
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
	var/datum/martial_art/muscle_implant/muscle_implant

/obj/item/organ/internal/cyberimp/arm/muscle/Initialize()
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
