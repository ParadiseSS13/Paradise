
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team helmet"
	desc = "A helmet worn by members of the Nanotrasen Emergency Response Team. Armoured and space ready."
	icon_state = "hardsuit0-ert_commander"
	item_state = "helm-command"
	item_color = "ert_commander"
	armor = list(melee = 45, bullet = 40, laser = 40, energy = 40, bomb = 25, bio = 100, rad = 75, fire = 100, acid = 80)
	resistance_flags = FIRE_PROOF
	var/obj/machinery/camera/camera
	var/has_camera = TRUE
	strip_delay = 130

	sprite_sheets = list(
		"Grey" = 'icons/mob/species/grey/helmet.dmi',
		"Vox" = 'icons/mob/species/vox/helmet.dmi'
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
	camera = new /obj/machinery/camera(src)
	camera.network = list("ERT")
	GLOB.cameranet.removeCamera(camera)
	camera.c_tag = wearer.name
	to_chat(wearer, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/hardsuit/ert/examine(mob/user)
	. = ..()
	if(in_range(user, src) && has_camera)
		. += "<span class='notice'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>"

/obj/item/clothing/head/helmet/space/hardsuit/ert/gamma
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)

/obj/item/clothing/suit/space/hardsuit/ert
	name = "emergency response team suit"
	desc = "A suit worn by members of the Nanotrasen Emergency Response Team. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun,/obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(melee = 45, bullet = 40, laser = 40, energy = 40, bomb = 25, bio = 100, rad = 75, fire = 100, acid = 80)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/rcd, /obj/item/crowbar, \
	/obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/multitool, \
	/obj/item/radio, /obj/item/analyzer, /obj/item/gun, /obj/item/melee/baton, /obj/item/reagent_containers/spray/pepper, \
	/obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	jetpack = /obj/item/tank/jetpack/suit
	strip_delay = 130
	slowdown = 0
	resistance_flags = FIRE_PROOF
	sprite_sheets = list(
		"Drask" = 'icons/mob/species/drask/suit.dmi',
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/ert/gamma
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)

//Commander
/obj/item/clothing/head/helmet/space/hardsuit/ert/commander
	name = "emergency response team commander helmet"
	desc = "A helmet worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_commander"
	item_state = "helm-command"
	item_color = "ert_commander"

/obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/commander
	name = "elite emergency response team commander helmet"
	icon_state = "hardsuit0-gammacommander"
	item_color = "gammacommander"

/obj/item/clothing/suit/space/hardsuit/ert/commander
	name = "emergency response team commander suit"
	desc = "A suit worn by the commander of a Nanotrasen Emergency Response Team. Has blue highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/commander

/obj/item/clothing/suit/space/hardsuit/ert/gamma/commander
	name = "elite emergency response team commander suit"
	icon_state = "ert_gcommander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/commander

//Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/security
	name = "emergency response team security helmet"
	desc = "A helmet worn by security members of a Nanotrasen Emergency Response Team. Has red highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_security"
	item_state = "syndicate-helm-black-red"
	item_color = "ert_security"

/obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/security
	name = "elite emergency response team security helmet"
	icon_state = "hardsuit0-gammasecurity"
	item_color = "gammasecurity"

/obj/item/clothing/suit/space/hardsuit/ert/security
	name = "emergency response team security suit"
	desc = "A suit worn by security members of a Nanotrasen Emergency Response Team. Has red highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_security"
	item_state = "syndicate-black-red"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/security

/obj/item/clothing/suit/space/hardsuit/ert/gamma/security
	name = "elite emergency response team security suit"
	icon_state = "ert_gsecurity"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/security

//Engineer
/obj/item/clothing/head/helmet/space/hardsuit/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "A helmet worn by engineers of a Nanotrasen Emergency Response Team. Has yellow highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_engineer"
	item_state = "helm-orange"
	item_color = "ert_engineer"

//Engineer
/obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/engineer
	name = "elite emergency response team engineer helmet"
	icon_state = "hardsuit0-gammaengineer"
	item_color = "gammaengineer"

/obj/item/clothing/suit/space/hardsuit/ert/engineer
	name = "emergency response team engineer suit"
	desc = "A suit worn by the engineers of a Nanotrasen Emergency Response Team. Has yellow highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_engineer"
	item_state = "suit-orange"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engineer

/obj/item/clothing/suit/space/hardsuit/ert/gamma/engineer
	name = "elite emergency response team engineer suit"
	icon_state = "ert_gengineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/engineer

//Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/medical
	name = "emergency response team medical helmet"
	desc = "A helmet worn by medical members of a Nanotrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_medical"
	item_color = "ert_medical"

/obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/medical
	name = "elite emergency response team medical helmet"
	icon_state = "hardsuit0-gammamedical"
	item_color = "gammamedical"

/obj/item/clothing/suit/space/hardsuit/ert/medical
	name = "emergency response team medical suit"
	desc = "A suit worn by medical members of a Nanotrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/medical

/obj/item/clothing/suit/space/hardsuit/ert/gamma/medical
	name = "elite emergency response team medical suit"
	icon_state = "ert_gmedical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/medical

//Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/janitor
	name = "emergency response team janitor helmet"
	desc = "A helmet worn by janitorial members of a Nanotrasen Emergency Response Team. Has purple highlights. Armoured and space ready."
	icon_state = "hardsuit0-ert_janitor"
	item_color = "ert_janitor"

/obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/janitor
	name = "elite emergency response team janitor helmet"
	icon_state = "hardsuit0-gammajanitor"
	item_color = "gammajanitor"

/obj/item/clothing/suit/space/hardsuit/ert/janitor
	name = "emergency response team janitor suit"
	desc = "A suit worn by the janitorial of a Nanotrasen Emergency Response Team. Has purple highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/janitor

/obj/item/clothing/suit/space/hardsuit/ert/gamma/janitor
	name = "elite emergency response team janitor suit"
	icon_state = "ert_gjanitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/gamma/janitor

//Paranormal
/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response unit helmet"
	desc = "A helmet worn by those who deal with paranormal threats for a living."
	icon_state = "hardsuit0-ert_paranormal"
	item_color = "ert_paranormal"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	resistance_flags = FIRE_PROOF
	has_camera = FALSE
	sprite_sheets = list(
		"Grey" = 'icons/mob/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/helmet.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team suit"
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats."
	icon_state = "hardsuit-paranormal"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	jetpack = null
	resistance_flags = FIRE_PROOF
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/suit.dmi'
		)
	hide_tail_by_species = list("Unathi, Tajaran, Vox, Vulpkanin")

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/New()
	..()
	new /obj/item/nullrod(src)

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inquisitor"
	item_color = "inquisitor"
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inquisitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/berserker
	name = "champion's helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "hardsuit0-berserker"
	item_color = "berserker"
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/berserker
	name = "champion's hardsuit"
	desc = "Voices echo from the hardsuit, driving the user insane."
	icon_state = "hardsuit-berserker"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/berserker
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 80, acid = 80)

