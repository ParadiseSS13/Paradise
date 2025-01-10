//////////////////////////////
// MARK: Item Test
//////////////////////////////

/obj/item/clothing/glasses/test_chameleon
	name = "optical meson scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"
	resistance_flags = NONE
	prescription_upgradable = TRUE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi'
	)

	// var/datum/action/item_action/chameleon/change/chameleon_action
	var/datum/chameleon_system/chameleon_system

	var/static/list/chameleon_blacklist = list() //This is a typecache
	var/static/chameleon_type = /obj/item/clothing/glasses
	var/static/chameleon_name = "Glasses"

/obj/item/clothing/glasses/test_chameleon/equipped(mob/user, slot, initial = FALSE)
	if(slot == ITEM_SLOT_EYES )
		user.mind.chameleon_system.give_scan()

	if(slot != ITEM_SLOT_EYES && user.mind.chameleon_system.scan)
		user.mind.chameleon_system.lose_scan()

	..()


// Срабатывает каждый раз когда беру в руки, плохо! Например при перекладывание из кармана в руку
/obj/item/clothing/glasses/test_chameleon/pickup(mob/user, silent)
	// SIGNAL_HANDLER
	if(!user.mind.chameleon_system)
		user.mind.chameleon_system = new /datum/chameleon_system(user)

	if(!chameleon_system)
		chameleon_system = user.mind.chameleon_system
		chameleon_system.link_item(src, chameleon_name, chameleon_type, chameleon_blacklist)

	..()

/obj/item/clothing/glasses/test_chameleon/dropped(mob/user, silent)
	// SIGNAL_HANDLER
	if(!chameleon_system)
		return ..()

	chameleon_system.unlink_item(src)
	chameleon_system = null
	..()

