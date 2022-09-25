/obj/item/clothing/under/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_color = "red_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_color = "blue_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host"
	icon_state = "scratch"
	item_state = "scratch"
	item_color = "scratch"

/obj/item/clothing/under/sl_suit
	name = "amish suit"
	desc = "It's a very amish looking suit."
	icon_state = "sl_suit"
	item_color = "sl_suit"

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	item_state = "waiter"
	item_color = "waiter"

/obj/item/clothing/under/rank/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"

/obj/item/clothing/under/rank/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "gy_suit"
	item_color = "vice"

/obj/item/clothing/under/solgov
	name = "\improper Trans-Solar Federation marine uniform"
	desc = "A comfortable and durable combat uniform worn by Trans-Solar Federation Marine Forces."
	icon_state = "solgov"
	item_state = "ro_suit"
	item_color = "solgov"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/solgov/elite
	name = "\improper Trans-Solar Federation Specops marine uniform"
	desc = "A comfortable and durable combat uniform worn by Trans-Solar Federation Specops Marine Forces."
	icon_state = "solgovelite"
	item_color = "solgovelite"

/obj/item/clothing/under/solgov/command
	name = "\improper Trans-Solar Federation Lieutenant's uniform"
	desc = "A comfortable and durable combat uniform worn by Trans-Solar Federation Marine Forces. This one has additional insignia on its shoulders and cuffs."
	icon_state = "solgovc"
	item_color = "solgovc"

/obj/item/clothing/under/solgov/command/elite
	name = "\improper Trans-Solar Federation Specops Lieutenant's uniform"
	desc = "A comfortable and durable combat uniform worn by Trans-Solar Federation Specops Marine Forces. This one has additional insignia on its shoulders and cuffs."
	icon_state = "solgovcelite"
	item_color = "solgovcelite"

/obj/item/clothing/under/solgov/rep
	name = "\improper Trans-Solar Federation representative's uniform"
	desc = "A formal uniform worn by the diplomatic representatives of the Trans-Solar Federation."
	icon_state = "solgovr"
	item_color = "solgovr"

/obj/item/clothing/under/rank/centcom_officer
	name = "\improper CentComm officer's jumpsuit"
	desc = "It's a jumpsuit worn by CentComm Officers."
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"

/obj/item/clothing/under/rank/centcom_officer/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/deathsquad
	name = "\improper Deathsquad jumpsuit"
	desc = "It's decorative jumpsuit worn by the Deathsquad. A small tag at the bottom reads \"Not associated with Nanotrasen\". "
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	sensor_mode = SENSOR_OFF // You think the Deathsquad wants to be seen?
	random_sensor = FALSE

/obj/item/clothing/under/rank/centcom_commander
	name = "\improper CentComm commander's jumpsuit"
	desc = "It's a jumpsuit worn by CentComm's highest-tier Commanders."
	icon_state = "centcom"
	item_state = "dg_suit"
	item_color = "centcom"

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper Nanotrasen naval officer's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Lieutenant-Commander\" and bears \"N.A.S. Trurl \" on the left shoulder. Worn exclusively by officers of the Nanotrasen Navy. It's got exotic materials for protection."
	icon_state = "navy_gold"
	item_state = "navy_gold"
	item_color = "navy_gold"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/captain
	name = "\improper Nanotrasen naval captain's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain\" and bears \"N.A.S. Trurl \" on the left shoulder. Worn exclusively by officers of the Nanotrasen Navy. It's got exotic materials for protection."
	icon_state = "navy_gold"
	item_state = "navy_gold"
	item_color = "navy_gold"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/captain/solgov
	name = "\improper Trans-Solar Federation commander's uniform"
	desc = "Gold trim on space-black cloth, this uniform is worn by generals of the Trans-Solar Federation. It has exotic materials for protection."

/obj/item/clothing/under/rank/centcom/blueshield
	name = "formal blueshield's uniform"
	desc = "Gold trim on space-black cloth, this uniform bears \"Close Protection\" on the left shoulder. It's got exotic materials for protection."
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 20)
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/representative
	name = "formal Nanotrasen Representative's uniform"
	desc = "Gold trim on space-black cloth, this uniform bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/representative/Initialize(mapload)
	. = ..()
	desc = "Gold trim on space-black cloth, this uniform bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/centcom/representative/skirt
	desc = "A silky smooth black and gold representative uniform with blue markings."
	name = "representative skirt"
	icon_state = "ntrepf"
	item_state = "ntrepf"
	item_color = "ntrepf"

/obj/item/clothing/under/rank/centcom/magistrate
	name = "formal magistrate's uniform"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Magistrate\" and bears \"N.S.S. Cyberiad\" on the left shoulder."
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	displays_id = FALSE

/obj/item/clothing/under/rank/centcom/magistrate/Initialize(mapload)
	. = ..()
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Magistrate\" and bears [station_name()] on the left shoulder."

/obj/item/clothing/under/rank/centcom/diplomatic
	name = "\improper Nanotrasen diplomatic uniform"
	desc = "A very gaudy and official looking uniform of the Nanotrasen Diplomatic Corps."
	icon_state = "presidente"
	item_state = "g_suit"
	item_color = "presidente"
	displays_id = FALSE

/obj/item/clothing/under/rank/blueshield
	name = "blueshield's uniform"
	desc = "A short-sleeved black uniform, paired with grey digital-camo cargo pants, all made out of a sturdy material. Blueshield standard issue."
	icon_state = "ert_uniform"
	item_state = "bl_suit"
	item_color = "ert_uniform"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/under/rank/blueshield/skirt
	name = "blueshield's skirt"
	desc = "A short, black and grey with blue markings skirted uniform. For the feminine Blueshield."
	icon_state = "blueshieldf"
	item_state = "blueshieldf"
	item_color = "blueshieldf"

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	item_color = "green_suit"

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	item_color = "overalls"

/obj/item/clothing/under/assistantformal
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

/obj/item/clothing/under/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	item_state = "burial"
	item_color = "burial"

/obj/item/clothing/under/redhawaiianshirt
	name = "red hawaiian shirt"
	desc = "a floral shirt worn to most vacation destinations."
	icon_state = "hawaiianred"
	item_state = "hawaiianred"
	item_color = "hawaiianred"

/obj/item/clothing/under/pinkhawaiianshirt
	name = "pink hawaiian shirt"
	desc = "a pink floral shirt the material feels cool and comfy."
	icon_state = "hawaiianpink"
	item_state = "hawaiianpink"
	item_color = "hawaiianpink"

/obj/item/clothing/under/orangehawaiianshirt
	name = "orange hawaiian shirt"
	desc = "a orange floral shirt for a relaxing day in space."
	icon_state = "hawaiianorange"
	item_state = "hawaiianorange"
	item_color = "hawaiianorange"

/obj/item/clothing/under/bluehawaiianshirt
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
	armor = list(MELEE = 5, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	armor = list(MELEE = INFINITY, BULLET = INFINITY, LASER = INFINITY, ENERGY = INFINITY, BOMB = INFINITY, BIO = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = -10
	siemens_coefficient = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
