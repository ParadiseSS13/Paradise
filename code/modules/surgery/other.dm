//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

/datum/surgery/infection
	name = "external infection treatment/autopsy"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand")

/datum/surgery/bleeding
	name = "internal bleeding"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders,/datum/surgery_step/generic/retract_skin,/datum/surgery_step/fix_vein,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head","groin", "l_arm", "r_arm", "l_leg", "r_leg", "r_hand", "l_hand")

/datum/surgery/bleeding/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected) return 0

		var/internal_bleeding = 0
		for(var/datum/wound/W in affected.wounds)
			if(W.internal)
				internal_bleeding = 1
				break
		if(internal_bleeding)
			return 1
		return 0

/datum/surgery_step/fix_vein
	name = "mend internal bleeding"
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	time = 32

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected) return 0

	var/internal_bleeding = 0
	for(var/datum/wound/W in affected.wounds)
		if(W.internal)
			internal_bleeding = 1
			break

	return affected.open == 2 && internal_bleeding

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [affected.name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in [affected.name] is unbearable!",1)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has patched the damaged vein in [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You have patched the damaged vein in [target]'s [affected.name] with \the [tool].</span>")

	for(var/datum/wound/W in affected.wounds) if(W.internal)
		affected.wounds -= W
		affected.update_damages()
	if (ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return 1

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>" , \
	"<span class='warning'> Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!</span>")
	affected.take_damage(5, 0)

	return 0

/datum/surgery_step/fix_dead_tissue		//Debridement
	name = "remove dead tissue"
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,		\
		/obj/item/weapon/kitchen/knife = 75,	\
		/obj/item/weapon/shard = 50, 		\
	)

	can_infect = 1
	blood_level = 1

	time = 16

/datum/surgery_step/fix_dead_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!hasorgans(target))
		return 0

	if (target_zone == "mouth" || target_zone == "eyes")
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	return affected && affected.open == 2 && (affected.status & ORGAN_DEAD)

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts cutting away necrotic tissue in [target]'s [affected.name] with \the [tool]." , \
	"You start cutting away necrotic tissue in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("The pain in [affected.name] is unbearable!",1)
	..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has cut away necrotic tissue in [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You have cut away necrotic tissue in [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 3

	return 1

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(CUT, 20, 1)

	return 0

/datum/surgery_step/treat_necrosis
	name = "treat necrosis"
	allowed_tools = list(
		/obj/item/weapon/reagent_containers/dropper = 100,
		/obj/item/weapon/reagent_containers/glass/bottle = 75,
		/obj/item/weapon/reagent_containers/glass/beaker = 75,
		/obj/item/weapon/reagent_containers/spray = 50,
		/obj/item/weapon/reagent_containers/glass/bucket = 50,
	)

	can_infect = 0
	blood_level = 0

	time = 24

/datum/surgery_step/fix_dead_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return 0

	var/obj/item/weapon/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		return 0

	if(!hasorgans(target))
		return 0

	if (target_zone == "mouth" || target_zone == "eyes")
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected.open == 3 && (affected.status & ORGAN_DEAD)

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts applying medication to the affected tissue in [target]'s [affected.name] with \the [tool]." , \
	"You start applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if (trans > 0)
		container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(container.reagents.has_reagent("mitocholide"))
			affected.status &= ~ORGAN_DEAD

		user.visible_message("<span class='notice'> [user] applies [trans] units of the solution to affected tissue in [target]'s [affected.name]</span>", \
			"<span class='notice'> You apply [trans] units of the solution to affected tissue in [target]'s [affected.name] with \the [tool].</span>")

	return 1

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message("<span class='warning'> [user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</span>" , \
	"<span class='warning'> Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!</span>")

	//no damage or anything, just wastes medicine


//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling 						//
//////////////////////////////////////////////////////////////////
/datum/surgery/remove_thrall
	name = "cleanse contaminations"//RENAME MEH
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,/datum/surgery_step/open_encased/retract, /datum/surgery_step/dethrall,/datum/surgery_step/glue_bone, /datum/surgery_step/set_bone,/datum/surgery_step/finish_bone,/datum/surgery_step/generic/cauterize)
	possible_locs = list("head")

/datum/surgery/remove_thrall/synth
	name = "cleanse contaminations"//RENAME MEH
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/internal/dethrall,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest")



/datum/surgery/remove_thrall/can_start(mob/user, mob/living/carbon/target)
	return is_thrall(target)//would this be too meta?

/datum/surgery/remove_thrall/synth/can_start(mob/user, mob/living/carbon/target)
	return is_thrall(target) && target.get_species() == "Machine"


/datum/surgery_step/dethrall
	name = "cleanse contamination"
	allowed_tools = list(/obj/item/device/flash = 100, /obj/item/device/flashlight/pen = 80, /obj/item/device/flashlight = 40)

	time = 30

/datum/surgery_step/internal/dethrall/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected && is_thrall(target) && affected.open_enough_for_surgery() && target_zone == target.named_organ_parent("brain")

/datum/surgery_step/internal/dethrall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/braincase = target.named_organ_parent("brain")
	user.visible_message("[user] reaches into [target]'s head with [tool].", "<span class='notice'>You begin aligning [tool]'s light to the tumor on [target]'s brain...</span>")
	target << "<span class='boldannounce'>A small part of your [braincase] pulses with agony as the light impacts it.</span>"
	..()

/datum/surgery_step/internal/dethrall/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	user.visible_message("[user] shines light onto the tumor in [target]'s head!", "<span class='notice'>You cleanse the contamination from [target]'s brain!</span>")
	ticker.mode.remove_thrall(target.mind,0)
	target.visible_message("<span class='warning'>A strange black mass falls from [target]'s head!</span>")
	new /obj/item/organ/internal/shadowtumor(get_turf(target))

	return 1

/datum/surgery_step/internal/dethrall/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/braincase = target.named_organ_parent("brain")
	if(prob(50))
		user.visible_message("<span class='warning'>[user] slips and rips the tumor out from [target]'s [braincase]!</span>", \
							 "<span class='warning'><b>You fumble and tear out [target]'s tumor!</span>")
		target.adjustBrainLoss(110) // This is so you can't just defib'n go
		ticker.mode.remove_thrall(target.mind,1)

		return 0
	else
		user.visible_message("<span class='warning'>[user]'s hand slips and fumbles! Luckily, they didn't damage anything!</span>")
		return 0
