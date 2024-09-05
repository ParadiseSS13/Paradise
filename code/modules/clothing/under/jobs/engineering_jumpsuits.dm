/obj/item/clothing/under/rank/engineering
	icon = 'icons/obj/clothing/under/engineering.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/engineering.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/engineering.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/engineering.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/engineering.dmi'
		)

/obj/item/clothing/under/rank/engineering/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpsuit"
	icon_state = "chiefengineer"
	item_state = "chief"
	item_color = "chief"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 200, ACID = 35)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpskirt"
	icon_state = "chieff"
	item_color = "chieff"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	item_state = "atmos_suit"
	item_color = "atmos"
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist
	name = "atmospheric technician's jumpsuit"
	desc = "A light jumpsuit useful for squeezing through narrow vents."
	resistance_flags = FIRE_PROOF

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != SLOT_HUD_JUMPSUIT)
		return
	if(!user.ventcrawler)
		user.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/dropped(mob/living/carbon/human/user)
	. = ..()
	if(user.get_item_by_slot(SLOT_HUD_JUMPSUIT) != src)
		return
	if(!user.get_int_organ(/obj/item/organ/internal/heart/gland/ventcrawling)) // This is such a snowflaky check
		user.ventcrawler = VENTCRAWLER_NONE

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/proc/check_clothing(mob/user as mob)
	//Allowed to wear: glasses, shoes, gloves, pockets, mask, and jumpsuit (obviously)
	var/list/slot_must_be_empty = list(SLOT_HUD_BACK,SLOT_HUD_HANDCUFFED,SLOT_HUD_LEGCUFFED,SLOT_HUD_LEFT_HAND,SLOT_HUD_RIGHT_HAND,SLOT_HUD_BELT,SLOT_HUD_HEAD,SLOT_HUD_OUTER_SUIT)
	for(var/slot_id in slot_must_be_empty)
		if(user.get_item_by_slot(slot_id))
			to_chat(user,"<span class='warning'>You can't fit inside while wearing \the [user.get_item_by_slot(slot_id)].</span>")
			return 0
	return 1

/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	desc = "It's a jumpskirt worn by atmospheric technicians."
	name = "atmospheric technician's jumpskirt"
	icon_state = "atmosf"
	item_color = "atmosf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineering/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	item_state = "engi_suit"
	item_color = "engine"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 75, ACID = 10)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/engineer/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/engineering/engineer/skirt
	desc = "It's an orange high visibility jumpskirt worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpskirt"
	icon_state = "enginef"
	item_color = "enginef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
