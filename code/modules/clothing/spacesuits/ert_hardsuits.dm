
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team helmet"
	desc = "A helmet worn by members of the Nanotrasen Emergency Response Team. Armoured and space ready."
	icon_state = "hardsuit0-ert_commander"
	item_state = "helm-command"
	item_color = "ert_commander"
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

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize()
	if(loc)
		var/mob/living/carbon/human/wearer = loc.loc	//loc is the hardsuit, so its loc is the wearer
		if(ishuman(wearer))
			register_camera(wearer)
	..()

/obj/item/clothing/head/helmet/space/hardsuit/ert/attack_self(mob/user)
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
	desc = "A suit worn by members of the Nanotrasen Emergency Response Team. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs,/obj/item/tank/internals)
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
	desc = "A helmet worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_commander"
	item_state = "helm-command"
	item_color = "ert_commander"

/obj/item/clothing/head/helmet/space/hardsuit/ert/commander/gamma
	name = "elite emergency response team commander helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "hardsuit0-gammacommander"
	item_color = "gammacommander"

/obj/item/clothing/suit/space/hardsuit/ert/commander
	name = "emergency response team commander suit"
	desc = "A suit worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/commander

/obj/item/clothing/suit/space/hardsuit/ert/commander/gamma
	name = "elite emergency response team commander suit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "ert_gcommander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/commander/gamma
	slowdown = 0

//Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/security
	name = "emergency response team security helmet"
	desc = "A helmet worn by security members of a Nanotrasen Emergency Response Team. Has red highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_security"
	item_state = "syndicate-helm-black-red"
	item_color = "ert_security"

/obj/item/clothing/head/helmet/space/hardsuit/ert/security/gamma
	name = "elite emergency response team security helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "hardsuit0-gammasecurity"
	item_color = "gammasecurity"

/obj/item/clothing/suit/space/hardsuit/ert/security
	name = "emergency response team security suit"
	desc = "A suit worn by security members of a Nanotrasen Emergency Response Team. Has red highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_security"
	item_state = "syndicate-black-red"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/security

/obj/item/clothing/suit/space/hardsuit/ert/security/gamma
	name = "elite emergency response team security suit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "ert_gsecurity"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/security/gamma
	slowdown = 0

//Engineer
/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "A helmet worn by engineers of a Nanotrasen Emergency Response Team. Has yellow highlights. Armoured and space ready."
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 150, FIRE = 200, ACID = 200)
	icon_state = "hardsuit0-ert_engineer"
	item_state = "helm-orange"
	item_color = "ert_engineer"

/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer/gamma
	name = "elite emergency response team engineer helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = 200, ACID = 200)
	icon_state = "hardsuit0-gammaengineer"
	item_color = "gammaengineer"

/obj/item/clothing/suit/space/hardsuit/ert/engineer
	name = "emergency response team engineer suit"
	desc = "A suit worn by the engineers of a Nanotrasen Emergency Response Team. Has yellow highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_engineer"
	item_state = "suit-orange"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 150, FIRE = 200, ACID = 200)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engineer

/obj/item/clothing/suit/space/hardsuit/ert/engineer/gamma
	name = "elite emergency response team engineer suit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "ert_gengineer"
	armor = list(MELEE = 40, BULLET = 15, LASER = 20, ENERGY = 5, BOMB = 15, RAD = INFINITY, FIRE = 200, ACID = 200)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engineer/gamma
	slowdown = 0

//Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/medical
	name = "emergency response team medical helmet"
	desc = "A helmet worn by medical members of a Nanotrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_medical"
	item_color = "ert_medical"

/obj/item/clothing/head/helmet/space/hardsuit/ert/medical/gamma
	name = "elite emergency response team medical helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "hardsuit0-gammamedical"
	item_color = "gammamedical"

/obj/item/clothing/suit/space/hardsuit/ert/medical
	name = "emergency response team medical suit"
	desc = "A suit worn by medical members of a Nanotrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/medical

/obj/item/clothing/suit/space/hardsuit/ert/medical/gamma
	name = "elite emergency response team medical suit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "ert_gmedical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/medical/gamma
	slowdown = 0

//Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "A helmet worn by janitorial members of a Nanotrasen Emergency Response Team. Has purple highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_janitor"
	item_color = "ert_janitor"

/obj/item/clothing/head/helmet/space/hardsuit/ert/janitor/gamma
	name = "elite emergency response team janitor helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "hardsuit0-gammajanitor"
	item_color = "gammajanitor"

/obj/item/clothing/suit/space/hardsuit/ert/janitor
	name = "emergency response team janitor suit"
	desc = "A suit worn by the janitorial of a Nanotrasen Emergency Response Team. Has purple highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/janitor

/obj/item/clothing/suit/space/hardsuit/ert/janitor/gamma
	name = "elite emergency response team janitor suit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	icon_state = "ert_gjanitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/janitor/gamma
	slowdown = 0

//Paranormal
/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response unit helmet"
	desc = "A helmet worn by those who deal with paranormal threats for a living."
	icon_state = "hardsuit0-ert_paranormal"
	item_color = "ert_paranormal"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team suit"
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats."
	icon_state = "hardsuit-paranormal"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	resistance_flags = FIRE_PROOF
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi'
		)
	hide_tail_by_species = list("Unathi, Tajaran, Vox, Vulpkanin")

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize(mapload)
	. = ..()
	new /obj/item/nullrod(src)

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inquisitor"
	item_color = "inquisitor"
	armor = list(MELEE = 95, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, RAD = INFINITY, FIRE = 200, ACID = 200)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inquisitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	armor = list(MELEE = 95, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, RAD = INFINITY, FIRE = 200, ACID = 200)
	slowdown = 0


// Solgov

/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov
	name = "\improper Trans-Solar Federation Specops Marine helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	desc = "A helmet worn by marines of the Trans-Solar Federation. Armored, space ready, and fireproof."
	icon_state = "hardsuit0-solgovmarine"
	item_state = "hardsuit0-solgovmarine"
	item_color = "solgovmarine"
	armor = list(MELEE = 25, BULLET = 75, LASER = 10, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/suit/space/hardsuit/ert/solgov
	name = "\improper Trans-Solar Federation Specops Marine hardsuit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	desc = "A suit worn by marines of the Trans-Solar Federation. Armored, space ready, and fireproof."
	icon_state = "ert_solgov_marine"
	item_state = "ert_solgov_marine"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/solgov
	slowdown = 0
	armor = list(MELEE = 25, BULLET = 75, LASER = 10, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = INFINITY, ACID = INFINITY)

/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov/command
	name = "\improper Trans-Solar Federation Specops Lieutenant helmet"
	desc = "A helmet worn by Lieutenants of the Trans-Solar Federation Marines. Has gold highlights to denote the wearer's rank. Armored, space ready, and fireproof."
	icon_state = "hardsuit0-solgovcommand"
	item_state = "hardsuit0-solgovcommand"
	item_color = "solgovcommand"

/obj/item/clothing/suit/space/hardsuit/ert/solgov/command
	name = "\improper Trans-Solar Federation Specops Lieutenant hardsuit"
	desc = "A suit worn by Lieutenants of the Trans-Solar Federation Marines. Has gold highlights to denote the wearer's rank. Armored, space ready, and fireproof."
	icon_state = "ert_solgov_command"
	item_state = "ert_solgov_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/solgov/command
