//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery/cybernetic_repair
	name = "Cybernetic Repair"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest", "head", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/brute
	name = "Cybernetic Repair (Brute)"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/external/repair_brute)

/datum/surgery/cybernetic_repair/burn
	name = "Cybernetic Repair (Burn)"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/external/repair_burn)

/datum/surgery/cybernetic_repair/internal
	name = "Internal Cybernetic Manipulation"
	possible_locs = list("eyes", "mouth", "chest", "head", "groin", "l_arm", "r_arm")

/datum/surgery/cybernetic_repair/internal/extract
	name = "Cybernetic part extraction"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/manipulate_organs/extract/robo)

/datum/surgery/cybernetic_repair/internal/extract/organic
	name = "Cybernetic organ extraction"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/manipulate_organs/extract)

/datum/surgery/cybernetic_repair/internal/repair
	name = "Cybernetic part repair"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/manipulate_organs/repair/robo)

/datum/surgery/cybernetic_repair/internal/repair/organic
	name = "Cybernetic organ repair"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/manipulate_organs/repair)

/datum/surgery/cybernetic_repair/internal/insert
	name = "Cybernetic insertion"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/manipulate_organs/insert)

/datum/surgery/cybernetic_repair/internal/insert/mmi
	name = "Cybernetic insertion"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/manipulate_organs/insert/mmi)
	possible_locs = list("chest", "head", "groin")

/datum/surgery/cybernetic_amputation
	name = "Robotic Limb Amputation"
	steps = list(/datum/surgery_step/robotics/external/amputate)
	possible_locs = list("chest", "head", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/can_start(mob/user, mob/living/carbon/target, selected_zone)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(selected_zone)
		if(!affected)
			return 0
		if(!affected.is_robotic())
			return 0
		return 1

/datum/surgery/cybernetic_amputation/can_start(mob/user, mob/living/carbon/target, selected_zone)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(selected_zone)
		if(!affected)
			return 0
		if(!affected.is_robotic())
			return 0
		if(affected.cannot_amputate)
			return 0
		return 1

//to do, moar surgerys or condense down ala manipulate organs.
/datum/surgery_step/robotics
	can_infect = 0
	painful = FALSE

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(!istype(target))
		return 0
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return 0
	return 1

/datum/surgery_step/robotics/external

/datum/surgery_step/robotics/external/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(!..())
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.is_robotic())
		return 0
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "unscrew hatch"
	allowed_tools = list(
		/obj/item/screwdriver = 100,
		/obj/item/coin = 50,
		/obj/item/kitchen/knife = 50
	)

	time = 16

/datum/surgery_step/robotics/external/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'>Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_tools = list(
		/obj/item/retractor = 100,
		/obj/item/crowbar = 100,
		/obj/item/kitchen/utensil/ = 50
	)

	time = 24

/datum/surgery_step/robotics/external/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'>You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>" )
	affected.open = 2
	return 1

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_tools = list(
		/obj/item/retractor = 100,
		/obj/item/crowbar = 100,
		/obj/item/kitchen/utensil = 50
	)

	steps_to_pop = 3
	steps_this_can_pop = list(/datum/surgery_step/robotics/external/close_hatch,/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch)
	time = 24

/datum/surgery_step/robotics/external/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	return 1

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/repair_brute
	name = "repair damage internally"
	allowed_tools = list(
		/obj/item/weldingtool = 100,
		/obj/item/gun/energy/plasmacutter = 50
	)

	steps_this_can_pop = list(/datum/surgery_step/robotics/external/repair_brute)
	steps_to_pop = 1
	time = 32


/datum/surgery_step/robotics/external/repair_brute/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.brute_dam > 0 || affected.disfigured))
		to_chat(user, "<span class='warning'>The [affected] does not require welding repair!</span>")
		return -1
	if(istype(tool, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = tool
		if(!welder.isOn() || !welder.remove_fuel(1,user))
			return -1
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
	"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")

/datum/surgery_step/robotics/external/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'>You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
	affected.heal_damage(rand(30,50),0,1,1)
	if(affected.disfigured)
		affected.disfigured = 0
		affected.update_icon()
		target.regenerate_icons()
	return 1


/datum/surgery_step/robotics/external/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
	affected.take_damage(0, rand(5,10))

/datum/surgery_step/robotics/external/repair_burn
	name = "repair heat damage"
	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

	steps_this_can_pop = list(/datum/surgery_step/robotics/external/repair_burn)
	steps_to_pop = 1
	time = 32

/datum/surgery_step/robotics/external/repair_burn/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
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

/datum/surgery_step/robotics/external/repair_burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes splicing cable into [target]'s [affected.name].</span>", \
	"<span class='notice'>You finishes splicing new cable into [target]'s [affected.name].</span>")
	affected.heal_damage(0,rand(30,50),1,1)
	return 1

/datum/surgery_step/robotics/external/repair/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user] causes a short circuit in [target]'s [affected.name]!</span>",
	"<span class='warning'>You cause a short circuit in [target]'s [affected.name]!</span>")
	target.apply_damage(rand(5,10), BURN, affected)

/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"

	allowed_tools = list(
	/obj/item/multitool = 100)

	steps_to_pop = 1
	steps_this_can_pop = list(/datum/surgery_step/robotics/external/amputate)
	time = 100

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to decouple [target]'s [affected.name] with \the [tool].", \
	"You start to decouple [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has decoupled [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'>You have decoupled [target]'s [affected.name] with \the [tool].</span>")


	add_attack_logs(user, target, "Surgically removed [affected.name] from. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1,DROPLIMB_SHARP)
	if(istype(thing,/obj/item))
		user.put_in_hands(thing)

	return 1

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("<span class='warning'>[user]'s hand slips!</span>", \
	"<span class='warning'>Your hand slips!</span>")
	return 0

/datum/surgery/cybernetic_customization
	name = "Cybernetic Appearance Customization"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch, /datum/surgery_step/robotics/external/customize_appearance)
	possible_locs = list("head", "chest", "l_arm", "r_arm", "r_leg", "l_leg")
	requires_organic_bodypart = FALSE

/datum/surgery/cybernetic_customization/can_start(mob/user, mob/living/carbon/human/target)
	if(ishuman(target))
		var/obj/item/organ/external/affected = target.get_organ(user.zone_sel.selecting)
		if(!affected)
			return FALSE
		if(!(affected.status & ORGAN_ROBOT))
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/customize_appearance
	name = "reprogram limb"
	allowed_tools = list(/obj/item/multitool = 100)
	time = 48

/datum/surgery_step/robotics/external/customize_appearance/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/customize_appearance/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to reprogram the appearance of [target]'s [affected.name] with [tool]." , \
	"You begin to reprogram the appearance of [target]'s [affected.name] with [tool].")
	..()

/datum/surgery_step/robotics/external/customize_appearance/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/chosen_appearance = input(user, "Select the company appearance for this limb.", "Limb Company Selection") as null|anything in selectable_robolimbs
	if(!chosen_appearance)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.robotize(chosen_appearance, convert_all = FALSE)
	if(istype(affected, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = affected
		head.h_style = "Bald" // nearly all the appearance changes for heads are non-monitors; we want to get rid of a floating screen
		target.update_hair()
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	user.visible_message("<span class='notice'> [user] reprograms the appearance of [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'> You reprogram the appearance of [target]'s [affected.name] with [tool].</span>")
	affected.open = 0
	return TRUE

/datum/surgery_step/robotics/external/customize_appearance/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>")
	return FALSE
