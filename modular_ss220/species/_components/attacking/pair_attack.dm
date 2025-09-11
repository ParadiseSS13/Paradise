/*
===Компонент на атаку парного оружия
Срабатывает при атаке оружием. Второе оружие через паузу в 0.2 секунды запускает атаку.

Срабатывает только, если оружие одинаковое.
*/

#define PAIRATTACK_RECOIL_MULT 2.5

#define COMSIG_PAIRATTACK_SYNC "sync_states"
#define COMSIG_PAIRATTACK_CHECK "check_state"
#define PAIRATTACK_CHECK_ACTIVE (1<<0)

/datum/component/pair_attack
	var/obj/item/offhand_item = null
	var/state_attack = FALSE
	var/attack_CD = 0

/datum/component/pair_attack/Initialize(attack_CD_OVR = 0)
	attack_CD = attack_CD_OVR

/datum/component/pair_attack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(offhand_pre_attack))
	RegisterSignal(parent, COMSIG_PAIRATTACK_CHECK, PROC_REF(check_state))
	RegisterSignal(parent, COMSIG_PAIRATTACK_SYNC, PROC_REF(sync_states))

/datum/component/pair_attack/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ITEM_ATTACK)
	UnregisterSignal(parent, COMSIG_PAIRATTACK_CHECK)
	UnregisterSignal(parent, COMSIG_PAIRATTACK_SYNC)

//Проверка, что оружие запустило атаку (для избегания цепи атак)
/datum/component/pair_attack/proc/check_state()
	SIGNAL_HANDLER
	return state_attack ? PAIRATTACK_CHECK_ACTIVE : 0

//Синхронизация состояния атак, чтобы оба оружия понимали, что они запустили атаку
/datum/component/pair_attack/proc/sync_states(weapon, newstate)
	SIGNAL_HANDLER
	state_attack = newstate

/datum/component/pair_attack/proc/offhand_pre_attack(obj/item/weapon, mob/living/target, mob/living/user, def_zone)
	SIGNAL_HANDLER
	offhand_item = user.get_inactive_hand()
	if(offhand_item.type != weapon.type)
		return
	if(SEND_SIGNAL(offhand_item, COMSIG_PAIRATTACK_CHECK) & PAIRATTACK_CHECK_ACTIVE)
		return
	state_attack = TRUE
	SEND_SIGNAL(offhand_item, COMSIG_PAIRATTACK_SYNC, state_attack)
	if(offhand_item)
		var/attack_haste = attack_CD ? attack_CD : user.next_move_modifier / 5
		var/attack_recoil = attack_haste * PAIRATTACK_RECOIL_MULT
		addtimer(CALLBACK(src, PROC_REF(offhand_attack), target, user, def_zone), attack_haste SECONDS)
		addtimer(CALLBACK(src, PROC_REF(offhand_post_attack)), attack_recoil SECONDS)

/datum/component/pair_attack/proc/offhand_attack(mob/living/target, mob/living/user, def_zone)
	if(QDELETED(src) || QDELETED(target) || user != offhand_item.loc  || !user.Adjacent(target) || !offhand_item)
		return
	offhand_item.attack(target, user, def_zone)

/datum/component/pair_attack/proc/offhand_post_attack()
	state_attack = FALSE
	if(offhand_item)
		SEND_SIGNAL(offhand_item, COMSIG_PAIRATTACK_SYNC, state_attack)

#undef PAIRATTACK_RECOIL_MULT
#undef COMSIG_PAIRATTACK_SYNC
#undef COMSIG_PAIRATTACK_CHECK
#undef PAIRATTACK_CHECK_ACTIVE
