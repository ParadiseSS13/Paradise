/datum/spell/paradox_spell/click_target/mind_interference
	name = "Mind Interference"
	desc = "You climb into the very halls of the mind, disrupting the normal functions of the victim's brain."
	action_icon_state = "mind_interference"
	base_cooldown = 70 SECONDS
	base_range = 10
	selection_activated_message = "<span class='warning'>Click on a target to interfere with their mind...</span>"
	selection_deactivated_message = "<span class='notice'>You decided to not corrupt anyone's mind.. Yet.</span>"

/datum/spell/paradox_spell/click_target/mind_interference/valid_target(target, user)
	var/mob/living/targ = target
	return targ.stat != DEAD && !is_paradox_clone(target)

/datum/spell/paradox_spell/click_target/mind_interference/cast(list/targets, mob/living/user = usr)
	var/mob/living/target = targets[1]
	var/mob/living/carbon/H = target

	if(is_paradox_clone(target))
		revert_cast()
		to_chat(user, "<span class='warning'>Useless. [target.name] is from our kin.</span>")
		return

	H.AdjustHallucinate(rand(60, 120) SECONDS)

	H.adjustBrainLoss(rand(6, 12))
	H.AdjustSlur(rand(10, 20) SECONDS)
	H.AdjustConfused(rand(10, 14) SECONDS)
	H.KnockDown(1 SECONDS)
	H.AdjustEyeBlind(1 SECONDS)
	H.AdjustEyeBlurry(2 SECONDS)
	H.AdjustDruggy(rand(1, 10) SECONDS)
	H.AdjustDrunk(rand(1, 10) SECONDS)
	H.AdjustDizzy(rand(1, 10) SECONDS)
	H.AdjustLoseBreath(rand(1, 2) SECONDS)


	user.drop_l_hand()
	user.drop_r_hand()

	to_chat(user, "<span class='userdanger'>A deafening buzz invades your mind...</span>")

	add_attack_logs(user, target, "(Paradox Clone) Mind Interferenced")
