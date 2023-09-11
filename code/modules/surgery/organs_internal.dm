/// Amount of units to transfer from the container to the organs during disinfection step.
#define GHETTO_DISINFECT_AMOUNT 5
/// Amount of mito necessary to revive an organ
#define MITO_REVIVAL_COST 1



/datum/surgery/organ_manipulation
	name = "Organ Manipulation"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/internal/manipulate_organs/finish,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_organic_bodypart = TRUE
	requires_bodypart = TRUE

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/generic/cauterize
	)

/datum/surgery/organ_manipulation_boneless
	name = "Organ Manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/generic/cauterize
	)
	requires_organic_bodypart = TRUE

/datum/surgery/organ_manipulation/alien
	name = "Alien Organ Manipulation"
	requires_bodypart = FALSE  // xenos just don't have "bodyparts"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	steps = list(
		/datum/surgery_step/saw_carapace,
		/datum/surgery_step/cut_carapace,
		/datum/surgery_step/retract_carapace,
		/datum/surgery_step/proxy/manipulate_organs/alien,
		/datum/surgery_step/generic/seal_carapace
	)




/datum/surgery/organ_manipulation/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected.encased) //no bone, problem.
			return FALSE
		if(HAS_TRAIT(target, TRAIT_NO_BONES))
			return FALSE
		return TRUE

/datum/surgery/organ_manipulation_boneless/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(affected && affected.encased) //no bones no problem.
			return FALSE
		if(HAS_TRAIT(target, TRAIT_NO_BONES))
			return TRUE
		return TRUE

// Intermediate steps for branching organ manipulation.
/datum/surgery/intermediate/manipulate
	requires_bodypart = TRUE

	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

// All these surgeries are necessary for slotting into proxy steps

/datum/surgery/intermediate/manipulate/extract
	steps = list(/datum/surgery_step/internal/manipulate_organs/extract)

/datum/surgery/intermediate/manipulate/implant
	steps = list(/datum/surgery_step/internal/manipulate_organs/implant)

/datum/surgery/intermediate/manipulate/mend
	steps = list(/datum/surgery_step/internal/manipulate_organs/mend)

/datum/surgery/intermediate/manipulate/clean
	steps = list(/datum/surgery_step/internal/manipulate_organs/clean)

/// The surgery step to trigger this whole situation
/datum/surgery_step/proxy/manipulate_organs
	name = "Manipulate Organs (proxy)"
	branches = list(
		/datum/surgery/intermediate/manipulate/extract,
		/datum/surgery/intermediate/manipulate/implant,
		/datum/surgery/intermediate/manipulate/mend,
		/datum/surgery/intermediate/manipulate/clean,
		/datum/surgery/intermediate/bleeding
	)

/datum/surgery_step/proxy/manipulate_organs/soft
	name = "Manipulate Organs Soft (proxy)"
	branches = list(
		/datum/surgery/intermediate/manipulate/extract,
		/datum/surgery/intermediate/manipulate/implant,
		/datum/surgery/intermediate/manipulate/mend,
		/datum/surgery/intermediate/manipulate/clean,
		/datum/surgery/intermediate/bleeding
	)

// have to redefine all of these because xenos don't technically have bodyparts.
/datum/surgery/intermediate/manipulate/extract/xeno
	requires_bodypart = FALSE

/datum/surgery/intermediate/manipulate/implant/xeno
	requires_bodypart = FALSE

/datum/surgery/intermediate/manipulate/mend/xeno
	requires_bodypart = FALSE

/datum/surgery/intermediate/manipulate/clean/xeno
	requires_bodypart = FALSE

/datum/surgery_step/proxy/manipulate_organs/alien
	name = "Manipulate Organs Xeno (proxy)"
	branches = list(
		/datum/surgery/intermediate/manipulate/extract/xeno,
		/datum/surgery/intermediate/manipulate/implant/xeno,
		/datum/surgery/intermediate/manipulate/mend/xeno,
		/datum/surgery/intermediate/manipulate/clean/xeno
	)

// Internal surgeries.
/datum/surgery_step/internal
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

/**
 * Get an internal list of organs for a zone (or an external organ).
 *
 * Helper function since we end up calling this a ton to work with carbons
 */
