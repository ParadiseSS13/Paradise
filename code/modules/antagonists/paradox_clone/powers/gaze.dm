/datum/spell/paradox_spell/click_target/gaze
	name = "Gaze"
	desc = "A close look at the victim, which causes them to fall off her feet."
	action_icon_state = "gaze"
	base_cooldown = 40 SECONDS
	base_range = 12
	base_max_charges = 2
	selection_activated_message = "<span class='warning'>Click on a target to gaze at them...</span>"
	selection_deactivated_message = "<span class='notice'>You decided to not gaze at anyone... For now.</span>"

/datum/spell/paradox_spell/click_target/gaze/valid_target(target, user)
	var/mob/living/targ = target
	return targ.stat == CONSCIOUS && !is_paradox_clone(target)

/datum/spell/paradox_spell/click_target/gaze/proc/check(mob/victim, mob/attacker)

	var/attacker_to_victim = get_dir(attacker, victim)
	var/attacker_dir = attacker.dir

	if(attacker_dir & attacker_to_victim || victim.loc == attacker.loc)
		return TRUE

	if(attacker_dir & reverse_direction(attacker_to_victim))
		return FALSE

	return TRUE

/datum/spell/paradox_spell/click_target/gaze/cast(list/targets, mob/living/user = usr)
	var/mob/living/target = targets[1]
	var/mob/living/carbon/human/H = user
	H.face_atom(target)

	if(ishuman(user))
		if(istype(H.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
			var/obj/item/clothing/glasses/sunglasses/blindfold/B = H.glasses
			if(B.tint)
				revert_cast()
				to_chat(user, "<span class='warning'>You can't gaze at anyone, your eyes are blocked!</span>")
				return

		if(/datum/mutation/disability/blindness in H.active_mutations)
			to_chat(user, "<span class='warning'>You don't see anything!</span>")
			revert_cast()
			return

		if(user.AmountBlinded() > 0)
			to_chat(user, "<span class='warning'>You don't see anything!</span>")
			revert_cast()
			return

		if(!can_see(user, target))
			revert_cast()
			return

		if(!check(target, user)) // if face_atom didn't work.
			to_chat(user, "<span class='warning'>You are out of [target.name] sight.</span>")
			revert_cast()
			return

		if(is_paradox_clone(target))
			revert_cast()
			to_chat(user, "<span class='warning'>Useless. [target.name] is from our kin.</span>")
			return

		target.KnockDown(8 SECONDS)
		target.AdjustSilence(4 SECONDS)
		target.apply_damage(30, STAMINA)
		target.Weaken(6 SECONDS)
		target.Confused(10 SECONDS)
		target.AdjustHallucinate(40 SECONDS)

		add_attack_logs(user, target, "(Paradox Clone) Gazed")
