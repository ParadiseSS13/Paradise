/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	//Not given any special protective value since the magic robes are full-body protection --NEO
	strip_delay = 50
	put_on_delay = 50
	magical = TRUE
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking, red, hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"
	dog_fashion = /datum/dog_fashion/head/red_wizard

/obj/item/clothing/head/wizard/black
	name = "black wizard hat"
	desc = "Strange-looking black hat-wear that most certainly belongs to a real skeleton. Spooky."
	icon_state = "blackwizard"
	dog_fashion = null


/obj/item/clothing/head/wizard/clown
	name = "purple wizard hat"
	desc = "Strange-looking purple hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizhatclown"
	item_state = "wizhatclown" // cheating
	dog_fashion = null

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	magical = FALSE
	resistance_flags = FLAMMABLE
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/wizard/marisa
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	dog_fashion = null

/obj/item/clothing/head/wizard/magus
	name = "Magus Helm"
	desc = "A mysterious helmet that hums with an unearthly power"
	icon_state = "magus"
	item_state = "magus"
	dog_fashion = null

/obj/item/clothing/head/wizard/amp
	name = "psychic amplifier"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"
	dog_fashion = null

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificant, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	allowed = list(/obj/item/teleportation_scroll)
	flags_inv = HIDEJUMPSUIT
	strip_delay = 50
	put_on_delay = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificant, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	item_state = "redwizrobe"

/obj/item/clothing/suit/wizrobe/black
	name = "black wizard robe"
	desc = "An unnerving black gem-lined robe that reeks of death and decay."
	icon_state = "blackwizard"
	item_state = "blackwizrobe"

/obj/item/clothing/suit/wizrobe/clown
	name = "Clown Robe"
	desc = "A set of armoured robes that seem to radiate a dark power. That, and bad fashion decisions."
	icon_state = "wizzclown"
	item_state = "wizzclown"

/obj/item/clothing/suit/wizrobe/marisa
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power"
	icon_state = "magusblue"
	item_state = "magusblue"

/obj/item/clothing/suit/wizrobe/magusred
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power"
	icon_state = "magusred"
	item_state = "magusred"

/obj/item/clothing/suit/wizrobe/psypurple
	name = "purple robes"
	desc = "Heavy, royal purple robes threaded with psychic amplifiers and weird, bulbous lenses. Do not machine wash."
	icon_state = "psyamp"
	item_state = "psyamp"

/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull, blue robe meant to mimick real wizard robes."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	resistance_flags = FLAMMABLE
	magical = FALSE

/obj/item/clothing/head/wizard/marisa/fake
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	resistance_flags = FLAMMABLE
	magical = FALSE

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	resistance_flags = FLAMMABLE
	magical = FALSE

//Shielded Armour

/obj/item/clothing/suit/space/hardsuit/shielded/wizard
	name = "battlemage armour"
	desc = "Not all wizards are afraid of getting up close and personal."
	icon_state = "hardsuit-wiz"
	item_state = "wiz_hardsuit"
	recharge_rate = 0
	current_charges = 15
	recharge_cooldown = INFINITY
	shield_state = "shield-red"
	shield_on = "shield-red"
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 20, bio = 20, rad = 20, fire = 100, acid = 100)
	slowdown = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	name = "battlemage helmet"
	desc = "A suitably impressive helmet."
	icon_state = "hardsuit0-wiz"
	item_state = "wiz_helm"
	item_color = "wiz"
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list(melee = 30, bullet = 20, laser = 20, energy = 20, bomb = 20, bio = 20, rad = 20, fire = 100, acid = 100)
	actions_types = list() //No inbuilt light
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard/attack_self(mob/user)
	return

/obj/item/wizard_armour_charge
	name = "battlemage shield charges"
	desc = "A powerful rune that will increase the number of hits a suit of battlemage armour can take before failing.."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"

/obj/item/wizard_armour_charge/afterattack(obj/item/clothing/suit/space/hardsuit/shielded/wizard/W, mob/user)
	. = ..()
	if(!istype(W))
		to_chat(user, "<span class='warning'>The rune can only be used on battlemage armour!</span>")
		return
	W.current_charges += 8
	to_chat(user, "<span class='notice'>You charge [W]. It can now absorb [W.current_charges] hits.</span>")
	qdel(src)
