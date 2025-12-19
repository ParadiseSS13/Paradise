// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flash_protect = FLASH_PROTECTION_WELDER
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
	)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/projectile/shotgun/boltaction/lionhunter, /obj/item/melee/cultblade/haunted)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// Quite well armored, though not vs disablers
	armor = list(MELEE = 50, BULLET = 40, LASER = 30, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 20)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
	)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	// Our hood gains the heretic_focus element.
	. += SPAN_NOTICE("Allows you to cast heretic spells while the hood is up.")

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
// To future coders, if we get atom storage, make it back into a hood again.

/obj/item/clothing/suit/hooded/cultrobes/eldritch/mob_can_equip(mob/M, slot, disable_warning)
	if(!IS_HERETIC(M))
		to_chat(M, SPAN_HIEROPHANT("The armor refuses to be equipped, repelling your attempts."))
		return FALSE
	. = ..()


/obj/item/clothing/suit/storage/void_cloak
	name = "void cloak"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	flags_inv = NONE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 25, LASER = 20, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 5)
	actions_types = list(/datum/action/item_action/toggle)
	pockets = /obj/item/storage/internal/void_cloak
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/projectile/shotgun/boltaction/lionhunter, /obj/item/melee/cultblade/haunted)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
	)
	/// Are we invisible?
	var/cloak_invisible = FALSE

/obj/item/clothing/suit/storage/void_cloak/Initialize(mapload)
	. = ..()
	make_visible()
	// We have to overide the initalize from above
	pockets.storage_slots = 3	//two slots
	pockets.max_w_class = WEIGHT_CLASS_NORMAL
	pockets.max_combined_w_class = 5

/obj/item/storage/internal/void_cloak
	silent = TRUE //Sneaky cloak, sneaky storage
	can_hold = list(
		/obj/item/ammo_box/lionhunter,
		/obj/item/heretic_labyrinth_handbook,
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/food/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/drinks/bottle/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
		/obj/item/ammo_box/lionhunter,
	)

/obj/item/clothing/suit/storage/void_cloak/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OUTER_SUIT)
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(hide_item))
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(show_item))
	if(IS_HERETIC(user))
		make_invisible()
	else
		make_visible()
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()

/obj/item/clothing/suit/storage/void_cloak/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM))

/obj/item/clothing/suit/storage/void_cloak/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_OUTER_SUIT) //we only give the mob the ability to activate the vest if he's actually wearing it.
		return TRUE

/obj/item/clothing/suit/storage/void_cloak/attack_self__legacy__attackchain(mob/user)
	if(!IS_HERETIC(user))
		to_chat(user, SPAN_HIEROPHANT("You lack the forbidden knowledge to access this cloaks potential."))
		return
	if(cloak_invisible)
		make_visible()
	else
		make_invisible()
	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc
		C.update_inv_wear_suit()


/obj/item/clothing/suit/storage/void_cloak/proc/hide_item(atom/movable/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(slot & ITEM_SLOT_SUIT_STORE)
		ADD_TRAIT(item, TRAIT_SKIP_EXAMINE, UID())
		ADD_TRAIT(item, TRAIT_NO_STRIP, UID())
		ADD_TRAIT(item, TRAIT_NO_WORN_ICON, UID())


/obj/item/clothing/suit/storage/void_cloak/proc/show_item(atom/movable/source, obj/item/item)
	SIGNAL_HANDLER
	REMOVE_TRAIT(item, TRAIT_NO_STRIP, UID())
	REMOVE_TRAIT(item, TRAIT_SKIP_EXAMINE, UID())
	REMOVE_TRAIT(item, TRAIT_NO_WORN_ICON, UID())

/obj/item/clothing/suit/storage/void_cloak/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	// Let examiners know this works as a focus only if the hood is down
	. += SPAN_NOTICE("Allows you to cast heretic spells while the hood is down.")

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/storage/void_cloak/proc/make_invisible()
	ADD_TRAIT(src, TRAIT_SKIP_EXAMINE, UID())
	ADD_TRAIT(src, TRAIT_NO_STRIP, UID())
	icon_state = "void_cloak_invisible"
	cloak_invisible = TRUE
	RemoveElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.visible_message(SPAN_NOTICE("Light shifts around [loc], making the cloak around them invisible!"))

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/storage/void_cloak/proc/make_visible()
	REMOVE_TRAIT(src, TRAIT_SKIP_EXAMINE, UID())
	REMOVE_TRAIT(src, TRAIT_NO_STRIP, UID())
	AddElement(/datum/element/heretic_focus)
	icon_state = "void_cloak"
	cloak_invisible = FALSE
	if(isliving(loc))
		loc.visible_message(SPAN_NOTICE("A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!"))
