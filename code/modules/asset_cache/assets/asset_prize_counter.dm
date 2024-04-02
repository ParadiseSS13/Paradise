/datum/asset/spritesheet/prize_counter
	name = "prize_counter"

/datum/asset/spritesheet/prize_counter/create_spritesheets()
	for(var/datum/prize_item/prize in GLOB.global_prizes.prizes)
		var/obj/item/prize_item = prize.typepath
		var/prize_icon = icon(icon = initial(prize_item.icon), icon_state = initial(prize_item.icon_state))
		var/imgid = replacetext(replacetext("[prize_item]", "/obj/item/", ""), "/", "-")
		Insert(imgid, prize_icon)

/datum/asset/spritesheet/prize_counter/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset
