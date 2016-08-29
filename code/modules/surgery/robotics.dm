//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery/cybernetic_repair
	name = "Cybernetic Repair"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/external/repair)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/internal
	name = "Internal Component Manipulation"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/manipulate_robotic_organs)
	possible_locs = list("eyes", "chest","head","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_amputation
	name = "Robotic Limb Amputation"
	steps = list(/datum/surgery_step/robotics/external/amputate)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/can_start(mob/user, mob/living/carbon/target)

	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 0
		if(!(affected.status & ORGAN_ROBOT))
			return 0
		return 1

/datum/surgery/cybernetic_amputation/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 0
		if(!(affected.status & ORGAN_ROBOT))
			return 0
		if(affected.cannot_amputate)
			return 0
		return 1

//to do, moar surgerys or condense down ala manipulate organs.
/datum/surgery_step/robotics
	can_infect = 0

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!istype(target))
		return 0
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return 0
	if(affected.status & ORGAN_DESTROYED)
		return 0
	return 1

/datum/surgery_step/robotics/external

/datum/surgery_step/robotics/external/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!..())
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.status & ORGAN_ROBOT))
		return 0
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "unscrew hatch"
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
		/obj/item/weapon/coin = 50,
		/obj/item/weapon/kitchen/knife = 50
	)

	time = 16

/datum/surgery_step/robotics/external/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'> Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil/ = 50
	)

	time = 24

/datum/surgery_step/robotics/external/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'> You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>" )
	affected.open = 2
	return 1

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil = 50
	)

	time = 24

/datum/surgery_step/robotics/external/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	return 1

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/repair
	name = "repair damage internally"
	allowed_tools = list()

	var/list/implements_finish = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil = 50
	)
	var/list/implements_heal_burn = list(
		/obj/item/stack/cable_coil = 100
	)
	var/list/implements_heal_brute = list(
		/obj/item/weapon/weldingtool = 100,
		/obj/item/weapon/gun/energy/plasmacutter = 50
	)
	var/current_type
	time = 32

/datum/surgery_step/robotics/external/repair/New()
	..()
	allowed_tools = implements_heal_burn + implements_heal_brute + implements_finish


