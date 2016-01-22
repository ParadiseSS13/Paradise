/datum/surgery/organ_manipulation
	name = "organ manipulation"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/manipulate_organs, /datum/surgery_step/glue_bone, /datum/surgery_step/set_bone,/datum/surgery_step/finish_bone,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head")
	requires_organic_bodypart = 0
	disallowed_mob = (/mob/living/carbon/human/machine)

/datum/surgery/organ_manipulation/soft
	possible_locs = list("groin", "eyes", "mouth")
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs,/datum/surgery_step/generic/cauterize)

/datum/surgery/organ_manipulation/boneless
	possible_locs = list("chest","head","groin", "eyes", "mouth")
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/internal/manipulate_organs,/datum/surgery_step/generic/cauterize)
	allowed_mob = list(/mob/living/carbon/human/diona,/mob/living/carbon/human/slime)
	disallowed_mob = list(/mob/living/carbon/human)

/datum/surgery/organ_manipulation/alien
	name = "alien organ manipulation"
	possible_locs = list("chest", "head", "groin", "eyes", "mouth")
	allowed_mob = list(/mob/living/carbon/alien/humanoid)
	disallowed_mob = list(/mob/living/carbon/human)
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw, /datum/surgery_step/internal/manipulate_organs,/datum/surgery_step/generic/cauterize)



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

//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling 						//
//////////////////////////////////////////////////////////////////
/datum/surgery/remove_thrall
	name = "clense contaminations"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/dethrall)
	possible_locs = list("head")

/datum/surgery_step/internal/dethrall
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 120
	max_duration = 120

/datum/surgery_step/internal/dethrall/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected && is_thrall(target) && affected.open_enough_for_surgery() && target_zone == target.named_organ_parent("brain")

/datum/surgery_step/internal/dethrall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/braincase = target.named_organ_parent("brain")
	user.visible_message("[user] begins looking around in [target]'s [braincase].", "<span class='notice'>You begin looking for foreign influences on [target]'s brain...")
	target << "<span class='boldannounce'>A small part of your [braincase] pulses with agony as the light impacts it.</span>"
	user.visible_message("[user] begins removing something from [target]'s [braincase].</span>", \
						 "<span class='notice'>You begin carefully extracting the tumor...</span>")
	..()

/datum/surgery_step/internal/dethrall/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/braincase = target.named_organ_parent("brain")
	user.visible_message("<span class='notice'>[user] carefully extracts the tumor from [target]'s brain!</span>", \
						 "<span class='notice'>You extract the black tumor from [target]'s [braincase]. It quickly shrivels and burns away.</span>")
	ticker.mode.remove_thrall(target.mind,0)
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

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////
///datum/surgery/remove_xeno_baby
//	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders,/datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,/datum/surgery_step/open_encased/retract, /datum/surgery_step/internal/remove_embryo)
//	possible_locs = list("chest")
//	disallowed_mob = (/mob/living/carbon/human/machine)


/datum/surgery_step/internal/remove_embryo//might can just do this in organ mainpulation..but this is TARGETED for..
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)
	blood_level = 2

	min_duration = 80
	max_duration = 100

/datum/surgery_step/internal/remove_embryo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/embryo = 0
	var/obj/item/organ/internal/body_egg/alien_embryo/A = target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
	if(A)
		embryo = 1
		//break

	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected && embryo && affected.open_enough_for_surgery() && target_zone == "chest"

/datum/surgery_step/internal/remove_embryo/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
		var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

/datum/surgery_step/internal/remove_embryo/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	user.visible_message("\red [user] rips the larva out of [target]'s ribcage!",
						 "You rip the larva out of [target]'s ribcage!")

	var/obj/item/organ/internal/body_egg/alien_embryo/A = target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
	if(A)
		user << "<span class='notice'>You found an unknown alien organism in [target]'s chest!</span>"
		if(prob(10))
			A.AttemptGrow()

	A.remove(target)
	A.loc = get_turf(target)

	return 1

/datum/surgery_step/internal/remove_embryo/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if (!hasorgans(target))
		return

	var/obj/item/organ/internal/body_egg/alien_embryo/A = target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
	if(A)
		if(prob(50))
			A.AttemptGrow(0)
			user.visible_message("<span class='warning'>[user] accidentally pokes the xenomorph in [target]!</span>", "<span class='warning'>You accidentally poke the xenomorph in [target]!</span>")
		else
			target.adjustOxyLoss(30)
			user.visible_message("<span class='warning'>[user] accidentally pokes [target] in the lungs!</span>", "<span class='warning'>You accidentally poke [target] in the lungs!</span>")

	return 0


