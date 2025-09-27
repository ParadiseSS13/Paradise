//Basic biosuit, white and yellow
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	desc = "A hood that protects the head and face from biological contaminants."
	icon = 'icons/obj/clothing/head/bio.dmi'
	icon_state = "bio"
	worn_icon = 'icons/mob/clothing/head/bio.dmi'
	permeability_coefficient = 0.01
	flags = BLOCKHAIR | THICKMATERIAL
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 200, FIRE = 20, ACID = INFINITY)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	resistance_flags = ACID_PROOF
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head/bio.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/head/bio.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head/bio.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head/bio.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head/bio.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head/bio.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head/bio.dmi'
	)

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon = 'icons/obj/clothing/suits/bio.dmi'
	icon_state = "bio"
	worn_icon = 'icons/mob/clothing/suits/bio.dmi'
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 0.45
	allowed = list(/obj/item/tank/internals/, /obj/item/pen, /obj/item/flashlight/pen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 200, FIRE = 20, ACID = INFINITY)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	strip_delay = 70
	put_on_delay = 70
	resistance_flags = ACID_PROOF
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suits/bio.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suits/bio.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suits/bio.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suits/bio.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/bio.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/bio.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suits/bio.dmi'
		)

//Medical biosuit, white with blue
/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"

//Virology biosuit, white with green
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"

//Security biosuit, white with red and a vest
/obj/item/clothing/head/bio_hood/security
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 200, FIRE = 20, ACID = INFINITY)
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 200, FIRE = 20, ACID = INFINITY)
	icon_state = "bio_security"

//Janitor's biosuit, grey with purple
/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"

//Scientist's biosuit, white with purple
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"

//CMO's biosuit, blue with white
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"

//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	strip_delay = 40
	put_on_delay = 20
	hide_tail_by_species = list("Unathi", "Tajaran", "Vulpkanin")
