//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

/datum/surgery/infection
	name = "External Infection Treatment"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/bleeding
	name = "Internal Bleeding"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders,/datum/surgery_step/generic/retract_skin,/datum/surgery_step/fix_vein,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/debridement
	name = "Debridement"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders,/datum/surgery_step/generic/retract_skin,/datum/surgery_step/fix_dead_tissue,/datum/surgery_step/treat_necrosis,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")

/datum/surgery/infection/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return FALSE
		if(affected.is_robotic())
			return FALSE
		return TRUE
	return FALSE

/datum/surgery/bleeding/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return FALSE

		if(affected.status & ORGAN_INT_BLEEDING)
			return TRUE
		return FALSE

/datum/surgery/debridement/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)

		if(!hasorgans(target))
			return FALSE

		if(!affected)
			return FALSE

		if(!(affected.status & ORGAN_DEAD))
			return FALSE

		return TRUE

	return FALSE

/datum/surgery_step/fix_vein
	name = "mend internal bleeding"
	allowed_tools = list(
	/obj/item/FixOVein = 100, \
	/obj/item/stack/cable_coil = 90
	)
	can_infect = TRUE
	blood_level = 1

	time = 32

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return FALSE

	if(affected.status & ORGAN_INT_BLEEDING)
		return TRUE

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [affected.name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in your [affected.name] is unbearable!")
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has patched the damaged vein in [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You have patched the damaged vein in [target]'s [affected.name] with \the [tool].</span>")

	affected.fix_internal_bleeding()
	if(ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return TRUE

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")
	affected.receive_damage(5, 0)

	return FALSE

/datum/surgery_step/fix_dead_tissue		//Debridement
	name = "remove dead tissue"
	allowed_tools = list(
		/obj/item/scalpel = 100,		\
		/obj/item/kitchen/knife = 90,	\
		/obj/item/shard = 60, 		\
	)

	can_infect = TRUE
	blood_level = 1

	time = 16

/datum/surgery_step/fix_dead_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!hasorgans(target))
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!affected)
		return FALSE

	if(!(affected.status & ORGAN_DEAD))
		return FALSE
	return TRUE

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts cutting away necrotic tissue in [target]'s [affected.name] with \the [tool]." , \
	"You start cutting away necrotic tissue in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in [affected.name] is unbearable!")
	..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has cut away necrotic tissue in [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You have cut away necrotic tissue in [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 3

	return TRUE

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.receive_damage(20)

	return FALSE

/datum/surgery_step/treat_necrosis
	name = "treat necrosis"
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
		/obj/item/reagent_containers/food/drinks/bottle = 80,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/glass/bucket = 50
	)

	can_infect = FALSE
	blood_level = 0

	time = 24

/datum/surgery_step/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!istype(tool, /obj/item/reagent_containers))
		return FALSE

	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		user.visible_message("[user] looks at \the [tool] and ponders." , \
		"You are not sure if \the [tool] contains mitocholide to treat the necrosis.")
		return FALSE

	if(!hasorgans(target))
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.status & ORGAN_DEAD))
		return FALSE
	return TRUE

/datum/surgery_step/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts applying medication to the affected tissue in [target]'s [affected.name] with \the [tool]." , \
	"You start applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!")
	..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return FALSE

	var/obj/item/reagent_containers/container = tool
	var/mitocholide = 0

	if(container.reagents.has_reagent("mitocholide"))
		mitocholide = 1

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if(trans > 0)
		container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(mitocholide)
			affected.status &= ~ORGAN_DEAD
			target.update_body()

		user.visible_message("<span class='notice'> [user] applies [trans] units of the solution to affected tissue in [target]'s [affected.name]</span>", \
			"<span class='notice'> You apply [trans] units of the solution to affected tissue in [target]'s [affected.name] with \the [tool].</span>")

	return TRUE

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message("<span class='warning'> [user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</span>" , \
	"<span class='warning'> Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</span>")

	//no damage or anything, just wastes medicine
