/obj/item/clothing/head/helmet/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja scarf"
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_hood"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	blockTracking = 1
	/// Tracking the cloak action
	var/datum/action/cooldown/ninja/ninja_cloak/cloak_action

/obj/item/clothing/head/helmet/space_ninja/Initialize(mapload)
	. = ..()
	cloak_action = new(src)

/obj/item/clothing/head/helmet/space_ninja/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user))
		return
	if(slot != ITEM_SLOT_HEAD)
		return
	cloak_action.Grant(user)

/obj/item/clothing/head/helmet/space_ninja/dropped(mob/user, silent)
	. = ..()
	cloak_action.stop_sneaking()
	cloak_action.Remove(user)

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	siemens_coefficient = 0
	pickpocket = 1 // Master of stealth, you can pick a pocket
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/mask/gas/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja(norm)"
	inhand_icon_state = "s-ninja_mask"
	flash_protect = FLASH_PROTECTION_FLASH
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi'
	)
	var/obj/item/voice_changer/voice_changer

/obj/item/clothing/mask/gas/space_ninja/Initialize(mapload)
	. = ..()
	voice_changer = new(src)

/obj/item/clothing/mask/gas/space_ninja/Destroy()
	QDEL_NULL(voice_changer)
	return ..()

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	no_slip = TRUE
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	var/datum/action/cooldown/ninja/freedom_shoes/freedoms_action

/obj/item/clothing/shoes/space_ninja/Initialize(mapload)
	. = ..()
	freedoms_action = new(src)

/obj/item/clothing/shoes/space_ninja/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user))
		return
	if(slot != ITEM_SLOT_SHOES)
		return
	ADD_TRAIT(user, TRAIT_GOTTAGONOTSOFAST, src)
	freedoms_action.Grant(user)

/obj/item/clothing/shoes/space_ninja/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GOTTAGONOTSOFAST, src)
	freedoms_action.Remove(user)

/obj/item/clothing/suit/space_ninja
	name = "ninja kabuto"
	desc = "A unique suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_suit"
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/melee/baton,
		/obj/item/tank/internals,
		/obj/item/katana/energy,
		/obj/item/restraints/handcuffs
	)
	flags_inv = HIDEJUMPSUIT | HIDETAIL
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	var/datum/action/cooldown/ninja/stim_suit/antistun_action

/obj/item/clothing/suit/space_ninja/Initialize(mapload)
	. = ..()
	antistun_action = new(src)

/obj/item/clothing/suit/space_ninja/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user))
		return
	if(slot != ITEM_SLOT_OUTER_SUIT)
		return
	antistun_action.Grant(user)

/obj/item/clothing/suit/space_ninja/dropped(mob/user, silent)
	. = ..()
	antistun_action.Remove(user)
