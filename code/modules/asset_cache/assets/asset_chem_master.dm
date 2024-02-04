/// Pill sprites for UIs
/datum/asset/spritesheet/chem_master
	name = "chem_master"

/datum/asset/spritesheet/chem_master/create_spritesheets()
	for(var/pill_type = 1 to 20)
		Insert("pill[pill_type]", 'icons/obj/chemical.dmi', "pill[pill_type]")
	for(var/bottle_type in list("bottle", "small_bottle", "wide_bottle", "round_bottle", "reagent_bottle"))
		Insert(bottle_type, 'icons/obj/chemical.dmi', bottle_type)

/datum/asset/spritesheet/chem_master/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(64, 64)
	pre_asset.Crop(16,16,48,48)
	pre_asset.Scale(32, 32)
	return pre_asset
