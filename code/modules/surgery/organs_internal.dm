#define GHETTO_DISINFECT_AMOUNT 5 //Amount of units to transfer from the container to the organs during ghetto surgery disinfection step
#define MITO_REVIVAL_COST 3
// Internal surgeries.
/datum/surgery_step/internal
	priority = 20 // Usually what you want to do
	can_infect = TRUE
	blood_level = 1

/datum/surgery_step/internal/manipulate_organs
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_OPEN_INCISION_BONES, SURGERY_STAGE_CARAPACE_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	time = 64

/datum/surgery_step/internal/manipulate_organs/is_valid_target(mob/living/carbon/target)
	return ishuman(target) || isalienadult(target)

/datum/surgery_step/internal/manipulate_organs/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	if(ishuman(target))
		if(target_zone != "eyes" && target_zone != "mouth") // Head will be the external organ. Which is encased
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			if(affected.encased && current_stage != SURGERY_STAGE_OPEN_INCISION_BONES)
				return FALSE
	return TRUE

/datum/surgery_step/internal/manipulate_organs/heal_organs
	name = "heal organs"
	allowed_surgery_tools = SURGERY_TOOLS_HEAL_ORGAN

/datum/surgery_step/internal/manipulate_organs/heal_organs/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/tool_name = "[tool]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		tool_name = "regenerative membrane"

	var/list/organs = target.get_organs_zone(target_zone)
	if(!organs.len)
		to_chat(user, "<span class='notice'>[target]'s [target_zone] does not seem to have any organs.</span>")
		return SURGERY_FAILED

	for(var/obj/item/organ/internal/I in organs)
		if(I && I.damage)
			if(!I.is_robotic() && !istype(tool, /obj/item/stack/nanopaste))
				if(!(I.sterile))
					spread_germs_to_organ(I, user, tool)
				user.visible_message("<span class='notice'>[user] starts treating damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'>You start treating damage to [target]'s [I.name] with [tool_name].</span>" )
			else if(I.is_robotic() && istype(tool, /obj/item/stack/nanopaste))
				user.visible_message("<span class='notice'>[user] starts treating damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'>You start treating damage to [target]'s [I.name] with [tool_name].</span>" )

		else
			to_chat(user, "<span class='notice'>[I] does not appear to be damaged.</span>")

	if(affected && ishuman(target))
		var/mob/living/carbon/human/H = target
		H.custom_pain("The pain in your [affected.name] is living hell!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/heal_organs/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = "[tool]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		tool_name = "regenerative membrane"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"
	if(istype(tool, /obj/item/stack/nanopaste))
		tool_name = "[tool]" //what else do you call nanopaste medically?

	for(var/obj/item/organ/internal/I in target.get_organs_zone(target_zone))
		if(I)
			I.surgeryize()
		if(I && I.damage)
			if(!I.is_robotic() && !istype(tool, /obj/item/stack/nanopaste))
				user.visible_message("<span class='notice'> [user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'> You treat damage to [target]'s [I.name] with [tool_name].</span>" )
				I.damage = 0
			else if(I.is_robotic() && istype(tool, /obj/item/stack/nanopaste))
				user.visible_message("<span class='notice'> [user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'> You treat damage to [target]'s [I.name] with [tool_name].</span>" )
				I.damage = 0

	return SURGERY_SUCCESS

/datum/surgery_step/internal/manipulate_organs/heal_organs/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, getting mess and tearing the inside of [target][affected ? "'s [affected.name]" : ""] with [tool]!</span>", \
		"<span class='warning'> Your hand slips, getting mess and tearing the inside of [target][affected ? "'s [affected.name]" : ""] with [tool]!</span>")
	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack) || istype(tool, /obj/item/stack/nanopaste))
		dam_amt = 5
		target.adjustToxLoss(10)
		if(affected)
			affected.receive_damage(5)
		else
			target.apply_damage(5, BRUTE, target_zone)

	for(var/obj/item/organ/internal/I in target.get_organs_zone(target_zone))
		if(I && I.damage && !(I.tough))
			I.receive_damage(dam_amt,0)

	return SURGERY_FAILED

