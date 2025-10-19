
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team helmet"
	desc = "An environmentally sealed combat helmet with a wide plexiglass visor for maximum visibility."
	icon_state = "hardsuit0-ert_commander"
	base_icon_state = "ert_commander"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	resistance_flags = FIRE_PROOF
	var/obj/machinery/camera/portable/camera
	var/has_camera = TRUE
	strip_delay = 130
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
	)

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize(mapload)
	if(loc)
		var/mob/living/carbon/human/wearer = loc.loc	//loc is the hardsuit, so its loc is the wearer
		if(ishuman(wearer))
			register_camera(wearer)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/ert/attack_self__legacy__attackchain(mob/user)
	if(camera || !has_camera)
		..(user)
	else
		register_camera(user)

/obj/item/clothing/head/helmet/space/hardsuit/ert/proc/register_camera(mob/wearer)
	if(camera || !has_camera)
		return
	camera = new /obj/machinery/camera/portable(src, FALSE)
	camera.network = list("ERT")
	camera.c_tag = wearer.name
	to_chat(wearer, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/hardsuit/ert/examine(mob/user)
	. = ..()
	if(in_range(user, src) && has_camera)
		. += "This helmet has a built-in camera. It's [camera ? "" : "in"]active."

/obj/item/clothing/head/helmet/space/hardsuit/ert/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/clothing/suit/space/hardsuit/ert
	name = "emergency response team suit"
	desc = "A powered combat hardsuit produced by Citadel Armories. Decently armored, environmentally sealed, and fire-resistant."
	icon_state = "ert_commander"
	inhand_icon_state = "suit-command"
	slowdown = 0
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/rcd, /obj/item/crowbar, \
					/obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/multitool, \
					/obj/item/radio, /obj/item/analyzer, /obj/item/gun, /obj/item/melee/baton, /obj/item/reagent_containers/spray/pepper, \
					/obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		)

//Commander
/obj/item/clothing/head/helmet/space/hardsuit/ert/commander
	name = "emergency response team commander helmet"
	desc = "An environmentally sealed combat helmet with a wide plexiglass visor for maximum visibility. This one has blue Command stripes."

/obj/item/clothing/suit/space/hardsuit/ert/commander
	name = "emergency response team commander suit"
	desc = "A powered combat hardsuit produced by Citadel Armories. Decently armored, environmentally sealed, and fire-resistant. This one is covered in blue Command livery."
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/commander

//Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/security
	name = "emergency response team security helmet"
	desc = "An environmentally sealed combat helmet with a wide plexiglass visor for maximum visibility. This one has red Security stripes."
	icon_state = "hardsuit0-ert_security"
	base_icon_state = "ert_security"

/obj/item/clothing/suit/space/hardsuit/ert/security
	name = "emergency response team security suit"
	desc = "A powered combat hardsuit produced by Citadel Armories. Decently armored, environmentally sealed, and fire-resistant. This one is covered in red Security livery."
	icon_state = "ert_security"
	inhand_icon_state = "syndicate-black-red"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/security

/obj/item/clothing/suit/space/hardsuit/ert/security/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HYPOSPRAY_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

//Engineer
/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "An environmentally sealed combat helmet with a wide plexiglass visor for maximum visibility. This one has orange Engineering stripes, and additional lead plating for improved radiation protection."
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 150, FIRE = 200, ACID = 200)
	icon_state = "hardsuit0-ert_engineer"
	base_icon_state = "ert_engineer"

/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer/gamma
	name = "elite emergency response team engineer helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = 200, ACID = 200)
	flags_2 = RAD_PROTECT_CONTENTS_2
	icon_state = "hardsuit0-gammaengineer"
	base_icon_state = "gammaengineer"

