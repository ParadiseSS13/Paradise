/// Sprites for job icons.
/datum/asset/spritesheet/cham_shoes
	name = "cham_shoes"

/datum/asset/spritesheet/cham_shoes/create_spritesheets()
	for(var/V in typesof(/obj/item/clothing/shoes))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if((initial(I.flags) & ABSTRACT) || !initial(I.icon_state))
				continue
			Insert(initial(I.name), 'icons/obj/clothing/shoes.dmi', SOUTH)


/datum/asset/spritesheet/cham_shoes/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	return pre_asset
