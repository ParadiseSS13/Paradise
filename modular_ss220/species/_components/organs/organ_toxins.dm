/*
=== Органы-токсины ===
Реализует процесс повреждения урона если в орагнизме обнаружен токсинный урон
*/

#define TOX_ORGANS_PROCESS 1

/datum/component/organ_toxin_damage
	var/obj/item/organ/internal/organ = null
	var/toxin_damage_rate

/datum/component/organ_toxin_damage/Initialize(tox_rate = TOX_ORGANS_PROCESS)
	organ = parent
	toxin_damage_rate = tox_rate

/datum/component/organ_toxin_damage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_TOX_HANDLE, PROC_REF(tox_handle_organ))

/datum/component/organ_toxin_damage/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ORGAN_TOX_HANDLE)

/datum/component/organ_toxin_damage/proc/tox_handle_organ()
	SIGNAL_HANDLER
	if(organ.status & ORGAN_DEAD)
		return
	if(organ.owner?.get_damage_amount(TOX))
		var/obj/item/organ/internal/liver/target_liver = organ.owner.get_int_organ(/obj/item/organ/internal/liver)
		var/obj/item/organ/internal/kidneys/target_kidney = organ.owner.get_int_organ(/obj/item/organ/internal/kidneys)

		if(organ == target_kidney || organ == target_liver)
			organ.receive_damage(organ.owner.get_damage_amount(TOX) * toxin_damage_rate, 1)
			organ.owner.adjustToxLoss(-1 * organ.owner.get_damage_amount(TOX) * toxin_damage_rate)
		else if(target_liver.status == ORGAN_DEAD && target_kidney.status == ORGAN_DEAD)
			organ.receive_damage(organ.owner.get_damage_amount(TOX) * toxin_damage_rate, 1)

#undef TOX_ORGANS_PROCESS
