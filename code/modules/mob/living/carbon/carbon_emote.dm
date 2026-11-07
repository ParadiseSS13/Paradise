/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/cross
	key = "cross"
	key_third_person = "crosses"
	message = "crosses their arms."
	hands_use_check = TRUE

/datum/emote/living/carbon/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH
	muzzled_noises = list("breathy")

/datum/emote/living/carbon/inhale/sharp
	key = "inhale_s"
	key_third_person = "inhales sharply!"
	message = "takes a deep breath!"

/datum/emote/living/carbon/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss."
	message_param = "blows a kiss at %t!"
	muzzled_noises = list("smooching")

/datum/emote/living/carbon/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	hands_use_check = TRUE

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message = "signs."
	message_param = "signs the number %t."
	param_desc = "number(0-10)"
	hands_use_check = TRUE
	target_behavior = EMOTE_TARGET_BHVR_NUM

/datum/emote/living/carbon/sign/run_emote(mob/user, params, type_override, intentional)
	var/fingers = round(text2num(params), 1)

	if(fingers > 10)
		to_chat(user, SPAN_WARNING("You don't have enough fingers!"))
		return TRUE
	else if(fingers < 0)
		to_chat(user, SPAN_WARNING("You're not entirely sure how to raise negative fingers."))
		return TRUE
	params = fingers
	return ..()

/datum/emote/living/carbon/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."

/datum/emote/living/carbon/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Paralyse(2 SECONDS)

/datum/emote/living/carbon/twirl
	key = "twirl"
	key_third_person = "twirls"
	message = "twirls something around in their hand."
	hands_use_check = TRUE

/datum/emote/living/carbon/twirl/run_emote(mob/user, params, type_override, intentional)

	if(!(user.get_active_hand() || user.get_inactive_hand()))
		to_chat(user, SPAN_WARNING("You need something in your hand to use this emote!"))
		return TRUE

	var/obj/item/thing

	if(user.get_active_hand())
		thing = user.get_active_hand()
	else
		thing = user.get_inactive_hand()

	if(istype(thing, /obj/item/grab))
		var/obj/item/grab/grabbed = thing
		message = "twirls [grabbed.affecting.name] around!"
		grabbed.affecting.emote("spin")
	else if(istype(thing, /obj/item/gun/energy/laser/lever_action))
		var/obj/item/gun/energy/laser/lever_action/gun = thing
		if(HAS_TRAIT(user, TRAIT_CLUMSY))
			message = "attempts to twirl [thing] around in their hand, but pulls the trigger instead!"
			gun.cycle_action(user)
			var/shot_leg = pick("l_foot", "r_foot")
			gun.process_fire(user, user, 0, params, zone_override = shot_leg)
			user.drop_item()
		else if(prob(50) && !(HAS_TRAIT(user, TRAIT_BADASS) || HAS_TRAIT(user, TRAIT_COOL)))
			message = "attempts to twirl [thing] around in their hand, but fumbles!"
			user.drop_item()
		else
			message = "twirls [thing] around in their hand!"
			gun.cycle_action(user)
		if(HAS_TRAIT(user, TRAIT_BADASS) && istype(user.get_inactive_hand(), /obj/item/gun/energy/laser/lever_action))
			var/obj/item/gun/energy/laser/lever_action/offhand = user.get_inactive_hand()
			offhand.cycle_action()
			message = "twirls [thing] around in their hand, and [offhand] in the other! What a badass!"
	else if(!(thing.flags & ABSTRACT))
		message = "twirls [thing] around in their hand!"
	else
		to_chat(user, SPAN_WARNING("You cannot twirl [thing]!"))
		return TRUE

	. = ..()
	message = initial(message)