/datum/surgery_step/internal/proc/get_organ_list(target_zone, mob/living/carbon/target, obj/item/organ/external/affected)
	var/list/organs

	if(affected && istype(affected))
		organs = affected.internal_organs
	else
		organs = target.get_organs_zone(target_zone)

	return organs


/datum/surgery_step/internal/manipulate_organs/mend
	name = "mend organs"
	allowed_tools = list(
		/obj/item/stack/medical/bruise_pack/advanced = 100,
		/obj/item/stack/medical/bruise_pack = 20,
		/obj/item/stack/nanopaste = 100
	)

/datum/surgery_step/internal/manipulate_organs/mend/proc/get_tool_name(obj/item/tool)
	var/tool_name = "[tool]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/nanopaste))
		tool_name = "[tool]" //what else do you call nanopaste medically?

	return tool_name

/datum/surgery_step/internal/manipulate_organs/mend/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = get_tool_name(tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!hasorgans(target))
		to_chat(user, "They do not have organs to mend!")
		// note that we want to return skip here so we can go "back" to the proxy step
		return SURGERY_BEGINSTEP_SKIP

	var/any_organs_damaged = FALSE

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)
		if(I && I.damage)
			any_organs_damaged = TRUE
			if(!I.is_robotic() && !istype(tool, /obj/item/stack/nanopaste))
				if(!(I.sterile))
					spread_germs_to_organ(I, user, tool)
				user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
				"You start treating damage to [target]'s [I.name] with [tool_name]." )
			else if(I.is_robotic() && istype(tool, /obj/item/stack/nanopaste))
				user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
				"You start treating damage to [target]'s [I.name] with [tool_name]." )

		else
			to_chat(user, "[I] does not appear to be damaged.")

	if(!any_organs_damaged)
		return SURGERY_BEGINSTEP_SKIP

	if(affected)
		var/mob/living/carbon/C = target
		C.custom_pain("The pain in your [affected.name] is living hell!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = get_tool_name(tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!hasorgans(target))
		return SURGERY_STEP_INCOMPLETE

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)
		if(I)
			I.surgeryize()
		if(I && I.damage)
			if(!I.is_robotic() && !istype(tool, /obj/item/stack/nanopaste))
				user.visible_message(
					"<span class='notice'> [user] treats damage to [target]'s [I.name] with [tool_name].</span>",
					"<span class='notice'> You treat damage to [target]'s [I.name] with [tool_name].</span>"
				)
				I.damage = 0
			else if(I.is_robotic() && istype (tool, /obj/item/stack/nanopaste))
				user.visible_message(
					"<span class='notice'> [user] treats damage to [target]'s [I.name] with [tool_name].</span>",
					"<span class='notice'> You treat damage to [target]'s [I.name] with [tool_name].</span>"
				)
				I.damage = 0
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='warning'> [user]'s hand slips, getting messy and tearing the inside of [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='warning'> Your hand slips, getting messy and tearing the inside of [target]'s [parse_zone(target_zone)] with [tool]!</span>"
	)

	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack) || istype(tool, /obj/item/stack/nanopaste))
		dam_amt = 5
		target.adjustToxLoss(10)
		if(affected)
			affected.receive_damage(5)

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)
		if(I && I.damage && !(I.tough))
			I.receive_damage(dam_amt,0)

	return SURGERY_STEP_RETRY

/datum/surgery_step/internal/manipulate_organs/extract
	name = "extract organ"
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/kitchen/utensil/fork = 70
	)

	var/obj/item/organ/internal/extracting = null

