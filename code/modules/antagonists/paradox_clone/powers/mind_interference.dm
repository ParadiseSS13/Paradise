/datum/spell/paradox_spell/click_target/mind_interference
	name = "Mind Interference"
	desc = "You climbing into the very halls of the mind, disrupting the normal functioning of victim's brain."
	action_icon_state = "mind_interference"
	base_cooldown = 120 SECONDS
	base_range = 10
	selection_activated_message		= "<span class='warning'>Click on a target to interference their mind...</span>"
	selection_deactivated_message	= "<span class='notice'>You decided to not corrupt anyone's mind.. Yet.</span>"

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

	H.AdjustHallucinate(rand(60,120) SECONDS)

	H.adjustBrainLoss(rand(6,12))
	H.AdjustSlur(rand(10,20) SECONDS)
	H.AdjustWeakened(rand(2,4) SECONDS)
	H.AdjustConfused(rand(6,8) SECONDS)
	H.AdjustStunned(rand(1,2) SECONDS)
	H.KnockDown(1 SECONDS)

	add_attack_logs(user, target, "(Paradox Clone) Mind Interferenced")