/datum/surgery_step/internal/manipulate_organs/clean
	name = "clean organs"
	allowed_surgery_tools = SURGERY_TOOLS_CLEAN_ORGAN

/datum/surgery_step/internal/manipulate_organs/clean/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_FAILED

	var/obj/item/reagent_containers/C = tool

	var/list/organs = target.get_organs_zone(target_zone)
	if(!organs.len)
		to_chat(user, "<span class='notice'>[target]'s [target_zone] does not seem to have any organs.</span>")
		return SURGERY_FAILED

	for(var/obj/item/organ/internal/I in organs)
		if(I)
			if(C.reagents.total_volume <= 0) //end_step handles if there is not enough reagent
				user.visible_message("[user] notices [tool] is empty.", \
				"You notice [tool] is empty.")
				return SURGERY_FAILED

			var/msg = "[user] starts pouring some of [tool] over [target]'s [I.name]."
			var/self_msg = "You start pouring some of [tool] over [target]'s [I.name]."
			if(istype(C,/obj/item/reagent_containers/syringe))
				msg = "[user] begins injecting [tool] into [target]'s [I.name]."
				self_msg = "You begin injecting [tool] into [target]'s [I.name]."
			user.visible_message(msg, self_msg)
			if(target && affected && ishuman(target))
				var/mob/living/carbon/human/H = target
				H.custom_pain("Something burns horribly in your [affected.name]!")
	return ..()

/datum/surgery_step/internal/manipulate_organs/clean/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!istype(tool,/obj/item/reagent_containers))
		return SURGERY_FAILED
	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing
	var/spaceacillin = 0 //how much actual antibiotic is in the thing
	var/mito_tot = 0
	if(R.reagent_list.len)
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= R.reagent_list.len
		mito_tot = R.get_reagent_amount("mitocholide")
		spaceacillin = R.get_reagent_amount("spaceacillin")

	for(var/obj/item/organ/internal/I in target.get_organs_zone(target_zone))
		if(I)
			if(R.total_volume < GHETTO_DISINFECT_AMOUNT)
				user.visible_message("<span class='notice'>[user] notices there is not enough in [tool].</span>", \
				"<span class='warning'>You notice there is not enough in [tool].</span>")
				break
			if(I.germ_level < INFECTION_LEVEL_ONE / 2 && !(I.status & ORGAN_DEAD))
				to_chat(user, "<span class='notice'>[I] does not appear to be infected.</span>")
				continue // Not dead so no need to inject
			var/success = FALSE
			if(I.germ_level >= INFECTION_LEVEL_ONE / 2)
				if(spaceacillin || ethanol)
					if(spaceacillin >= GHETTO_DISINFECT_AMOUNT)
						I.germ_level = 0
					else
						I.germ_level = max(I.germ_level-ethanol, 0)
					success = TRUE // Actually inject chems
				else if(!(I.status & ORGAN_DEAD)) // Not dead and got nothing to disinfect the organ with. Don't waste the other chems
					to_chat(user, "<span class='warning'>[I] does appear mildly infected but [C] does not seem to contain disinfectants. You decide to not inject the chemicals into [I].</span>")
					continue
			var/mito_trans
			if(mito_tot && (I.status & ORGAN_DEAD) && !I.is_robotic())
				mito_trans = min(mito_tot, C.amount_per_transfer_from_this / R.reagent_list.len)// How much mito is actually transfered
				success = TRUE
			if(!success)
				to_chat(user, "<span class='warning'>[C] does not seem to have the chemicals needed to clean [I]. You decide against wasting chemicals.</span>")
				continue
			if(istype(C, /obj/item/reagent_containers/syringe))
				user.visible_message("<span class='notice'> [user] has injected [tool] into [target]'s [I.name].</span>",
					"<span class='notice'> You have injected [tool] into [target]'s [I.name].</span>")
			else
				user.visible_message("<span class='notice'> [user] has poured some of [tool] over [target]'s [I.name].</span>",
					"<span class='notice'> You have poured some of [tool] over [target]'s [I.name].</span>")
			
			R.reaction(target, INGEST, R.total_volume / C.amount_per_transfer_from_this)
			R.trans_to(target, C.amount_per_transfer_from_this)
			
			if(mito_trans)
				mito_tot -= mito_trans
				if(I.is_robotic()) // Get out cyborg people
					continue
				if(mito_trans >= MITO_REVIVAL_COST)
					I.rejuvenate() // Just like splashing it onto it
				else
					to_chat(user, "<span class='warning'>[I] does not seem to respond to the amount of mitocholide inside the injection. Try injecting more next time.</span>")
				
	return SURGERY_SUCCESS

