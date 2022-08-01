
/obj/proc/get_card_account(obj/item/card/I)
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = I
		var/datum/money_account/D = GLOB.station_money_database.find_user_account(C.associated_account_number)
		if(D)
			return D

/mob/proc/get_worn_id_account()
	if(ishuman(src))
		var/mob/living/carbon/human/H=src
		var/obj/item/card/id/I=H.get_idcard()
		if(!I || !istype(I))
			return null
		var/datum/money_account/D = GLOB.station_money_database.find_user_account(I.associated_account_number)
		return D
