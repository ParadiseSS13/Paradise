/**
* Materials system
*
* Replaces all of the horrible variables that tracked each individual thing.
*/

/**
* MATERIALS DATUM
*
* Tracks and manages material storage for an object.
*/
/datum/materials
	var/list/datum/material/storage[0]

/datum/materials/New()
	for(var/matdata in subtypesof(/datum/material))
		var/datum/material/mat = new matdata
		storage[mat.id]=mat

/datum/materials/proc/addAmount(var/mat_id,var/amount)
	if(!(mat_id in storage))
		warning("addAmount(): Unknown material [mat_id]!")
		return
	// I HATE BYOND
	// storage[mat_id].stored++
	var/datum/material/mat=storage[mat_id]
	mat.stored += amount
	storage[mat_id]=mat

/datum/materials/proc/removeAmount(var/mat_id,var/amount)
	if(!(mat_id in storage))
		warning("removeAmount(): Unknown material [mat_id]!")
		return
	addAmount(mat_id,-amount)

/datum/materials/proc/getAmount(var/mat_id)
	if(!(mat_id in storage))
		warning("getAmount(): Unknown material [mat_id]!")
		return 0

	var/datum/material/mat=getMaterial(mat_id)
	return mat.stored

/datum/materials/proc/getMaterial(var/mat_id)
	if(!(mat_id in storage))
		warning("getMaterial(): Unknown material [mat_id]!")
		return 0

	return storage[mat_id]


/datum/material
	var/name=""
	var/processed_name=""
	var/id=""
	var/stored=0
	var/cc_per_sheet=CC_PER_SHEET_MISC
	var/oretype=null
	var/sheettype=null
	var/cointype=null
	var/value=0

/datum/material/New()
	if(processed_name=="")
		processed_name=name

/datum/material/iron
	name="Iron"
	id="iron"
	value=1
	cc_per_sheet=CC_PER_SHEET_METAL
	oretype=/obj/item/weapon/ore/iron
	sheettype=/obj/item/stack/sheet/metal
	cointype=/obj/item/weapon/coin/iron

/datum/material/glass
	name="Sand"
	processed_name="Glass"
	id="glass"
	value=1
	cc_per_sheet=CC_PER_SHEET_GLASS
	oretype=/obj/item/weapon/ore/glass
	sheettype=/obj/item/stack/sheet/glass

/datum/material/diamond
	name="Diamond"
	id="diamond"
	value=40
	oretype=/obj/item/weapon/ore/diamond
	sheettype=/obj/item/stack/sheet/mineral/diamond
	cointype=/obj/item/weapon/coin/diamond

/datum/material/plasma
	name="Plasma"
	id="plasma"
	value=40
	oretype=/obj/item/weapon/ore/plasma
	sheettype=/obj/item/stack/sheet/mineral/plasma
	cointype=/obj/item/weapon/coin/plasma

/datum/material/gold
	name="Gold"
	id="gold"
	value=20
	oretype=/obj/item/weapon/ore/gold
	sheettype=/obj/item/stack/sheet/mineral/gold
	cointype=/obj/item/weapon/coin/gold

/datum/material/silver
	name="Silver"
	id="silver"
	value=20
	oretype=/obj/item/weapon/ore/silver
	sheettype=/obj/item/stack/sheet/mineral/silver
	cointype=/obj/item/weapon/coin/silver

/datum/material/uranium
	name="Uranium"
	id="uranium"
	value=20
	oretype=/obj/item/weapon/ore/uranium
	sheettype=/obj/item/stack/sheet/mineral/uranium
	cointype=/obj/item/weapon/coin/uranium

/datum/material/clown
	name="Bananium"
	id="clown"
	value=100
	oretype=/obj/item/weapon/ore/clown
	sheettype=/obj/item/stack/sheet/mineral/clown
	cointype=/obj/item/weapon/coin/clown

/datum/material/plastic
	name="Plastic"
	id="plastic"
	value=1
	oretype=null
	sheettype=/obj/item/stack/sheet/mineral/plastic
	cointype=null

/datum/material/fabric
	name="Fabric"
	id="fabric"
	value=20
	oretype=/obj/item/weapon/ore/fabric
	sheettype=null
	cointype=null