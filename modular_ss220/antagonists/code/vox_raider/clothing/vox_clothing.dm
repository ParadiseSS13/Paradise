/obj/item/clothing/under/vox/jumpsuit
	name = "vox jumpsuit"
	desc = "Рабочая одежда вокса."
	icon_state = "vox-jumpsuit"
	item_color = "vox-jumpsuit"
	item_state = "syndicate-black"
	species_restricted = list("Vox")
	icon = 'modular_ss220/antagonists/icons/clothing/obj_under.dmi'
	icon_override = 'modular_ss220/antagonists/icons/clothing/mob/vox/uniform.dmi'
	sprite_sheets = list(
		"Vox" = 'modular_ss220/antagonists/icons/clothing/mob/vox/uniform.dmi'
		)
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/jumpsuit/red
	name = "vox work jumpsuit"
	icon_state = "vox-jumpsuit_red"
	item_color = "vox-jumpsuit_red"

/obj/item/clothing/under/vox/jumpsuit/teal
	name = "vox teal jumpsuit"
	icon_state = "vox-jumpsuit_teal"
	item_color = "vox-jumpsuit_teal"

/obj/item/clothing/under/vox/jumpsuit/blue
	name = "vox blue jumpsuit"
	icon_state = "vox-jumpsuit_blue"
	item_color = "vox-jumpsuit_blue"

/obj/item/clothing/under/vox/jumpsuit/green
	name = "vox green jumpsuit"
	icon_state = "vox-jumpsuit_green"
	item_color = "vox-jumpsuit_green"

/obj/item/clothing/under/vox/jumpsuit/yellow
	name = "vox yellow jumpsuit"
	icon_state = "vox-jumpsuit_yellow"
	item_color = "vox-jumpsuit_yellow"

/obj/item/clothing/under/vox/jumpsuit/purple
	name = "vox purple jumpsuit"
	icon_state = "vox-jumpsuit_purple"
	item_color = "vox-jumpsuit_purple"

// ================
//		loadout
/datum/gear/racial/vox_jumpsuit
	display_name = "vox work jumpsuit"
	description = "These loose clothes are optimized for the labors of the lower castes onboard the arkships. Large openings in the top allow for breathability while the pants are durable yet flexible enough to not restrict movement."
	path = /obj/item/clothing/under/vox/jumpsuit
	slot = SLOT_HUD_JUMPSUIT

/datum/gear/racial/vox_jumpsuit/red
	display_name = "vox red jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/red

/datum/gear/racial/vox_jumpsuit/teal
	display_name = "vox teal jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/teal

/datum/gear/racial/vox_jumpsuit/blue
	display_name = "vox blue jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/blue

/datum/gear/racial/vox_jumpsuit/green
	display_name = "vox green jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/green

/datum/gear/racial/vox_jumpsuit/yellow
	display_name = "vox yellow jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/yellow

/datum/gear/racial/vox_jumpsuit/purple
	display_name = "vox purple jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/purple

// ================
