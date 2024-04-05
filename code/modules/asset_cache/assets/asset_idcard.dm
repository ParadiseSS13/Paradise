/datum/asset/spritesheet/idcards
	name = "idcards"

/datum/asset/spritesheet/idcards/create_spritesheets()
	for(var/state in get_all_card_skins())
		Insert(state, 'icons/obj/card.dmi', state)

/datum/asset/spritesheet/idcards/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64,64)
	return pre_asset
