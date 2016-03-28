#define GHETTO_DISINFECT_AMOUNT 5 //Amount of units to transfer from the container to the organs during ghetto surgery disinfection step

/datum/surgery/organ_manipulation
	name = "Organ manipulation (encased, parent type)"
	steps = list()
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")
	requires_organic_bodypart = 1

/datum/surgery/organ_manipulation/insert
	name = "Organ insertion (encased)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs/insert)

/datum/surgery/organ_manipulation/extract
	name = "Organ extraction (encased)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs/extract)

/datum/surgery/organ_manipulation/extract/robo
	name = "Robot part extraction (encased)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs/extract/robo)

/datum/surgery/organ_manipulation/repair
	name = "Organ repair (encased)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs/repair)

/datum/surgery/organ_manipulation/repair/robo
	name = "Robotic organ repair (encased)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs/repair/robo)

/datum/surgery/organ_manipulation/soft
	name = "Organ manipulation (soft, parent type)"

/datum/surgery/organ_manipulation/soft/insert
	name = "Organ insertion (soft)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs/insert)

/datum/surgery/organ_manipulation/soft/extract
	name = "Organ extraction (soft)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs/extract)

/datum/surgery/organ_manipulation/soft/extract/robo
	name = "Robotic organ extraction (soft)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs/extract/robo)

/datum/surgery/organ_manipulation/soft/repair
	name = "Organ repair (soft)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs/repair)

/datum/surgery/organ_manipulation/soft/repair/robo
	name = "Robotic organ repair (soft)"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs/repair)

/datum/surgery/organ_manipulation/alien
	name = "Alien organ manipulation (parent type)"
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")
	allowed_mob = list(/mob/living/carbon/alien/humanoid)

/datum/surgery/organ_manipulation/alien/insert
	name = "Alien organ insertion"
	steps = list(/datum/surgery_step/saw_carapace,/datum/surgery_step/cut_carapace, /datum/surgery_step/retract_carapace,/datum/surgery_step/internal/manipulate_organs/insert)

/datum/surgery/organ_manipulation/alien/extract
	name = "Alien organ extraction"
	steps = list(/datum/surgery_step/saw_carapace,/datum/surgery_step/cut_carapace, /datum/surgery_step/retract_carapace,/datum/surgery_step/internal/manipulate_organs/extract)

/datum/surgery/organ_manipulation/can_start(mob/user, mob/living/carbon/target, selected_zone)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(selected_zone)
		if(!affected)
			return 0
		if(affected.status & ORGAN_ROBOT)
			return 0
		if(!affected.encased)
			return 0
		return 1

/datum/surgery/organ_manipulation/soft/can_start(mob/user, mob/living/carbon/target, selected_zone)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(selected_zone)
		if(!affected)
			return 0
		if(affected.status & ORGAN_ROBOT)
			return 0
		if(affected.encased)
			return 0
		return 1

/datum/surgery/organ_manipulation/alien/can_start(mob/user, mob/living/carbon/target, selected_zone)
	if(istype(target,/mob/living/carbon/alien/humanoid))
		return 1
	return 0

// Internal surgeries.
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	if(!hasorgans(target))
		return 0
	if(!ishuman(target))
		return 1 // We're dealing with a non-human, which lack limbs, so they're meeting all our standards
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(target_zone)
	return (affected != null)

/*
Careful, these procs can also be done on xenos!
*/
/datum/surgery_step/internal/manipulate_organs
	name = "Manipulate organs (parent type)"
	allowed_tools = list()
	steps_to_pop = 1
	time = 64

/datum/surgery_step/internal/manipulate_organs/repair
	name = "Manipulate organs (repair)"
	var/obj/item/organ/external/affected
	allowed_tools = list(/obj/item/stack/medical/bruise_pack/advanced = 100, /obj/item/stack/medical/bruise_pack = 20)
	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/repair)

/datum/surgery_step/internal/manipulate_organs/repair/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(target_zone)
	if(!affected)
		to_chat(user, "<span class='warning'>They do not have a [target_zone]!</span>")
		return 0
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && I.robotic < 2)
			return 1
	to_chat(user, "There are no damaged organs that you can repair with this!")
	return 0

/datum/surgery_step/internal/manipulate_organs/repair/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"
	var/mob/living/carbon/human/H = target
	affected = H.get_organ(user.zone_sel.selecting)
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && I.robotic < 2)
			spread_germs_to_organ(I, user)
			user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
			"You start treating damage to [target]'s [I.name] with [tool_name]." )
	if(H)
		H.custom_pain("The pain in your [affected.name] is living hell!",1)
	return 1

/datum/surgery_step/internal/manipulate_organs/repair/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		tool_name = "regenerative membrane"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	if(!hasorgans(target))
		return
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.robotic < 2)
			I.surgeryize()
			if(I.damage)
				user.visible_message("<span class='notice'>[user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'>You treat damage to [target]'s [I.name] with [tool_name].</span>" )
				I.damage = 0
	return 1

/datum/surgery_step/internal/manipulate_organs/repair/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_sel.selecting)
	user.visible_message("<span class='warning'>[user]'s hand slips, spreading grime and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, spreading grime and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>")
	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		dam_amt = 5
		target.adjustToxLoss(10)
		affected.take_damage(5)

	target.bleed_rate += dam_amt

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && !(I.tough))
			I.take_damage(dam_amt,0)

	return 0

/datum/surgery_step/internal/manipulate_organs/repair/robo
	name = "Manipulate organs (repair (robotic))"
	allowed_tools = list(/obj/item/stack/nanopaste = 100, /obj/item/screwdriver = 70, /obj/item/bonegel = 30)
	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/repair/robo)

/datum/surgery_step/internal/manipulate_organs/repair/robo/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(!hasorgans(target))
		to_chat(user, "They do not have organs to mend!")
		return 0
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(target_zone)
	if(!affected)
		to_chat(user, "<span class='warning'>They do not have a [target_zone]!</span>")
		return
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && I.robotic == 2)
			return 1
	to_chat(user, "There are no damaged organs that you can repair with this!")
	return 0

/datum/surgery_step/internal/manipulate_organs/repair/robo/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/mob/living/carbon/human/H = target
	affected = H.get_organ(user.zone_sel.selecting)
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && I.robotic >= 2)
			spread_germs_to_organ(I, user)
			I.surgeryize()
			user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
			"You start mending the damage to [target]'s [I.name]'s mechanisms." )

		H.custom_pain("The pain in your [affected.name] is living hell!",1)

/datum/surgery_step/internal/manipulate_organs/repair/robo/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/tool_name = "\the [tool]"

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.robotic >= 2)
			I.surgeryize()
			if(I.damage)
				user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'>You repair [target]'s [I.name] with [tool_name].</span>" )
				I.damage = 0
	return 1

/datum/surgery_step/internal/manipulate_organs/repair/robo/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, spreading grime and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, spreading grime and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>")
	target.adjustToxLoss(10)
	affected.take_damage(5)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && !(I.tough))
			I.take_damage(5,0)

	return 0

/datum/surgery_step/internal/manipulate_organs/extract
	name = "Extract organs"
	allowed_tools = list(/obj/item/hemostat = 100, /obj/item/wirecutters = 70, /obj/item/kitchen/utensil/fork = 55)
	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/extract)
	var/obj/item/organ/internal/I = null
	var/obj/item/organ/external/affected = null

/datum/surgery_step/internal/manipulate_organs/extract/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/list/organs = target.get_organs_zone(target_zone)
	organs = organs.Copy()
	var/list/organ_choices = list()
	var/obj/item/organ/external/affected
	var/mob/living/carbon/human/H
	if(ishuman(target))
		H = target
		affected = H.get_organ(user.zone_sel.selecting)

	var/removable_count = 0
	for(var/obj/item/organ/internal/O in organs)
		if(O.robotic != 2)
			removable_count++
	if(removable_count == 0)
		to_chat(user, "<span class='notice'>There are no removable organs in [target]'s [parse_zone(target_zone)]!</span>")
		return -1
	else
		for(var/obj/item/organ/internal/O in organs)
			if(O.unremovable)
				continue
			O.on_find(user)
			if(O.robotic == 2)
				continue // Use a robo surgery for this
			organ_choices[O.name] = O

		I = input("Remove which organ?", "Surgery", null, null) as null|anything in organ_choices
		if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
			I = organ_choices[I]
			if(!I) return -1
			user.visible_message("[user] starts to separate [target]'s [I] with \the [tool].", \
			"You start to separate [target]'s [I] with \the [tool] for removal." )
			if(affected && H)
				H.custom_pain("The pain in your [affected.name] is living hell!",1)
		else
			return -1

/datum/surgery_step/internal/manipulate_organs/extract/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(I && I.owner == target)
		user.visible_message("<span class='notice'>[user] has separated and extracts [target]'s [I] with \the [tool].</span>" , \
		"<span class='notice'>You have separated and extracted [target]'s [I] with \the [tool].</span>")

		add_attack_logs(target, user, "surgically removed [I.name] from", ATKLOG_MOST, addition="INTENT: [uppertext(user.a_intent)]")
		spread_germs_to_organ(I, user)
		var/obj/item/thing = I.remove(target)
		thing.loc = get_turf(target)
		if(!(user.l_hand && user.r_hand))
			user.put_in_hands(thing)
	else
		user.visible_message("<span class='notice'>[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")


/datum/surgery_step/internal/manipulate_organs/extract/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(I && I.owner == target)
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>", \
		"<span class='warning'>Your hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>")
		affected.take_damage(20)
	else
		user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	return 0

/datum/surgery_step/internal/manipulate_organs/extract/robo
	name = "Extract robotic organs"
	allowed_tools = list(/obj/item/multitool = 100, /obj/item/wirecutters = 70)
	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/extract/robo)

/datum/surgery_step/internal/manipulate_organs/extract/robo/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/list/organs = target.get_organs_zone(target_zone)
	var/list/organ_choices = list()
	var/mob/living/carbon/human/H
	if(ishuman(target))
		H = target
		affected = H.get_organ(target_zone)
	var/removable_count = 0
	for(var/obj/item/organ/internal/O in organs)
		if(O.robotic == 2)
			removable_count++
	if(removable_count == 0)
		to_chat(user, "<span class='notice'>There are no removable organs in [target]'s [parse_zone(target_zone)]!</span>")
		return -1
	else
		for(var/obj/item/organ/internal/O in organs)
			O.on_find(user)
			if(O.robotic != 2)
				continue // Use an organic surgery for this
			organ_choices[O.name] = O

		I = input("Remove which organ?", "Surgery", null, null) as null|anything in organ_choices
		if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
			I = organ_choices[I]
			if(!I) return -1
			user.visible_message("[user] starts to decouple [target]'s [I] with \the [tool].", \
			"You start to decouple [target]'s [I] with \the [tool]." )
			if(affected && H)
				H.custom_pain("The pain in your [affected.name] is living hell!",1)
		else
			return -1

/datum/surgery_step/internal/manipulate_organs/extract/robo/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(I && I.owner == target)
		user.visible_message("<span class='notice'>[user] has decoupled [target]'s [surgery.current_organ] with \the [tool].</span>" , \
		"<span class='notice'>You have decoupled [target]'s [surgery.current_organ] with \the [tool].</span>")

		add_attack_logs(target, user, "surgically removed [I.name] from", ATKLOG_MOST, addition="INTENT: [uppertext(user.a_intent)]")
		spread_germs_to_organ(I, user)
		var/obj/item/thing = I.remove(target)
		thing.loc = get_turf(target)
		if(!(user.l_hand && user.r_hand))
			user.put_in_hands(thing)
	else
		user.visible_message("<span class='notice'>[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")

