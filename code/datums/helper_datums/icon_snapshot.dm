/datum/icon_snapshot
	var/name
	var/icon
	var/icon_state
	var/list/overlays
	//используется только для ниндзя
	var/examine_text
	var/assignment = "Unknown"
	var/rank = "Unknown"

/datum/icon_snapshot/proc/makeImg()
	if(!icon || !icon_state)
		return
	var/obj/temp = new
	temp.icon = icon
	temp.icon_state = icon_state
	temp.overlays = overlays.Copy()
	var/icon/tempicon = getFlatIcon(temp) // TODO Actually write something less heavy-handed for this
	return tempicon

/datum/icon_snapshot/proc/copyInfoFrom(mob/living/carbon/human/target_mob)
	name = target_mob.name
	icon = target_mob.icon
	icon_state = target_mob.icon_state
	examine_text = target_mob.examine()
	overlays = target_mob.get_overlays_copy(list(L_HAND_LAYER,R_HAND_LAYER))
	var/obj/item/id_slot_item = GetIdCard(target_mob)
	if(istype(id_slot_item, /obj/item/card/id))
		var/obj/item/card/id/id_idCard = id_slot_item
		assignment = id_idCard.assignment
		rank = id_idCard.rank
	if(istype(id_slot_item, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/id_wallet = id_slot_item
		if(id_wallet.front_id)
			assignment = id_wallet.front_id.assignment
			rank = id_wallet.front_id.rank
