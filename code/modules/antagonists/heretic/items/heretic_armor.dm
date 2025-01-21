// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/projectile/shotgun/boltaction/lionhunter)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// Quite well armored, though not vs disablers
	armor = list(MELEE = 50, BULLET = 40, LASER = 30, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 20)


/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	// Our hood gains the heretic_focus element.
	. += "<span class='notice'>Allows you to cast heretic spells while the hood is up.</span>"

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	armor = list(MELEE = 30, BULLET = 25, LASER = 20, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 5)


/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SKIP_EXAMINE, UID(src))
	ADD_TRAIT(src, TRAIT_NO_STRIP, UID(src))

/obj/item/clothing/suit/hooded/cultrobes/void //doesnt need to be a hood, tht is the solutiohn
	name = "void cloak"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 25, LASER = 20, ENERGY = 10, BOMB = 15, RAD = 0, FIRE = 5, ACID = 5)

/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	//create_storage(storage_type = /datum/storage/pockets/void_cloak) QWERTODO: FIGURE OUT STORAGE
	make_visible()

/obj/item/clothing/suit/hooded/cultrobes/void/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OUTER_SUIT)
		RegisterSignal(user, COMSIG_ITEM_EQUIPPED, PROC_REF(hide_item))
		RegisterSignal(user, COMSIG_ITEM_DROPPED, PROC_REF(show_item))

/obj/item/clothing/suit/hooded/cultrobes/void/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/hide_item(atom/movable/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot & ITEM_SLOT_SUIT_STORE)
		ADD_TRAIT(source, TRAIT_SKIP_EXAMINE, UID(src))
		ADD_TRAIT(source, TRAIT_NO_STRIP, UID(src))

/obj/item/clothing/suit/hooded/cultrobes/void/proc/show_item(atom/movable/source, mob/equipper, slot)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_NO_STRIP, UID(src))
	REMOVE_TRAIT(source, TRAIT_SKIP_EXAMINE, UID(src))

/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	// Let examiners know this works as a focus only if the hood is down
	. += "<span class='notice'>Allows you to cast heretic spells while the hood is down.</span>"

/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	make_visible()
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/try_to_deploy()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")
	var/mob/living/wearer = loc
	if(IS_HERETIC_OR_MONSTER(wearer))
		return TRUE

	to_chat(loc, "You can't seem to get the hood up!")
	return FALSE

/obj/item/clothing/suit/hooded/cultrobes/void/on_hood_deploy()
	make_invisible()

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	ADD_TRAIT(src, TRAIT_SKIP_EXAMINE, UID(src))
	ADD_TRAIT(src, TRAIT_NO_STRIP, UID(src))
	RemoveElement(/datum/element/heretic_focus)

	if(isliving(loc))
		REMOVE_TRAIT(loc, TRAIT_RESISTLOWPRESSURE, UID(src))
		loc.visible_message("<span class='notice'>Light shifts around [loc], making the cloak around them invisible!</span>")

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	REMOVE_TRAIT(src, TRAIT_SKIP_EXAMINE, UID(src))
	REMOVE_TRAIT(src, TRAIT_NO_STRIP, UID(src))
	AddElement(/datum/element/heretic_focus)

	if(isliving(loc))
		ADD_TRAIT(loc, TRAIT_RESISTLOWPRESSURE, UID(src))
		loc.visible_message("<span class='notice'>A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!</span>")
