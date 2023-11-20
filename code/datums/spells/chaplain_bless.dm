
/obj/effect/proc_holder/spell/chaplain_bless
	name = "Bless"
	desc = "Blesses a single person."

	school = "transmutation"
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"

	selection_activated_message = "<span class='notice'>You prepare a blessing. Click on a target to start blessing.</span>"
	selection_deactivated_message = "<span class='notice'>The crew will be blessed another time.</span>"
	cooldown_min = 20
	action_icon_state = "shield"

/obj/effect/proc_holder/spell/chaplain_bless/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/chaplain_bless/valid_target(mob/living/carbon/human/target, mob/user)
	return target.mind && target.ckey && !target.stat

/obj/effect/proc_holder/spell/chaplain_bless/cast(list/targets, mob/living/user = usr)
	if(!istype(user))
		to_chat(user, "Somehow, you are not a living mob. This should never happen. Report this bug.")
		revert_cast()
		return

	if(!user.mind)
		to_chat(user, "Somehow, you are mindless. This should never happen. Report this bug.")
		revert_cast()
		return

	if(!HAS_MIND_TRAIT(user, TRAIT_HOLY))
		to_chat(user, "Somehow, you are not holy enough to use this ability. This should never happen. Report this bug.")
		revert_cast()
		return

	var/mob/living/carbon/human/target = targets[1]

	spawn(0) // allows cast to complete even if recipient ignores the prompt
		if(alert(target, "[user] wants to bless you, in the name of [user.p_their()] religion. Accept?", "Accept Blessing?", "Yes", "No") == "Yes") // prevents forced conversions
			user.visible_message("[user] starts blessing [target] in the name of [SSticker.Bible_deity_name].", "<span class='notice'>You start blessing [target] in the name of [SSticker.Bible_deity_name].</span>")
			if(do_after(user, 150, target = target))
				user.visible_message("[user] has blessed [target] in the name of [SSticker.Bible_deity_name].", "<span class='notice'>You have blessed [target] in the name of [SSticker.Bible_deity_name].</span>")
				if(!target.mind.isblessed)
					target.mind.isblessed = TRUE
					user.mind.num_blessed++

