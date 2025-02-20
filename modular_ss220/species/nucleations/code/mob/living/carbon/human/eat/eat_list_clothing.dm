/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	max_integrity *= 2
	integrity_failure *= 2


//==== =Moth-Nian-Tkach food =====
/obj/item/bedsheet/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 10
	nutritional_value = 15

/obj/item/clothing/Initialize(mapload)

	. = ..()
	material_type = MATERIAL_CLASS_NONE
	bites_limit = 10
	integrity_bite = 20
	nutritional_value = 5


//UNDER
/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 10
	integrity_bite = 40
	nutritional_value = 10


//NECK
/obj/item/clothing/neck/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 8
	nutritional_value = 10


//ACCESSORY
/obj/item/clothing/accessory/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 1

/obj/item/clothing/accessory/holobadge/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/accessory/legal_badge/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/neck/necklace/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/accessory/medal/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE


//GLOVES
/obj/item/clothing/gloves/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 2
	nutritional_value = 10

/obj/item/clothing/gloves/color/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 2
	nutritional_value = 10

/obj/item/clothing/gloves/color/yellow/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/gloves/color/red/insulated/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/gloves/color/red/insulated/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/gloves/color/latex/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/gloves/color/captain/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE


//MASK
/obj/item/clothing/mask/bandana/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 4
	nutritional_value = 10


//HEAD
/obj/item/clothing/head/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 6
	nutritional_value = 10

/obj/item/clothing/head/helmet/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/helmet/space/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/collectable/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/caphat/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/det_hat/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/beret/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/hos/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/warden/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/officer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/surgery/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/welding/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/cakehat/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/kitty/Initialize(mapload)	//Нет. Нельзя.
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/headmirror/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE


//SUIT
/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 16
	nutritional_value = 10

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 20

/obj/item/clothing/suit/chef/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 8

/obj/item/clothing/suit/apron/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_CLOTH
	bites_limit = 8

/obj/item/clothing/suit/chameleon/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/armor/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/storage/Initialize(mapload)		//jacket e.t.c.
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/fire/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE



//Full Costume
/obj/item/clothing/head/cardborg/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/cardborg/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/head/bio_hood/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/bio_suit/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/head/bomb_hood/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/bomb_suit/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/head/radiation/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/radiation/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/head/wizard/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/wizrobe/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/head/beekeeper_head/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/suit/beekeeper_suit/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/suit/hooded/explorer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/head/hooded/explorer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE

/obj/item/clothing/head/beanie/durathread/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
/obj/item/clothing/under/misc/durathread/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_NONE
