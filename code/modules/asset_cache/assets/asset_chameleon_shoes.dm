/// Sprites for job icons.
/datum/asset/spritesheet/cham_shoes
	name = "cham_shoes"

/datum/asset/spritesheet/cham_shoes/create_spritesheets()
	for(var/V in typesof(/obj/item/clothing/shoes))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if((initial(I.flags) & ABSTRACT) || !initial(I.icon_state) || (initial(I.icon_state) in sprites))
				continue
			Insert(initial(I.icon_state), initial(I.icon), initial(I.icon_state))


/datum/asset/spritesheet/cham_shoes/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset



/datum/asset/spritesheet/chameleon
	name = "chameleon"
	var/chameleon_type

/datum/asset/spritesheet/chameleon/New(_chameleon_type, chameleon_name)
	chameleon_type = _chameleon_type
	name = chameleon_name
	. = ..()

/datum/asset/spritesheet/chameleon/create_spritesheets()
	for(var/V in typesof(chameleon_type))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if((initial(I.flags) & ABSTRACT) || !initial(I.icon_state) || (initial(I.icon_state) in sprites))
				continue
			Insert(initial(I.icon_state), initial(I.icon), initial(I.icon_state))


/datum/asset/spritesheet/chameleon/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset
