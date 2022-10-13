/datum/component/parry
	/// the world.time we last parried at
	var/time_parried
	/// the max time since `time_parried` that counts as a perfect parry
	var/perfect_parry_window
	/// the max time since `time_parried` that the shield is still considered "active"
	var/parry_time_out_time

	/// the flat amount of damage the shield user takes per non-perfect parry
	var/stamina_constant
	/// stamina_coefficient * damage * time_since_time_parried = stamina damage taken per non perfect parry
	var/stamina_coefficient
	/// the attack types that are considered for parrying
	var/parryable_attack_types

/datum/component/parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/equipped)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, .proc/attempt_parry)

/datum/component/parry/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	UnregisterSignal(parent, COMSIG_ITEM_HIT_REACT)
	var/obj/item/I = parent
	if(ismob(I.loc))
		UnregisterSignal(I.loc, COMSIG_LIVING_RESIST)

/datum/component/parry/Initialize(_perfect_parry_window = 0, _stamina_constant = 0, _stamina_coefficient = 0, _parry_time_out_time = 1 SECONDS, _parryable_attack_types = ALL_ATTACK_TYPES)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	perfect_parry_window = _perfect_parry_window
	parry_time_out_time = _parry_time_out_time
	stamina_constant = _stamina_constant
	stamina_coefficient = _stamina_coefficient
	if(islist(_parryable_attack_types))
		parryable_attack_types = _parryable_attack_types
	else
		parryable_attack_types = list(_parryable_attack_types)

/datum/component/parry/proc/equipped(datum/source, mob/user)
	RegisterSignal(user, COMSIG_LIVING_RESIST, .proc/start_parry)

/datum/component/parry/proc/dropped(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_LIVING_RESIST)

/datum/component/parry/proc/start_parry(datum/source)
	time_parried = world.time

/datum/component/parry/proc/attempt_parry(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_type = MELEE_ATTACK)
	if(!(attack_type in parryable_attack_types))
		return
	var/time_since_parry = world.time - time_parried
	if(time_since_parry > parry_time_out_time)
		return
	var/stamina_damage = (time_since_parry / parry_time_out_time) * damage * stamina_coefficient + stamina_constant

	var/sound_to_play
	if(attack_type == PROJECTILE_ATTACK)
		sound_to_play = pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg')
	else
		sound_to_play = 'sound/weapons/parry.ogg'

	playsound(owner, sound_to_play, clamp(stamina_damage, 40, 120))

	if(time_since_parry <= perfect_parry_window) // a perfect parry
		if(isliving(hitby))
			var/mob/living/L = hitby
			L.changeNext_move(CLICK_CD_MELEE)
			L.Slowed(2 SECONDS, 1)
		return COMPONENT_BLOCK_SUCCESSFUL

	owner.adjustStaminaLoss(stamina_damage)
	if(owner.getStaminaLoss() < 100)
		return COMPONENT_BLOCK_SUCCESSFUL