/datum/surgery_step/robotics/external/repair/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return -1

	if(implement_type in implements_heal_burn)
		current_type = "burn"
		var/obj/item/stack/cable_coil/C = tool
		if(!(affected.burn_dam > 0))
			to_chat(user, "<span class='warning'>The [affected] does not have any burn damage!</span>")
			return -1
		if(!istype(C))
			return -1
		if(!C.get_amount() >= 3)
			to_chat(user, "<span class='warning'>You need three or more cable pieces to repair this damage.</span>")
			return -1
		C.use(3)
		user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
		"You begin to splice new cabling into [target]'s [affected.name].")

	else if(implement_type in implements_heal_brute)
		current_type = "brute"
		if(!(affected.brute_dam > 0 || affected.disfigured))
			to_chat(user, "<span class='warning'>The [affected] does not require welding repair!</span>")
			return -1
		if(istype(tool,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/welder = tool
			if(!welder.isOn() || !welder.remove_fuel(1,user))
				return -1
		user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
		"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")

	else if(implement_type in implements_finish)
		current_type = "finish"
		user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
		"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	else
		log_runtime(EXCEPTION("Invalid tool: '[implement_type]'"), src)
		return -1
	..()

/datum/surgery_step/robotics/external/repair/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	switch(current_type)
		if("brute")
			user.visible_message("<span class='notice'> [user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
			"<span class='notice'> You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
			affected.heal_damage(rand(30,50),0,1,1)
			if(affected.disfigured)
				affected.disfigured = 0
				affected.update_icon()
				target.regenerate_icons()
		if("burn")
			user.visible_message("<span class='notice'> [user] finishes splicing cable into [target]'s [affected.name].</span>", \
			"<span class='notice'> You finishes splicing new cable into [target]'s [affected.name].</span>")
			affected.heal_damage(0,rand(30,50),1,1)
		if("finish")
			user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
			"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
			affected.open = 0
			return 1
	return 0

/datum/surgery_step/robotics/external/repair/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	switch(current_type)
		if("brute")
			user.visible_message("<span class='warning'> [user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
			"<span class='warning'> Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
			target.apply_damage(rand(5,10), BURN, affected)
		if("burn")
			user.visible_message("<span class='warning'> [user] causes a short circuit in [target]'s [affected.name]!</span>",
			"<span class='warning'> You cause a short circuit in [target]'s [affected.name]!</span>")
			target.apply_damage(rand(5,10), BURN, affected)
		if("finish")
			user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
			"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return 0

///////condenseing remove/extract/repair here.	/////////////
/datum/surgery_step/robotics/manipulate_robotic_organs

	name = "internal part manipulation"
	allowed_tools = list(/obj/item/device/mmi = 100)
	var/implements_extract = list(/obj/item/device/multitool = 100)
	var/implements_mend = list(	/obj/item/stack/nanopaste = 100,/obj/item/weapon/bonegel = 30, /obj/item/weapon/screwdriver = 70)
	var/implements_insert = list(/obj/item/organ/internal = 100)
	var/implements_finish =list(/obj/item/weapon/retractor = 100,/obj/item/weapon/crowbar = 100,/obj/item/weapon/kitchen/utensil = 50)
	var/current_type
	var/obj/item/organ/internal/I = null
	var/obj/item/organ/external/affected = null
	time = 32

/datum/surgery_step/robotics/manipulate_robotic_organs/New()
	..()
	allowed_tools = allowed_tools + implements_extract + implements_mend + implements_insert + implements_finish




/datum/surgery_step/robotics/manipulate_robotic_organs/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	I = null
	affected = target.get_organ(target_zone)
	if(implement_type in implements_insert)
		current_type = "insert"
		var/obj/item/organ/internal/I = tool

		if(I.status != ORGAN_ROBOT || I.robotic != 2)
			to_chat(user, "<span class='notice'>You can only implant cybernetic organs.</span>")

		if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
			to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return -1

		if(I.damage > (I.max_damage * 0.75))
			to_chat(user, "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
			return -1

		if(target.get_int_organ(I))
			to_chat(user, "<span class='warning'> \The [target] already has [I].</span>")
			return -1

		user.visible_message("[user] begins reattaching [target]'s [tool].", \
		"You start reattaching [target]'s [tool].")
		target.custom_pain("Someone's rooting around in your [affected.name]!",1)
	else if(istype(tool,/obj/item/device/mmi))
		current_type = "install"

		if(target_zone != "chest")
			to_chat(user, "<span class='notice'> You must target the chest cavity.</span>")

			return -1
		var/obj/item/device/mmi/M = tool


		if(!affected)
			return -1

		if(!istype(M))
			return -1

		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			to_chat(user, "<span class='danger'>That brain is not usable.</span>")
			return -1

		if(!(affected.status & ORGAN_ROBOT))
			to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>")
			return -1

		if(!target.species)
			to_chat(user, "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>")
			return -1

		if(!target.species.has_organ["brain"])
			to_chat(user, "<span class='danger'>You're pretty sure [target.species.name_plural] don't normally have a brain.</span>")
			return -1

		if(target.get_int_organ(/obj/item/organ/internal/brain/))
			to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
			return -1

		user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
		"You start installing \the [tool] into [target]'s [affected.name].")

	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.get_organs_zone(target_zone)
		if(!(affected && (affected.status & ORGAN_ROBOT)))
			return -1
		if(!organs.len)
			to_chat(user, "<span class='notice'>There is no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		else
			for(var/obj/item/organ/internal/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			I = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
			if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
				I = organs[I]
				if(!I) return -1
				user.visible_message("[user] starts to decouple [target]'s [I] with \the [tool].", \
				"You start to decouple [target]'s [I] with \the [tool]." )

				target.custom_pain("The pain in your [affected.name] is living hell!",1)
			else
				return -1

	else if(implement_type in implements_mend)
		current_type = "mend"
		if(!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
					"You start mending the damage to [target]'s [I.name]'s mechanisms." )

		target.custom_pain("The pain in your [affected.name] is living hell!",1)

	else if(implement_type in implements_finish)
		current_type = "finish"
		user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
		"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")


	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(current_type == "mend")

		if(!hasorgans(target))
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("<span class='notice'> [user] repairs [target]'s [I.name] with [tool].</span>", \
					"<span class='notice'> You repair [target]'s [I.name] with [tool].</span>" )
					I.damage = 0
	else if(current_type == "insert")
		var/obj/item/organ/internal/I = tool

		if(!user.canUnEquip(I, 0))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
			return 0

		user.drop_item()
		I.insert(target)
		user.visible_message("<span class='notice'> [user] has reattached [target]'s [I].</span>" , \
		"<span class='notice'> You have reattached [target]'s [I].</span>")

		if(I && istype(I))
			I.status &= ~ORGAN_CUT_AWAY
	else if(current_type == "install")
		user.visible_message("<span class='notice'> [user] has installed \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'> You have installed \the [tool] into [target]'s [affected.name].</span>")

		var/obj/item/device/mmi/M = tool

		user.unEquip(tool)
		M.attempt_become_organ(affected,target)

	else if(current_type == "extract")
		if(I && I.owner == target)
			user.visible_message("<span class='notice'> [user] has decoupled [target]'s [I] with \the [tool].</span>" , \
		"<span class='notice'> You have decoupled [target]'s [I] with \the [tool].</span>")

			add_logs(user, target, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			spread_germs_to_organ(I, user)
			I.status |= ORGAN_CUT_AWAY
			var/obj/item/thing = I.remove(target)
			if(!istype(thing))
				thing.forceMove(get_turf(target))
			else
				user.put_in_hands(thing)
		else
			user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	else if(current_type == "finish")
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
		affected.open = 0
		affected.germ_level = 0
		return 1
	return 0

/datum/surgery_step/robotics/manipulate_robotic_organs/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(current_type == "mend")
		if(!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("<span class='warning'> [user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

		target.adjustToxLoss(5)
		affected.createwound(CUT, 5)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I)
				I.take_damage(rand(3,5),0)

	else if(current_type == "insert")
		user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	else if(current_type == "extract")
		user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	else if(current_type == "install")
		user.visible_message("<span class='warning'> [user]'s hand slips!</span>.", \
		"<span class='warning'> Your hand slips!</span>")
	else if(current_type == "finish")
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
		"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return 0


/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"

	allowed_tools = list(
	/obj/item/device/multitool = 100)

	time = 100

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to decouple [target]'s [affected.name] with \the [tool].", \
	"You start to decouple [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!",1)
	..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has decoupled [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'> You have decoupled [target]'s [affected.name] with \the [tool].</span>")


	add_logs(user, target, "surgically removed [affected.name] from", addition="INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1,DROPLIMB_EDGE)
	if(istype(thing,/obj/item))
		user.put_in_hands(thing)

	return 1

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='warning'> [user]'s hand slips!</span>", \
	"<span class='warning'> Your hand slips!</span>")
	return 0