/datum/surgery_step/internal/manipulate_organs

	allowed_tools = list(/obj/item/organ/internal = 100, /obj/item/weapon/reagent_containers/food/snacks/organ = 0)
	var/implements_extract = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 55)
	var/implements_mend = list(/obj/item/stack/medical/advanced/bruise_pack = 100,/obj/item/stack/nanopaste = 100,/obj/item/stack/medical/bruise_pack = 20)
	//Finish is just so you can close up after you do other things.
	var/implements_finsh = list(/obj/item/weapon/retractor = 100 ,/obj/item/weapon/crowbar = 75)
	var/current_type
	var/obj/item/organ/internal/I = null
	var/obj/item/organ/external/affected = null
	min_duration = 70
	max_duration = 90

/datum/surgery_step/internal/manipulate_organs/New()
	..()
	allowed_tools = allowed_tools + implements_extract + implements_mend + implements_finsh




/datum/surgery_step/internal/manipulate_organs/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	I = null
	affected = target.get_organ(target_zone)
	if(is_int_organ(tool))
		current_type = "insert"
		I = tool
		if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
			user << "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>"
			return -1

		if(I.damage > (I.max_damage * 0.75))
			user << "<span class='notice'> \The [I] is in no state to be transplanted.</span>"
			return -1

		if(target.get_int_organ(I))
			user << "\red \The [target] already has [I]."
			return -1

		user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.name].", \
		"You start transplanting \the [tool] into [target]'s [affected.name].")
		target.custom_pain("Someone's rooting around in your [affected.name]!",1)

	else if(implement_type in implements_finsh)
	//same as surgery step /datum/surgery_step/open_encased/close/
		current_type = "finish"
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(affected == "head" || affected == "upper body")
			var/msg = "[user] starts bending [target]'s [affected.encased] back into place with \the [tool]."
			var/self_msg = "You start bending [target]'s [affected.encased] back into place with \the [tool]."
			user.visible_message(msg, self_msg)
		else
			var/msg = "[user] starts pulling [target]'s skin back into place with \the [tool]."
			var/self_msg = "You start pulling [target]'s skin back into place with \the [tool]."
			user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your [affected.name]!",1)
	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.get_organs_zone(target_zone)
		if(!organs.len)
			user << "<span class='notice'>There are no removeable organs in [target]'s [parse_zone(target_zone)]!</span>"
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
				target.custom_pain("The pain in your [affected.name] is living hell!",1)
			else
				return -1

	else if(implement_type in implements_mend)
		//todo Change message, make it heal the organs...
		current_type = "mend"
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		else if (istype(tool, /obj/item/stack/medical/bruise_pack))
			tool_name = "the bandaid"
		else if (istype(tool, /obj/item/stack/nanopaste))
			tool_name = "\the [tool]" //what else do you call nanopaste medically?

		if(!hasorgans(target))
			user << "They do not have organs to mend!"
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic < 2 && !istype (tool, /obj/item/stack/nanopaste))
					if(!I.sterile)
						spread_germs_to_organ(I, user)
					user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
					"You start treating damage to [target]'s [I.name] with [tool_name]." )
				else if(I.robotic > 2 && istype(tool, /obj/item/stack/nanopaste))
					user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
					"You start treating damage to [target]'s [I.name] with [tool_name]." )

			user << "No organs appear to be damaged."
			return -1
		target.custom_pain("The pain in your [affected.name] is living hell!",1)

	else if(istype(tool, /obj/item/weapon/reagent_containers/food/snacks/organ))
		user << "<span class='warning'>[tool] was biten by someone! It's too damaged to use!</span>"
		return -1
	..()

