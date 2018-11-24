
/obj/effect/proc_holder/spell/targeted/chaplain_bless
	name = "Bless"
	desc = "Blesses a single person."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"

	max_targets = 1
	include_user = 0
	humans_only = 1

	range = 1
	cooldown_min = 20
	action_icon_state = "shield"


/obj/effect/proc_holder/spell/targeted/chaplain_bless/cast(list/targets, mob/living/user = usr, distanceoverride)

	if(!istype(user))
		to_chat(user, "Somehow, you are not a living mob. This should never happen. Report this bug.")
		return

	if(!user.mind)
		to_chat(user, "Somehow, you are mindless. This should never happen. Report this bug.")
		return

	if(!user.mind.isholy)
		to_chat(user, "Somehow, you are not holy enough to use this ability. This should never happen. Report this bug.")
		return

	var/mob/living/carbon/human/target = targets[range]

	if(!istype(target))
		to_chat(user, "No target.")
		return

	if(!(target in oview(range)) && !distanceoverride)//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		to_chat(user, "[target] is too far away!")
		return

	if(!target.mind)
		to_chat(user, "[target] appears to be catatonic. Your blessing would have no effect.")
		return

	if(!target.ckey)
		to_chat(user, "[target] appears to be too out of it to benefit from this.")
		return

	if(target.stat == DEAD)
		to_chat(user, "[target] is already dead. There is no point.")
		return

	if(target.mind.isblessed)
		to_chat(user, "[target] already has the aura of one who is blessed. Blessing them again would be pointless.")
		return

	spawn(0) // allows cast to complete even if recipient ignores the prompt
		if(alert(target, "[user] wants to bless you, in the name of their religion. Accept?","Accept Blessing?","Yes","No") == "Yes") // prevents forced conversions
			user.visible_message("[user] starts blessing [target] in the name of [ticker.Bible_deity_name].", "<span class='notice'>You start blessing [target] in the name of [ticker.Bible_deity_name].</span>")
			if(do_after(user, 100, target = target))
				user.visible_message("[user] has blessed [target] in the name of [ticker.Bible_deity_name].", "<span class='notice'>You have blessed [target] in the name of [ticker.Bible_deity_name].</span>")
				target.mind.isblessed = TRUE
				user.mind.religious_favor++
				to_chat(user, "You now have [user.mind.religious_favor] points of favor with your god.")


/obj/effect/proc_holder/spell/targeted/chaplain_grantheal
	name = "Grant Favor"
	desc = "Bestows the favor of your god on a single creature. Extremely powerful. Can only be applied to one creature at once."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"

	max_targets = 1
	include_user = 0
	humans_only = 1

	range = 1
	cooldown_min = 20
	action_icon_state = "mech_defense_mode_off"
	var/datum/mind/favored_mind


/obj/effect/proc_holder/spell/targeted/chaplain_grantheal/cast(list/targets, mob/living/user = usr, distanceoverride)

	if(!istype(user))
		to_chat(user, "Somehow, you are not a living mob. This should never happen. Report this bug.")
		return

	if(!user.mind)
		to_chat(user, "Somehow, you are mindless. This should never happen. Report this bug.")
		return

	if(!user.mind.isholy)
		to_chat(user, "Somehow, you are not holy enough to use this ability. This should never happen. Report this bug.")
		return

	var/mob/living/carbon/human/target = targets[range]

	if(!istype(target))
		to_chat(user, "No target.")
		return

	if(!(target in oview(range)) && !distanceoverride)//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		to_chat(user, "[target] is too far away!")
		return

	if(!target.mind)
		to_chat(user, "[target] appears to be catatonic. Your blessing would have no effect.")
		return

	if(!target.ckey)
		to_chat(user, "[target] appears to be too out of it to benefit from this.")
		return

	if(target.stat == DEAD)
		to_chat(user, "[target] is already dead. There is no point.")
		return

	if(!target.mind.isblessed)
		to_chat(user, "[target] must be blessed first.")
		return

	if(istype(favored_mind))
		for(var/obj/effect/proc_holder/spell/targeted/chaplain_heal/S in favored_mind.spell_list)
			favored_mind.RemoveSpell(S)
			to_chat(favored_mind.current, "<span class='warning'>You are no longer favored by [ticker.Bible_deity_name].</span>")
			to_chat(user, "<span class='warning'>You are no longer favoring [favored_mind].</span>")
	favored_mind = target.mind
	target.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/chaplain_heal(null))
	user.visible_message("<span class='notice'>[user] appeals to [ticker.Bible_deity_name] to grant [target] whatever favor they can!</span>", "<span class='boldnotice'>You appeal to [ticker.Bible_deity_name] to grant [target] whatever favor they can!</span>")


/obj/effect/proc_holder/spell/targeted/chaplain_heal
	name = "Invoke Favor"
	desc = ""

	school = "transmutation"
	charge_max = 1
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"

	max_targets = 1
	include_user = 1
	humans_only = 1
	stat_allowed = TRUE

	range = -1
	cooldown_min = 20
	action_icon_state = "mech_defense_mode_off"

/obj/effect/proc_holder/spell/targeted/chaplain_heal/can_cast(mob/user = usr)
	if(user.stat == DEAD)
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.health <= config.health_threshold_softcrit)
			return TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.health < (L.maxHealth / 2))
			return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/chaplain_heal/cast(list/targets, mob/living/user = usr, distanceoverride)
	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetParalysis(0)
	user.adjustStaminaLoss(-75)
	user.adjustBruteLoss(-10)
	user.adjustOxyLoss(-10)
	user.adjustToxLoss(-10)
	user.adjustFireLoss(-10)
	SEND_SOUND(user, 'sound/effects/hallelujah.ogg')
	to_chat(user, "<span class='boldnotice'>You feel invigorated!</span>")
	user.mind.RemoveSpell(src)