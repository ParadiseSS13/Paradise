/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, RAD = 10, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	//Not given any special protective value since the magic robes are full-body protection --NEO
	strip_delay = 50
	put_on_delay = 50
	magical = TRUE
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/wizard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking, red, hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"
	dog_fashion = /datum/dog_fashion/head/red_wizard

/obj/item/clothing/head/wizard/black
	name = "black wizard hat"
	desc = "Strange-looking black hat-wear that most certainly belongs to a real skeleton. Spooky."
	icon_state = "blackwizard"
	dog_fashion = /datum/dog_fashion/head/black_wizard

/obj/item/clothing/head/wizard/clown
	name = "purple wizard hat"
	desc = "Strange-looking purple hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizhatclown"
	dog_fashion = null

/obj/item/clothing/head/wizard/mime
	name = "magical beret"
	desc = "A magical red beret."
	icon_state = "wizhatmime"
	dog_fashion = null
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/wizard/fake
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = null
	magical = FALSE
	resistance_flags = FLAMMABLE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/wizard/fake/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/wizard/marisa
	name = "witch hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	dog_fashion = /datum/dog_fashion/head/wizard/marisa

/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	desc = "A mysterious helmet that hums with an unearthly power."
	icon_state = "magus"
	dog_fashion = /datum/dog_fashion/head/wizard/magus
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/wizard/magus/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/wizard/amp
	name = "psychic amplifier"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	dog_fashion = null

/obj/item/clothing/head/wizard/amp/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificent, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	inhand_icon_state = "b_suit"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, RAD = 10, FIRE = INFINITY, ACID = INFINITY)
	allowed = list(/obj/item/teleportation_scroll, /obj/item/gun/magic/staff, /obj/item/melee/ghost_sword, /obj/item/lava_staff, /obj/item/hierophant_club)
	max_suit_w = WEIGHT_CLASS_HUGE
	flags_inv = HIDEJUMPSUIT
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificent, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	inhand_icon_state = "r_suit"

/obj/item/clothing/suit/wizrobe/black
	name = "black wizard robe"
	desc = "An unnerving black gem-lined robe that reeks of death and decay."
	icon_state = "blackwizard"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/suit/wizrobe/clown
	name = "clown robe"
	desc = "A set of armoured robes that seem to radiate a dark power. That, and bad fashion decisions."
	icon_state = "wizzclown"
	inhand_icon_state = "clown"

/obj/item/clothing/suit/wizrobe/mime
	name = "mime robe"
	desc = "Red, black, and white robes. There is not much else to say about them."
	icon_state = "wizzmime"
	inhand_icon_state = "bl_suit"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)

/obj/item/clothing/suit/wizrobe/marisa
	name = "witch robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	inhand_icon_state = "bl_suit"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "magus robe"
	desc = "A set of armoured robes that seem to radiate a dark power."
	icon_state = "magusblue"

/obj/item/clothing/suit/wizrobe/magusred
	name = "magus robe"
	desc = "A set of armoured robes that seem to radiate a dark power."
	icon_state = "magusred"
	inhand_icon_state = "r_suit"

/obj/item/clothing/suit/wizrobe/psypurple
	name = "purple robes"
	desc = "Heavy, royal purple robes threaded with psychic amplifiers and weird, bulbous lenses. Do not machine wash."
	icon_state = "psyamp"
	inhand_icon_state = null

/obj/item/clothing/suit/wizrobe/fake
	desc = "A rather dull, blue robe meant to mimick real wizard robes."
	icon_state = "wizard-fake"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = null
	resistance_flags = FLAMMABLE
	magical = FALSE

/obj/item/clothing/head/wizard/marisa/fake
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = null
	resistance_flags = FLAMMABLE
	magical = FALSE

/obj/item/clothing/suit/wizrobe/marisa/fake
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = null
	resistance_flags = FLAMMABLE
	magical = FALSE

//Shielded Armour

/obj/item/clothing/suit/space/hardsuit/wizard
	name = "battlemage armor"
	desc = "Not all wizards are afraid of getting up close and personal."
	icon_state = "hardsuit-wiz"
	inhand_icon_state = "wiz_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	slowdown = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/suit/space/hardsuit/wizard/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 15, recharge_start_delay = 0 SECONDS)

/obj/item/clothing/suit/space/hardsuit/wizard/equipped(mob/user, slot)
	. = ..()
	ADD_TRAIT(user, TRAIT_ANTIMAGIC, "[UID()]")
	ADD_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK, "[UID()]")

/obj/item/clothing/suit/space/hardsuit/wizard/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_ANTIMAGIC, "[UID()]")
	REMOVE_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK, "[UID()]")

/obj/item/clothing/suit/space/hardsuit/wizard/arch
	desc = "For the arch wizard in need of additional protection."
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard/arch

/obj/item/clothing/suit/space/hardsuit/wizard/arch/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 15, recharge_start_delay = 1 SECONDS, charge_increment_delay = 1 SECONDS)

/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "battlemage helmet"
	desc = "A suitably impressive helmet."
	icon_state = "hardsuit0-wiz"
	base_icon_state = "wiz"
	armor = list(MELEE = 35, BULLET = 50, LASER = 20, ENERGY = 10, BOMB = 25, RAD = 50, FIRE = INFINITY, ACID = INFINITY)
	actions_types = list() //No inbuilt light
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/wizard/attack_self__legacy__attackchain(mob/user)
	return

/obj/item/clothing/head/helmet/space/hardsuit/wizard/arch
	desc = "A truly protective helmet."