/datum/surgery_step/internal/manipulate_organs/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(current_type == "mend")
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		if (istype(tool, /obj/item/stack/medical/bruise_pack))
			tool_name = "the bandaid"

		if (!hasorgans(target))
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I)
				I.surgeryize()
			if(I && I.damage > 0)
				if(I.robotic < 2 && !istype (tool, /obj/item/stack/nanopaste))
					user.visible_message("\blue [user] treats damage to [target]'s [I.name] with [tool_name].", \
					"\blue You treat damage to [target]'s [I.name] with [tool_name]." )
					I.damage = 0
				else if(I.robotic > 2 && istype (tool, /obj/item/stack/nanopaste))
					user.visible_message("\blue [user] treats damage to [target]'s [I.name] with [tool_name].", \
					"\blue You treat damage to [target]'s [I.name] with [tool_name]." )
					I.damage = 0
		//return 1
	else if(current_type == "insert")
		I = tool
		user.drop_item()
		I.insert(target)
		spread_germs_to_organ(I, user)
		user.visible_message("\blue [user] has transplanted \the [tool] into [target]'s [affected.name].", \
		"\blue You have transplanted \the [tool] into [target]'s [affected.name].")

		I.status &= ~ORGAN_CUT_AWAY

	else if(current_type == "extract")
		if(I && I.owner == target)
			user.visible_message("\blue [user] has separated and extracts [target]'s [I] with \the [tool]." , \
			"\blue You have separated and extracted [target]'s [I] with \the [tool].")

			add_logs(target,user, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			spread_germs_to_organ(I, user)
			I.status |= ORGAN_CUT_AWAY
			I.remove(target)
			I.loc = get_turf(target)
		else
			user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	else if(current_type == "finish")

		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(target_zone == "head" || target_zone == "upper body")
			var/msg = "\blue [user] bends [target]'s [affected.encased] back into place with \the [tool]."
			var/self_msg = "\blue You bend [target]'s [affected.encased] back into place with \the [tool]."
			user.visible_message(msg, self_msg)
			affected.open = 2.5
		else
			var/msg = "[user] pulls [target]'s skin back into place with \the [tool]."
			var/self_msg = "You pull [target]'s skin back into place with \the [tool]."
			user.visible_message(msg, self_msg)

		return 1


	return 0

//todo set up fail steps


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/*
/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,		\
	/obj/item/stack/medical/bruise_pack = 20
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return
		var/is_organ_damaged = 0
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic < 2)
				is_organ_damaged = 1
				break
		return ..() && is_organ_damaged

	begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		else if (istype(tool, /obj/item/stack/medical/bruise_pack))
			tool_name = "the bandaid"

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic < 2)
					if(!I.sterile)
						spread_germs_to_organ(I, user)
					user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
					"You start treating damage to [target]'s [I.name] with [tool_name]." )

		target.custom_pain("The pain in your [affected.name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/tool_name = "\the [tool]"
		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			tool_name = "regenerative membrane"
		if (istype(tool, /obj/item/stack/medical/bruise_pack))
			tool_name = "the bandaid"

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I)
				I.surgeryize()
			if(I && I.damage > 0)
				if(I.robotic < 2)
					user.visible_message("\blue [user] treats damage to [target]'s [I.name] with [tool_name].", \
					"\blue You treat damage to [target]'s [I.name] with [tool_name]." )
					I.damage = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("\red [user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!")
		var/dam_amt = 2

		if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
			target.adjustToxLoss(5)

		else if (istype(tool, /obj/item/stack/medical/bruise_pack))
			dam_amt = 5
			target.adjustToxLoss(10)
			affected.createwound(CUT, 5)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				I.take_damage(dam_amt,0)

/datum/surgery_step/internal/detatch_organ

	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		if (!..())
			return 0

		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		if(!(affected && !(affected.status & ORGAN_ROBOT)))
			return 0

		surgery.current_organ = null
		surgery.organ_ref = null

		var/list/attached_organs = list()
		for(var/organ in affected.internal_organs)
			var/obj/item/organ/internal/I = organ
			if(I && !(I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
				attached_organs[I.organ_tag] = I

		var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
		if(!organ_to_remove)
			return 0

		surgery.current_organ = organ_to_remove
		surgery.organ_ref = attached_organs[organ_to_remove]

		return ..() && organ_to_remove

	begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("[user] starts to separate [target]'s [surgery.current_organ] with \the [tool].", \
		"You start to separate [target]'s [surgery.current_organ] with \the [tool]." )
		target.custom_pain("The pain in your [affected.name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("\blue [user] has separated [target]'s [surgery.current_organ] with \the [tool]." , \
		"\blue You have separated [target]'s [surgery.current_organ] with \the [tool].")

		var/obj/item/organ/internal/I = surgery.organ_ref
		if(I && istype(I))
			spread_germs_to_organ(I, user)
			I.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!")
		affected.createwound(CUT, rand(30,50), 1)

/datum/surgery_step/internal/remove_organ

	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		if (!..())
			return 0
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		if(!istype(affected))
			return 0

		surgery.current_organ = null
		surgery.organ_ref = null

		var/list/removable_organs = list()
		for(var/organ in affected.internal_organs)
			var/obj/item/organ/internal/I = organ
			if(istype(I) && (I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
				removable_organs[I.organ_tag] = I

		var/organ_to_remove = input(user, "Which organ do you want to remove?") as null|anything in removable_organs
		if(!organ_to_remove)
			return 0

		surgery.current_organ = organ_to_remove
		surgery.organ_ref = removable_organs[organ_to_remove]
		return ..()

	begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("[user] starts removing [target]'s [surgery.current_organ] with \the [tool].", \
		"You start removing [target]'s [surgery.current_organ] with \the [tool].")
		target.custom_pain("Someone's ripping out your [surgery.current_organ]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("\blue [user] has removed [target]'s [surgery.current_organ] with \the [tool].", \
		"\blue You have removed [target]'s [surgery.current_organ] with \the [tool].")

		// Extract the organ!
		if(surgery.current_organ)
			var/obj/item/organ/internal/O = surgery.organ_ref
			if(O && istype(O))

				spread_germs_to_organ(O, user)
				O.remove(target)
				O.loc = get_turf(target)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, damaging [target]'s [affected.name] with \the [tool]!")
		affected.createwound(BRUISE, 20)

/datum/surgery_step/internal/replace_organ
	allowed_tools = list(
	/obj/item/organ/internal = 100
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		var/obj/item/organ/internal/O = tool
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected) return
		var/organ_compatible
		var/organ_missing

		if(!istype(O))
			return 0

		if((affected.status & ORGAN_ROBOT) && !(O.status & ORGAN_ROBOT))
			user << "<span class='danger'>You cannot install a naked organ into a robotic body.</span>"
			return 2

		if(!target.species)
			user << "\red You have no idea what species this person is. Report this on the bug tracker."
			return 2

		var/o_is = (O.gender == PLURAL) ? "are" : "is"
		var/o_a =  (O.gender == PLURAL) ? "" : "a "
		var/o_do = (O.gender == PLURAL) ? "don't" : "doesn't"

		if(O.organ_tag == "limb")
			return 0
		else if(target.species.has_organ[O.organ_tag])//need to change this around for cybernetic implants

			if(O.damage > (O.max_damage * 0.75))
				user << "\red \The [O.organ_tag] [o_is] in no state to be transplanted."
				return 2

			if(!target.get_int_organ(O))
				organ_missing = 1
			else
				user << "\red \The [target] already has [o_a][O.organ_tag]."
				return 2

			if(O && affected.limb_name == O.parent_organ)
				organ_compatible = 1
			else
				user << "\red \The [O.organ_tag] [o_do] normally go in \the [affected.name]."
				return 2
		else
			user << "\red You're pretty sure [target.species.name] don't normally have [o_a][O.organ_tag]."
			return 2

		return ..() && organ_missing && organ_compatible

	begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.name].", \
		"You start transplanting \the [tool] into [target]'s [affected.name].")
		target.custom_pain("Someone's rooting around in your [affected.name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has transplanted \the [tool] into [target]'s [affected.name].", \
		"\blue You have transplanted \the [tool] into [target]'s [affected.name].")
		user.drop_item(tool)
		var/obj/item/organ/internal/O = tool
		if(istype(O))
			O.insert(target)
			spread_germs_to_organ(O, user)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("\red [user]'s hand slips, damaging \the [tool]!", \
		"\red Your hand slips, damaging \the [tool]!")
		var/obj/item/organ/internal/I = tool
		if(istype(I))
			I.take_damage(rand(3,5),0)

/datum/surgery_step/internal/attach_organ
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 100
	max_duration = 120

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		if (!..())
			return 0

		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		if(!istype(affected))
			return 0

		surgery.current_organ = null
		surgery.organ_ref = null

		var/list/removable_organs = list()
		for(var/organ in affected.internal_organs)
			var/obj/item/organ/internal/I = organ
			if(I && istype(I) && (I.status & ORGAN_CUT_AWAY) && !(I.status & ORGAN_ROBOT) && I.parent_organ == target_zone)
				removable_organs[I.organ_tag] = I

		var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
		if(!organ_to_replace)
			return 0

		surgery.current_organ = organ_to_replace
		surgery.organ_ref = removable_organs[organ_to_replace]
		return ..()

	begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("[user] begins reattaching [target]'s [surgery.current_organ] with \the [tool].", \
		"You start reattaching [target]'s [surgery.current_organ] with \the [tool].")
		target.custom_pain("Someone's digging needles into your [surgery.current_organ]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("\blue [user] has reattached [target]'s [surgery.current_organ] with \the [tool]." , \
		"\blue You have reattached [target]'s [surgery.current_organ] with \the [tool].")

		var/obj/item/organ/internal/I = surgery.organ_ref
		if(I && istype(I))
			I.status &= ~ORGAN_CUT_AWAY
			spread_germs_to_organ(I, user)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s hand slips, damaging the flesh in [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, damaging the flesh in [target]'s [affected.name] with \the [tool]!")
		affected.createwound(BRUISE, 20)

*/
//////////////////////////////////////////////////////////////////
//						HEART SURGERY							//
//////////////////////////////////////////////////////////////////
// To be finished after some tests.
// /datum/surgery_step/ribcage/heart/cut
//	allowed_tools = list(
//	/obj/item/weapon/scalpel = 100,		\
//	/obj/item/weapon/kitchenknife = 75,	\
//	/obj/item/weapon/shard = 50, 		\
//	)

//	min_duration = 30
//	max_duration = 40

//	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
//		return ..() && target.op_stage.ribcage == 2