/obj/item/clothing/suit/space/hardsuit/ert/engineer
	name = "emergency response team engineer suit"
	desc = "A powered combat hardsuit produced by Citadel Armories. Decently armored, environmentally sealed, and fire-resistant. This one is covered in orange Engineering livery, and has additional lead inserts for added radiation protection."
	icon_state = "ert_engineer"
	inhand_icon_state = "suit-orange"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 150, FIRE = 200, ACID = 200)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engineer

/obj/item/clothing/suit/space/hardsuit/ert/engineer/gamma
	name = "elite emergency response team engineer suit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "ert_gengineer"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = 200, ACID = 200)
	flags_2 = RAD_PROTECT_CONTENTS_2
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engineer/gamma

//Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/medical
	name = "emergency response team medical helmet"
	desc = "An environmentally sealed combat helmet with a wide plexiglass visor for maximum visibility. This one's got white Medical stripes."
	icon_state = "hardsuit0-ert_medical"
	base_icon_state = "ert_medical"

/obj/item/clothing/suit/space/hardsuit/ert/medical
	name = "emergency response team medical suit"
	desc = "A powered combat hardsuit produced by Citadel Armories. Decently armored, environmentally sealed, and fire-resistant. This one is covered in white Medical livery."
	icon_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/medical

/obj/item/clothing/suit/space/hardsuit/ert/medical/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HYPOSPRAY_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

//Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "An environmentally sealed combat helmet with a wide plexiglass visor for maximum visibility. This one has purple Janitorial stripes."
	icon_state = "hardsuit0-ert_janitor"
	base_icon_state = "ert_janitor"

/obj/item/clothing/suit/space/hardsuit/ert/janitor
	name = "emergency response team janitor suit"
	desc = "A powered combat hardsuit produced by Citadel Armories. Decently armored, environmentally sealed, and fire-resistant. This one is covered in purple Janitorial livery."
	icon_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/janitor

//Paranormal
/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response unit helmet"
	desc = "An environmentally-sealed combat helmet covered in runes and warding sigils. The internal HUD is fairly outdated, and has Latin as a selectable language."
	icon_state = "hardsuit0-ert_paranormal"
	base_icon_state = "ert_paranormal"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team suit"
	desc = "A specially designed combat hardsuit produced by Citadel Armories for engaging paranormal threats, this suit is inlaid with interlocking geometric warding sigils and uses a unique holy water liquid-cooling system."
	icon_state = "hardsuit-paranormal"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)
	hide_tail_by_species = list("Unathi", "Tajaran", "Vox", "Vulpkanin")

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize(mapload)
	. = ..()
	new /obj/item/nullrod(src)

// Solgov

/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov
	name = "\improper MARSOC helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	desc = "A helmet worn by marines of the Trans-Solar Federation's Marine Special Operations Command. Armored, space ready, and fireproof."
	icon_state = "hardsuit0-solgovmarine"
	base_icon_state = "solgovmarine"
	armor = list(MELEE = 25, BULLET = 75, LASER = 10, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/suit/space/hardsuit/ert/solgov
	name = "\improper MARSOC hardsuit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	desc = "A suit worn by marines of the Trans-Solar Federation's Marine Special Operations Command. Armored, space ready, and fireproof."
	icon_state = "ert_solgov_marine"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/solgov
	armor = list(MELEE = 25, BULLET = 75, LASER = 10, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov/command
	name = "\improper MARSOC officer's helmet"
	desc = "A helmet worn by junior officers of the Trans-Solar Federation's Marine Special Operations Command. Has gold highlights to denote the wearer's rank. Armored, space ready, and fireproof."
	icon_state = "hardsuit0-solgovcommand"
	base_icon_state = "solgovcommand"

/obj/item/clothing/suit/space/hardsuit/ert/solgov/command
	name = "\improper MARSOC officer's hardsuit"
	desc = "A suit worn by junior officers of the Trans-Solar Federation's Marine Special Operations Command. Has gold highlights to denote the wearer's rank. Armored, space ready, and fireproof."
	icon_state = "ert_solgov_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/solgov/command