// Solgov

/obj/item/clothing/head/helmet/space/hardsuit/ert/solgov
	name = "Trans-Solar Federation Specops Marine helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	desc = "A helmet worn by marines of the Trans-Solar Federation. Armored, space ready, and fireproof."
	icon_state = "hardsuit0-solgovmarine"
	item_state = "hardsuit0-solgovmarine"
	item_color = "solgovmarine"
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ert/solgov
	name = "Trans-Solar Federation Specops Marine hardsuit"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	desc = "A suit worn by marines of the Trans-Solar Federation. Armored, space ready, and fireproof."
	icon_state = "ert_solgov_marine"
	item_state = "ert_solgov_marine"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/solgov
	slowdown = 0
	species_restricted = list("Human", "Slime People", "Skeleton", "Nucleation", "Machine")
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

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

	//Deathsquad hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 10, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	vision_flags = SEE_MOBS
	actions_types = null
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these
	see_in_dark = 8
	HUDType = MEDHUD
	strip_delay = 130

/obj/item/clothing/suit/space/hardsuit/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored, advanced space suit that protects against most forms of damage."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals,/obj/item/kitchen/knife/combat)
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 10, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	flags_inv = HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	jetpack = /obj/item/tank/jetpack/suit
	strip_delay = 130
	slowdown = 0
	dog_fashion = /datum/dog_fashion/back/deathsquad

	sprite_sheets = list(
		"Monkey" = 'icons/mob/species/monkey/suit.dmi',
		"Farwa" = 'icons/mob/species/monkey/suit.dmi',
		"Wolpin" = 'icons/mob/species/monkey/suit.dmi',
		"Neara" = 'icons/mob/species/monkey/suit.dmi',
		"Stok" = 'icons/mob/species/monkey/suit.dmi'
	)

