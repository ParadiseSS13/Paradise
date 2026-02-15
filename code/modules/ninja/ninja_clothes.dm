/obj/item/clothing/head/helmet/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja scarf"
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_hood"
	flags = BLOCKHAIR
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	blockTracking = 1
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Diona" = 'icons/mob/clothing/species/diona/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/vox/head.dmi',
	)
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

/obj/item/clothing/mask/gas/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_mask"
	flash_protect = FLASH_PROTECTION_FLASH
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/mask.dmi'
	sprite_sheets = list(
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/mask.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/mask.dmi',
		"Diona" = 'icons/mob/clothing/species/diona/mask.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/mask.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/skkulakin/mask.dmi',
	)
	var/obj/item/voice_changer/voice_changer

/obj/item/clothing/mask/gas/space_ninja/Initialize(mapload)
	. = ..()
	voice_changer = new(src)

/obj/item/clothing/mask/gas/space_ninja/Destroy()
	QDEL_NULL(voice_changer)
	return ..()

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	siemens_coefficient = 0
	pickpocket = TRUE // Master of stealth, you can pick a pocket
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/vox/gloves.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/gloves.dmi',
		"Diona" = 'icons/mob/clothing/species/diona/gloves.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/gloves.dmi',
	)

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
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/shoes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/shoes.dmi',
		"Diona" = 'icons/mob/clothing/species/diona/shoes.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/shoes.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/vox/shoes.dmi',
	)
	/// Linked freedoms action
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
	flags_inv = HIDEJUMPSUIT
	armor = list(MELEE = 30, BULLET = 35, LASER = 25, ENERGY = 25, BOMB = 20, RAD = 100, FIRE = INFINITY, ACID = INFINITY)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/suit.dmi',
		"Diona" = 'icons/mob/clothing/species/diona/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/vox/suit.dmi',
	)
	/// Linked stims action
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

/obj/item/storage/bag/garment/syndie/ninja_suit
	name = "ninja suit garment bag"

/obj/item/storage/bag/garment/syndie/ninja_suit/populate_contents()
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/shoes/space_ninja(src)
	new /obj/item/clothing/gloves/space_ninja(src)
	new /obj/item/clothing/head/helmet/space_ninja(src)
	new /obj/item/clothing/mask/gas/space_ninja(src)
	new /obj/item/clothing/suit/space_ninja(src)

/obj/item/card/id/syndicate/ninja
	name = "ninja card"
	initial_access = list(ACCESS_MAINT_TUNNELS)
	icon_state = "data"
