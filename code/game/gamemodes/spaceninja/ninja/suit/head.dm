/**
 * # Ninja Hood
 *
 * Space ninja's hood.  Provides armor and blocks AI tracking.
 *
 * A hood that only exists as a part of space ninja's starting kit.  Provides armor equal of space ninja's suit and disallows an AI to track the wearer.
 *
 */
/obj/item/clothing/head/helmet/space/space_ninja
	name = "ninja hood"
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | THICKMATERIAL
	flags_inv = HIDEHEADSETS|HIDENAME
	flags_cover = HEADCOVERSEYES	//We don't need to cover mouth
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "ninja_hood_classic"
	item_state = "ninja_hood_classic"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 25, "fire" = 100, "acid" = 100)
	blockTracking = TRUE //Roughly the only unique thing about this helmet.
	strip_delay = 12
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/**
 * # Ninja Scarf
 *
 * Игроку дана возможность вместо шлема носить не прикрывающий волосы шарф.
 * Если игрок такую возможность активирует, то при инициализации костюма на него наденется шарф,
 * а капюшон приобретёт необходимые флаги чтобы не скрывать волосы и пропадёт с персонажа визуально, но останется на игроке.
 * ИЦ оправдание такому подходу. Адаптивная защита шарфа прикрывающая голову. А по механу, это сохранит фишки шлема и визуал необходимый для образа.
 *
 */
/obj/item/clothing/neck/ninjascarf
	name = "ninja scarf"
	desc = "A stealthy, dark scarf."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "ninja_scarf_classic"
	item_state = "ninja_scarf_classic"
	strip_delay = 12
	flags = NODROP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

