/*
===Компонент на атаку парного оружия
Срабатывает при атаке оружием. Второе оружие через паузу в 0.2 секунды запускает атаку.

Срабатывает только, если оружие одинаковое.
*/

/datum/component/double_attack
	var/state_attack = FALSE
	var/attack_CD = 0

/datum/component/double_attack/Initialize(attack_CD_OVR = 0)
	attack_CD = attack_CD_OVR

/datum/component/double_attack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(hand_pre_attack))

/datum/component/double_attack/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ITEM_ATTACK)

/datum/component/double_attack/proc/hand_pre_attack(obj/item/weapon, mob/living/target, mob/living/user, def_zone)
	SIGNAL_HANDLER
	var/hand_item = user.get_active_hand()
	if(hand_item && !state_attack)
		state_attack = TRUE
		var/attack_haste = attack_CD ? attack_CD : user.next_move_modifier / 5
		addtimer(CALLBACK(src, PROC_REF(hand_attack), target, user, def_zone, hand_item), attack_haste SECONDS)

/datum/component/double_attack/proc/hand_attack(mob/living/target, mob/living/user, def_zone, obj/item/hand_item)
	if(QDELETED(src) || QDELETED(target) || user != hand_item.loc  || !user.Adjacent(target))
		return
	hand_item.attack(target, user, def_zone)
	state_attack = FALSE
