//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = WEIGHT_CLASS_TINY
	desc = "This is rubbish."
	resistance_flags = FLAMMABLE

/obj/item/trash/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["metal"] += 2
	C.stored_comms["wood"] += 1
	C.stored_comms["glass"] += 1
	qdel(src)
	return TRUE

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "Candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "Cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "Chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "Popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"

/obj/item/trash/syndi_cakes
	name = "Syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "Waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "Plate"
	icon_state = "plate"
	resistance_flags = NONE

/obj/item/trash/snack_bowl
	name = "Snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/fried_vox
	name = "Kentucky Fried Vox"
	icon_state = "fried_vox_empty"
	item_state = "fried_vox_empty"
	slot_flags = SLOT_HEAD
	dog_fashion = /datum/dog_fashion/head/fried_vox_empty
	sprite_sheets = list(
		"Skrell" = 'icons/mob/species/skrell/head.dmi',
		"Drask" = 'icons/mob/species/drask/head.dmi',
		"Kidan" = 'icons/mob/species/kidan/head.dmi',
		"Monkey" = 'icons/mob/species/monkey/head.dmi',
		"Farwa" = 'icons/mob/species/monkey/head.dmi',
		"Wolpin" = 'icons/mob/species/monkey/head.dmi',
		"Neara" = 'icons/mob/species/monkey/head.dmi',
		"Stok" = 'icons/mob/species/monkey/head.dmi'
	)

/obj/item/trash/pistachios
	name = "Pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "Semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "Tray"
	icon_state = "tray"
	resistance_flags = NONE

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	var/is_glass = 0
	var/is_plastic = 0
	resistance_flags = NONE

/obj/item/trash/gum
	name = "chewed gum"
	desc = "NOT free candy."
	icon_state = "gum"

/obj/item/trash/tastybread
	name = "bread tube"
	icon_state = "tastybread"

/obj/item/trash/spentcasing
	icon = 'icons/obj/weapons/ammo.dmi'
	name = "bullet casing"
	desc = "A spent bullet casing. Smells like cordite."
	icon_state = "gshell"

/obj/item/trash/tapetrash
	name = "old duct tape"
	icon_state = "tape"
	desc = "Not sticky anymore."
	throw_range = 1

/obj/item/trash/doshik
	name = "packaging from doshik"
	icon_state = "doshik"
	desc = "Still has a delicious smell."

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return

/obj/item/trash/broken_ashtray
	name = "ashtray shards"
	icon = 'icons/obj/ashtray.dmi'
	icon_state = "ashtray_bork_bl"

/obj/item/trash/broken_ashtray/Initialize(mapload)
	. = ..()
	icon_state = "ashtray_bork_" + pick(list("bl","br","gl"))

/obj/item/spentcasing
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "gshell"
	name = "Old bullet casing"
	desc = "A spent bullet casing. Smells like rusty metal."

	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 100)

/obj/item/spentcasing/Initialize()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(GLOB.alldirs)

/obj/effect/spawner/lootdrop/spentcasing
	name = "Old 12 gauge spent casings"
	icon_state ="spentcasing_12"
	lootcount = 2

	loot = list(/obj/item/spentcasing)

/obj/item/spentcasing/pistol
	icon_state = "s-casing"

/obj/effect/spawner/lootdrop/spentcasing/pistol
	name = "Old pistol spent casings"
	icon_state ="spentcasing_9"
	lootcount = 3

	loot = list(/obj/item/spentcasing/pistol)

/obj/item/spentcasing/rifle
	icon_state = "762-casing"

/obj/effect/spawner/lootdrop/spentcasing/rifle
	name = "Old rifle spent casings"
	icon_state ="spentcasing_762"
	lootcount = 5

	loot = list(/obj/item/spentcasing/rifle)
