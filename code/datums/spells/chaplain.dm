
/obj/effect/proc_holder/spell/targeted/chaplain_bless
	name = "Bless"
	desc = "Blesses a single person."

	school = "transmutation"
	charge_max = 60
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
		revert_cast()
		return

	if(!user.mind)
		to_chat(user, "Somehow, you are mindless. This should never happen. Report this bug.")
		revert_cast()
		return

	if(!user.mind.isholy)
		to_chat(user, "Somehow, you are not holy enough to use this ability. This should never happen. Report this bug.")
		revert_cast()
		return

	var/mob/living/carbon/human/target = targets[range]

	if(!istype(target))
		to_chat(user, "No target.")
		revert_cast()
		return

	if(!(target in oview(range)) && !distanceoverride)//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		to_chat(user, "[target] is too far away!")
		revert_cast()
		return

	if(!target.mind)
		to_chat(user, "[target] appears to be catatonic. Your blessing would have no effect.")
		revert_cast()
		return

	if(!target.ckey)
		to_chat(user, "[target] appears to be too out of it to benefit from this.")
		revert_cast()
		return

	if(target.stat == DEAD)
		to_chat(user, "[target] is already dead. There is no point.")
		revert_cast()
		return

	spawn(0) // allows cast to complete even if recipient ignores the prompt
		if(alert(target, "[user] wants to bless you, in the name of [user.p_their()] religion. Accept?", "Accept Blessing?", "Yes", "No") == "Yes") // prevents forced conversions
			user.visible_message("[user] starts blessing [target] in the name of [SSticker.Bible_deity_name].", "<span class='notice'>You start blessing [target] in the name of [SSticker.Bible_deity_name].</span>")
			if(do_after(user, 150, target = target))
				user.visible_message("[user] has blessed [target] in the name of [SSticker.Bible_deity_name].", "<span class='notice'>You have blessed [target] in the name of [SSticker.Bible_deity_name].</span>")
				if(!target.mind.isblessed)
					target.mind.isblessed = TRUE
					user.mind.num_blessed++