// This will runtime if done on a non-human, as-is - fortunately, you can't do so.
/datum/surgery_step/internal/manipulate_organs/extract/robo/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(I && I.owner == target)
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>", \
		"<span class='warning'>Your hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>")
		affected.take_damage(20)
	else
		user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	return 0

/datum/surgery_step/internal/manipulate_organs/insert
	name = "Insert organs"
	allowed_tools = list(/obj/item/organ/internal = 100, /obj/item/reagent_containers/food/snacks/organ = 1)
	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/insert)
	var/obj/item/organ/internal/I = null
	var/obj/item/organ/external/affected = null

/datum/surgery_step/internal/manipulate_organs/insert/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/organ/internal/I = tool

	if(!..())
		return 0

	if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		// I mean, you probably won't be able to reach this code anyways
		to_chat(user, "<span class='warning'>[tool] was bitten by someone! It's too damaged to use!</span>")
		return 0
	if(tool.flags & NODROP)
		to_chat(user, "<span class='warning'>[tool] is stuck to you! You can't drop it!</span>")
		return 0

	if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
		to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return 0

	if(I.damage > (I.max_damage * 0.75))
		to_chat(user, "<span class='notice'>\The [I] is in no state to be transplanted.</span>")
		return 0

	if(target.get_int_organ(I))
		to_chat(user, "<span class='warning'>\The [target] already has [I].</span>")
		return 0
	return 1

/datum/surgery_step/internal/manipulate_organs/insert/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	I = tool
	var/mob/living/carbon/human/H
	if(ishuman(target))
		H = target
		affected = H.get_organ(target_zone)
	if(affected)
		user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.name].", \
		"You start transplanting \the [tool] into [target]'s [affected.name].")
		if(H)
			H.custom_pain("Someone's rooting around in your [affected.name]!")
	else
		user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
		"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")


/datum/surgery_step/internal/manipulate_organs/insert/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	user.drop_item()
	I.insert(target)
	spread_germs_to_organ(I, user)
	if(!user.canUnEquip(I, 0))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
		return 0

	if(affected)
		user.visible_message("<span class='notice'>[user] has transplanted \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'>You have transplanted \the [tool] into [target]'s [affected.name].</span>")
	else
		user.visible_message("<span class='notice'>[user] has transplanted \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'>You have transplanted \the [tool] into [target]'s [parse_zone(target_zone)].</span>")
	return 1

/datum/surgery_step/internal/manipulate_organs/insert/mmi
	name = "Insert man-machine interface"
	allowed_tools = list(/obj/item/mmi = 100)
	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/insert/mmi)


/datum/surgery_step/internal/manipulate_organs/insert/mmi/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/obj/item/mmi/M = tool

	if(!ishuman(target))
		return 0
	var/mob/living/carbon/human/H = target
	affected = H.get_organ(target_zone)

	if(!istype(M))
		return 0

	if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
		to_chat(user, "<span class='danger'>That brain is not usable.</span>")
		return 0

	if(!(affected && affected.status & ORGAN_ROBOT))
		to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>")
		return 0

	if(!H.species.has_organ["brain"])
		to_chat(user, "<span class='danger'>You're pretty sure [H.species.name_plural] don't normally have a brain.</span>")
		return 0

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
		return 0

	if(M.flags & NODROP)
		to_chat(user, "<span class='warning'>\The [M] is stuck to you, you can't drop it!</span>")
		return 0
	return 1

/datum/surgery_step/internal/manipulate_organs/insert/mmi/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
	"You start installing \the [tool] into [target]'s [affected.name].")


