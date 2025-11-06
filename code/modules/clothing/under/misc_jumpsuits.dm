/obj/item/clothing/under/misc
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dyeable = TRUE

/obj/item/clothing/under/misc/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"

/obj/item/clothing/under/misc/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"

/obj/item/clothing/under/misc/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host."
	icon_state = "scratch"

/obj/item/clothing/under/misc/sl_suit
	name = "amish suit"
	desc = "It's a very amish looking suit."
	icon_state = "sl_suit"

/obj/item/clothing/under/misc/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/misc/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/misc/gimmick_captain_suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	inhand_icon_state = "dg_suit"

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/cursedclown
	name = "cursed clown suit"
	desc = "It wasn't already?"
	icon = 'icons/goonstation/objects/clothing/uniform.dmi'
	icon_state = "cursedclown"
	worn_icon = 'icons/goonstation/mob/clothing/uniform.dmi'
	inhand_icon_state = "cclown_uniform"
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	flags = NODROP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	has_sensor = FALSE // HUNKE
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/under/misc.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/misc.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/misc.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/misc.dmi'
		)

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"

/obj/item/clothing/under/misc/redhawaiianshirt
	name = "red hawaiian shirt"
	desc = "a floral shirt worn to most vacation destinations."
	icon_state = "hawaiianred"

/obj/item/clothing/under/misc/pinkhawaiianshirt
	name = "pink hawaiian shirt"
	desc = "a pink floral shirt the material feels cool and comfy."
	icon_state = "hawaiianpink"

/obj/item/clothing/under/misc/orangehawaiianshirt
	name = "orange hawaiian shirt"
	desc = "a orange floral shirt for a relaxing day in space."
	icon_state = "hawaiianorange"

/obj/item/clothing/under/misc/bluehawaiianshirt
	name = "blue hawaiian shirt"
	desc = "a blue floral shirt it has a oddly colored pink flower on it."
	icon_state = "hawaiianblue"

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	armor = list(MELEE = 5, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/misc/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"

/obj/item/clothing/under/misc/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"

/obj/item/clothing/under/misc/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"

/obj/item/clothing/under/misc/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"

/obj/item/clothing/under/misc/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"

/obj/item/clothing/under/misc/acj
	name = "administrative cybernetic jumpsuit"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	armor = list(MELEE = INFINITY, BULLET = INFINITY, LASER = INFINITY, ENERGY = INFINITY, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = -10
	siemens_coefficient = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	flags_2 = RAD_PROTECT_CONTENTS_2
