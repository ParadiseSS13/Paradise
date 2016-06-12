/datum/surgery/organ_manipulation
	name = "organ manipulation"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs, /datum/surgery_step/glue_bone, /datum/surgery_step/set_bone,/datum/surgery_step/finish_bone,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head")
	requires_organic_bodypart = 1

/datum/surgery/organ_manipulation/soft
	possible_locs = list("groin", "eyes", "mouth")
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs,/datum/surgery_step/generic/cauterize)
	requires_organic_bodypart = 1

/datum/surgery/organ_manipulation_boneless
	name = "organ manipulation"
	possible_locs = list("chest","head","groin", "eyes", "mouth")
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs,/datum/surgery_step/generic/cauterize)
	requires_organic_bodypart = 1

/datum/surgery/organ_manipulation/alien
	name = "alien organ manipulation"
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")
	allowed_mob = list(/mob/living/carbon/alien/humanoid)
	steps = list(/datum/surgery_step/saw_carapace,/datum/surgery_step/cut_carapace, /datum/surgery_step/retract_carapace,/datum/surgery_step/internal/manipulate_organs)


/datum/surgery/organ_manipulation/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(affected && (affected.status & ORGAN_ROBOT))
			return 0
		if(target.get_species() == "Machine")//i know organ robot might be enough but i am not taking chances...
			return 0
		if(affected && !affected.encased) //no bone, problem.
			return 0
		return 1

/datum/surgery/organ_manipulation_boneless/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)

		if(affected && (affected.status & ORGAN_ROBOT))
			return 0//no operating on robotic limbs in an organic surgery

		if(affected && affected.encased) //no bones no problem.
			return 0
		return 1

/datum/surgery/organ_manipulation/alien/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/alien/humanoid))
		return 1
	else return 0

// Internal surgeries.
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if (!hasorgans(target))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.open_enough_for_surgery()



/datum/surgery_step/internal/manipulate_organs
	name = "manipulate organs"
	allowed_tools = list(/obj/item/organ/internal = 100, /obj/item/weapon/reagent_containers/food/snacks/organ = 0)
	var/implements_extract = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/kitchen/utensil/fork = 55)
	var/implements_mend = list(/obj/item/stack/medical/advanced/bruise_pack = 100,/obj/item/stack/nanopaste = 100,/obj/item/stack/medical/bruise_pack = 20)
	//Finish is just so you can close up after you do other things.
	var/implements_finsh = list(/obj/item/weapon/scalpel/manager = 120,/obj/item/weapon/retractor = 100 ,/obj/item/weapon/crowbar = 75)
	var/current_type
	var/obj/item/organ/internal/I = null
	var/obj/item/organ/external/affected = null
	time = 64

/datum/surgery_step/internal/manipulate_organs/New()
	..()
	allowed_tools = allowed_tools + implements_extract + implements_mend + implements_finsh




/datum/surgery_step/internal/manipulate_organs/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	I = null
	var/mob/living/carbon/human/H
	if(istype(target,/mob/living/carbon/human))
		H = target
		affected = H.get_organ(target_zone)
	if(is_int_organ(tool))
		current_type = "insert"
		I = tool
		if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
			to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return -1

		if(I.damage > (I.max_damage * 0.75))
			to_chat(user, "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
			return -1

		if(target.get_int_organ(I))
			to_chat(user, "<span class='warning'> \The [target] already has [I].</span>")
			return -1
		if(affected)
			user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.name].", \
			"You start transplanting \the [tool] into [target]'s [affected.name].")
			H.custom_pain("Someone's rooting around in your [affected.name]!",1)
		else
			user.visible_message("[user] starts transplanting \the [tool] into [target]'s [parse_zone(target_zone)].", \
			"You start transplanting \the [tool] into [target]'s [parse_zone(target_zone)].")

	else if(implement_type in implements_finsh)
	//same as surgery step /datum/surgery_step/open_encased/close/
		current_type = "finish"

		if(affected && affected.encased)
			var/msg = "[user] starts bending [target]'s [affected.encased] back into place with \the [tool]."
			var/self_msg = "You start bending [target]'s [affected.encased] back into place with \the [tool]."
			user.visible_message(msg, self_msg)
		else
			var/msg = "[user] starts pulling [target]'s skin back into place with \the [tool]."
			var/self_msg = "You start pulling [target]'s skin back into place with \the [tool]."
			user.visible_message(msg, self_msg)
		if(affected)
			H.custom_pain("Something hurts horribly in your [affected.name]!",1)
	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.get_organs_zone(target_zone)
		if(!organs.len)
			to_chat(user, "<span class='notice'>There are no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
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
				user.visible_message("[user] starts to separate [target]'s [I] with \the [tool].", \
				"You start to separate [target]'s [I] with \the [tool] for removal." )
				if(affected)
					H.custom_pain("The pain in your [affected.name] is living hell!",1)
			else
				return -1

	else if(implement_type in implements_mend)
		current_type = "mend"
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		else if (istype(tool, /obj/item/stack/medical/bruise_pack))
			tool_name = "the bandaid"
		else if (istype(tool, /obj/item/stack/nanopaste))
			tool_name = "\the [tool]" //what else do you call nanopaste medically?

		if(!hasorgans(target))
			to_chat(user, "They do not have organs to mend!")
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic < 2 && !istype (tool, /obj/item/stack/nanopaste))
					if(!(I.sterile))
						spread_germs_to_organ(I, user)
					user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
					"You start treating damage to [target]'s [I.name] with [tool_name]." )
				else if(I.robotic >= 2 && istype(tool, /obj/item/stack/nanopaste))
					user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
					"You start treating damage to [target]'s [I.name] with [tool_name]." )

			to_chat(user, "[I] does not appear to be damaged.")
		H.custom_pain("The pain in your [affected.name] is living hell!",1)

	else if(istype(tool, /obj/item/weapon/reagent_containers/food/snacks/organ))
		to_chat(user, "<span class='warning'>[tool] was biten by someone! It's too damaged to use!</span>")
		return -1
	..()