/datum/surgery_step/internal/manipulate_organs/extract/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/list/organs = target.get_organs_zone(target_zone)
	if(!length(organs))
		to_chat(user, "<span class='notice'>There are no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_BEGINSTEP_SKIP

	for(var/obj/item/organ/internal/O in organs)
		if(O.unremovable)
			continue
		O.on_find(user)
		organs -= O
		organs[O.name] = O

	var/obj/item/organ/internal/I = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
	if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
		extracting = organs[I]
		if(!extracting)
			return SURGERY_BEGINSTEP_SKIP
		user.visible_message(
			"[user] starts to separate [target]'s [I] with [tool].",
			"You start to separate [target]'s [I] with [tool] for removal."
		)
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/affected = H.get_organ(user.zone_selected)
		if(H && affected)
			H.custom_pain("The pain in your [affected.name] is living hell!")
	else
		return SURGERY_BEGINSTEP_SKIP

	return ..()

/datum/surgery_step/internal/manipulate_organs/extract/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!extracting || extracting.owner != target)
		user.visible_message(
			"<span class='notice'>[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>"
		)
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		"<span class='notice'> [user] has separated and extracts [target]'s [extracting] with [tool].</span>",
		"<span class='notice'> You have separated and extracted [target]'s [extracting] with [tool].</span>"
	)

	add_attack_logs(user, target, "Surgically removed [extracting.name]. INTENT: [uppertext(user.a_intent)]")
	spread_germs_to_organ(extracting, user, tool)
	var/obj/item/thing = extracting.remove(target)
	if(thing) // some "organs", like egg infections, can have I.remove(target) return null, and so we can't use "thing" in that case
		if(istype(thing))
			user.put_in_hands(thing)
		else
			thing.forceMove(get_turf(target))
	target.update_icons()

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/extract/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(extracting && extracting.owner == target)
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/affected = H.get_organ(user.zone_selected)
		if(affected)
			user.visible_message(
				"<span class='warning'> [user]'s hand slips, damaging [target]'s [affected.name] with [tool]!</span>",
				"<span class='warning'> Your hand slips, damaging [target]'s [affected.name] with [tool]!</span>"
			)
			affected.receive_damage(20)
		else
			user.visible_message(
				"<span class='warning'> [user]'s hand slips, damaging [target]'s [parse_zone(target_zone)] with [tool]!</span>",
				"<span class='warning'> Your hand slips, damaging [target]'s [parse_zone(target_zone)] with [tool]!</span>"
			)
		return SURGERY_STEP_RETRY
	else
		user.visible_message(
			"[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>"
		)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/implant
	name = "implant an organ"
	allowed_tools = list(
		/obj/item/organ/internal = 100,
		/obj/item/reagent_containers/food/snacks/organ = 0  // there for the flavor text
	)

/datum/surgery_step/internal/manipulate_organs/implant/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		to_chat(user, "<span class='warning'>[tool] was bitten by someone! It's too damaged to use!</span>")
		return SURGERY_BEGINSTEP_SKIP

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/organ/internal/I = tool
	if(!istype(I))
		// dunno how you got here but okay
		return SURGERY_BEGINSTEP_SKIP

	if(I.requires_robotic_bodypart)
		to_chat(user, "<span class='warning'>[I] is an organ that requires a robotic interface! [target]'s [parse_zone(target_zone)] does not have one.</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
		to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(I.damage > (I.max_damage * 0.75))
		to_chat(user, "<span class='notice'> [I] is in no state to be transplanted.</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(target.get_int_organ(I))
		to_chat(user, "<span class='warning'> [target] already has [I].</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(affected)
		user.visible_message(
			"[user] starts transplanting [tool] into [target]'s [affected.name].",
			"You start transplanting [tool] into [target]'s [affected.name]."
		)
		var/mob/living/carbon/human/H = target
		H.custom_pain("Someone's rooting around in your [affected.name]!")
	else
		user.visible_message(
			"[user] starts transplanting [tool] into [target]'s [parse_zone(target_zone)].",
			"You start transplanting [tool] into [target]'s [parse_zone(target_zone)]."
		)
	return ..()

/datum/surgery_step/internal/manipulate_organs/implant/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!istype(tool))
		return SURGERY_STEP_INCOMPLETE
	if(I.requires_robotic_bodypart)
		to_chat(user, "<span class='warning'>[I] is an organ that requires a robotic interface[target].</span>")
		return SURGERY_STEP_INCOMPLETE
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
		return SURGERY_STEP_INCOMPLETE
	I.insert(target)
	spread_germs_to_organ(I, user, tool)

	if(affected)
		user.visible_message("<span class='notice'> [user] has transplanted [tool] into [target]'s [affected.name].</span>",
		"<span class='notice'> You have transplanted [tool] into [target]'s [affected.name].</span>")
	else
		user.visible_message("<span class='notice'> [user] has transplanted [tool] into [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'> You have transplanted [tool] into [target]'s [parse_zone(target_zone)].</span>")

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/implant/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		"<span class='warning'>[user]'s hand slips, damaging [tool]!</span>",
		"<span class='warning'>Your hand slips, damaging [tool]!</span>"
	)
	var/obj/item/organ/internal/I = tool
	if(istype(I) && !I.tough)
		I.receive_damage(rand(3,5),0)

	return SURGERY_STEP_RETRY


/datum/surgery_step/internal/manipulate_organs/clean
	name = "clean and/or revive organs"
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/syringe = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
		/obj/item/reagent_containers/food/drinks/bottle = 80,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/glass/bucket = 50
	)

