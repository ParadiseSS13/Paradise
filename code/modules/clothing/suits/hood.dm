//Hoods for winter coats and dark robes etc

/obj/item/clothing/suit/hooded
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this
	/// If this variable is true, the hood can not be removed if the hood is nodrop
	var/respects_nodrop = FALSE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/hood_component, hoodtype, TRUE, respects_nodrop)

/obj/item/clothing/suit/hooded/Destroy()
	QDEL_NULL(hood)
	. = ..()

/obj/item/clothing/head/hooded
	var/obj/item/clothing/suit/hooded/suit

/obj/item/clothing/head/hooded/Destroy()
	suit = null
	return ..()

/obj/item/clothing/head/hooded/screened_niqab
	name = "screened niqab"
	desc = "A niqab with an eye mesh for additional concealment. The wearer can see you, but you can't see them."
	icon_state = "abaya_hood"
	cold_protection = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS | HIDEMASK | HIDEFACE | HIDEEYES
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
		)

/obj/item/clothing/head/hooded/screened_niqab/red
	name = "red niqab"
	icon_state = "redabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/orange
	name = "orange niqab"
	icon_state = "orangeabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/yellow
	name = "yellow niqab"
	icon_state = "yellowabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/green
	name = "green niqab"
	icon_state = "greenabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/blue
	name = "blue niqab"
	icon_state = "blueabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/purple
	name = "purple niqab"
	icon_state = "purpleabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/white
	name = "white niqab"
	icon_state = "whiteabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/rainbow
	name = "rainbow niqab"
	icon_state = "rainbowabaya_hood"