/datum/surgery_step/internal/manipulate_organs/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(current_type == "mend")
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		if (istype(tool, /obj/item/stack/medical/bruise_pack))
			tool_name = "the bandaid"
		if (istype(tool, /obj/item/stack/nanopaste))
			tool_name = "\the [tool]" //what else do you call nanopaste medically?

		if (!hasorgans(target))
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I)
				I.surgeryize()
			if(I && I.damage > 0)
				if(I.robotic < 2 && !istype (tool, /obj/item/stack/nanopaste))
					user.visible_message("<span class='notice'> [user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
					"<span class='notice'> You treat damage to [target]'s [I.name] with [tool_name].</span>" )
					I.damage = 0
				else if(I.robotic >= 2 && istype (tool, /obj/item/stack/nanopaste))
					user.visible_message("<span class='notice'> [user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
					"<span class='notice'> You treat damage to [target]'s [I.name] with [tool_name].</span>" )
					I.damage = 0
		//return 1
	else if(current_type == "insert")
		I = tool
		user.drop_item()
		I.insert(target)
		spread_germs_to_organ(I, user)
		if(!user.canUnEquip(I, 0))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
			return 0

		if(affected)
			user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target]'s [affected.name].</span>", \
			"<span class='notice'> You have transplanted \the [tool] into [target]'s [affected.name].</span>")
		else
			user.visible_message("<span class='notice'> [user] has transplanted \the [tool] into [target]'s [affected.name].</span>", \
			"<span class='notice'> You have transplanted \the [tool] into [target]'s [parse_zone(target_zone)].</span>")
		I.status &= ~ORGAN_CUT_AWAY

	else if(current_type == "extract")
		if(I && I.owner == target)
			user.visible_message("<span class='notice'> [user] has separated and extracts [target]'s [I] with \the [tool].</span>" , \
			"<span class='notice'> You have separated and extracted [target]'s [I] with \the [tool].</span>")

			add_logs(target,user, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			spread_germs_to_organ(I, user)
			I.status |= ORGAN_CUT_AWAY
			I.remove(target)
			I.loc = get_turf(target)
		else
			user.visible_message("<span class='notice'>[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!</span>",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	else if(current_type == "finish")

		if(affected.encased)
			var/msg = "<span class='notice'> [user] bends [target]'s [affected.encased] back into place with \the [tool].</span>"
			var/self_msg = "<span class='notice'> You bend [target]'s [affected.encased] back into place with \the [tool].</span>"
			user.visible_message(msg, self_msg)
			affected.open = 2.5
		else
			var/msg = "<span class='notice'>[user] pulls [target]'s flesh back into place with \the [tool].</span>"
			var/self_msg = "<span class='notice'>You pull [target]'s flesh back into place with \the [tool].</span>"
			user.visible_message(msg, self_msg)

		return 1


	return 0

/datum/surgery_step/internal/manipulate_organs/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(current_type == "mend")
		if (!hasorgans(target))
			return

		user.visible_message("<span class='warning'> [user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>")
		var/dam_amt = 2

		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			target.adjustToxLoss(5)

		else if (istype(tool, /obj/item/stack/medical/bruise_pack) || istype(tool, /obj/item/stack/nanopaste))
			dam_amt = 5
			target.adjustToxLoss(10)
			affected.createwound(CUT, 5)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0 && !(I.tough))
				I.take_damage(dam_amt,0)

		return 0
	else if(current_type == "insert")

		user.visible_message("<span class='warning'> [user]'s hand slips, damaging \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, damaging \the [tool]!</span>")
		var/obj/item/organ/internal/I = tool
		if(istype(I) &&!(I.tough))
			I.take_damage(rand(3,5),0)
		return 0


	else if(current_type == "extract")
		if(I && I.owner == target)
			user.visible_message("<span class='warning'> [user]'s hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>", \
			"<span class='warning'> Your hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>")
			affected.createwound(BRUISE, 20)
		else
			user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
		return 0
	else if(current_type == "finish")
		if(affected.encased)
			var/msg = "<span class='warning'> [user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
			var/self_msg = "<span class='warning'> Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>"
			user.visible_message(msg, self_msg)
			affected.fracture()
		else
			var/msg = "<span class='warning'> [user]'s hand slips, tearing the skin!</span>"
			var/self_msg = "<span class='warning'> Your hand slips, tearing skin!</span>"
			user.visible_message(msg, self_msg)
		affected.createwound(BRUISE, 20)
		return 0


	return 0


//////////////////////////////////////////////////////////////////
//						SPESHUL AYLIUM STUPS					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/saw_carapace
	name = "saw carapace"
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/melee/energy/sword/cyborg/saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	time = 54


/datum/surgery_step/saw_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("[user] begins to cut through [target]'s [target_zone] with \the [tool].", \
	"You begin to cut through [target]'s [target_zone] with \the [tool].")
	..()

/datum/surgery_step/saw_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='notice'> [user] has cut [target]'s [target_zone] open with \the [tool].</span>",		\
	"<span class='notice'> You have cut [target]'s [target_zone] open with \the [tool].</span>")
	return 1

/datum/surgery_step/saw_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='warning'> [user]'s hand slips, cracking [target]'s [target_zone] with \the [tool]!</span>" , \
	"<span class='warning'> Your hand slips, cracking [target]'s [target_zone] with \the [tool]!</span>" )
	return 0

/datum/surgery_step/cut_carapace
	name = "cut carapace"
	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 115, \
	/obj/item/weapon/scalpel/laser2 = 110, \
	/obj/item/weapon/scalpel/laser1 = 105, \
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchen/knife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	/obj/item/weapon/scissors = 10,		\
	/obj/item/weapon/twohanded/chainsaw = 1, \
	/obj/item/weapon/claymore = 5, \
	/obj/item/weapon/melee/energy/ = 5, \
	/obj/item/weapon/pen/edagger = 5,  \
	)

	time = 16