/datum/surgery_step/internal/manipulate_organs/insert/mmi/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(!user.canUnEquip(tool, 0))
		to_chat(user, "<span class='warning'>[tool] is stuck to your hand, you can't put it in [target]!</span>")
		return 0
	user.visible_message("<span class='notice'>[user] has installed \the [tool] into [target]'s [affected.name].</span>", \
	"<span class='notice'>You have installed \the [tool] into [target]'s [affected.name].</span>")

	var/obj/item/mmi/M = tool
	var/obj/item/organ/internal/brain/mmi_holder/holder = new

	holder.parent_organ = target_zone
	holder.insert(target)
	user.unEquip(tool)
	M.forceMove(holder)
	holder.stored_mmi = M
	holder.update_from_mmi()

	if(M.brainmob && M.brainmob.mind)
		M.brainmob.mind.transfer_to(target)
	return 1

/datum/surgery_step/internal/manipulate_organs/insert/mmi/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips!</span>.", \
	"<span class='warning'>Your hand slips!</span>")
	return 0

/datum/surgery_step/internal/manipulate_organs/clean
	name = "Disinfect internal organs"
	allowed_tools = list(/obj/item/reagent_containers/dropper = 100,
								/obj/item/reagent_containers/syringe = 100,
								/obj/item/reagent_containers/glass/bottle = 90,
								/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
								/obj/item/reagent_containers/food/drinks/bottle = 80,
								/obj/item/reagent_containers/glass/beaker = 75,
								/obj/item/reagent_containers/spray = 60,
								/obj/item/reagent_containers/glass/bucket = 50)

	steps_this_can_pop = list(/datum/surgery_step/internal/manipulate_organs/clean)


/datum/surgery_step/internal/manipulate_organs/clean/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	if(!..())
		return FALSE

	if(!ishuman(target))
		return FALSE

	if(!istype(tool, /obj/item/reagent_containers))
		return FALSE

	var/obj/item/reagent_containers/C = tool

	if(C.reagents.total_volume < GHETTO_DISINFECT_AMOUNT)
		to_chat(user, "<span class='warning'>You need to have at least [GHETTO_DISINFECT_AMOUNT]u of disinfectant to proceed!</span>")
		return FALSE

	return TRUE

/datum/surgery_step/internal/manipulate_organs/clean/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(target_zone)
	. = -1

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		var/msg = "[user] starts pouring some of [tool] over [target]'s [I.name]."
		var/self_msg = "You start pouring some of [tool] over [target]'s [I.name]."
		user.visible_message(msg, self_msg)
		if(H && affected)
			H.custom_pain("Something burns horribly in your [affected.name]!")
		. = 0


/datum/surgery_step/internal/manipulate_organs/clean/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(target_zone)
	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing

	if(R.reagent_list.len)
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= R.reagent_list.len

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(R.total_volume < GHETTO_DISINFECT_AMOUNT)
			user.visible_message("[user] notices there is not enough of [tool].", \
			"You notice there is not enough of [tool].")
			break
		if(I.germ_level >= INFECTION_LEVEL_ONE / 2)
			I.germ_level = max(I.germ_level-ethanol, 0)
			user.visible_message("<span class='notice'> [user] has poured some of [tool] over [target]'s [I.name].</span>",
			"<span class='notice'> You have poured some of [tool] over [target]'s [I.name].</span>")
			R.trans_to(target, GHETTO_DISINFECT_AMOUNT)
			R.reaction(target, INGEST)
		else
			to_chat(user, "[I] does not appear to be infected.")
	return TRUE


/datum/surgery_step/internal/manipulate_organs/clean/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = H.get_organ(target_zone)

	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing

	if(R.reagent_list.len)
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= C.reagents.reagent_list.len

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		I.germ_level = max(I.germ_level-ethanol, 0)
		I.take_damage(rand(4,8),0)

	R.trans_to(target, GHETTO_DISINFECT_AMOUNT * 10)
	R.reaction(target, INGEST)

	user.visible_message("<span class='warning'> [user]'s hand slips, splashing the contents of [tool] all over [target]'s [affected.name] incision!</span>", \
	"<span class='warning'> Your hand slips, splashing the contents of [tool] all over [target]'s [affected.name] incision!</span>")
	return 0