/datum/surgery_step/internal/manipulate_organs/clean/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!istype(tool,/obj/item/reagent_containers))
		return SURGERY_FAILED
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing

	if(R.reagent_list.len)
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= C.reagents.reagent_list.len

	for(var/obj/item/organ/internal/I in target.get_organs_zone(target_zone))
		I.germ_level = max(I.germ_level-ethanol, 0)
		I.receive_damage(rand(4,8),0)

	R.trans_to(target, GHETTO_DISINFECT_AMOUNT * 10)
	R.reaction(target, INGEST)

	user.visible_message("<span class='warning'> [user]'s hand slips, splashing the contents of [tool] all over [target][affected ? "'s [affected.name]" : ""] incision!</span>", \
		"<span class='warning'> Your hand slips, splashing the contents of [tool] all over [target][affected ? "'s [affected.name]" : ""] incision!</span>")
	return SURGERY_FAILED

/datum/surgery_step/internal/manipulate_organs/extract
	name = "extract organ"
	allowed_surgery_tools = SURGERY_TOOLS_EXTRACT_ORGAN
	var/obj/item/organ/internal/organ_being_removed = null

/datum/surgery_step/internal/manipulate_organs/extract/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	organ_being_removed = null
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/mob/living/simple_animal/borer/B = target.has_brain_worms()
	if(target_zone == "head" && B)
		user.visible_message("<span class='notice'>[user] begins to extract [B] from [target]'s [parse_zone(target_zone)].</span>",
				"<span class='notice'>You begin to extract [B] from [target]'s [parse_zone(target_zone)]...</span>")
		return ..()

	var/list/organs = target.get_organs_zone(target_zone)
	if(!organs.len)
		to_chat(user, "<span class='notice'>There are no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_FAILED

	for(var/obj/item/organ/internal/O in organs)
		if(O.unremovable)
			continue
		O.on_find(user)
		organs -= O
		organs[O.name] = O

	organ_being_removed = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
	if(organ_being_removed && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
		organ_being_removed = organs[organ_being_removed]
		if(!organ_being_removed)
			return SURGERY_FAILED
		user.visible_message("<span class='notice'>[user] starts to separate [target]'s [organ_being_removed] with [tool].</span>", \
		"<span class='notice'>You start to separate [target]'s [organ_being_removed] with [tool] for removal.</span>" )
		if(target && affected && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.custom_pain("The pain in your [affected.name] is living hell!")
	else
		return SURGERY_FAILED

	return ..()


/datum/surgery_step/internal/manipulate_organs/extract/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/simple_animal/borer/B = target.has_brain_worms()
	if(target_zone == "head" && B && B.host == target)
		user.visible_message("<span class='notice'>[user] successfully extracts [B] from [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>You successfully extract [B] from [target]'s [parse_zone(target_zone)].</span>")
		add_attack_logs(user, target, "Surgically removed [B]. INTENT: [uppertext(user.a_intent)]")
		B.leave_host()
		return SURGERY_SUCCESS
	if(organ_being_removed && organ_being_removed.owner == target)
		user.visible_message("<span class='notice'> [user] has separated and extracts [target]'s [organ_being_removed] with [tool].</span>",
		"<span class='notice'> You have separated and extracted [target]'s [organ_being_removed] with [tool].</span>")

		add_attack_logs(user, target, "Surgically removed [organ_being_removed.name]. INTENT: [uppertext(user.a_intent)]")
		spread_germs_to_organ(organ_being_removed, user, tool)
		var/obj/item/thing = organ_being_removed.remove(target)
		if(!istype(thing))
			thing.forceMove(get_turf(target))
		else
			user.put_in_hands(thing)

		target.update_icons()
	else
		user.visible_message("<span class='notice'>[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")

	return SURGERY_SUCCESS

/datum/surgery_step/internal/manipulate_organs/extract/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(organ_being_removed && organ_being_removed.owner == target)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(affected)
			user.visible_message("<span class='warning'> [user]'s hand slips, damaging [target]'s [affected.name] with [tool]!</span>", \
			"<span class='warning'> Your hand slips, damaging [target]'s [affected.name] with [tool]!</span>")
			affected.receive_damage(20)
		else
			user.visible_message("<span class='warning'> [user]'s hand slips, damaging [target]'s [parse_zone(target_zone)] with [tool]!</span>", \
			"<span class='warning'> Your hand slips, damaging [target]'s [parse_zone(target_zone)] with [tool]!</span>")
	else
		user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	return SURGERY_FAILED

/datum/surgery_step/internal/manipulate_organs/implant
	name = "implant organ"
	accept_any_item = TRUE // can_use will check if it's an organ or not

/datum/surgery_step/internal/manipulate_organs/implant/can_use(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	return istype(tool, /obj/item/reagent_containers/food/snacks/organ) || istype(tool, /obj/item/organ/internal)

/datum/surgery_step/internal/manipulate_organs/implant/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		to_chat(user, "<span class='warning'>[tool] was bitten by someone! It's too damaged to use!</span>")
		return SURGERY_FAILED
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/organ/internal/I = tool
	if(I.requires_robotic_bodypart)
		to_chat(user, "<span class='warning'>[I] is an organ that requires a robotic interface[target].</span>")
		return SURGERY_FAILED
	if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
		to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_FAILED

	if(I.damage > (I.max_damage * 0.75))
		to_chat(user, "<span class='notice'> [I] is in no state to be transplanted.</span>")
		return SURGERY_FAILED

	if(target.get_int_organ(I))
		to_chat(user, "<span class='warning'> [target] already has [I].</span>")
		return SURGERY_FAILED

	if(affected)
		user.visible_message("<span class='notice'>[user] starts transplanting [tool] into [target]'s [affected.name].", \
		"<span class='notice'>You start transplanting [tool] into [target]'s [affected.name].")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.custom_pain("Someone's rooting around in your [affected.name]!")
	else
		user.visible_message("<span class='notice'>[user] starts transplanting [tool] into [target]'s [parse_zone(target_zone)].</span>", \
		"<span class='notice'>You start transplanting [tool] into [target]'s [parse_zone(target_zone)].</span>")

	return ..()

/datum/surgery_step/internal/manipulate_organs/implant/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool
	if(I.requires_robotic_bodypart)
		to_chat(user, "<span class='warning'>[I] is an organ that requires a robotic interface[target].</span>")
		return SURGERY_FAILED
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
		return SURGERY_FAILED
	I.insert(target)
	spread_germs_to_organ(I, user, tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected)
		user.visible_message("<span class='notice'> [user] has transplanted [tool] into [target]'s [affected.name].</span>",
		"<span class='notice'> You have transplanted [tool] into [target]'s [affected.name].</span>")
	else
		user.visible_message("<span class='notice'> [user] has transplanted [tool] into [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'> You have transplanted [tool] into [target]'s [parse_zone(target_zone)].</span>")

	return SURGERY_SUCCESS

/datum/surgery_step/internal/manipulate_organs/implant/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, damaging [tool]!</span>", \
	"<span class='warning'> Your hand slips, damaging [tool]!</span>")
	var/obj/item/organ/internal/I = tool
	if(istype(I) && !I.tough)
		I.receive_damage(rand(3,5),0)

	return SURGERY_FAILED

//////////////////////////////////////////////////////////////////
//						SPESHUL AYLIUM STUPS					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/alien/is_valid_target(mob/living/carbon/alien/humanoid/target)
	return isalienadult(target)

/datum/surgery_step/alien/saw_carapace
	name = "saw carapace"
	allowed_surgery_tools = SURGERY_TOOLS_SAW_BONE
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_CARAPACE_SAWN
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")

	time = 54

/datum/surgery_step/alien/saw_carapace/begin_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to cut through [target]'s [target_zone] with [tool].", \
	"You begin to cut through [target]'s [target_zone] with [tool].")
	..()

/datum/surgery_step/alien/saw_carapace/end_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool,datum/surgery/surgery)
	user.visible_message("<span class='notice'> [user] has cut [target]'s [target_zone] open with [tool].</span>",		\
	"<span class='notice'> You have cut [target]'s [target_zone] open with [tool].</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/alien/saw_carapace/fail_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, cracking [target]'s [target_zone] with [tool]!</span>" , \
	"<span class='warning'> Your hand slips, cracking [target]'s [target_zone] with [tool]!</span>" )
	return SURGERY_FAILED

/datum/surgery_step/alien/cut_carapace
	name = "cut carapace"
	allowed_surgery_tools = SURGERY_TOOLS_INCISION
	surgery_start_stage = SURGERY_STAGE_CARAPACE_SAWN
	next_surgery_stage = SURGERY_STAGE_CARAPACE_CUT
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")
	time = 16

/datum/surgery_step/alien/cut_carapace/begin_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] starts the incision on [target]'s [target_zone] with [tool].</span>", \
	"<span class='notice'>You start the incision on [target]'s [target_zone] with [tool].</span>")
	return ..()

/datum/surgery_step/alien/cut_carapace/end_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool,datum/surgery/surgery)
	user.visible_message("<span class='notice'> [user] has made an incision on [target]'s [target_zone] with [tool].</span>", \
	"<span class='notice'> You have made an incision on [target]'s [target_zone] with [tool].</span>",)
	return SURGERY_SUCCESS

/datum/surgery_step/alien/cut_carapace/fail_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, slicing open [target]'s [target_zone] in a wrong spot with [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing open [target]'s [target_zone] in a wrong spot with [tool]!</span>")
	return SURGERY_FAILED

/datum/surgery_step/retract_carapace
	name = "retract carapace"
	allowed_surgery_tools = SURGERY_TOOLS_RETRACT_SKIN
	surgery_start_stage = SURGERY_STAGE_CARAPACE_CUT
	next_surgery_stage = SURGERY_STAGE_CARAPACE_OPEN
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")
	time = 24

/datum/surgery_step/retract_carapace/begin_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/msg = "[user] starts to pry open the incision on [target]'s [target_zone] with [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [target_zone] with [tool]."
	if(target_zone == "chest")
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with [tool]."
	if(target_zone == "groin")
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with [tool]."
	user.visible_message("<span class='notice'>[msg]</span>", "<span class='notice'>[self_msg]</span")
	return ..()

/datum/surgery_step/retract_carapace/end_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/msg = "<span class='notice'> [user] keeps the incision open on [target]'s [target_zone] with [tool]</span>."
	var/self_msg = "<span class='notice'> You keep the incision open on [target]'s [target_zone] with [tool].</span>"
	if(target_zone == "chest")
		msg = "<span class='notice'> [user] keeps the ribcage open on [target]'s torso with [tool].</span>"
		self_msg = "<span class='notice'> You keep the ribcage open on [target]'s torso with [tool].</span>"
	if(target_zone == "groin")
		msg = "<span class='notice'> [user] keeps the incision open on [target]'s lower abdomen with [tool].</span>"
		self_msg = "<span class='notice'> You keep the incision open on [target]'s lower abdomen with [tool].</span>"
	user.visible_message(msg, self_msg)
	return SURGERY_SUCCESS

/datum/surgery_step/generic/retract_carapace/fail_step(mob/living/user, mob/living/carbon/alien/humanoid/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/msg = "<span class='warning'> [user]'s hand slips, tearing the edges of incision on [target]'s [target_zone] with [tool]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, tearing the edges of incision on [target]'s [target_zone] with [tool]!</span>"
	if(target_zone == "chest")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s torso with [tool]!</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s torso with [tool]!</span>"
	if(target_zone == "groin")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s lower abdomen with [tool]</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s lower abdomen with [tool]!</span>"
	user.visible_message(msg, self_msg)
	return SURGERY_FAILED
