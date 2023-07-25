/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement. Costs 30 chemicals."
	helptext = "This is obvious to nearby people, and can destroy standard restraints and closets."
	button_icon_state = "biodegrade"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 30 //High cost to prevent spam
	req_human = TRUE


/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = FALSE // only one form of shackles removed per use

	if(!user.restrained() && !user.legcuffed && !istype(user.loc, /obj/structure/closet) && !istype(user.loc, /obj/structure/spider/cocoon))
		to_chat(user, span_warning("We are already free!"))
		return FALSE

	if(user.handcuffed)
		var/obj/item/restraints/handcuffs/handcuffs = user.get_item_by_slot(slot_handcuffed)
		if(!istype(handcuffs))
			return FALSE

		user.visible_message(span_warning("[user] vomits a glob of acid on [user.p_their()] [handcuffs.name]!"), \
							span_warning("We vomit acidic ooze onto our restraints!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), user, handcuffs), 3 SECONDS)
		used = TRUE

	if(user.legcuffed && !used)
		var/obj/item/restraints/legcuffs/legcuffs = user.get_item_by_slot(slot_legcuffed)
		if(!istype(legcuffs))
			return FALSE

		user.visible_message(span_warning("[user] vomits a glob of acid on [user.p_their()] [legcuffs.name]!"), \
							span_warning("We vomit acidic ooze onto our leg restraints!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), user, legcuffs), 3 SECONDS)
		used = TRUE

	if(user.wear_suit?.breakouttime && !used)
		var/obj/item/clothing/suit/res_suit = user.get_item_by_slot(slot_wear_suit)
		if(!istype(res_suit))
			return FALSE

		user.visible_message(span_warning("[user] vomits a glob of acid across the front of [user.p_their()] [res_suit.name]!"), \
							span_warning("We vomit acidic ooze onto our straight jacket!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), user, res_suit), 3 SECONDS)
		used = TRUE

	if(istype(user.loc, /obj/structure/closet) && !used)
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE

		closet.visible_message(span_warning("[closet]'s hinges suddenly begin to melt and run!"), \
								span_warning("We vomit acidic goop onto the interior of [closet]!"))

		addtimer(CALLBACK(src, PROC_REF(open_closet), user, closet), 7 SECONDS)
		used = TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon) && !used)
		var/obj/structure/spider/cocoon/cocoon = user.loc
		if(!istype(cocoon))
			return FALSE

		cocoon.visible_message(span_warning("[cocoon] shifts and starts to fall apart!"), \
								span_warning("We secrete acidic enzymes from our skin and begin melting our cocoon..."))

		addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, cocoon), 2.5 SECONDS) //Very short because it's just webs
		used = TRUE

	if(!used)
		for(var/obj/item/grab/grab in user.grabbed_by)
			var/mob/living/carbon/grab_owner = grab.assailant
			user.visible_message(span_warning("[user] spits acid at [grab_owner]'s face and slips out of their grab!"))
			grab_owner.Stun(2 SECONDS) //Drops the grab
			grab_owner.apply_damage(5, BURN, "head", grab_owner.run_armor_check("head", "melee"))
			user.SetStunned(0) //This only triggers if they are grabbed, to have them break out of the grab, without the large stun time. If you use biodegrade as an antistun without being grabbed, it will not work
			user.SetWeakened(0)
			playsound(user.loc, 'sound/weapons/sear.ogg', 50, TRUE)
			used = TRUE

	if(used)
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE


/datum/action/changeling/biodegrade/proc/dissolve_restraint(mob/living/carbon/human/user, obj/restraints)
	if(QDELETED(user) || QDELETED(restraints))
		return

	if(user.handcuffed == restraints || user.legcuffed == restraints || user.wear_suit == restraints)
		user.visible_message(span_warning("[restraints] dissolves into a puddle of sizzling goop."))
		user.temporarily_remove_item_from_inventory(restraints, force = TRUE)
		qdel(restraints)


/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(QDELETED(user) || QDELETED(closet))
		return

	if(user.loc == closet)
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()
		closet.visible_message(span_warning("[closet]'s door breaks and opens!"), \
								span_warning("We open the container restraining us!"))


/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/cocoon)
	if(QDELETED(user) || QDELETED(cocoon))
		return

	if(user.loc == cocoon)
		qdel(cocoon) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, span_warning("We dissolve the cocoon!"))

