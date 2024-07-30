/obj/item/clothing/under/misc
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dyeable = TRUE
	icon = 'icons/obj/clothing/under/misc.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/misc.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/misc.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/misc.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/misc.dmi'
		)

/obj/item/clothing/under/misc/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_color = "red_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/misc/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_color = "blue_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/misc/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host"
	icon_state = "scratch"
	item_state = "scratch"
	item_color = "scratch"

/obj/item/clothing/under/misc/sl_suit
	name = "amish suit"
	desc = "It's a very amish looking suit."
	icon_state = "sl_suit"
	item_color = "sl_suit"

/obj/item/clothing/under/misc/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	item_color = "waiter"

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"

/obj/item/clothing/under/misc/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "gy_suit"
	item_color = "vice"

/obj/item/clothing/under/misc/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	item_color = "green_suit"

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	item_color = "overalls"

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	item_color = "assistant_formal"

/obj/item/clothing/under/cursedclown
	name = "cursed clown suit"
	desc = "It wasn't already?"
	icon = 'icons/goonstation/objects/clothing/uniform.dmi'
	icon_state = "cursedclown"
	item_state = "cclown_uniform"
	item_color = "cursedclown"
	icon_override = 'icons/goonstation/mob/clothing/uniform.dmi'
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	flags = NODROP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	has_sensor = FALSE // HUNKE
	sprite_sheets = null

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	item_state = "burial"
	item_color = "burial"

/obj/item/clothing/under/misc/redhawaiianshirt
	name = "red hawaiian shirt"
	desc = "a floral shirt worn to most vacation destinations."
	icon_state = "hawaiianred"
	item_state = "hawaiianred"
	item_color = "hawaiianred"

/obj/item/clothing/under/misc/pinkhawaiianshirt
	name = "pink hawaiian shirt"
	desc = "a pink floral shirt the material feels cool and comfy."
	icon_state = "hawaiianpink"
	item_state = "hawaiianpink"
	item_color = "hawaiianpink"

/obj/item/clothing/under/misc/orangehawaiianshirt
	name = "orange hawaiian shirt"
	desc = "a orange floral shirt for a relaxing day in space."
	icon_state = "hawaiianorange"
	item_state = "hawaiianorange"
	item_color = "hawaiianorange"

/obj/item/clothing/under/misc/bluehawaiianshirt
	name = "blue hawaiian shirt"
	desc = "a blue floral shirt it has a oddly colored pink flower on it."
	icon_state = "hawaiianblue"
	item_state = "hawaiianblue"
	item_color = "hawaiianblue"

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	item_state = "durathread"
	item_color = "durathread"
	armor = list(MELEE = 5, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/misc/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	item_color = "swim_black"

/obj/item/clothing/under/misc/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	item_color = "swim_blue"

/obj/item/clothing/under/misc/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	item_color = "swim_purp"

/obj/item/clothing/under/misc/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	item_color = "swim_green"

/obj/item/clothing/under/misc/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	item_color = "swim_red"

/obj/item/clothing/under/misc/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
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
