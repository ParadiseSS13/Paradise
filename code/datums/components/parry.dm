/datum/component/parry
	/// the world.time we last parried at
	var/time_parried
	/// the max time since `time_parried` that the shield is still considered "active"
	var/parry_time_out_time

	/// the flat amount of damage the shield user takes per non-perfect parry
	var/stamina_constant
	/// stamina_coefficient * damage * time_since_time_parried = stamina damage taken per non perfect parry
	var/stamina_coefficient
	/// the attack types that are considered for parrying
	var/parryable_attack_types
	/// the time between parry attempts
	var/parry_cooldown
	///Do we wish to mute the parry sound?
	var/no_parry_sound
	/// Text to be shown to users who examine the parent. Will list which type of attacks it can parry.
	var/examine_text

/datum/component/parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, PROC_REF(attempt_parry))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_parent_examined))

/datum/component/parry/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	UnregisterSignal(parent, COMSIG_ITEM_HIT_REACT)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	var/obj/item/I = parent
	if(ismob(I.loc))
		UnregisterSignal(I.loc, COMSIG_HUMAN_PARRY)

/datum/component/parry/Initialize(_stamina_constant = 0, _stamina_coefficient = 0, _parry_time_out_time = PARRY_DEFAULT_TIMEOUT, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = 2 SECONDS, _no_parry_sound = FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	parry_time_out_time = _parry_time_out_time
	stamina_constant = _stamina_constant
	stamina_coefficient = _stamina_coefficient
	parry_cooldown = _parry_cooldown
	no_parry_sound = _no_parry_sound
	if(islist(_parryable_attack_types))
		parryable_attack_types = _parryable_attack_types
	else
		parryable_attack_types = list(_parryable_attack_types)

	var/static/list/attack_types_english = list(
		MELEE_ATTACK = "melee attacks",
		UNARMED_ATTACK = "unarmed attacks",
		PROJECTILE_ATTACK = "projectiles",
		THROWN_PROJECTILE_ATTACK = "thrown projectiles",
		LEAP_ATTACK = "leap attacks"
	)
	var/list/attack_list = list()
	for(var/attack_type in parryable_attack_types)
		attack_list += attack_types_english[attack_type]

	examine_text = "<span class='notice'>It's able to <b>parry</b> [english_list(attack_list)].</span>"

/datum/component/parry/proc/equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot in list(slot_l_hand, slot_r_hand))
		RegisterSignal(user, COMSIG_HUMAN_PARRY, PROC_REF(start_parry))
	else
		UnregisterSignal(user, COMSIG_HUMAN_PARRY)

/datum/component/parry/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_HUMAN_PARRY)

/datum/component/parry/proc/start_parry(mob/living/L)
	SIGNAL_HANDLER
	var/time_since_parry = world.time - time_parried
	if(time_since_parry < parry_cooldown + parry_time_out_time) // stops spam
		return

	time_parried = world.time
	L.changeNext_move(CLICK_CD_PARRY)
	L.do_attack_animation(L, used_item = parent)

/datum/component/parry/proc/attempt_parry(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_type = MELEE_ATTACK)
	SIGNAL_HANDLER
	var/was_perfect = FALSE
	if(!(attack_type in parryable_attack_types))
		return
	var/time_since_parry = world.time - time_parried
	if(time_since_parry > parry_time_out_time)
		return

	var/armour_penetration_percentage = 0
	var/armour_penetration_flat = 0

	if(isitem(hitby))
		var/obj/item/I = hitby
		armour_penetration_percentage = I.armour_penetration_percentage
		armour_penetration_flat = I.armour_penetration_flat

	if(armour_penetration_flat + armour_penetration_percentage >= 100)
		return

	var/stamina_damage = stamina_coefficient * (((time_since_parry / parry_time_out_time) + armour_penetration_percentage / 100) * (damage + armour_penetration_flat)) + stamina_constant

	if(!no_parry_sound)
		var/sound_to_play
		if(attack_type == PROJECTILE_ATTACK)
			sound_to_play = pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg')
		else
			sound_to_play = 'sound/weapons/parry.ogg'

		playsound(owner, sound_to_play, clamp(stamina_damage, 40, 120))
	if(time_since_parry <= parry_time_out_time * 0.5) // a perfect parry
		was_perfect = TRUE

	owner.adjustStaminaLoss(stamina_damage)
	if(owner.getStaminaLoss() < 100)
		if(!was_perfect)
			return COMPONENT_BLOCK_SUCCESSFUL
		return (COMPONENT_BLOCK_SUCCESSFUL | COMPONENT_BLOCK_PERFECT)

/datum/component/parry/proc/on_parent_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += examine_text
