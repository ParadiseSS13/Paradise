/mob/proc/get_worn_id_account()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/card/id/I = H.get_idcard()
		if(!istype(I))
			return null
		var/datum/money_account/D = GLOB.station_money_database.find_user_account(I.associated_account_number)
		return D
