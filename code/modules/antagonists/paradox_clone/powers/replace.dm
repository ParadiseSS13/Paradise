/datum/spell/paradox_spell/click_target/replace // objective "kill"
	name = "Replace"
	desc = "You take hold of your original, and you start slowly sending it into the void, limb by limb, until there's nothing left of them..."
	action_icon_state = "replace"
	base_cooldown = 10 SECONDS
	base_range = 1
	selection_activated_message = "<span class='warning'>Click on the target to begin removing them from existence. This will take some time. It will be best to find a quiet place, as to not be disturbed...</span>"
	selection_deactivated_message = "<span class='notice'>You decided to spare them. For now...</span>"

/datum/spell/paradox_spell/click_target/replace/cast(list/targets, mob/living/user = usr)
	var/mob/living/target = targets[1]
	var/mob/living/carbon/human/H = target
	var/datum/antagonist/paradox_clone/evil_twin = user.mind.has_antag_datum(/datum/antagonist/paradox_clone)

	if(is_paradox_clone(target))
		revert_cast()
		to_chat(user, "<span class='warning'>Useless. [target.name] is from our kin.</span>")
		return

	if(evil_twin.original != target)
		revert_cast()
		to_chat(user, "<span class='warning'>This is not your original! You need [evil_twin.original.real_name]!</span>")
		return

	if(!do_after(user, 2 SECONDS, target = target))
		revert_cast()
		return

	var/obj/item/organ/internal/brain/B = locate() in user
	if(B && B.owner == evil_twin.original)
		qdel(B)
		var/datum/spell/paradox_spell/click_target/replace/R = locate() in evil_twin.owner.spell_list
		user.mind.RemoveSpell(R)

	to_chat(user, "<span class='warning'>Replacing process starts...</span>")
	H.AdjustHallucinate(rand(6, 12) SECONDS)
	to_chat(target, "<span class='biggerdanger'>Something is off with you!</span>")

	var/list/available_limbs = list()

	for(var/obj/item/organ/external/limb as anything in H.bodyparts)
		if(!istype(limb, /obj/item/organ/external/chest) && !istype(limb, /obj/item/organ/external/groin) && !istype(limb, /obj/item/organ/external/hand) && !istype(limb, /obj/item/organ/external/foot))
			available_limbs += limb

	while(length(available_limbs))
		if(do_after(user, rand(4, 8) SECONDS, target = target))
			var/obj/item/organ/external/limb_to_delete = pick_n_take(available_limbs)
			if(do_after(user, rand(6, 8) SECONDS, target = target) && istype(limb_to_delete, /obj/item/organ/external/head))
				to_chat(user, "<span class='warning'>You need to focus on [limb_to_delete] to remove it from existence!</span>")
			limb_to_delete.droplimb()
			do_sparks(rand(2, 4), FALSE, target)
			to_chat(target, "<span class='biggerdanger'>Your [limb_to_delete] just vanished!</span>")
			qdel(limb_to_delete)

			H.update_icons()
			H.regenerate_icons()

	if(!length(available_limbs))
		to_chat(user, "<span class='danger'>This is the final stage of replacement.</span>")
		if(do_after(user, rand(10, 20) SECONDS, target = target))
			do_sparks(rand(10, 20), FALSE, target)
			to_chat(target, "<span class='biggerdanger'>Game Over.</span>")
			qdel(target)
			var/datum/spell/paradox_spell/click_target/replace/R = locate() in evil_twin.owner.spell_list
			user.mind.RemoveSpell(R)
			to_chat(user, "<span class='notice'>Replacing completed...</span>")