/datum/surgery_step/internal/manipulate_organs/clean/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/reagent_containers/C = tool

	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)
		if(!I)
			continue
		if(C.reagents.total_volume <= 0) //end_step handles if there is not enough reagent
			user.visible_message(
				"[user] notices [tool] is empty.",
				"You notice [tool] is empty."
			)
			return SURGERY_BEGINSTEP_SKIP

		var/msg = "[user] starts pouring some of [tool] over [target]'s [I.name]."
		var/self_msg = "You start pouring some of [tool] over [target]'s [I.name]."
		if(istype(C, /obj/item/reagent_containers/syringe))
			msg = "[user] begins injecting [tool] into [target]'s [I.name]."
			self_msg = "You begin injecting [tool] into [target]'s [I.name]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something burns horribly in your [parse_zone(target_zone)]!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/clean/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return SURGERY_STEP_INCOMPLETE
	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/list/organs = get_organ_list(target_zone, target, affected)

	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing
	var/spaceacillin = 0 //how much actual antibiotic is in the thing
	var/mito_tot = 0 // same for mito, thanks farie

	if(length(R.reagent_list))
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= length(R.reagent_list)

		mito_tot = R.get_reagent_amount("mitocholide")
		spaceacillin = R.get_reagent_amount("spaceacillin")


	for(var/obj/item/organ/internal/I in organs)
		if(!I)  // if you have a null organ I wish you the best
			continue
		if(I.germ_level < INFECTION_LEVEL_ONE / 2 && !(I.status & ORGAN_DEAD))  // not dead, don't need to inject mito either
			to_chat(user, "[I] does not appear to need chemical treatment.")
			continue
		if(!spaceacillin && !ethanol && !mito_tot)
			to_chat(user, "<span class='warning'>[C] doesn't have anything in it that would be worth applying!</span>")
			break
		var/success = FALSE
		if(I.germ_level >= INFECTION_LEVEL_ONE / 2)
			// spacecillin completely cures infections if there is enough, ethanol just reduces the infection strength by the amount used.
			if(spaceacillin || ethanol)
				if(spaceacillin >= GHETTO_DISINFECT_AMOUNT)
					I.germ_level = 0
				else
					I.germ_level = max(I.germ_level-ethanol, 0)
				success = TRUE // we actually injected some chemicals

			else if(!(I.status & ORGAN_DEAD)) // Not dead and got nothing to disinfect the organ with. Don't waste the other chems
				to_chat(user, "<span class='warning'>[I] does appear mildly infected but [C] does not seem to contain disinfectants. You decide to not inject the chemicals into [I].</span>")
				continue

		var/mito_trans
		if(mito_tot && (I.status & ORGAN_DEAD) && !I.is_robotic())
			mito_trans = min(mito_tot, C.amount_per_transfer_from_this / length(R.reagent_list)) // How much mito is actually transfered
			success = TRUE
		if(!success)
			to_chat(user, "<span class='warning'>[C] does not seem to have the chemicals needed to clean [I]. You decide against wasting chemicals.</span>")
			continue

		// now try actually injecting.

		if(istype(C, /obj/item/reagent_containers/syringe))
			user.visible_message(
				"<span class='notice'> [user] has injected [tool] into [target]'s [I.name].</span>",
				"<span class='notice'> You have injected [tool] into [target]'s [I.name].</span>"
			)
		else
			user.visible_message(
				"<span class='notice'> [user] has poured some of [tool] over [target]'s [I.name].</span>",
				"<span class='notice'> You have poured some of [tool] over [target]'s [I.name].</span>"
			)

		R.reaction(target, REAGENT_INGEST, R.total_volume / C.amount_per_transfer_from_this)
		R.trans_to(target, C.amount_per_transfer_from_this)

		if(mito_trans)
			mito_tot -= mito_trans
			if(I.is_robotic()) // Get out cyborg people
				continue
			if(mito_trans >= MITO_REVIVAL_COST)
				I.rejuvenate() // Just like splashing it onto it
				user.visible_message("<span class='warning'>\The [I] seems to regain its lively luster!</span>")
			else
				to_chat(user, "<span class='warning'>[I] does not seem to respond to the amount of mitocholide inside the injection. Try injecting more next time.</span>")

	return SURGERY_STEP_CONTINUE


