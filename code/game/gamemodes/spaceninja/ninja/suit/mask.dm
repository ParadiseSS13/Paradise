/**
 * # Ninja Mask
 *
 * Space ninja's mask.  Other than looking cool, doesn't do anything.
 *
 * A mask which only spawns as a part of space ninja's starting kit.  Functions as a gas mask.
 *
 */
/obj/item/clothing/mask/gas/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "ninja_mask_classic_thermals"
	item_state = "ninja_mask_classic_thermals"
	strip_delay = 120
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	flags_cover = MASKCOVERSEYES	//We don't need to cover mouth
	flash_protect = -1	//Не должна защищать от флешек
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | NO_MOUSTACHING
	// "classic"	- Классическая белая маска
	// "new"		- Чёрная маска-визор
	var/visuals_type = "classic"
	var/obj/item/voice_changer/ninja/voice_changer

/obj/item/clothing/mask/gas/space_ninja/Initialize(mapload)
	. = ..()
	voice_changer = new(src)

/obj/item/clothing/mask/gas/space_ninja/Destroy()
	QDEL_NULL(voice_changer)
	return ..()
