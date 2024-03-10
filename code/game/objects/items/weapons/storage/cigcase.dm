/obj/item/storage/cigcase
	name = "cigarette case"
	desc = "A durable case for holding cigarettes and a variety of other things that can fit in it. You have a strange urge to crouch and look up when holding it."
	storage_slots = 15
	icon = 'icons/obj/wallets.dmi'
	icon_state = "cigcase"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=3"
	resistance_flags = FIRE_PROOF
	materials = list(MAT_TITANIUM = 500)
	can_hold = list(
		/obj/item/stack/spacecash,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/disk,
		/obj/item/bio_chip_implanter,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/rollingpaper,
		/obj/item/clothing/accessory/medal,
		/obj/item/clothing/accessory/holobadge
		)
	cant_hold = list(
		/obj/item/toy/crayon/spraycan
	)

/obj/item/storage/cigcase/nt_rep
	name = "golden cigarette case"
	desc = "A fancy golden cigarette case made in cooperation with Louis Crabbemarche. Often given to diplomats and representatives as a gift."
	storage_slots = 20
	icon_state = "cigcase_nt"
	origin_tech = "materials=5"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	materials = list(MAT_GOLD = 500)