/datum/surgery_step/internal/manipulate_organs/clean/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_STEP_INCOMPLETE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing

	if(length(R.reagent_list))
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= length(C.reagents.reagent_list)

	for(var/obj/item/organ/internal/I in target.get_organs_zone(target_zone))
		I.germ_level = max(I.germ_level-ethanol, 0)
		I.receive_damage(rand(4, 8), 0)

	R.trans_to(target, GHETTO_DISINFECT_AMOUNT * 10)
	R.reaction(target, REAGENT_INGEST)

	user.visible_message(
		"<span class='warning'> [user]'s hand slips, splashing the contents of [tool] all over [target][affected ? "'s [affected.name]" : ""] incision!</span>",
		"<span class='warning'> Your hand slips, splashing the contents of [tool] all over [target][affected ? "'s [affected.name]" : ""] incision!</span>"
	)
	// continue here since we want to keep moving in the surgery
	return SURGERY_STEP_CONTINUE

// FINISH
/datum/surgery_step/internal/manipulate_organs/finish
	name = "finish manipulation"
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 90
	)

/datum/surgery_step/internal/manipulate_organs/finish/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected && affected.encased)
		var/msg = "[user] starts bending [target]'s [affected.encased] back into place with [tool]."
		var/self_msg = "You start bending [target]'s [affected.encased] back into place with [tool]."
		user.visible_message(msg, self_msg)
	else
		var/msg = "[user] starts pulling [target]'s skin back into place with [tool]."
		var/self_msg = "You start pulling [target]'s skin back into place with [tool]."
		user.visible_message(msg, self_msg)

	if(H && affected)
		H.custom_pain("Something hurts horribly in your [affected.name]!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/finish/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg
	var/self_msg
	if(affected && affected.encased)
		msg = "<span class='notice'>[user] bends [target]'s [affected.encased] back into place with [tool].</span>"
		self_msg = "<span class='notice'> You bend [target]'s [affected.encased] back into place with [tool].</span>"
		affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	else
		msg = "<span class='notice'>[user] pulls [target]'s flesh back into place with [tool].</span>"
		self_msg = "<span class='notice'>You pull [target]'s flesh back into place with [tool].</span>"

	user.visible_message(msg, self_msg)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/finish/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg
	var/self_msg
	if(affected && affected.encased)
		msg = "<span class='warning'> [user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
		self_msg = "<span class='warning'> Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
		affected.fracture()
	else
		msg = "<span class='warning'> [user]'s hand slips, tearing the skin!</span>"
		self_msg = "<span class='warning'> Your hand slips, tearing skin!</span>"
	if(affected)
		affected.receive_damage(20)
	user.visible_message(msg, self_msg)
	return SURGERY_STEP_RETRY

//////////////////////////////////////////////////////////////////
//						SPESHUL AYLIUM STUPS					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/saw_carapace
	name = "saw carapace"
	allowed_tools = list(
		TOOL_SAW = 100,
		/obj/item/melee/energy/sword/cyborg/saw = 100,
		/obj/item/hatchet = 90
	)

	time = 5.4 SECONDS


/datum/surgery_step/saw_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	user.visible_message(
		"[user] begins to cut through [target]'s [target_zone] with [tool].",
		"You begin to cut through [target]'s [target_zone] with [tool]."
	)
	return ..()

/datum/surgery_step/saw_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	user.visible_message(
		"<span class='notice'> [user] has cut [target]'s [target_zone] open with [tool].</span>",
		"<span class='notice'> You have cut [target]'s [target_zone] open with [tool].</span>"
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/saw_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	user.visible_message(
		"<span class='warning'> [user]'s hand slips, cracking [target]'s [target_zone] with [tool]!</span>",
		"<span class='warning'> Your hand slips, cracking [target]'s [target_zone] with [tool]!</span>"
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/cut_carapace
	name = "cut carapace"
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 90,
		/obj/item/shard = 60,
		/obj/item/scissors = 12,
		/obj/item/butcher_chainsaw = 1,
		/obj/item/claymore = 6,
		/obj/item/melee/energy = 6,
		/obj/item/pen/edagger = 6
	)

	time = 1.6 SECONDS

/datum/surgery_step/cut_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	user.visible_message("[user] starts the incision on [target]'s [target_zone] with [tool].", \
	"You start the incision on [target]'s [target_zone] with [tool].")
	return ..()

/datum/surgery_step/cut_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	user.visible_message(
		"<span class='notice'> [user] has made an incision on [target]'s [target_zone] with [tool].</span>",
		"<span class='notice'> You have made an incision on [target]'s [target_zone] with [tool].</span>"
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cut_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	user.visible_message(
		"<span class='warning'>[user]'s hand slips, slicing open [target]'s [target_zone] in a wrong spot with [tool]!</span>",
		"<span class='warning'>Your hand slips, slicing open [target]'s [target_zone] in a wrong spot with [tool]!</span>"
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/retract_carapace
	name = "retract carapace"

	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		/obj/item/crowbar = 90,
		/obj/item/kitchen/utensil/fork = 60
	)

	time = 2.4 SECONDS

/datum/surgery_step/retract_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/msg = "[user] starts to pry open the incision on [target]'s [target_zone] with [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [target_zone] with [tool]."
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
	user.visible_message(msg, self_msg)
	return ..()

/datum/surgery_step/retract_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/msg = "<span class='notice'> [user] keeps the incision open on [target]'s [target_zone] with [tool].</span>"
	var/self_msg = "<span class='notice'> You keep the incision open on [target]'s [target_zone] with [tool].</span>"
	if(target_zone == BODY_ZONE_CHEST)
		msg = "<span class='notice'> [user] keeps the ribcage open on [target]'s torso with [tool].</span>"
		self_msg = "<span class='notice'> You keep the ribcage open on [target]'s torso with [tool].</span>"
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "<span class='notice'> [user] keeps the incision open on [target]'s lower abdomen with [tool].</span>"
		self_msg = "<span class='notice'> You keep the incision open on [target]'s lower abdomen with [tool].</span>"
	user.visible_message(msg, self_msg)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/retract_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/msg = "<span class='warning'> [user]'s hand slips, tearing the edges of incision on [target]'s [target_zone] with [tool]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, tearing the edges of incision on [target]'s [target_zone] with [tool]!</span>"
	if(target_zone == BODY_ZONE_CHEST)
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs in [target]'s torso with [tool]!</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs in [target]'s torso with [tool]!</span>"
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs in [target]'s lower abdomen with [tool]</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs in [target]'s lower abdomen with [tool]!</span>"
	user.visible_message(msg, self_msg)
	return SURGERY_STEP_RETRY

// redefine cauterize for every step because of course it relies on get_organ()
/datum/surgery_step/generic/seal_carapace/
	name = "seal carapace"

	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/seal_carapace/proc/zone_name(target_zone)
	var/zone = target_zone

	if(target_zone == BODY_ZONE_CHEST)
		zone = "torso"
	else if(target_zone == BODY_ZONE_PRECISE_GROIN)
		zone = "lower abdomen"

	return zone

/datum/surgery_step/generic/seal_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/zone = zone_name(target_zone)
	user.visible_message(
		"[user] is beginning to cauterize the incision on [target]'s [zone] with \the [tool].",
		"You are beginning to cauterize the incision on [target]'s [zone] with \the [tool]."
	)
	target.custom_pain("Your [zone] is being burned!")
	return ..()

/datum/surgery_step/generic/seal_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/zone = zone_name(target_zone)
	user.visible_message(
		"<span class='notice'>[user] cauterizes the incision on [target]'s [zone] with \the [tool].</span>",
		"<span class='notice'>You cauterize the incision on [target]'s [zone] with \the [tool].</span>"
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/seal_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/zone = zone_name(target_zone)
	user.visible_message(
		"<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [zone] with \the [tool]!</span>",
		"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [zone] with \the [tool]!</span>"
	)
	target.apply_damage(3, BURN, target_zone)
	return SURGERY_STEP_RETRY


#undef MITO_REVIVAL_COST
