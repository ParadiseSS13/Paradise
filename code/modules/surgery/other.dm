//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/debridement
	name = "disinfect wound"
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand", "r_foot", "l_foot")
	surgery_start_stage = SURGERY_STAGE_INCISION
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_tools = SURGERY_TOOLS_CAUTERIZE
	time = 24

/datum/surgery_step/generic/cut_open/cut_further // Debridement and cavity surgery
	name = "cut tissue"
	priority = 1
	surgery_start_stage = SURGERY_STAGE_OPEN_INCISION
	next_surgery_stage = SURGERY_STAGE_OPEN_INCISION_CUT

/datum/surgery_step/generic/cut_open/cut_further/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/dead_flesh = (affected.status & ORGAN_DEAD)
	user.visible_message("<span class='notice'>[user] starts cutting away [dead_flesh ? "necrotic" : ""] tissue in [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'>You start cutting away [dead_flesh ? "necrotic" : ""] tissue in [target]'s [affected.name] with \the [tool].</span>")
	target.custom_pain("The pain in [affected.name] is unbearable!")
	return ..()

/datum/surgery_step/generic/cut_open/cut_further/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/dead_flesh = (affected.status & ORGAN_DEAD)
	user.visible_message("<span class='notice'> [user] has cut away [dead_flesh ? "necrotic" : ""] tissue in [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You have cut away [dead_flesh ? "necrotic" : ""] tissue in [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 3

	return SURGERY_SUCCESS

/datum/surgery_step/generic/cut_open/cut_further/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.receive_damage(20)

	return SURGERY_FAILED

/datum/surgery_step/fix_vein
	name = "mend internal bleeding"
	surgery_start_stage = SURGERY_STAGE_OPEN_INCISION
	next_surgery_stage = SURGERY_STAGE_SAME
	allowed_surgery_tools = SURGERY_TOOLS_MEND_INTERNAL_BLEEDING
	can_infect = TRUE
	blood_level = 1

	time = 32

/datum/surgery_step/fix_vein/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target)

/datum/surgery_step/fix_vein/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected.internal_bleeding

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts patching the damaged vein in [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'>You start patching the damaged vein in [target]'s [affected.name] with \the [tool].</span>")
	target.custom_pain("The pain in [affected.name] is unbearable!")
	return ..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has patched the damaged vein in [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You have patched the damaged vein in [target]'s [affected.name] with \the [tool].</span>")

	affected.internal_bleeding = FALSE
	if(ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return SURGERY_SUCCESS

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")
	affected.receive_damage(5, 0)

	return SURGERY_FAILED

/datum/surgery_step/treat_necrosis
	name = "treat necrosis"
	surgery_start_stage = SURGERY_STAGE_OPEN_INCISION_CUT
	next_surgery_stage = SURGERY_STAGE_OPEN_INCISION
	allowed_surgery_tools = SURGERY_TOOLS_CLEAN_ORGAN

	time = 24

/datum/surgery_step/treat_necrosis/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target)

/datum/surgery_step/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE

	if(!istype(tool, /obj/item/reagent_containers))
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.status & ORGAN_DEAD))
		return FALSE
	return TRUE

/datum/surgery_step/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		user.visible_message("<span class='notice'>[user] looks at \the [tool] and ponders.</span>" , \
		"<span class='notice'>You are not sure if \the [tool] contains mitocholide to treat the necrosis.</span>")
		return SURGERY_FAILED
	
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'>You start applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].</span>")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!")
	return ..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_FAILED

	var/obj/item/reagent_containers/container = tool
	var/has_mitocholide = FALSE

	if(container.reagents.has_reagent("mitocholide"))
		has_mitocholide = TRUE

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if(trans > 0)
		container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(has_mitocholide)
			affected.status &= ~ORGAN_DEAD
			affected.germ_level = 0
			target.update_body()

		user.visible_message("<span class='notice'> [user] applies [trans] units of the solution to affected tissue in [target]'s [affected.name]</span>", \
			"<span class='notice'> You apply [trans] units of the solution to affected tissue in [target]'s [affected.name] with \the [tool].</span>")

	return SURGERY_SUCCESS

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_FAILED

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message("<span class='warning'> [user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</span>" , \
	"<span class='warning'> Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</span>")

	return SURGERY_FAILED
	//no damage or anything, just wastes medicine


//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling 						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/dethrall
	name = "cleanse contamination"
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_ROBOTIC_HATCH_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	possible_locs = list("head", "chest", "groin")
	allowed_surgery_tools = SURGERY_TOOLS_DETHRALL
	blood_level = 0
	requires_organic_bodypart = FALSE
	time = 30

/datum/surgery_step/internal/dethrall/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target) && is_thrall(target)

/datum/surgery_step/internal/dethrall/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!B || !(B in affected.internal_organs))
		return FALSE
	return TRUE

/datum/surgery_step/internal/dethrall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/braincase = target.named_organ_parent("brain")
	user.visible_message("<span class='notice'>[user] reaches into [target]'s head with [tool].</span>", "<span class='notice'>You begin aligning [tool]'s light to the tumor on [target]'s brain...</span>")
	to_chat(target, "<span class='boldannounce'>A small part of your [braincase] pulses with agony as the light impacts it.</span>")
	return ..()

/datum/surgery_step/internal/dethrall/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(isshadowlinglesser(target)) //Empowered thralls cannot be deconverted
		to_chat(target, "<span class='shadowling'><b><i>NOT LIKE THIS!</i></b></span>")
		user.visible_message("<span class='warning'>[target] suddenly slams upward and knocks down [user]!</span>", \
							 "<span class='userdanger'>[target] suddenly bolts up and slams you with tremendous force!</span>")
		user.StopResting() //Remove all stuns
		user.SetSleeping(0)
		user.SetStunned(0)
		user.SetWeakened(0)
		user.SetParalysis(0)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.Weaken(6)
			C.apply_damage(20, BRUTE, "chest")
		else if(issilicon(user))
			var/mob/living/silicon/S = user
			S.Weaken(8)
			S.apply_damage(20, BRUTE)
			playsound(S, 'sound/effects/bang.ogg', 50, 1)
		return SURGERY_FAILED
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/E = target.get_organ(check_zone(B.parent_organ))
	user.visible_message("<span class='notice'>[user] shines light onto the tumor in [target]'s [E]!</span>", "<span class='notice'>You cleanse the contamination from [target]'s brain!</span>")
	if(target.vision_type) //Turns off their darksight if it's still active.
		to_chat(target, "<span class='boldannounce'>Your eyes are suddenly wrought with immense pain as your darksight is forcibly dismissed!</span>")
		target.vision_type = null
	SSticker.mode.remove_thrall(target.mind, 0)
	target.visible_message("<span class='warning'>A strange black mass falls from [target]'s [E]!</span>")
	var/obj/item/organ/thing = new /obj/item/organ/internal/shadowtumor(get_turf(target))
	thing.set_dna(target.dna)
	user.put_in_hands(thing)
	return SURGERY_SUCCESS