/datum/surgery_step/cut_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("[user] starts the incision on [target]'s [target_zone] with \the [tool].", \
	"You start the incision on [target]'s [target_zone] with \the [tool].")
	..()

/datum/surgery_step/cut_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='notice'> [user] has made an incision on [target]'s [target_zone] with \the [tool].</span>", \
	"<span class='notice'> You have made an incision on [target]'s [target_zone] with \the [tool].</span>",)
	return 1

/datum/surgery_step/cut_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='warning'> [user]'s hand slips, slicing open [target]'s [target_zone] in a wrong spot with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing open [target]'s [target_zone] in a wrong spot with \the [tool]!</span>")
	return 0

/datum/surgery_step/retract_carapace
	name = "retract carapace"

	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	time = 24

/datum/surgery_step/retract_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/msg = "[user] starts to pry open the incision on [target]'s [target_zone] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [target_zone] with \the [tool]."
	if (target_zone == "chest")
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if (target_zone == "groin")
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	..()

/datum/surgery_step/retract_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/msg = "<span class='notice'> [user] keeps the incision open on [target]'s [target_zone] with \the [tool]</span>."
	var/self_msg = "<span class='notice'> You keep the incision open on [target]'s [target_zone] with \the [tool].</span>"
	if (target_zone == "chest")
		msg = "<span class='notice'> [user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the ribcage open on [target]'s torso with \the [tool].</span>"
	if (target_zone == "groin")
		msg = "<span class='notice'> [user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	return 1

/datum/surgery_step/generic/retract_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/msg = "<span class='warning'> [user]'s hand slips, tearing the edges of incision on [target]'s [target_zone] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, tearing the edges of incision on [target]'s [target_zone] with \the [tool]!</span>"
	if (target_zone == "chest")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
	if (target_zone == "groin")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	return 0