//////////////////////////////////////////////////////////////////
//						SPESHUL AYLIUM STUPS					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/saw_carapace
	name = "saw carapace"
	allowed_tools = list(
	/obj/item/circular_saw = 100, \
	/obj/item/melee/energy/sword/cyborg/saw = 100, \
	/obj/item/hatchet = 90
	)

	time = 54


/datum/surgery_step/saw_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("[user] begins to cut through [target]'s [target_zone] with [tool].", \
	"You begin to cut through [target]'s [target_zone] with [tool].")
	..()

/datum/surgery_step/saw_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("<span class='notice'>[user] has cut [target]'s [target_zone] open with [tool].</span>",		\
	"<span class='notice'>You have cut [target]'s [target_zone] open with [tool].</span>")
	return 1

/datum/surgery_step/saw_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [target_zone] with [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cracking [target]'s [target_zone] with [tool]!</span>" )
	return 0

/datum/surgery_step/cut_carapace
	name = "cut carapace"
	allowed_tools = list(
	/obj/item/scalpel = 100,		\
	/obj/item/kitchen/knife = 90,	\
	/obj/item/shard = 60, 		\
	/obj/item/scissors = 12,		\
	/obj/item/twohanded/chainsaw = 1, \
	/obj/item/claymore = 6, \
	/obj/item/melee/energy/ = 6, \
	/obj/item/pen/edagger = 6, \
	)

	time = 16

/datum/surgery_step/cut_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("[user] starts the incision on [target]'s [target_zone] with [tool].", \
	"You start the incision on [target]'s [target_zone] with [tool].")
	..()

/datum/surgery_step/cut_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [target_zone] with [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [target_zone] with [tool].</span>",)
	return 1

/datum/surgery_step/cut_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)

	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [target_zone] in a wrong spot with [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [target_zone] in a wrong spot with [tool]!</span>")
	return 0

/datum/surgery_step/retract_carapace
	name = "retract carapace"

	allowed_tools = list(
	/obj/item/scalpel/laser/manager = 100, \
	/obj/item/retractor = 100, 	\
	/obj/item/crowbar = 90,	\
	/obj/item/kitchen/utensil/fork = 60
	)

	time = 24

/datum/surgery_step/retract_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/msg = "[user] starts to pry open the incision on [target]'s [target_zone] with [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [target_zone] with [tool]."
	if(target_zone == "chest")
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
	if(target_zone == "groin")
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
	user.visible_message(msg, self_msg)
	..()

/datum/surgery_step/retract_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/msg = "<span class='notice'>[user] keeps the incision open on [target]'s [target_zone] with [tool].</span>"
	var/self_msg = "<span class='notice'>You keep the incision open on [target]'s [target_zone] with [tool].</span>"
	if(target_zone == "chest")
		msg = "<span class='notice'>[user] keeps the ribcage open on [target]'s torso with [tool].</span>"
		self_msg = "<span class='notice'>You keep the ribcage open on [target]'s torso with [tool].</span>"
	if(target_zone == "groin")
		msg = "<span class='notice'>[user] keeps the incision open on [target]'s lower abdomen with [tool].</span>"
		self_msg = "<span class='notice'>You keep the incision open on [target]'s lower abdomen with [tool].</span>"
	user.visible_message(msg, self_msg)
	return 1

/datum/surgery_step/generic/retract_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/active_surgery/surgery)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of incision on [target]'s [target_zone] with [tool]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, tearing the edges of incision on [target]'s [target_zone] with [tool]!</span>"
	if(target_zone == "chest")
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs [target]'s torso with [tool]!</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs [target]'s torso with [tool]!</span>"
	if(target_zone == "groin")
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs [target]'s lower abdomen with [tool].</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs [target]'s lower abdomen with [tool]!</span>"
	user.visible_message(msg, self_msg)
	return 0
