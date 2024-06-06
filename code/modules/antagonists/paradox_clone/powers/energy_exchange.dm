/datum/spell/paradox_spell/click_target/energy_exchange
	name = "Energy Exchange"
	desc = "You commit a paradox and exchange stamina, slowness, confusion and other negative effects with a chosen victim. Works even if target is not a human, as well as when you are unconscious."
	action_icon_state = "stamina_exchange"
	base_cooldown = 60 SECONDS
	base_range = 12
	selection_activated_message = "<span class='warning'>Click on the target to exchange stamina!</span>"
	selection_deactivated_message = "<span class='notice'>You decided to do nothing... But is it for sure?</span>"
	stat_allowed = UNCONSCIOUS

/datum/spell/paradox_spell/click_target/energy_exchange/create_new_targeting()
	var/datum/spell_targeting/click/C = new
	C.allowed_type = /mob/living
	C.range = base_range
	return C

/datum/spell/paradox_spell/click_target/energy_exchange/cast(list/targets, mob/living/user = usr)
	var/mob/living/target = targets[1]
	var/mob/living/carbon/H = target

	if(!iscarbon(target)) // If we can't exchange powers then just get a vampire's stun clear
		var/mob/living/carbon/human/U = user
		U.SetWeakened(0)
		U.SetStunned(0)
		U.SetKnockDown(0)
		U.SetParalysis(0)
		U.SetSleeping(0)
		U.SetConfused(0)
		U.adjustStaminaLoss(-100)
		U.stand_up(TRUE)
		SEND_SIGNAL(U, COMSIG_LIVING_CLEAR_STUNS)
		return

	var/mob/living/carbon/human/use = user

	if(is_paradox_clone(target))
		to_chat(user, "<span class='warning'>Useless. [target.name] is from our kin.</span>")
		revert_cast()
		return

	H.AdjustHallucinate(rand(10, 20) SECONDS)
	do_sparks(rand(1, 2), FALSE, H)
	do_sparks(rand(1, 2), FALSE, user)

	var/target_weakened = H.AmountWeakened()
	var/target_stunned = H.AmountStun()
	var/target_knockdown = H.AmountKnockDown()
	var/target_paralysis = H.AmountParalyzed()
	var/target_sleeping = H.AmountSleeping()
	var/target_confused = H.get_confusion()

	var/target_stamina = target.staminaloss

////////////////////////////////////////////////////

	var/user_weakened = use.AmountWeakened()
	var/user_stunned = use.AmountStun()
	var/user_knockdown = use.AmountKnockDown()
	var/user_paralysis = use.AmountParalyzed()
	var/user_sleeping = use.AmountSleeping()
	var/user_confused = use.get_confusion()

	var/user_stamina = use.staminaloss
	var/user_toxins = use.toxloss

	use.setStaminaLoss(target_stamina)
	H.setStaminaLoss(user_stamina, FALSE) // TRICKY PARADOX

	use.SetWeakened(target_weakened)
	H.SetWeakened(user_weakened)

	use.SetKnockDown(target_knockdown)
	H.SetKnockDown(user_knockdown)

	use.SetParalysis(target_paralysis)
	H.SetParalysis(user_paralysis)

	use.SetSleeping(target_sleeping)
	H.SetSleeping(user_sleeping)

	use.SetConfused(target_confused)
	H.SetConfused(user_confused)

	use.SetStunned(target_stunned)
	H.SetStunned(user_stunned)

	use.adjustToxLoss(user_toxins)
	H.setToxLoss(user_toxins)

	use.stand_up(TRUE)

	for(var/datum/reagent/R in use.reagents.reagent_list)
		if(!R.harmless)
			H.reagents.add_reagent(R.id, R.volume)
			use.reagents.remove_reagent(R.id, R.volume)
	// gives harmless target's reagents to user and user's harmful reagents to target
	for(var/datum/reagent/R in H.reagents.reagent_list)
		if(R.harmless)
			H.reagents.remove_reagent(R.id, R.volume)
			if(R.volume >= R.overdose_threshold)
				R.volume = R.overdose_threshold - 0.01
			use.reagents.add_reagent(R.id, R.volume)

	add_attack_logs(user, target, "(Paradox Clone) Energy Exchanged")
