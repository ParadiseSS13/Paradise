//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = WEIGHT_CLASS_TINY
	desc = "This is rubbish."
	resistance_flags = FLAMMABLE

/obj/item/trash/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["metal"] += 2
		C.stored_comms["wood"] += 1
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/trash/attack__legacy__attackchain(mob/M as mob, mob/living/user as mob)
	return

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

/obj/item/trash/twimsts
	name = "Twimsts"
	icon_state = "twimsts"

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"
	gender = PLURAL

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
	name = "plate"
	icon_state = "plate"
	resistance_flags = NONE

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/fried_vox
	name = "Kentucky Fried Vox"
	icon_state = "fried_vox_empty"
	slot_flags = ITEM_SLOT_HEAD
	dog_fashion = /datum/dog_fashion/head/fried_vox_empty
	sprite_sheets = list(
	"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
	"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
	"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
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

/obj/item/trash/tapetrash
	name = "old duct tape"
	icon_state = "tape"
	desc = "Not sticky anymore."
	throw_range = 1

/obj/item/trash/popsicle_stick
	name = "used popsicle stick"
	icon_state = "popsicle_stick_s"
	desc = "Still tastes sweet."

/obj/item/trash/caviar
	name = "caviar can"
	icon_state = "caviar-empty"
	desc = "There's none left."

// Ammo casings
/obj/item/trash/spentcasing
	icon = 'icons/obj/bullet.dmi'
	name = "arbitrary spent casing item"
	desc = "If you can see this and didn't spawn it, make an issue report on GitHub."
	icon_state = "pistol_brass"
	scatter_distance = 10

/obj/item/trash/spentcasing/Initialize(mapload)
	. = ..()
	scatter_atom()
	transform = turn(transform, rand(0, 360))

/obj/item/trash/spentcasing/shotgun
	name = "spent buckshot shell"
	desc = "A spent shotgun shell. It smells like cordite."
	icon_state = "buckshot"

/obj/item/trash/spentcasing/shotgun/rubbershot
	name = "spent rubbershot shell"
	desc = "A spent shotgun shell. It smells like cordite and singed rubber."
	icon_state = "rubbershot"

/obj/item/trash/spentcasing/shotgun/beanbag
	name = "spent beanbag shell"
	icon_state = "beanbag"

/obj/item/trash/spentcasing/shotgun/slug
	name = "spent slug shell"
	icon_state = "slug"

/obj/item/trash/spentcasing/shotgun/dragonsbreath
	name = "spent dragonsbreath shell"
	desc = "A spent shotgun shell. It smells like cordite, burnt plastic, and a hint of petroleum."
	icon_state = "dragonsbreath"

/obj/item/trash/spentcasing/shotgun/stun
	name = "spent stun shell"
	icon_state = "taser"

/obj/item/trash/spentcasing/bullet
	name = "spent bullet casing"
	desc = "A spent bullet casing. It smells of brass and cordite."
	icon_state = "rifle_brass"

/obj/item/trash/spentcasing/bullet/medium
	name = "spent large bullet casing"
	desc = "A spent high-caliber bullet casing. It smells of brass and cordite."
	icon_state = "heavy_brass"

/obj/item/trash/spentcasing/bullet/large
	name = "spent .50 BMG bullet casing"
	desc = "A spent .50 BMG bullet casing. It smells of brass and cordite."
	icon_state = "heavy_steel"

/obj/item/trash/spentcasing/bullet/lasershot
	desc = "A spent IK-series single-use lasershot cell. It smells of burnt plastic with a metallic-chemical undertone."
	icon_state = "lasercasing"
