/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement if we are restrained. Prepares hand to vomit acid on other objects, doesn't work on living targets. Costs 30 chemicals."
	helptext = "This is obvious to nearby people, and can destroy standard restraints and closets, and break you out of grabs."
	button_icon_state = "biodegrade"
	chemical_cost = 30 //High cost to prevent spam
	dna_cost = 4
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/defence
	/// Type of acid hand we give to person
	var/hand = /obj/item/melee/changeling_corrosive_acid
	/// Current hand given to human, null is we did not give hand, object if hand is given
	var/obj/item/melee/changeling_corrosive_acid/current_hand

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = FALSE // only one form of shackles removed per use

	if(user.handcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(!istype(O))
			return FALSE
		user.visible_message(SPAN_WARNING("[user] vomits a glob of acid on [user.p_their()] [O.name]!"), \
			SPAN_WARNING("We vomit acidic ooze onto our restraints!"))
		dissolve_restraint(user, O)
		used = TRUE

	if(user.legcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(!istype(O))
			return FALSE
		user.visible_message(SPAN_WARNING("[user] vomits a glob of acid on [user.p_their()] [O.name]!"), \
			SPAN_WARNING("We vomit acidic ooze onto our leg restraints!"))
		dissolve_restraint(user, O)
		used = TRUE

	if(user.wear_suit && user.wear_suit.breakouttime && !used)
		var/obj/item/clothing/suit/S = user.get_item_by_slot(ITEM_SLOT_OUTER_SUIT)
		if(!istype(S))
			return FALSE
		user.visible_message(SPAN_WARNING("[user] vomits a glob of acid across the front of [user.p_their()] [S.name]!"), \
			SPAN_WARNING("We vomit acidic ooze onto our straight jacket!"))
		dissolve_restraint(user, S)
		used = TRUE

	if(istype(user.loc, /obj/structure/closet) && !used)
		var/obj/structure/closet/C = user.loc
		if(!istype(C))
			return FALSE
		C.visible_message(SPAN_WARNING("[C]'s hinges suddenly begin to melt and run!"))
		to_chat(user, SPAN_WARNING("We vomit acidic goop onto the interior of [C]!"))
		addtimer(CALLBACK(src, PROC_REF(open_closet), user, C), 7 SECONDS)
		used = TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon) && !used)
		var/obj/structure/spider/cocoon/C = user.loc
		if(!istype(C))
			return FALSE
		C.visible_message(SPAN_WARNING("[src] shifts and starts to fall apart!"))
		to_chat(user, SPAN_WARNING("We secrete acidic enzymes from our skin and begin melting our cocoon..."))
		addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, C), 2.5 SECONDS) //Very short because it's just webs
		used = TRUE
	for(var/obj/item/grab/G in user.grabbed_by)
		var/mob/living/carbon/M = G.assailant
		user.visible_message(SPAN_WARNING("[user] spits acid at [M]'s face and slips out of their grab!"))
		M.Stun(2 SECONDS) //Drops the grab
		M.apply_damage(5, BURN, BODY_ZONE_HEAD, M.run_armor_check(BODY_ZONE_HEAD, MELEE))
		user.SetStunned(0) //This only triggers if they are grabbed, to have them break out of the grab, without the large stun time. If you use biodegrade as an antistun without being grabbed, it will not work
		user.SetWeakened(0)
		playsound(user.loc, 'sound/weapons/sear.ogg', 50, TRUE)
		used = TRUE

	if(used)
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
		return TRUE

	if(!current_hand)
		if(!add_hand_spell(user))
			return FALSE
		to_chat(user, SPAN_WARNING("We prepare hand to vomit acid!"))
		return TRUE
	remove_hand_spell(user, TRUE)
	return FALSE

/datum/action/changeling/biodegrade/proc/dissolve_restraint(mob/living/carbon/human/user, obj/O)
	if(O && (user.handcuffed == O || user.legcuffed == O || user.wear_suit == O))
		O.visible_message(SPAN_WARNING("[O] dissolves into a puddle of sizzling goop."))
		qdel(O)

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/C)
	if(C && user.loc == C)
		C.visible_message(SPAN_WARNING("[C]'s door breaks and opens!"))
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, SPAN_WARNING("We open the container restraining us!"))

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/C)
	if(C && user.loc == C)
		qdel(C) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, SPAN_WARNING("We dissolve the cocoon!"))

/datum/action/changeling/biodegrade/proc/add_hand_spell(mob/living/carbon/human/user)
	if(user.get_active_hand() && !user.drop_item())
		to_chat(user, SPAN_WARNING("[user.get_active_hand()] is stuck to our hand, we cannot emit acid on this hand."))
		return FALSE
	current_hand = new hand(src)
	user.put_in_active_hand(current_hand)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(remove_hand_spell))
	return TRUE

/datum/action/changeling/biodegrade/proc/remove_hand_spell(mob/living/carbon/human/user, any_hand=FALSE)
	SIGNAL_HANDLER
	if(!current_hand)
		return FALSE
	if(any_hand && user.get_active_hand() != current_hand)
		return FALSE
	qdel(current_hand)
	return TRUE

/obj/item/melee/changeling_corrosive_acid
	name = "Corrosive acid"
	desc = "A fistfull of death."
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "alien_acid"
	flags = ABSTRACT | NODROP | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 0
	throw_speed = 0
	var/datum/action/changeling/biodegrade/parent_action

/obj/item/melee/changeling_corrosive_acid/New(datum/action/changeling/biodegrade/new_parent)
	. = ..()
	parent_action = new_parent

/obj/item/melee/changeling_corrosive_acid/Destroy()
	if(parent_action)
		parent_action.current_hand = null
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WILLINGLY_DROP)
	return ..()

/obj/item/melee/changeling_corrosive_acid/afterattack__legacy__attackchain(atom/target, mob/user, proximity, params)
	if(target == user)
		to_chat(user, SPAN_NOTICEALIEN("You withdraw your readied acid."))
		parent_action.remove_hand_spell(user)
		return
	if(isliving(target))
		to_chat(user, SPAN_ALERT("We dont have enough acid to assault living target!"))
		return
	if(!proximity || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) // Don't want xenos ditching out of cuffs
		return
	if(target.acid_act(200, 100))
		visible_message(SPAN_ALERT("[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!"))
		add_attack_logs(user, target, "Applied corrosive acid") // Want this logged
	else
		to_chat(user, SPAN_NOTICEALIEN("You cannot dissolve this object."))
	parent_action.remove_hand_spell(user)
