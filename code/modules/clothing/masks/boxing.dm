/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY!"
	icon_state = "balaclava"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	can_toggle = TRUE
	actions_types = list(/datum/action/item_action/adjust)
	adjusted_flags = ITEM_SLOT_HEAD
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/balaclava/attack_self__legacy__attackchain(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/luchador
	name = "luchador mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi'
		)

/obj/item/clothing/mask/luchador/tecnicos
	name = "tecnicos mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "rudos mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"
